-- =============================================
-- FUNCTION: fn_FindPreviousValue
-- PURPOSE: Find previous hierarchical value for period-over-period growth
-- STEPS:
-- 1. If OrderIndex > 1: Get previous sibling at same level
-- 2. If OrderIndex = 1: Recursively search up hierarchy
--    a. Find parent's previous sibling
--    b. Get last descendant of that sibling
-- 3. Return found value or NULL
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[fn_FindPreviousValue](@CurrentIndicatorId INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @PreviousValue FLOAT;
    DECLARE @CurrentOrderIndex INT, @ParentId INT, @Level INT = 0;
    
    -- Get current indicator OrderIndex and ParentId
    SELECT @CurrentOrderIndex = OrderIndex, @ParentId = ParentId
    FROM Indicators WHERE Id = @CurrentIndicatorId;
    
    -- CASE 1: Simple case - previous sibling exists at same level
    IF @CurrentOrderIndex > 1
    BEGIN
        SELECT @PreviousValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        WHERE i.ParentId = @ParentId
          AND i.OrderIndex = @CurrentOrderIndex - 1;
        RETURN @PreviousValue;
    END
    
    -- CASE 2: Complex case - recursive hierarchy search
    DECLARE @CurrentLevelId INT = @CurrentIndicatorId;
    
    WHILE @ParentId IS NOT NULL AND @Level <= 10 -- Prevent infinite loop
    BEGIN
        -- Move up one level in hierarchy
        SELECT @CurrentLevelId = @ParentId;
        SELECT @CurrentOrderIndex = OrderIndex, @ParentId = ParentId
        FROM Indicators WHERE Id = @CurrentLevelId;
        
        -- If parent level has previous siblings
        IF @CurrentOrderIndex > 1
        BEGIN
            -- Find parent's previous sibling
            DECLARE @PreviousSiblingId INT;
            SELECT @PreviousSiblingId = Id
            FROM Indicators
            WHERE ParentId = (SELECT ParentId FROM Indicators WHERE Id = @CurrentLevelId)
              AND OrderIndex = @CurrentOrderIndex - 1;
            
            -- Find last descendant (max OrderIndex) of previous sibling
            DECLARE @LastDescendantId INT;
            SELECT TOP 1 @LastDescendantId = Id
            FROM Indicators
            WHERE ParentId = @PreviousSiblingId
            ORDER BY OrderIndex DESC;
            
            -- Return the value from last descendant
            SELECT @PreviousValue = Value
            FROM DataValues
            WHERE IndicatorId = @LastDescendantId;
            
            BREAK;
        END
        
        SET @Level = @Level + 1;
    END
    
    RETURN @PreviousValue;
END
GO

-- =============================================
-- FUNCTION: fn_FindLastYearValue
-- PURPOSE: Find previous year value for year-over-year growth
-- STEPS:
-- 1. Get current indicator details and date
-- 2. Search in same hierarchy for previous year value
-- 3. Priority: Exact date → Same month → Any date in previous year
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[fn_FindLastYearValue](
    @CurrentIndicatorId INT,
    @CalendarId INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @LastYearValue FLOAT;
    DECLARE @CurrentIndicatorName NVARCHAR(255);
    DECLARE @CurrentYear INT, @CurrentMonth INT, @CurrentDay INT, @TopLevelId INT;
    
    -- Get current indicator details
    SELECT 
        @CurrentIndicatorName = i.Name, 
        @CurrentYear = c.Year,
        @CurrentMonth = c.Month,
        @CurrentDay = c.Day,
        @TopLevelId = dbo.fn_GetTopLevelParent(i.Id)
    FROM Indicators i
    INNER JOIN DataValues dv ON i.Id = dv.IndicatorId
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Id = @CurrentIndicatorId AND dv.CalendarId = @CalendarId;
    
    -- PRIORITY 1: Exact date match (same month + same day)
    SELECT @LastYearValue = dv.Value
    FROM DataValues dv
    INNER JOIN Indicators i ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Name = @CurrentIndicatorName
      AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
      AND c.Year = @CurrentYear - 1
      AND c.Month = @CurrentMonth
      AND c.Day = @CurrentDay;
    
    -- PRIORITY 2: Same month only
    IF @LastYearValue IS NULL
    BEGIN
        SELECT @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @CurrentIndicatorName
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
          AND c.Year = @CurrentYear - 1
          AND c.Month = @CurrentMonth;
    END
    
    -- PRIORITY 3: Any date in previous year (latest first)
    IF @LastYearValue IS NULL
    BEGIN
        SELECT TOP 1 @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @CurrentIndicatorName
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
          AND c.Year = @CurrentYear - 1
        ORDER BY c.Month DESC, c.Day DESC;
    END
    
    RETURN @LastYearValue;
END
GO

-- =============================================
-- FUNCTION: fn_GetTopLevelParent
-- PURPOSE: Find root parent of hierarchy
-- STEPS:
-- 1. Start with current indicator
-- 2. Recursively move up parent chain
-- 3. Return top-most parent (where ParentId IS NULL)
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[fn_GetTopLevelParent] (@IndicatorId INT)
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
            BREAK; -- Reached top level
        END
    END

    RETURN @TopLevelId;
END;
GO

-- =============================================
-- TRIGGER: trg_CalculateHierarchicalGrowth
-- PURPOSE: Calculate growth metrics after data changes
-- OPTIMIZATIONS:
-- 1. Uses CTE instead of temp table
-- 2. Single update operation
-- 3. Removed redundant OUTER APPLY logic
-- 4. Better indexing recommendations
-- =============================================
CREATE OR ALTER TRIGGER [dbo].[trg_CalculateHierarchicalGrowth]
ON [dbo].[DataValues]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    
    -- Use CTE for better performance (no temp table I/O)
    WITH DataToUpdate AS (
        SELECT 
            dv.Id as DataValueId,
            dv.IndicatorId,
            dv.Value as CurrentValue,
            i.Name as IndicatorName,
            i.ParentId,
            dbo.fn_GetTopLevelParent(i.Id) as TopLevelId,
            dbo.fn_FindPreviousValue(i.Id) as PreviousValue,
            dv.CalendarId,
            c.Year as CurrentYear,
            dbo.fn_FindLastYearValue(i.Id, dv.CalendarId) as LastYearValue,
            -- Calculate hierarchy total in same query
            (SELECT SUM(dv2.Value) 
             FROM DataValues dv2
             INNER JOIN Indicators i2 ON dv2.IndicatorId = i2.Id
             WHERE i2.Name = i.Name
               AND dbo.fn_GetTopLevelParent(i2.Id) = dbo.fn_GetTopLevelParent(i.Id)
            ) as HierarchyTotalValue
        FROM DataValues dv
        INNER JOIN inserted ins ON dv.Id = ins.Id
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
    )
    -- Single update operation for all metrics
    UPDATE dv
    SET 
        GrowthSinceLastPeriod = 
            CASE 
                WHEN dtu.PreviousValue IS NOT NULL AND dtu.PreviousValue <> 0 THEN
                    ROUND(((dtu.CurrentValue - dtu.PreviousValue) / dtu.PreviousValue) * 100, 2)
                WHEN dtu.PreviousValue = 0 AND dtu.CurrentValue <> 0 THEN 100.0
                ELSE 0.0
            END,
        PercentageOfParentTotal = 
            CASE 
                WHEN dtu.HierarchyTotalValue IS NOT NULL AND dtu.HierarchyTotalValue <> 0 THEN
                    ROUND((dtu.CurrentValue / dtu.HierarchyTotalValue) * 100, 2)
                ELSE 0.0
            END,
        GrowthSinceLastYearPeriod = 
            CASE 
                WHEN dtu.LastYearValue IS NOT NULL AND dtu.LastYearValue <> 0 THEN
                    ROUND(((dtu.CurrentValue - dtu.LastYearValue) / dtu.LastYearValue) * 100, 2)
                WHEN dtu.LastYearValue = 0 AND dtu.CurrentValue <> 0 THEN 100.0
                ELSE 0.0
            END
    FROM DataValues dv
    INNER JOIN DataToUpdate dtu ON dv.Id = dtu.DataValueId;
END;
GO