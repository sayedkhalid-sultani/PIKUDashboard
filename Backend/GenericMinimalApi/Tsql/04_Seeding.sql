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

PRINT 'Seeding Calendars from 2020 to 2030...';
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
(N'Asia', N'Continent', 2),
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
(N'Household Impacts', NULL, 0, @MillionsUniteId, 5, N'#9C27B0', GETDATE(), @AdminUserId);

-- Get the Household Impacts category ID
SELECT @HouseholdImpactsId = Id FROM Indicators WHERE Name = N'Household Impacts' AND ParentId IS NULL;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Level 1 Events (Economic, Natural, Conflict, COVID-19)
-- =============================================================================
PRINT 'Seeding Household Impacts Events...';
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'Economic Events', @HouseholdImpactsId, 1, @MillionsUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Natural Events', @HouseholdImpactsId, 1, @MillionsUniteId, 2, N'#2196F3', GETDATE(), @AdminUserId),
(N'Conflict Events', @HouseholdImpactsId, 1, @MillionsUniteId, 3, N'#FF9800', GETDATE(), @AdminUserId),
(N'COVID-19 Impact', @HouseholdImpactsId, 1, @MillionsUniteId, 4, N'#E91E63', GETDATE(), @AdminUserId);

-- Get Event IDs
SELECT @EconomicEventId = Id FROM Indicators WHERE Name = N'Economic Events' AND ParentId = @HouseholdImpactsId;
SELECT @NaturalEventId = Id FROM Indicators WHERE Name = N'Natural Events' AND ParentId = @HouseholdImpactsId;
SELECT @ConflictEventId = Id FROM Indicators WHERE Name = N'Conflict Events' AND ParentId = @HouseholdImpactsId;
SELECT @CovidEventId = Id FROM Indicators WHERE Name = N'COVID-19 Impact' AND ParentId = @HouseholdImpactsId;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Level 2 Impact Types 
-- =============================================================================
PRINT 'Seeding Household Impacts Types...';
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
-- Economic Event Impact Types
(N'Income Loss', @EconomicEventId, 2, @MillionsUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Food Access Issues', @EconomicEventId, 2, @MillionsUniteId, 2, N'#8BC34A', GETDATE(), @AdminUserId),
(N'Debt Accumulation', @EconomicEventId, 2, @MillionsUniteId, 3, N'#CDDC39', GETDATE(), @AdminUserId),

-- Natural Event Impact Types
(N'Income Loss', @NaturalEventId, 2, @MillionsUniteId, 1, N'#2196F3', GETDATE(), @AdminUserId),
(N'Food Access Issues', @NaturalEventId, 2, @MillionsUniteId, 2, N'#03A9F4', GETDATE(), @AdminUserId),
(N'Debt Accumulation', @NaturalEventId, 2, @MillionsUniteId, 3, N'#00BCD4', GETDATE(), @AdminUserId),

-- Conflict Event Impact Types
(N'Income Loss', @ConflictEventId, 2, @MillionsUniteId, 1, N'#FF9800', GETDATE(), @AdminUserId),
(N'Food Access Issues', @ConflictEventId, 2, @MillionsUniteId, 2, N'#FFC107', GETDATE(), @AdminUserId),
(N'Debt Accumulation', @ConflictEventId, 2, @MillionsUniteId, 3, N'#FFEB3B', GETDATE(), @AdminUserId),

-- COVID-19 Impact Types
(N'Income Loss', @CovidEventId, 2, @MillionsUniteId, 1, N'#E91E63', GETDATE(), @AdminUserId),
(N'Food Access Issues', @CovidEventId, 2, @MillionsUniteId, 2, N'#F44336', GETDATE(), @AdminUserId),
(N'Debt Accumulation', @CovidEventId, 2, @MillionsUniteId, 3, N'#FF5722', GETDATE(), @AdminUserId);

-- Get Level 2 Impact Type IDs
SELECT @EconLossIncomeId = Id FROM Indicators WHERE Name = N'Income Loss' AND ParentId = @EconomicEventId;
SELECT @EconFoodAccessId = Id FROM Indicators WHERE Name = N'Food Access Issues' AND ParentId = @EconomicEventId;
SELECT @EconDebtId = Id FROM Indicators WHERE Name = N'Debt Accumulation' AND ParentId = @EconomicEventId;

SELECT @NatLossIncomeId = Id FROM Indicators WHERE Name = N'Income Loss' AND ParentId = @NaturalEventId;
SELECT @NatFoodAccessId = Id FROM Indicators WHERE Name = N'Food Access Issues' AND ParentId = @NaturalEventId;
SELECT @NatDebtId = Id FROM Indicators WHERE Name = N'Debt Accumulation' AND ParentId = @NaturalEventId;

SELECT @ConflictLossIncomeId = Id FROM Indicators WHERE Name = N'Income Loss' AND ParentId = @ConflictEventId;
SELECT @ConflictFoodAccessId = Id FROM Indicators WHERE Name = N'Food Access Issues' AND ParentId = @ConflictEventId;
SELECT @ConflictDebtId = Id FROM Indicators WHERE Name = N'Debt Accumulation' AND ParentId = @ConflictEventId;

SELECT @CovidLossIncomeId = Id FROM Indicators WHERE Name = N'Income Loss' AND ParentId = @CovidEventId;
SELECT @CovidFoodAccessId = Id FROM Indicators WHERE Name = N'Food Access Issues' AND ParentId = @CovidEventId;
SELECT @CovidDebtId = Id FROM Indicators WHERE Name = N'Debt Accumulation' AND ParentId = @CovidEventId;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Level 3 - Data Indicators (Actual values go here)
-- =============================================================================
PRINT 'Seeding Level 3 Data Indicators...';

-- Economic Events - 2021 and 2022 Data
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'2021', @EconLossIncomeId, 3, @MillionsUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'2022', @EconLossIncomeId, 3, @MillionsUniteId, 2, N'#4CAF50', GETDATE(), @AdminUserId),
(N'2021', @EconFoodAccessId, 3, @MillionsUniteId, 1, N'#8BC34A', GETDATE(), @AdminUserId),
(N'2022', @EconFoodAccessId, 3, @MillionsUniteId, 2, N'#8BC34A', GETDATE(), @AdminUserId),
(N'2021', @EconDebtId, 3, @MillionsUniteId, 1, N'#CDDC39', GETDATE(), @AdminUserId),
(N'2022', @EconDebtId, 3, @MillionsUniteId, 2, N'#CDDC39', GETDATE(), @AdminUserId);

