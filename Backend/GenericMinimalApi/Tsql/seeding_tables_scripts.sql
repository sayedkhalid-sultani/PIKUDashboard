-- Clean up existing data in correct order to respect foreign key constraints
DELETE FROM DataValuesAudit;
DELETE FROM DataValues;
DELETE FROM IndicatorChartTypes;
DELETE FROM Sources;
DELETE FROM ChartConfigs;
DELETE FROM Indicators;
DELETE FROM Locations;
DELETE FROM Calendars;
DELETE FROM Unites;

-- Reset identity seeds
DBCC CHECKIDENT ('DataValuesAudit', RESEED, 0);
DBCC CHECKIDENT ('DataValues', RESEED, 0);
DBCC CHECKIDENT ('IndicatorChartTypes', RESEED, 0);
DBCC CHECKIDENT ('Sources', RESEED, 0);
DBCC CHECKIDENT ('ChartConfigs', RESEED, 0);
DBCC CHECKIDENT ('Indicators', RESEED, 0);
DBCC CHECKIDENT ('Locations', RESEED, 0);
DBCC CHECKIDENT ('Calendars', RESEED, 0);
DBCC CHECKIDENT ('Unites', RESEED, 0);

-- Get UserId for 'sultani' and DepartmentId for 'Operations'
DECLARE @TradeUserId INT;
DECLARE @TradeDepartmentId INT;

SELECT @TradeUserId = Id FROM Users WHERE Username = 'sultani';
SELECT @TradeDepartmentId = Id FROM Departments WHERE Name = 'Operations';

-- If user or department doesn't exist, use default values
IF @TradeUserId IS NULL
    SET @TradeUserId = 1;

IF @TradeDepartmentId IS NULL
    SET @TradeDepartmentId = 1;

-- Unites - Create different units for different types of data
INSERT INTO Unites (Name) VALUES 
(N'Billion Dollar'),
(N'Percentage'),
(N'Count');

DECLARE @TradeUniteId INT;
DECLARE @PercentageUniteId INT;
DECLARE @CountUniteId INT;

SELECT @TradeUniteId = Id FROM Unites WHERE Name = N'Billion Dollar';
SELECT @PercentageUniteId = Id FROM Unites WHERE Name = N'Percentage';
SELECT @CountUniteId = Id FROM Unites WHERE Name = N'Count';

-- Locations
INSERT INTO Locations (Name, Type, ParentId) VALUES (N'Afghanistan', N'National', NULL);

DECLARE @TradeLocId INT = SCOPE_IDENTITY();

-- Calendars
INSERT INTO Calendars (CalendarDate, Year, Month, MonthName, Quarter, Day, Week, IsWeekend, Description)
VALUES
('2020-01-01', 2020, 1, N'January', 1, 1, 1, 0, N'Year 2020'),
('2021-01-01', 2021, 1, N'January', 1, 1, 1, 0, N'Year 2021'),
('2022-01-01', 2022, 1, N'January', 1, 1, 1, 0, N'Year 2022');

DECLARE @TradeCal2020 INT;
DECLARE @TradeCal2021 INT;
DECLARE @TradeCal2022 INT;

SELECT @TradeCal2020 = Id FROM Calendars WHERE Year = 2020 AND Month = 1;
SELECT @TradeCal2021 = Id FROM Calendars WHERE Year = 2021 AND Month = 1;
SELECT @TradeCal2022 = Id FROM Calendars WHERE Year = 2022 AND Month = 1;

-- Create main indicators with appropriate units
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, CreatedAt, CreatedByUserId)
VALUES 
(N'Trade Data', NULL, 0, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'Marital Status', NULL, 0, @PercentageUniteId, 2, GETDATE(), @TradeUserId);

DECLARE @TradeChartId INT;
DECLARE @MaritalStatusChartId INT;

SELECT @TradeChartId = Id FROM Indicators WHERE Name = N'Trade Data';
SELECT @MaritalStatusChartId = Id FROM Indicators WHERE Name = N'Marital Status';

