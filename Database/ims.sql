USE [master]
GO
/****** Object:  Database [IMS]    Script Date: 04/04/2015 10:21:40 ******/
CREATE DATABASE [IMS] ON  PRIMARY 
( NAME = N'IMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DALLS\MSSQL\DATA\IMS.mdf' , SIZE = 2304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'IMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DALLS\MSSQL\DATA\IMS_log.LDF' , SIZE = 768KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [IMS] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [IMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [IMS] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [IMS] SET ANSI_NULLS OFF
GO
ALTER DATABASE [IMS] SET ANSI_PADDING OFF
GO
ALTER DATABASE [IMS] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [IMS] SET ARITHABORT OFF
GO
ALTER DATABASE [IMS] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [IMS] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [IMS] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [IMS] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [IMS] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [IMS] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [IMS] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [IMS] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [IMS] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [IMS] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [IMS] SET  ENABLE_BROKER
GO
ALTER DATABASE [IMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [IMS] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [IMS] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [IMS] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [IMS] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [IMS] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [IMS] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [IMS] SET  READ_WRITE
GO
ALTER DATABASE [IMS] SET RECOVERY FULL
GO
ALTER DATABASE [IMS] SET  MULTI_USER
GO
ALTER DATABASE [IMS] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [IMS] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'IMS', N'ON'
GO
USE [IMS]
GO
/****** Object:  Table [dbo].[tbl_Department]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Department](
	[DeptId] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [varchar](100) NOT NULL,
	[HOD] [nvarchar](50) NOT NULL,
	[DeptCode] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_Department] PRIMARY KEY CLUSTERED 
(
	[DeptId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Item]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Item](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [varchar](100) NOT NULL,
	[Unit] [nvarchar](50) NOT NULL,
	[Company] [nvarchar](100) NULL,
	[Description] [nvarchar](255) NULL,
 CONSTRAINT [PK_tbl_Item] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Vendor]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Vendor](
	[VendorId] [int] IDENTITY(1,1) NOT NULL,
	[VendorName] [varchar](100) NOT NULL,
	[Address] [varchar](100) NOT NULL,
	[PhoneNo] [varchar](15) NOT NULL,
 CONSTRAINT [PK_tbl_Vendor] PRIMARY KEY CLUSTERED 
(
	[VendorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_UserInfo]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_UserInfo](
	[Id] [uniqueidentifier] NOT NULL,
	[FullName] [nvarchar](150) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[UserType] [nvarchar](20) NULL,
	[DeptId] [int] NOT NULL,
 CONSTRAINT [PK_tbl_UserInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ReceivedItem]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_ReceivedItem](
	[ReceivedId] [uniqueidentifier] NOT NULL,
	[ReceivedDate] [date] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Unit] [varchar](20) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Rate] [float] NOT NULL,
	[Amount] [money] NOT NULL,
	[VendorId] [int] NOT NULL,
	[Remarks] [varchar](max) NULL,
	[ReceivedBy] [varchar](50) NOT NULL,
	[GRN_NO] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tbl_ReceivedItem] PRIMARY KEY CLUSTERED 
(
	[ReceivedId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_IssuedItem]    Script Date: 04/04/2015 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_IssuedItem](
	[IssuedId] [uniqueidentifier] NOT NULL,
	[IssuedDate] [date] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Unit] [varchar](20) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Rate] [float] NOT NULL,
	[Amount] [money] NOT NULL,
	[DeptId] [int] NOT NULL,
	[ISN_NO] [varchar](100) NOT NULL,
	[Remarks] [varchar](max) NULL,
	[IssuedBy] [varchar](50) NOT NULL,
	[ReceivedBy] [varchar](50) NOT NULL,
 CONSTRAINT [PK_tbl_IssuedItem] PRIMARY KEY CLUSTERED 
(
	[IssuedId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[procGetItem]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[procGetItem]
AS
BEGIN
Select ItemName,ItemId,Unit FROM tbl_Item
END
GO
/****** Object:  StoredProcedure [dbo].[procGetDepartment]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetDepartment]
AS
BEGIN
Select DepartmentName,DeptId FROM tbl_Department
END
GO
/****** Object:  Table [dbo].[tbl_BalanceDetail]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_BalanceDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Rate] [float] NOT NULL,
	[Amount] [money] NOT NULL,
 CONSTRAINT [PK_tbl_BalanceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Balance]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Balance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Rate] [float] NOT NULL,
	[Amount] [money] NOT NULL,
	[date] [date] NULL,
 CONSTRAINT [PK_tbl_Balance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[procGetVendor]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetVendor]
AS
BEGIN
Select VendorId,VendorName FROM tbl_Vendor
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveDepartment]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveDepartment]
(
@DepartmentName nvarchar(50)
,@DeptCode nvarchar(50)
,@HOD nvarchar(50)
,@DeptId int
)
AS
BEGIN
	if(exists(select * from tbl_Department where DeptId=@DeptId))
Begin
Update tbl_Department set
DepartmentName=@DepartmentName
,DeptCode=@DeptCode
,HOD=@HOD
where DeptId=@DeptId
select @DeptId
end
else
begin

	Insert Into tbl_Department
	(
	DepartmentName,
	DeptCode,
	HOD
	)
	values
	(
	@DepartmentName,
	@DeptCode,
	@HOD
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveItem]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveItem]
(
@ItemName nvarchar(50)
,@Unit nvarchar(50)
,@Company nvarchar(50)
,@description nvarchar(255)
,@ItemId int
)
AS
BEGIN
	if(exists(select * from tbl_Item where ItemId=@ItemId))
Begin
Update tbl_Item set
ItemName=@ItemName
,Unit=@Unit
,Company=@Company
,description=@description
where ItemId=@ItemId
select @ItemId
end
else
begin

	Insert Into tbl_Item
	(
	ItemName,
	Unit,
	Company,
	Description
	)
	values
	(
	@ItemName,
	@Unit,
	@Company,
	@description
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSearchItem]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*/

CREATE PROC [dbo].[procSearchItem]
(
@Search nvarchar(150)
)
AS
BEGIN
	select * from(
	select 
	ItemName as 'Item',
	unit as 'Unit',
	Description as 'Description',
	Company as 'Company/Model'
	from tbl_Item member
	) as s where s.Item like @Search+'%' -- '%'+@Search+'%'
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveVendor]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveVendor]
(
@VendorName nvarchar(50)
,@Address nvarchar(50)
,@PhoneNo nvarchar(15)
,@VendorId int
)
AS
BEGIN
	if(exists(select * from tbl_Vendor where VendorId=@VendorId))
Begin
Update tbl_Vendor set
VendorName=@VendorName
,Address=@Address
,PhoneNo=@PhoneNo
where VendorId=@VendorId
select @VendorId
end
else
begin

	Insert Into tbl_Vendor
	(
	VendorName,
	Address,
	PhoneNo
	)
	values
	(
	@VendorName,
	@Address,
	@PhoneNo
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveUser]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveUser]
(
@FullName nvarchar(50)
,@UserName nvarchar(50)
,@Password nvarchar(50)
,@UserType nvarchar(20)
,@DeptId int
,@UserId varchar(max)
)
AS
BEGIN
	--DECLARE @uId uniqueidentifier
	--SET @uId = NEWID()
	if(exists(select * from tbl_UserInfo where Id=@UserId))
