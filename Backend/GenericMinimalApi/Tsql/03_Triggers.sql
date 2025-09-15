-- functions section

-- logic to find previous value based on OrderIndex and hierarchy for calculating GrowthSinceLastPeriod
-- If current indicator's OrderIndex = 1:
--    Step 1: Check parent's OrderIndex
--    Step 2: If parent's OrderIndex > 1:
--         - Find parent's previous sibling (OrderIndex - 1)
--         - In that previous sibling, find child with highest OrderIndex
--         - Use that value as previous value
--    Step 3: If parent's OrderIndex = 1:
--         - Go to grandparent level
--         - Repeat Step 2 logic recursively
CREATE OR ALTER   FUNCTION [dbo].[fn_FindPreviousValue](@CurrentIndicatorId INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @PreviousValue FLOAT;
    DECLARE @CurrentOrderIndex INT, @ParentId INT, @Level INT = 0;
    
    -- Get current indicator details
    SELECT @CurrentOrderIndex = OrderIndex, @ParentId = ParentId
    FROM Indicators WHERE Id = @CurrentIndicatorId;
    
    -- Case 1: OrderIndex > 1 - simple case
    IF @CurrentOrderIndex > 1
    BEGIN
        SELECT @PreviousValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        WHERE i.ParentId = @ParentId
          AND i.OrderIndex = @CurrentOrderIndex - 1;
        RETURN @PreviousValue;
    END
    
    -- Case 2: OrderIndex = 1 - recursive search up hierarchy
    DECLARE @CurrentLevelId INT = @CurrentIndicatorId;
    
    WHILE @ParentId IS NOT NULL
    BEGIN
        -- Move up one level
        SELECT @CurrentLevelId = @ParentId;
        SELECT @CurrentOrderIndex = OrderIndex, @ParentId = ParentId
        FROM Indicators WHERE Id = @CurrentLevelId;
        
        -- If we found a level with OrderIndex > 1
        IF @CurrentOrderIndex > 1
        BEGIN
            -- Find previous sibling at this level
            DECLARE @PreviousSiblingId INT;
            SELECT @PreviousSiblingId = Id
            FROM Indicators
            WHERE ParentId = (SELECT ParentId FROM Indicators WHERE Id = @CurrentLevelId)
              AND OrderIndex = @CurrentOrderIndex - 1;
            
            -- Find last descendant of previous sibling
            DECLARE @LastDescendantId INT;
            SELECT @LastDescendantId = Id
            FROM Indicators
            WHERE ParentId = @PreviousSiblingId
              AND OrderIndex = (SELECT MAX(OrderIndex) FROM Indicators WHERE ParentId = @PreviousSiblingId);
            
            -- Get the value
            SELECT @PreviousValue = Value
            FROM DataValues
            WHERE IndicatorId = @LastDescendantId            
            BREAK;
        END
        
        SET @Level = @Level + 1;
        
        -- Safety check to prevent infinite loop
        IF @Level > 10 BREAK;
    END
    
    RETURN @PreviousValue;
END
GO





CREATE OR ALTER   FUNCTION [dbo].[fn_FindLastYearValue](
    @CurrentIndicatorId INT,
    @CalendarId INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @LastYearValue FLOAT;
    DECLARE @CurrentIndicatorName NVARCHAR(255);
    DECLARE @CurrentYear INT;
    DECLARE @CurrentMonth INT;
    DECLARE @CurrentDay INT;
    DECLARE @TopLevelId INT;
    DECLARE @LocationId INT;
    
    -- Get current indicator details
    SELECT @CurrentIndicatorName = i.Name, 
           @CurrentYear = c.Year,
           @CurrentMonth = c.Month,
           @CurrentDay = c.Day,
           @TopLevelId = dbo.fn_GetTopLevelParent(i.Id),
           @LocationId = dv.LocationId
    FROM Indicators i
    INNER JOIN DataValues dv ON i.Id = dv.IndicatorId
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Id = @CurrentIndicatorId AND dv.CalendarId = @CalendarId;
    
    -- Try to find exact match (same hierarchy, same indicator name, same month/day, previous year)
    SELECT @LastYearValue = dv.Value
    FROM DataValues dv
    INNER JOIN Indicators i ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Name = @CurrentIndicatorName
      AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId  -- Same hierarchy
      AND c.Year = @CurrentYear - 1
      AND c.Month = @CurrentMonth
      AND c.Day = @CurrentDay
      AND dv.LocationId = @LocationId;
    
    -- If exact date not found, try same month only (ignore day)
    IF @LastYearValue IS NULL
    BEGIN
        SELECT @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @CurrentIndicatorName
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId  -- Same hierarchy
          AND c.Year = @CurrentYear - 1
          AND c.Month = @CurrentMonth
          AND dv.LocationId = @LocationId;
    END
    
    -- If still not found, try same year only (any month/day in previous year)
    IF @LastYearValue IS NULL
    BEGIN
        SELECT @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @CurrentIndicatorName
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId  -- Same hierarchy
          AND c.Year = @CurrentYear - 1
          AND dv.LocationId = @LocationId;
    END
    
    RETURN @LastYearValue;
END
GO


CREATE OR ALTER   FUNCTION [dbo].[fn_GetTopLevelParent] (@IndicatorId INT)
RETURNS INT
AS
BEGIN
    DECLARE @CurrentId INT = @IndicatorId;
    DECLARE @ParentId INT;
    DECLARE @TopLevelId INT = @IndicatorId;

    WHILE @CurrentId IS NOT NULL
    BEGIN
        SELECT @ParentId = ParentId 
        FROM Indicators 
        WHERE Id = @CurrentId;
        
        IF @ParentId IS NOT NULL
        BEGIN
            SET @TopLevelId = @ParentId;
            SET @CurrentId = @ParentId;
        END
        ELSE
        BEGIN
            SET @CurrentId = NULL;
        END
    END

    RETURN @TopLevelId;
END;
GO



CREATE OR ALTER TRIGGER [dbo].[trg_CalculateHierarchicalGrowth]
ON [dbo].[DataValues]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Create a temporary table to store the data we need to update
        CREATE TABLE #DataToUpdate (
            DataValueId INT,
            IndicatorId INT,
            CurrentValue DECIMAL(18,2),
            IndicatorName NVARCHAR(255),
            ParentId INT,
            TopLevelId INT,
            PreviousValue DECIMAL(18,2),
            HierarchyTotalValue DECIMAL(18,2),
            CalendarId INT,
            CurrentYear INT,
            LastYearValue DECIMAL(18,2)
        );

        -- Insert data into temp table
        INSERT INTO #DataToUpdate (DataValueId, IndicatorId, CurrentValue, IndicatorName, ParentId, CalendarId, CurrentYear)
        SELECT 
            dv.Id, 
            dv.IndicatorId, 
            dv.Value,
            i.Name,
            i.ParentId,
            dv.CalendarId,
            c.Year
        FROM DataValues dv
        INNER JOIN inserted ins ON dv.Id = ins.Id
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id;

        -- Update top level IDs
        UPDATE #DataToUpdate
        SET TopLevelId = dbo.fn_GetTopLevelParent(IndicatorId);

        -- Update previous values (hierarchical growth)
        UPDATE #DataToUpdate
        SET PreviousValue = dbo.fn_FindPreviousValue(IndicatorId);

        -- Update last year values using string year comparison
        UPDATE dtu
        SET LastYearValue = last_year.Value
        FROM #DataToUpdate dtu
        OUTER APPLY (
            -- Extract year number from current indicator name
            SELECT CurrentYearNumber = TRY_CAST(dtu.IndicatorName AS INT)
        ) year_check
        OUTER APPLY (
            -- If it's a year, look for previous year indicator
            SELECT dv.Value
            FROM DataValues dv
            INNER JOIN Indicators i ON dv.IndicatorId = i.Id
            INNER JOIN Calendars c ON dv.CalendarId = c.Id
            WHERE i.ParentId = dtu.ParentId  -- Same parent indicator
              AND i.Name = CAST(year_check.CurrentYearNumber - 1 AS NVARCHAR(4))  -- Previous year as string
              AND dbo.fn_GetTopLevelParent(i.Id) = dtu.TopLevelId  -- Same top-level hierarchy
              AND c.Year = dtu.CurrentYear - 1  -- Previous calendar year
        ) last_year
        WHERE year_check.CurrentYearNumber IS NOT NULL;

        -- Update hierarchy total values
        UPDATE dtu
        SET HierarchyTotalValue = calc.TotalValue
        FROM #DataToUpdate dtu
        CROSS APPLY (
            SELECT SUM(dv_sibling.Value) as TotalValue
            FROM DataValues dv_sibling
            INNER JOIN Indicators i_sibling ON dv_sibling.IndicatorId = i_sibling.Id
            WHERE i_sibling.Name = dtu.IndicatorName  -- Same indicator name
            AND dbo.fn_GetTopLevelParent(i_sibling.Id) = dtu.TopLevelId  -- Same top-level hierarchy
        ) calc;

        -- Finally update the main table with all three metrics
        UPDATE dv
        SET 
            GrowthSinceLastPeriod = 
                CASE 
                    WHEN dtu.PreviousValue IS NOT NULL AND dtu.PreviousValue <> 0 THEN
                        ROUND(((dtu.CurrentValue - dtu.PreviousValue) / dtu.PreviousValue) * 100, 2)
                    WHEN dtu.PreviousValue = 0 AND dtu.CurrentValue <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END,
            PercentageOfParentTotal = 
                CASE 
                    WHEN dtu.HierarchyTotalValue IS NOT NULL AND dtu.HierarchyTotalValue <> 0 THEN
                        ROUND((dtu.CurrentValue / dtu.HierarchyTotalValue) * 100, 2)
                    ELSE
                        0.0
                END,
            GrowthSinceLastYearPeriod = 
                CASE 
                    WHEN dtu.LastYearValue IS NOT NULL AND dtu.LastYearValue <> 0 THEN
                        ROUND(((dtu.CurrentValue - dtu.LastYearValue) / dtu.LastYearValue) * 100, 2)
                    WHEN dtu.LastYearValue = 0 AND dtu.CurrentValue <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END
        FROM DataValues dv
        INNER JOIN #DataToUpdate dtu ON dv.Id = dtu.DataValueId;

        -- Clean up
        DROP TABLE #DataToUpdate;
    END
END;
GO