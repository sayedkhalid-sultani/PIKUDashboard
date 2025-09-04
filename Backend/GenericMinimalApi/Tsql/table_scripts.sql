-- Drop foreign key constraints first
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ChartConfigs_IndicatorId')
    ALTER TABLE ChartConfigs DROP CONSTRAINT FK_ChartConfigs_IndicatorId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ChartConfigs_DepartmentId')
    ALTER TABLE ChartConfigs DROP CONSTRAINT FK_ChartConfigs_DepartmentId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ChartConfigs_CreatedByUserId')
    ALTER TABLE ChartConfigs DROP CONSTRAINT FK_ChartConfigs_CreatedByUserId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ChartConfigs_UpdatedByUserId')
    ALTER TABLE ChartConfigs DROP CONSTRAINT FK_ChartConfigs_UpdatedByUserId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ChartConfigs_DeletedByUserId')
    ALTER TABLE ChartConfigs DROP CONSTRAINT FK_ChartConfigs_DeletedByUserId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__Chart__236943A5')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__Chart__236943A5;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__Paren__22751F6C')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__Paren__22751F6C;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__UniteI__245D67DE')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__UniteI__245D67DE;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__Create__25518C17')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__Create__25518C17;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__Update__2645B050')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__Update__2645B050;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__Indicator__Delete__2739D489')
    ALTER TABLE Indicators DROP CONSTRAINT FK__Indicator__Delete__2739D489;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_IndicatorChartTypes_IndicatorId')
    ALTER TABLE IndicatorChartTypes DROP CONSTRAINT FK_IndicatorChartTypes_IndicatorId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValues_IndicatorId')
    ALTER TABLE DataValues DROP CONSTRAINT FK_DataValues_IndicatorId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValues_CalendarId')
    ALTER TABLE DataValues DROP CONSTRAINT FK_DataValues_CalendarId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValues_LocationId')
    ALTER TABLE DataValues DROP CONSTRAINT FK_DataValues_LocationId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValues_CreatedByUserId')
    ALTER TABLE DataValues DROP CONSTRAINT FK_DataValues_CreatedByUserId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValues_UpdatedByUserId')
    ALTER TABLE DataValues DROP CONSTRAINT FK_DataValues_UpdatedByUserId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DataValuesAudit_DataValueId')
    ALTER TABLE DataValuesAudit DROP CONSTRAINT FK_DataValuesAudit_DataValueId;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Locations_ParentId')
    ALTER TABLE Locations DROP CONSTRAINT FK_Locations_ParentId;

-- Drop tables in correct order
DROP TABLE IF EXISTS DataValuesAudit;
DROP TABLE IF EXISTS DataValues;
DROP TABLE IF EXISTS Sources;
DROP TABLE IF EXISTS IndicatorChartTypes;
DROP TABLE IF EXISTS ChartConfigs;
DROP TABLE IF EXISTS Indicators;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Calendars;
DROP TABLE IF EXISTS Unites;

-- Unites
CREATE TABLE Unites (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

-- Calendars
CREATE TABLE Calendars (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CalendarDate DATE NOT NULL,
    Year INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    Quarter INT NOT NULL,
    Day INT NOT NULL,
    Week INT NOT NULL,
    IsWeekend BIT NOT NULL,
    Description NVARCHAR(255) NULL
);
CREATE INDEX IX_Calendars_Year_Month ON Calendars(Year, Month);

-- Locations
CREATE TABLE Locations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Type NVARCHAR(50) NULL,
    ParentId INT NULL,
    Latitude FLOAT NULL,
    Longitude FLOAT NULL
);
CREATE INDEX IX_Locations_ParentId ON Locations(ParentId);

ALTER TABLE Locations 
ADD CONSTRAINT FK_Locations_ParentId FOREIGN KEY (ParentId) REFERENCES Locations(Id);

-- Indicators
CREATE TABLE Indicators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    ParentId INT NULL,
    OrderIndex INT NOT NULL,
    Level INT NOT NULL,
    Color NVARCHAR(10) NULL,
    UniteId INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserId INT NULL,
    UpdatedAt DATETIME NULL,
    UpdatedByUserId INT NULL,
    DeletedByUserId INT NULL,
    DeletedAt DATETIME NULL
);
CREATE INDEX IX_Indicators_ParentId ON Indicators(ParentId);
CREATE INDEX IX_Indicators_UniteId ON Indicators(UniteId);

ALTER TABLE Indicators 
ADD CONSTRAINT FK_Indicators_ParentId FOREIGN KEY (ParentId) REFERENCES Indicators(Id),
    CONSTRAINT FK_Indicators_UniteId FOREIGN KEY (UniteId) REFERENCES Unites(Id),
    CONSTRAINT FK_Indicators_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id),
    CONSTRAINT FK_Indicators_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES Users(Id),
    CONSTRAINT FK_Indicators_DeletedByUserId FOREIGN KEY (DeletedByUserId) REFERENCES Users(Id);

