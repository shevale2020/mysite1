USE [master]
GO
/****** Object:  Database [AMS]    Script Date: 4/27/2019 9:14:28 AM ******/
CREATE DATABASE [AMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS01\MSSQL\DATA\AMS.mdf' , SIZE = 5184KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'AMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS01\MSSQL\DATA\AMS_log.ldf' , SIZE = 2624KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [AMS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AMS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AMS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AMS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AMS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AMS] SET ARITHABORT OFF 
GO
ALTER DATABASE [AMS] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [AMS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AMS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AMS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AMS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AMS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AMS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AMS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AMS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AMS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [AMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AMS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AMS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AMS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AMS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AMS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AMS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AMS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [AMS] SET  MULTI_USER 
GO
ALTER DATABASE [AMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AMS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [AMS] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AMS] SET QUERY_STORE = OFF
GO
USE [AMS]
GO
/****** Object:  UserDefinedFunction [dbo].[LogOutTime]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create FUNCTION [dbo].[LogOutTime](@TransectionId int )  
RETURNS int   
AS   
-- Returns the stock level for the product.  
BEGIN  
   Declare @UserName Varchar(100) 
   Declare @LoginDate Date 
   Declare @OutTime Time(7) 
   Declare @InTime Time (7)
   
   select @UserName = UserName, @LoginDate= LoginDate, @OutTime=LogoutTime from Transection where TransectionId=@TransectionId

 set   @InTime = (select top 1  LogoutTime
								from Transection where UserName =@UserName
								 and LogoutTime > @OutTime 
								 and LoginDate =@LoginDate 
								 and [Event]='OnSessionChange'
								order by LogoutTime	
				  )
				   
   return datediff(SECOND,@OutTime,@InTime)

END


GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split](@String nvarchar(MAX), @Delimiter char(1))       
	Returns @temptable TABLE (items nvarchar(MAX))       
	as       
	BEGIN       
		DECLARE @idx int       
		DECLARE @slice nvarchar(max)       

		SELECT @idx = 1       
		if len(@String)<1 or @String is null  return       

		while @idx!= 0       
		BEGIN       
		set @idx = charindex(@Delimiter,@String)       
		if @idx!=0       
		set @slice = left(@String,@idx - 1)       
		else       
		set @slice = @String       

		if(len(@slice)>0)  
		insert into @temptable(Items) values(@slice)       

		set @String = right(@String,len(@String) - @idx)       
		if len(@String) = 0 break       
		end   
		return       
end

GO
/****** Object:  UserDefinedFunction [dbo].[ExplodeDates]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ExplodeDates](@startdate datetime, @enddate datetime)
returns table as
return (
with 
 N0 as (SELECT 1 as n UNION ALL SELECT 1)
,N1 as (SELECT 1 as n FROM N0 t1, N0 t2)
,N2 as (SELECT 1 as n FROM N1 t1, N1 t2)
,N3 as (SELECT 1 as n FROM N2 t1, N2 t2)
,N4 as (SELECT 1 as n FROM N3 t1, N3 t2)
,N5 as (SELECT 1 as n FROM N4 t1, N4 t2)
,N6 as (SELECT 1 as n FROM N5 t1, N5 t2)
,nums as (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as num FROM N6)
SELECT DATEADD(day,num-1,@startdate) as thedate
FROM nums
WHERE num <= DATEDIFF(day,@startdate,@enddate) + 1
);

GO
/****** Object:  Table [dbo].[IdleReason]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdleReason](
	[IdleReasonId] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NOT NULL,
	[LoginDate] [date] NULL,
	[IdleFromTime] [time](7) NULL,
	[IdleToTime] [time](7) NULL,
	[TotalIdleHours] [numeric](4, 2) NULL,
	[IdleReason] [varchar](500) NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_IdleReason] PRIMARY KEY CLUSTERED 
(
	[IdleReasonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocationMaster]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocationMaster](
	[LocationMasterID] [int] IDENTITY(1,1) NOT NULL,
	[LocationName] [nvarchar](500) NOT NULL,
	[ContraryPID] [int] NOT NULL,
	[Description] [varchar](100) NULL,
	[IsEnabled] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_LocationMaster] PRIMARY KEY CLUSTERED 
(
	[LocationMasterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LunchTimeMaster]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LunchTimeMaster](
	[LunchTimeMasterID] [int] IDENTITY(1,1) NOT NULL,
	[LocationMasterID] [int] NOT NULL,
	[LunchTimeFrom] [time](7) NOT NULL,
	[LunchTimeTo] [time](7) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[SSTime] [time](7) NULL,
	[SETime] [time](7) NULL,
	[ShiftID] [int] NULL,
 CONSTRAINT [PK_LunchTimeMaster] PRIMARY KEY CLUSTERED 
(
	[LunchTimeMasterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PickListHeader]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PickListHeader](
	[PicklistID] [int] IDENTITY(1,1) NOT NULL,
	[PicklistName] [nvarchar](500) NOT NULL,
	[Description] [varchar](100) NULL,
	[IsEnabled] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_PickListHeader] PRIMARY KEY CLUSTERED 
(
	[PicklistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PickListValue]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PickListValue](
	[PicklistValueID] [int] IDENTITY(1,1) NOT NULL,
	[PicklistValueName] [nvarchar](max) NOT NULL,
	[PicklistValueCode] [varchar](20) NULL,
	[PicklistID] [int] NULL,
	[Description] [varchar](500) NULL,
	[IsEnabled] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_PickListValue] PRIMARY KEY CLUSTERED 
(
	[PicklistValueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[StaffID] [int] IDENTITY(1,1) NOT NULL,
	[StaffName] [nvarchar](100) NULL,
	[DesignationPID] [int] NULL,
	[SectionPID] [int] NULL,
	[LocationMasterID] [int] NULL,
	[Qualification] [nvarchar](100) NULL,
	[MobileNo] [nvarchar](25) NULL,
	[Address] [nvarchar](200) NULL,
	[DOB] [date] NULL,
	[JoiniongDate] [date] NULL,
	[EmailID] [nvarchar](100) NULL,
	[Photo] [image] NULL,
	[IsActive] [bit] NULL,
	[ResignDate] [date] NULL,
	[ResignReason] [nvarchar](300) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[ModifiedOn] [datetime] NOT NULL,
	[StaffUserName] [nvarchar](100) NULL,
	[StaffPassword] [nvarchar](100) NULL,
	[FStaffName] [nvarchar](100) NULL,
	[EMobileNo] [nvarchar](25) NULL,
	[Gender] [nvarchar](4) NULL,
	[PAN] [nvarchar](10) NULL,
	[SSN] [nvarchar](10) NULL,
	[AadharNo] [nvarchar](10) NULL,
	[EIdealTime] [nvarchar](5) NULL,
	[OFCLoc] [nvarchar](50) NULL,
	[OFCTime] [nvarchar](4) NULL,
	[WOff] [nvarchar](50) NULL,
	[EMPType] [nvarchar](50) NULL,
	[Role] [nvarchar](50) NULL,
 CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transection]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transection](
	[TransectionId] [int] IDENTITY(1,1) NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[UserName] [varchar](50) NULL,
	[LoginTime] [time](7) NULL,
	[LogoutTime] [time](7) NULL,
	[LoginDate] [date] NULL,
	[TotalHours] [numeric](4, 2) NULL,
	[Event] [varchar](50) NULL,
	[Reason] [varchar](500) NULL,
	[IsManual] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Transection] PRIMARY KEY CLUSTERED 
(
	[TransectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NULL,
	[Passward] [nvarchar](50) NULL,
	[FullName] [varchar](100) NULL,
	[StaffID] [int] NULL,
	[IsAdmin] [bit] NULL,
	[IsEnabled] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[Role] [nchar](10) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[LocationMaster] ON 

INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1042, N'Pune', 1, N'Development office', 1, 1, CAST(N'2019-03-05T00:11:00.163' AS DateTime), 1, CAST(N'2019-03-05T00:11:00.163' AS DateTime))
INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1043, N'Mohali', 1, N'Offshore Team', 1, 1, CAST(N'2019-03-05T00:11:36.257' AS DateTime), 1, CAST(N'2019-03-05T00:11:36.257' AS DateTime))
INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1045, N'Mumbai', 1, N'Test', 1, 1, CAST(N'2019-03-06T09:17:54.647' AS DateTime), 1, CAST(N'2019-03-06T09:17:54.647' AS DateTime))
INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1046, N'New york', 8, N'sales office', 1, 1, CAST(N'2019-04-08T16:45:36.343' AS DateTime), 1, CAST(N'2019-04-08T16:45:36.343' AS DateTime))
INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1047, N'B1', 11, N'sales office', 1, 1, CAST(N'2019-04-12T13:09:33.170' AS DateTime), 1, CAST(N'2019-04-12T13:09:33.170' AS DateTime))
INSERT [dbo].[LocationMaster] ([LocationMasterID], [LocationName], [ContraryPID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1048, N'Nagpur', 1, N'Sales office', 1, 1, CAST(N'2019-04-15T13:59:22.497' AS DateTime), 1, CAST(N'2019-04-15T13:59:22.497' AS DateTime))
SET IDENTITY_INSERT [dbo].[LocationMaster] OFF
SET IDENTITY_INSERT [dbo].[LunchTimeMaster] ON 

INSERT [dbo].[LunchTimeMaster] ([LunchTimeMasterID], [LocationMasterID], [LunchTimeFrom], [LunchTimeTo], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [SSTime], [SETime], [ShiftID]) VALUES (1, 1042, CAST(N'01:03:00' AS Time), CAST(N'13:03:00' AS Time), 1, CAST(N'2019-03-06T21:42:15.930' AS DateTime), 1, CAST(N'2019-03-06T21:42:15.930' AS DateTime), NULL, NULL, 5)
INSERT [dbo].[LunchTimeMaster] ([LunchTimeMasterID], [LocationMasterID], [LunchTimeFrom], [LunchTimeTo], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [SSTime], [SETime], [ShiftID]) VALUES (2, 1043, CAST(N'06:06:00' AS Time), CAST(N'05:05:00' AS Time), 1, CAST(N'2019-03-06T21:53:16.900' AS DateTime), 1, CAST(N'2019-03-06T21:53:16.900' AS DateTime), NULL, NULL, 5)
INSERT [dbo].[LunchTimeMaster] ([LunchTimeMasterID], [LocationMasterID], [LunchTimeFrom], [LunchTimeTo], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [SSTime], [SETime], [ShiftID]) VALUES (3, 1046, CAST(N'03:03:00' AS Time), CAST(N'08:04:00' AS Time), 1, CAST(N'2019-04-08T16:46:13.203' AS DateTime), 1, CAST(N'2019-04-08T16:46:13.203' AS DateTime), NULL, NULL, 5)
INSERT [dbo].[LunchTimeMaster] ([LunchTimeMasterID], [LocationMasterID], [LunchTimeFrom], [LunchTimeTo], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [SSTime], [SETime], [ShiftID]) VALUES (4, 1048, CAST(N'23:59:00' AS Time), CAST(N'12:58:00' AS Time), 1, CAST(N'2019-04-15T14:00:42.227' AS DateTime), 1, CAST(N'2019-04-15T14:00:42.227' AS DateTime), NULL, NULL, 5)
INSERT [dbo].[LunchTimeMaster] ([LunchTimeMasterID], [LocationMasterID], [LunchTimeFrom], [LunchTimeTo], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [SSTime], [SETime], [ShiftID]) VALUES (5, 1043, CAST(N'12:59:00' AS Time), CAST(N'12:59:00' AS Time), 1, CAST(N'2019-04-27T08:05:34.460' AS DateTime), 1, CAST(N'2019-04-27T08:05:34.460' AS DateTime), NULL, NULL, 5)
SET IDENTITY_INSERT [dbo].[LunchTimeMaster] OFF
SET IDENTITY_INSERT [dbo].[PickListHeader] ON 

INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (3, N'Section', N'Section', 1, 1, CAST(N'2001-01-01T00:00:00.000' AS DateTime), 1, CAST(N'2001-01-01T00:00:00.000' AS DateTime))
INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (4, N'Designation', N'Designation', 1, 1, CAST(N'2001-01-01T00:00:00.000' AS DateTime), 1, CAST(N'2001-01-01T00:00:00.000' AS DateTime))
INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (5, N'Country', N'List of Country', 1, 1, CAST(N'2019-01-12T17:13:19.160' AS DateTime), 1, CAST(N'2019-01-12T17:13:19.160' AS DateTime))
INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (6, N'LunchTime', N'Lunch Time Detils', 1, 1, CAST(N'2019-02-23T13:29:15.937' AS DateTime), 1, CAST(N'2019-02-23T13:29:15.937' AS DateTime))
INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (7, N'Country', N'This Category will add the Country.', 1, 1, CAST(N'2019-03-04T22:11:42.470' AS DateTime), 1, CAST(N'2019-03-04T22:11:42.470' AS DateTime))
INSERT [dbo].[PickListHeader] ([PicklistID], [PicklistName], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (8, N'Shift Time', N'This Category will add the shift', 1, 1, CAST(N'2019-03-06T11:25:23.580' AS DateTime), 1, CAST(N'2019-03-06T11:25:23.580' AS DateTime))
SET IDENTITY_INSERT [dbo].[PickListHeader] OFF
SET IDENTITY_INSERT [dbo].[PickListValue] ON 

INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1, N'India', N'01', 7, N'India Offices', 1, 1, CAST(N'2019-03-05T00:10:30.997' AS DateTime), 1, CAST(N'2019-03-05T00:10:30.997' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (2, N'Developer', N'01', 4, N'IT Dev', 1, 1, CAST(N'2019-03-05T00:20:45.427' AS DateTime), 1, CAST(N'2019-03-05T00:20:45.427' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (3, N'IT Team', N'01', 3, N'IT Dept', 1, 1, CAST(N'2019-03-05T00:21:45.047' AS DateTime), 1, CAST(N'2019-03-05T00:21:45.047' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (4, N'Canada', N'01', 7, N'Head Office', 1, 1, CAST(N'2019-03-05T00:42:10.037' AS DateTime), 1, CAST(N'2019-03-05T00:42:10.037' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (5, N'6PM to 4AM (Winters)', N'01', 8, N'Canada Shift', 1, 1, CAST(N'2019-03-06T11:26:25.507' AS DateTime), 1, CAST(N'2019-03-06T11:26:25.507' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (6, N'5PM to 3AM (Summers)', N'02', 8, N'Summers', 1, 1, CAST(N'2019-03-06T11:57:45.347' AS DateTime), 1, CAST(N'2019-03-06T11:57:45.347' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (7, N'USA', N'002', 5, N'USA', 1, 1, CAST(N'2019-04-08T16:43:57.430' AS DateTime), 1, CAST(N'2019-04-08T16:43:57.430' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (8, N'USA', N'007', 7, N'Development Office', 1, 1, CAST(N'2019-04-08T16:44:57.093' AS DateTime), 1, CAST(N'2019-04-08T16:44:57.093' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (9, N'4PM to 3AM (Winters)', N'3323', 8, N'USA', 1, 1, CAST(N'2019-04-08T16:47:19.623' AS DateTime), 1, CAST(N'2019-04-08T16:47:19.623' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (10, N'China', N'001', 5, N'Test', 1, 1, CAST(N'2019-04-12T13:06:20.773' AS DateTime), 1, CAST(N'2019-04-12T13:06:20.773' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (11, N'China', N'001', 7, N'Sales ofice', 1, 1, CAST(N'2019-04-12T13:08:42.457' AS DateTime), 1, CAST(N'2019-04-12T13:08:42.457' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (12, N'Sales', N'0013', 3, N'Sales Team', 1, 1, CAST(N'2019-04-15T12:51:12.290' AS DateTime), 1, CAST(N'2019-04-15T12:51:12.290' AS DateTime))
INSERT [dbo].[PickListValue] ([PicklistValueID], [PicklistValueName], [PicklistValueCode], [PicklistID], [Description], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (13, N'Test Engg.', N'10001', 4, N'Qa', 1, 1, CAST(N'2019-04-15T12:52:30.663' AS DateTime), 1, CAST(N'2019-04-15T12:52:30.663' AS DateTime))
SET IDENTITY_INSERT [dbo].[PickListValue] OFF
SET IDENTITY_INSERT [dbo].[Transection] ON 

INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1, N'7f8bccd5-c2ac-4723-9ede-f755584f2f3b', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:12:40.8807792' AS Time), CAST(N'07:12:41.1077794' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'ddd', 0, 1, CAST(N'2019-04-12T13:31:43.457' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.457' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (2, N'6d891b17-8d17-4125-9f8a-cbafaec1ac31', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:13:33.1968652' AS Time), CAST(N'07:13:33.8808634' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'fjdsfhsdf', 0, 1, CAST(N'2019-04-12T13:31:43.473' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.473' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (3, N'ba2630e1-e9ae-4523-8d3f-a7c55b8a6996', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:14:07.6210450' AS Time), CAST(N'07:14:08.4660435' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'te', 0, 1, CAST(N'2019-04-12T13:31:43.473' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.473' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (4, N'0cc8e0e0-89c6-4bfb-8c45-ec605239aecd', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:18:23.8236573' AS Time), CAST(N'07:18:24.4636498' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'test', 0, 1, CAST(N'2019-04-12T13:31:43.473' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.473' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (5, N'7702aed2-0408-418b-8055-277023ee86db', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:20:27.9432651' AS Time), CAST(N'07:20:28.6832667' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'tttt', 0, 1, CAST(N'2019-04-12T13:31:43.487' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.487' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (6, N'2e1ae01c-7ccc-4223-9aeb-66734da94512', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'07:27:33.7899473' AS Time), CAST(N'07:27:34.5769519' AS Time), CAST(N'2019-03-31' AS Date), NULL, N'IdleTime', N'tttt', 0, 1, CAST(N'2019-04-12T13:31:43.487' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.487' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (7, N'94ae5c51-13fb-4ff9-b4b9-fef54f4f04c9', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'12:57:43.0196816' AS Time), CAST(N'13:21:54.5359282' AS Time), CAST(N'2019-04-12' AS Date), NULL, N'OnStart', N'', 0, 1, CAST(N'2019-04-12T13:31:43.487' AS DateTime), 2, CAST(N'2019-04-12T13:31:43.487' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (8, N'b40c196c-b0d3-499b-acaf-feccd67e8805', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'12:57:43.0196816' AS Time), CAST(N'13:33:24.2767472' AS Time), CAST(N'2019-04-12' AS Date), NULL, N'OnSessionChange', N'SessionLock', 0, 1, CAST(N'2019-04-12T13:41:40.950' AS DateTime), 2, CAST(N'2019-04-12T13:41:40.950' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (9, N'184beaef-076d-48ae-8c3a-e672f3dad63f', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'12:57:43.0196816' AS Time), CAST(N'13:33:52.0052728' AS Time), CAST(N'2019-04-12' AS Date), NULL, N'OnSessionChange', N'SessionUnlock', 0, 1, CAST(N'2019-04-12T13:41:40.950' AS DateTime), 2, CAST(N'2019-04-12T13:41:40.950' AS DateTime))
INSERT [dbo].[Transection] ([TransectionId], [ClientGuid], [UserName], [LoginTime], [LogoutTime], [LoginDate], [TotalHours], [Event], [Reason], [IsManual], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (10, N'9cb2d176-e6c5-46a9-8ada-eab241a3dec1', N'DESKTOP-L42NJP8\Narayan Sultane', CAST(N'13:52:11.5484451' AS Time), CAST(N'13:52:12.5101837' AS Time), CAST(N'2019-04-12' AS Date), NULL, N'IdleTime', N'outside office', 0, 1, CAST(N'2019-04-12T14:01:40.950' AS DateTime), 2, CAST(N'2019-04-12T14:01:40.950' AS DateTime))
SET IDENTITY_INSERT [dbo].[Transection] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (1, N'12345', N'12345', N'Sultane Narayan1', 1, 0, 1, 1, CAST(N'2019-02-05T12:20:56.257' AS DateTime), 1, CAST(N'2019-04-18T13:29:05.537' AS DateTime), N'M         ')
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (2, N'Dhairyashil Shevale', N'15', N'Dhairyashil Shevale', 2, 0, 1, 1, CAST(N'2019-02-19T23:11:00.027' AS DateTime), 1, CAST(N'2019-02-19T23:11:00.027' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (3, N'Prashant C', N'2', N'Prashant C', 3, 0, 1, 1, CAST(N'2019-03-06T09:10:15.803' AS DateTime), 1, CAST(N'2019-03-06T09:10:16.003' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (4, N'Admin', N'Admin', N'SuperAdmin', 4, 1, 1, 123, CAST(N'2019-03-06T11:29:39.113' AS DateTime), 123, CAST(N'2019-03-06T11:29:39.113' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (5, N'12345', N'12345', N'Sultane Narayan1', 1, 0, 1, 1, CAST(N'2019-02-05T12:20:56.257' AS DateTime), 1, CAST(N'2019-04-18T13:29:05.537' AS DateTime), N'M         ')
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (6, N'Dhairyashil Shevale', N'15', N'Dhairyashil Shevale', 2, 0, 1, 1, CAST(N'2019-02-19T23:11:00.027' AS DateTime), 1, CAST(N'2019-02-19T23:11:00.027' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (7, N'Prashant C', N'2', N'Prashant C', 3, 0, 1, 1, CAST(N'2019-03-06T09:10:15.803' AS DateTime), 1, CAST(N'2019-03-06T09:10:16.003' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (8, N'ABC', NULL, N'ABC', 4, 0, 1, 123, CAST(N'2019-03-06T11:29:39.113' AS DateTime), 123, CAST(N'2019-03-06T11:29:39.113' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [UserName], [Passward], [FullName], [StaffID], [IsAdmin], [IsEnabled], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [Role]) VALUES (12, N'12345678', N'sfsdf', N'Narayan Sultnae4', 5, 1, 1, 1, CAST(N'2019-04-19T13:32:39.377' AS DateTime), 1, CAST(N'2019-04-19T13:32:39.377' AS DateTime), N'A         ')
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[LunchTimeMaster]  WITH CHECK ADD  CONSTRAINT [FK_LunchTimeMaster_LocationMaster] FOREIGN KEY([LocationMasterID])
REFERENCES [dbo].[LocationMaster] ([LocationMasterID])
GO
ALTER TABLE [dbo].[LunchTimeMaster] CHECK CONSTRAINT [FK_LunchTimeMaster_LocationMaster]
GO
ALTER TABLE [dbo].[PickListValue]  WITH CHECK ADD  CONSTRAINT [FK_PickListValue_PickListHeader] FOREIGN KEY([PicklistID])
REFERENCES [dbo].[PickListHeader] ([PicklistID])
GO
ALTER TABLE [dbo].[PickListValue] CHECK CONSTRAINT [FK_PickListValue_PickListHeader]
GO
ALTER TABLE [dbo].[Staff]  WITH CHECK ADD  CONSTRAINT [FK_Staff_LocationMaster] FOREIGN KEY([LocationMasterID])
REFERENCES [dbo].[LocationMaster] ([LocationMasterID])
GO
ALTER TABLE [dbo].[Staff] CHECK CONSTRAINT [FK_Staff_LocationMaster]
GO
/****** Object:  StoredProcedure [dbo].[GetEmployeeSessionDetail]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[GetEmployeeSessionDetail]
@ContraryPID int, 
@LocationID int,
@StaffID int,
@FromDate Date,
@ToDate date
as
Begin

select 
	  [StaffID]
      ,[UserName]
      ,[InTime]
      ,[OutTime]
	  ,(TotalWorkingTime-(IdelTime+LogOutTime)) AS [NetWorkingTime]
      ,[TotalWorkingTime]
      ,[IdelTime]
      ,[LogOutTime]
      ,[LoginDate]
      ,[ContraryName]
      ,[LocationName]
      ,[Designation]
      ,[ShiftTime]
      ,[DepartmentName]
      ,[LocationMasterId]
	  ,SectionPID
	  ,ContraryPID
	  from (
select 
	   [StaffID]
      ,[UserName]
      ,Min([InTime]) as InTime
      ,Max([OutTime]) as OutTime
	  ,datediff(MI,Min([InTime]),Max([OutTime]) ) as [TotalWorkingTime]
	  ,sum(case when [Event]='IdleTime' then  datediff(MI,[InTime],[OutTime] )  else 0 end)  as IdelTime
	  ,sum ( case when  [OldEvent]='OnSessionChange'  and [OutTime] is not null then dbo.LogOutTime(TransectionId) else 0 end )/60 as LogOutTime
      ,[LoginDate]
      ,[ContraryName]
      ,[LocationName]
      ,[Designation]
      ,[ShiftTime]
      ,[DepartmentName]
      ,[LocationMasterId]
	  ,SectionPID
	  ,ContraryPID
 
 from (
select 
      t.TransectionId
	  ,s.StaffID
      ,isnull(s.StaffName,[UserName]) as [UserName]
	  ,case when ([Event]='OnStart') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLogon')  then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionUnlock')  then [LogoutTime] 
			when ([Event]='IdleTime')  then [LoginTime] 
            Else null
	   End as InTime
      ,case when ([Event]='OnSessionChange' and   [Reason] ='SessionLogoff') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLock')  then [LogoutTime] 
			when ([Event]='IdleTime' )  then [LogoutTime] 
            Else null
	   End as OutTime
      ,[LoginDate]
	  ,Case when [Event]='OnSessionChange' Then Reason else [Event] end  as [Event]
	  ,[Event] as OldEvent
	  ,pv1.PicklistValueName as ContraryName
	  ,l.LocationName
	  ,pv.PicklistValueName as Designation
	  ,pv2.PicklistValueName as  ShiftTime
	  ,pv2.PicklistValueName as  DepartmentName
	  ,s.OFCLoc as LocationMasterId
	  ,s.SectionPID
	  ,l.ContraryPID
     from Transection t 
	 left join [Staff] s on s.StaffUserName = t.UserName
	 left join LocationMaster l on l.LocationMasterID= s.OFCLoc
	 left join PickListValue pv on pv.PicklistValueID= s.DesignationPID
	 left join PickListValue pv1 on pv1.PicklistValueID= l.ContraryPID
	 left join PickListValue pv2 on pv2.PicklistValueID= s.OFCTime
	 left join PickListValue pv3 on pv3.PicklistValueID= s.SectionPID
	 where 
	   t.[LoginDate]  between @FromDate and @ToDate  and
	   isnull( s.OFCLoc,0)  = case when @LocationID=0  then     isnull(s.OFCLoc,0)  else @LocationID end  and 
	     isnull(l.ContraryPID,0)   = case when @ContraryPID=0 then     isnull(l.ContraryPID,0)   else @ContraryPID end  and 
	     isnull(s.SectionPID,0)  = case when @LocationID=0 then     isnull(s.SectionPID,0)  else @LocationID end  
	 ) E

	 group by 
	 [StaffID]
	  ,[UserName]
      ,[LoginDate]
      ,[ContraryName]
      ,[LocationName]
      ,[Designation]
      ,[ShiftTime]
      ,[DepartmentName]
      ,[LocationMasterId]
	  ,SectionPID
	  ,ContraryPID
	  ) S order by LoginDate 
END



GO
/****** Object:  StoredProcedure [dbo].[ManageStudentClassMappingAndAttendanceDetails]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ManageStudentClassMappingAndAttendanceDetails]
	-- Add the parameters for the stored procedure here
	--@StudentPresentDates NVARCHAR(max)=null
	@PresentDays NVARCHAR(max),
	@OutOfExamMarks int=null,
	@OutOfSectionMarks int=null,
	@OutOfDays int=null,
	@BehaviourComment NVARCHAR(max)
	,@AcademicComment NVARCHAR(max)=null
	,@ExamMarks NVARCHAR(max)=null
	,@SectionRating NVARCHAR(max)=null
	,@ClassID INT=null
	,@SemesterID INT=null
	,@AcademicYearID INT=null
	,@SectionID INT=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	declare @tblstudentbcomment table (
		studentID INT
		,Bcomment NVARCHAR(max)
		)

	INSERT INTO @tblstudentbcomment
	SELECT substring(items, 1, charindex('$', items) - 1) AS studentID
		,RIGHT(items, LEN(items) - CHARINDEX('$', items)) AS BComment
	FROM Split(@BehaviourComment, '#')

	UPDATE StudentClassMapping
	SET BehaviourComment = case when TEMP.Bcomment !=' ' then TEMP.Bcomment else BehaviourComment end ,
	CreatedBy=1, CreatedOn=SYSDATETIME(),
	    ModifiedBy=1,ModifiedOn=SYSDATETIME()
	FROM @tblstudentbcomment TEMP
	INNER JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID

	INSERT INTO StudentClassMapping (
		StudentID
		,ClassPID
		,YearPID
		,SemesterID
		,SectionPID
		,SchoolID
		,BehaviourComment
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		)
	SELECT TEMP.studentID
		,@ClassID
		,@AcademicYearID
		,@SemesterID
		,@SectionID
		,STUD.StudentID
		,TEMP.Bcomment
		,1
		,SYSDATETIME()
		,1
		,SYSDATETIME()
	FROM @tblstudentbcomment TEMP
	LEFT JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID
	INNER JOIN Student STUD on STUD.StudentID=TEMP.studentID
	WHERE scm.StudentClassMappingID IS NULL
	
	
	
	declare @tblstudentbcomment1 table (
		studentID INT
		,Acomment NVARCHAR(max)
		)

	INSERT INTO @tblstudentbcomment1
	SELECT substring(items, 1, charindex('$', items) - 1) AS studentID
		,RIGHT(items, LEN(items) - CHARINDEX('$', items)) AS AComment
	FROM Split(@AcademicComment, '#')

	UPDATE StudentClassMapping
	SET AcademicComment = case when TEMP.Acomment !=' ' then TEMP.Acomment else AcademicComment end ,
	CreatedBy=1, CreatedOn=SYSDATETIME(),
	    ModifiedBy=1,ModifiedOn=SYSDATETIME()
	FROM @tblstudentbcomment1 TEMP
	INNER JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID

	INSERT INTO StudentClassMapping (
		StudentID
		,ClassPID
		,YearPID
		,SemesterID
		,SectionPID
		,SchoolID
		,BehaviourComment
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		)
	SELECT TEMP.studentID
		,@ClassID
		,@AcademicYearID
		,@SemesterID
		,@SectionID
		,STUD.StudentID
		,TEMP.Acomment
		,1
		,SYSDATETIME()
		,1
		,SYSDATETIME()
	FROM @tblstudentbcomment1 TEMP
	LEFT JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID
	INNER JOIN Student STUD on STUD.StudentID=TEMP.studentID
	WHERE scm.StudentClassMappingID IS NULL
	
	
	declare @tblstudentbcomment2 table (
		studentID INT
		,ExamMarkss NVARCHAR(max)
		)

	INSERT INTO @tblstudentbcomment2
	SELECT substring(items, 1, charindex('$', items) - 1) AS studentID
		,RIGHT(items, LEN(items) - CHARINDEX('$', items)) AS ExamMarkss
	FROM Split(@ExamMarks, '#')

	UPDATE StudentClassMapping
	SET ExamMarks = case when TEMP.ExamMarkss !=' ' then TEMP.ExamMarkss else ExamMarks end ,
	CreatedBy=1, CreatedOn=SYSDATETIME(),
	    ModifiedBy=1,ModifiedOn=SYSDATETIME()
	FROM @tblstudentbcomment2 TEMP
	INNER JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID =@ClassID
		AND scm.SemesterID = @SemesterID

	INSERT INTO StudentClassMapping (
		StudentID
		,ClassPID
		,YearPID
		,SemesterID
		,SectionPID
		,SchoolID
		,ExamMarks
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		)
	SELECT TEMP.studentID
		,@ClassID
		,@AcademicYearID
		,@SemesterID
		,@SectionID
		,STUD.StudentID
		,TEMP.ExamMarkss
		,1
		,SYSDATETIME()
		,1
		,SYSDATETIME()
	FROM @tblstudentbcomment2 TEMP
	LEFT JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID
	INNER JOIN Student STUD on STUD.StudentID=TEMP.studentID
	WHERE scm.StudentClassMappingID IS NULL
	
	
	
	declare @tblstudentbcomment3 table (
		studentID INT
		,Sectionratingg NVARCHAR(max)
		)

	INSERT INTO @tblstudentbcomment3
	SELECT substring(items, 1, charindex('$', items) - 1) AS studentID
		,RIGHT(items, LEN(items) - CHARINDEX('$', items)) AS SectionRating
	FROM Split(@SectionRating, '#')

	UPDATE StudentClassMapping
	SET SectionRating = case when TEMP.Sectionratingg !=' ' then TEMP.Sectionratingg else SectionRating end ,
	    CreatedBy=1, CreatedOn=SYSDATETIME(),
	    ModifiedBy=1,ModifiedOn=SYSDATETIME()
	FROM @tblstudentbcomment3 TEMP
	INNER JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID =@ClassID
		AND scm.SemesterID = @SemesterID

	INSERT INTO StudentClassMapping (
		StudentID
		,ClassPID
		,YearPID
		,SemesterID
		,SectionPID
		,SchoolID
		,SectionRating
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		)
	SELECT TEMP.studentID
		,@ClassID
		,@AcademicYearID
		,@SemesterID
		,@SectionID
		,STUD.StudentID
		,TEMP.Sectionratingg
		,1
		,SYSDATETIME()
		,1
		,SYSDATETIME()
	FROM @tblstudentbcomment3 TEMP
	LEFT JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID
	INNER JOIN Student STUD on STUD.StudentID=TEMP.studentID
	WHERE scm.StudentClassMappingID IS NULL
	
	
	
	declare @tblstudentbcomment4 table (
		studentID INT
		,PresentDayss int)
		

	INSERT INTO @tblstudentbcomment4
	SELECT substring(items, 1, charindex('$', items) - 1) AS studentID
		,RIGHT(items, LEN(items) - CHARINDEX('$', items)) AS PresentDays
	FROM Split(@PresentDays, '#')

	UPDATE StudentClassMapping
	SET PresentDays = case when TEMP.PresentDayss !=' ' then TEMP.PresentDayss else PresentDays end ,
	    OutOfExamMarks=@OutOfExamMarks,
	    OutOfSectionMarks=@OutOfSectionMarks,
	    OutOfPresentDays=@OutOfDays,
	    CreatedBy=1, CreatedOn=SYSDATETIME(),
	    ModifiedBy=1,ModifiedOn=SYSDATETIME()
	FROM @tblstudentbcomment4 TEMP
	INNER JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID =@ClassID
		AND scm.SemesterID = @SemesterID

	INSERT INTO StudentClassMapping (
		StudentID
		,ClassPID
		,YearPID
		,SemesterID
		,SectionPID
		,SchoolID
		,PresentDays
		,OutOfExamMarks,
		OutOfSectionMarks,
		OutOfPresentDays
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		)
	SELECT TEMP.studentID
		,@ClassID
		,@AcademicYearID
		,@SemesterID
		,@SectionID
		,STUD.StudentID
		,TEMP.PresentDayss
		,@OutOfExamMarks,
	    @OutOfSectionMarks,
	    @OutOfDays
		,1
		,SYSDATETIME()
		,1
		,SYSDATETIME()
	FROM @tblstudentbcomment4 TEMP
	LEFT JOIN StudentClassMapping SCM ON scm.StudentID = TEMP.studentID
		AND scm.SectionPID = @SectionID
		AND scm.ClassPID = @ClassID
		AND scm.SemesterID = @SemesterID
	INNER JOIN Student STUD on STUD.StudentID=TEMP.studentID
	WHERE scm.StudentClassMappingID IS NULL
	
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadAdmitedStudentDetail]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		Minakshi Magar
	-- Alter date: 25/11/2016
	-- Description:	Read Student
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadAdmitedStudentDetail]	
	
	AS
	
	BEGIN
	
				 select pv.PicklistValueName as YearName, COUNT(1) as StudentCount   from Student s  inner join PickListValue pv on s.AdmittedYearPID=pv.PicklistValueID group by  pv.PicklistValueName
				 
				 
				
				
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadAllSchoolDetails]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Swati>
-- Create date: <Create Date,,18/11/2016>
-- Description:	<Description,,ReadAllSchoolDetails>
-- =============================================
CREATE PROCEDURE [dbo].[ReadAllSchoolDetails]
	
AS
BEGIN

	SET NOCOUNT ON;

  
select pv.PicklistValueName as'SocietyName',s.* from School S
inner join PickListValue pv on pv.PicklistValueID =s.SocietyPID  
where s.isActive=1	
END

GO
/****** Object:  StoredProcedure [dbo].[ReadAllStaffDetails]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Author,,Swati>

-- Create date: <Create Date,,19/11/2016>

-- Description:	<Description,,ReadAllSchoolDetails>

-- =============================================

CREATE PROCEDURE [dbo].[ReadAllStaffDetails]

AS

BEGIN



	SET NOCOUNT ON;

select tcm.StaffID,tcm.StaffName,tcm.Photo,tcm.Qualification,2019 as 'JoiningYear','InEnabled',tcm.[Address],tcm.EmailID,tcm.DOB,tcm.IsActive,tcm.[ResignReason] as Reason,pv3.PicklistValueName as 'Designation',tcm.MobileNo,pv.PicklistValueName as 'Section'
 
  
from Staff tcm

inner join PickListValue pv on pv.PicklistValueID =tcm.SectionPID



inner join PickListValue pv3 on pv3.PicklistValueID=tcm.DesignationPID

END


GO
/****** Object:  StoredProcedure [dbo].[ReadAllStaffDetailsindividually]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 2/1/2017
	-- Description:	Read staff
	-- =============================================
	--ALTER PROCEDURE [dbo].[ReadStaffIndividual]
	
		
 --       @StaffID int	
	--	AS
	--BEGIN
		
	--		BEGIN
				
	--			select StaffName,Qualification,MobileNo,Address,EmailID from Staff		 
	--	where  StaffID=@StaffID
		
	--		END
		
	--END
	CREATE PROCEDURE [dbo].[ReadAllStaffDetailsindividually]
 @StaffID int	
AS

BEGIN

	SET NOCOUNT ON;
select tcm.StaffID,tcm.StaffName,tcm.Photo,tcm.Qualification,pv2.PicklistValueName as 'JoiningYear','InEnabled',tcm.[Address],tcm.EmailID,tcm.DOB,tcm.IsActive,tcm.Reason,pv3.PicklistValueName as 'Designation',tcm.MobileNo,pv.PicklistValueName as 'Section' 
from Staff tcm
inner join PickListValue pv on pv.PicklistValueID =tcm.SectionPID
inner join PickListValue pv2 on pv2.PicklistValueID=tcm.JoiniongYearPID
inner join PickListValue pv3 on pv3.PicklistValueID=tcm.DesignationPID
where  StaffID=@StaffID
END

GO
/****** Object:  StoredProcedure [dbo].[ReadAllStudentInSchoolCollege]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 25/1/2017
	-- Description:	Read Read All Student In School college
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadAllStudentInSchoolCollege]
	@StudentTypePID int
	
		AS
	BEGIN
		
    BEGIN	
    	if (@StudentTypePID=71)		
       select s.StudentID,s.StudentName,s.DOB,s.EmailID,s.Photo,
              s.MotherMobileNo,s.FatherMobileNo,s.PermanentAddress,
              s.TemporaryAddress,Sc.SchoolName,Se.SemesterName,s.StudentTypePID,
              Pv.PicklistValueName as'CurrentClass',
              PV2.PicklistValueName as 'AdmittedClass',
              Pv4.PicklistValueName as 'StudentType',
              Pv3.PicklistValueName as 'AdmittedYear' from Student s 
				inner join School Sc on Sc.SchoolID = S.SchoolID
				inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
				inner join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
				inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
				inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID
			    inner join PickListValue Pv4 on Pv4.PicklistValueID =S.StudentTypePID 
				 
          where StudentTypePID In ('71') 
      else
       select s.StudentID,s.StudentName,s.DOB,s.EmailID,s.Photo,
              s.MotherMobileNo,s.FatherMobileNo,s.PermanentAddress,
              s.TemporaryAddress,Sc.SchoolName,Se.SemesterName,s.StudentTypePID,
              Pv.PicklistValueName as'CurrentClass',
              PV2.PicklistValueName as 'AdmittedClass',
              Pv4.PicklistValueName as 'StudentType',
              Pv3.PicklistValueName as 'AdmittedYear' from Student s
				inner join School Sc on Sc.SchoolID = S.SchoolID
				inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
				inner join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
				inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
				inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
				inner join PickListValue Pv4 on Pv4.PicklistValueID =S.StudentTypePID 
      where StudentTypePID not In ('71') 
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadBranchwiseReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 22/1/2017
	-- Description:	Read Branch
	-- =============================================

	CREATE PROCEDURE [dbo].[ReadBranchwiseReport]
 @PicklistValueID int	
AS

BEGIN

	--SET NOCOUNT ON;
select s.StudentID,
       s.StudentName,
       s.BranchSpecilization,
       pv.PicklistValueName as 'Branch',
       s.DOB,s.EmailID,s.Photo,
       Sc.SchoolName,
       Se.SemesterName,
       Pv.PicklistValueName as'CurrentClass',
       s.MotherMobileNo,
       s.FatherMobileNo,
       s.PermanentAddress,
       s.TemporaryAddress,
       pv.PicklistValueID,
      
       Se.SemesterName,
       Pv.PicklistValueName as'CurrentClass',
       PV2.PicklistValueName as 'AdmittedClass',
       Pv3.PicklistValueName as 'AdmittedYear' 
 from Student s
	inner join PickListValue pv on s.BranchSpecilization=pv.PicklistValueID 
	inner join School Sc on Sc.SchoolID = S.SchoolID
	inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
	inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
	inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
where BranchSpecilization=@PicklistValueID
END

GO
/****** Object:  StoredProcedure [dbo].[ReadCollegeWiseStudent]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 22/1/2017
	-- Description:	Read College wise student 
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadCollegeWiseStudent]
	
		
        @CollegeName nvarchar(200)
		AS
	BEGIN
		
			BEGIN
				
				select s.StudentID,s.CollegeName,s.StudentName,s.DOB,s.EmailID,s.Photo,
s.MotherMobileNo,s.FatherMobileNo,s.PermanentAddress,s.TemporaryAddress,
Sc.SchoolName,Se.SemesterName,Pv.PicklistValueName as'CurrentClass',
PV2.PicklistValueName as 'AdmittedClass',Pv3.PicklistValueName as 'AdmittedYear' from Student S 
inner join School Sc on Sc.SchoolID = S.SchoolID
inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
inner join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
where   CollegeName= @CollegeName
                 
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadFeesDetailsReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		SNEHAL SAWANT
	-- Alter date: 11/24/2016
	-- Description:	Read All Role Records
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadFeesDetailsReport]
	@IsSchool int
			
	AS
	BEGIN
if(@IsSchool =1)
			SELECT fd.FeesDetailID as ID,
						 st.StudentName,
							  sc.SchoolName,
							  fd.ChequeAmount,					
							  fd.ChequeDate,
							  fd.ChequeNo
							  from FeesDetail fd 
						left join Student st on fd.StudentID=st.StudentID
						inner join School sc on fd.SchoolID=sc.SchoolID
					else  
							SELECT fd.FeesDetailID as ID,
						 st.StudentName,
							  sc.SchoolName,
							  fd.ChequeAmount,					
							  fd.ChequeDate,
							  fd.ChequeNo
							  from FeesDetail fd 
						inner join Student st on fd.StudentID=st.StudentID
						left join School sc on fd.SchoolID=sc.SchoolID	
						END

GO
/****** Object:  StoredProcedure [dbo].[ReadFreesDetail]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		SNEHAL SAWANT
	-- Alter date: 11/24/2016
	-- Description:	Read All Role Records
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadFreesDetail]
	
		
		
		
	AS
	BEGIN
		
										
						SELECT fd.FeesDetailID ,
							  fd.ChequeAmount,
							  fd.StudentID,
							  fd.SchoolID,
							  fd.ClassPID,
							  fd.ChequeDate,
							  fd.ChequeNo,
							  pv.PicklistValueName as ClassName,
							  st.StudentName,
							  sc.SchoolName
						 from FeesDetail fd 
						left join PickListValue pv on fd.ClassPID=pv.PicklistValueID
						left join Student st on fd.StudentID=st.StudentID
						left join School sc on fd.SchoolID=sc.SchoolID
									
		
			END

GO
/****** Object:  StoredProcedure [dbo].[ReadSchoolAllStudent]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 22/1/2017
	-- Description:	Read College wise student 
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadSchoolAllStudent]
	
		--@StudentTypePID int
      
		AS
	BEGIN		
			BEGIN				
				SELECT s.StudentID,
				       s.StudentName,
				       s.StudentTypePID,
				       pv.PicklistValueID,
				       pv.PicklistValueName as 'StudentType',
				        case WHEN StudentTypePID=1 then SchoolID 
                             WHEN StudentTypePID=2 then SchoolID END as 'School',
                        case WHEN StudentTypePID=3 then CollegeName 
                             WHEN StudentTypePID=4 then CollegeName END as 'College'
				       
				       
				       FROM student s inner join PickListValue pv on s.StudentTypePID=pv.PicklistValueID
                  --WHERE StudentTypePID=@StudentTypePID
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadSemester]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		SNEHAL SAWANT
	-- Alter date: 11/24/2016
	-- Description:	Read All Role Records
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadSemester]
	
		
		
		
	AS
	BEGIN
		
										
						select s.SemesterID,pv.PicklistValueName as 'YearName',s.SemesterName,s.StartDate,s.EndDate,s.IsActive from Semester s
						inner join PickListValue pv on pv.PicklistValueID= s.YearPID
									
		
			END

GO
/****** Object:  StoredProcedure [dbo].[ReadSingalParentChild]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 3/1/2017
	-- Description:	Read Singal Parent Child
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadSingalParentChild]
		AS
	BEGIN
			BEGIN
				
 select s.StudentID,
		s.StudentName,
		s.DOB,
		s.EmailID,
		s.Photo,
		s.MotherMobileNo,
	    s.FatherMobileNo,
		s.PermanentAddress,
	    s.TemporaryAddress,
	    s.SchoolID,
	    s.CurrentClassPID, 
	    s.AdmittedClassPID,
	    s.AdmittedYearPID ,
	    s.CurrentSemesterID,
	    Sc.SchoolName,
	    Se.SemesterName,
	    Pv.PicklistValueName as'CurrentClass',
        PV2.PicklistValueName as 'AdmittedClass',
        Pv3.PicklistValueName as 'AdmittedYear',	    
  case WHEN IsMother='TRUE' then MotherMobileNo 
       WHEN IsFather='TRUE' then FatherMobileNo END as 'ParentMobileNo',
  case WHEN IsMother='TRUE' then 'Mother'
       WHEN IsFather='TRUE' then 'Father'END as 'Parent' 
  From Student s inner join PickListValue Pv on Pv.PicklistValueID =s.CurrentClassPID 
                 inner join PickListValue Pv2 on Pv2.PicklistValueID =s.AdmittedClassPID
                 inner join PickListValue Pv3 on Pv3.PicklistValueID =s.AdmittedYearPID 
                 inner join School Sc on Sc.SchoolID = s.SchoolID
                 inner join Semester Se on Se.SemesterID= s.CurrentSemesterID   
  where 
  case when IsMother='TRUE' and IsFather='TRUE'  then 0
       WHEN IsMother='FALSE'and IsFather='FALSE' then 0
       WHEN IsMother='TRUE' and IsFather='FALSE' then 1
       WHEN IsMother='FALSE'and IsFather='TRUE'  then 1
       END =1 and s.SchoolID is not null
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadSingalParentChildReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 3/1/2017
	-- Description:	Read Singal Parent Child
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadSingalParentChildReport]
	@StudentTypePID int
		AS
	BEGIN
			BEGIN
			if (@StudentTypePID=71)			
 select s.StudentID,
		s.StudentName,
		s.DOB,
		s.EmailID,
		s.Photo,
		s.MotherMobileNo,
	    s.FatherMobileNo,
		s.PermanentAddress,
	    s.TemporaryAddress,
	    s.SchoolID,
	    s.CurrentClassPID, 
	    s.AdmittedClassPID,
	    s.AdmittedYearPID ,
	    s.CurrentSemesterID,
	    Sc.SchoolName,
	    Se.SemesterName,
	    Pv.PicklistValueName as'CurrentClass',
        PV2.PicklistValueName as 'AdmittedClass',
        Pv3.PicklistValueName as 'AdmittedYear',
         Pv4.PicklistValueName as 'StudentType',	    
  case WHEN IsMother='TRUE' then MotherMobileNo 
       WHEN IsFather='TRUE' then FatherMobileNo END as 'ParentMobileNo',
  case WHEN IsMother='TRUE' then 'Mother'
       WHEN IsFather='TRUE' then 'Father'END as 'Parent' 
  From Student s inner join PickListValue Pv on Pv.PicklistValueID =s.CurrentClassPID 
                 inner join PickListValue Pv2 on Pv2.PicklistValueID =s.AdmittedClassPID
                 inner join PickListValue Pv3 on Pv3.PicklistValueID =s.AdmittedYearPID 
                 inner join School Sc on Sc.SchoolID = s.SchoolID
                    inner join PickListValue Pv4 on Pv4.PicklistValueID =S.StudentTypePID 
                 inner join Semester Se on Se.SemesterID= s.CurrentSemesterID   
  where 
  case when IsMother='TRUE' and IsFather='TRUE'  then 0
       WHEN IsMother='FALSE'and IsFather='FALSE' then 0
       WHEN IsMother='TRUE' and IsFather='FALSE' then 1
       WHEN IsMother='FALSE'and IsFather='TRUE'  then 1
       END =1 and StudentTypePID In ('71') 
       else
       select s.StudentID,
		s.StudentName,
		s.DOB,
		s.EmailID,
		s.Photo,
		s.MotherMobileNo,
	    s.FatherMobileNo,
		s.PermanentAddress,
	    s.TemporaryAddress,
	    s.SchoolID,
	    s.CurrentClassPID, 
	    s.AdmittedClassPID,
	    s.AdmittedYearPID ,
	    s.CurrentSemesterID,
	    Sc.SchoolName,
	    Se.SemesterName,
	    Pv.PicklistValueName as'CurrentClass',
        PV2.PicklistValueName as 'AdmittedClass',
        Pv3.PicklistValueName as 'AdmittedYear',
         Pv4.PicklistValueName as 'StudentType',	    
  case WHEN IsMother='TRUE' then MotherMobileNo 
       WHEN IsFather='TRUE' then FatherMobileNo END as 'ParentMobileNo',
  case WHEN IsMother='TRUE' then 'Mother'
       WHEN IsFather='TRUE' then 'Father'END as 'Parent' 
  From Student s inner join PickListValue Pv on Pv.PicklistValueID =s.CurrentClassPID 
                 inner join PickListValue Pv2 on Pv2.PicklistValueID =s.AdmittedClassPID
                 inner join PickListValue Pv3 on Pv3.PicklistValueID =s.AdmittedYearPID 
                 inner join School Sc on Sc.SchoolID = s.SchoolID
                    inner join PickListValue Pv4 on Pv4.PicklistValueID =S.StudentTypePID 
                 inner join Semester Se on Se.SemesterID= s.CurrentSemesterID   
  where 
  case when IsMother='TRUE' and IsFather='TRUE'  then 0
       WHEN IsMother='FALSE'and IsFather='FALSE' then 0
       WHEN IsMother='TRUE' and IsFather='FALSE' then 1
       WHEN IsMother='FALSE'and IsFather='TRUE'  then 1
       END =1 and StudentTypePID not In ('71') 
       
       
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStaffClassMappingDetails]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Swati>
-- Create date: <Create Date,,19/11/2016>
-- Description:	<Description,,ReadAllSchoolDetails>
-- =============================================
CREATE PROCEDURE [dbo].[ReadStaffClassMappingDetails]
	(
@YearPID int ,
@ClassPID int ,
@SemesterPID int 
)
AS
BEGIN

	SET NOCOUNT ON;
select s.StaffID,s.StaffName,sem.SemesterName,sem.SemesterID,pv2.PicklistValueName as 'Year',
pv1.PicklistValueName as 'Class',pv.PicklistValueName as 'Section' from TeacherClassMapping tcm
inner join PickListValue pv on pv.PicklistValueID =tcm.SectionPID
inner join PickListValue pv1 on pv1.PicklistValueID=tcm.ClassPID
inner join PickListValue pv2 on pv2.PicklistValueID=tcm.YearPID
inner join Semester sem on sem.SemesterID=tcm.SemesterID
inner join Staff s on s.StaffID=tcm.StaffID
END

GO
/****** Object:  StoredProcedure [dbo].[ReadStaffDailyAttendanceReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReadStaffDailyAttendanceReport]

     @StaffID int,
	 @ContraryPID int,
	 @LocationID int
AS
BEGIN

if(@StaffID=0)

select [TransectionId]
      ,[ClientGuid]
      , isnull(s.StaffName,[UserName]) as [UserName]
	  ,case when ([Event]='OnStart') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLogon')  then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionUnlock')  then [LogoutTime] 
			when ([Event]='IdleTime')  then [LoginTime] 
            Else null
	   End as InTime
      ,case when ([Event]='OnSessionChange' and   [Reason] ='SessionLogoff') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLock')  then [LogoutTime] 
			when ([Event]='IdleTime' )  then [LogoutTime] 
            Else null
	   End as OutTime
      ,[LoginDate]
      ,[TotalHours]
      ,Case when [Event]='OnSessionChange' Then Reason else [Event] end  as [Event]
      ,[Reason]
      ,[IsManual]
      ,t.[CreatedBy]
      ,t.[CreatedOn]
      ,t.[ModifiedBy]
      ,t.[ModifiedOn]
     from Transection t 
	 left join [Staff] s on s.StaffUserName = t.UserName
	 left join LocationMaster l on l.LocationMasterID= @LocationID
	 where case when @LocationID=0 then 0 else isnull (s.LocationMasterID,0) end = @LocationID
	 and case when @ContraryPID=0 then 0 else isnull (l.ContraryPID,0) end = @ContraryPID

	  order by UserName, LoginDate

	  else 

	  select [TransectionId]
      ,[ClientGuid]
      , isnull(s.StaffName,[UserName]) as [UserName]
	  ,case when ([Event]='OnStart') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLogon')  then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionUnlock')  then [LogoutTime] 
			when ([Event]='IdleTime')  then [LoginTime] 
            Else null
	   End as InTime
      ,case when ([Event]='OnSessionChange' and   [Reason] ='SessionLogoff') then [LogoutTime] 
			when ([Event]='OnSessionChange' and   [Reason] ='SessionLock')  then [LogoutTime] 
			when ([Event]='IdleTime' )  then [LogoutTime] 
            Else null
	   End as OutTime
      ,[LoginDate]
      ,[TotalHours]
      ,Case when [Event]='OnSessionChange' Then Reason else [Event] end  as [Event]
      ,[Reason]
      ,[IsManual]
      ,t.[CreatedBy]
      ,t.[CreatedOn]
      ,t.[ModifiedBy]
      ,t.[ModifiedOn]
      from Transection t 
	 left join [Staff] s on s.StaffUserName = t.UserName
	 left join LocationMaster l on l.LocationMasterID= @LocationID
	 where case when @LocationID=0 then 0 else isnull (s.LocationMasterID,0) end = case when s.LocationMasterID is null then 0 else  @LocationID end
	 and case when @ContraryPID=0 then 0 else isnull (l.ContraryPID,0) end = case when l.ContraryPID is null then 0 else  @ContraryPID end
	  and case when @StaffID=0 then 0 else isnull (s.StaffID,0) end = case when s.StaffID is null then 0 else @StaffID end

	  order by UserName, LoginDate

END
GO
/****** Object:  StoredProcedure [dbo].[ReadStandardWiseStudentReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 22/1/2017
	-- Description:	Read Standard wise student
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadStandardWiseStudentReport]
	
		
        @CurrentClassPID int	
		AS
	BEGIN
		
			BEGIN
				
				select s.StudentID,s.StudentName,s.DOB,s.EmailID,s.Photo,
s.MotherMobileNo,s.FatherMobileNo,s.PermanentAddress,s.TemporaryAddress,
Sc.SchoolName,Se.SemesterName,Pv.PicklistValueName as'CurrentClass',
PV2.PicklistValueName as 'AdmittedClass',Pv3.PicklistValueName as 'AdmittedYear' from Student S 
inner join School Sc on Sc.SchoolID = S.SchoolID
inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
inner join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
where   CurrentClassPID=@CurrentClassPID
		
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentAcademicDetailsForReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentAcademicDetailsForReport] (@YearPID    int, 
                                                             @StudentID  int, 
                                                             @SemesterID int) 
AS 
  BEGIN 

  Declare @TempStudDetail TABLE (
	[StudentID] [int] NOT NULL,
--	[StudentName] [nvarchar](100) NULL,
	[Class] [nvarchar](max) NOT NULL,
	[ClassPID] [int] NULL,
	[Year] [nvarchar](max) NOT NULL,
	[SemesterName] [nvarchar](50) NULL,
	[SemesterID] [int] NULL,
	[YearPID] [int] NULL
)
insert into @TempStudDetail
      select
	  Distinct
	   scm.StudentID, 
             pv.PicklistValueName  as Class, 
             Scm.ClassPID     as ClassPID, 
             Pv3.PicklistValueName as Year, 
             sem.SemesterName, 
             Scm.SemesterID   as SemesterID, 
             scm.YearPID           as YearPID 

      from   
	      StudentClassMapping  Scm 
             inner join Semester Sem 
                     on Sem.SemesterID = Scm.SemesterID 
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = scm.YearPID 
      where  Scm.StudentID = case 
                             when @StudentID = 0 then Scm.StudentID 
                             else @StudentID 
                           end 
             and Scm.SemesterID = case 
                                         when @SemesterID = 0 then 
                                        Scm.SemesterID 
                                         else @SemesterID 
                                       end 
             and scm.YearPID = case 
                                 when @YearPID = 0 then scm.YearPID 
                                 else @YearPID 
                               end 

							   Select  ts.*, S.Photo, s.StudentName, s.FatherMobileNo,s.MotherMobileNo,S.PermanentAddress, s.TemporaryAddress, s.StudentMobileNo,s.EmailID, s.DOB , case when  pv.SchoolName IS null then s.CollegeName else pv.SchoolName end  as SchoolName from @TempStudDetail ts 
							   inner join Student s on s.StudentID=ts.StudentID
							   left join School pv on pv.SchoolID=s.SchoolID
							     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentAcademicDetailsForSubReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- Author:     
-- Create date: <11/09/2016,,> 
-- Description:   
-- ============================================= 
CREATE PROCEDURE [dbo].[ReadStudentAcademicDetailsForSubReport] (@YearPID    int, 
                                                                @StudentID  int, 
                                                                @SemesterID int) 
AS 
  BEGIN 
      select scm.StudentClassMappingID, 
             tcm.StaffID, 
             st.StaffName, 
             st.MobileNo, 
            Convert(varchar(50), scm.ExamMarks) +'/'+ Convert(varchar(50),scm.OutOfExamMarks) as ExamMarks , 
           Convert(varchar(50),  scm.SectionRating)+'/'+ Convert(varchar(50),scm.OutOfSectionMarks) as SectionRating, 
             s.StudentID, 
             S.Photo, 
             S.StudentName, 
             pv.PicklistValueName  as Class, 
             pv2.PicklistValueName as Section, 
             Pv3.PicklistValueName as Year, 
             sem.SemesterName, 
             scm.AcademicComment, 
             scm.BehaviourComment, 
             Convert(varchar(50),scm.PresentDays ) as TotalPresentDays, 
             case when (scm.OutOfPresentDays =null OR scm.OutOfPresentDays =0 ) Then 0 else   Convert(varchar(50), scm.OutOfPresentDays - scm.PresentDays)end as TotalAbsentDays 
      from   StudentClassMapping scm 
             left join Student S 
                     on S.StudentID = scm.StudentID 
             left join Semester Sem 
                     on Sem.SemesterID = scm.SemesterID 
             left join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             left join PickListValue Pv2 
                     on Pv2.PicklistValueID = scm.SectionPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = scm.YearPID 
             left join TeacherClassMapping tcm 
                    on tcm.ClassPID = scm.ClassPID 
                       and tcm.YearPID = scm.YearPID 
                       and tcm.SemesterID = scm.SemesterID 
					   and tcm.SectionPID=scm.SectionPID
             left join Staff st 
                    on st.StaffID = tcm.StaffID 
      where  scm.StudentID =@StudentID
             and scm.SemesterID = @SemesterID
             and scm.YearPID = @YearPID
             order by Pv2.PicklistValueCode
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentAttenadance]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentAttenadance] (
                                                             @StudentID  int
                                                                                                                         
                                                             ) 
AS 
  BEGIN
   
      select
	  scm.OutOfPresentDays,
	  scm.PresentDays,
	  sem.SemesterName,
	  pv.PicklistValueName as ClassName,
	  pv3.PicklistValueName as YearName,
	  pv2.PicklistValueName as SectionName,
	  
	  pv3.PicklistValueName +'-'+pv.PicklistValueName+'-'+ sem.SemesterName as RowName
      from   
	      StudentClassMapping  Scm 
             inner join Semester Sem 
                     on Sem.SemesterID = Scm.SemesterID 
                     inner join PickListValue pv2 on pv2.PicklistValueID=scm.SectionPID
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = Scm.YearPID 
      where  Scm.StudentID = @StudentID

	order by pv2.PicklistValueCode,	pv3.PicklistValueName, sem.SemesterID						     				     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentComment]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentComment] (
                                                             @StudentID  int
                                                                                                                         
                                                             ) 
AS 
  BEGIN
   
      select
	  scm.AcademicComment,
	  scm.BehaviourComment,
	  sem.SemesterName,
	  pv.PicklistValueName as ClassName,
	  pv3.PicklistValueName as YearName,
	  pv2.PicklistValueName as SectionName,
	  pv3.PicklistValueName +'-'+pv.PicklistValueName+'-'+ sem.SemesterName as RowName
	  

      from   
	      StudentClassMapping  Scm 
             inner join Semester Sem 
                     on Sem.SemesterID = Scm.SemesterID 
             inner join PickListValue pv2 on pv2.PicklistValueID=scm.SectionPID
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = Scm.YearPID 
      where  Scm.StudentID = @StudentID

order by pv2.PicklistValueCode,	pv3.PicklistValueName, sem.SemesterID			     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentCount]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		Minakshi Magar
	-- Alter date: 25/11/2016
	-- Description:	Read Student
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadStudentCount]	
	
	AS
	
	BEGIN
	
				DECLARE @Students NVARCHAR(MAX)=(select count(StudentID) as TotalStudent from Student);
				
				
			DECLARE @Staffs NVARCHAR(MAX)=(select count(StaffID) as TotalSatff from Staff);
		
				 
			DECLARE @Year NVARCHAR(MAX)=(select count(StudentID) as TotalCurrentStudent from Student S
				 inner join PickListValue pv on s.AdmittedYearPID=pv.PicklistValueID
				 where pv.IsEnabled=1);
				 
				 
		 
				 
			
	
				 select @Students as TotalStudent ,@Staffs as TotalSatff,@Year as TotalCurrentStudent
				
				
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentDetailsForReport]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Swati,,Name>
-- Create date: <11/09/2016,,>
-- Description:	<Student Details,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReadStudentDetailsForReport]
(
@YearPID int ,
@ClassPID int ,
@ParentType int =0,
@StudentTypePID int=0 ,
@SchoolID int =0,
@CollegeName varchar(500)=null ,
@BranchSpecilization varchar(500) =null,
@BatchPID int=0,
@IsActive int=0)

	
AS
BEGIN

    -- Insert statements for procedure here
    if(@ParentType=4)


    
select 
	s.StudentID,
	s.StudentName,
	s.DOB,
	s.EmailID,
	s.Photo,
	ISNULL( s.FatherMobileNo ,'')+	 case when  s.FatherMobileNo ='0' or s.FatherMobileNo IS null or  s.FatherMobileNo =''  then ISNULL(s.MotherMobileNo,'') else 	ISNULL('/'+s.MotherMobileNo,'') end as ParentMobileNo,
	
	s.PermanentAddress,
	s.TemporaryAddress,
	case when ( s.SchoolID = 0 or s.SchoolID  is null )then s.CollegeName   else Sc.SchoolName end as SchoolName ,
	s.BranchSpecilization ,
	
	'' as SemesterName,
	Pv.PicklistValueName as'CurrentClass',
	Pv3.PicklistValueName as'CurrentClass',
	
	PV2.PicklistValueName as 'AdmittedClass',
	Pv4.PicklistValueName as BatchName
		from Student S 
		left join School Sc on Sc.SchoolID = S.SchoolID
		left join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
		left join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
		left join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
		left join PickListValue Pv4 on Pv4.PicklistValueID =S.BatchPID 
		
	where ISNULL( s.CurrentClassPID,0) = case when  @ClassPID =0 then ISNULL( s.CurrentClassPID,0)  else @ClassPID end

	   and   ISNULL(s.AdmittedYearPID,0) = case when  @YearPID =0 then ISNULL(s.AdmittedYearPID,0)  else @YearPID end
	   and ISNULL( s.StudentTypePID,0) = case when  @StudentTypePID =0 then ISNULL( s.StudentTypePID,0)  else @StudentTypePID end
	   and ISNULL( s.SchoolID ,'0')= case when  @SchoolID =0 then ISNULL( s.SchoolID ,0)  else @SchoolID end
	   and ISNULL( s.CollegeName,'0') = case when  @CollegeName ='0' then ISNULL( s.CollegeName,'0')   else @CollegeName end
	   and ISNULL( s.BranchSpecilization,'0') = case when  @BranchSpecilization ='0' then ISNULL( s.BranchSpecilization,'0')  else @BranchSpecilization end
	   and  ISNULL(s.BatchPID ,0)= case when  @BatchPID =0 then ISNULL(s.BatchPID ,0)  else @BatchPID end
	
	   and  case when IsMother='TRUE' and IsFather='TRUE'  then 0
		    WHEN IsMother='FALSE'and IsFather='FALSE' then 0
		    WHEN IsMother='TRUE' and IsFather='FALSE' then 1
            WHEN IsMother='FALSE'and IsFather='TRUE'  then 1
            END =1 
        and  ISNULL(s.IsActive ,'true')= case when  @IsActive =2 
                     then ISNULL(s.IsActive ,'true')  else @IsActive end
							
	                      
													
else

select 
	s.StudentID,
	s.StudentName,
	s.DOB,
	s.EmailID,
	s.Photo,
	ISNULL( s.FatherMobileNo ,'')+	 case when  s.FatherMobileNo ='0' or s.FatherMobileNo  IS null or  s.FatherMobileNo =''  then ISNULL(s.MotherMobileNo,'') else 	ISNULL('/'+s.MotherMobileNo,'') end as ParentMobileNo,
	s.PermanentAddress,
	s.TemporaryAddress,
	case when  (s.SchoolID = 0 or s.SchoolID  is null) then s.CollegeName else   Sc.SchoolName end as SchoolName ,
	s.BranchSpecilization ,
	'' as SemesterName,
	Pv.PicklistValueName as'CurrentClass',
	PV2.PicklistValueName as 'AdmittedClass',
	Pv3.PicklistValueName as 'AdmittedYear' ,
	Pv4.PicklistValueName as BatchName
	
		from Student S 
		left join School Sc on Sc.SchoolID = S.SchoolID
		left join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
		left join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
		left join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
		left join PickListValue Pv4 on Pv4.PicklistValueID =S.BatchPID 
	where ISNULL( s.CurrentClassPID,0) = case when  @ClassPID =0 then ISNULL( s.CurrentClassPID,0)  else @ClassPID end

	   and   ISNULL(s.AdmittedYearPID,0) = case when  @YearPID =0 then ISNULL(s.AdmittedYearPID,0)  else @YearPID end
	   and ISNULL( s.StudentTypePID,0) = case when  @StudentTypePID =0 then ISNULL( s.StudentTypePID,0)  else @StudentTypePID end
	   and ISNULL( s.SchoolID ,'0')= case when  @SchoolID =0 then ISNULL( s.SchoolID ,'0')  else @SchoolID end
	   and ISNULL( s.CollegeName,'0') = case when  @CollegeName ='0' then ISNULL( s.CollegeName,'0')   else @CollegeName end
	   and ISNULL( s.BranchSpecilization,'0') = case when  @BranchSpecilization ='0' then ISNULL( s.BranchSpecilization,'0')  else @BranchSpecilization end
	   and  ISNULL(s.BatchPID ,0)= case when  @BatchPID =0 then ISNULL(s.BatchPID ,0)  else @BatchPID end
	   and  ISNULL(s.IsFather,0) = case when  @ParentType =0 then ISNULL(s.IsFather,0)
	                         when   @ParentType =2 then  1 
	                         when  @ParentType =1 then  0 		
	                         when  @ParentType =3 then  case when s.IsFather IS null then null else 0 end  end							
	   and  ISNULL(s.IsMother ,0)= case when  @ParentType =0 then ISNULL(s.IsMother ,0) 
	                         when   @ParentType =2 then  0 
	                         when  @ParentType =1 then  1		
	                         when  @ParentType =3 then   case when s.IsMother IS null then null else 0 end   end	
	                          and  ISNULL(s.IsActive ,0)= case when  @IsActive =2 then ISNULL(s.IsActive ,0)  else @IsActive end
	 
end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentExamMark]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentExamMark] (
                                                             @StudentID  int
                                                                                                                         
                                                             ) 
AS 
  BEGIN
   
      select
	  scm.ExamMarks,
	  scm.OutOfExamMarks,
	  sem.SemesterName,
	  pv.PicklistValueName as ClassName,
	  pv3.PicklistValueName as YearName,
	  pv2.PicklistValueName as SectionName,
	  pv2.PicklistValueCode as SectionOrder,
	  pv3.PicklistValueName +'-'+pv.PicklistValueName+'-'+ sem.SemesterName as RowName

      from   
	      StudentClassMapping  Scm 
             inner join Semester Sem 
                     on Sem.SemesterID = Scm.SemesterID 
                     inner join PickListValue pv2 on pv2.PicklistValueID=scm.SectionPID
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = Scm.YearPID 
      where  Scm.StudentID = @StudentID

order by pv2.PicklistValueCode,	pv3.PicklistValueName, sem.SemesterID
							     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentGeneralComment]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		Minakshi Magar
	-- Alter date: 8/11/2016
	-- Description:	Read Balance
	-- =============================================
  CREATE PROCEDURE [dbo].[ReadStudentGeneralComment]
       	
	AS
	BEGIN
				select s.StudentName,sgc.StudentGeneralCommentID,
       s.StudentID,
       sgc.Comment
  from  StudentGeneralComment sgc  inner join 
       Student s
    on s.StudentID=sgc.StudentID
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentGenralComment]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:		Minakshi Magar
	-- Alter date: 8/11/2016
	-- Description:	Read Balance
	-- =============================================
  CREATE PROCEDURE [dbo].[ReadStudentGenralComment]
       	@StudentID int,
       	@YearPID int=null,
       	@SemesterID int=null
	AS
	BEGIN
				select s.StudentName,sgc.StudentGeneralCommentID,
       s.StudentID,
       sgc.Comment
  from  StudentGeneralComment sgc  inner join 
       Student s
    on s.StudentID=sgc.StudentID
    where sgc.StudentID=@StudentID
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentIndividual]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
	-- Author:	Minakshi Magar
	-- Alter date: 3/1/2017
	-- Description:	Read student individually
	-- =============================================
	CREATE PROCEDURE [dbo].[ReadStudentIndividual]
	
		
        @StudentID int	
		AS
	BEGIN
		
			BEGIN
				
				select s.StudentID,s.StudentName,s.DOB,s.EmailID,s.Photo,
s.MotherMobileNo,s.FatherMobileNo,s.PermanentAddress,s.TemporaryAddress,
Sc.SchoolName,Se.SemesterName,Pv.PicklistValueName as'CurrentClass',
PV2.PicklistValueName as 'AdmittedClass',Pv3.PicklistValueName as 'AdmittedYear' from Student S 
inner join School Sc on Sc.SchoolID = S.SchoolID
inner join Semester Se on Se.SemesterID= S.CurrentSemesterID
inner join PickListValue Pv on Pv.PicklistValueID =S.CurrentClassPID
inner join PickListValue Pv2 on Pv2.PicklistValueID =S.AdmittedClassPID
inner join PickListValue Pv3 on Pv3.PicklistValueID =S.AdmittedYearPID 
where   StudentID=@StudentID
		
			END
		
	END

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentOverallPerformance]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentOverallPerformance] (@YearPID    int, 
                                                             @StudentID  int, 
                                                             @SemesterID int
                                                             
                                                             ) 
AS 
  BEGIN 

  Declare @TempStudDetail TABLE (
	[StudentID] [int] NOT NULL,
--	[StudentName] [nvarchar](100) NULL,
	[Class] [nvarchar](max) NOT NULL,
	[ClassPID] [int] NULL,
	[Year] [nvarchar](max) NOT NULL,
	[SemesterName] [nvarchar](50) NULL,
	[SemesterID] [int] NULL,
	[YearPID] [int] NULL
)
insert into @TempStudDetail
      select
	  Distinct
	   scm.StudentID, 
             pv.PicklistValueName  as Class, 
             Scm.CurrentClassPID     as ClassPID, 
             Pv3.PicklistValueName as Year, 
             sem.SemesterName, 
             Scm.CurrentSemesterID   as SemesterID, 
             Sem.YearPID           as YearPID 

      from   
	      Student  Scm 
	         inner join StudentClassMapping scr on scr.ClassPID=scm.CurrentClassPID
	         
	            and scr.YearPID=
	            case    when @YearPID = 0 then scr.YearPID 
                                 else @YearPID 
                               end
				     and scr.SemesterID = 
				     case 
                                         when @SemesterID = 0 then 
                                       scr.SemesterID
                                         else @SemesterID 
                                       end 
             inner join Semester Sem 
                     on Sem.SemesterID = Scr.SemesterID 
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.CurrentClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = Scr.YearPID 
      where  Scm.StudentID = case 
                             when @StudentID = 0 then Scm.StudentID 
                             else @StudentID 
                           end 
         
							   Select distinct   ts.*, S.Photo, s.StudentName, s.FatherMobileNo,s.MotherMobileNo,S.PermanentAddress, s.TemporaryAddress, s.StudentMobileNo,s.EmailID, s.DOB ,pv.SchoolName as SchoolName from @TempStudDetail ts inner join Student s on s.StudentID=ts.StudentID
							   inner join School pv on pv.SchoolID=s.SchoolID
							     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentSectionMark]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:      
-- Create date: <11/09/2016,,>  
-- Description:    
-- =============================================  
CREATE PROCEDURE [dbo].[ReadStudentSectionMark] (
                                                             @StudentID  int
                                                                                                                         
                                                             ) 
AS 
  BEGIN
   
      select
	  scm.SectionRating,
	  scm.OutOfSectionMarks,
	  sem.SemesterName,
	  pv.PicklistValueName as ClassName,
	  pv3.PicklistValueName as YearName,
	  pv2.PicklistValueName as SectionName,
	  pv3.PicklistValueName +'-'+pv.PicklistValueName+'-'+ sem.SemesterName as RowName

      from   
	      StudentClassMapping  Scm 
             inner join Semester Sem 
                     on Sem.SemesterID = Scm.SemesterID 
                     inner join PickListValue pv2 on pv2.PicklistValueID=scm.SectionPID
             inner join PickListValue Pv 
                     on Pv.PicklistValueID = scm.ClassPID 
             inner join PickListValue Pv3 
                     on Pv3.PicklistValueID = Scm.YearPID 
      where  Scm.StudentID = @StudentID


order by pv2.PicklistValueCode,	pv3.PicklistValueName, sem.SemesterID								     
  end

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentSectionWiseSemesterWiseStudentDetails]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReadStudentSectionWiseSemesterWiseStudentDetails]
	-- Add the parameters for the stored procedure here
	(
	@ClassPID int,
	@SectionID int,
	@SemesterID int,
	@YearId int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    if(@YearId = (select PicklistValueID from PickListValue where PicklistID=2 and IsEnabled=1 ))
    begin
	select s.*, scm.[StudentClassMappingID]
        ,scm.[StudentID]
        ,scm.[ClassPID]
        ,scm.[YearPID]
        ,scm.[SemesterID]
        ,scm.[SectionPID]
        ,scm.[SchoolID]
        ,scm.[AcademicComment]
        ,scm.[BehaviourComment]
        ,scm.[ImageComment]
        ,scm.[SectionRating]
        ,scm.[OutOfSectionMarks]
        ,scm.[ExamMarks]
        ,scm.[OutOfExamMarks]
        ,case when  (scm.[PresentDays] Is null OR  scm.[PresentDays]=0) then ( select top(1)PresentDays from StudentClassMapping where StudentID=scm.StudentID and ClassPID=scm.ClassPID and YearPID =scm.YearPID and SemesterID =scm.SemesterID and  [PresentDays] Is not null and  [PresentDays]!=0  )  else scm.[PresentDays] end as PresentDays
        ,case when  (scm.[OutOfPresentDays] Is null OR  scm.[OutOfPresentDays]=0) then ( select top(1)[OutOfPresentDays] from StudentClassMapping where StudentID=scm.StudentID and ClassPID=scm.ClassPID and YearPID =scm.YearPID and SemesterID =scm.SemesterID and  [OutOfPresentDays] Is not null and  [OutOfPresentDays]!=0  )  else scm.[OutOfPresentDays] end as [OutOfPresentDays]
        ,scm.[CreatedBy]
        ,scm.[CreatedOn]
        ,scm.[ModifiedBy]
        ,scm.[ModifiedOn]
	, class.PicklistValueName as ClassName,
     Yr.PicklistValueName as [Year],
     Sem.SemesterName as SemesterName,
     Section.PicklistValueName as Section
	 from Student s 
left join StudentClassMapping SCM on s.StudentID=SCM.StudentID and s.CurrentClassPID=scm.ClassPID and scm.YearPID= @YearId
 and scm.SectionPID=@SectionID and scm.SemesterID =@SemesterID
 inner join PickListValue class on class.PicklistValueID=@ClassPID
 inner join PickListValue Section on Section.PicklistValueID=@SectionID
 inner join PickListValue Yr on Yr.PicklistValueID=@YearId
 inner join Semester Sem on Sem.SemesterID=@SemesterID
 --left join StudentAttendance SA on SA.StudentClassMappingID=SCM.StudentClassMappingID
--left join StudentAttendance SA on SCM.StudentClassMappingID=Sa.StudentClassMappingID
where s.CurrentClassPID=@ClassPID and s.IsActive=1 --and s.CurrentSemesterID=@SemesterID 
end

--and scm.SectionPID=11 
else
begin
select  s.*,  scm.[StudentClassMappingID]
        ,scm.[StudentID]
        ,scm.[ClassPID]
        ,scm.[YearPID]
        ,scm.[SemesterID]
        ,scm.[SectionPID]
        ,scm.[SchoolID]
        ,scm.[AcademicComment]
        ,scm.[BehaviourComment]
        ,scm.[ImageComment]
        ,scm.[SectionRating]
        ,scm.[OutOfSectionMarks]
        ,scm.[ExamMarks]
        ,scm.[OutOfExamMarks]
        ,case when  (scm.[PresentDays] Is null OR  scm.[PresentDays]=0) then ( select top(1)PresentDays from StudentClassMapping where StudentID=scm.StudentID and ClassPID=scm.ClassPID and YearPID =scm.YearPID and SemesterID =scm.SemesterID and  [PresentDays] Is not null and  [PresentDays]!=0  )  else scm.[PresentDays] end as PresentDays
        ,case when  (scm.[OutOfPresentDays] Is null OR  scm.[OutOfPresentDays]=0) then ( select top(1)[OutOfPresentDays] from StudentClassMapping where StudentID=scm.StudentID and ClassPID=scm.ClassPID and YearPID =scm.YearPID and SemesterID =scm.SemesterID and  [OutOfPresentDays] Is not null and  [OutOfPresentDays]!=0  )  else scm.[OutOfPresentDays] end as [OutOfPresentDays]
        ,scm.[CreatedBy]
        ,scm.[CreatedOn]
        ,scm.[ModifiedBy]
        ,scm.[ModifiedOn], class.PicklistValueName as ClassName,
     Yr.PicklistValueName as [Year],
     Sem.SemesterName as SemesterName,
     Section.PicklistValueName as Section
  from StudentClassMapping SCM inner join Student s on s.StudentID=scm.StudentID
 inner join PickListValue class on class.PicklistValueID=@ClassPID
 inner join PickListValue Section on Section.PicklistValueID=@SectionID
 inner join PickListValue Yr on Yr.PicklistValueID=@YearId
 inner join Semester Sem on Sem.SemesterID=@SemesterID
  where  scm.ClassPID=@ClassPID
 and scm.SectionPID=@SectionID and scm.SemesterID =@SemesterID
 --left join StudentAttendance SA on SA.StudentClassMappingID=SCM.StudentClassMappingID
--left join StudentAttendance SA on SCM.StudentClassMappingID=Sa.StudentClassMappingID
and scm.yearpid=@yearid --and s.CurrentSemesterID=@SemesterID 
end

END



--delete from StudentClassMapping where StudentClassMappingID not in (
--SELECT 
-- MAX(StudentClassMappingID)as id
   
--  FROM [StudentClassMapping]
  
  
--  group by [StudentID]
--      ,[ClassPID]
--      ,[YearPID]
--      ,[SemesterID]
--      ,[SectionPID]
--      ,[SchoolID]
--)

GO
/****** Object:  StoredProcedure [dbo].[ReadStudentWiseSemesterWiseAttendance]    Script Date: 4/27/2019 9:14:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReadStudentWiseSemesterWiseAttendance]
 @ClassPID int,
	@SectionID int,
	@SemesterID int,
	@StudentID int
 as 
 Begin
Declare @SemesterStartDate datetime
Declare @SemesterEndDate datetime


select @SemesterStartDate=startdate,@SemesterEndDate=EndDate from Semester where 
SemesterID=(select top(1) SemesterID from StudentClassMapping
where SemesterID=@SemesterID and SectionPID=@SectionID and ClassPID=@ClassPID)

select IsStatus,thedate As PresentDate  from StudentAttendance Sa right join StudentClassMapping SCM 
on SCM.ClassPID=@ClassPID and scm.SemesterID=@SemesterID and SCM.SectionPID=@SectionID and SCM.StudentID=@StudentID
 right join dbo.ExplodeDates(@SemesterStartDate,@SemesterEndDate)as d on sa.StudentClassMappingID=SCM.StudentClassMappingID
and d.thedate=Sa.PresentDate
where  datepart(weekday,thedate-1)=7;
End

GO
USE [master]
GO
ALTER DATABASE [AMS] SET  READ_WRITE 
GO
