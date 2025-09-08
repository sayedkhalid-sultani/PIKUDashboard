/*
    PIKUDashboard Schema Modification Script
    ---------------------------------------
    This script removes the PeriodType and LocationType columns from the DataValues table,
    as their values can be derived from the related Calendars and Locations tables.

    Steps:
    1. Drop indexes dependent on PeriodType and LocationType.
    2. Remove PeriodType and LocationType columns from DataValues.
    3. (Optional) Verify columns are removed.
*/

-- Step 1: Drop indexes
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DataValues_PeriodType' AND object_id = OBJECT_ID('dbo.DataValues'))
    DROP INDEX IX_DataValues_PeriodType ON dbo.DataValues;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DataValues_LocationType' AND object_id = OBJECT_ID('dbo.DataValues'))
    DROP INDEX IX_DataValues_LocationType ON dbo.DataValues;

-- Step 2: Remove columns from DataValues
ALTER TABLE [dbo].[DataValues]
DROP COLUMN PeriodType, LocationType;

-- Step 3: (Optional) Verify columns are removed
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DataValues'
  AND COLUMN_NAME IN ('PeriodType', 'LocationType');
-- This should return 0 rows if columns were successfully removed.