-- This trigger automatically recalculates Growth and Total values based on ChartConfigs settings: 
-- when CalculateGrowthBy is set to 'Legend' it calculates percentage growth across categories, when set to 'Indicator' it calculates within each indicator; similarly, CalculateTotalBy determines whether totals are summed by 'Legend' categories or individual 'Indicator' values,
-- ensuring dynamic accuracy based on configuration.

IF OBJECT_ID('trg_CalculateGrowthAndTotalMetrics', 'TR') IS NOT NULL
    DROP TRIGGER trg_CalculateGrowthAndTotalMetrics;
GO

CREATE TRIGGER [dbo].[trg_CalculateGrowthAndTotalMetrics]
ON [dbo].[DataValues]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- For DELETE operations, recalculate growth and total for affected records
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Get affected indicator names from deleted records
        DECLARE @AffectedIndicatorNames TABLE (IndicatorName NVARCHAR(255));
        
        INSERT INTO @AffectedIndicatorNames (IndicatorName)
        SELECT DISTINCT i.Name
        FROM deleted d
        INNER JOIN Indicators i ON d.IndicatorId = i.Id;

        -- Recalculate growth and total for all records with affected indicator names
        UPDATE current_dv
        SET 
            Growth = 
                CASE 
                    -- Check CalculateGrowthBy setting for the chart
                    WHEN cc.CalculateGrowthBy = 'legend' THEN
                        -- LEGEND MODE: Calculate growth within same parent group
                        CASE 
                            WHEN legend_prev.PreviousValue IS NOT NULL AND legend_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - legend_prev.PreviousValue) / legend_prev.PreviousValue) * 100, 2)
                            WHEN legend_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Calculate growth across different parents
                        CASE 
                            WHEN indicator_prev.PreviousValue IS NOT NULL AND indicator_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - indicator_prev.PreviousValue) / indicator_prev.PreviousValue) * 100, 2)
                            WHEN indicator_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                END,
            Total = 
                CASE 
                    -- Check CalculateTotalBy setting for the chart
                    WHEN cc.CalculateTotalBy = 'legend' THEN
                        -- LEGEND MODE: Calculate total within same parent group
                        CASE 
                            WHEN legend_total.AbsoluteLegendTotal IS NOT NULL AND legend_total.AbsoluteLegendTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / legend_total.AbsoluteLegendTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Calculate total across all instances of same indicator
                        CASE 
                            WHEN indicator_total.AbsoluteIndicatorTotal IS NOT NULL AND indicator_total.AbsoluteIndicatorTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / indicator_total.AbsoluteIndicatorTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                END
        FROM DataValues current_dv
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        INNER JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
        INNER JOIN @AffectedIndicatorNames ain ON current_i.Name = ain.IndicatorName
        -- Get ChartConfig to check CalculateGrowthBy and CalculateTotalBy settings
        LEFT JOIN Indicators chart_i ON current_parent.ParentId = chart_i.Id OR (current_parent.ParentId IS NULL AND current_parent.Id = chart_i.Id)
        LEFT JOIN ChartConfigs cc ON chart_i.Id = cc.IndicatorId
        -- For LEGEND mode Growth calculation (within same parent) - exclude deleted records
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            WHERE prev_i.ParentId = current_i.ParentId  -- SAME PARENT
              AND prev_i.OrderIndex < current_i.OrderIndex  -- LOWER ORDERINDEX
              AND prev_i.Id <> current_i.Id  -- DIFFERENT INDICATOR
              AND prev_dv.Id NOT IN (SELECT Id FROM deleted)  -- EXCLUDE DELETED RECORDS
            ORDER BY prev_i.OrderIndex DESC  -- MOST RECENT PREVIOUS
        ) legend_prev
        -- For INDICATOR mode Growth calculation (across different parents) - exclude deleted records
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            INNER JOIN Indicators prev_parent ON prev_i.ParentId = prev_parent.Id
            WHERE prev_i.Name = current_i.Name  -- SAME INDICATOR NAME
              AND prev_i.ParentId <> current_i.ParentId  -- DIFFERENT PARENT
              AND prev_parent.OrderIndex < current_parent.OrderIndex  -- EARLIER PARENT
              AND prev_dv.Id NOT IN (SELECT Id FROM deleted)  -- EXCLUDE DELETED RECORDS
            ORDER BY prev_parent.OrderIndex DESC  -- MOST RECENT PREVIOUS PARENT
        ) indicator_prev
        -- For LEGEND mode Total calculation (within same parent group)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_legend.Value)) as AbsoluteLegendTotal
            FROM DataValues dv_legend
            INNER JOIN Indicators i_legend ON dv_legend.IndicatorId = i_legend.Id
            WHERE i_legend.ParentId = current_i.ParentId  -- SAME PARENT GROUP
              AND dv_legend.Id NOT IN (SELECT Id FROM deleted)  -- EXCLUDE DELETED RECORDS
        ) legend_total
        -- For INDICATOR mode Total calculation (across all instances)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_indicator.Value)) as AbsoluteIndicatorTotal
            FROM DataValues dv_indicator
            INNER JOIN Indicators i_indicator ON dv_indicator.IndicatorId = i_indicator.Id
            WHERE i_indicator.Name = current_i.Name  -- SAME INDICATOR NAME
              AND dv_indicator.Id NOT IN (SELECT Id FROM deleted)  -- EXCLUDE DELETED RECORDS
        ) indicator_total
        -- Exclude currently deleted records from being updated
        WHERE current_dv.Id NOT IN (SELECT Id FROM deleted);
    END

    -- For INSERT and UPDATE operations, recalculate affected indicators
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Determine which indicators need recalculation
        DECLARE @AffectedIndicatorNames2 TABLE (IndicatorName NVARCHAR(255));
        
        INSERT INTO @AffectedIndicatorNames2 (IndicatorName)
        SELECT DISTINCT i.Name
        FROM inserted ins
        INNER JOIN Indicators i ON ins.IndicatorId = i.Id;

        -- Recalculate both Growth and Total for affected indicators
        UPDATE current_dv
        SET 
            Growth = 
                CASE 
                    -- Check CalculateGrowthBy setting for the chart
                    WHEN cc.CalculateGrowthBy = 'legend' THEN
                        -- LEGEND MODE: Calculate growth within same parent group
                        CASE 
                            WHEN legend_prev.PreviousValue IS NOT NULL AND legend_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - legend_prev.PreviousValue) / legend_prev.PreviousValue) * 100, 2)
                            WHEN legend_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Default calculation
                        CASE 
                            WHEN indicator_prev.PreviousValue IS NOT NULL AND indicator_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - indicator_prev.PreviousValue) / indicator_prev.PreviousValue) * 100, 2)
                            WHEN indicator_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                END,
            Total = 
                CASE 
                    -- Check CalculateTotalBy setting for the chart
                    WHEN cc.CalculateTotalBy = 'legend' THEN
                        -- LEGEND MODE: Calculate total within same parent group
                        CASE 
                            WHEN legend_total.AbsoluteLegendTotal IS NOT NULL AND legend_total.AbsoluteLegendTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / legend_total.AbsoluteLegendTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Calculate total across all instances of same indicator
                        CASE 
                            WHEN indicator_total.AbsoluteIndicatorTotal IS NOT NULL AND indicator_total.AbsoluteIndicatorTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / indicator_total.AbsoluteIndicatorTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                END
        FROM DataValues current_dv
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        INNER JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
        INNER JOIN @AffectedIndicatorNames2 ain ON current_i.Name = ain.IndicatorName
        -- Get ChartConfig to check CalculateGrowthBy and CalculateTotalBy settings
        LEFT JOIN Indicators chart_i ON current_parent.ParentId = chart_i.Id OR (current_parent.ParentId IS NULL AND current_parent.Id = chart_i.Id)
        LEFT JOIN ChartConfigs cc ON chart_i.Id = cc.IndicatorId
        -- For LEGEND mode Growth calculation (within same parent)
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            WHERE prev_i.ParentId = current_i.ParentId  -- SAME PARENT
              AND prev_i.OrderIndex < current_i.OrderIndex  -- LOWER ORDERINDEX
              AND prev_i.Id <> current_i.Id  -- DIFFERENT INDICATOR
            ORDER BY prev_i.OrderIndex DESC  -- MOST RECENT PREVIOUS
        ) legend_prev
        -- For INDICATOR mode Growth calculation (across different parents)
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            INNER JOIN Indicators prev_parent ON prev_i.ParentId = prev_parent.Id
            WHERE prev_i.Name = current_i.Name  -- SAME INDICATOR NAME
              AND prev_i.ParentId <> current_i.ParentId  -- DIFFERENT PARENT
              AND prev_parent.OrderIndex < current_parent.OrderIndex  -- EARLIER PARENT
            ORDER BY prev_parent.OrderIndex DESC  -- MOST RECENT PREVIOUS PARENT
        ) indicator_prev
        -- For LEGEND mode Total calculation (within same parent group)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_legend.Value)) as AbsoluteLegendTotal
            FROM DataValues dv_legend
            INNER JOIN Indicators i_legend ON dv_legend.IndicatorId = i_legend.Id
            WHERE i_legend.ParentId = current_i.ParentId  -- SAME PARENT GROUP
        ) legend_total
        -- For INDICATOR mode Total calculation (across all instances)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_indicator.Value)) as AbsoluteIndicatorTotal
            FROM DataValues dv_indicator
            INNER JOIN Indicators i_indicator ON dv_indicator.IndicatorId = i_indicator.Id
            WHERE i_indicator.Name = current_i.Name  -- SAME INDICATOR NAME
        ) indicator_total;
    END
