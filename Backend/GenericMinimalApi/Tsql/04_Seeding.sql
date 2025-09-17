-- PIKUDashboard Data Seeding Script
-- Clean up existing data
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
-- DECLARE ALL VARIABLES
-- =============================================================================
DECLARE @AdminUserId INT;
DECLARE @AfghanistanLocId INT;
DECLARE @MillionsUniteId INT;
DECLARE @Calendar2021Id INT, @Calendar2022Id INT, @Calendar2023Id INT, @Calendar2024Id INT;

-- =============================================================================
-- Indicator and Data Value Variables
-- =============================================================================

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
INSERT INTO Departments (Name, ParentID) VALUES 
(N'Executive Leadership', NULL),
(N'Finance & Analytics', 1),
(N'Operations', 1);

PRINT 'Seeding Users...';
INSERT INTO Users (Username, PasswordHash, Role, Departments, IsLocked) VALUES 
(N'admin', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwwaKrmTnPWY86FBJKTs/IyW6IMo=', N'Admin', 1, 0);

SELECT @AdminUserId = Id FROM Users WHERE Username = 'admin';

PRINT 'Seeding Unites...';
INSERT INTO Unites (Name) VALUES 
(N'Millions');
SELECT @MillionsUniteId = Id FROM Unites WHERE Name = N'Millions';

PRINT 'Seeding Locations...';
INSERT INTO Locations (Name, Type, ParentId) VALUES 
(N'Global', N'Region', NULL),
(N'Asia', N'Continent', 1),
(N'Middle East', N'Region', 2),
(N'Afghanistan', N'Country', 3);
SELECT @AfghanistanLocId = Id FROM Locations WHERE Name = N'Afghanistan';

-- =============================================================================
-- Chart Data: Type of impact of specific events on households
-- =============================================================================

---
--- Indicator Seeding for "Type of impact of specific events on households"
---


-- Indicator Hierarchy IDs
DECLARE @MainImpactsId INT;
DECLARE @EconomicImpactId INT, @NaturalImpactId INT, @ConflictImpactId INT, @CovidImpactId INT;
DECLARE @EcoLossId INT, @EcoFoodId INT, @EcoDebtId INT;
DECLARE @NatLossId INT, @NatFoodId INT, @NatDebtId INT;
DECLARE @ConLossId INT, @ConFoodId INT, @ConDebtId INT;
DECLARE @CovLossId INT, @CovFoodId INT, @CovDebtId INT;

-- Data Value IDs (not strictly necessary for the insert, but useful for reference)
DECLARE @EcoLoss2021ValId INT;
DECLARE @EcoFood2021ValId INT;
DECLARE @EcoDebt2021ValId INT;
DECLARE @NatLoss2022ValId INT;
DECLARE @NatFood2022ValId INT;
DECLARE @NatDebt2022ValId INT;
DECLARE @ConLoss2023ValId INT;
DECLARE @ConFood2023ValId INT;
DECLARE @ConDebt2023ValId INT;
DECLARE @CovLoss2024ValId INT;
DECLARE @CovFood2024ValId INT;
DECLARE @CovDebt2024ValId INT;

PRINT 'Seeding Indicators for "Type of impact of specific events on households" hierarchy...';
INSERT INTO [dbo].[Indicators] ([Name], [ParentId], [OrderIndex], [Level], [UniteId], [CreatedAt])
VALUES ('Type of impact of specific events on households', NULL, 1, 1, @MillionsUniteId, GETDATE());
SELECT @MainImpactsId = SCOPE_IDENTITY();

-- Level 2: Main Categories
INSERT INTO [dbo].[Indicators] ([Name], [ParentId], [OrderIndex], [Level], [UniteId], [CreatedAt])
VALUES 
('Economic', @MainImpactsId, 1, 2, @MillionsUniteId, GETDATE()),
('Natural', @MainImpactsId, 2, 2, @MillionsUniteId, GETDATE()),
('Conflict', @MainImpactsId, 3, 2, @MillionsUniteId, GETDATE()),
('COVID-19', @MainImpactsId, 4, 2, @MillionsUniteId, GETDATE());

SELECT @EconomicImpactId = Id FROM Indicators WHERE Name = 'Economic' AND ParentId = @MainImpactsId;
SELECT @NaturalImpactId = Id FROM Indicators WHERE Name = 'Natural' AND ParentId = @MainImpactsId;
SELECT @ConflictImpactId = Id FROM Indicators WHERE Name = 'Conflict' AND ParentId = @MainImpactsId;
SELECT @CovidImpactId = Id FROM Indicators WHERE Name = 'COVID-19' AND ParentId = @MainImpactsId;

-- Level 3: Sub-indicators
INSERT INTO [dbo].[Indicators] ([Name], [ParentId], [OrderIndex], [Level], [UniteId], [CreatedAt])
VALUES 
-- Economic
('Loss of income', @EconomicImpactId, 1, 3, @MillionsUniteId, GETDATE()),
('Limited access to food', @EconomicImpactId, 2, 3, @MillionsUniteId, GETDATE()),
('Taking on debt', @EconomicImpactId, 3, 3, @MillionsUniteId, GETDATE()),

-- Natural
('Loss of income', @NaturalImpactId, 1, 3, @MillionsUniteId, GETDATE()),
('Limited access to food', @NaturalImpactId, 2, 3, @MillionsUniteId, GETDATE()),
('Taking on debt', @NaturalImpactId, 3, 3, @MillionsUniteId, GETDATE()),

-- Conflict
('Loss of income', @ConflictImpactId, 1, 3, @MillionsUniteId, GETDATE()),
('Limited access to food', @ConflictImpactId, 2, 3, @MillionsUniteId, GETDATE()),
('Taking on debt', @ConflictImpactId, 3, 3, @MillionsUniteId, GETDATE()),

-- COVID-19
('Loss of income', @CovidImpactId, 1, 3, @MillionsUniteId, GETDATE()),
('Limited access to food', @CovidImpactId, 2, 3, @MillionsUniteId, GETDATE()),
('Taking on debt', @CovidImpactId, 3, 3, @MillionsUniteId, GETDATE());

-- Get new sub-indicator IDs
SELECT @EcoLossId = Id FROM Indicators WHERE Name = 'Loss of income' AND ParentId = @EconomicImpactId;
SELECT @EcoFoodId = Id FROM Indicators WHERE Name = 'Limited access to food' AND ParentId = @EconomicImpactId;
SELECT @EcoDebtId = Id FROM Indicators WHERE Name = 'Taking on debt' AND ParentId = @EconomicImpactId;

SELECT @NatLossId = Id FROM Indicators WHERE Name = 'Loss of income' AND ParentId = @NaturalImpactId;
SELECT @NatFoodId = Id FROM Indicators WHERE Name = 'Limited access to food' AND ParentId = @NaturalImpactId;
SELECT @NatDebtId = Id FROM Indicators WHERE Name = 'Taking on debt' AND ParentId = @NaturalImpactId;

SELECT @ConLossId = Id FROM Indicators WHERE Name = 'Loss of income' AND ParentId = @ConflictImpactId;
SELECT @ConFoodId = Id FROM Indicators WHERE Name = 'Limited access to food' AND ParentId = @ConflictImpactId;
SELECT @ConDebtId = Id FROM Indicators WHERE Name = 'Taking on debt' AND ParentId = @ConflictImpactId;

SELECT @CovLossId = Id FROM Indicators WHERE Name = 'Loss of income' AND ParentId = @CovidImpactId;
SELECT @CovFoodId = Id FROM Indicators WHERE Name = 'Limited access to food' AND ParentId = @CovidImpactId;
SELECT @CovDebtId = Id FROM Indicators WHERE Name = 'Taking on debt' AND ParentId = @CovidImpactId;

---
--- Data Value Seeding
---

PRINT 'Linking data values to the new indicators...';
SELECT @Calendar2021Id = Id FROM Calendars WHERE Year = 2021 AND Month = 1 AND Day = 1;
SELECT @Calendar2022Id = Id FROM Calendars WHERE Year = 2022 AND Month = 1 AND Day = 1;
SELECT @Calendar2023Id = Id FROM Calendars WHERE Year = 2023 AND Month = 1 AND Day = 1;
SELECT @Calendar2024Id = Id FROM Calendars WHERE Year = 2024 AND Month = 1 AND Day = 1;

-- Insert data values with different calendar years and Afghanistan location
INSERT INTO [dbo].[DataValues] ([IndicatorId], [Value], [CalendarId], [LocationId])
VALUES 
-- Economic (2021)
(@EcoLossId, 3.3, @Calendar2021Id, @AfghanistanLocId),
(@EcoFoodId, 2.9, @Calendar2021Id, @AfghanistanLocId),
(@EcoDebtId, 2.4, @Calendar2021Id, @AfghanistanLocId),

-- Natural (2022)
(@NatLossId, 3.3, @Calendar2022Id, @AfghanistanLocId),
(@NatFoodId, 2.6, @Calendar2022Id, @AfghanistanLocId),
(@NatDebtId, 2.0, @Calendar2022Id, @AfghanistanLocId),

-- Conflict (2023)
(@ConLossId, 0.2, @Calendar2023Id, @AfghanistanLocId),
(@ConFoodId, 0.2, @Calendar2023Id, @AfghanistanLocId),
(@ConDebtId, 0.1, @Calendar2023Id, @AfghanistanLocId),

-- COVID-19 (2024)
(@CovLossId, 0.3, @Calendar2024Id, @AfghanistanLocId),
(@CovFoodId, 0.2, @Calendar2024Id, @AfghanistanLocId),
(@CovDebtId, 0.2, @Calendar2024Id, @AfghanistanLocId);
SELECT 
    -- Grandparent Level (Main Category)
    gp.Name as 'MainCategory',

    -- Parent Level (Event Type)
    p.Name as 'EventType',
    p.OrderIndex as 'EventTypeOrder',
    
    -- Indicator Level (Specific Impact)
    i.Name as 'ImpactType',
    i.OrderIndex as 'ImpactTypeOrder',
    i.Level,
    
    -- Data Values
    dv.Value,
    dv.GrowthSinceLastPeriod,
    dv.GrowthSinceLastYearPeriod,
    dv.PercentageOfParentTotal,
    
    -- Calendar Information
    c.CalendarDate,
    c.Year,
    c.MonthName,
    c.Quarter,
    
    -- Location Information (if available)
    l.Name as 'LocationName',
    l.Type as 'LocationType'
    
FROM DataValues dv
INNER JOIN Indicators i ON dv.IndicatorId = i.Id
INNER JOIN Indicators p ON i.ParentId = p.Id
INNER JOIN Indicators gp ON p.ParentId = gp.Id
INNER JOIN Calendars c ON dv.CalendarId = c.Id
LEFT JOIN Locations l ON dv.LocationId = l.Id
WHERE gp.Name = 'Type of impact of specific events on households'
ORDER BY 
    gp.OrderIndex, 
    p.OrderIndex, 
    i.OrderIndex, 
    c.Year;