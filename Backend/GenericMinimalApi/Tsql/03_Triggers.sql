CREATE OR ALTER TRIGGER [dbo].[trg_CalculateImpactMetrics]
ON [dbo].[DataValues]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- For INSERT and UPDATE operations
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE current_dv
        SET 
            -- 1. Percentage of GLOBAL TOTAL for ALL indicators with same name (no CalendarId filter)
            PercentageOfParentTotal = 
                CASE 
                    WHEN global_total.GlobalTotalValue IS NOT NULL AND global_total.GlobalTotalValue <> 0 THEN
                        ROUND((current_dv.Value / global_total.GlobalTotalValue) * 100, 2)
                    ELSE
                        0.0
                END,
            
            -- 2. Growth since previous indicator using OrderIndex hierarchy
            GrowthSinceLastPeriod = 
                CASE 
                    WHEN previous_indicator.PreviousValue IS NOT NULL AND previous_indicator.PreviousValue <> 0 THEN
                        ROUND(((current_dv.Value - previous_indicator.PreviousValue) / previous_indicator.PreviousValue) * 100, 2)
                    WHEN previous_indicator.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END,
            
            -- 3. Growth since same period last year (with fallback to same month only)
            GrowthSinceLastYearPeriod = 
                CASE 
                    -- Exact date match found
                    WHEN last_year_value.ExactMatchValue IS NOT NULL AND last_year_value.ExactMatchValue <> 0 THEN
                        ROUND(((current_dv.Value - last_year_value.ExactMatchValue) / last_year_value.ExactMatchValue) * 100, 2)
                    WHEN last_year_value.ExactMatchValue = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    
                    -- Same month match found (fallback)
                    WHEN last_year_value.ExactMatchValue IS NULL AND last_year_value.SameMonthValue IS NOT NULL AND last_year_value.SameMonthValue <> 0 THEN
                        ROUND(((current_dv.Value - last_year_value.SameMonthValue) / last_year_value.SameMonthValue) * 100, 2)
                    WHEN last_year_value.ExactMatchValue IS NULL AND last_year_value.SameMonthValue = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    
                    -- No previous year data found
                    ELSE
                        0.0
                END
            
        FROM DataValues current_dv
        INNER JOIN inserted i ON current_dv.Id = i.Id
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        INNER JOIN Calendars current_cal ON current_dv.CalendarId = current_cal.Id
        
        -- Calculate GLOBAL TOTAL for ALL indicators with same name (NO CalendarId filter)
        OUTER APPLY (
            SELECT 
                SUM(dv_global.Value) as GlobalTotalValue
            FROM DataValues dv_global
            INNER JOIN Indicators i_global ON dv_global.IndicatorId = i_global.Id
            WHERE i_global.Name = current_i.Name
        ) global_total
        
        -- Find previous value using OrderIndex hierarchy
        OUTER APPLY (
            SELECT TOP 1 prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            WHERE prev_i.Name = current_i.Name
              AND prev_i.ParentId = current_i.ParentId
              AND prev_i.OrderIndex = current_i.OrderIndex - 1
              AND prev_dv.CalendarId = current_dv.CalendarId
            
            UNION ALL
            
            SELECT TOP 1 prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            INNER JOIN Indicators prev_parent ON prev_i.ParentId = prev_parent.Id
            INNER JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
            WHERE prev_i.Name = current_i.Name
              AND prev_parent.ParentId = current_parent.ParentId
              AND prev_parent.OrderIndex = current_parent.OrderIndex - 1
              AND prev_i.OrderIndex = (SELECT MAX(OrderIndex) FROM Indicators WHERE ParentId = prev_parent.Id)
              AND prev_dv.CalendarId = current_dv.CalendarId
              
            ORDER BY 
                CASE WHEN prev_i.ParentId = current_i.ParentId THEN 1 ELSE 2 END
        ) previous_indicator
        
        -- Find value from same period last year with fallback to same month only
        OUTER APPLY (
            SELECT 
                -- Exact date match
                (SELECT TOP 1 last_year_dv.Value
                 FROM DataValues last_year_dv
                 INNER JOIN Indicators last_year_i ON last_year_dv.IndicatorId = last_year_i.Id
                 INNER JOIN Calendars last_year_cal ON last_year_dv.CalendarId = last_year_cal.Id
                 WHERE last_year_i.Name = current_i.Name
                   AND last_year_cal.Year = current_cal.Year - 1
                   AND last_year_cal.Month = current_cal.Month
                   AND last_year_cal.Day = current_cal.Day) as ExactMatchValue,
                
                -- Same month fallback (only if exact date not found)
                (SELECT TOP 1 last_year_dv.Value
                 FROM DataValues last_year_dv
                 INNER JOIN Indicators last_year_i ON last_year_dv.IndicatorId = last_year_i.Id
                 INNER JOIN Calendars last_year_cal ON last_year_dv.CalendarId = last_year_cal.Id
                 WHERE last_year_i.Name = current_i.Name
                   AND last_year_cal.Year = current_cal.Year - 1
                   AND last_year_cal.Month = current_cal.Month
                   AND NOT EXISTS (
                       SELECT 1 
                       FROM DataValues exact_dv
                       INNER JOIN Indicators exact_i ON exact_dv.IndicatorId = exact_i.Id
                       INNER JOIN Calendars exact_cal ON exact_dv.CalendarId = exact_cal.Id
                       WHERE exact_i.Name = current_i.Name
                         AND exact_cal.Year = current_cal.Year - 1
                         AND exact_cal.Month = current_cal.Month
                         AND exact_cal.Day = current_cal.Day
                   )
                 ORDER BY last_year_cal.Day DESC) as SameMonthValue
        ) last_year_value;
    END
END;
GO