END;
GO
-- This trigger automatically recalculates and updates all Growth and Total metric values in the DataValues table
-- whenever the calculation methodology (CalculateGrowthBy or CalculateTotalBy settings) is modified in the ChartConfigs
-- table, ensuring that all existing data immediately reflects any changes to the calculation rules without manual intervention.

IF OBJECT_ID('trg_RecalculateMetricsOnConfigChange', 'TR') IS NOT NULL
    DROP TRIGGER trg_RecalculateMetricsOnConfigChange;
GO

CREATE TRIGGER [dbo].[trg_RecalculateMetricsOnConfigChange]
ON [dbo].[ChartConfigs]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if CalculateGrowthBy or CalculateTotalBy columns were updated
    IF UPDATE(CalculateGrowthBy) OR UPDATE(CalculateTotalBy)
    BEGIN
        -- Get affected chart indicators and their config changes
        DECLARE @AffectedCharts TABLE (
            ChartIndicatorId INT,
            CalculateGrowthBy NVARCHAR(50),
            CalculateTotalBy NVARCHAR(50)
        );
        
        INSERT INTO @AffectedCharts (ChartIndicatorId, CalculateGrowthBy, CalculateTotalBy)
        SELECT DISTINCT 
            i.IndicatorId,
            i.CalculateGrowthBy,
            i.CalculateTotalBy
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id
        WHERE i.CalculateGrowthBy <> d.CalculateGrowthBy
           OR i.CalculateTotalBy <> d.CalculateTotalBy;

        -- If no changes, exit
        IF NOT EXISTS (SELECT 1 FROM @AffectedCharts)
            RETURN;

        -- Recalculate both Growth and Total for all DataValues related to these charts
        UPDATE current_dv
        SET 
            Growth = 
                CASE 
                    -- Check CalculateGrowthBy setting for the chart
                    WHEN ac.CalculateGrowthBy = 'legend' THEN
                        -- LEGEND MODE: Calculate growth within same parent group
                        CASE 
                            WHEN legend_prev.PreviousValue IS NOT NULL AND legend_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - legend_prev.PreviousValue) / legend_prev.PreviousValue) * 100, 2)
                            WHEN legend_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Calculate growth across different parents
                        CASE 
                            WHEN indicator_prev.PreviousValue IS NOT NULL AND indicator_prev.PreviousValue <> 0 THEN
                                ROUND(((current_dv.Value - indicator_prev.PreviousValue) / indicator_prev.PreviousValue) * 100, 2)
                            WHEN indicator_prev.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                                100.0
                            ELSE
                                0.0
                        END
                END,
            Total = 
                CASE 
                    -- Check CalculateTotalBy setting for the chart
                    WHEN ac.CalculateTotalBy = 'legend' THEN
                        -- LEGEND MODE: Calculate total within same parent group
                        CASE 
                            WHEN legend_total.AbsoluteLegendTotal IS NOT NULL AND legend_total.AbsoluteLegendTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / legend_total.AbsoluteLegendTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                    ELSE
                        -- INDICATOR MODE: Calculate total across all instances of same indicator
                        CASE 
                            WHEN indicator_total.AbsoluteIndicatorTotal IS NOT NULL AND indicator_total.AbsoluteIndicatorTotal <> 0 THEN
                                ROUND((ABS(current_dv.Value) / indicator_total.AbsoluteIndicatorTotal) * 100, 2)
                            ELSE
                                0.0
                        END
                END
        FROM DataValues current_dv
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        INNER JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
        -- Find the chart-level indicator (go up the hierarchy until we find the chart root)
        CROSS APPLY (
            -- If current parent has a parent, that's the chart, otherwise current parent is the chart
            SELECT 
                CASE 
                    WHEN current_parent.ParentId IS NOT NULL THEN current_parent.ParentId
                    ELSE current_parent.Id
                END as ChartIndicatorId
        ) chart_finder
        INNER JOIN @AffectedCharts ac ON chart_finder.ChartIndicatorId = ac.ChartIndicatorId
        -- For LEGEND mode Growth calculation (within same parent group)
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            WHERE prev_i.ParentId = current_i.ParentId  -- SAME PARENT
              AND prev_i.OrderIndex < current_i.OrderIndex  -- LOWER ORDERINDEX
              AND prev_i.Id <> current_i.Id  -- DIFFERENT INDICATOR
              AND prev_dv.CalendarId = current_dv.CalendarId  -- SAME PERIOD
              AND prev_dv.LocationId = current_dv.LocationId  -- SAME LOCATION
            ORDER BY prev_i.OrderIndex DESC  -- MOST RECENT PREVIOUS
        ) legend_prev
        -- For INDICATOR mode Growth calculation (across different parents)
        OUTER APPLY (
            SELECT TOP 1 
                prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            INNER JOIN Indicators prev_parent ON prev_i.ParentId = prev_parent.Id
            WHERE prev_i.Name = current_i.Name  -- SAME INDICATOR NAME
              AND prev_i.ParentId <> current_i.ParentId  -- DIFFERENT PARENT
              AND prev_parent.OrderIndex < current_parent.OrderIndex  -- EARLIER PARENT
              AND prev_dv.CalendarId = current_dv.CalendarId  -- SAME PERIOD
              AND prev_dv.LocationId = current_dv.LocationId  -- SAME LOCATION
            ORDER BY prev_parent.OrderIndex DESC  -- MOST RECENT PREVIOUS PARENT
        ) indicator_prev
        -- For LEGEND mode Total calculation (within same parent group)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_legend.Value)) as AbsoluteLegendTotal
            FROM DataValues dv_legend
            INNER JOIN Indicators i_legend ON dv_legend.IndicatorId = i_legend.Id
            WHERE i_legend.ParentId = current_i.ParentId  -- SAME PARENT GROUP
              AND dv_legend.CalendarId = current_dv.CalendarId  -- SAME PERIOD
              AND dv_legend.LocationId = current_dv.LocationId  -- SAME LOCATION
        ) legend_total
        -- For INDICATOR mode Total calculation (across all instances)
        OUTER APPLY (
            SELECT 
                SUM(ABS(dv_indicator.Value)) as AbsoluteIndicatorTotal
            FROM DataValues dv_indicator
            INNER JOIN Indicators i_indicator ON dv_indicator.IndicatorId = i_indicator.Id
            WHERE i_indicator.Name = current_i.Name  -- SAME INDICATOR NAME
              AND dv_indicator.CalendarId = current_dv.CalendarId  -- SAME PERIOD
              AND dv_indicator.LocationId = current_dv.LocationId  -- SAME LOCATION
        ) indicator_total;
    END
END;
GO

