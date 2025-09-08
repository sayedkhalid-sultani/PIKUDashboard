SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_CalculateImpactMetrics]
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
            -- 1. Percentage of Total within the SAME PARENT
            PercentageOfParentTotal = 
                CASE 
                    WHEN parent_total.ParentTotalValue IS NOT NULL AND parent_total.ParentTotalValue <> 0 THEN
                        ROUND((current_dv.Value / parent_total.ParentTotalValue) * 100, 2)
                    ELSE
                        0.0
                END,
            
            -- 2. Growth since previous parent for the SAME indicator name
            GrowthSinceLastPeriod = 
                CASE 
                    WHEN previous_parent.PreviousValue IS NOT NULL AND previous_parent.PreviousValue <> 0 THEN
                        ROUND(((current_dv.Value - previous_parent.PreviousValue) / previous_parent.PreviousValue) * 100, 2)
                    WHEN previous_parent.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END
            
        FROM DataValues current_dv
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        INNER JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
        
        -- Calculate TOTAL within the SAME PARENT (all children of the same parent)
        OUTER APPLY (
            SELECT 
                SUM(dv_sibling.Value) as ParentTotalValue
            FROM DataValues dv_sibling
            INNER JOIN Indicators i_sibling ON dv_sibling.IndicatorId = i_sibling.Id
            WHERE i_sibling.ParentId = current_parent.Id  -- Same parent
              AND dv_sibling.CalendarId = current_dv.CalendarId  -- Same period
        ) parent_total
        
        -- Find value from previous parent for the SAME indicator name using OrderIndex
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            INNER JOIN Indicators prev_parent ON prev_i.ParentId = prev_parent.Id
            WHERE prev_i.Name = current_i.Name  -- Exact same indicator name
              AND prev_parent.ParentId = current_parent.ParentId  -- Same grandparent
              AND prev_parent.OrderIndex = current_parent.OrderIndex - 1  -- Previous OrderIndex
              AND prev_dv.CalendarId = current_dv.CalendarId  -- Same period
        ) previous_parent;
    END
END;
GO