-- Natural Events - 2021 and 2022 Data
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'2021', @NatLossIncomeId, 3, @MillionsUniteId, 1, N'#2196F3', GETDATE(), @AdminUserId),
(N'2022', @NatLossIncomeId, 3, @MillionsUniteId, 2, N'#2196F3', GETDATE(), @AdminUserId),
(N'2021', @NatFoodAccessId, 3, @MillionsUniteId, 1, N'#03A9F4', GETDATE(), @AdminUserId),
(N'2022', @NatFoodAccessId, 3, @MillionsUniteId, 2, N'#03A9F4', GETDATE(), @AdminUserId),
(N'2021', @NatDebtId, 3, @MillionsUniteId, 1, N'#00BCD4', GETDATE(), @AdminUserId),
(N'2022', @NatDebtId, 3, @MillionsUniteId, 2, N'#00BCD4', GETDATE(), @AdminUserId);

-- Conflict Events - 2021 and 2022 Data
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'2021', @ConflictLossIncomeId, 3, @MillionsUniteId, 1, N'#FF9800', GETDATE(), @AdminUserId),
(N'2022', @ConflictLossIncomeId, 3, @MillionsUniteId, 2, N'#FF9800', GETDATE(), @AdminUserId),
(N'2021', @ConflictFoodAccessId, 3, @MillionsUniteId, 1, N'#FFC107', GETDATE(), @AdminUserId),
(N'2022', @ConflictFoodAccessId, 3, @MillionsUniteId, 2, N'#FFC107', GETDATE(), @AdminUserId),
(N'2021', @ConflictDebtId, 3, @MillionsUniteId, 1, N'#FFEB3B', GETDATE(), @AdminUserId),
(N'2022', @ConflictDebtId, 3, @MillionsUniteId, 2, N'#FFEB3B', GETDATE(), @AdminUserId);

