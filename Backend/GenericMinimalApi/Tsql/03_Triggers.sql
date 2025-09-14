-- Pure OrderIndex Logic Only: Works for 4 levels deep hierarchy
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
                    WHEN previous_value.PreviousValue IS NOT NULL AND previous_value.PreviousValue <> 0 THEN
                        ROUND(((current_dv.Value - previous_value.PreviousValue) / previous_value.PreviousValue) * 100, 2)
                    WHEN previous_value.PreviousValue = 0 AND current_dv.Value <> 0 THEN
                        100.0
                    ELSE
                        0.0
                END
            
        FROM DataValues current_dv
        INNER JOIN inserted i ON current_dv.Id = i.Id
        INNER JOIN Indicators current_i ON current_dv.IndicatorId = current_i.Id
        
        -- Get parent information
        LEFT JOIN Indicators current_parent ON current_i.ParentId = current_parent.Id
        LEFT JOIN Indicators current_grandparent ON current_parent.ParentId = current_grandparent.Id
        LEFT JOIN Indicators current_ggparent ON current_grandparent.ParentId = current_ggparent.Id
        
        OUTER APPLY (
            -- Find previous value using only OrderIndex logic
            SELECT TOP 1 prev_dv.Value as PreviousValue
            FROM DataValues prev_dv
            INNER JOIN Indicators prev_i ON prev_dv.IndicatorId = prev_i.Id
            
            -- Case 1: Same parent, OrderIndex - 1
            WHERE (
                (prev_i.ParentId = current_i.ParentId AND prev_i.OrderIndex = current_i.OrderIndex - 1)
                OR
                -- Case 2: OrderIndex = 1, find parent's previous sibling's last child
                (current_i.OrderIndex = 1 AND current_parent.OrderIndex > 1 
                 AND prev_i.ParentId IN (
                     SELECT Id FROM Indicators 
                     WHERE ParentId = current_parent.ParentId 
                     AND OrderIndex = current_parent.OrderIndex - 1
                 )
                 AND prev_i.OrderIndex = (SELECT MAX(OrderIndex) FROM Indicators WHERE ParentId = prev_i.ParentId))
                OR
                -- Case 3: OrderIndex = 1 and parent OrderIndex = 1, find grandparent's previous sibling's last child
                (current_i.OrderIndex = 1 AND current_parent.OrderIndex = 1 AND current_grandparent.OrderIndex > 1
                 AND prev_i.ParentId IN (
                     SELECT Id FROM Indicators 
                     WHERE ParentId = current_grandparent.ParentId 
                     AND OrderIndex = current_grandparent.OrderIndex - 1
                 )
                 AND prev_i.OrderIndex = (SELECT MAX(OrderIndex) FROM Indicators WHERE ParentId = prev_i.ParentId))
                OR
                -- Case 4: OrderIndex = 1, parent OrderIndex = 1, grandparent OrderIndex = 1, find ggparent's previous sibling's last child
                (current_i.OrderIndex = 1 AND current_parent.OrderIndex = 1 AND current_grandparent.OrderIndex = 1 AND current_ggparent.OrderIndex > 1
                 AND prev_i.ParentId IN (
                     SELECT Id FROM Indicators 
                     WHERE ParentId = current_ggparent.ParentId 
                     AND OrderIndex = current_ggparent.OrderIndex - 1
                 )
                 AND prev_i.OrderIndex = (SELECT MAX(OrderIndex) FROM Indicators WHERE ParentId = prev_i.ParentId))
            )
            AND prev_dv.CalendarId = current_dv.CalendarId
            AND prev_dv.LocationId = current_dv.LocationId
            
            ORDER BY 
                -- Priority: same parent > parent level > grandparent level > ggparent level
                CASE 
                    WHEN prev_i.ParentId = current_i.ParentId THEN 1
                    WHEN prev_i.ParentId IN (SELECT Id FROM Indicators WHERE ParentId = current_parent.ParentId) THEN 2
                    WHEN prev_i.ParentId IN (SELECT Id FROM Indicators WHERE ParentId = current_grandparent.ParentId) THEN 3
                    ELSE 4
                END
        ) previous_value;
    END
END;
GO



-- Fun approach dynamically calculate OrderIndex based on recursive CTE
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