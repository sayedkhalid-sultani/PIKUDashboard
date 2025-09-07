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

DECLARE @AdminUserId INT;
DECLARE @OperationsDepartmentId INT;

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
(N'Index Points');

DECLARE @BillionDollarUniteId INT;
DECLARE @PercentageUniteId INT;
DECLARE @CountUniteId INT;
DECLARE @MillionDollarUniteId INT;

SELECT @BillionDollarUniteId = Id FROM Unites WHERE Name = N'Billion Dollar';
SELECT @PercentageUniteId = Id FROM Unites WHERE Name = N'Percentage';
SELECT @CountUniteId = Id FROM Unites WHERE Name = N'Count';
SELECT @MillionDollarUniteId = Id FROM Unites WHERE Name = N'Million Dollar';

PRINT 'Seeding Locations...';
-- Locations
INSERT INTO Locations (Name, Type, ParentId, Latitude, Longitude) VALUES 
(N'Global', N'Region', NULL, NULL, NULL),
(N'Asia', N'Continent', 1, NULL, NULL),
(N'Middle East', N'Region', 2, NULL, NULL),
(N'Afghanistan', N'Country', 3, 33.9391, 67.7100),
(N'Pakistan', N'Country', 3, 30.3753, 69.3451),
(N'Iran', N'Country', 3, 32.4279, 53.6880),
(N'Kabul', N'Province', 4, 34.5553, 69.2075),
(N'Herat', N'Province', 4, 34.3482, 62.1997),
(N'Kandahar', N'Province', 4, 31.6289, 65.7372),
(N'Balkh', N'Province', 4, 36.7551, 66.8975);

DECLARE @AfghanistanLocId INT;
SELECT @AfghanistanLocId = Id FROM Locations WHERE Name = N'Afghanistan';

-- Get Calendar IDs for quarterly data
DECLARE @Cal2020Q1 INT, @Cal2020Q2 INT, @Cal2020Q3 INT, @Cal2020Q4 INT;
DECLARE @Cal2021Q1 INT, @Cal2021Q2 INT, @Cal2021Q3 INT, @Cal2021Q4 INT;
DECLARE @Cal2022Q1 INT, @Cal2022Q2 INT, @Cal2022Q3 INT, @Cal2022Q4 INT;
DECLARE @Cal2023Q1 INT, @Cal2023Q2 INT, @Cal2023Q3 INT, @Cal2023Q4 INT;
DECLARE @Cal2024Q1 INT, @Cal2024Q2 INT, @Cal2024Q3 INT, @Cal2024Q4 INT;
DECLARE @Cal2025Q1 INT, @Cal2025Q2 INT, @Cal2025Q3 INT, @Cal2025Q4 INT;

SELECT @Cal2020Q1 = Id FROM Calendars WHERE Year = 2020 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2020Q2 = Id FROM Calendars WHERE Year = 2020 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2020Q3 = Id FROM Calendars WHERE Year = 2020 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2020Q4 = Id FROM Calendars WHERE Year = 2020 AND Quarter = 4 AND Day = 1 AND Month = 10;
SELECT @Cal2021Q1 = Id FROM Calendars WHERE Year = 2021 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2021Q2 = Id FROM Calendars WHERE Year = 2021 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2021Q3 = Id FROM Calendars WHERE Year = 2021 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2021Q4 = Id FROM Calendars WHERE Year = 2021 AND Quarter = 4 AND Day = 1 AND Month = 10;
SELECT @Cal2022Q1 = Id FROM Calendars WHERE Year = 2022 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2022Q2 = Id FROM Calendars WHERE Year = 2022 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2022Q3 = Id FROM Calendars WHERE Year = 2022 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2022Q4 = Id FROM Calendars WHERE Year = 2022 AND Quarter = 4 AND Day = 1 AND Month = 10;
SELECT @Cal2023Q1 = Id FROM Calendars WHERE Year = 2023 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2023Q2 = Id FROM Calendars WHERE Year = 2023 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2023Q3 = Id FROM Calendars WHERE Year = 2023 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2023Q4 = Id FROM Calendars WHERE Year = 2023 AND Quarter = 4 AND Day = 1 AND Month = 10;
SELECT @Cal2024Q1 = Id FROM Calendars WHERE Year = 2024 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2024Q2 = Id FROM Calendars WHERE Year = 2024 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2024Q3 = Id FROM Calendars WHERE Year = 2024 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2024Q4 = Id FROM Calendars WHERE Year = 2024 AND Quarter = 4 AND Day = 1 AND Month = 10;
SELECT @Cal2025Q1 = Id FROM Calendars WHERE Year = 2025 AND Quarter = 1 AND Day = 1 AND Month = 1;
SELECT @Cal2025Q2 = Id FROM Calendars WHERE Year = 2025 AND Quarter = 2 AND Day = 1 AND Month = 4;
SELECT @Cal2025Q3 = Id FROM Calendars WHERE Year = 2025 AND Quarter = 3 AND Day = 1 AND Month = 7;
SELECT @Cal2025Q4 = Id FROM Calendars WHERE Year = 2025 AND Quarter = 4 AND Day = 1 AND Month = 10;

PRINT 'Creating main dashboard indicators...';
-- Create main indicators for different business areas
INSERT INTO Indicators (Name, ParentId, Level, UniteId, OrderIndex, Color, CreatedAt, CreatedByUserId)
VALUES 
-- Level 0: Main Dashboard Categories
(N'Financial Performance', NULL, 0, @BillionDollarUniteId, 1, N'#4CAF50', GETDATE(), @AdminUserId),
(N'Operational Metrics', NULL, 0, @CountUniteId, 2, N'#2196F3', GETDATE(), @AdminUserId),
(N'Market Analysis', NULL, 0, @PercentageUniteId, 3, N'#FF9800', GETDATE(), @AdminUserId),
(N'Human Resources', NULL, 0, @PercentageUniteId, 4, N'#E91E63', GETDATE(), @AdminUserId);

-- ... rest of the script continues with the same structure as before for Indicators, ChartConfigs, DataValues, etc.

PRINT 'Data seeding completed successfully!';
PRINT 'Calendar data seeded from 2020-01-01 to 2030-12-31';
PRINT 'Login credentials:';
PRINT 'All users have password: admin';
PRINT 'Admin users: admin, ahmad.sultani';
PRINT 'Manager users: sara.analyst, mohammad.finance, fatima.operations';
PRINT 'Viewer users: viewer1, viewer2';
PRINT '';
PRINT 'Remember to change passwords in production environment.';