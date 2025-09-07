-- Table definitions with foreign keys included, in dependency order

CREATE TABLE [dbo].[Unites](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] [nvarchar](100) NOT NULL
);

CREATE TABLE [dbo].[Users](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Username] [nvarchar](100) NOT NULL,
    [PasswordHash] [nvarchar](255) NOT NULL,
    [Role] [nvarchar](20) NOT NULL,
    [Departments] [int] NULL,
    [IsLocked] [bit] NOT NULL DEFAULT ((0))
);

CREATE TABLE [dbo].[Departments](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] [nvarchar](100) NOT NULL,
    [ParentID] [int] NULL
);

CREATE TABLE [dbo].[Indicators](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] [nvarchar](100) NOT NULL,
    [ParentId] [int] NULL,
    [OrderIndex] [int] NOT NULL,
    [Level] [int] NOT NULL,
    [Color] [nvarchar](10) NULL,
    [UniteId] [int] NOT NULL,
    [CreatedAt] [datetime] NOT NULL DEFAULT (getdate()),
    [CreatedByUserId] [int] NULL,
    [UpdatedAt] [datetime] NULL,
    [UpdatedByUserId] [int] NULL,
    [DeletedByUserId] [int] NULL,
    [DeletedAt] [datetime] NULL,
    CONSTRAINT [FK_Indicators_ParentId] FOREIGN KEY([ParentId]) REFERENCES [dbo].[Indicators] ([Id]),
    CONSTRAINT [FK_Indicators_UniteId] FOREIGN KEY([UniteId]) REFERENCES [dbo].[Unites] ([Id]),
    CONSTRAINT [FK_Indicators_CreatedByUserId] FOREIGN KEY([CreatedByUserId]) REFERENCES [dbo].[Users] ([Id]),
    CONSTRAINT [FK_Indicators_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId]) REFERENCES [dbo].[Users] ([Id]),
    CONSTRAINT [FK_Indicators_DeletedByUserId] FOREIGN KEY([DeletedByUserId]) REFERENCES [dbo].[Users] ([Id])
);

CREATE TABLE [dbo].[Calendars](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CalendarDate] [date] NOT NULL,
    [Year] [int] NOT NULL,
    [Month] [int] NOT NULL,
    [MonthName] [nvarchar](20) NOT NULL,
    [Quarter] [int] NOT NULL,
    [Day] [int] NOT NULL,
    [Week] [int] NOT NULL,
    [IsWeekend] [bit] NOT NULL,
    [Description] [nvarchar](255) NULL,
    [MonthShortLabel] [nvarchar](10) NOT NULL DEFAULT(''),      -- new column
    [QuarterShortLabel] [nvarchar](10) NOT NULL DEFAULT(''),    -- new column
    [YearQuarterLabel] [nvarchar](20) NOT NULL DEFAULT(''),     -- new column
    [MonthYearLabel] [nvarchar](20) NOT NULL DEFAULT('')        -- new column
);

CREATE TABLE [dbo].[Locations](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] [nvarchar](100) NOT NULL,
    [Type] [nvarchar](50) NULL,
    [ParentId] [int] NULL,
    CONSTRAINT [FK_Locations_ParentId] FOREIGN KEY([ParentId]) REFERENCES [dbo].[Locations] ([Id])
);

CREATE TABLE [dbo].[DataValues](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IndicatorId] [int] NOT NULL,
    [Value] [float] NOT NULL,
    [CalendarId] [int] NULL,
    [LocationId] [int] NULL,
    [PeriodType] [nvarchar](50) NOT NULL,
    [LocationType] [nvarchar](50) NOT NULL,
    [Growth] [float] NULL,
    [Total] [float] NULL,
    [DateAdded] [datetime] NOT NULL DEFAULT (getdate()),
    [CreatedByUserId] [int] NULL,
    [UpdatedByUserId] [int] NULL,
    [UpdatedAt] [datetime] NULL,
    CONSTRAINT [FK_DataValues_IndicatorId] FOREIGN KEY([IndicatorId]) REFERENCES [dbo].[Indicators] ([Id]),
    CONSTRAINT [FK_DataValues_CalendarId] FOREIGN KEY([CalendarId]) REFERENCES [dbo].[Calendars] ([Id]),
    CONSTRAINT [FK_DataValues_LocationId] FOREIGN KEY([LocationId]) REFERENCES [dbo].[Locations] ([Id]),
    CONSTRAINT [FK_DataValues_CreatedByUserId] FOREIGN KEY([CreatedByUserId]) REFERENCES [dbo].[Users] ([Id]),
    CONSTRAINT [FK_DataValues_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId]) REFERENCES [dbo].[Users] ([Id])
);