-- Create ChartConfigs for main indicators
INSERT INTO ChartConfigs (IndicatorId, DepartmentId, ChartType, Title, Subtitle, Description, CalculateGrowthBy, CalculateTotalBy, CreatedAt, CreatedByUserId)
VALUES
(@TradeChartId, @TradeDepartmentId, N'bar', N'Trade Data', N'Exports, Imports, and Trade Deficit', N'Annual trade data', N'Legend', N'Legend', GETDATE(), @TradeUserId),
(@MaritalStatusChartId, @TradeDepartmentId, N'pie', N'Marital Status Distribution', N'Distribution of marital status types in population', N'Chart showing percentage distribution of different marital status types', N'legend', N'legend', GETDATE(), @TradeUserId);

-- Level 1 Indicators for Trade Data (using Billion Dollar unit)
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, CreatedAt, CreatedByUserId)
VALUES
(N'Exports', @TradeChartId, 1, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'Imports', @TradeChartId, 1, @TradeUniteId, 2, GETDATE(), @TradeUserId),
(N'Trade Deficit', @TradeChartId, 1, @TradeUniteId, 3, GETDATE(), @TradeUserId),
(N'Target', @TradeChartId, 1, @TradeUniteId, 4, GETDATE(), @TradeUserId);

DECLARE @TradeExportsId INT;
DECLARE @TradeImportsId INT;
DECLARE @TradeDeficitId INT;
DECLARE @TradeTargetId INT;

SELECT @TradeExportsId = Id FROM Indicators WHERE Name = N'Exports' AND ParentId = @TradeChartId;
SELECT @TradeImportsId = Id FROM Indicators WHERE Name = N'Imports' AND ParentId = @TradeChartId;
SELECT @TradeDeficitId = Id FROM Indicators WHERE Name = N'Trade Deficit' AND ParentId = @TradeChartId;
SELECT @TradeTargetId = Id FROM Indicators WHERE Name = N'Target' AND ParentId = @TradeChartId;

-- Level 2 (Year) for Trade Data indicators - Individual year names
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, CreatedAt, CreatedByUserId)
VALUES
(N'2020', @TradeExportsId, 2, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'2021', @TradeExportsId, 2, @TradeUniteId, 2, GETDATE(), @TradeUserId),
(N'2022', @TradeExportsId, 2, @TradeUniteId, 3, GETDATE(), @TradeUserId),
(N'2020', @TradeImportsId, 2, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'2021', @TradeImportsId, 2, @TradeUniteId, 2, GETDATE(), @TradeUserId),
(N'2022', @TradeImportsId, 2, @TradeUniteId, 3, GETDATE(), @TradeUserId),
(N'2020', @TradeDeficitId, 2, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'2021', @TradeDeficitId, 2, @TradeUniteId, 2, GETDATE(), @TradeUserId),
(N'2022', @TradeDeficitId, 2, @TradeUniteId, 3, GETDATE(), @TradeUserId),
(N'2020', @TradeTargetId, 2, @TradeUniteId, 1, GETDATE(), @TradeUserId),
(N'2021', @TradeTargetId, 2, @TradeUniteId, 2, GETDATE(), @TradeUserId),
(N'2022', @TradeTargetId, 2, @TradeUniteId, 3, GETDATE(), @TradeUserId);

-- Get Level 2 Trade Data IDs
DECLARE @TradeExp2020 INT;
DECLARE @TradeExp2021 INT;
DECLARE @TradeExp2022 INT;
DECLARE @TradeImp2020 INT;
DECLARE @TradeImp2021 INT;
DECLARE @TradeImp2022 INT;
DECLARE @TradeDef2020 INT;
DECLARE @TradeDef2021 INT;
DECLARE @TradeDef2022 INT;
DECLARE @TradeTarget2020 INT;
DECLARE @TradeTarget2021 INT;
DECLARE @TradeTarget2022 INT;