Begin
Update tbl_UserInfo set
FullName=@FullName
,UserName=@UserName
,Password=@Password
,UserType=@UserType
,DeptId=@DeptId
where Id=@UserId
end
else
begin

	Insert Into tbl_UserInfo
	(
	FullName,
	UserName,
	Password,
	UserType,
	DeptId,
	Id
	)
	values
	(
	@FullName,
	@UserName,
	@Password,
	@UserType,
	@DeptId,
	@UserId
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveReceived]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveReceived]
(    
     @Date date,
      @itemId int,
      @unit varchar(20),
      @quantity varchar(10),
      @Rate float,
      @amount money,
      @vendorId int,
      --@GNR nvarchar(30),
      @remarks varchar(max),
      @receivedby nvarchar(50),
      @Id uniqueidentifier
)

AS
BEGIN
	if(exists(select * from tbl_ReceivedItem where ReceivedId= @Id))
	Begin
	Update tbl_ReceivedItem set
	ReceivedDate=@Date,
	ItemId=@itemId,
	Unit=@unit,
	Quantity=@quantity,
	Rate=@Rate,
	Amount=@amount,
	VendorId=@vendorId,
	--GNR_NO=@GNR,
	Remarks=@remarks,
	ReceivedBy=@receivedby
	where ReceivedId=@Id
	end
	else
	begin

	Insert Into tbl_ReceivedItem
	(
	ReceivedDate,
	ItemId,
	Unit,
	Quantity,
	Rate,
	Amount,
	VendorId,
	--GNR_NO,
	Remarks,
	ReceivedBy,
	ReceivedId
	)
	values
	(
		@Date,
      @itemId,
      @unit ,
      @quantity ,
      @Rate ,
      @amount ,
      @vendorId ,
      --@GNR ,
      @remarks ,
      @receivedby,
      @Id
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveIssued]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveIssued]
(    
     @Date date,
      @itemId int,
      @unit varchar(20),
      @quantity int,
      @Rate float,
      @amount money,
      @deptId int,
      @ISN nvarchar(30),
      @remarks varchar(max),
      @receivedby nvarchar(50),
      @issuedby nvarchar(50),
      @Id uniqueidentifier
)

