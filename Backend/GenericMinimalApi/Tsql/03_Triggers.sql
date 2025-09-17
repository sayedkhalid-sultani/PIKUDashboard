-- FUNCTION: fn_FindPreviousValue
-- PURPOSE: Find previous hierarchical value for period-over-period growth calculations
-- STEPS:
-- 1. Get GroupBy setting from ChartConfigs for the indicator
-- 2. Get latest CalendarId, LocationId, and hierarchy details from DataValues
-- 3. If GroupBy is not defined, use hierarchy logic:
--    - If OrderIndex > 1: get previous sibling's latest value
--    - If OrderIndex = 1: recursively search up hierarchy to find parent's previous sibling and get its last descendant's value
-- 4. If GroupBy is defined, use grouping logic:
--    - For time grouping: find previous value in same time period or previous time period
--    - For location grouping: find previous value in location hierarchy based on OrderIndex
-- 5. Return found value or NULL if no value found
CREATE OR ALTER FUNCTION dbo.fn_FindPreviousValue(@IndicatorId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @PreviousValue DECIMAL(18,2) = NULL;
    DECLARE @GroupBy NVARCHAR(50);

    ---------------------------------------------------
    -- 1) Find top-level parent and its GroupBy setting
    ---------------------------------------------------
    DECLARE @TopIndicatorId INT = dbo.fn_GetTopLevelParent(@IndicatorId);

    SELECT TOP 1 @GroupBy = cc.GroupBy
    FROM ChartConfigs cc
    WHERE cc.IndicatorId = @TopIndicatorId
    ORDER BY cc.Id DESC;

    ---------------------------------------------------
    -- 2) Get current indicator's calendar/location info
    ---------------------------------------------------
    DECLARE @CalendarId INT, @LocationId INT;
    DECLARE @CurrOrder INT, @ParentId INT;
    DECLARE @CurrYear INT, @CurrMonth INT, @CurrQuarter INT;

    SELECT TOP 1 
        @CalendarId = dv.CalendarId,
        @LocationId = dv.LocationId,
        @CurrOrder = i.OrderIndex,
        @ParentId = i.ParentId,
        @CurrYear = c.Year,
        @CurrMonth = c.Month,
        @CurrQuarter = c.Quarter
    FROM DataValues dv
    INNER JOIN Indicators i ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON dv.CalendarId = c.Id
    WHERE i.Id = @IndicatorId
    ORDER BY dv.CalendarId DESC;

    ---------------------------------------------------
    -- 3) Case A: No GroupBy → use pure hierarchy logic
    ---------------------------------------------------
    IF @GroupBy IS NULL OR LTRIM(RTRIM(@GroupBy)) = ''
    BEGIN
        DECLARE @CurrId INT = @IndicatorId;
        DECLARE @OrderIndex INT, @ParentIndicatorId INT;

        SELECT @OrderIndex = OrderIndex, @ParentIndicatorId = ParentId
        FROM Indicators WHERE Id = @CurrId;

        -- If has previous sibling
        IF @OrderIndex > 1
        BEGIN
            SELECT TOP 1 @PreviousValue = dv.Value
            FROM Indicators i
            INNER JOIN DataValues dv ON dv.IndicatorId = i.Id
            WHERE i.ParentId = @ParentIndicatorId
              AND i.OrderIndex = @OrderIndex - 1
            ORDER BY dv.CalendarId DESC;
            RETURN @PreviousValue;
        END

        -- Otherwise, climb up the hierarchy
        WHILE @ParentIndicatorId IS NOT NULL
        BEGIN
            SET @CurrId = @ParentIndicatorId;
            SELECT @OrderIndex = OrderIndex, @ParentIndicatorId = ParentId
            FROM Indicators WHERE Id = @CurrId;

            IF @OrderIndex > 1
            BEGIN
                DECLARE @PrevSiblingId INT;
                SELECT TOP 1 @PrevSiblingId = Id
                FROM Indicators
                WHERE ParentId = @ParentIndicatorId
                  AND OrderIndex = @OrderIndex - 1;

                -- descend to deepest child
                WHILE EXISTS (SELECT 1 FROM Indicators WHERE ParentId = @PrevSiblingId)
                BEGIN
                    SELECT TOP 1 @PrevSiblingId = Id
                    FROM Indicators
                    WHERE ParentId = @PrevSiblingId
                    ORDER BY OrderIndex DESC;
                END

                -- grab its latest DataValue
                SELECT TOP 1 @PreviousValue = dv.Value
                FROM DataValues dv
                WHERE dv.IndicatorId = @PrevSiblingId
                ORDER BY dv.CalendarId DESC;

                RETURN @PreviousValue;
            END
        END

        RETURN NULL;
    END

    ---------------------------------------------------
    -- 4) Case B: GroupBy defined → time/location logic
    ---------------------------------------------------
    ELSE
    BEGIN
        -- -------- Yearly / Quarterly / Monthly --------
        IF @GroupBy IN ('Yearly','Quarterly','Monthly')
        BEGIN
            IF @CurrOrder > 1
            BEGIN
                -- Previous sibling in same group
                SELECT TOP 1 @PreviousValue = dv.Value
                FROM DataValues dv
                INNER JOIN Indicators i ON dv.IndicatorId = i.Id
                INNER JOIN Calendars c ON dv.CalendarId = c.Id
                WHERE i.ParentId = @ParentId
                  AND i.OrderIndex < @CurrOrder
                  AND ((@GroupBy='Yearly' AND c.Year=@CurrYear)
                       OR (@GroupBy='Quarterly' AND c.Year=@CurrYear AND c.Quarter=@CurrQuarter)
                       OR (@GroupBy='Monthly' AND c.Year=@CurrYear AND c.Month=@CurrMonth))
                ORDER BY i.OrderIndex DESC, c.CalendarDate DESC;
            END
            ELSE
            BEGIN
                -- First order → find most recent previous group
                SELECT TOP 1 @PreviousValue = dv.Value
                FROM DataValues dv
                INNER JOIN Indicators i ON dv.IndicatorId = i.Id
                INNER JOIN Calendars c ON dv.CalendarId = c.Id
                WHERE i.ParentId = @ParentId
                  AND ((@GroupBy='Yearly' AND c.Year < @CurrYear)
                       OR (@GroupBy='Quarterly' AND (c.Year < @CurrYear OR (c.Year=@CurrYear AND c.Quarter < @CurrQuarter)))
                       OR (@GroupBy='Monthly' AND (c.Year < @CurrYear OR (c.Year=@CurrYear AND c.Month < @CurrMonth))))
                ORDER BY c.Year DESC, c.Quarter DESC, c.Month DESC, i.OrderIndex DESC;
            END
        END

        -- -------- Province / Region --------
        ELSE IF @GroupBy IN ('Province','Region')
        BEGIN
            DECLARE @CurrLocationOrder INT, @ParentLocationId INT;
            SELECT @CurrLocationOrder = OrderIndex, @ParentLocationId = ParentId
            FROM Locations WHERE Id = @LocationId;

            IF @CurrLocationOrder > 1
            BEGIN
                SELECT TOP 1 @PreviousValue = dv.Value
                FROM DataValues dv
                INNER JOIN Indicators i ON dv.IndicatorId = i.Id
                INNER JOIN Locations l ON dv.LocationId = l.Id
                WHERE i.ParentId = @ParentId
                  AND l.ParentId = @ParentLocationId
                  AND l.OrderIndex < @CurrLocationOrder
                ORDER BY l.OrderIndex DESC, dv.Id DESC;
            END
            ELSE
            BEGIN
                -- First location in order → find any lower-order previous
                SELECT TOP 1 @PreviousValue = dv.Value
                FROM DataValues dv
                INNER JOIN Indicators i ON dv.IndicatorId = i.Id
                INNER JOIN Locations l ON dv.LocationId = l.Id
                WHERE i.ParentId = @ParentId
                  AND l.ParentId = @ParentLocationId
                  AND l.OrderIndex < @CurrLocationOrder
                ORDER BY l.OrderIndex DESC, dv.Id DESC;
            END
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
-- 3. Priority: Exact date → Same month -> Same Quarter → Any date in previous year
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
    DECLARE @Year INT, @Month INT, @Day INT, @Quarter INT, @TopLevelId INT;

    SELECT 
        @Name = i.Name,
        @Year = c.Year,
        @Month = c.Month,
        @Day = c.Day,
        @Quarter = c.Quarter,
        @TopLevelId = dbo.fn_GetTopLevelParent(i.Id)
    FROM Indicators i
    INNER JOIN DataValues dv ON dv.IndicatorId = i.Id
    INNER JOIN Calendars c ON c.Id = dv.CalendarId
    WHERE i.Id = @CurrentIndicatorId AND dv.CalendarId = @CalendarId;

    ----------------------------------------------------
    -- Priority 1: exact same date (month + day, last yr)
    ----------------------------------------------------
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

    ----------------------------------------------------
    -- Priority 2: same month in previous year
    ----------------------------------------------------
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

    ----------------------------------------------------
    -- Priority 3: same quarter in previous year
    ----------------------------------------------------
    IF @LastYearValue IS NULL
    BEGIN
        SELECT TOP (1) @LastYearValue = dv.Value
        FROM DataValues dv
        INNER JOIN Indicators i ON dv.IndicatorId = i.Id
        INNER JOIN Calendars c ON dv.CalendarId = c.Id
        WHERE i.Name = @Name
          AND dbo.fn_GetTopLevelParent(i.Id) = @TopLevelId
          AND c.Year = @Year - 1
          AND c.Quarter = @Quarter
        ORDER BY c.Month DESC, c.Day DESC;
    END

    ----------------------------------------------------
    -- Priority 4: any date in previous year (latest)
    ----------------------------------------------------
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
GO

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