SELECT @TradeExp2020 = Id FROM Indicators WHERE Name = N'2020' AND ParentId = @TradeExportsId;
SELECT @TradeExp2021 = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @TradeExportsId;
SELECT @TradeExp2022 = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @TradeExportsId;
SELECT @TradeImp2020 = Id FROM Indicators WHERE Name = N'2020' AND ParentId = @TradeImportsId;
SELECT @TradeImp2021 = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @TradeImportsId;
SELECT @TradeImp2022 = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @TradeImportsId;
SELECT @TradeDef2020 = Id FROM Indicators WHERE Name = N'2020' AND ParentId = @TradeDeficitId;
SELECT @TradeDef2021 = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @TradeDeficitId;
SELECT @TradeDef2022 = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @TradeDeficitId;
SELECT @TradeTarget2020 = Id FROM Indicators WHERE Name = N'2020' AND ParentId = @TradeTargetId;
SELECT @TradeTarget2021 = Id FROM Indicators WHERE Name = N'2021' AND ParentId = @TradeTargetId;
SELECT @TradeTarget2022 = Id FROM Indicators WHERE Name = N'2022' AND ParentId = @TradeTargetId;

-- Link Target indicator to chart type "line"
INSERT INTO IndicatorChartTypes (ChartType, IndicatorId) VALUES (N'line', @TradeTargetId);

-- DataValues for Trade Data (in Billion Dollars)
INSERT INTO DataValues (IndicatorId, Value, CalendarId, LocationId, PeriodType, LocationType, CreatedByUserId)
VALUES
(@TradeExp2020, 0.8, @TradeCal2020, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeExp2021, 0.9, @TradeCal2021, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeExp2022, 1.8, @TradeCal2022, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeImp2020, 6.5, @TradeCal2020, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeImp2021, 5.3, @TradeCal2021, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeImp2022, 6.5, @TradeCal2022, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeDef2020, -5.7, @TradeCal2020, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeDef2021, -4.4, @TradeCal2021, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeDef2022, -4.7, @TradeCal2022, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeTarget2020, 2.0, @TradeCal2020, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeTarget2021, 2.5, @TradeCal2021, @TradeLocId, N'Yearly', N'National', @TradeUserId),
(@TradeTarget2022, 3.0, @TradeCal2022, @TradeLocId, N'Yearly', N'National', @TradeUserId);

-- Level 1 Indicators for Marital Status (using Percentage unit)
INSERT INTO Indicators (Name, ParentId, OrderIndex, Level, UniteId, CreatedAt, CreatedByUserId)
VALUES 
('Single', @MaritalStatusChartId, 1, 1, @PercentageUniteId, GETDATE(), @TradeUserId),
('Divorced', @MaritalStatusChartId, 2, 1, @PercentageUniteId, GETDATE(), @TradeUserId),
('Widowed', @MaritalStatusChartId, 3, 1, @PercentageUniteId, GETDATE(), @TradeUserId),
('Married', @MaritalStatusChartId, 4, 1, @PercentageUniteId, GETDATE(), @TradeUserId),
('Married - Spouse Abroad', @MaritalStatusChartId, 5, 1, @PercentageUniteId, GETDATE(), @TradeUserId),
('Small Family', @MaritalStatusChartId, 6, 1, @PercentageUniteId, GETDATE(), @TradeUserId);

-- Get Level 1 Marital Status IDs
DECLARE @SingleId INT;
DECLARE @DivorcedId INT;
DECLARE @WidowedId INT;
DECLARE @MarriedId INT;
DECLARE @MarriedAbroadId INT;
DECLARE @SmallFamilyId INT;

SELECT @SingleId = Id FROM Indicators WHERE Name = 'Single' AND ParentId = @MaritalStatusChartId;
SELECT @DivorcedId = Id FROM Indicators WHERE Name = 'Divorced' AND ParentId = @MaritalStatusChartId;
SELECT @WidowedId = Id FROM Indicators WHERE Name = 'Widowed' AND ParentId = @MaritalStatusChartId;
SELECT @MarriedId = Id FROM Indicators WHERE Name = 'Married' AND ParentId = @MaritalStatusChartId;
SELECT @MarriedAbroadId = Id FROM Indicators WHERE Name = 'Married - Spouse Abroad' AND ParentId = @MaritalStatusChartId;
SELECT @SmallFamilyId = Id FROM Indicators WHERE Name = 'Small Family' AND ParentId = @MaritalStatusChartId;