-- ChartConfigs
CREATE TABLE ChartConfigs (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IndicatorId INT NOT NULL UNIQUE,
    DepartmentId INT NOT NULL,
    ChartType NVARCHAR(50) NOT NULL,
    Title NVARCHAR(255) NULL,
    Subtitle NVARCHAR(255) NULL,
    Description NVARCHAR(255) NULL,
    MaxXAxisValue FLOAT NULL,
    MaxYAxisValue FLOAT NULL,
    GroupBy NVARCHAR(50) NULL,
    ChartConfigJson NVARCHAR(MAX) NULL,
    CalculateGrowthBy NVARCHAR(50) NOT NULL DEFAULT 'Legend',
    CalculateTotalBy NVARCHAR(50) NOT NULL DEFAULT 'Legend',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserId INT NULL,
    UpdatedAt DATETIME NULL,
    UpdatedByUserId INT NULL,
    DeletedByUserId INT NULL,
    DeletedAt DATETIME NULL
);
CREATE INDEX IX_ChartConfigs_IndicatorId ON ChartConfigs(IndicatorId);

ALTER TABLE ChartConfigs 
ADD CONSTRAINT FK_ChartConfigs_IndicatorId FOREIGN KEY (IndicatorId) REFERENCES Indicators(Id),
    CONSTRAINT FK_ChartConfigs_DepartmentId FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    CONSTRAINT FK_ChartConfigs_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id),
    CONSTRAINT FK_ChartConfigs_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES Users(Id),
    CONSTRAINT FK_ChartConfigs_DeletedByUserId FOREIGN KEY (DeletedByUserId) REFERENCES Users(Id);

-- IndicatorChartTypes
CREATE TABLE IndicatorChartTypes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChartType NVARCHAR(50) NOT NULL,
    IndicatorId INT NOT NULL
);
CREATE INDEX IX_IndicatorChartTypes_IndicatorId ON IndicatorChartTypes(IndicatorId);

ALTER TABLE IndicatorChartTypes 
ADD CONSTRAINT FK_IndicatorChartTypes_IndicatorId FOREIGN KEY (IndicatorId) REFERENCES Indicators(Id);

-- Sources
CREATE TABLE Sources (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(1000) NULL,
    IndicatorId INT NOT NULL
);
CREATE INDEX IX_Sources_IndicatorId ON Sources(IndicatorId);

ALTER TABLE Sources 
ADD CONSTRAINT FK_Sources_IndicatorId FOREIGN KEY (IndicatorId) REFERENCES Indicators(Id);

-- DataValues
CREATE TABLE DataValues (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IndicatorId INT NOT NULL,
    Value FLOAT NOT NULL,
    CalendarId INT NULL,
    LocationId INT NULL,
    PeriodType NVARCHAR(50) NOT NULL,
    LocationType NVARCHAR(50) NOT NULL,
    Growth FLOAT NULL,
    Total FLOAT NULL,
    DateAdded DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserId INT NULL,
    UpdatedByUserId INT NULL,
    UpdatedAt DATETIME NULL
);
CREATE INDEX IX_DataValues_IndicatorId ON DataValues(IndicatorId);
CREATE INDEX IX_DataValues_CalendarId ON DataValues(CalendarId);
CREATE INDEX IX_DataValues_LocationId ON DataValues(LocationId);
CREATE INDEX IX_DataValues_PeriodType ON DataValues(PeriodType);
CREATE INDEX IX_DataValues_LocationType ON DataValues(LocationType);

ALTER TABLE DataValues 
ADD CONSTRAINT FK_DataValues_IndicatorId FOREIGN KEY (IndicatorId) REFERENCES Indicators(Id),
    CONSTRAINT FK_DataValues_CalendarId FOREIGN KEY (CalendarId) REFERENCES Calendars(Id),
    CONSTRAINT FK_DataValues_LocationId FOREIGN KEY (LocationId) REFERENCES Locations(Id),
    CONSTRAINT FK_DataValues_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id),
    CONSTRAINT FK_DataValues_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES Users(Id);

-- DataValuesAudit
CREATE TABLE DataValuesAudit (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DataValueId INT NOT NULL,
    UpdatedAt DATETIME NULL,
    UpdatedByUserId INT NULL,
    DeletedByUserId INT NULL,
    DeletedAt DATETIME NULL
);
CREATE INDEX IX_DataValuesAudit_DataValueId ON DataValuesAudit(DataValueId);

ALTER TABLE DataValuesAudit 
ADD CONSTRAINT FK_DataValuesAudit_DataValueId FOREIGN KEY (DataValueId) REFERENCES DataValues(Id);