AS
BEGIN
	if(exists(select * from tbl_IssuedItem where IssuedId= @Id))
	Begin
	Update tbl_IssuedItem set
	IssuedDate=@Date,
	ItemId=@itemId,
	Unit=@unit,
	Quantity=@quantity,
	Rate=@Rate,
	Amount=@amount,
	DeptId=@deptId,
	ISN_NO=@ISN,
	Remarks=@remarks,
	ReceivedBy=@receivedby,
	IssuedBy=@issuedby
	where IssuedId=@Id
	end
	else
	begin

	Insert Into tbl_IssuedItem
	(
	IssuedDate,
	ItemId,
	Unit,
	Quantity,
	Rate,
	Amount,
	DeptId,
	ISN_NO,
	Remarks,
	ReceivedBy,
	IssuedBy,
	IssuedId
	)
	values
	(
	  @Date,
      @itemId,
      @unit ,
      @quantity ,
      @Rate ,
      @amount ,
      @deptId ,
      @ISN ,
      @remarks ,
      @receivedby,
      @issuedby,
      @Id
	)
	select SCOPE_IDENTITY()
end	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveBalanceDetail]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveBalanceDetail]
(     @date date,
      @itemId int,
      @quantity varchar(10),
      @Rate float,
      @amount money,
      @Id int,
      @rec int,
      @issue int
)
AS
BEGIN
if(@rec=1)
BEGIN
if(exists(select * from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and date=@date))
	begin
		Update tbl_BalanceDetail set
		Quantity=Quantity+@quantity,
		Amount=Amount+@amount
		where ItemId=@itemId and Rate=@Rate and date=@date
	end
	else if(exists(select * from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate))
	begin
		Insert Into tbl_BalanceDetail
		(
		ItemId,
		date,
		Quantity,
		Rate,
		Amount
		)
		values
		(
		  @itemId,
		  @date,
		  @quantity +(select top 1(quantity) from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and date<=@date order by date desc),
		  @Rate ,
		  @amount+(select top 1(Amount) from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and date<=@date order by date desc )
		)
		select SCOPE_IDENTITY()
	end
	else
	begin
		Insert Into tbl_BalanceDetail
		(
		ItemId,
		date,
		Quantity,
		Rate,
		Amount
		)
		values
		(
		  @itemId,
		  @date,
		  @quantity ,
		  @Rate ,
		  @amount
		)
		select SCOPE_IDENTITY()
	end
END
ELSE
BEGIN
	if(exists(select * from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and DATE=@date))
	Begin
		Update tbl_BalanceDetail set
		Quantity=Quantity-@quantity,
		Amount=Amount-@amount
		where ItemId=@itemId and Rate=@Rate and date=@date
	end
	else
	BEGIN
	Insert Into tbl_BalanceDetail
		(
		ItemId,
		date,
		Quantity,
		Rate,
		Amount
		)
		values
		(
		  @itemId,
		  @date,
		  (select top 1(quantity) from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and date<=@date order by date desc )-@quantity,
		  @Rate ,
		  (select top 1(amount) from tbl_BalanceDetail where itemId= @itemId and Rate=@Rate and date<=@date order by date DESC )-@amount
		)
		select SCOPE_IDENTITY()
	END
END
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveBalance]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveBalance]
(     @date date,
      @itemId int,
      @quantity varchar(10),
      @Rate float,
      @amount money,
      @Id int,
      @rec int,
      @issue int
)
AS
BEGIN
if(@rec=1)
BEGIN
	if(exists(select * from tbl_Balance where itemId= @itemId and Rate=@Rate))
	Begin
	Update tbl_Balance set
	date=@date,
	Quantity=Quantity+@quantity,
	Amount=Amount+@amount
	where ItemId=@itemId and Rate=@Rate
	end
	else
	begin

	Insert Into tbl_Balance
	(
	ItemId,
	date,
	Quantity,
	Rate,
	Amount
	)
	values
	(
      @itemId,
      @date,
      @quantity ,
      @Rate ,
      @amount
	)
	select SCOPE_IDENTITY()
end	
END
ELSE
BEGIN
	if(exists(select * from tbl_Balance where itemId= @itemId and Rate=@Rate))
	Begin
	Update tbl_Balance set
	date=@date,
	Quantity=Quantity-@quantity,
	Amount=Amount-@amount
	where ItemId=@itemId and Rate=@Rate
	end
