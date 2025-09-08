/*
    PIKUDashboard Schema Modification Script
    ---------------------------------------
    This script performs maintenance and recalculation for calculated columns in the DataValues table.
    It is intended to be run after triggers or logic affecting growth and total metrics have been updated.

    Steps:
    1. Drop old triggers to prepare for updated logic.
    2. Execute the updated triggers in the 03_Triggers.sql file.
    3. Clear calculated columns (GrowthSinceLastPeriod, PercentageOfParentTotal) for a clean recalculation.
    4. Verify that all calculated columns are cleared (should return 0 rows).
    5. Reactivate triggers by updating values (forces recalculation via triggers).
    6. Check the results to ensure calculated columns are updated.
*/

-- Step 1: Drop old triggers
DROP TRIGGER IF EXISTS [dbo].[trg_RecalculateMetricsOnConfigChange];
DROP TRIGGER IF EXISTS [dbo].[trg_CalculateGrowthAndTotalMetrics];

-- Step 2: Execute the updated triggers in the 03_Triggers.sql file
--    (Run the CREATE TRIGGER statements from 03_Triggers.sql to recreate the triggers with the latest logic)

-- Step 3: Clear calculated columns
UPDATE DataValues 
SET GrowthSinceLastPeriod = NULL,
    PercentageOfParentTotal = NULL;

-- Step 4: Verify columns are cleared
SELECT  
    Id,
    IndicatorId,
    Value,
    GrowthSinceLastPeriod,
    PercentageOfParentTotal
FROM DataValues
WHERE GrowthSinceLastPeriod IS NOT NULL 
   OR PercentageOfParentTotal IS NOT NULL;
-- This should return 0 rows if clearing was successful

-- Step 5: Reactivate the trigger by updating values (forces recalculation)
UPDATE DataValues 
SET Value = Value;

-- Step 6: Check the results
SELECT 
    dv.Id,
    i.Name as IndicatorName,
    parent.Name as ParentName,
    parent.OrderIndex,
    dv.Value,
    dv.GrowthSinceLastPeriod,
    dv.PercentageOfParentTotal,
    CASE 
        WHEN dv.GrowthSinceLastPeriod IS NULL THEN 'NOT CALCULATED'
        ELSE 'CALCULATED'
    END as Status
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Indicators parent ON i.ParentId = parent.Id
ORDER BY i.Name, parent.OrderIndex;