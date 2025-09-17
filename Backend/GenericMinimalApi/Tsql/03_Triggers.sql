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
CREATE OR ALTER FUNCTION dbo.fn_FindPreviousValue(@CurrentIndicatorId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @PreviousValue DECIMAL(18,2) = NULL;
    DECLARE @CurrId INT = @CurrentIndicatorId;
    DECLARE @OrderIndex INT, @ParentId INT;

    SELECT @OrderIndex = OrderIndex, @ParentId = ParentId
    FROM Indicators WHERE Id = @CurrId;

    -- CASE 1: previous sibling under same parent
    IF @OrderIndex > 1
    BEGIN
        SELECT TOP (1) @PreviousValue = dv.Value
        FROM Indicators i
        JOIN DataValues dv ON dv.IndicatorId = i.Id
        WHERE i.ParentId = @ParentId
          AND i.OrderIndex = @OrderIndex - 1
        RETURN @PreviousValue;
    END

    -- CASE 2: climb up the chain, find parent's previous sibling then its last descendant
    WHILE @ParentId IS NOT NULL
    BEGIN
        -- move up
        SET @CurrId = @ParentId;
        SELECT @OrderIndex = OrderIndex, @ParentId = ParentId
        FROM Indicators WHERE Id = @CurrId;

        IF @OrderIndex > 1
        BEGIN
            DECLARE @PrevSiblingId INT;
            SELECT TOP (1) @PrevSiblingId = Id
            FROM Indicators
            WHERE ParentId = @ParentId
              AND OrderIndex = @OrderIndex - 1;

            -- descend to the last descendant (by OrderIndex)
            WHILE EXISTS (SELECT 1 FROM Indicators WHERE ParentId = @PrevSiblingId)
            BEGIN
                SELECT TOP (1) @PrevSiblingId = Id
                FROM Indicators
                WHERE ParentId = @PrevSiblingId
                ORDER BY OrderIndex DESC;
            END

            -- grab the latest DataValues for that last descendant
            SELECT TOP (1) @PreviousValue = dv.Value
            FROM DataValues dv
            WHERE dv.IndicatorId = @PrevSiblingId;

            RETURN @PreviousValue;
        END
    END

    RETURN @PreviousValue;
END;
GO

-- =============================================
-- FUNCTION: fn_FindLastYearValue
-- PURPOSE: Find previous year value for year-over-year growth
-- STEPS:
-- 1. Get current indicator details and date
-- 2. Search in same hierarchy for previous year value
-- 3. Priority: Exact date → Same month → Any date in previous year
-- =============================================
CREATE OR ALTER FUNCTION dbo.fn_FindLastYearValue(
    @CurrentIndicatorId INT,
    @CalendarId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @LastYearValue DECIMAL(18,2) = NULL;
    DECLARE @Name NVARCHAR(255);
    DECLARE @Year INT, @Month INT, @Day INT, @TopLevelId INT;

    SELECT 
        @Name = i.Name,
        @Year = c.Year,
        @Month = c.Month,
        @Day = c.Day,
        @TopLevelId = dbo.fn_GetTopLevelParent(i.Id)
    FROM Indicators i
    INNER JOIN DataValues dv ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON c.Id = dv.CalendarId
    WHERE i.Id = @CurrentIndicatorId AND dv.CalendarId = @CalendarId;

    -- Priority 1: exact date (same month + day in previous year)
    SELECT TOP (1) @LastYearValue = dv.Value
    FROM DataValues dv
    INNER JOIN Indicators i ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Name = @Name
      AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
      AND c.Year = @Year - 1
      AND c.Month = @Month
      AND c.Day = @Day
    ORDER BY c.Month DESC, c.Day DESC;

    -- Priority 2: same month in previous year
    IF @LastYearValue IS NULL
    BEGIN
        SELECT TOP (1) @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @Name
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
          AND c.Year = @Year - 1
          AND c.Month = @Month
        ORDER BY c.Month DESC, c.Day DESC;
    END

    -- Priority 3: any date in previous year (latest)
    IF @LastYearValue IS NULL
    BEGIN
        SELECT TOP (1) @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @Name
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
          AND c.Year = @Year - 1
        ORDER BY c.Month DESC, c.Day DESC;
    END

    RETURN @LastYearValue;
END;


-- =============================================
-- FUNCTION: fn_GetTopLevelParent
-- PURPOSE: Find root parent of hierarchy
-- STEPS:
-- 1. Start with current indicator
-- 2. Recursively move up parent chain
-- 3. Return top-most parent (where ParentId IS NULL)
-- =============================================
CREATE OR ALTER FUNCTION dbo.fn_GetTopLevelParent(@IndicatorId INT)
RETURNS INT
AS
BEGIN
    DECLARE @CurrentId INT = @IndicatorId;
    DECLARE @ParentId INT;

    WHILE 1 = 1
    BEGIN
        SELECT @ParentId = ParentId FROM Indicators WHERE Id = @CurrentId;
        IF @ParentId IS NULL BREAK;
        SET @CurrentId = @ParentId;
    END

    RETURN @CurrentId;
END;
GO
-- =============================================
-- TRIGGER: trg_CalculateHierarchicalGrowth
-- PURPOSE: Calculate growth metrics after data changes

CREATE OR ALTER TRIGGER dbo.trg_CalculateHierarchicalGrowth
ON dbo.DataValues
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Process only rows that were inserted/updated
    UPDATE dv
    SET 
        -- Growth since last period (previous sibling/previous descendant)
        GrowthSinceLastPeriod = CASE 
            WHEN prev.PreviousValue IS NOT NULL AND prev.PreviousValue <> 0 
                THEN ROUND(((dv.Value - prev.PreviousValue) / prev.PreviousValue) * 100.0, 2)
            WHEN prev.PreviousValue = 0 AND dv.Value <> 0 THEN 100.00
            ELSE 0.00
        END,
        -- Growth vs last year (using the prioritized lookup)
        GrowthSinceLastYearPeriod = CASE
            WHEN prev.LastYearValue IS NOT NULL AND prev.LastYearValue <> 0
                THEN ROUND(((dv.Value - prev.LastYearValue) / prev.LastYearValue) * 100.0, 2)
            WHEN prev.LastYearValue = 0 AND dv.Value <> 0 THEN 100.00
            ELSE 0.00
        END,
        -- Percentage among same-name indicators but only inside same top-level group
        PercentageOfParentTotal = CASE 
            WHEN i.ParentId IS NULL THEN 100.00 -- top-level indicator => 100%
            WHEN parent_sum.TotalValue IS NOT NULL AND parent_sum.TotalValue <> 0
                THEN ROUND((dv.Value / parent_sum.TotalValue) * 100.0, 2)
            ELSE 0.00
        END
    FROM DataValues dv
    INNER JOIN inserted ins ON dv.Id = ins.Id
    INNER JOIN Indicators i ON dv.IndicatorId = i.Id
    CROSS APPLY (SELECT dbo.fn_GetTopLevelParent(i.Id) AS TopId) AS topinfo
    CROSS APPLY (
        SELECT 
            dbo.fn_FindPreviousValue(i.Id)     AS PreviousValue,
            dbo.fn_FindLastYearValue(i.Id, dv.CalendarId) AS LastYearValue
    ) AS prev
    CROSS APPLY (
        -- sum of Value for indicators with same Name, but only within the same top-level group
        SELECT SUM(dv_sib.Value) AS TotalValue
        FROM DataValues dv_sib
        INNER JOIN Indicators i_sib ON dv_sib.IndicatorId = i_sib.Id
        WHERE i_sib.Name = i.Name
          AND dbo.fn_GetTopLevelParent(i_sib.Id) = topinfo.TopId
    ) AS parent_sum;
END;
GO