END
END
GO
/****** Object:  StoredProcedure [dbo].[procGetReceivedItem]    Script Date: 04/04/2015 10:21:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetReceivedItem]
AS
BEGIN
Select distinct item.ItemName,
item.ItemId,
item.Unit
FROM tbl_Item item Join tbl_ReceivedItem rec on rec.ItemId=item.ItemId
 
END
GO
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetailReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetReceivedDetailReport]
AS
BEGIN

Select 
	ReceivedDate as 'Date',
	item.ItemName as 'Item',
	Quantity,
	Rate,
	Amount,
	vendor.VendorName as 'Vendor',
	GRN_NO,
	ReceivedBy as 'Received By'
FROM tbl_ReceivedItem rec
join tbl_Item item on item.ItemId=rec.ItemId
join tbl_Vendor vendor on vendor.VendorId=rec.VendorId
order by ReceivedDate,GRN_NO
END
GO
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetail]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetReceivedDetail]
(
 @itemId int
 )
AS
BEGIN

Select 
	ReceivedDate,
	item.ItemName,
	item.Unit,
	Quantity,
	Rate,
	Amount,
	vendor.VendorName ,
	GRN_NO,
	Remarks,
	ReceivedBy,
	ReceivedId
FROM tbl_ReceivedItem rec
join tbl_Item item on item.ItemId=rec.ItemId
join tbl_Vendor vendor on vendor.VendorId=rec.VendorId
where item.ItemId=@itemId

END
GO
/****** Object:  StoredProcedure [dbo].[procUserInfo]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procUserInfo]
(
	@Username varchar(30),
	@Password varchar(30)
	--@role varchar(30)
)
AS
BEGIN

    SELECT * from tbl_UserInfo WHERE Username=@Username AND Password=@Password
	
END
GO
/****** Object:  StoredProcedure [dbo].[procGetBalanceDetail]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[procGetBalanceDetail]
(
 @itemId int
 )
AS
BEGIN

Select 
	item.ItemName,
	item.Unit,
	Quantity,
	Rate,
	Amount
FROM tbl_Balance blnc
join tbl_Item item on blnc.ItemId=item.ItemId
where blnc.ItemId=@itemId

END
GO
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReportSummary]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_VendorWiseItemReportSummary] '2010/01/01','2015/01/01','1'
 */
create proc [dbo].[proc_VendorWiseItemReportSummary]
(
	@DateFrom date,
	@DateTo date,
	@venId int
)
AS
BEGIN
	Select 
	item.ItemName,
	--rec.ReceivedDate as 'Received Date',
	SUM(rec.Quantity) as 'Quantity',
	AVG(rec.Rate) 'Rate',
	SUM(rec.Amount) 'Amount'
	FROM tbl_Item item
	right outer join  tbl_ReceivedItem rec on item.ItemId=rec.ItemId 
	WHERE rec.VendorId=@venId and rec.ReceivedDate between @DateFrom and @DateTo
	group by item.ItemName
END
GO
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_VendorWiseItemReport] '2010/01/01','2015/01/01','1'
 */
CREATE proc [dbo].[proc_VendorWiseItemReport]
(
	@DateFrom date,
	@DateTo date,
	@venId int
)
AS
BEGIN
	Select 
	item.ItemName,
	rec.ReceivedDate as 'Received Date',
	(rec.Quantity),
	(rec.Rate),
	(rec.Amount)
	FROM tbl_Item item
	right outer join  tbl_ReceivedItem rec on item.ItemId=rec.ItemId 
	WHERE rec.VendorId=@venId and rec.ReceivedDate between @DateFrom and @DateTo
	order by rec.ItemId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetStockLedgerReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[proc_GetStockLedgerReport]
AS
BEGIN
Select 
	item.ItemId,
	item.ItemName,
	--rec.ReceivedDate,
	(rec.Quantity),
	sum(rec.Rate),
	sum(rec.Amount)
	--issue.IssuedDate,
	--issue.Quantity,
	--issue.Rate,
	--issue.Amount
	
FROM tbl_Item item
left join  tbl_ReceivedItem rec on item.ItemId=rec.ItemId
left join tbl_IssuedItem issue on issue.ItemId=item.ItemId
 group by item.ItemName,item.ItemId,rec.Quantity
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReportTest]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetLedgerReportTest] '2015/01/01','2016/01/01'
 */
