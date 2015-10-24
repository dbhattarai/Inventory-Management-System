USE [master]
GO
/****** Object:  Database [IMS2]    Script Date: 08/04/2015 08:39:15 ******/
CREATE DATABASE [IMS2] ON  PRIMARY 
( NAME = N'IMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DALLS\MSSQL\DATA\IMS2.mdf' , SIZE = 2304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'IMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DALLS\MSSQL\DATA\IMS2_1.LDF' , SIZE = 5696KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [IMS2] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [IMS2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [IMS2] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [IMS2] SET ANSI_NULLS OFF
GO
ALTER DATABASE [IMS2] SET ANSI_PADDING OFF
GO
ALTER DATABASE [IMS2] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [IMS2] SET ARITHABORT OFF
GO
ALTER DATABASE [IMS2] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [IMS2] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [IMS2] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [IMS2] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [IMS2] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [IMS2] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [IMS2] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [IMS2] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [IMS2] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [IMS2] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [IMS2] SET  DISABLE_BROKER
GO
ALTER DATABASE [IMS2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [IMS2] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [IMS2] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [IMS2] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [IMS2] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [IMS2] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [IMS2] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [IMS2] SET  READ_WRITE
GO
ALTER DATABASE [IMS2] SET RECOVERY FULL
GO
ALTER DATABASE [IMS2] SET  MULTI_USER
GO
ALTER DATABASE [IMS2] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [IMS2] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'IMS2', N'ON'
GO
USE [IMS2]
GO
/****** Object:  Table [dbo].[tbl_Department]    Script Date: 08/04/2015 08:39:18 ******/
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
/****** Object:  Table [dbo].[tbl_Vendor]    Script Date: 08/04/2015 08:39:18 ******/
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
/****** Object:  Table [dbo].[tbl_transaction]    Script Date: 08/04/2015 08:39:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_transaction](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[transactionId] [uniqueidentifier] NOT NULL,
	[grn] [int] NULL,
	[isn] [int] NULL,
	[itemId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[recQuantity] [money] NOT NULL,
	[issQuantity] [money] NOT NULL,
	[rate] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[itemId] ASC,
	[Date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetDatabaseName]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_GetDatabaseName]
AS
BEGIN
select db_name() as DatabaseName
END
GO
/****** Object:  StoredProcedure [dbo].[proc_DBMgmt]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_DBMgmt] 
@FLG AS INT, 
@DBNAME AS VARCHAR(150), 
@BKPNAME AS VARCHAR(450) AS
 IF @FLG=1
   BACKUP DATABASE @DBNAME TO DISK=@BKPNAME 
 ELSE IF @FLG=2 
  BEGIN
      --Query 
		Declare @Sql varchar(max)
		SELECT @Sql ='alter database ' + @DBNAME +' set multi_user'
		EXECUTE(@Sql)

		--Query To Restore Database
		RESTORE DATABASE @DBNAME FROM DISK=@BKPNAME with Replace

  END
GO
/****** Object:  Table [dbo].[tbl_Item]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  Table [dbo].[tbl_IssuedItem]    Script Date: 08/04/2015 08:39:19 ******/
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
	[Quantity] [money] NOT NULL,
	[Rate] [float] NOT NULL,
	[Amount] [money] NOT NULL,
	[DeptId] [int] NOT NULL,
	[ISN_NO] [int] IDENTITY(1,1) NOT NULL,
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReport]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetItemWiseStockLedgerReport] '2015/01/01','2016/01/01','5'
 */
CREATE proc [dbo].[proc_GetItemWiseStockLedgerReport]
(
	@DateFrom date,
	@DateTo date,
	@itemId int
)
AS
BEGIN
DECLARE @Balance MONEY
DECLARE @rate MONEY
DECLARE @balanceQuantity int
DECLARE @openingBalance int
IF object_id('tempdb..##TBL_LEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGERFINAL
	END
CREATE TABLE #TBL_LEDGERFINAL
	 (
		 RowId int Identity(1,1),
		 Date date,
		 itemId int,
		  item varchar(100),	      
	      rQuantity money, 
		  rRate float,
		  rAmount money,
		  iQuantity money, 
		  iRate float,
		  iAmount money,
		   bQuantity money,
		  bAmount money
	 )
	 
	 IF object_id('tempdb..##TBL_TEMPLEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_TEMPLEDGERFINAL
	END
CREATE TABLE #TBL_TEMPLEDGERFINAL
	 (
		  Date date,
		  item varchar(100),	      
	      rQuantity money, 
		  rRate float,
		  rAmount money,
		  iQuantity money, 
		  iRate float,
		  iAmount money,
		   bQuantity money,
		  bAmount money
	 )
	 
INSERT INTO #TBL_LEDGERFINAL
	SELECT *,Temp.[Received Quantity]-TEMP.[Issued quantity] as 'Balance Quantity',Temp.[Received Amount]-TEMP.[Issued Amount] as 'Balance Amount' FROM (
			select 
			t.Date,
			t.itemId,i.ItemName,
			 SUM(case when recQuantity>0 then recQuantity else 0 end) as 'Received Quantity',
			 avg(case when grn=0 then 0 else t.rate end) as 'Received Rate',
			 --t.rate as rRate,
			-- AVG(case when recQuantity>0 then rate else 0 end) as ReceivedRate,
			 SUM(case when recQuantity>0 then recQuantity else 0 end)*avg(t.rate) as 'Received Amount'
			,SUM(case when issQuantity>0 then issQuantity else 0 end) as 'Issued quantity',
			--AVG(case when issQuantity>0 then rate else 0 end) as IssuedRate,
			avg(case when isn=0 then 0 else t.rate end) as 'Issued Rate',
			SUM(case when issQuantity>0 then issQuantity else 0 end)*avg(t.rate) as 'Issued Amount' 
			from tbl_transaction t join tbl_Item i on i.ItemId=t.itemId 
			where t.Date between @DateFrom and @DateTo group by t.itemId,i.ItemName,t.Date,t.rate 
	)TEMP order by Temp.itemId,TEMP.Date

Set @openingBalance=(select isnull(sum(isnull(recQuantity,0)-isnull(issQuantity,0)),0) from tbl_transaction where date<@DateFrom and itemId=@ItemId)
			insert #TBL_TEMPLEDGERFINAL(item)
			SELECT  distinct UPPER(item) FROM #TBL_LEDGERFINAL where itemId=@ItemId

			insert #TBL_TEMPLEDGERFINAL(item,bQuantity)
			SELECT 'Opening Balance --------------->',@openingBalance
set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId)
		WHILE @rate is not null
		BEGIn
			
			SET @balanceQuantity=(SELECT ISNULL(sum((ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
			FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)
			
			SET @Balance=(SELECT ISNULL(sum(ts.rate*(ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
			FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)

			insert #TBL_TEMPLEDGERFINAL
			SELECT TEMP1.Date, '',TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount,ISNULL(SUM(ISNULL(TEMP2.bQuantity,0)),0)+@balanceQuantity,ISNULL(SUM(ISNULL(TEMP2.bAmount,0)),0)+@Balance from
			(
			SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
			) as TEMP1 inner join 
			(SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
			) as TEMP2 on TEMP2.RowId<=TEMP1.RowId group by TEMP1.Date, TEMP1.item,TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount
			set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId AND rRate>@rate)
		END
		
		insert #TBL_TEMPLEDGERFINAL(item,rQuantity,iQuantity)
		(select 'Total', SUM(ISNULL(rQuantity,0)),SUM(ISNULL(iQuantity,0)) from #TBL_TEMPLEDGERFINAL)
SELECT 
	
	Date as 'Date',
	item as 'Item',
	rQuantity as 'Received Quantity',
	rRate as ' Received Rate',
	rAmount as 'Received Amount',
	iQuantity as 'Issued Quantity',
	iRate as ' Issued Rate',
	iAmount as 'Issued Amount',
	(bQuantity) as 'Balance Quantity',
	(bAmount) as 'Balance Amount' 
	 from #TBL_TEMPLEDGERFINAL
	
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReport]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetLedgerReport] '2015/01/01','2016/01/01'
 */
CREATE proc [dbo].[proc_GetLedgerReport]
(
	@DateFrom date,
	@DateTo date
)
AS
BEGIN
DECLARE @ItemId int
DECLARE @Balance MONEY
DECLARE @rate MONEY
DECLARE @balanceQuantity money
DECLARE @openingBalance money
IF object_id('tempdb..##TBL_LEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGERFINAL
	END
CREATE TABLE #TBL_LEDGERFINAL
	 (
		 RowId int Identity(1,1),
		 Date date,
		 itemId int,
		  item varchar(100),	      
	      rQuantity money, 
		  rRate float,
		  rAmount money,
		  iQuantity money, 
		  iRate float,
		  iAmount money,
		   bQuantity money,
		  bAmount money
	 )
	 
	 IF object_id('tempdb..##TBL_TEMPLEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_TEMPLEDGERFINAL
	END
CREATE TABLE #TBL_TEMPLEDGERFINAL
	 (
		  Date date,
		  itemId int,
		  item varchar(100),	      
	      rQuantity money, 
		  rRate float,
		  rAmount money,
		  iQuantity money, 
		  iRate float,
		  iAmount money,
		   bQuantity money,
		  bAmount money
	 )
	 
	
INSERT INTO #TBL_LEDGERFINAL
	SELECT *,Temp.[Received Quantity]-TEMP.[Issued quantity] as 'Balance Quantity',Temp.[Received Amount]-TEMP.[Issued Amount] as 'Balance Amount' FROM (
			select 
			t.Date,
			t.itemId,i.ItemName,
			 SUM(case when recQuantity>0 then recQuantity else 0 end) as 'Received Quantity',
			avg(case when grn=0 then 0 else t.rate end) as 'Received Rate',
			-- AVG(case when recQuantity>0 then rate else 0 end) as ReceivedRate,
			 SUM(case when recQuantity>0 then recQuantity else 0 end)*avg(t.rate) as 'Received Amount'
			,SUM(case when issQuantity>0 then issQuantity else 0 end) as 'Issued quantity',
			--AVG(case when issQuantity>0 then rate else 0 end) as IssuedRate,
			avg(case when isn=0 then 0 else t.rate end) as 'Issued Rate',
			SUM(case when issQuantity>0 then issQuantity else 0 end)*avg(t.rate) as 'Issued Amount' 
			from tbl_transaction t join tbl_Item i on i.ItemId=t.itemId 
			where t.Date between @DateFrom and @DateTo group by t.itemId,i.ItemName,t.Date,t.rate 
	)TEMP order by Temp.itemId,TEMP.Date

SET @ItemId=(SELECT min(itemId) from #TBL_LEDGERFINAL)

WHILE @ItemId is not null
BEGIn
 Set @openingBalance=(select isnull(sum(isnull(recQuantity,0)-isnull(issQuantity,0)),0) from tbl_transaction where date<@DateFrom and itemId=@ItemId)
insert #TBL_TEMPLEDGERFINAL(item)
SELECT  distinct UPPER(item) FROM #TBL_LEDGERFINAL where itemId=@ItemId

insert #TBL_TEMPLEDGERFINAL(item,bQuantity)
SELECT 'Opening Balance --------------->',@openingBalance

set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId)
		WHILE @rate is not null
		BEGIn
		SET @balanceQuantity=(SELECT ISNULL(sum((ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
		FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)
		
		SET @Balance=(SELECT ISNULL(sum(ts.rate*(ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
		FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)

		insert #TBL_TEMPLEDGERFINAL
		SELECT TEMP1.Date,Temp1.itemId, '',TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount,ISNULL(SUM(ISNULL(TEMP2.bQuantity,0)),0)+@balanceQuantity,ISNULL(SUM(ISNULL(TEMP2.bAmount,0)),0)+@Balance from
		(
		SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
		) as TEMP1 inner join 
		(SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
		) as TEMP2 on TEMP2.RowId<=TEMP1.RowId group by TEMP1.Date,Temp1.itemId, TEMP1.item,TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount
		set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId AND rRate>@rate)
		END
		
		insert #TBL_TEMPLEDGERFINAL(item,rQuantity,iQuantity)
		(select 'Total', SUM(ISNULL(rQuantity,0)),SUM(ISNULL(iQuantity,0)) from #TBL_TEMPLEDGERFINAL where itemId=@ItemId)
SET @ItemId=(SELECT min(itemId) from #TBL_LEDGERFINAL where itemId>@ItemId)
END

SELECT 
	
	Date as 'Date',
	item as 'Item',
	rQuantity as 'Received Quantity',
	rRate as ' Received Rate',
	rAmount as 'Received Amount',
	iQuantity as 'Issued Quantity',
	iRate as ' Issued Rate',
	iAmount as 'Issued Amount',
	(bQuantity) as 'Balance Quantity',
	(bAmount) as 'Balance Amount' 
	 from #TBL_TEMPLEDGERFINAL 
	
END
GO
/****** Object:  StoredProcedure [dbo].[procGetDepartment]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  StoredProcedure [dbo].[procGetBalanceDetail]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	[procGetBalanceDetail] '5'
*/
CREATE proc [dbo].[procGetBalanceDetail]
(
 @itemId int
 )
AS
BEGIN
WITH    i AS
        (
        SELECT  t.itemId,i.ItemName,t.rate, SUM(t.recQuantity) AS qin
        FROM    tbl_transaction t 
        join tbl_Item i on i.ItemId=t.itemId
        GROUP BY
                t.itemId,rate,i.ItemName
        ),
        o AS
        (
        SELECT  t.itemId,i.ItemName,t.rate, SUM(t.issQuantity) AS qout
        FROM    tbl_transaction t 
        join tbl_Item i on i.ItemId=t.itemId
        GROUP BY
                t.itemId,rate,i.ItemName
        )
SELECT  COALESCE(i.itemId, o.itemId) AS itemId,
		COALESCE(i.itemName, o.itemName) AS ItemName,
		
        --COALESCE(qin, 0) AS stock_in,
        --COALESCE(qout, 0) AS stock_out,
        COALESCE(qin, 0) - COALESCE(qout, 0) AS quantity,
        COALESCE(i.rate, o.rate) AS Rate,
        (COALESCE(qin, 0) - COALESCE(qout, 0))*COALESCE(i.rate, o.rate) as amount
FROM    i
FULL JOIN
        o
ON      o.itemId = i.itemId and o.rate=i.rate
where o.itemId=@itemId

END
GO
/****** Object:  StoredProcedure [dbo].[procGetItem]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  StoredProcedure [dbo].[procGetVendor]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveDepartment]    Script Date: 08/04/2015 08:39:19 ******/
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
--	if(exists(select * from tbl_Department where DeptId=@DeptId))
--Begin
--Update tbl_Department set
--DepartmentName=@DepartmentName
--,DeptCode=@DeptCode
--,HOD=@HOD
--where DeptId=@DeptId
--select @DeptId
--end
--else
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
/****** Object:  StoredProcedure [dbo].[procSavedailyTransaction]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSavedailyTransaction]
(     @date date,
      @itemId int,
      @Rate float,
      @quantity money,
      @amount money,
      @Id int,
      @rec int,
      @issue int,
      @grn int,
      @isn int,
      @transactionId uniqueidentifier
)
AS
BEGIN
if(@rec=1)
BEGIN
	if(exists(select * from tbl_transaction where transactionId= @transactionId))
	Begin
	Update tbl_transaction set
	itemId=@itemId,
	Date=@date,
	recQuantity=@quantity,
	issQuantity=0,
	rate=@Rate,
	grn=@grn,
	isn=@isn
	where transactionId=@transactionId
	end
	ELSE
	BEGIN
		Insert Into tbl_transaction
		(
		ItemId,
		date,
		recQuantity,
		issQuantity,
		rate,
		grn,
		isn,
		transactionId
		)
		values
		(
		  @itemId,
		  @date,
		  @quantity,
		  0,
		  @Rate,
		  @grn,
		  @isn,
		  @transactionId
		 )
		select SCOPE_IDENTITY()
END
END
ELSE
BEGIN
if(exists(select * from tbl_transaction where transactionId= @transactionId))
	Begin
	Update tbl_transaction set
	itemId=@itemId,
	Date=@date,
	recQuantity=0,
	issQuantity=@quantity,
	rate=@Rate,
	grn=@grn,
	isn=@isn
	where transactionId=@transactionId
	end
	ELSE
	BEGIN
	Insert Into tbl_transaction
		(
		ItemId,
		date,
		recQuantity,
		issQuantity,
		rate,
		grn,
		isn,
		transactionId
		)
		values
		(
		  @itemId,
		  @date,
		  0,
		  @quantity,
		  @Rate,
		  @grn,
		  @isn,
		  @transactionId
		 )
		select SCOPE_IDENTITY()
END
END
END
GO
/****** Object:  StoredProcedure [dbo].[procSearchItem]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[dbo].[procSearchItem] 'i'
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
/****** Object:  StoredProcedure [dbo].[procSaveVendor]    Script Date: 08/04/2015 08:39:19 ******/
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
--	if(exists(select * from tbl_Vendor where VendorId=@VendorId))
--Begin
--Update tbl_Vendor set
--VendorName=@VendorName
--,Address=@Address
--,PhoneNo=@PhoneNo
--where VendorId=@VendorId
--select @VendorId
--end
--else
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
/****** Object:  Table [dbo].[tbl_ReceivedItem]    Script Date: 08/04/2015 08:39:19 ******/
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
	[Quantity] [money] NOT NULL,
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
/****** Object:  Table [dbo].[tbl_UserInfo]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  Table [dbo].[tbl_BalanceDetail]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  Table [dbo].[tbl_Balance]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  StoredProcedure [dbo].[SpGetLedgerReportTest]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[SpGetLedgerReportTest] '2015/01/01','2016/01/01'
 */
CREATE proc [dbo].[SpGetLedgerReportTest]
(
	@DateFrom date,
	@DateTo date
)
AS
BEGIN
DECLARE @ItemId int
DECLARE @Balance MONEY
DECLARE @rate MONEY
DECLARE @balanceQuantity int
IF object_id('tempdb..##TBL_LEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGERFINAL
	END
CREATE TABLE #TBL_LEDGERFINAL
	 (
		 RowId int Identity(1,1),
		 Date date,
		 itemId int,
		  item varchar(100),	      
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		   bQuantity int,
		  bAmount money
	 )
	 
	 IF object_id('tempdb..##TBL_TEMPLEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_TEMPLEDGERFINAL
	END
CREATE TABLE #TBL_TEMPLEDGERFINAL
	 (
		  Date date,
		  item varchar(100),	      
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		   bQuantity int,
		  bAmount money
	 )
	 
INSERT INTO #TBL_LEDGERFINAL
	SELECT *,Temp.[Received Quantity]-TEMP.[Issued quantity] as 'Balance Quantity',Temp.[Received Amount]-TEMP.[Issued Amount] as 'Balance Amount' FROM (
			select 
			t.Date,
			t.itemId,i.ItemName,
			 SUM(case when recQuantity>0 then recQuantity else 0 end) as 'Received Quantity',
			 t.rate as rRate,
			-- AVG(case when recQuantity>0 then rate else 0 end) as ReceivedRate,
			 SUM(case when recQuantity>0 then recQuantity else 0 end)*avg(t.rate) as 'Received Amount'
			,SUM(case when issQuantity>0 then issQuantity else 0 end) as 'Issued quantity',
			--AVG(case when issQuantity>0 then rate else 0 end) as IssuedRate,
			t.rate as iRate,
			SUM(case when issQuantity>0 then issQuantity else 0 end)*avg(t.rate) as 'Issued Amount' 
			from tbl_transaction t join tbl_Item i on i.ItemId=t.itemId 
			where t.Date between @DateFrom and @DateTo group by t.itemId,i.ItemName,t.Date,t.rate 
	)TEMP order by Temp.itemId,TEMP.Date

SET @ItemId=(SELECT min(itemId) from #TBL_LEDGERFINAL)

WHILE @ItemId is not null
BEGIn
insert #TBL_TEMPLEDGERFINAL(item)
SELECT  distinct item FROM #TBL_LEDGERFINAL where itemId=@ItemId
set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId)
		WHILE @rate is not null
		BEGIn
		SET @balanceQuantity=(SELECT ISNULL(sum((ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
		FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)
		
		SET @Balance=(SELECT ISNULL(sum(ts.rate*(ISNULL(ts.recQuantity,0)-ISNULL(ts.issQuantity,0))),0) 
		FROm tbl_transaction ts where ts.itemId=@ItemId and ts.rate=@rate and ts.Date<@DateFrom)

		insert #TBL_TEMPLEDGERFINAL
		SELECT TEMP1.Date, TEMP1.item,TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount,ISNULL(SUM(ISNULL(TEMP2.bQuantity,0)),0)+@balanceQuantity,ISNULL(SUM(ISNULL(TEMP2.bAmount,0)),0)+@Balance from
		(
		SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
		) as TEMP1 inner join 
		(SELECt * From #TBL_LEDGERFINAL where itemId=@ItemId and rRate=@rate
		) as TEMP2 on TEMP2.RowId<=TEMP1.RowId group by TEMP1.Date, TEMP1.item,TEMP1.rQuantity,TEMP1.rRate,TEMP1.rAmount,TEMP1.iQuantity,TEMP1.iRate,TEMP1.iAmount
		set @rate=(SELECT min(rRate) from #TBL_LEDGERFINAL where itemId=@ItemId AND rRate>@rate)
		END
SET @ItemId=(SELECT min(itemId) from #TBL_LEDGERFINAL where itemId>@ItemId)
END

SELECT 
	
	Date as 'Date',
	item as 'Item',
	rQuantity as 'Received Quantity',
	rRate as ' Received Rate',
	rAmount as 'Received Amount',
	iQuantity as 'Issued Quantity',
	iRate as ' Issued Rate',
	iAmount as 'Issued Amount',
	(bQuantity) as 'Balance Quantity',
	(bAmount) as 'Balance Amount' 
	 from #TBL_TEMPLEDGERFINAL
	
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveItem]    Script Date: 08/04/2015 08:39:19 ******/
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
--	if(exists(select * from tbl_Item where ItemId=@ItemId))
--Begin
--Update tbl_Item set
--ItemName=@ItemName
--,Unit=@Unit
--,Company=@Company
--,description=@description
--where ItemId=@ItemId
--select @ItemId
--end
--else
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
/****** Object:  StoredProcedure [dbo].[procSaveIssued]    Script Date: 08/04/2015 08:39:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveIssued]
(    
     @Date date,
      @itemId int,
      @unit varchar(20),
      @quantity money,
      @Rate float,
      @amount money,
      @deptId int,
      @ISN int,
      @remarks varchar(max),
      @receivedby nvarchar(50),
      @issuedby nvarchar(50),
      @Id uniqueidentifier
)

AS
SET IDENTITY_INSERT dbo.tbl_IssuedItem ON;
BEGIN
	if(exists(select * from tbl_IssuedItem where IssuedId= @Id))
	Begin
	--SET IDENTITY_INSERT dbo.tbl_ReceivedItem ON;
	Update tbl_IssuedItem set
	IssuedDate=@Date,
	ItemId=@itemId,
	Unit=@unit,
	Quantity=@quantity,
	Rate=@Rate,
	Amount=@amount,
	DeptId=@deptId,
	--ISN_NO=@ISN,
	Remarks=@remarks,
	ReceivedBy=@receivedby,
	IssuedBy=@issuedby
	where IssuedId=@Id
	--SET IDENTITY_INSERT dbo.tbl_ReceivedItem OFF;
	end
	else if(exists(select * from tbl_IssuedItem where ItemId= @itemId and Rate=@rate and IssuedDate=@Date))
	BEGIN
	Update tbl_IssuedItem set
	Quantity=Quantity-@quantity,
	Amount=Amount-@amount
	where ItemId=@itemId and Rate=@Rate and IssuedDate=@Date
	END
	else
	begin
--SET IDENTITY_INSERT dbo.tbl_ReceivedItem ON;
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
	--SET IDENTITY_INSERT dbo.tbl_ReceivedItem ON;
end	
SET IDENTITY_INSERT tbl_IssuedItem OFF
END
GO
/****** Object:  StoredProcedure [dbo].[procUserInfo]    Script Date: 08/04/2015 08:39:19 ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveUser]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveReceived]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procSaveReceived]
(    
     @Date date,
      @itemId int,
      @unit varchar(20),
      @quantity money,
      @Rate float,
      @amount money,
      @vendorId int,
      @GNR nvarchar(30),
      @remarks varchar(max),
      @receivedby nvarchar(50),
      @Id uniqueidentifier
)

AS
SET IDENTITY_INSERT dbo.tbl_ReceivedItem ON;
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
	--GRN_NO=@GNR,
	Remarks=@remarks,
	ReceivedBy=@receivedby
	where ReceivedId=@Id
	end
	--else if(exists(select * from tbl_ReceivedItem where ItemId= @itemId and Rate=@rate and ReceivedDate=@Date))
	--BEGIN
	--Update tbl_ReceivedItem set
	--Quantity=Quantity+@quantity,
	--Amount=Amount+@amount
	--where ItemId=@itemId and Rate=@Rate and ReceivedDate=@Date
	--END
	
 --if(exists(select * from tbl_ReceivedItem where GRN_NO=@GNR))
	--BEGIN
	--Update tbl_ReceivedItem set
	--ReceivedDate=@Date
	--where GRN_NO=@GNR
	--END
	
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
	GRN_NO,
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
      @GNR ,
      @remarks ,
      @receivedby,
      @Id
	)
	select SCOPE_IDENTITY()
end	
SET IDENTITY_INSERT tbl_ReceivedItem OFF
END
GO
/****** Object:  StoredProcedure [dbo].[procSaveBalanceDetail]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveBalance]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[procGetReceivedItem]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetailReport]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetReceivedDetailReport]
(
	@itemId int
)
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
where rec.ItemId=@itemId
order by ReceivedDate,GRN_NO
END
GO
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetail]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[procGetIsnWiseIssuedDetail]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[procGetIsnWiseIssuedDetail]
(
	@isn int
)
AS
BEGIN

Select 
	--rec.*,
	rec.IssuedId
      ,rec.IssuedDate as 'Date'
      ,rec.[ItemId]
      ,rec.[Unit]
      ,rec.[Quantity]
      ,rec.[Rate]
      ,rec.[Amount]
      ,rec.DeptId
      ,rec.[Remarks]
      ,rec.[ReceivedBy]
      ,rec.ISN_NO as 'ISN',
	item.ItemName,
	dept.DepartmentName
	
FROM tbl_IssuedItem rec
join tbl_Item item on item.ItemId=rec.ItemId
join tbl_Department dept on dept.DeptId=rec.DeptId
where rec.ISN_NO=@isn
order by IssuedDate,ISN_NO
END
GO
/****** Object:  StoredProcedure [dbo].[procGetGnrWiseReceivedDetail]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procGetGnrWiseReceivedDetail]
(
	@gnr int
)
AS
BEGIN

Select 
	--rec.*,
	rec.[ReceivedId]
      ,rec.[ReceivedDate] as 'Date'
      ,rec.[ItemId]
      ,rec.[Unit]
      ,rec.[Quantity]
      ,rec.[Rate]
      ,rec.[Amount]
      ,rec.[VendorId]
      ,rec.[Remarks]
      ,rec.[ReceivedBy]
      ,rec.[GRN_NO] as 'GNR',
	item.ItemName,
	vendor.VendorName
	
FROM tbl_ReceivedItem rec
join tbl_Item item on item.ItemId=rec.ItemId
join tbl_Vendor vendor on vendor.VendorId=rec.VendorId
where rec.GRN_NO=@gnr
order by ReceivedDate,GRN_NO
END
GO
/****** Object:  StoredProcedure [dbo].[getLatestGRNandISN]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getLatestGRNandISN]
AS

BEGIN
IF object_id('tempdb..##TBL_LATEST') IS NOT NULL
	BEGIN
		DROP TABLE TBL_LATEST
	END
	CREATE TABLE #TBL_LATEST
	 (
	      GRN int,
	      ISN int
	 )
	 Insert into #TBL_LATEST(GRN,ISN)
	values (
(select MAX(GRN_NO) from tbl_ReceivedItem as GRN),
(select MAX(ISN_NO) from tbl_IssuedItem as ISN))
Select * from #TBL_LATEST
END
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteReceiveDetail]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ProcDeleteReceiveDetail]
(
--@id int,
@grn nvarchar(max)
)
AS
BEGIN
DELETE From tbl_ReceivedItem where GRN_NO=@grn
DELETE From tbl_transaction where grn=@grn
END
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteissueDetail]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ProcDeleteissueDetail]
(
--@id int,
@isn nvarchar(max)
)
AS
BEGIN
DELETE From tbl_IssuedItem where ISN_NO=@isn
DELETE From tbl_transaction where isn=@isn
END
GO
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReportSummary]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReport]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetStockLedgerReport]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReportTest]    Script Date: 08/04/2015 08:39:20 ******/
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
		  iAmount money
	 )
	 IF object_id('tempdb..##TBL_Transaction') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_Transaction
	END
	CREATE TABLE #TBL_Transaction
	 (
		  itemId int,
	      Date date,
	     balance money
	 )
	 
	 IF object_id('tempdb..##TBL_LEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGERFINAL
	END
	CREATE TABLE #TBL_LEDGERFINAL
	 (
		  item varchar(100),
	      Date date,
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		  bQuantity int,
		  bAmount money
	 )
	 declare 	@itemId int
	 declare @itemName varchar(50)
	 
	 set @itemId=(select min(itemId) from tbl_ReceivedItem)
	 While(@itemId is not null)
	 Begin
	 set @itemName=(select ItemName from tbl_Item where ItemId=@itemId)
	 
	 
	 INSERT INTO #TBL_LEDGER(itemId,item,Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount) 
	Select 
			@itemId,
			@itemName,
			(isnull(rec.ReceivedDate,iss.IssuedDate)) as 'Date',
			sum(rec.Quantity) as 'Received Quantity',
			avg(rec.Rate) as Rate,
			sum(rec.Amount) as Amount,
			sum(iss.Quantity) as 'Issued Quantity',
			avg(iss.Rate) as Rate,
			sum(iss.Amount) as Amount
			from tbl_ReceivedItem rec 
			full join tbl_IssuedItem iss on iss.IssuedDate=rec.ReceivedDate
			where rec.ItemId=@itemId or iss.ItemId=@itemId
			group by rec.ReceivedDate,iss.IssuedDate
			
			
			
		INSERT INTO #TBL_Transaction(itemId,Date,balance)
			 SELECT x.itemId ,x.date
				 ,SUM(y.recQuantity)-SUM(y.issQuantity) Balance 
			  FROM tbl_transaction x 
			  JOIN tbl_transaction y ON y.itemId = x.itemId AND y.date <= x.date
			 WHERE x.itemId = @itemId GROUP BY x.date,x.itemId ORDER BY Date ASC; 
				 
				 
				 
		 set @itemId=(select min(itemId) from tbl_ReceivedItem where ItemId>@itemId)
	END	
	
	
	 INSERT INTO #TBL_LEDGERFINAL(item,Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount,bQuantity,bAmount) 
	select leg.item as 'Item',
	leg.Date as 'Date',
	leg.rQuantity as 'Received Quantity',
	leg.rRate as 'Rate',
	leg.rAmount as 'Received Amount',
	leg.iQuantity as 'Issued Quantity',
	leg.iRate as 'Rate',
	leg.iAmount as 'Issued Amount',
	t.balance,
	isnull(leg.rRate,leg.iRate)*t.balance
	from #TBL_LEDGER leg join #TBL_Transaction t on t.itemId=leg.itemId and leg.Date=t.Date
	
	
	
	select 
	 item as 'Item',
	Date as 'Date',
	rQuantity as 'Received Quantity',
	rRate as 'Rate',
	rAmount as 'Received Amount',
	iQuantity as 'Issued Quantity',
	iRate as 'Rate',
	iAmount as 'Issued Amount',
	(bQuantity) as 'Balance Quantity',
	(bAmount) as 'Balance Amount' 
	from #TBL_LEDGERFINAL
		
	
	
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReportSummary]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReport]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReportTest]    Script Date: 08/04/2015 08:39:20 ******/
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
		  itemId int,
		  item varchar(100),
	      Date date,
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money
	 )
	 IF object_id('tempdb..##TBL_Transaction') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_Transaction
	END
	CREATE TABLE #TBL_Transaction
	 (
		  itemId int,
	      Date date,
	     balance money
	 )
	 
	 IF object_id('tempdb..##TBL_LEDGERFINAL') IS NOT NULL
	BEGIN
		DROP TABLE #TBL_LEDGERFINAL
	END
	CREATE TABLE #TBL_LEDGERFINAL
	 (
		  item varchar(100),
	      Date date,
	      rQuantity int, 
		  rRate float,
		  rAmount money,
		  iQuantity int, 
		  iRate float,
		  iAmount money,
		  bQuantity int,
		  bAmount money
	 )

	 INSERT INTO #TBL_LEDGER(itemId,item,Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount) 
	Select 
			
			(isnull(rec.ItemId,iss.ItemId)) as 'Date',
			(select ItemName from tbl_Item where ItemId=@itemId),
			(isnull(rec.ReceivedDate,iss.IssuedDate)) as 'Date',
			sum(rec.Quantity) as 'Received Quantity',
			avg(rec.Rate) as Rate,
			sum(rec.Amount) as Amount,
			sum(iss.Quantity) as 'Issued Quantity',
			avg(iss.Rate) as Rate,
			sum(iss.Amount) as Amount
			from tbl_ReceivedItem rec 
			full join tbl_IssuedItem iss on iss.IssuedDate=rec.ReceivedDate
			where rec.ItemId=@itemId or iss.ItemId=@itemId
			group by rec.ReceivedDate,iss.IssuedDate,rec.ItemId,iss.ItemId
			
			
			
		INSERT INTO #TBL_Transaction(itemId,Date,balance)
			 SELECT x.itemId ,x.date
				 ,SUM(y.recQuantity)-SUM(y.issQuantity) Balance 
			  FROM tbl_transaction x 
			  JOIN tbl_transaction y ON y.itemId = x.itemId AND y.date <= x.date
			 WHERE x.itemId = @itemId AND y.itemId=@itemId GROUP BY x.date,x.itemId ORDER BY Date DESC; 
				 
	
	 INSERT INTO #TBL_LEDGERFINAL(item,Date,rQuantity,rRate,rAmount,iQuantity,iRate,iAmount,bQuantity,bAmount) 
	select leg.item as 'Item',
	leg.Date as 'Date',
	leg.rQuantity as 'Received Quantity',
	leg.rRate as 'Rate',
	leg.rAmount as 'Received Amount',
	leg.iQuantity as 'Issued Quantity',
	leg.iRate as 'Rate',
	leg.iAmount as 'Issued Amount',
	t.balance,
	isnull(leg.rRate,leg.iRate)*t.balance
	from #TBL_LEDGER leg join #TBL_Transaction t on t.itemId=leg.itemId and leg.Date=t.Date
	
	select * from #TBL_LEDGER
	select * from #TBL_Transaction
	select 
	 item as 'Item',
	Date as 'Date',
	rRate as 'Rate',
	rQuantity as 'Received Quantity',
	rAmount as 'Received Amount',
	iQuantity as 'Issued Quantity',
	--iRate as 'Rate',
	iAmount as 'Issued Amount',
	(bQuantity) as 'Balance Quantity',
	(bAmount) as 'Balance Amount' 
	from #TBL_LEDGERFINAL order by DATE asc
		
	
	
END

--Delete from tbl_Balance delete from tbl_BalanceDetail delete from tbl_transaction
--delete from tbl_ReceivedItem delete from tbl_IssuedItem
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReportSummary]    Script Date: 08/04/2015 08:39:20 ******/
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
	sum(iss.Quantity) as 'Quantity',
	AVG(iss.Rate) as 'Rate',
	SUM(iss.Amount) as 'Amount'
	FROM tbl_Department dept
	right outer join  tbl_IssuedItem iss on dept.DeptId=iss.DeptId 
	WHERE iss.ItemId=@itemId and iss.IssuedDate between @DateFrom and @DateTo
	group by dept.DepartmentName
END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReport]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetISNVoucherDetails]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[proc_GetISNVoucherDetails]
(
	@datefrom date,
	@dateTo date
)
AS
BEGIN
	select 
		rec.*,
		item.ItemName,
		ven.DepartmentName
	 from tbl_IssuedItem rec join tbl_Item item on rec.ItemId=item.ItemId
	 join tbl_Department ven on rec.DeptId=ven.DeptId
	 where rec.IssuedDate between @datefrom and @dateTo
	 order by ISN_NO 
 END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetGRNVoucherDetails]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_GetGRNVoucherDetails]
(
	@datefrom date,
	@dateTo date
)
AS
BEGIN
	select 
		rec.*,
		item.ItemName,
		ven.VendorName
	 from tbl_ReceivedItem rec join tbl_Item item on rec.ItemId=item.ItemId
	 join tbl_Vendor ven on rec.VendorId=ven.VendorId
	 where rec.ReceivedDate between @datefrom and @dateTo
	 order by GRN_NO 
 END
GO
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReportSummary]    Script Date: 08/04/2015 08:39:20 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReport]    Script Date: 08/04/2015 08:39:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[dbo].[proc_GetDepartmentWiseItemReport] '2010/01/01','2016/01/01','3'
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
/****** Object:  ForeignKey [FK__tbl_Issue__DeptI__4AB81AF0]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
/****** Object:  ForeignKey [FK__tbl_Issue__ItemI__4BAC3F29]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Issue__ItemI__4CA06362]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Recei__ItemI__4D94879B]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Recei__Vendo__4E88ABD4]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([VendorId])
REFERENCES [dbo].[tbl_Vendor] ([VendorId])
GO
/****** Object:  ForeignKey [FK__tbl_UserI__DeptI__3B75D760]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_UserInfo]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
/****** Object:  ForeignKey [FK__tbl_Balan__ItemI__3C69FB99]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_BalanceDetail]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
/****** Object:  ForeignKey [FK__tbl_Balan__ItemI__3D5E1FD2]    Script Date: 08/04/2015 08:39:19 ******/
ALTER TABLE [dbo].[tbl_Balance]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