-- Level 2 Indicators for Marital Status - Individual gender names
INSERT INTO Indicators (Name, ParentId, OrderIndex, Level, UniteId, CreatedAt, CreatedByUserId)
VALUES 
('Male', @SingleId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @SingleId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Male', @DivorcedId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @DivorcedId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Male', @WidowedId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @WidowedId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Male', @MarriedId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @MarriedId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Male', @MarriedAbroadId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @MarriedAbroadId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Male', @SmallFamilyId, 1, 2, @PercentageUniteId, GETDATE(), @TradeUserId),
('Female', @SmallFamilyId, 2, 2, @PercentageUniteId, GETDATE(), @TradeUserId);

-- Get Level 2 Marital Status IDs
DECLARE @SingleMaleId INT;
DECLARE @SingleFemaleId INT;
DECLARE @DivorcedMaleId INT;
DECLARE @DivorcedFemaleId INT;
DECLARE @WidowedMaleId INT;
DECLARE @WidowedFemaleId INT;
DECLARE @MarriedMaleId INT;
DECLARE @MarriedFemaleId INT;
DECLARE @MarriedAbroadMaleId INT;
DECLARE @MarriedAbroadFemaleId INT;
DECLARE @SmallFamilyMaleId INT;
DECLARE @SmallFamilyFemaleId INT;

SELECT @SingleMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @SingleId;
SELECT @SingleFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @SingleId;
SELECT @DivorcedMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @DivorcedId;
SELECT @DivorcedFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @DivorcedId;
SELECT @WidowedMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @WidowedId;
SELECT @WidowedFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @WidowedId;
SELECT @MarriedMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @MarriedId;
SELECT @MarriedFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @MarriedId;
SELECT @MarriedAbroadMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @MarriedAbroadId;
SELECT @MarriedAbroadFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @MarriedAbroadId;
SELECT @SmallFamilyMaleId = Id FROM Indicators WHERE Name = 'Male' AND ParentId = @SmallFamilyId;
SELECT @SmallFamilyFemaleId = Id FROM Indicators WHERE Name = 'Female' AND ParentId = @SmallFamilyId;

-- DataValues for Marital Status (in Percentages)
DECLARE @CurrentCalendarId INT;
SELECT @CurrentCalendarId = Id FROM Calendars WHERE Year = 2025 AND Month = 8;

IF @CurrentCalendarId IS NULL
BEGIN
    INSERT INTO Calendars (CalendarDate, Year, Month, MonthName, Quarter, Day, Week, IsWeekend, Description)
    VALUES ('2025-08-01', 2025, 8, 'August', 3, 1, 1, 0, 'Marital Status Data');
    SET @CurrentCalendarId = SCOPE_IDENTITY();
END

INSERT INTO DataValues (IndicatorId, Value, CalendarId, LocationId, PeriodType, LocationType, CreatedByUserId)
VALUES 
(@SingleMaleId, 15.0, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@SingleFemaleId, 10.5, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@DivorcedMaleId, 3.2, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@DivorcedFemaleId, 5.0, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@WidowedMaleId, 1.5, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@WidowedFemaleId, 2.2, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@MarriedMaleId, 22.0, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@MarriedFemaleId, 23.3, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@MarriedAbroadMaleId, 6.1, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@MarriedAbroadFemaleId, 6.0, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@SmallFamilyMaleId, 2.5, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId),
(@SmallFamilyFemaleId, 2.7, @CurrentCalendarId, @TradeLocId, 'Yearly', 'National', @TradeUserId);

-- Seed additional Locations with GIS data
INSERT INTO Locations (Name, Type, ParentId, Latitude, Longitude)
VALUES 
(N'Kabul', N'Province', @TradeLocId, 34.5553, 69.2075),
(N'Herat', N'Province', @TradeLocId, 34.3482, 62.1997);

-- Seed Sources for indicators (multiple sources per indicator)
INSERT INTO Sources (Name, Description, IndicatorId)
VALUES
(N'World Bank', N'Trade statistics from World Bank', @TradeChartId),
(N'Afghanistan Customs', N'Official customs data', @TradeChartId),
(N'Central Statistics Organization', N'Marital status survey data', @MaritalStatusChartId),
(N'UN Population Division', N'International marital status data', @MaritalStatusChartId);

-- Add sources for sub-indicators
INSERT INTO Sources (Name, Description, IndicatorId)
VALUES
(N'Export Authority', N'Exports data for Afghanistan', @TradeExportsId),
(N'Import Authority', N'Imports data for Afghanistan', @TradeImportsId);

PRINT 'Data seeding completed successfully!';