CREATE proc [dbo].[proc_GetLedgerReportTest]
(
	@DateFrom date,
	@DateTo date
)
AS
BEGIN
	Declare @itemId int	 
	Declare @itemName varchar(100)	 
	Declare @rQuantityTotal int	 
	Declare @rRateTotal int	 
	Declare @rAmountTotal int
	Declare @iQuantityTotal int	 
	Declare @iRateTotal int	 
	Declare @iAmountTotal int	 
	Declare @bQuantityTotal int	 
	Declare @bRateTotal int	 
	Declare @bAmountTotal int
	IF object_id('tempdb..##TBL_LEDGER') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGER
	END
	CREATE TABLE #TBL_LEDGER
	 (
		  itemId int,
		  item varchar(100),
	      Date date,
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		  bQuantity int, 
		  bRate float,
		  bAmount money
	 )
	set @itemId=(select min(itemId) from tbl_ReceivedItem)

	WHILE @itemId is not NULL
	BEGIN
		if exists(Select * from tbl_ReceivedItem where ItemId=@itemId)
		BEGIN
		set @itemName=(Select ItemName as 'Item' from tbl_Item where ItemId=@itemId )
			INSERT INTO #TBL_LEDGER(Item)
			select @itemName
			
			INSERT INTO #TBL_LEDGER(itemId,Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount,bQuantity,brate,bAmount) 
			Select 
			@itemId,
			isnull(rec.ReceivedDate,iss.IssuedDate) as 'Date',
			sum(rec.Quantity) as 'Received Quantity',
			avg(rec.Rate) as Rate,
			sum(rec.Amount) as Amount,
			sum(iss.Quantity) as 'Issued Quantity',
			avg(iss.Rate) as Rate,
			sum(iss.Amount) as Amount,
			(blnc.Quantity) as 'Balance Quantity',
			avg(blnc.Rate) as Rate,
			(blnc.Amount) as Amount
			from  tbl_ReceivedItem rec --on item.ItemId=rec.ItemId
			full outer join tbl_IssuedItem iss on iss.IssuedDate=rec.ReceivedDate
			join tbl_BalanceDetail blnc on  blnc.date=iss.IssuedDate or rec.ReceivedDate=blnc.date
			where rec.ItemId=@itemId or iss.ItemId=@itemId
			group by iss.ItemId,rec.ItemId,iss.IssuedDate,rec.ReceivedDate,blnc.Quantity,blnc.Amount
			order by iss.IssuedDate,rec.ReceivedDate
		END
		
		set @rQuantityTotal=(select SUM(isnull(rQuantity,0)) from #TBL_LEDGER where itemId=@itemId)
		set @rRateTotal=(select Avg(isnull(rRate,0)) from #TBL_LEDGER where itemId=@itemId)
		set @rAmountTotal=(select SUM(isnull(rQuantity,0)) from #TBL_LEDGER where item='Total')*
		(select Avg(isnull(rRate,0)) from #TBL_LEDGER where item='total')
		set @iQuantityTotal=(select SUM(isnull(iQuantity,0)) from #TBL_LEDGER where itemId=@itemId)
		set @iRateTotal=(select avg(isnull(iRate,0)) from #TBL_LEDGER where itemId=@itemId)
		set @iAmountTotal=(select SUM(isnull(iAmount,0)) from #TBL_LEDGER where itemId=@itemId)
		set @bQuantityTotal=(select top 1(isnull(bQuantity,0)) from #TBL_LEDGER where itemId=@itemId order by DATE desc)
		set @bRateTotal=(select Avg(isnull(bRate,0)) from #TBL_LEDGER where itemId=@itemId)
		set @bAmountTotal=(select top 1(isnull(bAmount,0)) from #TBL_LEDGER where itemId=@itemId order by date DESC)
		INSERT INTO #TBL_LEDGER(item,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount,bQuantity,bRate,bAmount)
		(Select 'Total'+' '+@itemName,@rQuantityTotal,@rRateTotal,@rAmountTotal,@iQuantityTotal,@iRateTotal,@iAmountTotal,@bQuantityTotal,@bRateTotal,@bAmountTotal )
	set @itemId=(select min(itemId) from tbl_ReceivedItem where ItemId>@itemId)
	END
	select * from #TBL_LEDGER
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetLedgerReport] '2010/01/01','2015/01/01'
 */
CREATE proc [dbo].[proc_GetLedgerReport]
(
	@DateFrom date,
	@DateTo date
)
AS
BEGIN
Declare @itemId int
IF object_id('tempdb..##TBL_LEDGER') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGER
	END
	CREATE TABLE #TBL_LEDGER
	 (
	      Item VARCHAR(50),
	      ReceivedDate date,
	      Quantity int, 
		  Rate float,
		  Amount money
	 )
	 
	 IF object_id('tempdb..##TBL_ISSUED') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_ISSUED
	END
	CREATE TABLE #TBL_ISSUED
	 (
	     Item VARCHAR(50),
	      issuedDate date,
	      Quantity int, 
		  Rate float,
		  Amount money
	 )
	 
	 IF object_id('tempdb..##TBL_BALANCE') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_BALANCE
	END
	CREATE TABLE #TBL_BALANCE
	 (
	      Item VARCHAR(50),
	      Quantity int, 
		  Rate float,
		  Amount money
	 )
set @itemId=(select min(itemId) from tbl_Item)

WHILE @itemId is not NULL
BEGIN
if exists(Select * from tbl_ReceivedItem where ItemId=@itemId)
BEGIN
 INSERT INTO #TBL_LEDGER(Item)
	(Select ItemName as 'Item' from tbl_Item where ItemId=@itemId )
 INSERT INTO #TBL_LEDGER(ReceivedDate,Quantity,Rate,Amount) 
SELECT * from 
(
	Select 
	rec.ReceivedDate as 'Received Date',
	(rec.Quantity),
	(rec.Rate),
	(rec.Amount)
	FROM tbl_Item item
	inner join  tbl_ReceivedItem rec on item.ItemId=rec.ItemId
	WHERE rec.ItemId=@itemId and rec.ReceivedDate between @DateFrom and @DateTo
 )temp1 order by 'Received Date'
 END
 
 if exists(Select * from tbl_ReceivedItem where ItemId=@itemId)
 BEGIN
 INSERT INTO #TBL_ISSUED(ITEM)
	(Select ItemName as 'Item' from tbl_Item where ItemId=@itemId )
INSERT INTO #TBL_ISSUED(issuedDate,Quantity,Rate,Amount)	
SELECT * from 
(
	Select
	issue.IssuedDate as 'Issue Date',
	issue.Quantity,
	issue.Rate,
	issue.Amount
	FROM tbl_Item item
	join  tbl_issuedItem issue on item.ItemId=issue.ItemId
	WHERE issue.ItemId=@itemId and issue.IssuedDate between @DateFrom and @DateTo
 )temp2 order by 'Issue Date'
END

if exists(Select * from tbl_ReceivedItem where ItemId=@itemId)
BEGIN
 INSERT INTO #TBL_BALANCE(ITEM)
	(Select ItemName as 'Item' from tbl_Item where ItemId=@itemId )
INSERT INTO #TBL_BALANCE(Quantity,Rate,Amount)
 SELECT * from
 (
	Select
	blnc.Quantity,
	blnc.Rate,
	blnc.Amount
	from tbl_Balance blnc
 WHERE blnc.ItemId=@itemId
 )temp3 
 END
 
  set @itemId=(select min(itemId) from tbl_Item where ItemId>@itemId)
 END
 
 select
   ISNULL(CAST(item as nvarchar(100)),'')as Item,
   ISNULL(CAST(ReceivedDate as nvarchar(100)),'') as 'Received Date',
   ISNULL(CAST(Quantity as nvarchar(100)),'') as Quantity,
   ISNULL(CAST(Rate as nvarchar(100)),'') as Rate,
   ISNULL(CAST(Amount as nvarchar(100)),'') as Amount
  from #TBL_LEDGER
  
  select
  ISNULL(CAST(item as nvarchar(100)),'')as Item,
   ISNULL(CAST(issuedDate as nvarchar(100)),'') as 'Issued Date',
   ISNULL(CAST(Quantity as nvarchar(100)),'') as Quantity,
   ISNULL(CAST(Rate as nvarchar(100)),'') as Rate,
   ISNULL(CAST(Amount as nvarchar(100)),'') as Amount
  from #TBL_ISSUED
  
 select 
 ISNULL(CAST(item as nvarchar(100)),'')as Item,
   ISNULL(CAST(Quantity as nvarchar(100)),'') as Quantity,
   ISNULL(CAST(Rate as nvarchar(100)),'') as Rate,
   ISNULL(CAST(Amount as nvarchar(100)),'') as Amount
  from #TBL_BALANCE
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReportSummary]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseVendorReportSummary] '2010/01/01','2015/01/01','2'
 */
CREATE proc [dbo].[proc_GetItemWiseVendorReportSummary]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
	Select 
	ven.VendorName as 'Vendor',
	--rec.ReceivedDate as 'Received Date',
	SUM(rec.Quantity) as 'Quantity',
	AVG(rec.Rate) as 'Rate',
	SUM(rec.Amount) as 'Amount'
	FROM tbl_Vendor ven
   join  tbl_ReceivedItem rec on ven.VendorId=rec.VendorId 
	WHERE rec.ItemId=@itemId and rec.ReceivedDate between @DateFrom and @DateTo
	group by ven.VendorName
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseVendorReport] '2010/01/01','2015/01/01','2'
 */
CREATE proc [dbo].[proc_GetItemWiseVendorReport]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
	Select 
	ven.VendorName as 'Vendor',
	rec.ReceivedDate as 'Received Date',
	(rec.Quantity),
	(rec.Rate),
	(rec.Amount)
	FROM tbl_Vendor ven
	right outer join  tbl_ReceivedItem rec on ven.VendorId=rec.VendorId 
	WHERE rec.ItemId=@itemId and rec.ReceivedDate between @DateFrom and @DateTo
	order by rec.VendorId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReportTest]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseStockLedgerReportTest] '2015/01/01','2015/12/12','2'
 */
CREATE proc [dbo].[proc_GetItemWiseStockLedgerReportTest]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
IF object_id('tempdb..##TBL_LEDGER') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGER
	END
	CREATE TABLE #TBL_LEDGER
	 (
	      Date date,
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		  bQuantity int, 
		  bRate float,
		  bAmount money
	 )
	 INSERT INTO #TBL_LEDGER(Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount,bQuantity,brate,bAmount) 

Select 
	isnull(rec.ReceivedDate,iss.IssuedDate) as 'Date',
	sum(rec.Quantity) as 'Received Quantity',
	avg(rec.Rate) as Rate,
	sum(rec.Amount) as Amount,
	sum(iss.Quantity) as 'Issued Quantity',
	avg(iss.Rate) as Rate,
	sum(iss.Amount) as Amount,
	(blnc.Quantity) as 'Balance Quantity',
	avg(blnc.Rate) as Rate,
	(blnc.Amount) as Amount
	from  tbl_ReceivedItem rec --on item.ItemId=rec.ItemId
	full outer join tbl_IssuedItem iss on iss.IssuedDate=rec.ReceivedDate
    join tbl_BalanceDetail blnc on rec.ReceivedDate=blnc.date or blnc.date=iss.IssuedDate
    where rec.ItemId=@itemId or iss.ItemId=@itemId or blnc.ItemId=@itemId and (rec.ReceivedDate between @DateFrom and @DateTo or iss.IssuedDate between @DateFrom and @DateTo)
	group by iss.ItemId,rec.ItemId,iss.IssuedDate,rec.ReceivedDate,blnc.Quantity,blnc.Amount
	order by iss.IssuedDate,rec.ReceivedDate
	
	
	--gfhgfh
	
	--Select * from #TBL_LEDGER
	
	select
   ISNULL(CAST(Date as nvarchar(100)),'') as ' Date',
   ISNULL(CAST(rQuantity as nvarchar(100)),'') as 'Quantity',
   ISNULL(CAST(rRate as nvarchar(100)),'') as 'Rate',
   ISNULL(CAST(rAmount as nvarchar(100)),'') as 'Amount',
   
   ISNULL(CAST(iQuantity as nvarchar(100)),'') as ' Issued Quantity',
   ISNULL(CAST(iRate as nvarchar(100)),'') as 'Issued Rate',
   ISNULL(CAST(iAmount as nvarchar(100)),'') as 'Issued Amount',
   
   ISNULL(CAST(bQuantity as nvarchar(100)),'') as 'Balance Quantity',
   ISNULL(CAST(bRate as nvarchar(100)),'') as 'Balance Rate',
   ISNULL(CAST(bAmount as nvarchar(100)),'') as 'Balance Amount'
 from #TBL_LEDGER
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseStockLedgerReport] '2',03-05-2010 18:18:18,03-05-2015 18:18:18
 */
CREATE proc [dbo].[proc_GetItemWiseStockLedgerReport]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
SELECT * from 
(
	Select 
	rec.ReceivedDate as 'Received Date',
	(rec.Quantity),
	(rec.Rate),
	(rec.Amount)
	FROM tbl_Item item
	join  tbl_ReceivedItem rec on item.ItemId=rec.ItemId
	WHERE item.ItemId=@itemId and rec.ReceivedDate between @DateFrom and @DateTo
 )temp1 order by 'Received Date'
	
SELECT * from 
(
	Select
	issue.IssuedDate as 'Issue Date',
	issue.Quantity,
	issue.Rate,
	issue.Amount
	FROM tbl_Item item
	join  tbl_issuedItem issue on item.ItemId=issue.ItemId
	WHERE item.ItemId=@itemId and issue.IssuedDate between @DateFrom and @DateTo
 )temp2 order by 'Issue Date'
 
 BEGIN
 SELECT * from
 (
	Select
	blnc.Quantity,
	blnc.Rate,
	blnc.Amount
	from tbl_Balance blnc
 WHERE blnc.ItemId=@itemId
 )temp3 
 END
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReportSummary]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseDepartmentReportSummary] '2010/01/01','2015/01/01','2'
 */
CREATE proc [dbo].[proc_GetItemWiseDepartmentReportSummary]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
	Select 
	dept.DepartmentName as 'Department',
	--iss.IssuedDate as 'Issued Date',
	sum(iss.Quantity),
	AVG(iss.Rate),
	SUM(iss.Amount)
	FROM tbl_Department dept
	right outer join  tbl_IssuedItem iss on dept.DeptId=iss.DeptId 
	WHERE iss.ItemId=@itemId and iss.IssuedDate between @DateFrom and @DateTo
	group by dept.DepartmentName
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseDepartmentReport] '2010/01/01','2015/01/01','2'
 */
