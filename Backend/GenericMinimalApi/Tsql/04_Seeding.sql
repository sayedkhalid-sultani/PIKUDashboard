-- PIKUDashboard Data Seeding Script
-- This script populates the database with professional sample data
-- Password hash for 'admin' password is provided for admin users

-- Clean up existing data in correct order to respect foreign key constraints
PRINT 'Cleaning up existing data...';
DELETE FROM DataValuesAudit;
DELETE FROM DataValues;
DELETE FROM IndicatorChartTypes;
DELETE FROM Sources;
DELETE FROM ChartConfigs;
DELETE FROM Indicators;
DELETE FROM Locations;
DELETE FROM Calendars;
DELETE FROM Unites;
DELETE FROM UserDepartments;
DELETE FROM UserSubDepartments;
DELETE FROM RefreshTokens;
DELETE FROM Users;
DELETE FROM Departments;

-- Reset identity seeds
PRINT 'Resetting identity seeds...';
DBCC CHECKIDENT ('DataValuesAudit', RESEED, 0);
DBCC CHECKIDENT ('DataValues', RESEED, 0);
DBCC CHECKIDENT ('IndicatorChartTypes', RESEED, 0);
DBCC CHECKIDENT ('Sources', RESEED, 0);
DBCC CHECKIDENT ('ChartConfigs', RESEED, 0);
DBCC CHECKIDENT ('Indicators', RESEED, 0);
DBCC CHECKIDENT ('Locations', RESEED, 0);
DBCC CHECKIDENT ('Calendars', RESEED, 0);
DBCC CHECKIDENT ('Unites', RESEED, 0);
DBCC CHECKIDENT ('Users', RESEED, 0);
DBCC CHECKIDENT ('Departments', RESEED, 0);

-- =============================================================================
-- DECLARE ALL VARIABLES AT THE BEGINNING
-- =============================================================================
DECLARE @AdminUserId INT;
DECLARE @OperationsDepartmentId INT;
DECLARE @AfghanistanLocId INT;
DECLARE @BillionDollarUniteId INT;
DECLARE @PercentageUniteId INT;
DECLARE @CountUniteId INT;
DECLARE @MillionDollarUniteId INT;
DECLARE @MillionsUniteId INT;
DECLARE @HouseholdImpactsId INT;
DECLARE @EconomicEventId INT, @NaturalEventId INT, @ConflictEventId INT, @CovidEventId INT;
DECLARE @EconLossIncomeId INT, @EconFoodAccessId INT, @EconDebtId INT;
DECLARE @NatLossIncomeId INT, @NatFoodAccessId INT, @NatDebtId INT;
DECLARE @ConflictLossIncomeId INT, @ConflictFoodAccessId INT, @ConflictDebtId INT;
DECLARE @CovidLossIncomeId INT, @CovidFoodAccessId INT, @CovidDebtId INT;
DECLARE @Calendar2022Id INT;

PRINT 'Seeding Calendars from 2020 to 2030...';
-- Seed Calendars table with dates from 2020 to 2030
DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate DATE = '2030-12-31';

