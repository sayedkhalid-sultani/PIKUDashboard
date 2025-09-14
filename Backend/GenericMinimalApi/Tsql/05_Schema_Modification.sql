/*
    PIKUDashboard Schema Modification Script
    ---------------------------------------
    This script updates the DataValues table by:
    - Removing user-related columns and their foreign key constraints (if they exist).
    - Adding a new column for growth since last year period.

    Steps:
    1. Drop foreign key constraints for CreatedByUserId and UpdatedByUserId (if they exist).
    2. Drop default constraint on DateAdded.
    3. Remove DateAdded, CreatedByUserId, UpdatedByUserId, and UpdatedAt columns from DataValues.
    4. Add GrowthSinceLastYearPeriod column to DataValues.
*/

-- Step 1: Drop foreign key constraints if they exist
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DataValues_CreatedByUserId'
)
    ALTER TABLE [dbo].[DataValues] DROP CONSTRAINT FK_DataValues_CreatedByUserId;

IF EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DataValues_UpdatedByUserId'
)
    ALTER TABLE [dbo].[DataValues] DROP CONSTRAINT FK_DataValues_UpdatedByUserId;

-- Step 2: Drop default constraint on DateAdded
ALTER TABLE [dbo].[DataValues]
DROP CONSTRAINT DF__DataValue__DateA__00DF2177;

-- Step 3: Remove user-related columns
ALTER TABLE [dbo].[DataValues]
DROP COLUMN DateAdded, CreatedByUserId, UpdatedByUserId, UpdatedAt;

-- Step 4: Add new growth column
ALTER TABLE [dbo].[DataValues]
ADD GrowthSinceLastYearPeriod DECIMAL(18, 2) NULL;