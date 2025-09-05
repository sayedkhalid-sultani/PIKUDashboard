USE [master]
GO
/****** Object:  Database [PIKUDashboard]    Script Date: 8/31/2025 3:47:03 PM ******/
CREATE DATABASE [PIKUDashboard]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MinimalWEBAPI', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\PIKUDashboard.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MinimalWEBAPI_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\PIKUDashboard_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [PIKUDashboard] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PIKUDashboard].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PIKUDashboard] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PIKUDashboard] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PIKUDashboard] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PIKUDashboard] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PIKUDashboard] SET ARITHABORT OFF 
GO
ALTER DATABASE [PIKUDashboard] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PIKUDashboard] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PIKUDashboard] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PIKUDashboard] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PIKUDashboard] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PIKUDashboard] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PIKUDashboard] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PIKUDashboard] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PIKUDashboard] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PIKUDashboard] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PIKUDashboard] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PIKUDashboard] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PIKUDashboard] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PIKUDashboard] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PIKUDashboard] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PIKUDashboard] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PIKUDashboard] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PIKUDashboard] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PIKUDashboard] SET  MULTI_USER 
GO
ALTER DATABASE [PIKUDashboard] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PIKUDashboard] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PIKUDashboard] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PIKUDashboard] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PIKUDashboard] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PIKUDashboard] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [PIKUDashboard] SET QUERY_STORE = ON
GO
ALTER DATABASE [PIKUDashboard] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [PIKUDashboard]
GO
/****** Object:  User [sultani]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE USER [sultani] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [sultani]
GO
/****** Object:  UserDefinedTableType [dbo].[IndicatorTableType]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE TYPE [dbo].[IndicatorTableType] AS TABLE(
	[Name] [nvarchar](200) NOT NULL,
	[DepartmentId] [int] NOT NULL,
	[Value] [decimal](18, 2) NOT NULL,
	[EffectiveDate] [date] NOT NULL,
	[CreatedBy] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[IntList]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE TYPE [dbo].[IntList] AS TABLE(
	[Id] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[Calendars]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendars](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[MonthName] [nvarchar](20) NOT NULL,
	[Quarter] [int] NOT NULL,
	[Day] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[Description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChartConfigs]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChartConfigs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
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
	[CalculateGrowthBy] [nvarchar](50) NOT NULL,
	[CalculateTotalBy] [nvarchar](50) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserId] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[DeletedByUserId] [int] NULL,
	[DeletedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataValues]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataValues](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IndicatorId] [int] NOT NULL,
	[Value] [float] NOT NULL,
	[CalendarId] [int] NULL,
	[LocationId] [int] NULL,
	[PeriodType] [nvarchar](50) NOT NULL,
	[LocationType] [nvarchar](50) NOT NULL,
	[Growth] [float] NULL,
	[Total] [float] NULL,
	[DateAdded] [datetime] NOT NULL,
	[CreatedByUserId] [int] NULL,
	[UpdatedByUserId] [int] NULL,
	[UpdatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataValuesAudit]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataValuesAudit](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataValueId] [int] NOT NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[DeletedByUserId] [int] NULL,
	[DeletedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ParentID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLogs](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[LoggedAt] [datetime2](7) NOT NULL,
	[Operation] [nvarchar](50) NULL,
	[ProcedureName] [nvarchar](255) NULL,
	[Parameters] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[StackTrace] [nvarchar](max) NULL,
	[UserName] [nvarchar](256) NULL,
	[RequestPath] [nvarchar](512) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndicatorChartTypes]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndicatorChartTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ChartType] [nvarchar](50) NOT NULL,
	[IndicatorId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Indicators]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Indicators](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ParentId] [int] NULL,
	[OrderIndex] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[Color] [nvarchar](10) NULL,
	[UniteId] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserId] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserId] [int] NULL,
	[DeletedByUserId] [int] NULL,
	[DeletedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Type] [nvarchar](50) NULL,
	[ParentId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RefreshTokens]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RefreshTokens](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[TokenHash] [nvarchar](256) NOT NULL,
	[JwtId] [uniqueidentifier] NOT NULL,
	[ExpiresAt] [datetime2](7) NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[RevokedAt] [datetime2](7) NULL,
	[ReplacedByTokenId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Unites]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Unites](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserDepartments]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserDepartments](
	[UserId] [int] NULL,
	[DepartmentID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](100) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[Role] [nvarchar](20) NOT NULL,
	[Departments] [int] NULL,
 CONSTRAINT [PK__Users__3214EC077457E1D1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserSubDepartments]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSubDepartments](
	[UserId] [int] NULL,
	[SubDepartmentId] [int] NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Calendars] ON 
GO
INSERT [dbo].[Calendars] ([Id], [CalendarDate], [Year], [Month], [MonthName], [Quarter], [Day], [Week], [IsWeekend], [Description]) VALUES (1, CAST(N'2020-01-01' AS Date), 2020, 1, N'January', 1, 1, 1, 0, N'Year 2020')
GO
INSERT [dbo].[Calendars] ([Id], [CalendarDate], [Year], [Month], [MonthName], [Quarter], [Day], [Week], [IsWeekend], [Description]) VALUES (2, CAST(N'2021-01-01' AS Date), 2021, 1, N'January', 1, 1, 1, 0, N'Year 2021')
GO
INSERT [dbo].[Calendars] ([Id], [CalendarDate], [Year], [Month], [MonthName], [Quarter], [Day], [Week], [IsWeekend], [Description]) VALUES (3, CAST(N'2022-01-01' AS Date), 2022, 1, N'January', 1, 1, 1, 0, N'Year 2022')
GO
INSERT [dbo].[Calendars] ([Id], [CalendarDate], [Year], [Month], [MonthName], [Quarter], [Day], [Week], [IsWeekend], [Description]) VALUES (4, CAST(N'2025-08-01' AS Date), 2025, 8, N'August', 3, 1, 1, 0, N'Marital Status Data')
GO
SET IDENTITY_INSERT [dbo].[Calendars] OFF
GO
SET IDENTITY_INSERT [dbo].[ChartConfigs] ON 
GO
INSERT [dbo].[ChartConfigs] ([Id], [IndicatorId], [DepartmentId], [ChartType], [Title], [Subtitle], [Description], [MaxXAxisValue], [MaxYAxisValue], [GroupBy], [ChartConfigJson], [CalculateGrowthBy], [CalculateTotalBy], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (1, 1, 4, N'bar', N'Trade Data', N'Exports, Imports, and Trade Deficit', N'Annual trade data', NULL, NULL, NULL, NULL, N'indicator', N'indicator', CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[ChartConfigs] ([Id], [IndicatorId], [DepartmentId], [ChartType], [Title], [Subtitle], [Description], [MaxXAxisValue], [MaxYAxisValue], [GroupBy], [ChartConfigJson], [CalculateGrowthBy], [CalculateTotalBy], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (2, 2, 4, N'pie', N'Marital Status Distribution', N'Distribution of marital status types in population', N'Chart showing percentage distribution of different marital status types', NULL, NULL, NULL, NULL, N'indicator', N'indicator', CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[ChartConfigs] OFF
GO
SET IDENTITY_INSERT [dbo].[DataValues] ON 
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (1, 7, 0.8, 1, 1, N'Yearly', N'National', 0, 5.33, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (2, 8, 0.9, 2, 1, N'Yearly', N'National', 0, 6.87, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (3, 9, 1.8, 3, 1, N'Yearly', N'National', 0, 11.25, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (4, 10, 6.5, 1, 1, N'Yearly', N'National', 712.5, 43.33, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (5, 11, 5.3, 2, 1, N'Yearly', N'National', 488.89, 40.46, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (6, 12, 6.5, 3, 1, N'Yearly', N'National', 261.11, 40.63, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (7, 13, -5.7, 1, 1, N'Yearly', N'National', -187.69, 38, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (8, 14, -4.4, 2, 1, N'Yearly', N'National', -183.02, 33.59, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (9, 15, -4.7, 3, 1, N'Yearly', N'National', -172.31, 29.38, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (10, 16, 2, 1, 1, N'Yearly', N'National', -135.09, 13.33, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (11, 17, 2.5, 2, 1, N'Yearly', N'National', -156.82, 19.08, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (12, 18, 3, 3, 1, N'Yearly', N'National', -163.83, 18.75, CAST(N'2025-08-31T15:23:54.897' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (13, 25, 15, 4, 1, N'Yearly', N'National', 0, 29.82, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (14, 26, 10.5, 4, 1, N'Yearly', N'National', 0, 21.13, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (15, 27, 3.2, 4, 1, N'Yearly', N'National', -78.67, 6.36, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (16, 28, 5, 4, 1, N'Yearly', N'National', -52.38, 10.06, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (17, 29, 1.5, 4, 1, N'Yearly', N'National', -53.13, 2.98, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (18, 30, 2.2, 4, 1, N'Yearly', N'National', -56, 4.43, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (19, 31, 22, 4, 1, N'Yearly', N'National', 1366.67, 43.74, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (20, 32, 23.3, 4, 1, N'Yearly', N'National', 959.09, 46.88, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (21, 33, 6.1, 4, 1, N'Yearly', N'National', -72.27, 12.13, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (22, 34, 6, 4, 1, N'Yearly', N'National', -74.25, 12.07, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (23, 35, 2.5, 4, 1, N'Yearly', N'National', -59.02, 4.97, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[DataValues] ([Id], [IndicatorId], [Value], [CalendarId], [LocationId], [PeriodType], [LocationType], [Growth], [Total], [DateAdded], [CreatedByUserId], [UpdatedByUserId], [UpdatedAt]) VALUES (24, 36, 2.7, 4, 1, N'Yearly', N'National', -55, 5.43, CAST(N'2025-08-31T15:23:55.000' AS DateTime), 5, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[DataValues] OFF
GO
SET IDENTITY_INSERT [dbo].[Departments] ON 
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (1, N'Finance', 4)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (2, N'HR', 4)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (3, N'IT', 4)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (4, N'Operations', NULL)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (5, N'Electronics', NULL)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (6, N'Grocery', 5)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (7, N'Home', 5)
GO
INSERT [dbo].[Departments] ([Id], [Name], [ParentID]) VALUES (8, N'Sports', NULL)
GO
SET IDENTITY_INSERT [dbo].[Departments] OFF
GO
SET IDENTITY_INSERT [dbo].[ErrorLogs] ON 
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (450, CAST(N'2025-08-17T04:14:37.8329535' AS DateTime2), N'QuerySingleAsync', N'GetUserById', N'{"Id":6}', N'Procedure or function ''GetUserById'' expects parameter ''@UserId'', which was not supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure or function ''GetUserById'' expects parameter ''@UserId'', which was not supplied.
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<ExecuteDbDataReaderAsync>b__195_0(Task`1 result)
   at System.Threading.Tasks.ContinuationResultTaskFromResultTask`2.InnerInvoke()
   at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state)
--- End of stack trace from previous location ---
   at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state)
   at System.Threading.Tasks.Task.ExecuteWithThreadLocal(Task& currentTaskSlot, Thread threadPoolThread)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.QueryRowAsync[T](IDbConnection cnn, Row row, Type effectiveType, CommandDefinition command) in /_/Dapper/SqlMapper.Async.cs:line 489
   at GenericMinimalApi.Services.DapperService.QuerySingleAsync[T](String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 69
ClientConnectionId:21ff269d-b21a-46a8-afaf-987849c68168
Error Number:201,State:4,Class:16', N'admin', N'/auth/refresh')
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (451, CAST(N'2025-08-17T04:14:37.8378101' AS DateTime2), N'Global', N'UnhandledException', NULL, N'Procedure or function ''GetUserById'' expects parameter ''@UserId'', which was not supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure or function ''GetUserById'' expects parameter ''@UserId'', which was not supplied.
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<ExecuteDbDataReaderAsync>b__195_0(Task`1 result)
   at System.Threading.Tasks.ContinuationResultTaskFromResultTask`2.InnerInvoke()
   at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state)
--- End of stack trace from previous location ---
   at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state)
   at System.Threading.Tasks.Task.ExecuteWithThreadLocal(Task& currentTaskSlot, Thread threadPoolThread)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.QueryRowAsync[T](IDbConnection cnn, Row row, Type effectiveType, CommandDefinition command) in /_/Dapper/SqlMapper.Async.cs:line 489
   at GenericMinimalApi.Services.DapperService.QuerySingleAsync[T](String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 69
   at GenericMinimalApi.Services.DapperService.QuerySingleAsync[T](String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 74
   at GenericMinimalApi.Extensions.AuthEndpointExtensions.<>c.<<MapAuthEndpoints>b__0_2>d.MoveNext() in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Extensions\AuthEndpointExtensions.cs:line 126
--- End of stack trace from previous location ---
   at Microsoft.AspNetCore.Http.RequestDelegateFactory.<TaskOfTToValueTaskOfObject>g__ExecuteAwaited|91_0[T](Task`1 task)
   at GenericMinimalApi.Filters.ValidationFilter`1.InvokeAsync(EndpointFilterInvocationContext ctx, EndpointFilterDelegate next) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Filters\ValidationFilter.cs:line 38
   at Microsoft.AspNetCore.Http.RequestDelegateFactory.<ExecuteValueTaskOfObject>g__ExecuteAwaited|128_0(ValueTask`1 valueTask, HttpContext httpContext, JsonTypeInfo`1 jsonTypeInfo)
   at Microsoft.AspNetCore.Http.RequestDelegateFactory.<>c__DisplayClass101_2.<<HandleRequestBodyAndCompileRequestDelegateForJson>b__2>d.MoveNext()
--- End of stack trace from previous location ---
   at GenericMinimalApi.Middleware.GlobalExceptionMiddleware.InvokeAsync(HttpContext context, IErrorLogger errorLogger) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Middleware\GlobalExceptionMiddleware.cs:line 24
ClientConnectionId:21ff269d-b21a-46a8-afaf-987849c68168
Error Number:201,State:4,Class:16', N'admin', N'/auth/refresh')
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (452, CAST(N'2025-08-17T04:17:02.3888331' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:e82ae4cc-0973-4fc3-9a32-4f80eb9f0334
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (453, CAST(N'2025-08-17T04:17:11.9958252' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-10T04:17:11.9968458Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:e82ae4cc-0973-4fc3-9a32-4f80eb9f0334
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (454, CAST(N'2025-08-17T10:49:05.0102473' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:5808a16e-ba67-4954-af42-283f18cea7a5
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (455, CAST(N'2025-08-17T10:49:14.5130583' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-10T10:49:14.5133767Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:5808a16e-ba67-4954-af42-283f18cea7a5
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (456, CAST(N'2025-08-19T03:24:48.8934999' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:ff0ce048-e52c-4184-a0b0-dba24f141dac
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (457, CAST(N'2025-08-19T03:24:57.1261061' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-12T03:24:57.1124704Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:ff0ce048-e52c-4184-a0b0-dba24f141dac
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (458, CAST(N'2025-08-19T04:58:53.8436278' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:0db82d45-32e0-4877-adc5-4053512dc4cd
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (459, CAST(N'2025-08-19T04:59:03.4548531' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-12T04:59:03.4369479Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:0db82d45-32e0-4877-adc5-4053512dc4cd
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (460, CAST(N'2025-08-19T09:01:02.3356287' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:fc4abec5-4a49-45cc-abe6-c894ce7d01b1
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (461, CAST(N'2025-08-19T09:01:11.7034754' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-12T09:01:11.6632086Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:fc4abec5-4a49-45cc-abe6-c894ce7d01b1
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (462, CAST(N'2025-08-19T10:15:35.7254092' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeExpiredRefreshTokens', N'{"OutputMessage":null}', N'Could not find stored procedure ''PurgeExpiredRefreshTokens''.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Could not find stored procedure ''PurgeExpiredRefreshTokens''.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:9426a03d-6eb9-465b-8c81-d81bfe0a85d9
Error Number:2812,State:62,Class:16', NULL, NULL)
GO
INSERT [dbo].[ErrorLogs] ([Id], [LoggedAt], [Operation], [ProcedureName], [Parameters], [Message], [StackTrace], [UserName], [RequestPath]) VALUES (463, CAST(N'2025-08-19T10:15:45.3032989' AS DateTime2), N'ExecuteWithOutputAsync', N'PurgeOldErrorLogs', N'{"OutputMessage":null,"CutoffUtc":"2025-08-12T10:15:45.3010085Z"}', N'Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.', N'Microsoft.Data.SqlClient.SqlException (0x80131904): Procedure PurgeOldErrorLogs has no parameters and arguments were supplied.
   at Microsoft.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, SqlCommand command, Boolean callerHasConnectionLock, Boolean asyncClose)
   at Microsoft.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at Microsoft.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at Microsoft.Data.SqlClient.SqlCommand.CompleteAsyncExecuteReader(Boolean isInternal, Boolean forDescribeParameterEncryption)
   at Microsoft.Data.SqlClient.SqlCommand.InternalEndExecuteNonQuery(IAsyncResult asyncResult, Boolean isInternal, String endMethod)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryInternal(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.EndExecuteNonQueryAsync(IAsyncResult asyncResult)
   at Microsoft.Data.SqlClient.SqlCommand.<>c.<InternalExecuteNonQueryAsync>b__193_1(IAsyncResult asyncResult)
   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)
--- End of stack trace from previous location ---
   at Dapper.SqlMapper.ExecuteImplAsync(IDbConnection cnn, CommandDefinition command, Object param) in /_/Dapper/SqlMapper.Async.cs:line 662
   at GenericMinimalApi.Services.DapperService.ExecuteWithOutputAsync(String procedure, Object param, IUnitOfWork uow, Nullable`1 userId) in C:\ReposatoryAsp.netCore\V2\Backend\GenericMinimalApi\Services\DapperService.cs:line 91
ClientConnectionId:9426a03d-6eb9-465b-8c81-d81bfe0a85d9
Error Number:8146,State:2,Class:16', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[ErrorLogs] OFF
GO
SET IDENTITY_INSERT [dbo].[IndicatorChartTypes] ON 
GO
INSERT [dbo].[IndicatorChartTypes] ([Id], [ChartType], [IndicatorId]) VALUES (1, N'line', 6)
GO
SET IDENTITY_INSERT [dbo].[IndicatorChartTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[Indicators] ON 
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (1, N'Trade Data', NULL, 1, 0, NULL, 1, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (2, N'Marital Status', NULL, 2, 0, NULL, 2, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (3, N'Exports', 1, 1, 1, NULL, 1, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (4, N'Imports', 1, 2, 1, NULL, 1, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (5, N'Trade Deficit', 1, 3, 1, NULL, 1, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (6, N'Target', 1, 4, 1, NULL, 1, CAST(N'2025-08-31T15:23:54.883' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (7, N'2020', 3, 1, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (8, N'2021', 3, 2, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (9, N'2022', 3, 3, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (10, N'2020', 4, 1, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (11, N'2021', 4, 2, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (12, N'2022', 4, 3, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (13, N'2020', 5, 1, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (14, N'2021', 5, 2, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (15, N'2022', 5, 3, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (16, N'2020', 6, 1, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (17, N'2021', 6, 2, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (18, N'2022', 6, 3, 2, NULL, 1, CAST(N'2025-08-31T15:23:54.887' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (19, N'Single', 2, 1, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (20, N'Divorced', 2, 2, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (21, N'Widowed', 2, 3, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (22, N'Married', 2, 4, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (23, N'Married - Spouse Abroad', 2, 5, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (24, N'Small Family', 2, 6, 1, NULL, 2, CAST(N'2025-08-31T15:23:54.987' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (25, N'Male', 19, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (26, N'Female', 19, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (27, N'Male', 20, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (28, N'Female', 20, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (29, N'Male', 21, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (30, N'Female', 21, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (31, N'Male', 22, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (32, N'Female', 22, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (33, N'Male', 23, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (34, N'Female', 23, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (35, N'Male', 24, 1, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Indicators] ([Id], [Name], [ParentId], [OrderIndex], [Level], [Color], [UniteId], [CreatedAt], [CreatedByUserId], [UpdatedAt], [UpdatedByUserId], [DeletedByUserId], [DeletedAt]) VALUES (36, N'Female', 24, 2, 2, NULL, 2, CAST(N'2025-08-31T15:23:54.990' AS DateTime), 5, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Indicators] OFF
GO
SET IDENTITY_INSERT [dbo].[Locations] ON 
GO
INSERT [dbo].[Locations] ([Id], [Name], [Type], [ParentId]) VALUES (1, N'Afghanistan', N'National', NULL)
GO
SET IDENTITY_INSERT [dbo].[Locations] OFF
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'06d6cf9f-2cbe-4f61-8444-0124fb46d76c', 6, N'Nb790eRMPolh6eWJyG4fX4l7tkds9DvIF4b1GiVithE=', N'a418023f-426f-4a0e-8058-820e8f44d85c', CAST(N'2025-08-10T11:05:13.6600000' AS DateTime2), CAST(N'2025-08-03T11:05:13.6619507' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e0bdff5e-4ff9-4669-8bb4-012d52123d4d', 6, N'ksFek2yixsRgC7UuQQUzrKgBYDgBEHJJZfzOvU2dN/w=', N'03bf5a63-b166-45c0-b1b3-8f81ac903945', CAST(N'2025-08-10T11:18:08.5833333' AS DateTime2), CAST(N'2025-08-03T11:18:08.5767958' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'75350418-84ec-44a3-8a11-0294ce2eec72', 6, N'GO8enIzTvg1/XJVxnvMeKUWHa+sXRA5t+aUHYuI4CMI=', N'f3560a2e-0b2d-4608-9889-b8a93308e941', CAST(N'2025-08-13T03:34:55.3900000' AS DateTime2), CAST(N'2025-08-06T03:34:55.3854257' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b8809505-b9c1-4553-a859-02c337329fc9', 6, N'JjKYv9D8jXtm9dV/47MmwNdQSpE/tc1lPCg6VUDImxU=', N'dddaf355-a716-47ea-9e80-f4ec57df42a5', CAST(N'2025-08-13T04:05:16.5133333' AS DateTime2), CAST(N'2025-08-06T04:05:16.5007898' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0a17c783-5dca-418b-82f4-0354048f2acd', 6, N'Nfz1kLymWs2VSDU7i9XUjvkkTT5Bh+ALYCAOFoWj/Jk=', N'a16c2d28-567a-4def-beb6-7f4b2d4eee61', CAST(N'2025-08-26T04:08:53.8366667' AS DateTime2), CAST(N'2025-08-19T04:08:53.8419614' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7ca8ba6f-e986-469e-9aae-03ce5b4114ee', 6, N'qWZ8Oy6War054gWPC29O04L2x782RwT/NbPPngritFk=', N'61c469c7-3216-463e-96ea-2138c827b9cd', CAST(N'2025-08-19T10:19:12.3800000' AS DateTime2), CAST(N'2025-08-12T10:19:12.3813445' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b10e4441-fb72-4984-82a7-047a7a0ad3f2', 6, N'k58RM4k/obZ6NuNNhZmHJVP6AJiNW1OPZ0CxuvZY40Y=', N'd1de9562-b7ba-4c01-b41f-f98ca08b3807', CAST(N'2025-08-18T06:09:13.7766667' AS DateTime2), CAST(N'2025-08-11T06:09:13.7834929' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ca67d7fd-b379-4a91-b75e-04ff0176ac1c', 6, N'eDDdgc3dtevMN3dJv/bmaj/y9GUfu5+r6u0FdTRkXkk=', N'9a5e1cd3-b4da-4037-8464-1e99ec274e44', CAST(N'2025-08-11T07:49:16.3233333' AS DateTime2), CAST(N'2025-08-04T07:49:16.3261492' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7187fd4d-ca96-497b-9a2e-066cc0e59690', 5, N'1hpnuA/TGc4TtpbrWvlXGgMgNe+pJsujj4tUc8/hlX4=', N'5307c168-8629-4ac5-8676-c26e7fe2f553', CAST(N'2025-08-10T03:27:49.0133333' AS DateTime2), CAST(N'2025-08-03T03:27:49.0272491' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a5e22c2d-be4d-4943-835a-070748c0b694', 6, N'oiNzLZ/r7LiCf8AWwiF3Fl8bhUrW2iuQyJoQaadw9m8=', N'03df36f0-a87f-4e02-bd14-060540f3acc5', CAST(N'2025-08-13T09:14:00.5133333' AS DateTime2), CAST(N'2025-08-06T09:14:00.5184126' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6c419f0c-775f-4055-9609-070e6c72d2bd', 6, N'moJCHOPQbdFYxbhNg3eBNBiEpWUl7PgAoK+NnQB95ZI=', N'94feebac-4ddd-416b-b329-19e715232a1e', CAST(N'2025-08-10T11:27:29.7533333' AS DateTime2), CAST(N'2025-08-03T11:27:29.7522808' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'abb0887d-6506-4544-b380-076f93e50c6d', 6, N'VPPyVGyDOxD0JgN9habe85Y55CoE4tRwCKZE1xEBIb8=', N'5399b675-83d3-4a09-97ec-f16334d24441', CAST(N'2025-08-18T03:27:30.5533333' AS DateTime2), CAST(N'2025-08-11T03:27:30.5610831' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'14d4a469-2e25-4fd2-827a-096065da15d6', 6, N'H3iUWCADm/quBRQYJ6/OMCkLL10d2RPcaK4mi+4gwpk=', N'44bd1325-6d9d-480d-9495-78a95a778f3e', CAST(N'2025-08-11T09:00:50.7433333' AS DateTime2), CAST(N'2025-08-04T09:00:50.7455418' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ce98b8a9-4e06-473c-899f-0ae63ed26ddd', 6, N'7WANGtgmlSjykd+CS4YiuBu+YvekWDwhwbPrmwGBdMA=', N'ea63c087-8c76-4541-8808-269be7c568a6', CAST(N'2025-08-11T10:51:28.9833333' AS DateTime2), CAST(N'2025-08-04T10:51:28.9887663' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd58941c8-ccea-419a-a9b0-0c349bbab308', 6, N'v12KyJjXCc1Hx2X1b0Gjxl9mdnTPitwrErrzG8/ExmI=', N'b566a622-41e9-43ba-9760-99a6061ff012', CAST(N'2025-08-13T04:28:51.9000000' AS DateTime2), CAST(N'2025-08-06T04:28:51.9046448' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'405689f9-3fcf-4ef8-b2c0-0dbbc310b54e', 6, N'NHXgx4w04TyAmAwYwvakVLTu1brChp3Ic9nuGLYmZ4c=', N'd89983f9-bfc7-401e-8c1d-dc7ec62bfa1e', CAST(N'2025-08-14T04:07:28.8200000' AS DateTime2), CAST(N'2025-08-07T04:07:28.8263338' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'fad5f036-0ad3-4e25-868d-0ef4866a892f', 6, N'fWYWgGCH0qvlh/+jByBHCnIWSv1eYAaJGOcieTa3a1o=', N'b4f26637-dce9-4e6c-b569-5de088f2dd9b', CAST(N'2025-08-13T06:46:54.6700000' AS DateTime2), CAST(N'2025-08-06T06:46:54.6750894' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'50b99d55-931d-43a1-b87c-10ffd4867328', 6, N'tH4q4Of1gQWFXst5OJOdDqupBFQVgHLiPieZmcT3bHY=', N'72fb64e1-1cb1-4eee-be3a-6ed2323ddfd4', CAST(N'2025-08-18T11:29:59.2900000' AS DateTime2), CAST(N'2025-08-11T11:29:59.2910537' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b6ac2105-90e2-4f61-a3df-1124c453753b', 6, N'X/06m5CIv8pr+tN4R+gx1vFwpDvcQ4Em3Z5WqbUFzT8=', N'72836cf8-a2c7-4c12-b4ec-0234e6c3c479', CAST(N'2025-08-18T11:24:05.6566667' AS DateTime2), CAST(N'2025-08-11T11:24:05.6579067' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2dff5954-a91f-4daf-b63e-114d100f4dce', 6, N'QXUWMI2PQ1MeI/4ytEwpec/+y10RIRb5ZIKPlh6lVxs=', N'43dcb7cc-5c4a-4189-b010-8bc3f9370f24', CAST(N'2025-08-24T04:39:23.6866667' AS DateTime2), CAST(N'2025-08-17T04:39:23.6906005' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a1d4777f-adc9-44c2-8863-12738635e312', 6, N'LGBQo62NOpPr1X43z2pQ1tE1GPRKJQX6WmdQSXs912c=', N'fc6f2416-8233-444b-ab06-7a34a86e91b3', CAST(N'2025-08-18T04:46:56.6900000' AS DateTime2), CAST(N'2025-08-11T04:46:56.6899684' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'39258853-06c1-4d2e-bd9d-12e3810a1a07', 6, N'kXYiBGjkiV5dNf8TMJEYIQO57Xgk4CgHqnPdZ/ji98Y=', N'df13929c-1c8d-42eb-a285-472a9a577497', CAST(N'2025-08-26T09:01:19.2866667' AS DateTime2), CAST(N'2025-08-19T09:01:19.2985658' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3f60e0a1-786a-410c-8527-13eae36aa8f9', 6, N'GFm1ohKVC65STlCvyxI8rC1+d5mmRWRrN0ukNM35cw0=', N'18085eb2-901f-443e-9397-575043ae0602', CAST(N'2025-08-20T09:24:23.1900000' AS DateTime2), CAST(N'2025-08-13T09:24:23.1898674' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2c1622f8-fbe5-4766-a9f5-14ef6028eaff', 6, N'mAxrWbea/Ljh4lIOc9V8HWVMELyg0WWc9CrSuLJ46jU=', N'bca71698-19fe-4471-9eb7-4ddd113fba26', CAST(N'2025-08-11T09:06:33.1666667' AS DateTime2), CAST(N'2025-08-04T09:06:33.1581390' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5c3c571a-f139-4e5b-9673-151e7567ab38', 6, N'e/z/sQ4w8zA9Ah8xB++l+xC8kaoOoQjHNPQg8JK11a0=', N'419c61f5-f63e-4eb8-be2d-f4f26d7fb8c1', CAST(N'2025-08-11T09:11:15.3300000' AS DateTime2), CAST(N'2025-08-04T09:11:15.3327638' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7bdfa861-3376-4899-a87b-157cb9a45a12', 6, N'DKdn7OhAueZQvWZwW8V/WOwybTtfap6Riccwhd4eX/8=', N'8e4b698b-ee1c-42c4-8dec-8f1e417ca6de', CAST(N'2025-08-13T07:00:39.9433333' AS DateTime2), CAST(N'2025-08-06T07:00:39.9487149' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd58c4d2c-a262-467f-b2b7-186950cf6005', 6, N'VBviRjBrEBMN692aLIgdQXGmWDGvs256AOEyREd6O1c=', N'ed6d1e9c-499d-4d7c-aa8f-a02d14c5b800', CAST(N'2025-08-19T05:04:18.8433333' AS DateTime2), CAST(N'2025-08-12T05:04:18.8356883' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ceb7a831-97fb-4386-8ced-1a5fec6d5932', 6, N'CbKsGrcCMXPFeIrnJfskPWJJc5Apwm04IOZjBePkncE=', N'5de62379-bf04-412e-8ff7-ae742b9a6dc5', CAST(N'2025-08-13T09:08:05.6800000' AS DateTime2), CAST(N'2025-08-06T09:08:05.6811126' AS DateTime2), CAST(N'2025-08-06T09:08:13.7037688' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3721d50f-d72a-4636-9a88-1ccea49b9409', 6, N'uzzSVYvLuFVB74itRS1TONbAL/ObLHOC8HIPhg9/gO8=', N'6def88b2-d00c-4f37-b908-6843ebd957cc', CAST(N'2025-08-10T11:26:30.5333333' AS DateTime2), CAST(N'2025-08-03T11:26:30.5364642' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'68e0bda6-8aeb-47d3-9910-1dcc21dcb1d3', 6, N'4im7/TUkI8WWucouhGK72gRT1F2HH7aoTzuQh2YshSY=', N'd94d3c8c-f8e0-4990-bc2e-d3aab7a86c63', CAST(N'2025-08-16T02:48:04.1300000' AS DateTime2), CAST(N'2025-08-09T02:48:04.1242603' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c68776de-2a14-4ffb-9c99-1dfb9334d081', 5, N'rLlgg+9hQrKLFRHD0BeLzdUeByy0/3vdwjWu7PzxiA8=', N'0a9d5a25-95f3-4241-93b8-5e867c78845d', CAST(N'2025-08-09T17:47:12.1066667' AS DateTime2), CAST(N'2025-08-02T17:47:12.1395872' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'facfdd08-44a1-4cda-95e7-1e198c0a9ae4', 6, N'wz4xOD/6F+T2SnqjUor5L3ODhENJgN2Lkmys24Xbpqg=', N'a52b225a-73c6-4869-92d1-9e5372f16004', CAST(N'2025-08-18T11:22:15.9900000' AS DateTime2), CAST(N'2025-08-11T11:22:15.9874336' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'532be330-27a7-4c34-906f-1e647b359d69', 6, N'Nt4fHrpzUfVOct09H6gOS6xM2ukAWzxfgzKhtVJOrlk=', N'74f0f0ab-aadd-4d71-8772-b97442bc59bd', CAST(N'2025-08-20T10:35:35.8300000' AS DateTime2), CAST(N'2025-08-13T10:35:35.8319067' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd7f92f2c-3575-4059-9f9c-1ea233b73895', 6, N'wsZ5LvHh7238VQwXV6TKxOWPknTxzwinoCZZTq6NLeg=', N'3e468160-5a9f-4a7a-9312-7c72fbaca99e', CAST(N'2025-08-14T11:19:20.8666667' AS DateTime2), CAST(N'2025-08-07T11:19:20.8710541' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4bfd4bfa-ef28-4cf4-9318-1ea8f374063d', 6, N'Hj8IAAnC9dr/RnjOr0rRDv6I9Wj7wIwqx/SsxviAVZs=', N'47d7e34c-68d0-4de8-a8da-1cc9fe86eb72', CAST(N'2025-08-11T06:48:20.9100000' AS DateTime2), CAST(N'2025-08-04T06:48:20.9131489' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'508dc3d2-8bd3-4683-8f59-1fdac3521adb', 6, N'N1qz+kHgHkQ83ulyMoug2IARs6XYxg1+D6ukHa4W5OU=', N'24984494-76da-4f2b-92bc-646cf9d34ea2', CAST(N'2025-08-18T11:30:28.3900000' AS DateTime2), CAST(N'2025-08-11T11:30:28.3880946' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'05425bf2-3efa-4d1e-91cb-1fe1096032b4', 6, N'nk3X7qRwmhlyUXj3NML+tPf1O9Y4jUCWRtuRTqzzRBw=', N'8450b37e-2814-4e5d-b53e-719cfc12088c', CAST(N'2025-08-13T03:33:57.6266667' AS DateTime2), CAST(N'2025-08-06T03:33:57.6194471' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0997fbb4-8784-4e6d-9fd4-200daf0f14b5', 6, N'h+7EgougvwyL9JScvJiquBe6tnp1PJTajp6Rfk4dLg4=', N'f4453ef1-3438-4592-a95e-606ca78f78e8', CAST(N'2025-08-26T10:32:41.8700000' AS DateTime2), CAST(N'2025-08-19T10:32:41.8772366' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4ab769fc-87d0-49b8-94df-210c07bf9274', 6, N'ypJ0EAl+OvL6lFbovpYoWgU7CbHUYMInijjQzj2JqOo=', N'937588e1-6b18-4165-9b50-fb02362f8e8d', CAST(N'2025-08-11T09:11:03.2866667' AS DateTime2), CAST(N'2025-08-04T09:11:03.2807077' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4e43056a-48d1-41ae-ac52-21c07b52b44f', 6, N'GvA4l4lk0lsjmcgb/p5FRAdefnsqsx7hKsnOi6DtIcw=', N'df9a9ca7-a988-42d5-bce6-c876e3c56bcf', CAST(N'2025-08-11T07:12:15.4700000' AS DateTime2), CAST(N'2025-08-04T07:12:15.4693575' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2ad4e7c3-7b3c-446f-9731-2248a5ec450f', 6, N'rN7I2cu9WstbV0bKzEJ1pNCPHtp6pYMhB4eJESz3X8w=', N'e9aa8674-2561-411c-92a6-3f5a06a44e5b', CAST(N'2025-08-11T06:34:29.8500000' AS DateTime2), CAST(N'2025-08-04T06:34:29.8537625' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'32a35cea-5717-40b7-b536-22ab6d3ee72c', 6, N'9Ddz03HCjXbMe1crW2Z7c/AtUtwYs9ZjcCkMNHIzSjA=', N'2afcbf4c-0465-4719-b222-9c63b73b1411', CAST(N'2025-08-13T04:02:44.6533333' AS DateTime2), CAST(N'2025-08-06T04:02:44.6594542' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'871680b0-8737-477c-b038-238118805b6b', 6, N'+hOcZZ1c+yDGZqbRIdQEDKBug2++9CHhJsGnMKqT9UY=', N'0e19036c-9db4-46ef-a96c-48b21509b54e', CAST(N'2025-08-18T11:29:35.2433333' AS DateTime2), CAST(N'2025-08-11T11:29:35.2464449' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd8f1396a-6921-4dc0-9dce-242349fbdfe9', 6, N'A8JgXQM2EZ3FL4u8gcwVCX6Qd4SFUL+umPMEvH3fntU=', N'3b3a9af4-cb73-489a-b968-30b0a6bc02d2', CAST(N'2025-08-18T04:29:05.1533333' AS DateTime2), CAST(N'2025-08-11T04:29:05.1645445' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bb1a0c44-7140-4a28-a08f-26138263fe39', 6, N'yWNhfpFifgzcgazGjjflR3jwv4OvZW363mX+oxiqm6c=', N'74d92db8-23f7-4087-9400-cc1a4874a4c9', CAST(N'2025-08-16T04:08:36.2633333' AS DateTime2), CAST(N'2025-08-09T04:08:36.2622814' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'be57b49f-4efb-4a94-a330-264abe8b98ba', 6, N'9DjntZn9kGEWoOgXN3F2CB/TYk62Ga9TdOoqKjbf2Jg=', N'7a9609ab-baae-40fb-bc7e-270f692bb574', CAST(N'2025-08-24T04:39:23.6933333' AS DateTime2), CAST(N'2025-08-17T04:39:23.6928235' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'57770e05-9ffc-4cdb-b617-27e0c82961fe', 5, N'gA8TjPMJdU62QnyvsqtepnxvIX7dS/azp+ztNnDeFPU=', N'345152e9-823b-4f59-87e5-cd653d672979', CAST(N'2025-08-10T04:09:55.2533333' AS DateTime2), CAST(N'2025-08-03T04:09:55.2457081' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'09b2949d-664c-44f8-bad4-285725887698', 6, N'OS9cAKeVQFDljqSvYu3Z29wFb/gE+EJVsedFFUNm7+k=', N'fa39d556-e8b2-4a68-b833-ae84868ba22a', CAST(N'2025-08-20T09:25:02.0300000' AS DateTime2), CAST(N'2025-08-13T09:25:02.0288766' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'72694cca-38c9-4b43-86ab-2990e530c70d', 6, N'zUlpEjYoovGYv6RHWO1Cwmo9tDqbR9L5Aj0kSUzlDoM=', N'2e5470bd-902a-4c5f-adf5-21c9bf8ff99b', CAST(N'2025-08-18T11:30:09.3900000' AS DateTime2), CAST(N'2025-08-11T11:30:09.3872271' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'39260e63-13a2-4def-a266-29e1c8359f68', 5, N'JS5foel86k04p199Sa+DqKXncD6ws0z4HM0GlLbvxzg=', N'25a1b06c-a223-4fcf-98d9-57f749f877d2', CAST(N'2025-08-09T17:49:13.7566667' AS DateTime2), CAST(N'2025-08-02T17:49:13.7908975' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'115b9e2b-11ea-4db4-8829-2c083004c5d0', 6, N'jPnm8IO0W8bm/IJqmcxOSUNNzSYsrsi1U5KHhbqAvUk=', N'a8ca714a-46a5-4e0b-babb-253cb26fc846', CAST(N'2025-08-26T04:48:19.0966667' AS DateTime2), CAST(N'2025-08-19T04:48:19.1027027' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9426fcf0-a05a-4a51-96e2-2c0d390e4b94', 6, N'52H9ZrOjQyks3lWIKdhn/nvYuuWeX82wDpL2EqFtoGI=', N'4277157c-b0b5-477b-bd7c-10108afed19b', CAST(N'2025-08-13T07:02:52.4633333' AS DateTime2), CAST(N'2025-08-06T07:02:52.4694996' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7827a0b5-5a97-49c6-8e35-2c2eb23c87a3', 6, N'4+lCKlUVHSyP1lMcZ86TR6nKiajF1B08aOtXquinUxg=', N'67f92d48-e092-4afb-9749-7eeff87658be', CAST(N'2025-08-11T11:33:36.5233333' AS DateTime2), CAST(N'2025-08-04T11:33:36.5194943' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'dec5fc11-af9b-4c91-b8f7-2ca19a624eeb', 6, N'7qvrnpnLjgGB+Q7mMJrXxYu0UnWUNnBCS3BwxAQ07jM=', N'd36be7b1-f9dc-4c4a-ba79-32643ab68a12', CAST(N'2025-08-13T09:37:36.6733333' AS DateTime2), CAST(N'2025-08-06T09:37:36.6763328' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ab60c3d4-b329-42b7-903e-309363b63ef2', 5, N'JcwzpF8ZgL0MyFThGIoA4t4+q+gDX5RtG9orr9aiR4c=', N'068c7f54-ff3a-4811-8dd6-8c2db5c0b433', CAST(N'2025-08-09T17:13:07.3133333' AS DateTime2), CAST(N'2025-08-02T17:13:07.3021543' AS DateTime2), CAST(N'2025-08-02T17:13:22.9911210' AS DateTime2), N'c15ed9d7-47da-4001-a3b4-af33d2fe52ba')
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'579e7ab7-a80f-4c18-91c2-30bb7a93eaec', 6, N'O7G9S9p/ja/lYOGGG7WuAwysWOuuIwKsH1LTS310Qvk=', N'59aa68ec-02fc-4b74-988b-edf1e5fb823d', CAST(N'2025-08-13T09:33:30.3933333' AS DateTime2), CAST(N'2025-08-06T09:33:30.4054465' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4b08c475-4edf-4b4f-8305-30fe3ef41b43', 6, N'ZJ33Nt6T1Nv6onb/F34Dsy8GC3HqV0KsDgQT23/y9Tk=', N'd79d1a31-4608-43c5-a566-a63165313a36', CAST(N'2025-08-13T04:01:12.3166667' AS DateTime2), CAST(N'2025-08-06T04:01:12.3043890' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd1eca449-fecc-47a7-b1dc-3236498fe271', 6, N'pGzAdneoISkrjW72yQXpmlcIZkgRedVbTAcYPPcUuWA=', N'135ba228-1b0e-40be-89ab-b6573c7a8f13', CAST(N'2025-08-10T11:40:10.7033333' AS DateTime2), CAST(N'2025-08-03T11:40:10.7086618' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd0d04b4f-3749-4553-a23a-33955f14742d', 6, N'+h0NpCJQ6YGD/NHEF+nEkp69YxTRsDPFAP0Hv6QH/5o=', N'6306071c-9e3c-4a46-afab-5d93af8a566b', CAST(N'2025-08-18T11:00:09.3766667' AS DateTime2), CAST(N'2025-08-11T11:00:09.3809637' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a5ae7cfb-8272-4106-b57e-350420ecd4bc', 6, N'tONkyzKW6e/PMJ6dI+XIQoPPt6//JnCDIxTeN4sxA6g=', N'd324bdd4-fff1-4e13-bc82-841046a39383', CAST(N'2025-08-13T09:21:11.8033333' AS DateTime2), CAST(N'2025-08-06T09:21:11.8067540' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5d665649-a2a2-49eb-aa79-35534a975d81', 6, N'KrYPtENw3/PNB3TbxIhUqRA5EOAN2WePusjQdrpmKLE=', N'f1b49d9f-753a-4f99-8b98-b74e896d2265', CAST(N'2025-08-16T02:05:17.7600000' AS DateTime2), CAST(N'2025-08-09T02:05:17.7661559' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'49dc63e1-509b-4427-b0cf-3623ab829124', 6, N'KADOcksSU6gH3aLocmxzD3eIHZ/0egDGsgUL+3UXHJc=', N'156f20c7-59a2-4783-9c8d-c0e2ff5260c4', CAST(N'2025-08-19T10:44:11.3533333' AS DateTime2), CAST(N'2025-08-12T10:44:11.3532902' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd0f2c56a-6bc2-4b7a-a269-36dd12e072a8', 6, N'GJ6Tc2orDtfmyuPfUb3UIjfYRzY8SS7eTy+RpN52bhY=', N'04d15600-bd62-4516-8c8f-1a6a6cd4e430', CAST(N'2025-08-26T03:25:03.0966667' AS DateTime2), CAST(N'2025-08-19T03:25:03.1046066' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5a20c28e-5409-4b2f-b7f3-37cc0ee64bf5', 6, N'ZceLQWHbMTl5HLDLTzeap/sUJrELu5hrDs/0xCVfE0o=', N'93454b23-d184-4bf4-bcbd-c169f8cec019', CAST(N'2025-08-11T11:15:15.0900000' AS DateTime2), CAST(N'2025-08-04T11:15:15.0927304' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b52f4734-ec34-4d58-abcc-3b89472c93e0', 6, N'mDzqZuTqT19Cwz2RnVUX8zxWxsdboAgA4tZtfVWXIKM=', N'fd3cef4a-1171-4587-ac0c-a307156aed04', CAST(N'2025-08-14T06:48:31.6966667' AS DateTime2), CAST(N'2025-08-07T06:48:31.7003232' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9e2a686d-fc84-4382-8d11-3bdeb248340d', 6, N'Hlbn+u1pahdrfujm9NPecLUcNJ5f0izb5WWj+r7jVJQ=', N'07e8bfe1-8faf-45bc-8356-c43e39f23331', CAST(N'2025-08-10T11:21:07.0866667' AS DateTime2), CAST(N'2025-08-03T11:21:07.0762335' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e9b3be68-bc0d-4f6d-8a9a-3d45ff967616', 6, N'ptjc8VzC01UYmIOjhJDa9Uiari6L47mPXRwQxUqjZF8=', N'04a01132-7ad8-4881-b75e-b6518e00cfe1', CAST(N'2025-08-11T09:06:38.6433333' AS DateTime2), CAST(N'2025-08-04T09:06:38.6406809' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7b978516-315a-4f60-9bd4-3ecfe4d32382', 6, N'w0Kc9rKcemwuxwnwgEddui1NLC3L6wmQLoD8HaFkzQc=', N'429093f4-3c90-42b2-b20f-75967d1c7d72', CAST(N'2025-08-13T03:48:04.0333333' AS DateTime2), CAST(N'2025-08-06T03:48:04.0395849' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'402b6130-787e-4d5a-bae5-3ee5ce98dfe8', 6, N'Uc7wVXVzLSQTEPbVCrct0rFgSFK/C10mjsBGjUoheLc=', N'6720485b-3ea3-4faf-b501-7bdd7a791dd2', CAST(N'2025-08-19T03:08:28.2866667' AS DateTime2), CAST(N'2025-08-12T03:08:28.2844543' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'f74f3931-2cb7-40db-8dc7-3f2bf2a0a8fd', 6, N'GkGEIzCyFoDjQubmZUxVqac8tkG1MBDuGwdGRKx+8RQ=', N'8561a9ee-5d5b-431e-97ee-f3c69dbdbc8a', CAST(N'2025-08-11T11:40:01.6833333' AS DateTime2), CAST(N'2025-08-04T11:40:01.6865931' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ec99259b-2328-4564-b9a4-3f7599580838', 6, N'GB8wfdCWxfnNF1dNV7MJiM52vgvmeE4yGQ/qa58Xoh0=', N'cef6f36d-ee45-43e5-9338-ea3b8f2d6368', CAST(N'2025-08-14T04:53:54.7266667' AS DateTime2), CAST(N'2025-08-07T04:53:54.7312447' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1b3f56e1-5451-4126-8d26-3f96c2c20d38', 6, N'aoLMO506LNEwN4ABPnFrpziCCYAfNG86DjktX7ccO/M=', N'569c5f1a-df82-420b-b590-f653484b5f30', CAST(N'2025-08-20T11:23:01.2200000' AS DateTime2), CAST(N'2025-08-13T11:23:01.2215151' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b6b824ac-1cb2-41c1-baa4-3fe1f10202ed', 6, N'vuZp21toQxcec1v527itdBjCV5XqMQ5Bi0hqv9ldniE=', N'90e5b808-89f9-430c-af4c-6b075f9ad46c', CAST(N'2025-08-18T07:06:27.4733333' AS DateTime2), CAST(N'2025-08-11T07:06:27.4787059' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7f6078bc-ba0a-4e36-a655-3feee614469a', 6, N'EMHF71kSnIN2+hfko4xW/9gUk13riO5E8iNYEDcj/hU=', N'10095223-70c8-4553-97cd-14d5fbc92f46', CAST(N'2025-08-13T04:01:20.3466667' AS DateTime2), CAST(N'2025-08-06T04:01:20.3355031' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4245d254-c9ec-4529-b68c-40b7f2ab8bba', 6, N'ysWikUcnpUAZ4MNIHu20YKDujPHb4hRFvQryl/vO15A=', N'2ac9c97c-02b6-427e-8415-655d392e1e9a', CAST(N'2025-08-11T06:43:13.9666667' AS DateTime2), CAST(N'2025-08-04T06:43:13.9697528' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3e193cf0-2951-431c-aa74-40e16a769dc9', 6, N'ZZCglm1vdyo4IehqsAeCioiCAlXj2j6Ql9Tfo4SsFxk=', N'76cfef9e-7925-4a93-8d33-042ef65c1851', CAST(N'2025-08-18T11:28:08.6600000' AS DateTime2), CAST(N'2025-08-11T11:28:08.6525144' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd262815e-6a55-4748-a7fd-41a58ef25a7b', 6, N'IQIbXQUuL7Jb50RNN+/2dIqESDiaZYOH8z6cYvvVMLQ=', N'2b90f9a5-dda4-4c46-bbed-446f73b97883', CAST(N'2025-08-13T09:02:06.5933333' AS DateTime2), CAST(N'2025-08-06T09:02:06.5990116' AS DateTime2), CAST(N'2025-08-06T09:02:16.6326897' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd0ddb095-2e06-4199-baf3-42bb93b611ec', 6, N'2g5wRv+6nl2soYhl/2o80GpQ0bghKdHgvtw5c3o1uDE=', N'e1b6b65a-0889-40b9-a784-8264753c483d', CAST(N'2025-08-11T07:43:28.3866667' AS DateTime2), CAST(N'2025-08-04T07:43:28.3780767' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c3cc1c95-61ab-49dc-bced-43e34946a4ca', 6, N'hPQwnq3m3tbsZrqlbyrYhvA71nv/8nwjY6bpfiAJa40=', N'7bb69dc7-d338-4a9c-b0cc-dbccecba94eb', CAST(N'2025-08-11T07:59:59.7733333' AS DateTime2), CAST(N'2025-08-04T07:59:59.7859119' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0a647c82-a7e5-4e91-a3d6-46b55d91946c', 6, N'WxYJ0vMwnXLTxaMrvAaBRKABR8wtW6hPe8pLcM9/Q1Y=', N'5eef653e-98e5-47f1-9ea4-835b58e20a75', CAST(N'2025-08-13T06:48:01.9100000' AS DateTime2), CAST(N'2025-08-06T06:48:01.9151172' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'82e23de7-2630-4b59-b51e-46bed54ed009', 6, N'9QjGkA+MXFZnpzzOmf9MoTkU5XB3OpT7VtFeIyS4rD4=', N'd5cc8649-fee7-475b-8657-2b638856b1ab', CAST(N'2025-08-24T04:39:27.9000000' AS DateTime2), CAST(N'2025-08-17T04:39:27.8951013' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c1228d00-39c3-4725-b201-48085c1b95c3', 6, N'+RgcStY9KtmHa2wldWCzIAHjgvh4D3k6EeF2t7Z2/1w=', N'9a27826a-dcb9-4085-b893-1d8f0c72e017', CAST(N'2025-08-24T04:17:18.2800000' AS DateTime2), CAST(N'2025-08-17T04:17:18.2831721' AS DateTime2), CAST(N'2025-08-17T04:17:43.9677860' AS DateTime2), N'10a00c9d-2f64-4b66-8131-f5e69a8303f9')
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4891f047-48b7-4c2a-8036-48d77ad4b771', 6, N'yuhTQFIgVEsAT4xlKLS53YHmle7/8Ff7FXxptBIpfvI=', N'c660b71d-7728-4f46-bec3-7002409b398f', CAST(N'2025-08-18T09:54:51.7133333' AS DateTime2), CAST(N'2025-08-11T09:54:51.7118886' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'40193c01-cbe5-49a4-a2d7-4a19912afc7d', 6, N'aLvOnj3fX3jWYkO+xN5CSh/AHaWb+JOCDly+VsysgpQ=', N'444aee2f-37d9-4bbf-abdd-ba705b448f21', CAST(N'2025-08-18T11:43:46.5066667' AS DateTime2), CAST(N'2025-08-11T11:43:46.5115225' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3830cef4-fb0c-4a11-95e1-4a7c4f5ecd7b', 6, N'+rCc8pgpGhTYpfNs7ZMjL+3gyHZ+Y+ERx0uDm4sjLgQ=', N'63c2ed8c-ffde-4aa5-b5be-fb1e030c46e9', CAST(N'2025-08-26T04:32:14.3533333' AS DateTime2), CAST(N'2025-08-19T04:32:14.3598044' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3aa673b6-04d9-46c3-9a10-4acdbc840efc', 6, N'6fDz0GGLiTn2mQfVWhMUQ7Xyeoa9CkRkNhnksqLzMz8=', N'c383284b-f209-42d1-9bf1-32ff627dadee', CAST(N'2025-08-26T03:39:40.9766667' AS DateTime2), CAST(N'2025-08-19T03:39:40.9838204' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9ed3f475-14ec-4f76-acd2-4b98feb7fb6b', 6, N'xA8Dee1/SKnMbDdOjtbLQJS/Fk9fRhSldeko/4ER1W4=', N'72213585-4a89-4d57-b60c-0f06b2b0275a', CAST(N'2025-08-20T09:40:45.0600000' AS DateTime2), CAST(N'2025-08-13T09:40:45.0705696' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ad5e5c14-5fd7-4eec-8938-4bb1e81d0b56', 6, N'zQvxhvSjfmXN7H92d1KOTrPt4Ek/xP1GRkE4ISDDhfw=', N'4ad67ad1-3ccd-40b6-825f-53699fa44de0', CAST(N'2025-08-11T07:12:49.1466667' AS DateTime2), CAST(N'2025-08-04T07:12:49.1460506' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'19104d47-af83-4898-90f2-4bd364adf3c5', 6, N'yEtlJMPKoglZ1E+pNwT3NtJ1qO4VMU5YQQ9woCfhOl0=', N'dfe83f33-bcb2-4290-b4a0-5a3e5204f308', CAST(N'2025-08-14T10:01:20.8333333' AS DateTime2), CAST(N'2025-08-07T10:01:20.8373677' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd494827a-96a9-4881-81b1-4bd9e0313b43', 6, N'OqB8/t7E9tYJo28L5pU29vjq7EzDkO7i9jRyei+Ymxo=', N'9f9aff1e-e81c-4cec-9435-dc77facecc84', CAST(N'2025-08-16T04:19:38.0066667' AS DateTime2), CAST(N'2025-08-09T04:19:38.0132394' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7e0bf0f2-ff8b-4437-9cfa-4c54c5cc6513', 6, N'1CVGCmGu7hsQtrLpBHkf8c3QaELaU1oxIGvrVcCCY08=', N'30a9215b-81c2-4233-ba44-592989424c55', CAST(N'2025-08-10T11:04:26.0433333' AS DateTime2), CAST(N'2025-08-03T11:04:26.0517323' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bcb90d2d-87cb-4337-acaa-4dfdd5f7c648', 6, N'6U8lfH/JbgpXDxDSGHd+8+GW03CngBsq7qdcN88l3sI=', N'1a9c4292-d70b-41e1-a982-faf86d8c5794', CAST(N'2025-08-24T16:49:39.3200000' AS DateTime2), CAST(N'2025-08-17T16:49:39.3086798' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bd8f11b7-d416-4cd7-b3ae-4e240ac66d73', 6, N'yFhnjzRtSVOSNawwshtIhQ9D2cZshW/auTFWnPAmIb0=', N'970e3cee-cc78-46c4-95a3-05e1aea4d6d6', CAST(N'2025-08-22T13:36:48.7300000' AS DateTime2), CAST(N'2025-08-15T13:36:48.7291534' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd98d8dc2-2490-46a3-ac28-4ea7a8a02ac4', 6, N'u8JOjiVvfMLd9nScNroZUrgFEhIe0rCL2Q79n7w7Fyo=', N'fcfea6ea-9fec-47fe-8103-957c0d3b1827', CAST(N'2025-08-13T04:12:53.6300000' AS DateTime2), CAST(N'2025-08-06T04:12:53.6231840' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6274ec50-faf7-45a9-835d-4f4387b066fa', 6, N'bMhZP2uzqynNqa8W8et5HWLD0zjE3y/8bCCLDwU/Qjk=', N'5705fecd-32a3-4038-8231-676f6df8e372', CAST(N'2025-08-11T09:20:34.5200000' AS DateTime2), CAST(N'2025-08-04T09:20:34.5269310' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'56354f17-4dd6-4629-a87c-5047a413f717', 6, N'3tfG3J7xmi3upvK/xUmMR8OiKOkuu2Ye5Zb1/Jlk5UQ=', N'fe97a948-0549-4aa8-9146-24c6c5acf4ca', CAST(N'2025-08-20T06:59:48.1266667' AS DateTime2), CAST(N'2025-08-13T06:59:48.1281016' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8a10ec93-09e4-4ed2-bdba-534343d1eedd', 6, N'IzelOc7ZcS7WEgmqEDUzq7mKMK8wQHI2OdpCs+1nzSE=', N'5a653063-ee65-4232-a495-e4b3a22ed9c4', CAST(N'2025-08-16T03:07:45.4133333' AS DateTime2), CAST(N'2025-08-09T03:07:45.4116581' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a32a6017-24b7-4042-a3c0-539b900103f7', 6, N'KTGNcwRZspLYR+AuJ0cOzNEPWSEPHZEJAfZUFwHHbcY=', N'9aa22cf5-cce9-4ef3-9254-5570ba592699', CAST(N'2025-08-13T09:07:53.7066667' AS DateTime2), CAST(N'2025-08-06T09:07:53.7053452' AS DateTime2), CAST(N'2025-08-06T09:07:58.0366411' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'563d094e-c98f-46c1-afd6-55169e85cd87', 6, N'weCbhPr4SVByq5IDW7hg6NCXOJ1D4QAJYXYIhpyuzdM=', N'b91ca343-6dba-4b91-8b04-520e81ac6108', CAST(N'2025-08-11T09:15:44.5966667' AS DateTime2), CAST(N'2025-08-04T09:15:44.5952104' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'95eaf3e3-5c19-4793-b34c-56280832a328', 6, N'E3raAUVjxvFwJEIdIeY1wD4/OLp8ufN9vS8J2T86PVw=', N'0505dd29-7506-42fc-902c-6cff00035a0b', CAST(N'2025-08-16T02:18:51.0266667' AS DateTime2), CAST(N'2025-08-09T02:18:51.0220897' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a71533e5-6430-40ab-8f85-563d085d3b76', 6, N'iODz58Fsu9J9yUxmsm6eprsUomy7t2HFOd+mWy3zycA=', N'ef4a21c6-462d-4c46-ae0b-9c4ed12d5123', CAST(N'2025-08-11T09:14:42.2600000' AS DateTime2), CAST(N'2025-08-04T09:14:42.2642483' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ec84e48b-90e1-47a8-823d-56949b299057', 6, N'jlNet8EqKNMiBIZfaPadDVCTWbY8gv5b6RDBy0uTQa4=', N'92bac8ef-c132-4aff-8f92-c43fa62b6cea', CAST(N'2025-08-13T06:35:48.5700000' AS DateTime2), CAST(N'2025-08-06T06:35:48.5762780' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9178ba1e-ad77-4b83-a6a4-56d2315a6989', 6, N'ZUWhUpgSNW4rldloSu9CdDOFau2WP88VLYWOHNnNgsk=', N'4b9dec30-4e10-4ad7-b7a2-9bf2c115405a', CAST(N'2025-08-24T11:47:24.0900000' AS DateTime2), CAST(N'2025-08-17T11:47:24.0917529' AS DateTime2), CAST(N'2025-08-17T16:49:39.3246011' AS DateTime2), N'bcb90d2d-87cb-4337-acaa-4dfdd5f7c648')
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b98f8791-9545-49e6-9493-57c244f07303', 6, N'XK/0cjQLBkyq4h+ZkUcHwGjBo1gHvBT0aobF6dM92c4=', N'56380356-39e1-4564-94c0-6113d08a2cc3', CAST(N'2025-08-14T06:41:20.9066667' AS DateTime2), CAST(N'2025-08-07T06:41:20.9013421' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5072fa53-7600-4663-bcaf-57cd59a5d204', 6, N'uR4PRVKpNRzQMH4IOIFinrSxTlqLC2qoud6gQsGDNUo=', N'e64ca514-ab07-43b6-893b-9c17b3a15a6a', CAST(N'2025-08-13T09:38:41.4966667' AS DateTime2), CAST(N'2025-08-06T09:38:41.5125848' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8f747b81-f666-4f63-9145-57e8d5176d13', 6, N'Hi5C3ye0FKwiXB9sxKF8uO6dkn/yUiMAy3ZYQ5gwSG0=', N'6c4572b9-6b3c-4163-b4e1-0584f35a56bb', CAST(N'2025-08-19T05:25:36.1600000' AS DateTime2), CAST(N'2025-08-12T05:25:36.1480902' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7d14d3c1-32b5-4a24-9609-58b94b876fc1', 6, N'0lQJF2qoKzFLqxPhPi7e9hLpWYan4I/zhh95Quu1E+w=', N'f5db64ff-fca0-433b-ae17-f8dae81cd0dc', CAST(N'2025-08-14T05:29:07.2466667' AS DateTime2), CAST(N'2025-08-07T05:29:07.2482471' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'35e991de-2256-4f11-ad09-59db9ab67832', 6, N'1DUZICiaPv2koLu3jLA1Spl3A9i98+uLJnePTvPyLJI=', N'bed11f94-d277-49d9-adfc-259eba29c0c2', CAST(N'2025-08-13T07:28:43.6233333' AS DateTime2), CAST(N'2025-08-06T07:28:43.6183935' AS DateTime2), CAST(N'2025-08-06T08:54:55.3178265' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c1cf73cf-32dd-4795-96ac-59dec1cfbe3d', 6, N'xBVQWwjNHG7orqJrfm4t/DgFKu7HyXrGgyEyM7qmlSU=', N'0fcc9105-9d3b-4b8f-aab2-07d08e461ad7', CAST(N'2025-08-13T07:30:16.6800000' AS DateTime2), CAST(N'2025-08-06T07:30:16.6825822' AS DateTime2), CAST(N'2025-08-06T08:54:55.3178265' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e3d17315-9151-4021-a5f3-5afff1fb9478', 6, N'y+agkMBoZamcI8Kh6OHT9Ot07w+a7FRrezJORB4dPMM=', N'dc5c3ad5-0f64-4d05-aa5a-1f5ccae42bb0', CAST(N'2025-08-11T09:18:10.1500000' AS DateTime2), CAST(N'2025-08-04T09:18:10.1520417' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'de4c1dff-6963-4d09-aebb-5b3a21199c43', 6, N'R9FDZA9SJMPGwf97WzOc4YU2EYaGwDBxaXrsYTD8goA=', N'570ab1d9-a341-4bb0-b395-f66dcde52bbf', CAST(N'2025-08-13T04:04:03.6066667' AS DateTime2), CAST(N'2025-08-06T04:04:03.5981419' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd1c9eeca-bf62-43b4-afad-5c297e9ee5cf', 6, N'8MxzUclXe/pUpR2c/TlJDkmOO7dL1YG4EVXEgnMfm/Q=', N'f22ad490-cb3b-43f2-9e7a-6ed1f23e01aa', CAST(N'2025-08-14T11:44:00.5933333' AS DateTime2), CAST(N'2025-08-07T11:44:00.5830320' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0a46d829-ee5f-4ce5-930a-5cf669436667', 6, N'COWFKimnIq7iHTYvoMg8MVgHTQQ9V5NCt+3hoL5M8p4=', N'9d3949a8-c73b-4c9d-b4a4-1f0ac746edea', CAST(N'2025-08-11T08:00:49.4700000' AS DateTime2), CAST(N'2025-08-04T08:00:49.4652710' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8a73b1e5-16ce-44a3-aaeb-5dfc1b5ac803', 6, N'plgcmu+L8A6O6pkhREGuONP8cJq0cezr5rrVdosUwjk=', N'7fa14d1c-a139-4652-86b8-6fa9d70bc97c', CAST(N'2025-08-24T04:39:23.6900000' AS DateTime2), CAST(N'2025-08-17T04:39:23.6906005' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1c00ee40-91fa-47ec-b85a-5e7c5cfa1fc6', 6, N'PvftZtKNUqdfMOFQ6KMH/BJPHxdT5yf5Dc4jqhIn2qU=', N'e76f56fe-ad83-4137-9a94-f98d52dd28df', CAST(N'2025-08-11T06:44:02.3733333' AS DateTime2), CAST(N'2025-08-04T06:44:02.3769133' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'67b934e3-c055-4a5c-88a5-603a600c940e', 6, N'Q8ZHaFyyi1wl4vEszwHiE0LN2kc76YBAAXWAlmpt1lU=', N'474e6fd4-1831-4b6b-9642-84e686dc6ed3', CAST(N'2025-08-26T04:59:04.7733333' AS DateTime2), CAST(N'2025-08-19T04:59:04.7781550' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8c7cb0db-0797-414e-a301-619de5975eb2', 6, N'gu1cIaCVrCsNyor9pVfOYYzGCvOuTCWKnw/RqlHBJpc=', N'7209e1db-2119-4896-9079-d94b1b71f621', CAST(N'2025-08-14T07:15:12.1666667' AS DateTime2), CAST(N'2025-08-07T07:15:12.1628628' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b654ce26-6cb6-4a9f-ad85-620aecbfee88', 6, N'+LHo24EpGQQeneoCRIS3xmCyHOwAStxnwikXpWrqsD8=', N'90cbfb99-ed1d-4a88-a695-5d72f5a05fad', CAST(N'2025-08-13T03:48:29.1566667' AS DateTime2), CAST(N'2025-08-06T03:48:29.1605505' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c3916abd-faf6-495a-bb64-625c73b29c41', 6, N'u5kZFjKXmP3Dn0/W4PNdkpzMxpC06/kQ6p3i64CzhTI=', N'760b2950-05b7-4d5d-b1bf-e72e2dad24bd', CAST(N'2025-08-26T04:57:50.3833333' AS DateTime2), CAST(N'2025-08-19T04:57:50.3842503' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c6e8fd84-d9c0-4fa3-8938-6318383f32a9', 6, N'zv6JmnYUIBnEqQpkebQ3e6PS8IdZ5gIUyuk495mpazE=', N'35df9cd6-be54-4b79-8ba1-982c872215cf', CAST(N'2025-08-11T09:22:37.2700000' AS DateTime2), CAST(N'2025-08-04T09:22:37.2557182' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1cf8b46e-ea3e-4ef0-bc5f-631dbe313887', 6, N'1FIKpPrlvcPHrF05w5hbn7RsAoz8D+LqIhEEcQhwk8w=', N'fe453f9c-2d78-41b0-8db3-36fac8ede58f', CAST(N'2025-08-26T11:00:45.6000000' AS DateTime2), CAST(N'2025-08-19T11:00:45.6027593' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ef2aa021-45d4-482e-a545-6369f164ea6e', 6, N'WH6wubmxQhONyXuopCtufTscXIl3bodTbR8UBrq5x4E=', N'dc5a39d4-6f2b-4324-918e-8d9402904c34', CAST(N'2025-08-13T08:55:10.9666667' AS DateTime2), CAST(N'2025-08-06T08:55:10.9757826' AS DateTime2), CAST(N'2025-08-06T08:56:38.2491768' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c1cc62c4-8ed1-45ee-a48b-63f0b6536800', 6, N'si+hzf4srbWGKTvPgADBsVpUQLOFNk4TMJCxhyZ7E7Y=', N'46b7a041-41cc-4c8e-b11f-a6a29d9927a4', CAST(N'2025-08-19T03:09:37.6566667' AS DateTime2), CAST(N'2025-08-12T03:09:37.6545220' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'45fa6623-5005-4f08-bbe5-64180e227372', 6, N'9m7xWrg1EP6c6rPWB2ZXy74Bk2vAHgQdwz8XmLbh0/Y=', N'ab672506-657e-402e-967c-c26fec18ba4b', CAST(N'2025-08-11T05:56:17.3133333' AS DateTime2), CAST(N'2025-08-04T05:56:17.3144432' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'66fc4645-0c0a-47f8-aed8-647fb2eb19c7', 6, N'AinyW/kM/7s/Fe7MA7qULdi4tc68YoFwT+6QpKhuiCs=', N'ed5f8e82-5672-4e24-8802-ba6e8acd5833', CAST(N'2025-08-12T03:25:25.0300000' AS DateTime2), CAST(N'2025-08-05T03:25:25.0375153' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0f8d0d23-dd11-40f8-bb83-64ca0e99e5ac', 6, N'vZ/2GGwZV3RyqEcuNw9MPsSPbdvDzU1+JHJSmeZBrIM=', N'b97c4276-ccf7-47be-b086-43c87cb57aa4', CAST(N'2025-08-13T08:54:15.3600000' AS DateTime2), CAST(N'2025-08-06T08:54:15.3668898' AS DateTime2), CAST(N'2025-08-06T08:54:55.3178265' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'baa2cf07-5b06-4e45-9ca4-6563037bb53c', 6, N'SkTDdUavkNTmGnzA8mEqx5Tlpp+l5qPvoZXayH1MKE8=', N'b8176d5d-96ad-41a6-adb1-7920a10f4f3d', CAST(N'2025-08-10T11:15:03.9666667' AS DateTime2), CAST(N'2025-08-03T11:15:03.9675268' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'274638f6-c838-408f-8868-660e8cb28c63', 6, N'd1bSHAe3XkpxNQIzdtFFMOutWhKzNetuiAzlehkJN0g=', N'ddc75b6a-2af7-4825-9140-e7402fd5b016', CAST(N'2025-08-13T06:42:17.7766667' AS DateTime2), CAST(N'2025-08-06T06:42:17.7764498' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'892080cd-d368-479a-97bf-661a0d6f05d8', 6, N'CDkM8TSSgPvln3tsFdD4HlUDvDUcyCFizP/yK229SdU=', N'94b05dd2-a0a8-4aa0-9ffc-2bf7bb83c752', CAST(N'2025-08-18T05:11:31.6566667' AS DateTime2), CAST(N'2025-08-11T05:11:31.6612204' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'245752d0-832d-4c19-a7e7-68cd81cc3325', 6, N'jRPZX1X0jAW09LFVbfk1NIsMRdNBKBruuygyQvEXK5g=', N'407ecbc0-f0fe-4a52-892d-1868ffffb31c', CAST(N'2025-08-18T04:58:56.0300000' AS DateTime2), CAST(N'2025-08-11T04:58:56.0274402' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'010e9d75-e455-4e40-8e3e-68e517c6e39f', 6, N'UyGSjQT29FMXH4CPWNaQYobtXykVV5HX6PQ6N37VOxU=', N'9841774a-4ce8-473f-bd3c-12437731a39d', CAST(N'2025-08-19T06:49:10.5566667' AS DateTime2), CAST(N'2025-08-12T06:49:10.5644246' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7afe5f00-dd13-4216-a73b-69531315823f', 6, N'eR9wyXlJscHQDASVZGiYxBYFamfo14YZAyy4fLGDcQE=', N'89a6e4d9-4b4f-4ca7-a883-e184642f3a02', CAST(N'2025-08-11T07:45:42.9066667' AS DateTime2), CAST(N'2025-08-04T07:45:42.8945981' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e635c2c9-ddfe-4e16-849b-6c4112ec5d80', 6, N'j68l/8qhz3zZ0Blp+VLLkaqNSyfpc3pu1S9VCHitdWw=', N'd536cab2-3e11-442b-b3ac-62f629e9e061', CAST(N'2025-08-16T03:06:12.5433333' AS DateTime2), CAST(N'2025-08-09T03:06:12.5474091' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0da85de0-a48c-459b-89ba-6cc413c80764', 5, N'nzDsl56tUq5jUib3FFxsnHiyQMqvo/9FudnY1tsLpMU=', N'738c611f-fac5-4601-ae02-b80fb5a1b90d', CAST(N'2025-08-10T04:01:27.9000000' AS DateTime2), CAST(N'2025-08-03T04:01:27.9088905' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'feffb78e-1957-4137-980e-6ce842b490cb', 6, N'EkAu8zxZcsxiA+MsqsTz8HdAQI+ZhJpbrPHH7+s8qjQ=', N'651f7f6d-508f-410c-a781-166b99c5c0bc', CAST(N'2025-08-19T08:52:47.4766667' AS DateTime2), CAST(N'2025-08-12T08:52:47.4824018' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'84b185bf-40c2-445a-9c7d-6da9133f328c', 6, N'L16WggkMab9L1u1sUaLAPO8iX2rAgfJkeFL/FiQgJFY=', N'569ad38d-89df-49ec-8381-2552eae1e41a', CAST(N'2025-08-20T09:41:14.3000000' AS DateTime2), CAST(N'2025-08-13T09:41:14.2990880' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a2ebb482-5b6e-4850-aab4-6e3861a1edc9', 6, N'u7IQXsvgedy9IFLRJIL0gX2kVMpE26kpDxCPEwskCo4=', N'3570c1c2-7323-4743-ae05-3a441030481d', CAST(N'2025-08-18T04:47:15.0700000' AS DateTime2), CAST(N'2025-08-11T04:47:15.0557651' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9143a3dc-e00b-45ef-a557-6f28c23fab99', 6, N'U44iiyfIJvCWw8SrW9wje9ct2dr/HgczhtdBjdD2vGE=', N'9217961f-e5d4-4f6a-98e7-9a490c217ebc', CAST(N'2025-08-18T11:38:34.5300000' AS DateTime2), CAST(N'2025-08-11T11:38:34.5335788' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8b75dbfe-cafb-4cd9-a598-71bbd9e98c4e', 6, N'pKhOS5WSMW6kg+nNF3BXLHlExI4/HTZp1NfCGvLAB7I=', N'0b9c9d75-aabc-4623-95bf-c03bb60dbd4d', CAST(N'2025-08-17T03:41:33.7500000' AS DateTime2), CAST(N'2025-08-10T03:41:33.7575306' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e4d9d6ce-12c7-46f6-b474-7267cbbddbe0', 5, N'VBw0ib3++hqof6HPGshwLL2xh53sQzRSZHzvsdwFndU=', N'befa0720-552b-4d7c-84d0-71ea7ef668fa', CAST(N'2025-08-19T11:36:32.0333333' AS DateTime2), CAST(N'2025-08-12T11:36:32.0353810' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1edd7a46-95e0-4f83-99ec-72ef0ff63192', 6, N'PUR2P+2HPQObjRd7SlLZwXCO/6lJgoMGX7uLe88kvu0=', N'25d99e16-c473-4b10-9ecd-53d96adf2985', CAST(N'2025-08-13T03:59:29.4066667' AS DateTime2), CAST(N'2025-08-06T03:59:29.4128877' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c17fd055-ff1f-4ae8-821d-75a3efec5d84', 6, N'FkS1BoreFkd/ngKaLxCXlLEh9+9CvYCraOWV7NFh7r8=', N'28c59567-488e-416f-91e1-62cd793d65ee', CAST(N'2025-08-16T03:14:39.6233333' AS DateTime2), CAST(N'2025-08-09T03:14:39.6310062' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a0e4f4f4-89c2-471f-8811-771e00739585', 6, N'wkeoy3KAxeu9opSifpVT+IkzxjtmreCKllJjBO1UvqQ=', N'51445dac-c1b2-45fc-b7bc-fa4924be8e1d', CAST(N'2025-08-20T11:37:14.7533333' AS DateTime2), CAST(N'2025-08-13T11:37:14.7576056' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'46d6ab29-f340-4487-9fe3-77735f0c915c', 6, N'mjU76vaHBj2zpBBQsdguWvAnOrpJ4xudOcv1wzbZYjA=', N'08ce8b5a-d97d-45b4-9921-dc21dd859a5d', CAST(N'2025-08-14T08:57:07.7566667' AS DateTime2), CAST(N'2025-08-07T08:57:07.7600594' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ecbe970a-3694-4274-b9ad-798f00b99f43', 6, N'L1ik8BEOXahy5RWXvehLRbj0tKLVsy38jC9VOhTK5wA=', N'325cac97-0a5a-4a11-ab8a-4b7c575509b5', CAST(N'2025-08-14T06:18:40.7433333' AS DateTime2), CAST(N'2025-08-07T06:18:40.7452991' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'85c7450d-c7d8-4b58-b952-7a6829d8c915', 6, N'WrfaSguui50I1udZ/BabAcX8j9n16clr0G/mtfexFx4=', N'6bf3fe06-9bf7-4e43-8d8c-9dd9f04fdfb0', CAST(N'2025-08-11T09:14:53.2733333' AS DateTime2), CAST(N'2025-08-04T09:14:53.2653629' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'0d885f24-ea80-4cbc-8b9a-7bffaa24d044', 6, N'MSyshDPh7QpULqPExNweRYt7AzDeKGo8LFEB0IeqSXg=', N'428f0835-8f94-4201-909e-4ccc0be3220e', CAST(N'2025-08-10T11:15:53.8300000' AS DateTime2), CAST(N'2025-08-03T11:15:53.8288115' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b5d02523-12af-4087-aaaa-7c2d24b13c05', 6, N'b2gl9uq5VrTv5/W2J1NXsPqIiSm14jJotNMPFQlQI5M=', N'a7cc60f8-26c6-44ed-98f3-961d14ae8643', CAST(N'2025-08-20T06:54:33.9033333' AS DateTime2), CAST(N'2025-08-13T06:54:33.9004636' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4b1964fd-af97-4c23-af8c-7cbe3b981ff3', 6, N'G4mXuP82lp2y4/Ozv5E1kFYC4uhdpG0xLLNYJi6JXDU=', N'ac03e796-3522-4917-9321-014d195549cb', CAST(N'2025-08-13T04:12:37.8833333' AS DateTime2), CAST(N'2025-08-06T04:12:37.8851318' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'95c8f76a-a11b-4bd1-8475-7dac99f8e103', 5, N'tZfGy3Q4p6eea5r5NpB1yoZcQXXr9ddBW/ts/shyi90=', N'5d045c4d-1c5e-48da-9676-77611072dcb1', CAST(N'2025-08-10T07:22:04.0233333' AS DateTime2), CAST(N'2025-08-03T07:22:04.0334323' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2d14abb0-633f-4489-a048-7e6c44e54bee', 6, N'APjcy0/JV2J3CbMIZxLIOFSAuIEDOpS1y0+AADCImQo=', N'f5d4a5f4-1f06-4bef-8711-db14cfc3ac28', CAST(N'2025-08-16T02:02:58.3700000' AS DateTime2), CAST(N'2025-08-09T02:02:58.3778110' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'474955f5-852d-4d8b-9339-7e96caf79f0f', 6, N'H8M/RvuqIHneu0F+zyr7/7i4AaYW6JvkeeoF3dvigcE=', N'f9b69354-57c1-4d9e-83b2-fc968dc4fe69', CAST(N'2025-08-16T10:22:56.6366667' AS DateTime2), CAST(N'2025-08-09T10:22:56.6395146' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'491b1c94-d7ce-44b4-a6db-8063d9c649b6', 5, N'JLBj3xMgmOdTYaErf16t080wIAOZ7mE7p8phGM0CvKc=', N'99c3972e-c1d2-4d5e-9bc8-b6ed8d783297', CAST(N'2025-08-20T03:09:31.5100000' AS DateTime2), CAST(N'2025-08-13T03:09:31.4997737' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e94319b4-886b-426d-9872-8140c9aba63d', 6, N'Ws9uB7bxik/zPRg9NGNbanRkZCurMspXWblr7VonfhY=', N'8b5cae2b-4af9-45e3-b485-f9d213c8eca0', CAST(N'2025-08-17T05:26:28.5333333' AS DateTime2), CAST(N'2025-08-10T05:26:28.5366441' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'23512358-e91c-4b6a-a9f3-814e941fa55c', 6, N'v5hiGwfBlJnLhgGQyUqunpUOvendUzU30hm0lxrksxY=', N'e18ccc31-1613-4cbc-9966-a93866ef76fc', CAST(N'2025-08-14T04:41:06.4366667' AS DateTime2), CAST(N'2025-08-07T04:41:06.4415132' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e9b2f34d-545b-40d7-903c-82029544a1ef', 6, N'2SkZnQeWv08XLqdIGFyug6/9F8SeVpO5tcDJrOOTk2w=', N'05e00fe0-b370-45f4-9cd9-054800bba593', CAST(N'2025-08-18T05:08:45.0366667' AS DateTime2), CAST(N'2025-08-11T05:08:45.0285063' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2ecfff43-d6e0-4591-9d81-83cfb123ab3b', 6, N'd3CYdruOxgJPT5LC7GwMBHuX3pzHLmKUZ3A9+Z5t9S0=', N'13d5d69f-835e-4d91-b250-2a5bd24d6f10', CAST(N'2025-08-10T11:42:31.6500000' AS DateTime2), CAST(N'2025-08-03T11:42:31.6549642' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'219ccfd2-a04a-48c4-bedc-84d8f1b85a48', 6, N'wSg1eqMXCRAnM6qU9q0lgBjUjUJb3Zn/Cs0Oqav5NGc=', N'78691a95-465f-4289-8362-18856acaa8a1', CAST(N'2025-08-11T08:02:34.5866667' AS DateTime2), CAST(N'2025-08-04T08:02:34.5829069' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'67c5c81b-7ffe-42f4-9310-84dc627ec272', 6, N'8OW8J9is12fH+09TV3yZ1+s0CCFw+I+mwWUbh/y+OIw=', N'6cefbb34-33bc-428b-9f35-02e64c4e0190', CAST(N'2025-08-13T07:26:29.6966667' AS DateTime2), CAST(N'2025-08-06T07:26:29.6990300' AS DateTime2), CAST(N'2025-08-06T07:28:34.8589499' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7fac2a27-2373-47a2-8cd6-854d88e1892f', 6, N'B1MPsNJ6/2lzHutGH0NYyez08K/prboLU4ceyiT6QjA=', N'976437cb-d61d-4684-9f59-d31be8841126', CAST(N'2025-08-18T11:40:44.7333333' AS DateTime2), CAST(N'2025-08-11T11:40:44.7298368' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b1dd85e2-963f-4432-9da5-85ecfb6997d6', 6, N'/qmQ9XRJ2a/Aeg3f/KxK0VtzpDuC7Q+rtUfDUNH9aVg=', N'fe540e22-3580-4bd7-82bd-d1019c9c46a2', CAST(N'2025-08-20T07:25:18.8366667' AS DateTime2), CAST(N'2025-08-13T07:25:18.8435355' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'cdf3eff1-1af6-459a-a940-873964f83d7e', 6, N'40/GmMVvGieusF0EBgsag95kaXkVpIhjPw7bAqzR9Is=', N'd81f35e0-ecbe-4a69-b57f-39ebd9755a77', CAST(N'2025-08-11T09:20:29.7033333' AS DateTime2), CAST(N'2025-08-04T09:20:29.7043493' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e07fa67d-5877-40a8-ba48-873a6b1ae251', 6, N'pud6ZcmnbMBHaDsHSM3VtG0HldDJ+mIYpCkwK8btVGM=', N'aef85a86-ac09-4a64-9a90-2904c748deb5', CAST(N'2025-08-13T07:24:14.4700000' AS DateTime2), CAST(N'2025-08-06T07:24:14.4749580' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8cce4c3b-7e0c-435d-b6bc-875991ea461b', 6, N'wet5qJ9NEzqQpncfGa5Q3Eld8e+lxU4YNGlW9lmHiD4=', N'a09e6dfa-de45-4d2c-8150-d799c49148f9', CAST(N'2025-08-13T09:46:03.2566667' AS DateTime2), CAST(N'2025-08-06T09:46:03.2668949' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4eb73213-88cc-4e53-81ba-88b48c073a4c', 6, N'53PVAA6OuoQr/gmRkklTm0uxsQq41Fa4P6xo10JUUQU=', N'ea3fd8aa-082b-495c-b1f2-391714260136', CAST(N'2025-08-13T03:33:38.9233333' AS DateTime2), CAST(N'2025-08-06T03:33:38.9298759' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8b01b31d-a0de-4104-9ab5-89798d7d39c9', 6, N'1xPlxJGOAV0EkOQ8vB9v3+UzlIgOJXCQe0xICIOE/+o=', N'bddeb9b4-ba0c-41b2-ab53-4393940ad875', CAST(N'2025-08-18T15:52:32.3200000' AS DateTime2), CAST(N'2025-08-11T15:52:32.3199345' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd08c8302-50dc-48ed-bd74-8a4dc4896a09', 6, N'cKUYgHGbSVzIZg92VQEhqMbqs6n+mmvIr5M3KUVZD60=', N'0a8021b7-d6fa-4ac4-9166-8e45ed2a75c5', CAST(N'2025-08-11T06:08:45.8866667' AS DateTime2), CAST(N'2025-08-04T06:08:45.8909499' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a044d263-b1e8-4694-8e40-8a8d309fe4b3', 6, N'COjjFhz2kcdBVhppo9HKuYkBVSSnGSNoB1QPiPOaw0k=', N'949b1e7d-7058-4a49-8f09-f62ad60bdf0f', CAST(N'2025-08-11T07:45:30.0733333' AS DateTime2), CAST(N'2025-08-04T07:45:30.0787185' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'fadb2bf7-190f-4d58-b870-8b778a9c5b48', 6, N'YR4sV53Omjx+HXP3+RPWipxZkfeAgvhgTOUfUcVJCHk=', N'8244319d-d12f-497b-9b05-f097874d3db8', CAST(N'2025-08-13T06:51:54.6533333' AS DateTime2), CAST(N'2025-08-06T06:51:54.6593433' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'86a95f3e-dbed-41c8-a6ce-8c1267031596', 6, N'Idpxih73YwNyfnHE+Qv1REUCNO5dv2dLR0MHrDMRaYQ=', N'61705c6c-6ca0-40fb-8b96-1571d3027473', CAST(N'2025-08-16T07:46:32.8766667' AS DateTime2), CAST(N'2025-08-09T07:46:32.8794896' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'993e1085-bf4b-4042-abd9-8c406af86405', 33, N'n3YyyT5D3HVP/odZMosrS+kL3brBWgj+QsgJy2RaRXE=', N'0d589336-59f8-4d18-9d77-8c3a111b7e4f', CAST(N'2025-08-20T03:53:25.3166667' AS DateTime2), CAST(N'2025-08-13T03:53:25.3173150' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'510842e9-7ae5-4b5e-a695-8c8f9e1ac623', 6, N'0D65DRskA2dZFFdRYQhE61T/BBMGJhHP15etfv+FTo0=', N'21950afb-9665-4d09-bd26-91fa72c87d3b', CAST(N'2025-08-12T03:21:32.9366667' AS DateTime2), CAST(N'2025-08-05T03:21:32.9402174' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'90dcec7f-b41d-4196-a4d7-8ce6ef0f40fd', 6, N'lcSaBVfMprx2rQkIdkyy4p3TR7tmRFIISKDbzGnD3CQ=', N'1082ebdb-75ef-47d3-9f62-e98714af3d76', CAST(N'2025-08-19T11:26:13.3533333' AS DateTime2), CAST(N'2025-08-12T11:26:13.3559064' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'fa19c77f-6d5d-4d32-8703-8d0e3030bb8b', 6, N'tOPdhRWvWIYT53mKZf7cihTKYla3Fdp+trY7LNNtSUE=', N'431f260b-6531-48f2-ae75-68982058c18a', CAST(N'2025-08-13T04:12:01.9633333' AS DateTime2), CAST(N'2025-08-06T04:12:01.9663294' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'51be78af-73ce-4503-b9ab-8e01b6b01078', 6, N'wgpjFDNbWxgKkv6hAe8C1MHVIEwcJVUVEr2rkLdFgXo=', N'23cfebdf-ae64-4681-a44a-16220d9c5ce9', CAST(N'2025-08-13T09:13:32.5033333' AS DateTime2), CAST(N'2025-08-06T09:13:32.5037393' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'14586575-1f92-4282-8188-8e1e2589bcae', 6, N'3TfALGRg7q5d8YIz8gf/4ioRmEsX74KrYPmfm9b72XU=', N'cafdf9f1-3ea7-4def-8c82-fb0254428fca', CAST(N'2025-08-16T03:07:33.9633333' AS DateTime2), CAST(N'2025-08-09T03:07:33.9659794' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'550f5b55-d90d-44cd-879a-8e55c443bdeb', 6, N'OMMKJkXxokwYQWSaaP512vfqogSv2RioU/Ua7gaam5A=', N'2d8a696c-d872-4a4f-ad96-7062a8674bac', CAST(N'2025-08-20T03:05:55.2600000' AS DateTime2), CAST(N'2025-08-13T03:05:55.2693228' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6d9dd2c5-2395-47cc-8a8c-8fb3bcad1638', 6, N'WHPALNi5M/c7HUAbLo5en+8h6smRdeLO12/CUKOLrss=', N'f6cd19cd-3dae-4841-8e2c-339b58d64a76', CAST(N'2025-08-23T13:36:59.6900000' AS DateTime2), CAST(N'2025-08-16T13:36:59.6966945' AS DateTime2), CAST(N'2025-08-17T04:39:23.6968239' AS DateTime2), N'be57b49f-4efb-4a94-a330-264abe8b98ba')
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'db8cc662-69e4-46dc-acfb-904e382794b3', 6, N'0VvR4YYX/iIcCpeQPl8gJr7+r8tMrBIMhTUWl0e0qIc=', N'd2016ee1-cade-40eb-8eed-42c31b80270b', CAST(N'2025-08-20T11:03:28.9600000' AS DateTime2), CAST(N'2025-08-13T11:03:28.9533823' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8ee9355e-11bc-4851-98d2-90780c3fbcf9', 6, N'QoJ14Nbt/hsTBAfT73XtJXJ00mZasBvswb8id52xy6Y=', N'a542e330-7e9d-4e0b-97d8-f3d8c8b482c4', CAST(N'2025-08-16T02:58:27.5533333' AS DateTime2), CAST(N'2025-08-09T02:58:27.5572827' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'199983a2-e856-4196-a6d6-90e5d6b01641', 6, N'68Y9SGja5lM1On8zShHsz7NhYEvJVq5AdaRK7i62YH0=', N'ba03083a-aa37-4761-be17-af67374e4049', CAST(N'2025-08-11T10:51:38.0166667' AS DateTime2), CAST(N'2025-08-04T10:51:38.0150750' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7fd5c42e-3774-42be-8b37-91cd5e4df5f4', 6, N'4uYXni/R/1XZJzG5ub2TvSZlQ7tnBoqp3Ke/1kBQ9+8=', N'10bd5dca-af5e-4f10-9763-bba67d5cea73', CAST(N'2025-08-14T10:00:07.9400000' AS DateTime2), CAST(N'2025-08-07T10:00:07.9370327' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8e137b4a-a212-4a0e-b356-92a81d1f4d06', 6, N'5leJO54DwQDhN81oftvbVgQx7eBbuZqnqL8UvUBN6l0=', N'b2f02be0-25a3-4eab-b2aa-f4e67dbee004', CAST(N'2025-08-14T08:46:35.0566667' AS DateTime2), CAST(N'2025-08-07T08:46:35.0570523' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b744dbc4-b188-4506-9b91-93ad686cb451', 6, N'FPfqFS2cyYR82t4EY6AemACVJc0HP7TDPNo/NbhlWqs=', N'b8f99468-9387-499b-91eb-ab9b4a72d864', CAST(N'2025-08-13T09:52:24.7000000' AS DateTime2), CAST(N'2025-08-06T09:52:24.7100208' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9d36e758-e91e-41fd-b9df-954b32b6bf4c', 6, N'8OLeAg/lpeMZDq9c2MQrfJzJGZBCfUh2UnpyLxBoo1U=', N'3a24575d-fbbf-4808-b261-36e7d66172e9', CAST(N'2025-08-13T06:42:07.0800000' AS DateTime2), CAST(N'2025-08-06T06:42:07.0846450' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'597289ab-c672-4d4b-83c2-95502692d87b', 6, N'/dF1OPYx59fct/CtmgxC+gar1A1FWMb4bXbxbnNcM/g=', N'd5e90d8a-0f3f-4d1f-98d0-a4b95db93ac6', CAST(N'2025-08-14T08:36:30.7533333' AS DateTime2), CAST(N'2025-08-07T08:36:30.7561598' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'53bb5f8c-ed06-47c5-8331-95a14a597985', 6, N'wYnPXxYw9VGq+vpR7mLsd6woQdItomXpXjKyAeWa1HM=', N'73c68d6f-d048-445b-8936-8d53cf2333c6', CAST(N'2025-08-18T11:23:26.9033333' AS DateTime2), CAST(N'2025-08-11T11:23:26.9035185' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'99bcd5d6-3b3a-4b19-9eab-95c0e99778e2', 6, N'BUMbBwgIsjhMbzU8OOSh/siDTBP9kHEYdTz6H7wcwpY=', N'd782a6af-a6b1-4a4e-8601-8f345390d62f', CAST(N'2025-08-13T04:00:34.0933333' AS DateTime2), CAST(N'2025-08-06T04:00:34.1049294' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'abcf2c35-d20c-49f1-93e0-968f067c4b1b', 6, N'Zpz/XI+PrbZnlxAETaxrB+zDmX+YCh47vhUza3w5Dk8=', N'2f0a3f80-7bc3-4071-8db4-41947c24c5bf', CAST(N'2025-08-11T06:45:44.3100000' AS DateTime2), CAST(N'2025-08-04T06:45:44.3129352' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c221df91-3055-4ebf-8b5e-969976cfbbc2', 6, N'XL07XdazQRS14RJ7flR9Gvh0pR/mxTjZFdT118CkwAU=', N'27deaac9-5bf0-4ee7-94ff-638a6078d995', CAST(N'2025-08-11T09:19:53.2766667' AS DateTime2), CAST(N'2025-08-04T09:19:53.2688705' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'19782b40-c6b0-4311-a97e-9710ec1ca5c7', 6, N'RVgXIal7CyjE2nrYdWaEFT43Sw+nRZOXi6QdSv/4q10=', N'8266093a-72f7-4bbb-b00c-4fd368582ba4', CAST(N'2025-08-16T10:21:14.1266667' AS DateTime2), CAST(N'2025-08-09T10:21:14.1207433' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5dc13e9a-83a6-4333-a6a2-9752c457b066', 6, N'bzdYQeeyesIzBiVL8TbWBC/Q19jG1HSwFAoZ0EDyos4=', N'60791b62-86f4-4c68-9a55-df30b81feab2', CAST(N'2025-08-10T11:42:57.6166667' AS DateTime2), CAST(N'2025-08-03T11:42:57.6201722' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'abd4be80-2925-4a53-9dc8-979d5e99d155', 6, N'+nwqcpnaWhuHMUvFXMGEeol8yn7G5oCnbdhi8Ykg9QI=', N'f760c31c-6522-449a-93da-68be17867c7a', CAST(N'2025-08-10T08:45:26.4100000' AS DateTime2), CAST(N'2025-08-03T08:45:26.4089600' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'886fb886-cfc9-4a1d-926e-98a3c28431d7', 6, N'8QxSPF9LjGX96ESvfoRsyDHqFsFxA0ehltMQAm/XQLQ=', N'71bca8c6-8525-4fc5-8a17-6f43b648c4a0', CAST(N'2025-08-18T11:42:37.5100000' AS DateTime2), CAST(N'2025-08-11T11:42:37.5126475' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'01e74c52-4b67-4b2f-979e-98d46971ac82', 6, N'aOaHK1ifQ+s+GkhctKRshAvNfgukhpQjjHk8tASkDo4=', N'59ebd369-f811-4c06-83ef-7ca59a19956b', CAST(N'2025-08-13T09:39:01.0366667' AS DateTime2), CAST(N'2025-08-06T09:39:01.0363283' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'074c5423-a2e2-4d27-b8c2-9a51b8ac79f1', 6, N'y7xOnwR3hN/Us8U43VnAksdW9jgGNx69SsHW9kINx50=', N'45c91285-b1be-4fd3-a466-d9d04b0aba63', CAST(N'2025-08-20T09:25:26.9966667' AS DateTime2), CAST(N'2025-08-13T09:25:27.0015627' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bc07a091-35b6-445f-9511-9acb8866a121', 6, N'0WWdh/meV094OtgbNFKCOdVxpRPfzTc2WTpKoLL44FU=', N'6e6ad57a-76b6-43d4-a4b4-16259d082e14', CAST(N'2025-08-11T05:51:43.5833333' AS DateTime2), CAST(N'2025-08-04T05:51:43.5854133' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'af6bfa79-f1ad-402d-8bc9-9cba80276ee4', 5, N'ExUWn6YvpYb/mbS/TGOjdzLi2P43JZMsCc3gakpq+5g=', N'd02d774f-3c7e-40c1-8787-3d9863179105', CAST(N'2025-08-09T17:11:39.0466667' AS DateTime2), CAST(N'2025-08-02T17:11:39.0728434' AS DateTime2), CAST(N'2025-08-02T17:12:18.8378634' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a136f4fe-69ba-4386-8ce2-9dc27523850f', 5, N'Tw/HPivUweiui1qZU6g89ZhOrgNnyFwjelHEfeJedSc=', N'0604651a-523c-4011-9459-fc0b511bf961', CAST(N'2025-08-10T04:08:27.4500000' AS DateTime2), CAST(N'2025-08-03T04:08:27.4601596' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4c379e82-5f19-43c5-a2e9-9e36da84170e', 6, N'3+WLFUOJadpk1qON6ov03z1OOSr82qGP6Hqk5wIiz5U=', N'106ec340-55ca-44b9-bd93-fad2a965b2b6', CAST(N'2025-08-11T07:29:10.1600000' AS DateTime2), CAST(N'2025-08-04T07:29:10.1572585' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd3004a49-9068-4388-bc1d-a0acf0d1f787', 6, N'7IclhJgg2ayxd41FbrW/icvw36Ds7Xskh2dc5j/ID5Q=', N'2ea5ab5d-6e9d-4e21-a1f7-4f23832de89f', CAST(N'2025-08-11T09:18:23.1233333' AS DateTime2), CAST(N'2025-08-04T09:18:23.1359829' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6d0e38cb-9468-4fa6-b706-a0c7f8093701', 6, N'2+v82SaxwD4qA/QXn+ccyfGImYgRNCJcdYEA78Ai+k8=', N'5a17f7ab-3121-4646-8848-a904fed628c1', CAST(N'2025-08-13T04:03:41.5000000' AS DateTime2), CAST(N'2025-08-06T04:03:41.5118365' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'58adac34-09f1-4029-9e42-a3a7b241624f', 6, N'qHuYZcrC8fMy7xTVSM3iPL67SDl+R2v1OQWIV+XjawE=', N'b8edb676-0160-4caf-b5ed-d5d1231717ff', CAST(N'2025-08-11T07:45:38.0266667' AS DateTime2), CAST(N'2025-08-04T07:45:38.0259838' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2aa19c88-ced3-4a3a-b0d4-a3b6befbd87e', 6, N'5zdE+GQfbL5gTaZ6WDAA/U42Uljnmg0BEQLfwuRlkNM=', N'fa139989-6f7f-4dc8-98a1-d9b6cf2adb08', CAST(N'2025-08-11T06:25:34.4533333' AS DateTime2), CAST(N'2025-08-04T06:25:34.4528752' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3f0e2c38-0f8c-4125-8ebd-a43c20a151fa', 6, N'0N3Tp2ncqtyyXR/pwF97w/tX4fQlRmN8qPJ7QKgSjEY=', N'ed37e4bc-3286-4f35-93a9-eab1cab78e5f', CAST(N'2025-08-10T11:30:31.6133333' AS DateTime2), CAST(N'2025-08-03T11:30:31.6189242' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'391a92ab-3f75-4ca4-9182-a484d5cddaae', 6, N'hGFdMuQGszSeuDZdql2JPINvfl8wgAIcZJk/+I4K1gY=', N'b31bdbf1-b4e0-45a6-a6ec-5deec3595fbf', CAST(N'2025-08-26T05:01:23.9133333' AS DateTime2), CAST(N'2025-08-19T05:01:23.9066317' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1af3e28f-c1b2-438c-965a-a50a8092234a', 6, N'o+EgPgcozccr9GO99SngAADzkhtURvdu58lY+IToXr8=', N'57ca7c93-23db-4856-8579-1899dda401e5', CAST(N'2025-08-19T11:25:27.2000000' AS DateTime2), CAST(N'2025-08-12T11:25:27.1959719' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a9a364cb-1219-4d5d-9fb7-a619d1b31382', 6, N'fBCvfU/q1DFEbTsWEivfo/T3rqxkUt2wgnU2LEDlepI=', N'0ccca37f-9583-4164-a68b-34945b09d0cb', CAST(N'2025-08-26T03:26:39.1066667' AS DateTime2), CAST(N'2025-08-19T03:26:39.1077053' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'affd7df5-5b29-4f95-87ec-a65cc60cdaf3', 6, N'4prxXJmEesPstiy85LK6meYHMTwtI7RNS4e4v0R9w5E=', N'465b5c2e-9d24-4c7b-83ef-923e799e8909', CAST(N'2025-08-18T05:03:53.4933333' AS DateTime2), CAST(N'2025-08-11T05:03:53.4884807' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'fd7ed55c-9021-424e-ab0f-a6b233568401', 6, N'kQ8KNsU5LRJnqtWsYBevEhSO13i3qSj5l/R0AMPVSG0=', N'f6f0615e-6dfa-48c0-9667-6e09dcfa25e8', CAST(N'2025-08-13T04:29:11.6466667' AS DateTime2), CAST(N'2025-08-06T04:29:11.6411188' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'67849edc-ce2d-4e86-9fda-a6d86d437a36', 6, N'LHOkKG1wTpN/bmfOZdSSQOrNNSc3oOZQLjCF/uszSjg=', N'717c216b-49eb-45fc-b424-ab09900949aa', CAST(N'2025-08-10T11:27:19.1566667' AS DateTime2), CAST(N'2025-08-03T11:27:19.1670399' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b4564e87-7f1f-4789-a77d-a76d0ad8c156', 6, N'Ltd0sx1zimiVYaQWvmTyFmi7yMkl6c+c9Qa8D+vWieA=', N'b7784170-6a9d-4ddf-874b-e068ce5600f6', CAST(N'2025-08-10T07:35:04.6866667' AS DateTime2), CAST(N'2025-08-03T07:35:04.6876538' AS DateTime2), CAST(N'2025-08-03T07:36:08.9479873' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'f37b267c-9cf1-45c0-94ea-a9dcc467fff1', 6, N'jlq55qmQyVuc0xCTf8NRCfyd7LmMw8koPHSzzOSAQw4=', N'9f521564-9a9d-4991-a884-78a305d2d499', CAST(N'2025-08-18T04:58:38.4600000' AS DateTime2), CAST(N'2025-08-11T04:58:38.4550420' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'14f449e9-9194-4582-ba41-a9ec6bf7455a', 6, N'c/QnlzEh6AdfOd+chtWlmtWhaDDcLS5q0VH6ZzYv/tQ=', N'30727acc-f46e-48a6-9cc6-b6bd66f7777d', CAST(N'2025-08-13T07:28:23.2066667' AS DateTime2), CAST(N'2025-08-06T07:28:23.2004663' AS DateTime2), CAST(N'2025-08-06T07:28:34.8589499' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a53ab3bb-9b15-4d27-9169-ac451fc6a30c', 6, N'Lu+R0QzskPvFy9ouX6gw4lk/Rar0QdHr+9RXEzgw+28=', N'e8c53667-2b33-4aaa-a3a9-3263ee9d3ea8', CAST(N'2025-08-11T06:33:53.9766667' AS DateTime2), CAST(N'2025-08-04T06:33:53.9787482' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'91ac451c-0448-4090-984e-acfb85048907', 6, N'sET3mwr8jN+j9xkiIZdsdFwFbLsje2LGdM2mmGgbctY=', N'9be4165b-4d04-42c8-9afc-ec9d79b48be1', CAST(N'2025-08-11T10:37:54.5266667' AS DateTime2), CAST(N'2025-08-04T10:37:54.5319185' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'adeb8780-402b-4c17-b1f4-ad72900802d0', 6, N'JXA75uhCwMU57Sn8ZEqaE9THQFhqZCFjxEAH2EiDCI4=', N'fa891d65-5a37-4243-a1d6-40ed4df23532', CAST(N'2025-08-13T03:35:05.9933333' AS DateTime2), CAST(N'2025-08-06T03:35:05.9966164' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ede60e33-5ddc-4ee6-bc1f-adf310542a11', 6, N'6WmelHGW+DD5ijp6ued86DVZSMvNJ6UBqdhNWO4QnXA=', N'db9cef61-3685-40c6-a7b9-2602857527e8', CAST(N'2025-08-11T06:55:59.6400000' AS DateTime2), CAST(N'2025-08-04T06:55:59.6425685' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'15c2df23-3fc0-4fba-8102-ae4673fbb6be', 5, N'tay7qPunbfUkKDc5Tu337t4TAV4xue2NQhaQTo0cAHs=', N'c84b086e-31d1-41f1-a0db-a277e9ad980a', CAST(N'2025-08-09T17:45:59.6766667' AS DateTime2), CAST(N'2025-08-02T17:45:59.7058457' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b0efaa7f-f0b1-4bd9-b97e-ae72a35a501e', 6, N'Y2OhRFwek6ihAiooJZdfLgm8JtMYg6gYy8GQumsIspI=', N'3e00b1d6-2154-42a1-9fbd-a40c66aa2905', CAST(N'2025-08-14T09:54:42.6700000' AS DateTime2), CAST(N'2025-08-07T09:54:42.6681687' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bd5a44fd-7e6f-4c1f-aa8c-aebc9e1ffdb1', 6, N't59ZIK2TqbN4x7sDuzaJj90oO/VLAfwJ1skV1wCj2dw=', N'a38861f6-bacd-44eb-b3cd-48fd455c16e2', CAST(N'2025-08-11T10:59:49.3033333' AS DateTime2), CAST(N'2025-08-04T10:59:49.3077539' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c15ed9d7-47da-4001-a3b4-af33d2fe52ba', 5, N'mFkX4SQe2sWCUt6K3AOzCPhL5/dvBDMtc4sTWhWy9rM=', N'9ffbf043-1e35-4871-ad27-c43ae47d0df0', CAST(N'2025-08-09T17:13:22.9800000' AS DateTime2), CAST(N'2025-08-02T17:13:22.9839448' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'89f37c77-e9c6-4b64-be69-b04edd5170a8', 6, N'dTaqrsTtYaP1MpFxVCcriH/BLB7r6/vq2Y0D+BCxZyw=', N'aeda5b2d-cdb2-4b30-a457-0ed92e0c15e3', CAST(N'2025-08-16T03:12:44.5200000' AS DateTime2), CAST(N'2025-08-09T03:12:44.5218688' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'16c62cee-7799-4956-b14f-b0b66a873692', 6, N'5tUYIpKy//6tx8FI3IRTzZoeitiHewRlalh7vs9hagI=', N'f132e3aa-3a03-43b0-b9fb-9271ebba08b5', CAST(N'2025-08-22T12:35:39.5066667' AS DateTime2), CAST(N'2025-08-15T12:35:39.5080499' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'212a15ca-9787-4dcf-9389-b1369a4771bc', 6, N'35xcp6BHIqZwc+ofNiCqU5nU3m+lzOA/OOQVnOYkJr4=', N'7fa1584c-ef2f-4806-9910-cf52702e45e7', CAST(N'2025-08-26T11:08:55.8433333' AS DateTime2), CAST(N'2025-08-19T11:08:55.8432160' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'64a02974-75f7-4984-9fcc-b3975ba8b2ac', 6, N'vQ0rMTdmbfZhvg/k5G5QyuyLS8SIvaowPDl2KgbKBK4=', N'10b7600a-c4b2-4542-9565-3cc90cae8acb', CAST(N'2025-08-10T07:33:38.7366667' AS DateTime2), CAST(N'2025-08-03T07:33:38.7252668' AS DateTime2), CAST(N'2025-08-03T07:36:08.9479873' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c2867138-acce-45b6-b5b2-b3a81ea2ff29', 6, N'FT4W3aWlKuvcC/UnrIb3hZ2l0LWgHPcQw8V2TV2RtYc=', N'1d4566cc-3c33-439b-b2cb-04039253ac93', CAST(N'2025-08-24T10:49:14.1366667' AS DateTime2), CAST(N'2025-08-17T10:49:14.1344926' AS DateTime2), CAST(N'2025-08-17T11:47:24.0985933' AS DateTime2), N'9178ba1e-ad77-4b83-a6a4-56d2315a6989')
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd6a674ea-9d71-46f7-bac9-b4f4c4fac233', 6, N'Zl9ll6qatGqOutS9FtorUslt18hX8Da3ymlDKk9uHbo=', N'b6ab27d5-cd6b-4ddc-b764-081edccb4647', CAST(N'2025-08-11T07:50:26.4500000' AS DateTime2), CAST(N'2025-08-04T07:50:26.4471680' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6c8aa502-b0fc-42c1-97cf-b78f829d0580', 5, N'nqxgOnMkzjWIDs71I1niR8VNeUybIzPUq9swZTuYBR0=', N'8ff70ca2-94e1-43fc-8ab4-cd6842cf931d', CAST(N'2025-08-10T03:21:55.9100000' AS DateTime2), CAST(N'2025-08-03T03:21:55.9189278' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4ae6b924-7b49-4d05-969c-b79249f474b2', 6, N'96CNGGIToPUa4xgkuaYTSBJhg/dXLp6yHxOIZVRFxpI=', N'2b82e2f9-7cfd-496c-96e2-6514dee9edde', CAST(N'2025-08-13T07:16:20.0466667' AS DateTime2), CAST(N'2025-08-06T07:16:20.0521457' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'366f3c93-e395-47b7-b559-b9a1d4f2f585', 6, N'cRL8SS7jwecGPhy8LdZix5MO6E5W64Y+42uL3kSdXuk=', N'1755c328-e915-48c3-91ef-217e1b7e8724', CAST(N'2025-08-16T03:29:25.8033333' AS DateTime2), CAST(N'2025-08-09T03:29:25.8042674' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'407b6dc3-8733-4a31-8cce-ba544ca0f064', 6, N'+r3Cg6PN5u6tCXK5caz5MMNLK7oe5cHOP1wyUR3V/Dw=', N'502db085-5923-47ea-b57e-991aa8beef29', CAST(N'2025-08-16T03:31:34.2800000' AS DateTime2), CAST(N'2025-08-09T03:31:34.2863410' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8ce75f41-7c3e-4d54-9ef7-ba572559e492', 6, N'2cTnqEsBsDgnU8hGF8r5Rv6lC6Jo/iucgRjvuYvosw4=', N'4117b337-1305-49e8-858a-7e915313c1d2', CAST(N'2025-08-11T09:09:03.4400000' AS DateTime2), CAST(N'2025-08-04T09:09:03.4289159' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3ed88fe0-93eb-448f-b012-bb2dfca3484e', 6, N'UYshP3bzF2sPqwMdgVepqRteWp+Cw1Qy+MzdLOcFJpU=', N'c2382355-81fb-459d-a4af-7aeae9109c23', CAST(N'2025-08-16T08:25:45.5666667' AS DateTime2), CAST(N'2025-08-09T08:25:45.5669719' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8a674bc1-2d86-4293-aa21-bcc255ef9759', 6, N'LF0kGWwChZZ8enTCOmOIkNXj9KX4z5t39GILWE22foA=', N'e6ae702e-39ef-4c71-8796-fce443004c58', CAST(N'2025-08-16T10:38:08.6400000' AS DateTime2), CAST(N'2025-08-09T10:38:08.6381781' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e856a9ef-ec75-458b-b605-bdbdce5e0860', 6, N'cT+Qpl6X+642jd1Uk82HGN3ZZcj6lf3DyNeJNk6ocnU=', N'7e64cde9-9c86-4cab-a717-5157a1398434', CAST(N'2025-08-16T02:50:00.1466667' AS DateTime2), CAST(N'2025-08-09T02:50:00.1547951' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'55d6c769-d52f-4bad-93a9-bdc9303d1416', 6, N'a6oQqp93DEec2xjC+A0uTCVWNLHSNZkBqoChnbGWujE=', N'f83f2b99-90a3-4bed-be14-5e63b83dc626', CAST(N'2025-08-14T04:22:28.0466667' AS DateTime2), CAST(N'2025-08-07T04:22:28.0473376' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'70063c38-99b3-4c19-8d56-be0b22de75bd', 6, N'/lYqstIyucEDhLSHwgfQU4B37gL/SWD84hJS6Gw/c24=', N'3d3e422f-f269-4ec1-8b79-51fa99183b16', CAST(N'2025-08-14T08:52:49.4233333' AS DateTime2), CAST(N'2025-08-07T08:52:49.4268382' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b8ac95e9-b9a2-4f59-b8ef-bf3e494282f0', 6, N'UXNkAKTz+R3n2ot7cWzndk1hr5NBAeF96e94p6qt4UU=', N'9ed68525-fa64-4a91-9bf0-067b25f78c3c', CAST(N'2025-08-13T04:03:24.8166667' AS DateTime2), CAST(N'2025-08-06T04:03:24.8115861' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'dea55a55-9c23-44ae-90c2-bff6047630f9', 6, N'MNL2UxPobVQJqhhpEO3H+xK8xPqsBkamR6cPZphqaAU=', N'bc0a2e27-396d-4143-88e3-2907199eeb6b', CAST(N'2025-08-11T11:17:02.8100000' AS DateTime2), CAST(N'2025-08-04T11:17:02.8090860' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'81aadd3d-4e66-46e4-b388-c068312cf7fb', 6, N'TgxMo4LfToh0No2QWiBvONi9XcdM7qccAxH9UO8stQ4=', N'8c679641-9313-40fb-9eb8-1c27064d930c', CAST(N'2025-08-19T03:38:56.9100000' AS DateTime2), CAST(N'2025-08-12T03:38:56.9128014' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a26d06c5-417d-41d5-8d8b-c13f039e75c1', 6, N'cebDIFYmNYgrvCuVLTq0F7dvpo+VdJA10oMOY1c46aM=', N'a34b20ef-de04-4915-a7b7-1ced6f17d04a', CAST(N'2025-08-11T09:09:07.9500000' AS DateTime2), CAST(N'2025-08-04T09:09:07.9523029' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'718c2a1b-248f-4c17-91d3-c1cb72401a42', 6, N'xyPFyC6lLq7sMSg8Rs7aCB0GVMvB/BOeLeQKofzA2uc=', N'5d9ab005-3b55-4501-96b5-d233b4901046', CAST(N'2025-08-14T05:48:01.5600000' AS DateTime2), CAST(N'2025-08-07T05:48:01.5612956' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'29bf430d-1679-4396-8977-c22a6c891f75', 6, N'x2tDs4MX+nTvfAOGpjpFbVsFe5fmn5pWqZdrcsVL1L4=', N'815cc254-9520-47c5-b6e7-28a7d9443f6d', CAST(N'2025-08-10T11:15:34.2766667' AS DateTime2), CAST(N'2025-08-03T11:15:34.2805268' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'00e5282a-71cd-42a1-a4b7-c3b7353c786b', 6, N'43FT+KE2aB1h+dVdLU6JR3Bkj/mR4DTlZZ8R0qETyC8=', N'97020899-3b20-4337-be7f-54945cc1490b', CAST(N'2025-08-22T14:35:38.4500000' AS DateTime2), CAST(N'2025-08-15T14:35:38.4530290' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'68b4a763-4736-4baf-8e51-c4b9252f5a77', 6, N'Q3SOLwUmD+X7Hv+tWc1x6kbd/gXV/U+iU4Cz0UqlYxM=', N'eee5c47c-d552-4010-99b8-ff2d32f83c4b', CAST(N'2025-08-20T11:42:09.4000000' AS DateTime2), CAST(N'2025-08-13T11:42:09.3948942' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'cb604159-9184-4b1a-923e-c4d4eedf52cd', 6, N'N9MUUzez7ZsMo3SRbIZitPPY9IkRnmt/k3T3v9Aq4yE=', N'7aed636c-ffb4-479f-8829-e78971973018', CAST(N'2025-08-11T11:16:36.1566667' AS DateTime2), CAST(N'2025-08-04T11:16:36.1594891' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2ebf0187-cbf7-45a4-9411-c5cb3590f522', 6, N'X0E+lN9l9v9/IHUnECNKBc9/f+uqxkW1y2r+Mp0SW0I=', N'5fb0e42a-1065-4e61-a13b-2652fb1bec51', CAST(N'2025-08-20T09:24:06.5300000' AS DateTime2), CAST(N'2025-08-13T09:24:06.5375478' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd7674df0-38d7-4517-b228-c610543e7a10', 6, N'j/yU7DyYJO04k8Rmkdlf5ScFg9WLqIPAkAh53Q/HCjk=', N'e2959ce4-9a8e-4634-bbb3-a9e871693558', CAST(N'2025-08-26T04:22:31.6566667' AS DateTime2), CAST(N'2025-08-19T04:22:31.6583866' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'de874899-f029-48ee-8eef-c77cca160c61', 6, N'r7BP56Fft/2qSFIOFCZYiCcK71cmXPHOMk/eDcAQ01s=', N'293342fa-71fd-4da2-a54a-52a30fdf5204', CAST(N'2025-08-20T11:35:44.3133333' AS DateTime2), CAST(N'2025-08-13T11:35:44.3166319' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a706d9ce-c9a8-4ee2-9ea4-c8813984ad01', 6, N'DItj7emgtaE/wCj8sf3sDclPoPufFcV7IAdzu6lHdLQ=', N'e39e9ac8-440f-4290-8698-99e53010c302', CAST(N'2025-08-12T03:04:31.4033333' AS DateTime2), CAST(N'2025-08-05T03:04:31.4093746' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a66d9f33-69ee-4d23-895c-c9870cdc988c', 6, N'CshXwrJ4C77QmBoWQC5RIcTl8xFA3BpNr1KIXDlb4MA=', N'5b9cb9db-fc2d-4893-bf78-738f596076c1', CAST(N'2025-08-13T04:05:11.3833333' AS DateTime2), CAST(N'2025-08-06T04:05:11.3772351' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4452c9ae-6720-48f0-a705-c9af3691550a', 6, N'0CaalrAnFnUtleyfxX5wiwPMAwMNuSfaXFvjSxfPa+o=', N'5b88a396-4e0d-41e9-b14d-0cae69db2a58', CAST(N'2025-08-14T04:51:41.2400000' AS DateTime2), CAST(N'2025-08-07T04:51:41.2451200' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'97e7173e-e312-492d-abe8-ca0aa9fd9fdd', 6, N'ShaNmWUtQM1oB9yEXsjAJZwx/9wc6JBpC38tFHWC8IQ=', N'abb49a53-2b48-43f0-8f75-201e94806132', CAST(N'2025-08-22T05:30:01.8600000' AS DateTime2), CAST(N'2025-08-15T05:30:01.8817350' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'93f00484-7dd7-4a5d-8db2-cb2de1d36b25', 5, N'YTADUhp9bsE35LaTi4DZXBSUzP4Jga+jP/A+rVtMqPI=', N'6ac269b4-45d3-43d8-8181-d03be2dc78e7', CAST(N'2025-08-10T03:50:53.1500000' AS DateTime2), CAST(N'2025-08-03T03:50:53.1687276' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'039e6370-43fa-437c-90b1-cb6b7596812e', 6, N'BJPduwJdginEo/bihXxAjFe3pn0WBWJY4UWUEcfbYt4=', N'b931b967-b5ec-4ef3-b096-11026be04a96', CAST(N'2025-08-14T09:50:18.8000000' AS DateTime2), CAST(N'2025-08-07T09:50:18.7981328' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'63e268c5-57ac-4366-a37a-cb6f44eef069', 6, N'iygUm+dkc5Z3ZN3r3ebeCsHYxmL8N2hlelMn0lpDPcs=', N'5250c977-5c4a-4e1b-bff1-829267845809', CAST(N'2025-08-11T11:34:30.6966667' AS DateTime2), CAST(N'2025-08-04T11:34:30.7010160' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'14c5f418-9270-45d8-8cbf-cc15c4dc603b', 6, N'65qxOMA9K1t7cS6QCfqY15f7vkBDP8BwV9j/+Fc1n3I=', N'62f099eb-a350-4f67-8c5c-d57cd12b083f', CAST(N'2025-08-20T09:14:51.3966667' AS DateTime2), CAST(N'2025-08-13T09:14:51.3951752' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1021fa3e-d17e-44f8-8f68-cc8c166d61fb', 6, N'KcH8a0q+KlWjIQmeshYvXTOVws1Qzn6YYUJFOtinghQ=', N'7edc2dd5-8955-41c7-904a-916d03331547', CAST(N'2025-08-13T09:22:06.1633333' AS DateTime2), CAST(N'2025-08-06T09:22:06.1675977' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'9101ebd8-dca1-4a23-a019-cd64c7f9767a', 6, N'YnLTlWTp71s/T4txxV8NgVARubRAncFYezm3jks4a1U=', N'519e7974-23be-4d75-b605-02aad6f37364', CAST(N'2025-08-10T11:18:04.2200000' AS DateTime2), CAST(N'2025-08-03T11:18:04.2182726' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4210dd81-3358-447b-b40a-d1295e792d09', 6, N'i1D1WE/+4hZcms0k8p/A3ZCxjLMeV1Ud8rj5BoD8nMw=', N'91f541a3-2eab-4f35-8160-af6d69b49bd9', CAST(N'2025-08-13T03:54:38.7966667' AS DateTime2), CAST(N'2025-08-06T03:54:38.8008720' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'84d33898-3351-48dd-9b9e-d2f6de10c64a', 6, N'PmW+vsTeThEO7OeGMF4bLVcxKi7FGTsS/Vae+SLWxQg=', N'388adaa9-e174-43ae-a139-2a2fde152c37', CAST(N'2025-08-13T09:43:47.9300000' AS DateTime2), CAST(N'2025-08-06T09:43:47.9234135' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ab3e2b44-7194-4c2d-8a6c-d377a7305dcc', 6, N'GnbICcYcI3xZqN0At5cLv2aZeDXVe7YtNWr1oqGYDt8=', N'85e4e1e4-3411-469c-aa00-37b23e5aa27c', CAST(N'2025-08-11T11:30:15.5133333' AS DateTime2), CAST(N'2025-08-04T11:30:15.5140778' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'bd6673e1-bb78-4222-beb9-d3e7c60ad788', 6, N'jE3EXo+JaKHmcJL87rMyO6Ta05sKsqi5w1MpVeeuwgM=', N'b9ad44e0-ad4b-4008-a90f-af66b6f0c79d', CAST(N'2025-08-12T03:11:33.4966667' AS DateTime2), CAST(N'2025-08-05T03:11:33.4902905' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c56dc180-e927-4be2-aca8-d4a6f30b36cd', 6, N'03WGEiQ5ttAYl/6VGwt8fR7i7GlR2qsrD/BvhZ0E56Q=', N'57522075-8954-4f72-bfaa-1594fff89fea', CAST(N'2025-08-20T03:44:41.2633333' AS DateTime2), CAST(N'2025-08-13T03:44:41.2692063' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6424e41b-0d07-4488-a339-d59526940c3a', 6, N'YxVH2uoarpZ90QqwEt1QrBv3dley8dLI0/2pGEstYkM=', N'43124678-e8ab-4031-9ba9-61e387be1546', CAST(N'2025-08-14T09:00:46.4666667' AS DateTime2), CAST(N'2025-08-07T09:00:46.4701246' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'44f86cdd-7882-4161-a382-d5d20b772596', 6, N'tt/Y6WriUa7QMh1OMBedh1BokVdkXPqnBTHSJwXeKa0=', N'3a622de7-b170-4059-9dd3-3e527aa5e69b', CAST(N'2025-08-11T07:22:46.3933333' AS DateTime2), CAST(N'2025-08-04T07:22:46.3895981' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd04c97b2-ae5b-4d05-9981-d7588487f15e', 6, N'+SYn9TQjBglXmfm4Nbh24TNgJ6+X8zm2Nw2QUW43KJM=', N'1e8ce515-c2f9-4b6d-b54e-872fdd4055bd', CAST(N'2025-08-14T04:02:21.4866667' AS DateTime2), CAST(N'2025-08-07T04:02:21.4949381' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd24a0a01-829a-449b-b565-d98bc1097b98', 6, N'PqNwfHk0SS40ygO/+AJ7Zpivf6zP2fSN6ITUop9o9FA=', N'b1040101-02ee-4f32-9d61-92ddbd735413', CAST(N'2025-08-16T04:16:06.8833333' AS DateTime2), CAST(N'2025-08-09T04:16:06.8814756' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'acd41c6d-463f-44d9-b8aa-da22c8d90cdc', 6, N'8EIznjVvhP4KfWlnaFGukfPwUIqoDEeJ08Q6ugBgANM=', N'632b02e0-3ed8-4c96-95b8-92308a53c83f', CAST(N'2025-08-20T03:52:58.7566667' AS DateTime2), CAST(N'2025-08-13T03:52:58.7551234' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'f0d9ba77-177d-4e1d-bfee-db4cc8f17bb6', 6, N'X40tM9EVtkiNB+nh70tH/52eikpdk9qvIfpRt9OcY5s=', N'f83805c0-8240-4f2f-abf0-150a20c571a3', CAST(N'2025-08-11T07:43:22.5033333' AS DateTime2), CAST(N'2025-08-04T07:43:22.4879564' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'68e0f73f-3758-4cbd-8f0b-dd9740dd3964', 6, N'XfMVJZjHU7Va4KEoc7iEYPxhl3VVzkndK/UUHczCkhs=', N'203cd88f-e33c-453f-8bf8-068388ef221d', CAST(N'2025-08-20T08:47:31.2933333' AS DateTime2), CAST(N'2025-08-13T08:47:31.2924785' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2701407b-873a-496f-812c-dd99be61cd89', 6, N'z1tJvIj+ATkwKoWYpovZ76IwYur+apDtR5DLDP87Gdo=', N'e38f3591-5bae-459b-8a4d-d9cd529cc5d9', CAST(N'2025-08-13T11:40:04.2333333' AS DateTime2), CAST(N'2025-08-06T11:40:04.2544021' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'615b5088-2b69-4c00-8f4c-de3bc15ca2af', 6, N'vhVyg3vuc7KxMG2Km3Vtksdz8/DXXRVxvhyXiumjTCs=', N'8f4572c5-6870-4982-b3fa-eff83285398e', CAST(N'2025-08-10T11:04:49.5533333' AS DateTime2), CAST(N'2025-08-03T11:04:49.5403026' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4bf93b1f-8940-452b-8f5b-de93216b5a15', 6, N'Odfqa5v/SFnllQmNzwxwYXpdQ1tgTnmfOEH+bHOXSsI=', N'ddd39b13-2663-4f6c-b461-d5bf7988235e', CAST(N'2025-08-11T07:07:19.3266667' AS DateTime2), CAST(N'2025-08-04T07:07:19.3218533' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a06c73f3-0ac9-48cc-9b4e-e0830025e85c', 6, N'aRpZeB2H9lQJTspBJr4nfwYYx5ulVZfFHurst/hviR8=', N'dcb28746-9fd4-4bd8-85e4-41167a38d160', CAST(N'2025-08-11T07:43:17.8233333' AS DateTime2), CAST(N'2025-08-04T07:43:17.8278016' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'21ef1d20-ada8-4e89-aac5-e1450cfa7eb0', 6, N'wmR3HJlfBhL/eetDPxoVsUULTRW7w9F36px9wWu/FBA=', N'6f9727da-07bf-49a1-9f21-44b2ba83a0f6', CAST(N'2025-08-11T09:22:02.6866667' AS DateTime2), CAST(N'2025-08-04T09:22:02.6780257' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e721d661-2a54-4a6b-aea6-e16db57d9873', 6, N'oEDuP1dsqnqEHi1lkdeJtRn/NScdBjtcVP5M4T+KCtY=', N'c099521d-3b2c-4e2e-b46c-f1ebf083a664', CAST(N'2025-08-20T04:09:06.9166667' AS DateTime2), CAST(N'2025-08-13T04:09:06.9216100' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'd74f8bb6-a84d-4f26-b881-e22957106d81', 6, N'X1QYekx7X7vUZSvvECbYR30rnS2YBsjmr0HHyQciFMo=', N'edf1918f-925f-4890-a142-53df63c4360d', CAST(N'2025-08-11T09:09:20.8966667' AS DateTime2), CAST(N'2025-08-04T09:09:20.8918238' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'73931ba9-26f7-434b-abe0-e28e801e69eb', 6, N'Zr3JX8w3yMK7YJMZSk/KFGVIj4wUGP5qyRqWOx2zFdo=', N'870f7097-afa4-45ca-92a1-42d40c8b20b9', CAST(N'2025-08-18T09:40:34.5600000' AS DateTime2), CAST(N'2025-08-11T09:40:34.5547314' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'24edb88e-5322-447e-98bd-e2c907cb9521', 6, N'9twDdoNH/zathr4s1qOrvt6mytPLIV5qEgw26iwUeQA=', N'a3333481-7a73-44cd-898c-abdc4ccda7c4', CAST(N'2025-08-18T08:53:09.5633333' AS DateTime2), CAST(N'2025-08-11T08:53:09.5693398' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'69a0cb97-9d7a-4030-ba22-e2cc82504ca4', 6, N'wK/fKYYq7VoqZ7UiFIbqxzcoiPdeUw7PPQtRy+ljGDE=', N'2cef886c-6f80-4562-b6ab-3c6fd58d358e', CAST(N'2025-08-16T07:19:34.5800000' AS DateTime2), CAST(N'2025-08-09T07:19:34.5815598' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3a0683b3-6899-47d2-af29-e2d1de257ed3', 6, N'VhfNDwB7BagdhU5gcsWIl0J+/Dsz6JlqvTw17c9sX9g=', N'bb62a406-3e41-4292-a8ca-5429897172c1', CAST(N'2025-08-21T03:56:34.5100000' AS DateTime2), CAST(N'2025-08-14T03:56:34.5111182' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2d0d1cd1-ba6e-430b-ad6f-e3598b32b1d1', 6, N'OxWYrTvOhIqZacpgk/qX6aqOvJzM/Pe8EVlNL3UVHWM=', N'3b8f28e4-43bd-4a7f-bd00-6dbce61bafa4', CAST(N'2025-08-11T11:15:54.0600000' AS DateTime2), CAST(N'2025-08-04T11:15:54.0629347' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'73c9a332-f730-4bc0-a343-e3d797c5c2d7', 6, N'PyKAlBWQ5oIolA+kqvEUkHy+12MrB0Hk2P35saiUlX4=', N'a7cb14d3-9893-4e9c-acdb-54f274387495', CAST(N'2025-08-16T01:58:45.9433333' AS DateTime2), CAST(N'2025-08-09T01:58:45.9551419' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'1a2709e7-ad56-40cd-baad-e51e28d03949', 6, N'nJNxS3zlzAYdXXI5YtqDXPAWuLvUu8mKO902jCS9Xy8=', N'cbb3d915-106d-4a4a-975d-07ed0b90420a', CAST(N'2025-08-24T04:05:57.5100000' AS DateTime2), CAST(N'2025-08-17T04:05:57.5166489' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'176f62eb-1f7b-4c7d-948d-e68a4b381d02', 6, N'Bt16cr0UAMy0cXWZM0JM4u/Zwzhorhixm1xRzs1JH5U=', N'ef4fdead-fa4b-4463-aa09-f29ab87672c4', CAST(N'2025-08-11T06:44:29.3633333' AS DateTime2), CAST(N'2025-08-04T06:44:29.3685638' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b184d22c-d221-4209-bba6-e6a039590859', 6, N'5KCwzm3/liSfIRSs75NsorrkwBcZbk1B7n7X3H5PLGY=', N'4b0d60dc-4323-4c22-8cb0-c2d1b40c8384', CAST(N'2025-08-18T05:02:46.7766667' AS DateTime2), CAST(N'2025-08-11T05:02:46.7665110' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'af06ef9b-3a4f-4d83-9e4d-e6c4ffce9ac3', 6, N'Hp517hs7qnHndr3mhu2P88554uqPRW5h20pHHSpyBTQ=', N'd04bbd96-40d2-4425-ad98-901d6308c9c7', CAST(N'2025-08-18T10:46:48.1833333' AS DateTime2), CAST(N'2025-08-11T10:46:48.1866396' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'184497b3-c8c8-4920-bb3f-eb27a1f47e0f', 6, N'yZBf6R+algfbTUy5Jmf78uedMWSkHJw2AG5K6Rpf1AI=', N'dfce03ad-9eaa-4a7e-b7f2-ec2e455e4bac', CAST(N'2025-08-18T09:56:51.8866667' AS DateTime2), CAST(N'2025-08-11T09:56:51.8786260' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'85b8dfd6-471f-46de-9bc4-eb97801bbb48', 6, N'WVmDAL89UXfbkt7SQ/rV1Tiv4qwpXOUlm0budGWIrxM=', N'312c8291-34fe-4aaa-b34a-8033e3133808', CAST(N'2025-08-11T10:52:19.0300000' AS DateTime2), CAST(N'2025-08-04T10:52:19.0292337' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'c7d2106e-edc8-4a5e-9684-eb9cfaf3ea1c', 6, N'0PkIVwg0PDSRhku+g0B8P4EkBDiVXd2EzIiyWITHMGA=', N'a4522e5d-8ce5-4d59-a694-a9fd34ffcfc1', CAST(N'2025-08-22T06:28:11.4266667' AS DateTime2), CAST(N'2025-08-15T06:28:11.4308387' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2b6d97c5-4936-4f0b-8566-ec5ad227703b', 6, N'f5HQD4wuDQkE3X9O9V/O2KeF/0sKsU6qX+UZy3SaMrY=', N'3ed71580-e458-4d29-80f5-83ca563eee48', CAST(N'2025-08-16T06:43:53.2800000' AS DateTime2), CAST(N'2025-08-09T06:43:53.2837687' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'dc312415-e74d-49a5-8a8a-ec81bcc785ca', 6, N'hjebAnkWOk5kG+edf9lyMuyC6ROItJ6yVFLzpOEsYrs=', N'03d6c334-90e8-4608-b544-27ee36fd6e53', CAST(N'2025-08-11T05:59:01.0733333' AS DateTime2), CAST(N'2025-08-04T05:59:01.0715657' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4faab810-353f-415b-9cac-ec983bfa3469', 6, N'mdobVWw3/jF0HBVfSrUFN5h5nehI+/TNEebpvjqIKDw=', N'9b98515a-ccbd-4c4b-8edc-8cefb92cab2b', CAST(N'2025-08-10T07:36:29.7600000' AS DateTime2), CAST(N'2025-08-03T07:36:29.7632727' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4bd6717e-0393-4ef8-a148-ecd3f45264e2', 6, N'vXr+xJVml7mNJmcyzKYyZ17hZ1oAKPufa4kfjqjc33s=', N'1740b261-82f3-4468-8a41-cd9e1043b696', CAST(N'2025-08-11T07:26:11.5866667' AS DateTime2), CAST(N'2025-08-04T07:26:11.5921022' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'31cf968f-1386-4d3f-bebf-efe898c7c90f', 6, N'LteIsLyGiZyxQkL6Fnj0M7uY0/8AAV1hEJlThUNmCqA=', N'ab1efd50-86fe-403e-8689-d8bd9b8a765d', CAST(N'2025-08-11T06:37:33.1233333' AS DateTime2), CAST(N'2025-08-04T06:37:33.1222895' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'3ccf173c-03f7-4d37-8c8e-f0d6f6edb0c3', 6, N'DCdNJrEiAK1rqZg5us27P1MYQIydhHM+qNrCGuFsz1A=', N'2be78e0c-d158-421b-b665-e8a737fdb464', CAST(N'2025-08-16T02:02:17.8933333' AS DateTime2), CAST(N'2025-08-09T02:02:17.9112359' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'aa1be967-bf84-426c-9c13-f129a9c6a677', 6, N'kfqUNYnDeg+8xq+STOkvYiOLozya8aoDTOGNnVxMmts=', N'8aaedae0-f7c2-4709-90d3-80d0b79564a2', CAST(N'2025-08-13T08:54:33.3400000' AS DateTime2), CAST(N'2025-08-06T08:54:33.3372627' AS DateTime2), CAST(N'2025-08-06T08:54:55.3178265' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2dec6ed9-f718-4aa5-8507-f258072b6e58', 6, N'KKNVha+9+yN4VyxOPgHzKw3eSgCFrzg5/tF0XArVtVs=', N'e13920b4-69cb-48a7-ba78-aa3c635219cf', CAST(N'2025-08-11T06:27:11.5033333' AS DateTime2), CAST(N'2025-08-04T06:27:11.4978646' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'447bd16b-0979-49f3-b477-f28a5a3a803c', 6, N'FnXTZQTIK5/qp4fPSFBD00aLxI83I+saGojeTCAVCgA=', N'02bd6a53-f010-496b-9ac9-e038e3a5a2cc', CAST(N'2025-08-13T07:25:58.9666667' AS DateTime2), CAST(N'2025-08-06T07:25:58.9548229' AS DateTime2), CAST(N'2025-08-06T07:28:34.8589499' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e7c96877-bcab-4b31-af0a-f29b8851f367', 6, N'C5bqdLqcqY1SM/9c6adlKaDVKFNH4Gl2qKbfWPVtlXE=', N'3538a5d0-d8ad-47d1-8a3a-f958f6523516', CAST(N'2025-08-19T04:40:01.2500000' AS DateTime2), CAST(N'2025-08-12T04:40:01.2499404' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'37c20984-27d0-41c7-8ba5-f43dcdae1be7', 6, N'eK0KGMfROt5PmRJ9rFK8nxy+eKc2oYpQM6TWmUoRVnA=', N'7f1ca9e4-bbd0-4891-8888-05a0b5c0195a', CAST(N'2025-08-20T09:20:15.3100000' AS DateTime2), CAST(N'2025-08-13T09:20:15.3124852' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'aff6f125-e9e8-4b9c-beb5-f44fa948661f', 6, N'sK0fUY+BZeUBI1FIZpuhE+PWtS6YpcvSVSYWfjdDDOw=', N'b3a40a35-9b07-430e-bdc4-bafed15faa2e', CAST(N'2025-08-18T15:53:25.3366667' AS DateTime2), CAST(N'2025-08-11T15:53:25.3350232' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'335ad56c-37d8-41da-8483-f569c73d25eb', 6, N'W7JAYXgdtiQZ41cHf9vycKoeBhVtulNbO5CdGLvXf+c=', N'5a2d0aa1-d2d3-4bd5-aa82-1365440af15c', CAST(N'2025-08-16T10:19:00.2166667' AS DateTime2), CAST(N'2025-08-09T10:19:00.2236570' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'8ca30d0c-53a2-4fb1-800c-f584ef400c25', 6, N'HXF2tKEaq+YNuoG79nqwsugvWVRDnnTwKIgvF+/DIWY=', N'71221b78-3db7-4ca0-ba86-e4a5564c6c30', CAST(N'2025-08-19T10:39:36.4300000' AS DateTime2), CAST(N'2025-08-12T10:39:36.4327860' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'677853fa-93e2-4c13-83a4-f5c5531c8a83', 6, N'yOqfqImfuB4MMQR8SwsfjFgwEWwwSPZgFQz2VJM4Vhw=', N'990343f8-7e6f-47b5-8213-b26ab5d54c98', CAST(N'2025-08-20T11:32:39.0800000' AS DateTime2), CAST(N'2025-08-13T11:32:39.0753676' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4fe35715-e4d7-4826-903f-f5e5ebd96985', 6, N'2mwqZe1ABS4nDO43XFnHZ/4wJ7cbI5r9lNHHCieSRSw=', N'838ce6ec-2082-44ce-817b-701104d8ecba', CAST(N'2025-08-13T04:33:48.9566667' AS DateTime2), CAST(N'2025-08-06T04:33:48.9601055' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'10a00c9d-2f64-4b66-8131-f5e69a8303f9', 6, N'vu6esRzgHcbq+lqOneF28gLAUXmtv0qqU40eiXFBvMk=', N'3eaf7def-f479-4233-b093-d5e39669f9e2', CAST(N'2025-08-24T04:17:43.9633333' AS DateTime2), CAST(N'2025-08-17T04:17:43.9586525' AS DateTime2), CAST(N'2025-08-17T04:18:09.4051122' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'a652472e-edf7-494b-8a35-f675cb7a602d', 6, N'lvIaUSRJgmc+qt1+WdmQVEYplXn8agMN5Q8Z73h/Dr0=', N'74d3c640-b9e2-4b03-ad91-48ec36ea830e', CAST(N'2025-08-11T09:09:33.2033333' AS DateTime2), CAST(N'2025-08-04T09:09:33.2023957' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'e7116c11-adb2-4cf5-9634-f6b8f90393be', 6, N'bp2kltzELMigRz6DruOfO537ywovld2QD9m6rC/vyW8=', N'9292bbe1-b5dc-4cc1-a151-9f23b5af39d1', CAST(N'2025-08-19T11:37:07.4200000' AS DateTime2), CAST(N'2025-08-12T11:37:07.4247767' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'603caa58-042b-4ff0-a88e-f6e342314114', 6, N'scYBWK4xTJWez5ontICQHyMsmFuyIZM/Cp9NvM7OQUI=', N'694b33c5-e4e2-46ce-975f-f05f785f354f', CAST(N'2025-08-24T04:06:55.5266667' AS DateTime2), CAST(N'2025-08-17T04:06:55.5325586' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'835e7cf3-0806-449a-ae8e-f75708fd5410', 6, N'PKrcxIyl5XgUC04K3zUnsFSjmyVdPdTJTOaehr9uWjQ=', N'7e1a1c35-47ac-4f83-a8f4-efeec4b29fbb', CAST(N'2025-08-11T06:40:13.2466667' AS DateTime2), CAST(N'2025-08-04T06:40:13.2413627' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4421bfea-88c4-46d7-9156-f7ba3a610b47', 6, N'kHDq5vYeLe9T0oQZo8PWdCra2GQgHzuJ7U6mwUtV4ro=', N'82bdc32a-b062-498d-a18a-721b6f4ae09d', CAST(N'2025-08-11T07:26:23.0400000' AS DateTime2), CAST(N'2025-08-04T07:26:23.0450622' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2e55c7c9-948d-4cef-b672-f8554b45c8c0', 6, N'gq6bn5wk9BWJcnrcUm3jkTSpoAOu7hP196P9puIcF4c=', N'c83c55b2-8557-403e-aa67-5d7a06df7a31', CAST(N'2025-08-11T08:00:27.4700000' AS DateTime2), CAST(N'2025-08-04T08:00:27.4731727' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'b9e823c6-f09b-4d36-989b-f958c6ded888', 6, N'LdbYLm2sobZX9IAx4E0BIzEVt6uLBYKq5DsPWxoJgy0=', N'a946f3b6-511f-4cda-8acc-d1c0469e1d81', CAST(N'2025-08-19T10:13:50.0700000' AS DateTime2), CAST(N'2025-08-12T10:13:50.0620551' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'4f25d90f-6d58-4441-b93a-f9ca40b8c7db', 6, N'elf1zCeTQ3uWQUdXzP0uze9/t2julXgF/DhLmcGK5/Q=', N'604157ff-69ba-4d04-b6b7-60c3b0a5291e', CAST(N'2025-08-16T08:28:14.3300000' AS DateTime2), CAST(N'2025-08-09T08:28:14.3354060' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'733924f3-e2c7-4a6e-a1c9-f9cd12c86c79', 6, N'GRatH/H9givri0pfNr+tbuy93DlUetzIdem/JzdQDzE=', N'edacb8f7-e880-4147-bd41-0373f08f49f9', CAST(N'2025-08-20T09:20:35.3933333' AS DateTime2), CAST(N'2025-08-13T09:20:35.3907378' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'11adc036-110d-470c-bbd5-fa21ca9fca26', 6, N'sXZ0i3GpAaOKib2uiz6ktVI/c2p1f5kHj6NQ2dDf/8I=', N'c9d39233-43a0-499c-87e9-c2261d675408', CAST(N'2025-08-13T04:05:00.8700000' AS DateTime2), CAST(N'2025-08-06T04:05:00.8765492' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'49350777-42a5-4994-a23e-fa3e0b096228', 6, N'VWOf1jJ2gzMJKUZ+hO7a1Yso4tJ4eQtrASc5Mvxhr40=', N'efbafb33-3cfa-4269-9329-166b6f42a5a7', CAST(N'2025-08-20T09:02:39.5366667' AS DateTime2), CAST(N'2025-08-13T09:02:39.5399648' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ad8111e4-d7d7-4575-969a-fa6db52e85f0', 6, N'nXcsxj1UiE0Kg7aa59OdT8ktFb2homq5GVGw4vSTDg4=', N'87ec60fa-d08d-4494-b723-64749a8ea319', CAST(N'2025-08-11T09:00:26.0466667' AS DateTime2), CAST(N'2025-08-04T09:00:26.0526378' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'5db56fd7-326b-463d-90a0-fb9f8f32fd49', 6, N'hntaTVkVuYQ9xQymxNvzwHopIfdzxP44rrT2ViB1hAE=', N'7670e84c-e781-4cf5-8882-796f70eac24a', CAST(N'2025-08-18T11:45:49.5533333' AS DateTime2), CAST(N'2025-08-11T11:45:49.5498129' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'2d3e0adc-5a89-4c8a-80fe-fbfc120fb806', 35, N'bPLoNw3mLIuhnFl2x7QfVx3VNgy/uhRuZseXs6vVjnI=', N'747e6d01-30e6-407e-aa4d-6cd639178345', CAST(N'2025-08-26T03:25:36.5233333' AS DateTime2), CAST(N'2025-08-19T03:25:36.5278827' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'20aaa60d-7b01-4d97-80f0-fc04f0a3b7b0', 6, N'DnndyS19TyjzyNsQdy3ex2LUp/H5laiHZEAszAB31dk=', N'f3be8ffa-d214-42cf-951a-362411837e12', CAST(N'2025-08-26T10:15:55.2566667' AS DateTime2), CAST(N'2025-08-19T10:15:55.2626630' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'30ea3c42-6c50-439a-b2a4-fc1d03cc2537', 6, N'Z0atjdo8g2nF8qtTzvu+nxi9PeQB6qQKGTV+x4gRwiA=', N'32b45b40-9ac1-4d70-aa0b-848273f6cd6a', CAST(N'2025-08-13T06:04:02.9566667' AS DateTime2), CAST(N'2025-08-06T06:04:02.9511033' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'6e194162-3174-40fd-ab7d-fda04efb2447', 6, N'2++yGtN+ZU5pw8MVuPm1ThO1DCSIa0RIlVTe0j8OvcY=', N'92b47021-04c7-42c0-9987-0b4407c17959', CAST(N'2025-08-10T11:40:17.9833333' AS DateTime2), CAST(N'2025-08-03T11:40:17.9736407' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'590ea266-155b-4dad-ab0a-fdbfa7b0ace6', 6, N'n/Q75uIZ0Qhf/pErT1wZ/tBUXma8DDWT2e8hfJiOdAM=', N'ce6fcf7b-5e48-4f50-949f-64e8a13b0b2a', CAST(N'2025-08-13T03:56:58.7366667' AS DateTime2), CAST(N'2025-08-06T03:56:58.7476004' AS DateTime2), CAST(N'2025-08-06T07:25:38.1474089' AS DateTime2), NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'7a2bb3bf-9c91-482e-b8b5-fe8f2ac82e8b', 6, N'fxF+guoet3Dafr1Dwt/vuTjVyqUctvNWmU0kODVNp28=', N'eaa73a73-2f16-4008-a1a6-cdddc84aa903', CAST(N'2025-08-22T07:29:06.1066667' AS DateTime2), CAST(N'2025-08-15T07:29:06.1023157' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'aec32b7c-c9ab-4df3-a64d-ff00473d8762', 6, N'mK8qjZ+q3/XUvrG91x8Q3foMnoghBGv9ActnYm/ObYM=', N'e6c80317-f16b-45b5-a1ac-e44d832c4613', CAST(N'2025-08-18T10:46:02.4066667' AS DateTime2), CAST(N'2025-08-11T10:46:02.4052969' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'ac3ceb7b-a99c-44c7-8d23-ff07ae0f956d', 6, N'IwC8ACU5RB8t9WIxObuaY38kOFSKxwQoQrgYC0EP2oc=', N'26886649-83bc-4d9b-b234-95b47338039e', CAST(N'2025-08-18T11:22:55.5500000' AS DateTime2), CAST(N'2025-08-11T11:22:55.5404342' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[RefreshTokens] ([Id], [UserId], [TokenHash], [JwtId], [ExpiresAt], [CreatedAt], [RevokedAt], [ReplacedByTokenId]) VALUES (N'f64dab23-ee57-4b81-9998-ff0dd6e8dabb', 6, N'V9s6ze+Pazkj5tOxbfMBAPtPB9cZo+fEwtZIvdr6KNM=', N'6578193e-3eb8-4bcd-ae97-3fa105baba09', CAST(N'2025-08-24T04:39:23.6866667' AS DateTime2), CAST(N'2025-08-17T04:39:23.6906005' AS DateTime2), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Unites] ON 
GO
INSERT [dbo].[Unites] ([Id], [Name]) VALUES (1, N'Billion Dollar')
GO
INSERT [dbo].[Unites] ([Id], [Name]) VALUES (2, N'Percentage')
GO
INSERT [dbo].[Unites] ([Id], [Name]) VALUES (3, N'Count')
GO
SET IDENTITY_INSERT [dbo].[Unites] OFF
GO
INSERT [dbo].[UserDepartments] ([UserId], [DepartmentID]) VALUES (6, 4)
GO
SET IDENTITY_INSERT [dbo].[Users] ON 
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (5, N'sultani', N'100000.ZcfqzR4G68SLXlDW0aFYaA==.G1S/n252qWn1SoinwuaKrmTnPWY86FBJKTs/IyW6IMo=', N'Admin', 7)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (6, N'admin', N'100000.BexkrbtF/XBHTBqZdjqwrA==.40fAH4lPX2tlPCfjB0WMQQ1F4TLbnauDlt8usDiiRt0=', N'Admin', 5)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (29, N'sameer', N'100000.b8qdrR3bfU3Bxv1GDtB00g==.RjCEFWCYTWHPs0yTY+zu5F4COCBzn+i7PLN3bQLNl7A=', N'Admin', 1)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (30, N'mustafa', N'100000.nnOzUm599ivsbbxlsCsqFA==.O/kHKAABe64mErs8TazMl6uoPdF8eOGNZyihkQaf/OI=', N'Admin', 3)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (31, N'testing', N'100000.VJI3oLNu6Plltw3kXVkhWA==.S37nqFJkrUgMkFcYY+aC61/qfyifmZ4nlLvlsVoPemo=', N'Manager', 2)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (32, N'af', N'100000.IS+wYqZnY2b9Q7DzzHsniw==.6N4OXUlsBo5PQu+DO2/9aIv4FgsR1ZzpNoyQUWnxFRY=', N'Manager', 3)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (33, N'jalal', N'100000.ByJMPI/sAj4gr9iMnx9WaQ==.U7UVOpgxb0pp7fLdB4Y4d6PhTDPbaewrwDT6C1a3GYQ=', N'Manager', 4)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (34, N'mujeeb', N'100000.Sv1XYhvW2jPIYwySE+EFVw==.WlN0dqYfRTjNWpDtThU7rhmWi6x14Ey4ssTSOuD3yB0=', N'Manager', 4)
GO
INSERT [dbo].[Users] ([Id], [Username], [PasswordHash], [Role], [Departments]) VALUES (35, N'zaki', N'100000.8S2qGzG/+8FlnZ3y9vY9lA==.ToiE0B91tpXlDHVwn5B+QSvU8mfWhAEICHYnkGATAB8=', N'Viewer', 5)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
INSERT [dbo].[UserSubDepartments] ([UserId], [SubDepartmentId]) VALUES (6, 2)
GO
INSERT [dbo].[UserSubDepartments] ([UserId], [SubDepartmentId]) VALUES (6, 3)
GO
/****** Object:  Index [IX_Calendars_Year_Month]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_Calendars_Year_Month] ON [dbo].[Calendars]
(
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__ChartCon__4CDF25A3349C8992]    Script Date: 8/31/2025 3:47:04 PM ******/
ALTER TABLE [dbo].[ChartConfigs] ADD UNIQUE NONCLUSTERED 
(
	[IndicatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_ChartConfigs_IndicatorId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_ChartConfigs_IndicatorId] ON [dbo].[ChartConfigs]
(
	[IndicatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DataValues_CalendarId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValues_CalendarId] ON [dbo].[DataValues]
(
	[CalendarId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DataValues_IndicatorId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValues_IndicatorId] ON [dbo].[DataValues]
(
	[IndicatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DataValues_LocationId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValues_LocationId] ON [dbo].[DataValues]
(
	[LocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DataValues_LocationType]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValues_LocationType] ON [dbo].[DataValues]
(
	[LocationType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DataValues_PeriodType]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValues_PeriodType] ON [dbo].[DataValues]
(
	[PeriodType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DataValuesAudit_DataValueId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_DataValuesAudit_DataValueId] ON [dbo].[DataValuesAudit]
(
	[DataValueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_IndicatorChartTypes_IndicatorId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_IndicatorChartTypes_IndicatorId] ON [dbo].[IndicatorChartTypes]
(
	[IndicatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Indicators_ParentId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_Indicators_ParentId] ON [dbo].[Indicators]
(
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Indicators_UniteId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_Indicators_UniteId] ON [dbo].[Indicators]
(
	[UniteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Locations_ParentId]    Script Date: 8/31/2025 3:47:04 PM ******/
CREATE NONCLUSTERED INDEX [IX_Locations_ParentId] ON [dbo].[Locations]
(
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__RefreshT__BCB33F923A0CA48E]    Script Date: 8/31/2025 3:47:04 PM ******/
ALTER TABLE [dbo].[RefreshTokens] ADD UNIQUE NONCLUSTERED 
(
	[TokenHash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartConfigs] ADD  DEFAULT ('Legend') FOR [CalculateGrowthBy]
GO
ALTER TABLE [dbo].[ChartConfigs] ADD  DEFAULT ('Legend') FOR [CalculateTotalBy]
GO
ALTER TABLE [dbo].[ChartConfigs] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[DataValues] ADD  DEFAULT (getdate()) FOR [DateAdded]
GO
ALTER TABLE [dbo].[ErrorLogs] ADD  CONSTRAINT [DF_ErrorLogs_LoggedAt]  DEFAULT (sysutcdatetime()) FOR [LoggedAt]
GO
ALTER TABLE [dbo].[Indicators] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RefreshTokens] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ChartConfigs]  WITH CHECK ADD  CONSTRAINT [FK_ChartConfigs_CreatedByUserId] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[ChartConfigs] CHECK CONSTRAINT [FK_ChartConfigs_CreatedByUserId]
GO
ALTER TABLE [dbo].[ChartConfigs]  WITH CHECK ADD  CONSTRAINT [FK_ChartConfigs_DeletedByUserId] FOREIGN KEY([DeletedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[ChartConfigs] CHECK CONSTRAINT [FK_ChartConfigs_DeletedByUserId]
GO
ALTER TABLE [dbo].[ChartConfigs]  WITH CHECK ADD  CONSTRAINT [FK_ChartConfigs_DepartmentId] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([Id])
GO
ALTER TABLE [dbo].[ChartConfigs] CHECK CONSTRAINT [FK_ChartConfigs_DepartmentId]
GO
ALTER TABLE [dbo].[ChartConfigs]  WITH CHECK ADD  CONSTRAINT [FK_ChartConfigs_IndicatorId] FOREIGN KEY([IndicatorId])
REFERENCES [dbo].[Indicators] ([Id])
GO
ALTER TABLE [dbo].[ChartConfigs] CHECK CONSTRAINT [FK_ChartConfigs_IndicatorId]
GO
ALTER TABLE [dbo].[ChartConfigs]  WITH CHECK ADD  CONSTRAINT [FK_ChartConfigs_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[ChartConfigs] CHECK CONSTRAINT [FK_ChartConfigs_UpdatedByUserId]
GO
ALTER TABLE [dbo].[DataValues]  WITH CHECK ADD  CONSTRAINT [FK_DataValues_CalendarId] FOREIGN KEY([CalendarId])
REFERENCES [dbo].[Calendars] ([Id])
GO
ALTER TABLE [dbo].[DataValues] CHECK CONSTRAINT [FK_DataValues_CalendarId]
GO
ALTER TABLE [dbo].[DataValues]  WITH CHECK ADD  CONSTRAINT [FK_DataValues_CreatedByUserId] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[DataValues] CHECK CONSTRAINT [FK_DataValues_CreatedByUserId]
GO
ALTER TABLE [dbo].[DataValues]  WITH CHECK ADD  CONSTRAINT [FK_DataValues_IndicatorId] FOREIGN KEY([IndicatorId])
REFERENCES [dbo].[Indicators] ([Id])
GO
ALTER TABLE [dbo].[DataValues] CHECK CONSTRAINT [FK_DataValues_IndicatorId]
GO
ALTER TABLE [dbo].[DataValues]  WITH CHECK ADD  CONSTRAINT [FK_DataValues_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dbo].[DataValues] CHECK CONSTRAINT [FK_DataValues_LocationId]
GO
ALTER TABLE [dbo].[DataValues]  WITH CHECK ADD  CONSTRAINT [FK_DataValues_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[DataValues] CHECK CONSTRAINT [FK_DataValues_UpdatedByUserId]
GO
ALTER TABLE [dbo].[DataValuesAudit]  WITH CHECK ADD  CONSTRAINT [FK_DataValuesAudit_DataValueId] FOREIGN KEY([DataValueId])
REFERENCES [dbo].[DataValues] ([Id])
GO
ALTER TABLE [dbo].[DataValuesAudit] CHECK CONSTRAINT [FK_DataValuesAudit_DataValueId]
GO
ALTER TABLE [dbo].[IndicatorChartTypes]  WITH CHECK ADD  CONSTRAINT [FK_IndicatorChartTypes_IndicatorId] FOREIGN KEY([IndicatorId])
REFERENCES [dbo].[Indicators] ([Id])
GO
ALTER TABLE [dbo].[IndicatorChartTypes] CHECK CONSTRAINT [FK_IndicatorChartTypes_IndicatorId]
GO
ALTER TABLE [dbo].[Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Indicators_CreatedByUserId] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Indicators] CHECK CONSTRAINT [FK_Indicators_CreatedByUserId]
GO
ALTER TABLE [dbo].[Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Indicators_DeletedByUserId] FOREIGN KEY([DeletedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Indicators] CHECK CONSTRAINT [FK_Indicators_DeletedByUserId]
GO
ALTER TABLE [dbo].[Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Indicators_ParentId] FOREIGN KEY([ParentId])
REFERENCES [dbo].[Indicators] ([Id])
GO
ALTER TABLE [dbo].[Indicators] CHECK CONSTRAINT [FK_Indicators_ParentId]
GO
ALTER TABLE [dbo].[Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Indicators_UniteId] FOREIGN KEY([UniteId])
REFERENCES [dbo].[Unites] ([Id])
GO
ALTER TABLE [dbo].[Indicators] CHECK CONSTRAINT [FK_Indicators_UniteId]
GO
ALTER TABLE [dbo].[Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Indicators_UpdatedByUserId] FOREIGN KEY([UpdatedByUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Indicators] CHECK CONSTRAINT [FK_Indicators_UpdatedByUserId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_ParentId] FOREIGN KEY([ParentId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_ParentId]
GO
ALTER TABLE [dbo].[RefreshTokens]  WITH CHECK ADD  CONSTRAINT [FK_RefreshTokens_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RefreshTokens] CHECK CONSTRAINT [FK_RefreshTokens_Users]
GO
/****** Object:  StoredProcedure [dbo].[CreateRefreshToken]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create
CREATE   PROCEDURE [dbo].[CreateRefreshToken]
    @Id UNIQUEIDENTIFIER,
    @UserId INT,
    @TokenHash NVARCHAR(256),
    @JwtId UNIQUEIDENTIFIER,
    @ExpiresAt DATETIME2,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO RefreshTokens (Id, UserId, TokenHash, JwtId, ExpiresAt)
        VALUES (@Id, @UserId, @TokenHash, @JwtId, @ExpiresAt);
        SET @OutputMessage = 'Refresh token created.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[CreateUser]
    @Username NVARCHAR(100),
    @PasswordHash NVARCHAR(255),
    @Role NVARCHAR(20),
    @Departments NVARCHAR(255) = NULL,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        SET @OutputMessage = 'Error: Username already exists.';
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Role, Departments)
    VALUES (@Username, @PasswordHash, @Role, @Departments);

    SET @OutputMessage = 'User created successfully.';
END
GO
/****** Object:  StoredProcedure [dbo].[GetDropDownOptions]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetDropDownOptions]
(
  @UserId    INT = NULL,
  @Dropdown  NVARCHAR(100) = NULL,
  @ParentIds dbo.IntList READONLY        -- ✅ no default
)
AS
BEGIN
  SET NOCOUNT ON;

  IF @Dropdown = N'Departments'
  BEGIN
      SELECT id AS Value, name AS Label
      FROM dbo.departments;
      RETURN;
  END;

  IF @Dropdown = N'SubDepartments'
  BEGIN
      IF EXISTS (SELECT 1 FROM @ParentIds)
      BEGIN
          SELECT id AS Value, name AS Label
          FROM dbo.departments
          WHERE parentid IN (SELECT Id FROM @ParentIds);
          RETURN;
      END;

      SELECT id AS Value, name AS Label
      FROM dbo.departments;
      RETURN;
  END;
END;

GO
/****** Object:  StoredProcedure [dbo].[GetProductsAndDepartments]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetProductsAndDepartments]
  @DepartmentId INT = NULL,
  @UserId INT=Null
AS
BEGIN
  SET NOCOUNT ON;

  -- Result set 1
  SELECT Id, Name, Price, DepartmentId
  FROM Products
  WHERE (@DepartmentId IS NULL OR DepartmentId = @DepartmentId)

  -- Result set 2
  SELECT Id, Name FROM Departments
  WHERE (@DepartmentId IS NULL OR Id = @DepartmentId);
END
GO
/****** Object:  StoredProcedure [dbo].[GetRefreshTokenByHash]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Get by hash
CREATE   PROCEDURE [dbo].[GetRefreshTokenByHash]
    @TokenHash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 *
    FROM RefreshTokens
    WHERE TokenHash = @TokenHash;
END
GO
/****** Object:  StoredProcedure [dbo].[GetUserById]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Username,  PasswordHash, Role
    FROM Users
    WHERE Id = @UserId;
END;


GO
/****** Object:  StoredProcedure [dbo].[GetUserByUsername]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        u.Id,
        u.Username,
        u.PasswordHash,
		U.role AS Role,
		U.Departments

    FROM dbo.Users u
    WHERE u.Username = @Username;
END
GO
/****** Object:  StoredProcedure [dbo].[GetUsers]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUsers]
	@UserId INT=NULL
AS
BEGIN
	SELECT U.id AS Id,U.Username AS Username,U.role AS Role,D.name AS Departments  FROM dbo.users u INNER JOIN 
	dbo.Departments d ON u.Departments=d.Id
END
GO
/****** Object:  StoredProcedure [dbo].[InsertErrorLog]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------- Insert proc (used by logger) ---------- */
CREATE   PROCEDURE [dbo].[InsertErrorLog]
    @Operation     NVARCHAR(50)  = NULL,
    @ProcedureName NVARCHAR(255) = NULL,
    @Parameters    NVARCHAR(MAX) = NULL,
    @Message       NVARCHAR(MAX) = NULL,
    @StackTrace    NVARCHAR(MAX) = NULL,
    @UserName      NVARCHAR(256) = NULL,
    @RequestPath   NVARCHAR(512) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT dbo.ErrorLogs(Operation, ProcedureName, Parameters, Message, StackTrace, UserName, RequestPath)
        VALUES (@Operation, @ProcedureName, @Parameters, @Message, @StackTrace, @UserName, @RequestPath);
    END TRY
    BEGIN CATCH
        -- swallow to avoid recursive failure
        RETURN;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[InsertIndicatorsBulk]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[InsertIndicatorsBulk]
    @Items dbo.IndicatorTableType READONLY,
	  @UserId INT=NULL,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Indicators (Name, DepartmentId, Value, EffectiveDate, CreatedBy)
        SELECT Name, DepartmentId, Value, EffectiveDate, CreatedBy
        FROM @Items;

        DECLARE @rows INT = @@ROWCOUNT;
        SET @OutputMessage = CONCAT('Inserted ', @rows, ' indicator(s).');
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[InsertProduct]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[InsertProduct]
    @Name          NVARCHAR(100),
    @Price         DECIMAL(18,2),
    @DepartmentId  INT,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DepartmentId IS NULL
    BEGIN
        SET @OutputMessage = N'Error: DepartmentId is required.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Id = @DepartmentId)
    BEGIN
        SET @OutputMessage = N'Error: Department not found.';
        RETURN;
    END

    BEGIN TRY
        INSERT dbo.Products (Name, Price, DepartmentId)
        VALUES (@Name, @Price, @DepartmentId);

        SET @OutputMessage = N'Product inserted successfully.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[PurgeOldErrorLogs]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PurgeOldErrorLogs]
AS
BEGIN
  -- Your logic here, e.g.:
  DELETE FROM ErrorLogs
  WHERE Loggedat < DATEADD(DAY, -30, GETDATE());
END;
GO
/****** Object:  StoredProcedure [dbo].[RevokeAllRefreshTokensForUser]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Revoke ALL refresh tokens for a user (optional but recommended)
CREATE   PROCEDURE [dbo].[RevokeAllRefreshTokensForUser]
    @UserId INT,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.RefreshTokens
        SET RevokedAt = SYSUTCDATETIME()
        WHERE UserId = @UserId AND RevokedAt IS NULL;

        SET @OutputMessage = N'All refresh tokens revoked for user.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[RevokeRefreshToken]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Revoke (optionally link replacement)
CREATE   PROCEDURE [dbo].[RevokeRefreshToken]
    @Id UNIQUEIDENTIFIER,
    @ReplacedByTokenId UNIQUEIDENTIFIER = NULL,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE RefreshTokens
        SET RevokedAt = SYSUTCDATETIME(),
            ReplacedByTokenId = @ReplacedByTokenId
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @OutputMessage = 'Error: refresh token not found.';
            RETURN;
        END

        SET @OutputMessage = 'Refresh token revoked.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Update password hash for a user
CREATE   PROCEDURE [dbo].[UpdateUserPassword]
    @Id INT,
    @PasswordHash NVARCHAR(255),
    @OutputMessage NVARCHAR(4000) OUTPUT,
	@UserId INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @Id)
        BEGIN
            SET @OutputMessage = N'Error: User not found.';
            RETURN;
        END

        UPDATE dbo.Users
        SET PasswordHash = @PasswordHash
        WHERE Id = @Id;

        SET @OutputMessage = N'Password changed successfully.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[Users_GetById]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[Users_GetById]
@Id  INT,
@UserId INT
AS
BEGIN
SELECT u.id,username,role,u.Departments AS Departments FROM dbo.Users u INNER JOIN dbo.Departments d ON U.Departments = d.Id 
WHERE u.id=@Id
end 
GO
/****** Object:  StoredProcedure [dbo].[Users_Insert]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Users_Insert]
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Role NVARCHAR(50),
    @Department INT,
	@UserId INT=NULL ,
	@OutputMessage NVARCHAR(MAX) output
AS
BEGIN
    -- Insert user
    -- Then insert multiple departments
    INSERT INTO users (username,PasswordHash,Role,Departments)
	VALUES (@Username,@Password,@Role,@Department)

SET @OutputMessage='record inserted successfully'
END
GO
/****** Object:  StoredProcedure [dbo].[Users_Update]    Script Date: 8/31/2025 3:47:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Users_Update]
  @Username NVARCHAR(50),
  @Password NVARCHAR(100)=NULL,
  @Role NVARCHAR(50),
  @Departments INT,                -- ← plural
  @UserId INT = NULL,
  @OutputMessage NVARCHAR(MAX) OUTPUT,
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;
  IF @Password IS NULL OR @Password='' 
  BEGIN 
    UPDATE dbo.Users
  SET Username     = @Username,
          Role         = @Role,
      Departments  = @Departments
  WHERE Id = @Id;
  END

  ELSE
  begin

  UPDATE dbo.Users
  SET Username     = @Username,
      PasswordHash = @Password,
      Role         = @Role,
      Departments  = @Departments
  WHERE Id = @Id;
  END 

  SET @OutputMessage = 'record updated successfully';
END
GO
USE [master]
GO
ALTER DATABASE [PIKUDashboard] SET  READ_WRITE 
GO