CREATE proc [dbo].[proc_GetItemWiseDepartmentReport]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
	Select 
	dept.DepartmentName as 'Department',
	iss.IssuedDate as 'Issued Date',
	(iss.Quantity),
	(iss.Rate),
	(iss.Amount)
	FROM tbl_Department dept
	right outer join  tbl_IssuedItem iss on dept.DeptId=iss.DeptId 
	WHERE iss.ItemId=@itemId and iss.IssuedDate between @DateFrom and @DateTo
	order by iss.DeptId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReportSummary]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetDepartmentWiseItemReportSummary] '2010/01/01','2015/01/01','3'
 */
CREATE proc [dbo].[proc_GetDepartmentWiseItemReportSummary]
(
	@DateFrom date,
	@DateTo date,
	@deptId int
)
AS
BEGIN
Declare @itemId int
Declare @deptCode int
set @itemId=(select min(ItemId) from tbl_IssuedItem where DeptId=@deptId)
BEGIN
Begin
	Select 
	item.ItemName as 'Item',
	--iss.IssuedDate as 'Issued Date',
	SUM(iss.Quantity) as 'Quantity',
	AVG(iss.Rate) as 'Rate',
	SUM(iss.Amount) as 'Amount'
	FROM tbl_Item item
	right outer join  tbl_IssuedItem iss on item.ItemId=iss.ItemId 
	WHERE iss.DeptId=@deptId and iss.IssuedDate between @DateFrom and @DateTo
	group by item.ItemName
	SET @itemId = (select min(ItemId) from tbl_IssuedItem where DeptId=@deptId and ItemId > @itemId)
