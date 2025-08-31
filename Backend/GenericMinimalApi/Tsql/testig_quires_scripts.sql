-- Test 1: Initial data check before trigger testing
SELECT 
    dv.id,
    i.Id AS IndicatorId,
    i.Name AS IndicatorName,
    parent_i.Name AS ParentIndicatorName,
    dv.Value,
    dv.Growth,
    dv.Total,
    u.Name AS UniteName,
    grandparent_i.Name AS TableName
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Unites u ON i.UniteId = u.Id
LEFT JOIN Calendars c ON dv.CalendarId = c.Id
LEFT JOIN Locations l ON dv.LocationId = l.Id
LEFT JOIN Indicators parent_i ON i.ParentId = parent_i.Id
LEFT JOIN Indicators grandparent_i ON parent_i.ParentId = grandparent_i.Id
ORDER BY i.Id, parent_i.Name;

-- Test 2: Test trg_CalculateGrowthAndTotalMetrics trigger 
-- by updating values to trigger growth and total calculations
PRINT 'Testing trg_CalculateGrowthAndTotalMetrics trigger...';
UPDATE DataValues 
SET Value = Value + 0.1; 

-- Test 3: Check if Growth and Total values were updated after trigger execution
PRINT 'Checking updated Growth and Total values...';
SELECT 
    dv.id,
    i.Id AS IndicatorId,
    i.Name AS IndicatorName,
    parent_i.Name AS ParentIndicatorName,
    dv.Value,
    dv.Growth,
    dv.Total,
    u.Name AS UniteName,
    grandparent_i.Name AS TableName
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Unites u ON i.UniteId = u.Id
LEFT JOIN Calendars c ON dv.CalendarId = c.Id
LEFT JOIN Locations l ON dv.LocationId = l.Id
LEFT JOIN Indicators parent_i ON i.ParentId = parent_i.Id
LEFT JOIN Indicators grandparent_i ON parent_i.ParentId = grandparent_i.Id
ORDER BY i.Id, parent_i.Name;

-- Test 4: Test trg_RecalculateMetricsOnConfigChange trigger
-- by changing calculation method in ChartConfigs
PRINT 'Testing trg_RecalculateMetricsOnConfigChange trigger...';
UPDATE ChartConfigs 
SET CalculateGrowthBy = 'indicator', 
    CalculateTotalBy = 'indicator';

-- Test 5: Verify that metrics were recalculated after config change
PRINT 'Checking recalculated values after config change...';
SELECT 
    dv.id,
    i.Id AS IndicatorId,
    i.Name AS IndicatorName,
    parent_i.Name AS ParentIndicatorName,
    dv.Value,
    dv.Growth,
    dv.Total,
    u.Name AS UniteName,
    cc.CalculateGrowthBy,
    cc.CalculateTotalBy
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Unites u ON i.UniteId = u.Id
INNER JOIN ChartConfigs cc ON i.Id = cc.IndicatorId
LEFT JOIN Indicators parent_i ON i.ParentId = parent_i.Id
ORDER BY i.Id, parent_i.Name;