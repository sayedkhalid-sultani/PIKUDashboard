CREATE OR ALTER FUNCTION dbo.fn_FindPreviousValue(@CurrentIndicatorId INT)
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
          AND i.OrderIndex = @CurrentOrderIndex - 1
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

-- Simplified trigger using the function
CREATE OR ALTER TRIGGER [dbo].[trg_CalculateHierarchicalGrowth]
ON [dbo].[DataValues]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE current_dv
        SET 
            GrowthSinceLastPeriod = 
                CASE 
                    WHEN prev_value IS NOT NULL AND prev_value <> 0 THEN
                        ROUND(((current_dv.Value - prev_value) / prev_value) * 100, 2)
                    WHEN prev_value = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END
            
        FROM DataValues current_dv
        INNER JOIN inserted i ON current_dv.Id = i.Id
        CROSS APPLY (
            SELECT dbo.fn_FindPreviousValue(current_dv.IndicatorId) as prev_value
        ) previous;
    END
END;
GO