CREATE TABLE [dbo].[DataValuesAudit](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [DataValueId] [int] NOT NULL,
    [UpdatedAt] [datetime] NULL,
    [UpdatedByUserId] [int] NULL,
    [DeletedByUserId] [int] NULL,
    [DeletedAt] [datetime] NULL,
    CONSTRAINT [FK_DataValuesAudit_DataValueId] FOREIGN KEY([DataValueId]) REFERENCES [dbo].[DataValues] ([Id])
);

CREATE TABLE [dbo].[IndicatorChartTypes](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ChartType] [nvarchar](50) NOT NULL,
    [IndicatorId] [int] NOT NULL,
    CONSTRAINT [FK_IndicatorChartTypes_IndicatorId] FOREIGN KEY([IndicatorId]) REFERENCES [dbo].[Indicators] ([Id])
);

CREATE TABLE [dbo].[Sources](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] [nvarchar](255) NOT NULL,
    [Description] [nvarchar](1000) NULL,
    [IndicatorId] [int] NOT NULL,
    CONSTRAINT [FK_Sources_IndicatorId] FOREIGN KEY([IndicatorId]) REFERENCES [dbo].[Indicators] ([Id])
);

CREATE TABLE [dbo].[ChartConfigs](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IndicatorId] [int] NOT NULL,
    [DepartmentId] [int] NOT NULL,
    [ChartType] [nvarchar](50) NOT NULL,
    [Title] [nvarchar](255) NULL,
    [Subtitle] [nvarchar](255) NULL,
    [Description] [nvarchar](255) NULL,
    [MaxXAxisValue] [float] NULL,
    [MaxYAxisValue] [float] NULL,
    [GroupBy] [nvarchar](50) NULL,
    [ChartConfigJson] [nvarchar](max) NULL,
    [CalculateGrowthBy] [nvarchar](50) NOT NULL DEFAULT ('Legend'),
    [CalculateTotalBy] [nvarchar](50) NOT NULL DEFAULT ('Legend'),
    [CreatedAt] [datetime] NOT NULL DEFAULT (getdate()),
    [CreatedByUserId] [int] NULL,
    [UpdatedAt] [datetime] NULL,
    [UpdatedByUserId] [int] NULL,
    [DeletedByUserId] [int] NULL,
    [DeletedAt] [datetime] NULL,
    CONSTRAINT [FK_ChartConfigs_IndicatorId] FOREIGN KEY([IndicatorId]) REFERENCES [dbo].[Indicators] ([Id]),
    CONSTRAINT [FK_ChartConfigs_DepartmentId] FOREIGN KEY([DepartmentId]) REFERENCES [dbo].[Departments] ([Id]),
    CONSTRAINT [FK_ChartConfigs_CreatedByUserId] FOREIGN KEY([CreatedByUserId]) REFERENCES [dbo].[Users] ([Id]),
    CONSTRAINT [FK_ChartConfigs_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId]) REFERENCES [dbo].[Users] ([Id]),
    CONSTRAINT [FK_ChartConfigs_DeletedByUserId] FOREIGN KEY([DeletedByUserId]) REFERENCES [dbo].[Users] ([Id])
);

CREATE TABLE [dbo].[RefreshTokens](
    [Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
    [UserId] [int] NOT NULL,
    [TokenHash] [nvarchar](256) NOT NULL UNIQUE,
    [JwtId] [uniqueidentifier] NOT NULL,
    [ExpiresAt] [datetime2](7) NOT NULL,
    [CreatedAt] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
    [RevokedAt] [datetime2](7) NULL,
    [ReplacedByTokenId] [uniqueidentifier] NULL,
    CONSTRAINT [FK_RefreshTokens_Users] FOREIGN KEY([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [dbo].[ErrorLogs](
    [Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [LoggedAt] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
    [Operation] [nvarchar](50) NULL,
    [ProcedureName] [nvarchar](255) NULL,
    [Parameters] [nvarchar](max) NULL,
    [Message] [nvarchar](max) NULL,
    [StackTrace] [nvarchar](max) NULL,
    [UserName] [nvarchar](256) NULL,
    [RequestPath] [nvarchar](512) NULL
);

CREATE TABLE [dbo].[UserDepartments](
    [UserId] [int] NULL,
    [DepartmentID] [int] NULL
);

CREATE TABLE [dbo].[UserSubDepartments](
    [UserId] [int] NULL,
    [SubDepartmentId] [int] NULL
);