-- COVID-19 Impact - 2021 and 2022 Data
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
(N'2021', @CovidLossIncomeId, 3, @MillionsUniteId, 1, N'#E91E63', GETDATE(), @AdminUserId),
(N'2022', @CovidLossIncomeId, 3, @MillionsUniteId, 2, N'#E91E63', GETDATE(), @AdminUserId),
(N'2021', @CovidFoodAccessId, 3, @MillionsUniteId, 1, N'#F44336', GETDATE(), @AdminUserId),
(N'2022', @CovidFoodAccessId, 3, @MillionsUniteId, 2, N'#F44336', GETDATE(), @AdminUserId),
(N'2021', @CovidDebtId, 3, @MillionsUniteId, 1, N'#FF5722', GETDATE(), @AdminUserId),
(N'2022', @CovidDebtId, 3, @MillionsUniteId, 2, N'#FF5722', GETDATE(), @AdminUserId);

-- Get Level 3 Indicator IDs
DECLARE @EconIncome2021Id INT, @EconIncome2022Id INT, @EconFood2021Id INT, @EconFood2022Id INT, @EconDebt2021Id INT, @EconDebt2022Id INT;
DECLARE @NatIncome2021Id INT, @NatIncome2022Id INT, @NatFood2021Id INT, @NatFood2022Id INT, @NatDebt2021Id INT, @NatDebt2022Id INT;
DECLARE @ConflictIncome2021Id INT, @ConflictIncome2022Id INT, @ConflictFood2021Id INT, @ConflictFood2022Id INT, @ConflictDebt2021Id INT, @ConflictDebt2022Id INT;
DECLARE @CovidIncome2021Id INT, @CovidIncome2022Id INT, @CovidFood2021Id INT, @CovidFood2022Id INT, @CovidDebt2021Id INT, @CovidDebt2022Id INT;

SELECT @EconIncome2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @EconLossIncomeId;
SELECT @EconIncome2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @EconLossIncomeId;
SELECT @EconFood2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @EconFoodAccessId;
SELECT @EconFood2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @EconFoodAccessId;
SELECT @EconDebt2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @EconDebtId;
SELECT @EconDebt2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @EconDebtId;

SELECT @NatIncome2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @NatLossIncomeId;
SELECT @NatIncome2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @NatLossIncomeId;
SELECT @NatFood2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @NatFoodAccessId;
SELECT @NatFood2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @NatFoodAccessId;
SELECT @NatDebt2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @NatDebtId;
SELECT @NatDebt2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @NatDebtId;

SELECT @ConflictIncome2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @ConflictLossIncomeId;
SELECT @ConflictIncome2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @ConflictLossIncomeId;
SELECT @ConflictFood2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @ConflictFoodAccessId;
SELECT @ConflictFood2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @ConflictFoodAccessId;
SELECT @ConflictDebt2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @ConflictDebtId;
SELECT @ConflictDebt2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @ConflictDebtId;

SELECT @CovidIncome2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @CovidLossIncomeId;
SELECT @CovidIncome2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @CovidLossIncomeId;
SELECT @CovidFood2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @CovidFoodAccessId;
SELECT @CovidFood2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @CovidFoodAccessId;
SELECT @CovidDebt2021Id = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @CovidDebtId;
SELECT @CovidDebt2022Id = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @CovidDebtId;

-- =============================================================================
-- HOUSEHOLD IMPACTS: Data Values for 2021 and 2022 (NOAA Survey Data)
-- =============================================================================
PRINT 'Seeding Household Impacts Data for 2021 and 2022...';

