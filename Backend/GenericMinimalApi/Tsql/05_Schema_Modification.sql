-- First add the new columns
ALTER TABLE [dbo].[DataValues]
ADD [GrowthSinceLastPeriod] [float] NULL,
    [PercentageOfParentTotal] [float] NULL;

-- Copy data from old columns to new columns
UPDATE [dbo].[DataValues] 
SET [GrowthSinceLastPeriod] = [Growth],
    [PercentageOfParentTotal] = [Total];

-- Drop the old columns (after verifying data is correct)
ALTER TABLE [dbo].[DataValues]
DROP COLUMN [Growth], [Total];