end
end
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReport]    Script Date: 04/04/2015 10:21:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetDepartmentWiseReport] '2010/01/01','2015/01/01','3'
 */
CREATE proc [dbo].[proc_GetDepartmentWiseItemReport]
(
	@DateFrom date,
	@DateTo date,
	@deptId int
)
AS
BEGIN
Declare @itemId int
Declare @deptCode int
--set @deptCode=(select min(DeptId) from tbl_Department)
--While @deptCode is not null
set @itemId=(select min(ItemId) from tbl_IssuedItem where DeptId=@deptId)
BEGIN
--While @itemId is not null
Begin
	Select 
	item.ItemName as 'Item',
	iss.IssuedDate as 'Issued Date',
	(iss.Quantity),
	(iss.Rate),
	(iss.Amount)
	FROM tbl_Item item
	right outer join  tbl_IssuedItem iss on item.ItemId=iss.ItemId 
	WHERE iss.DeptId=@deptId and iss.IssuedDate between @DateFrom and @DateTo
	order by iss.ItemId
	SET @itemId = (select min(ItemId) from tbl_IssuedItem where DeptId=@deptId and ItemId > @itemId)
end
--set @deptCode=(select min(DeptId) from tbl_Department where DeptId>@deptCode)
end
END
GO
/****** Object:  ForeignKey [FK__tbl_UserI__DeptI__1BFD2C07]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_UserInfo]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
/****** Object:  ForeignKey [FK__tbl_Recei__ItemI__34C8D9D1]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Recei__Vendo__35BCFE0A]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([VendorId])
REFERENCES [dbo].[tbl_Vendor] ([VendorId])
GO
/****** Object:  ForeignKey [FK__tbl_Issue__DeptI__4222D4EF]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
/****** Object:  ForeignKey [FK__tbl_Issue__ItemI__4316F928]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Issue__ItemI__47DBAE45]    Script Date: 04/04/2015 10:21:43 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Balan__ItemI__656C112C]    Script Date: 04/04/2015 10:21:45 ******/
ALTER TABLE [dbo].[tbl_BalanceDetail]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Balan__ItemI__4F7CD00D]    Script Date: 04/04/2015 10:21:45 ******/
ALTER TABLE [dbo].[tbl_Balance]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
