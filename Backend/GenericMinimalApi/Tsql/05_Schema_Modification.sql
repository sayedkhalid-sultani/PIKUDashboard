/*
    PIKUDashboard Schema Modification Script
    ---------------------------------------
    This script removes the CalculateGrowthBy and CalculateTotalBy columns from the ChartConfigs table.

    Steps:
    1. Check if CalculateGrowthBy and CalculateTotalBy columns exist in ChartConfigs.
    2. Remove CalculateGrowthBy and CalculateTotalBy columns from ChartConfigs.
    3. (Optional) Verify columns are removed.
*/

-- Step 1: Check if columns exist (optional)
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChartConfigs'
  AND COLUMN_NAME IN ('CalculateGrowthBy', 'CalculateTotalBy');

-- Step 2: Remove CalculateGrowthBy and CalculateTotalBy columns from ChartConfigs
ALTER TABLE [dbo].[ChartConfigs]
DROP COLUMN CalculateGrowthBy, CalculateTotalBy;

-- Step 3: (Optional) Verify columns are removed
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChartConfigs'
  AND COLUMN_NAME IN ('CalculateGrowthBy', 'CalculateTotalBy');
-- This should return 0 rows if columns