WITH CalendarCTE AS (
    SELECT @StartDate AS CalendarDate
    UNION ALL
    SELECT DATEADD(DAY, 1, CalendarDate)
    FROM CalendarCTE
    WHERE DATEADD(DAY, 1, CalendarDate) <= @EndDate
)
INSERT INTO Calendars (
    CalendarDate, Year, Month, MonthName, Quarter, Day, Week, IsWeekend, Description,
    MonthShortLabel, QuarterShortLabel, YearQuarterLabel, MonthYearLabel
)
SELECT 
    CalendarDate,
    YEAR(CalendarDate) AS Year,
    MONTH(CalendarDate) AS Month,
    DATENAME(MONTH, CalendarDate) AS MonthName,
    DATEPART(QUARTER, CalendarDate) AS Quarter,
    DAY(CalendarDate) AS Day,
    DATEPART(WEEK, CalendarDate) AS Week,
    CASE WHEN DATEPART(WEEKDAY, CalendarDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend,
    CONCAT('Q', DATEPART(QUARTER, CalendarDate), ' ', YEAR(CalendarDate)) AS Description,
    LEFT(DATENAME(MONTH, CalendarDate), 3) AS MonthShortLabel,
    CONCAT('Q', DATEPART(QUARTER, CalendarDate)) AS QuarterShortLabel,
    CONCAT('Q', DATEPART(QUARTER, CalendarDate), '/', YEAR(CalendarDate)) AS YearQuarterLabel,
    CONCAT(LEFT(DATENAME(MONTH, CalendarDate), 3), '/', YEAR(CalendarDate)) AS MonthYearLabel
FROM CalendarCTE
OPTION (MAXRECURSION 0);

PRINT 'Seeding Departments...';
-- Departments
INSERT INTO Departments (Name, ParentID) VALUES 
(N'Executive Leadership', NULL),
(N'Finance & Analytics', 1),
(N'Operations', 1),
(N'Sales & Marketing', 1),
(N'Human Resources', 1),
(N'IT Department', 1),
(N'Data Analytics', 2),
(N'Financial Planning', 2),
(N'Field Operations', 3),
(N'Logistics', 3),
(N'Digital Marketing', 4),
(N'Customer Success', 4);

PRINT 'Seeding Users with secure password hashes...';
-- Users with secure password hashes (password: admin)
INSERT INTO Users (Username, PasswordHash, Role, Departments, IsLocked) VALUES 
(N'admin', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Admin', 1, 0),
(N'ahmad.sultani', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Admin', 3, 0),
(N'sara.analyst', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Manager', 7, 0),
(N'mohammad.finance', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Manager', 8, 0),
(N'fatima.operations', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Manager', 9, 0),
(N'viewer1', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Viewer', 4, 0),
(N'viewer2', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Viewer', 5, 0);

-- Set admin user ID
SELECT @AdminUserId = Id FROM Users WHERE Username = 'admin';
SELECT @OperationsDepartmentId = Id FROM Departments WHERE Name = 'Operations';

PRINT 'Seeding Unites...';
-- Unites - Create different units for different types of data
INSERT INTO Unites (Name) VALUES 
(N'Billion Dollar'),
(N'Percentage'),
(N'Count'),
(N'Million Dollar'),
(N'Ratio'),
(N'Index Points'),
(N'Millions');  -- Added for Household Impacts data

-- Set unit IDs
SELECT @BillionDollarUniteId = Id FROM Unites WHERE Name = N'Billion Dollar';
SELECT @PercentageUniteId = Id FROM Unites WHERE Name = N'Percentage';
SELECT @CountUniteId = Id FROM Unites WHERE Name = N'Count';
SELECT @MillionDollarUniteId = Id FROM Unites WHERE Name = N'Million Dollar';
SELECT @MillionsUniteId = Id FROM Unites WHERE Name = N'Millions';

PRINT 'Seeding Locations...';
-- Locations
INSERT INTO Locations (Name, Type, ParentId) VALUES 
(N'Global', N'Region', NULL),
(N'Asia', N'Continent', 1),
(N'Middle East', N'Region', 2),
(N'Afghanistan', N'Country', 3),
(N'Pakistan', N'Country', 3),
(N'Iran', N'Country', 3),
(N'Kabul', N'Province', 4),
(N'Herat', N'Province', 4),
(N'Kandahar', N'Province', 4),
(N'Balkh', N'Province', 4);

-- Set Afghanistan location ID
SELECT @AfghanistanLocId = Id FROM Locations WHERE Name = N'Afghanistan';

-- =============================================================================
-- HOUSEHOLD IMPACTS CATEGORY - Event Impact Analysis
-- =============================================================================
PRINT 'Creating main dashboard indicators...';
-- Create main indicators for different business areas
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
-- Level 0: Main Dashboard Categories
(N'Financial Performance', NULL, 0, @BillionDollarUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Operational Metrics', NULL, 0, @CountUniteId, 2, N'#2196F3', GETDATE(), @AdminUserId),
(N'Market Analysis', NULL, 0, @PercentageUniteId, 3, N'#FF9800', GETDATE(), @AdminUserId),
(N'Human Resources', NULL, 0, @PercentageUniteId, 4, N'#E91E63', GETDATE(), @AdminUserId),
(N'Household Impacts', NULL, 0, @MillionsUniteId, 5, N'#9C27B0', GETDATE(), @AdminUserId);

-- Get the Household Impacts category ID
SELECT @HouseholdImpactsId = Id FROM Indicators WHERE Name = N'Household Impacts' AND ParentId IS NULL;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Level 1 Events (Economic, Natural, Conflict, COVID-19)
-- =============================================================================
PRINT 'Seeding Household Impacts Events...';
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'Economic', @HouseholdImpactsId, 1, @MillionsUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Natural', @HouseholdImpactsId, 1, @MillionsUniteId, 2, N'#2196F3', GETDATE(), @AdminUserId),
(N'Conflict', @HouseholdImpactsId, 1, @MillionsUniteId, 3, N'#FF9800', GETDATE(), @AdminUserId),
(N'COVID-19', @HouseholdImpactsId, 1, @MillionsUniteId, 4, N'#E91E63', GETDATE(), @AdminUserId);

-- Get Event IDs
SELECT @EconomicEventId = Id FROM Indicators WHERE Name = N'Economic' AND ParentId = @HouseholdImpactsId;
SELECT @NaturalEventId = Id FROM Indicators WHERE Name = N'Natural' AND ParentId = @HouseholdImpactsId;
SELECT @ConflictEventId = Id FROM Indicators WHERE Name = N'Conflict' AND ParentId = @HouseholdImpactsId;
SELECT @CovidEventId = Id FROM Indicators WHERE Name = N'COVID-19' AND ParentId = @HouseholdImpactsId;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Level 2 Impact Types (Loss of income, Limited access to food, Taking on debt)
-- =============================================================================
PRINT 'Seeding Household Impacts Types...';
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
-- Economic Event Impact Types
(N'Loss of income', @EconomicEventId, 2, @MillionsUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Limited access to food', @EconomicEventId, 2, @MillionsUniteId, 2, N'#8BC34A', GETDATE(), @AdminUserId),
(N'Taking on debt', @EconomicEventId, 2, @MillionsUniteId, 3, N'#CDDC39', GETDATE(), @AdminUserId),

-- Natural Event Impact Types
(N'Loss of income', @NaturalEventId, 2, @MillionsUniteId, 1, N'#2196F3', GETDATE(), @AdminUserId),
(N'Limited access to food', @NaturalEventId, 2, @MillionsUniteId, 2, N'#03A9F4', GETDATE(), @AdminUserId),
(N'Taking on debt', @NaturalEventId, 2, @MillionsUniteId, 3, N'#00BCD4', GETDATE(), @AdminUserId),

-- Conflict Event Impact Types
(N'Loss of income', @ConflictEventId, 2, @MillionsUniteId, 1, N'#FF9800', GETDATE(), @AdminUserId),
(N'Limited access to food', @ConflictEventId, 2, @MillionsUniteId, 2, N'#FFC107', GETDATE(), @AdminUserId),
(N'Taking on debt', @ConflictEventId, 2, @MillionsUniteId, 3, N'#FFEB3B', GETDATE(), @AdminUserId),

-- COVID-19 Event Impact Types
(N'Loss of income', @CovidEventId, 2, @MillionsUniteId, 1, N'#E91E63', GETDATE(), @AdminUserId),
(N'Limited access to food', @CovidEventId, 2, @MillionsUniteId, 2, N'#F44336', GETDATE(), @AdminUserId),
(N'Taking on debt', @CovidEventId, 2, @MillionsUniteId, 3, N'#FF5722', GETDATE(), @AdminUserId);

-- Get Impact Type IDs
SELECT @EconLossIncomeId = Id FROM Indicators WHERE Name = N'Loss of income' AND ParentId = @EconomicEventId;
SELECT @EconFoodAccessId = Id FROM Indicators WHERE Name = N'Limited access to food' AND ParentId = @EconomicEventId;
SELECT @EconDebtId = Id FROM Indicators WHERE Name = N'Taking on debt' AND ParentId = @EconomicEventId;

SELECT @NatLossIncomeId = Id FROM Indicators WHERE Name = N'Loss of income' AND ParentId = @NaturalEventId;
SELECT @NatFoodAccessId = Id FROM Indicators WHERE Name = N'Limited access to food' AND ParentId = @NaturalEventId;
SELECT @NatDebtId = Id FROM Indicators WHERE Name = N'Taking on debt' AND ParentId = @NaturalEventId;

SELECT @ConflictLossIncomeId = Id FROM Indicators WHERE Name = N'Loss of income' AND ParentId = @ConflictEventId;
SELECT @ConflictFoodAccessId = Id FROM Indicators WHERE Name = N'Limited access to food' AND ParentId = @ConflictEventId;
SELECT @ConflictDebtId = Id FROM Indicators WHERE Name = N'Taking on debt' AND ParentId = @ConflictEventId;

SELECT @CovidLossIncomeId = Id FROM Indicators WHERE Name = N'Loss of income' AND ParentId = @CovidEventId;
SELECT @CovidFoodAccessId = Id FROM Indicators WHERE Name = N'Limited access to food' AND ParentId = @CovidEventId;
SELECT @CovidDebtId = Id FROM Indicators WHERE Name = N'Taking on debt' AND ParentId = @CovidEventId;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Data Values for 2022 (NOAA Survey Data)
-- =============================================================================
PRINT 'Seeding Household Impacts Data for 2022...';
SELECT TOP 1 @Calendar2022Id = Id FROM Calendars WHERE Year = 2022 AND Month = 12 AND Day = 31;

INSERT INTO DataValues (IndicatorId, Value, CalendarId, LocationId, PeriodType, LocationType, DateAdded, CreatedByUserId)
VALUES 
-- Economic Event Impacts 2022
(@EconLossIncomeId, 3.2, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@EconFoodAccessId, 2.5, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@EconDebtId, 4.1, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),

-- Natural Event Impacts 2022
(@NatLossIncomeId, 2.8, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@NatFoodAccessId, 3.1, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@NatDebtId, 2.2, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),

-- Conflict Event Impacts 2022
(@ConflictLossIncomeId, 1.9, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@ConflictFoodAccessId, 2.2, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@ConflictDebtId, 1.5, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),

-- COVID-19 Event Impacts 2022
(@CovidLossIncomeId, 4.8, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@CovidFoodAccessId, 3.9, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId),
(@CovidDebtId, 5.2, @Calendar2022Id, @AfghanistanLocId, N'Yearly', N'National', GETDATE(), @AdminUserId);

-- =============================================================================
-- TRIGGER ACTIVATION: Calculate Growth and Percentage metrics
-- =============================================================================
PRINT 'Activating trigger to calculate GrowthSinceLastPeriod and PercentageOfParentTotal...';
UPDATE DataValues SET Value = Value WHERE CalendarId = @Calendar2022Id;

-- =============================================================================
-- VERIFICATION: Check Household Impacts data
-- =============================================================================
PRINT 'Verifying Household Impacts data...';
SELECT 
    grandparent.Name,
    parent.Name ,
    i.Name ,
    dv.Value,
    dv.GrowthSinceLastPeriod,
    dv.PercentageOfParentTotal,
    c.Year
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Indicators parent ON i.ParentId = parent.Id
INNER JOIN Indicators grandparent ON parent.ParentId = grandparent.Id
INNER JOIN Calendars c ON dv.CalendarId = c.Id
ORDER BY parent.OrderIndex, i.OrderIndex;

PRINT 'Data seeding completed successfully!';
PRINT 'Household Impacts data has been integrated with automatic metric calculations';
PRINT 'GrowthSinceLastPeriod and PercentageOfParentTotal columns are automatically calculated by trigger';
PRINT '';
PRINT 'Calendar data seeded from 2020-01-01 to 2030-12-31';
PRINT 'Login credentials:';
PRINT 'All users have password: admin';
PRINT 'Admin users: admin, ahmad.sultani';
PRINT 'Manager users: sara.analyst, mohammad.finance, fatima.operations';
PRINT 'Viewer users: viewer1, viewer2';
PRINT '';
PRINT 'Remember to change passwords in production environment.';