-- Get calendar IDs for December 31st of 2021 and 2022
DECLARE @Calendar2021Id INT, @Calendar2022Id INT;
SELECT @Calendar2021Id = Id FROM Calendars WHERE Year = 2021 AND Month = 12 AND Day = 31;
SELECT @Calendar2022Id = Id FROM Calendars WHERE Year = 2022 AND Month = 12 AND Day = 31;

INSERT INTO DataValues (IndicatorId, Value, CalendarId, LocationId)
VALUES 
-- Economic Event Impacts 2021
(@EconIncome2021Id, 2.8, @Calendar2021Id, @AfghanistanLocId),
(@EconFood2021Id, 2.1, @Calendar2021Id, @AfghanistanLocId),
(@EconDebt2021Id, 3.5, @Calendar2021Id, @AfghanistanLocId),

-- Economic Event Impacts 2022
(@EconIncome2022Id, 3.2, @Calendar2022Id, @AfghanistanLocId),
(@EconFood2022Id, 2.5, @Calendar2022Id, @AfghanistanLocId),
(@EconDebt2022Id, 4.1, @Calendar2022Id, @AfghanistanLocId),

-- Natural Event Impacts 2021
(@NatIncome2021Id, 2.4, @Calendar2021Id, @AfghanistanLocId),
(@NatFood2021Id, 2.7, @Calendar2021Id, @AfghanistanLocId),
(@NatDebt2021Id, 1.8, @Calendar2021Id, @AfghanistanLocId),

-- Natural Event Impacts 2022
(@NatIncome2022Id, 2.8, @Calendar2022Id, @AfghanistanLocId),
(@NatFood2022Id, 3.1, @Calendar2022Id, @AfghanistanLocId),
(@NatDebt2022Id, 2.2, @Calendar2022Id, @AfghanistanLocId),

-- Conflict Event Impacts 2021
(@ConflictIncome2021Id, 1.5, @Calendar2021Id, @AfghanistanLocId),
(@ConflictFood2021Id, 1.8, @Calendar2021Id, @AfghanistanLocId),
(@ConflictDebt2021Id, 1.2, @Calendar2021Id, @AfghanistanLocId),

-- Conflict Event Impacts 2022
(@ConflictIncome2022Id, 1.9, @Calendar2022Id, @AfghanistanLocId),
(@ConflictFood2022Id, 2.2, @Calendar2022Id, @AfghanistanLocId),
(@ConflictDebt2022Id, 1.5, @Calendar2022Id, @AfghanistanLocId),

-- COVID-19 Event Impacts 2021
(@CovidIncome2021Id, 4.2, @Calendar2021Id, @AfghanistanLocId),
(@CovidFood2021Id, 3.4, @Calendar2021Id, @AfghanistanLocId),
(@CovidDebt2021Id, 4.8, @Calendar2021Id, @AfghanistanLocId),

-- COVID-19 Event Impacts 2022
(@CovidIncome2022Id, 4.8, @Calendar2022Id, @AfghanistanLocId),
(@CovidFood2022Id, 3.9, @Calendar2022Id, @AfghanistanLocId),
(@CovidDebt2022Id, 5.2, @Calendar2022Id, @AfghanistanLocId);


-- =============================================================================
-- VERIFICATION: Check Household Impacts data with all metrics
-- =============================================================================
PRINT 'Verifying Household Impacts data with all calculated metrics...';

SELECT 
    grandparent.Name as "Event Type",
    parent.Name as "Impact Type", 
    i.Name as "Year",
    dv.Value,
    c.Year as "Calendar Year",
    dv.GrowthSinceLastPeriod as "Hierarchical Growth %",
    dv.PercentageOfParentTotal as "Global Share %",
    dv.GrowthSinceLastYearPeriod as "YoY Growth %"
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Indicators parent ON i.ParentId = parent.Id
INNER JOIN Indicators grandparent ON parent.ParentId = grandparent.Id
INNER JOIN Calendars c ON dv.CalendarId = c.Id
WHERE grandparent.ParentId = @HouseholdImpactsId
ORDER BY grandparent.OrderIndex, parent.OrderIndex, i.OrderIndex, c.Year;