USE [master]
GO
/****** Object:  Database [IMS]    Script Date: 10/15/2015 10:30:01 AM ******/
CREATE DATABASE [IMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'IMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\IMS.mdf' , SIZE = 3328KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'IMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\IMS_log.LDF' , SIZE = 7616KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
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
ALTER DATABASE [IMS] SET  DISABLE_BROKER 
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
ALTER DATABASE [IMS] SET RECOVERY FULL 
GO
ALTER DATABASE [IMS] SET  MULTI_USER 
GO
ALTER DATABASE [IMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [IMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [IMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [IMS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [IMS]
GO
/****** Object:  StoredProcedure [dbo].[getLatestGRNandISN]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_DBMgmt]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetDatabaseName]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetDepartmentWiseItemReportSummary]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetGRNVoucherDetails]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetISNVoucherDetails]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseDepartmentReportSummary]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseStockLedgerReportTest]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetItemWiseVendorReportSummary]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetLedgerReportTest]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_GetStockLedgerReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[proc_VendorWiseItemReportSummary]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[ProcDeleteissueDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[ProcDeleteReceiveDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetBalanceDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetDepartment]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetGnrWiseReceivedDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetIsnWiseIssuedDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetReceivedDetailReport]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetReceivedItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procGetVendor]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveBalance]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveBalanceDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSavedailyTransaction]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveDepartment]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveIssued]    Script Date: 10/15/2015 10:30:02 AM ******/
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
	--else if(exists(select * from tbl_IssuedItem where ItemId= @itemId and Rate=@rate and IssuedDate=@Date))
	--BEGIN
	--Update tbl_IssuedItem set
	--Quantity=Quantity-@quantity,
	--Amount=Amount-@amount
	--where ItemId=@itemId and Rate=@Rate and IssuedDate=@Date
	--END
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
/****** Object:  StoredProcedure [dbo].[procSaveItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveReceived]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveUser]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSaveVendor]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procSearchItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[procUserInfo]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  StoredProcedure [dbo].[SpGetLedgerReportTest]    Script Date: 10/15/2015 10:30:02 AM ******/
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
/****** Object:  Table [dbo].[tbl_Balance]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_BalanceDetail]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_Department]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_IssuedItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Item]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_ReceivedItem]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_transaction]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_UserInfo]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_Vendor]    Script Date: 10/15/2015 10:30:02 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[tbl_Balance] ON 

INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (1, 1, 1, 0, 0.0000, CAST(0x3D3A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (2, 1, 4, 1, 3.0000, CAST(0x333A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (3, 32, 300, 60, 16140.0000, CAST(0x383A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (4, 39, 3, 1800, 5400.0000, CAST(0x333A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (5, 39, 11, 2450, 22050.0000, CAST(0x3C3A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (6, 21, 2, 160, 320.0000, CAST(0x333A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (7, 88, 12, 10, 120.0000, CAST(0x333A0B00 AS Date))
INSERT [dbo].[tbl_Balance] ([Id], [ItemId], [Quantity], [Rate], [Amount], [date]) VALUES (8, 94, 1, 114, 114.0000, CAST(0x333A0B00 AS Date))
SET IDENTITY_INSERT [dbo].[tbl_Balance] OFF
SET IDENTITY_INSERT [dbo].[tbl_Department] ON 

INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (1, N'Inventory', N'SuperAdmin', N'001')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (2, N'Cafeteria', N'Rameshwor Dhakal', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (3, N'GRADE 1 (A)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (4, N'GRADE 1 (B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (5, N'GRADE 2 (A)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (6, N'GRADE 2 (B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (7, N'GRADE 3 (A)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (8, N'GRADE 3 (B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (9, N'GRADE 4(A)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (10, N'GRADE 4(B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (11, N'GRADE 5 (B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (12, N'GRADE 5 (B)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (13, N'ECA', N'SHANKAR GAUTAM', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (14, N'ENGLISH (6,7,8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (15, N'ENGLISH (9,10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (16, N'NEPALI (6,7,8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (17, N'NEPALI (9,10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (18, N'MATH ( 6,7,8 )', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (19, N'MATH (9,10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (20, N'SOCIAL (6-8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (21, N'SOCIAL (9-10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (22, N'SCIENCE (6-8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (23, N'SCIENCE (9-10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (24, N'COMPUTER (6-8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (25, N'COMPUTER (9-10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (26, N'EPH (9-10)', N'EKTA RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (27, N'PRE VOCATIONAL (6,7,8)', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (28, N'VISUAL ARTS', N'VANI RANA', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (29, N'PERFORMING ART (MUSIC)', N'SUBASH DAHAL', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (30, N'MULTIPURPOSE (DANCE ETC)', N'SUBASH DAHAL', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (31, N'G-11 MANAGEMENT', N'EKTA RANA / MEDIN SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (32, N'G-11 (SCIENCE)', N'EKTA RANA /  MEDIN SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (33, N'G-12 ( MANAGEMENT)', N'EKTA RANA / MEDIN SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (34, N'G-12 (SCIENCE)', N'EKTA RANA / MEDIN SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (35, N'IT', N'BISHAL SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (36, N'TRANSPORTATION', N'SHAKAR SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (37, N'MAINTENANCE', N'SHAKAR SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (38, N'SECURITY', N'BISHAL SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (39, N'FRONT OFFICE', N'BISHAL SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (40, N'LIBRARY', N'MEDIN SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (41, N'ACCOUNT', N'SHAKAR SIR', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (42, N'IBDP', N'DINESH/SHANKAR/SANJEEV', N'00')
INSERT [dbo].[tbl_Department] ([DeptId], [DepartmentName], [HOD], [DeptCode]) VALUES (43, N'SCHOOL OPERATION', N'BISHAL K.C', N'00')
SET IDENTITY_INSERT [dbo].[tbl_Department] OFF
SET IDENTITY_INSERT [dbo].[tbl_IssuedItem] ON 

INSERT [dbo].[tbl_IssuedItem] ([IssuedId], [IssuedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [DeptId], [ISN_NO], [Remarks], [IssuedBy], [ReceivedBy]) VALUES (N'aeff5cfe-0594-4423-89d9-3c0ec6cdf6ea', CAST(0x853A0B00 AS Date), 16, N'PKT', 75.0000, 32, 2400.0000, 11, 1, N'rtrtert', N'Admin', N'fsdffdfdg')
INSERT [dbo].[tbl_IssuedItem] ([IssuedId], [IssuedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [DeptId], [ISN_NO], [Remarks], [IssuedBy], [ReceivedBy]) VALUES (N'9e8c0604-b84f-43e1-b2a7-54fdb2d573e6', CAST(0x853A0B00 AS Date), 16, N'PKT', 500.0000, 32, 16000.0000, 11, 1, N'rtrtert', N'Admin', N'fsdffdfdg')
SET IDENTITY_INSERT [dbo].[tbl_IssuedItem] OFF
SET IDENTITY_INSERT [dbo].[tbl_Item] ON 

INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (1, N'Exercise Book- Nepali', N'PC', N'Sparsha Printers', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (2, N'Potato (Alu)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (3, N'Cleansing Towel', N'pc', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (4, N'MALMAL CLOTH', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (5, N'MOP 175', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (6, N'MOP STICK 90', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (7, N'GARBAGE BAG ', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (8, N'MAIDA', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (9, N'KANCHAN CHEESE', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (10, N'PAPER GLASS ', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (11, N'GAS LIGHTER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (12, N'PRILL', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (13, N'SUNTALA RICE', N'BORA', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (14, N'RAHAR (NON POLISH)', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (15, N'OKI SOYA OIL ', N'JAR', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (16, N'MILK', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (17, N'DDC BUTTER', N'PC', N'DDC', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (18, N'HARIO KERAU', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (19, N'DDC GHEE REFFIL', N'KG', N'DDC', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (20, N'JEERA POWDER', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (21, N'BEPOL', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (22, N'FLOREX PHYNEL', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (23, N'BREAD 60', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (24, N'SETO TEEL', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (25, N'DRINKING CHOC ', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (26, N'DRUK VINEGAR', N'BTL', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (27, N'BMC ROGHNI', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (28, N'NAPKIN (BIG)', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (29, N'KALO JEERA', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (30, N'SALT', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (31, N'CORN FLOUR', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (32, N' Water', N'Jar(20 leters)', N'Ganga Jal', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (33, N'DRUK KETCHUP', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (34, N'NDS BUTTER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (35, N'NANGOL DOUGHNUT', N'PKT', N'NANGLO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (36, N'WAI WAI ', N'PKT', N'WAI WAI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (37, N'BRI PISTA', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (38, N'RARA ', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (39, N'Tanker Water', N'Leters', N'Godawari Water', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (40, N'CURD BOX', N'LTR', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (41, N'Tanker Water', N'Leters', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (42, N'NANGLO CROISSANT', N'PKT', N'NANGLO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (43, N'DRUK JAM', N'PCS', N'DRUK', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (44, N'MUSHROOM DRY', N'KGS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (45, N'BABY CORN', N'PCS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (46, N'BAKING POWDER', N'PCS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (47, N'Drinking Water', N'Jar', N'Ganga Jal', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (48, N'YALE ICE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (49, N'BHANBHORI SAUCE', N'BTL', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (50, N'FRAGATA OLIVE BLACK', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (51, N'ROSEMARY ', N'PC', N'SREE TARA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (52, N'QILLA XL ', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (53, N'LEONARDO EXRA OLIVE OIL', N'BTL', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (54, N'TIGER SOYA STANDARD', N'BTL', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (55, N'EGG', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (56, N'TOKLA GOLD REF', N'PKT', N'TOKLA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (57, N'NESCAFE COFFE ', N'PKT', N'NESCAFE', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (58, N'CHANA DAL', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (59, N'YEAST 500 GM', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (60, N'BMC ROGHNI 50 GM', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (61, N'MOZZRELLA CHEESE', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (62, N'DRUK CHILLI SAUCE', N'BTL', N'DRUK', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (63, N'ARIEL ', N'KG', N'ARIEL', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (64, N'BMC KASOORI METHI', N'PCS', N'BMC', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (65, N'KWATI', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (66, N'NANGLO PAUVAJI BUN', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (67, N'SETO SIMI', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (68, N'RICH CORN FLAKES', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (69, N'NESTLE CORNFLAKES', N'PKT', N'NESTLE', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (70, N'RAJMA', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (71, N'KHAIRO TEEL', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (72, N'AJINOMOTO', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (73, N'VIM POWDER', N'PC', N'VIM', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (74, N'HAHNE CORN FLAKES', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (75, N'BMC MEAT MASALA', N'PC', N'BMC', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (76, N'MEIZAN SUN', N'JAR', N'MEIZAN', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (77, N'RASWARI BOX', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (78, N'KAJU', N'KGS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (79, N'KISMIS', N'KGS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (80, N'SESANE OIL ', N'BTL', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (81, N'MUSURO', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (82, N'JEERA GEDA', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (83, N'BESAR', N'KGS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (84, N'KHURSANI POWDER', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (85, N'METHI', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (86, N'SUGAR', N'KG', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (87, N'ALFA', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (88, N'GREEN PAD', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (89, N'VIM POWDER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (90, N'TIGER NOODLES', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (91, N'MARICH POWDER', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (92, N'RUBBER GLOVE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (93, N'DHARA MUSTARD OIL', N'PKT', N'DHARA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (94, N'COLIN', N'PCS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (95, N'HARPIC', N'PCS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (96, N'A4 Size Color Paper- 100 GM', N'PC', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (97, N'Board Marker', N'PC', N'Snowmen', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (98, N'Pilot Marker', N'PC', N'Pilot', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (99, N'Permanent Marker', N'PC', N'Snowmen', N'NA')
GO
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (100, N'Pencil- Nataraj', N'PC', N'Nataraj', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (101, N'Eraser- Doms', N'PC', N'DOMS', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (102, N'Sharpner- Doms', N'PC', N'DOMS', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (103, N'Pencil Holder', N'PC', N'Huajie-Chainese', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (104, N'Paper Clip', N'pkt', N'Chinese ', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (105, N'Push Pin', N'pkt', N'Chinese ', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (106, N'Crayon ', N'pkt(12pcs)', N'Chinese ', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (107, N'Sketch Pen', N'pkt (12Pcs)', N'Chinese ', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (108, N'Color Pencil', N'Pkt (12pcs)', N'Doms', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (109, N'Graph Sheet', N'Pkt', N'Na', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (110, N' Map (out line)', N'pkt', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (111, N'Scissor', N'pc', N'Chinese ', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (112, N'Duster', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (113, N'Cler Bag', N'pc', N'Chinese ', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (114, N'Business File ( A4)', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (115, N'Business File (A$)', N'PC', N'Chinese ', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (116, N'Ring File', N'pc', N'Narayani Stationery', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (117, N'Chart Paper', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (118, N'Flip Chart', N'Pc', N'80G', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (119, N'Kite Paper', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (120, N'Glaze Paper', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (121, N'Scale 12"', N'PC', N'Natraj', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (122, N'Attendence Register', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (123, N'Box File Triangle', N'pc', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (124, N'Box File Square', N'Pc', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (125, N'Masking Tape 2"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (126, N'Masking Tape 1/2"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (127, N'Masking Tape 1"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (128, N'Cello Tape 2"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (129, N'Cello Tape 1"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (130, N'Cello Tape 1/2"', N'PC', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (131, N'Binding  Tape 2"', N'pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (132, N'Binding Tape 1½"', N'Pc', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (133, N'Binding Tape 1"', N'PC', N'Chinese ', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (134, N'Stapler Pin No.10', N'pkt (1000pcs)', N'Kangaro', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (135, N'Stapler Pin No. 24/6', N'Pkt (1000pcs)', N'Kangaro', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (136, N'Gel Pen', N'pc', N'Cello Writing Aids Pvt. Ltd.', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (137, N'Correction Pen', N'pc', N'Weib', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (138, N'Letter Head', N'pkt (500pcs)', N'80G', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (139, N'Envelope A4 Size', N'pc', N'Na', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (140, N'Phone Diary', N'pc', N'Na', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (141, N'Pen (Maxriter)', N'PC', N'Maxriter', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (142, N'Pen (Maxriter)', N'Pc', N'Cello Maxriter', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (143, N'Note Book', N'pc', N'Tashi Stationery', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (144, N'Binding Sheet A4 Size', N'Pkt (100pcs)', N'Oddy (100 MicronsI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (145, N'Lamination Film A4 Size', N'Pkt (100pcs)', N'YIDU SAILS (160 micron)', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (146, N'Single Line Exercise Book  (Nepali copy)', N'copies ', N'60g (100pgs)', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (147, N'Map (out lineline)', N'pkt (100pcs)', N'Na', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (148, N'Index File ', N'pc', N'Huajie', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (149, N'EXERCISE BOOK (INTER LEAF 4-10) ', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (150, N'EXERCISE BOOK (INTER LEAF 2-3 )', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (151, N'EXERCISE BOOK (INTERLEAF 1)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (152, N'GLUE STICK 22G', N'PC', N'AMOS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (153, N'EXERCISE BOOK (MATH BIG SQURE)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (154, N'EXERCISE BOOK (MATH SMALL SQURE)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (155, N'EXERCISE BOOK ( DRAWING)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (156, N'SKETCH BOOK (20 PG)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (157, N'EXERCISE BOOK ( ENGLISH BIG 1-2 )', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (158, N'EXERCISE COPY (ENGLISH 3-5)', N'PC', N'SPARSHA PRINTERS', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (159, N'PAPER CUTTER', N'PC', N'DELI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (160, N'PAPER CUTTER', N'PC', N'DELI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (161, N'LOOSE SHEET', N'BUNDLE', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (162, N'DOUBLE TAPA', N'PC', N'ODDY', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (163, N'PILOT PEN', N'PC', N'PILOT', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (164, N'CD MARKER', N'PC', N'CELLO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (165, N'STAMP PAD', N'PC', N'SUPREME', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (166, N'ID  CARD HOLDER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (167, N'GEOMETRY BOX', N'PC', N'MARSHAL', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (168, N'FILE DIVEDER', N'PC', N'HAOXIANG', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (169, N'ZIP LOCK BAG', N'PC', N'HAOXIANG', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (170, N'HANDBOOK', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (171, N'ULLENS BROCHURE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (172, N'IB BROCHURE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (173, N'CALENDER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (174, N'TAPE HOLDER', N'PC', N'DELI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (175, N'FEVICOL', N'PC', N'GRIPPO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (176, N'NEPALI FILE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (177, N'ULLENS T-SHIRT', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (178, N'ULLENS  CUP', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (179, N'CLIP BOARD', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (180, N'PUNCHING MACHINE', N'PC', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (181, N'TONER', N'PC', N'CANON', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (182, N'A3-SIZE PAPER', N'RIM', N'JK', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (183, N'COLOUR PALLETTE', N'PC', N'KBI', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (184, N'HIGHLIGHTER', N'PC', N'CELLO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (185, N'STAPLER MACHINE NO.10-1M', N'PKT', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (186, N'STAPLER MACHINE HS-45P', N'PKT', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (187, N'PILOT REFIL', N'PC', N'PILOT', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (188, N'ENVELOPE SMALL', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (189, N'BINDER CLIP[', N'PC', N'DIMOND', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (190, N'GLITTER PEN', N'PC', N'DIAMOND', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (191, N'STIMER ', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (192, N'BIRTHDAY CANDLE', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (193, N'LABEL SHEET', N'PKT', N'ODDY', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (194, N'SCHOOL DIARY', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (195, N'LEATHER FOLDER', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (196, N'VAN LOG BOOK', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (197, N'CHEMISTRY COPY', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (198, N'ENVELOPE MEDIUM', N'PC', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (199, N'A4 SIZE PAPER', N'RIM', N'JK', N'')
GO
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (200, N'Water', N'Tanker (8000ltrs)', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (201, N'Water (8000ltrs)', N'tanker', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (202, N'Tanker Water (8000ltrs)', N'Tanker', N'Na', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (203, N'Tanker Water (7000 Ltrs)', N'Tanker', N'Na', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (204, N'Drinking Water ', N'Jar (20Ltrs)', N'Ganga jal', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (205, N'Cauliflower', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (206, N'Beans (Seemi)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (207, N'Cabbage (Banda)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (208, N'CARROT', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (209, N'TOPHU', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (210, N'POTATO', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (211, N'POTATO (AALU)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (212, N'PAPAYA (MEWA)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (213, N'ONION', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (214, N'TOMATO', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (215, N'DHANIYA', N'Mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (216, N'Lemon (kagati)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (217, N'MANGO ', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (218, N'PANEER', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (219, N'SAAG (Chinese)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (220, N'SAAG (Rayo)', N'mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (221, N'SAAG (Toree)', N'mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (222, N'SALAD', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (223, N'CUCUMBER (KAAKRO)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (224, N'CHILLI', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (225, N'DHANIYA  (Seeds)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (226, N'GINGER (Adhuwa)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (227, N'Garlic  ', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (228, N'Brinzal (venta)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (229, N'CREAM', N'Ltrs', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (230, N'GARLIC (GREEN)', N'Mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (231, N'TOKLA TEA BAG', N'PKT', N'TOKLA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (232, N'Pharseeko munta', N'mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (233, N' TOKLA TEA BAG', N'KG', N'TOKLA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (234, N'NDS DOUGHNUT ', N'PKT', N'NDS', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (235, N'BITTER GOURD (KARELA)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (236, N'PUMPKIN (PHARSI)', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (237, N'CHILLE DRY', N'KG', N'NA', N'NA')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (238, N'NIURO SAAG', N'Mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (239, N'Palungo Saag', N'mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (240, N'PALAK', N'Kally', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (241, N'Apple', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (242, N'Chilli (Akabare)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (243, N'Cat 6 cable (Prolink)', N'box (300m)', N'prolink', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (244, N'Metal Greep ( 8)', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (245, N'Metal Greep with hook ', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (246, N'Commode Spray', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (247, N'Commode Flush Handle ', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (248, N'Hook ', N'pcs', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (249, N'Electric Thermos', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (250, N'Gas Pipe ', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (251, N'Regulator (High-Presser)', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (252, N'Clip ', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (253, N'Gown(Graduation)', N'pc', N'Best Tailor', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (254, N'Cap (Graduation)', N'pc', N'Best Tailor', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (255, N'Scaf (Graduation )', N'pc', N'Best Tailor', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (256, N'Tassels ', N'pc', N'Best Tailor', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (257, N'Ullens Register', N'copies', N'Sparsha Printers', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (258, N'White Board (6×4)', N'pc', N'indian', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (259, N'STAPLER PIN NO 23/13', N'PC', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (260, N'STAPLER PIN NO 24/6', N'PC', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (261, N'STAPLER PIN NO 23/10', N'PC', N'KANGARO', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (262, N'Tanker Water (1400ltrs)', N'Tanker', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (263, N'Dalle Musrum', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (264, N'Pate Musrum', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (265, N'Bottle Gourd (lauka)', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (266, N'Capsicum', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (267, N'Pokche Saag', N'mutha', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (268, N'Radish', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (269, N'Emly', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (270, N'Bodi ', N'kg', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (271, N'Banana', N'Dozen', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (272, N'Saffron 4g', N'pc', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (273, N'Kureelo', N'kg', N'Na', N'Na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (274, N'Jel Pen', N'pcs', N'cello', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (275, N'File (certificate )', N'pcs', N'na', N'na')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (276, N'PASTA 400', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (277, N'TOOTH PICK 30', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (278, N'BAMBOO SHOOTS', N'CAN', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (279, N'SIMI(LUKLA)', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (280, N'LUKLA(SIMI)', N'PKT', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (281, N'PHENYLE', N'5 LTR', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (282, N'School Register', N'PCS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (283, N'MIXED DAL', N'KGS', N'NA', N'')
INSERT [dbo].[tbl_Item] ([ItemId], [ItemName], [Unit], [Company], [Description]) VALUES (284, N'Folder with emboss', N'pc', N'na', N'')
SET IDENTITY_INSERT [dbo].[tbl_Item] OFF
SET IDENTITY_INSERT [dbo].[tbl_ReceivedItem] ON 

INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'02e10928-8f35-4578-a988-00d56e4d0b13', CAST(0x343A0B00 AS Date), 19, N'KG', 2.0000, 740, 1480.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9099c315-d96c-4f94-bbd7-013aeaf0c5f3', CAST(0x383A0B00 AS Date), 30, N'PKT', 10.0000, 18, 180.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5ab4ae45-da10-46ab-855f-01eca00fabe1', CAST(0x383A0B00 AS Date), 25, N'PC', 2.0000, 480, 960.0000, 2, N'4062,8536,4713,8535,', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'989fad88-6a38-4c2e-888b-01f1cdf933ae', CAST(0x333A0B00 AS Date), 134, N'pkt (1000pcs)', 137.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9e686fc3-1e98-4a8e-8e85-026452b585bc', CAST(0x3D3A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b6c7f55e-f4df-4df1-9cd4-02b0f3cac5c6', CAST(0x333A0B00 AS Date), 234, N'PKT', 2.0000, 55, 110.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9cf16383-b91c-4d62-a00d-033ea55d3526', CAST(0x353A0B00 AS Date), 236, N'KG', 30.0000, 60, 1800.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bb5bf6eb-6479-45d4-9feb-0366eecf7172', CAST(0x363A0B00 AS Date), 16, N'PKT', 70.0000, 32, 2240.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46e4d418-1d8a-4c44-b7a4-036b86a023e7', CAST(0x393A0B00 AS Date), 276, N'PKT', 65.0000, 90, 5850.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aa597900-ac74-419d-96f6-03b9c2ddc6e8', CAST(0x383A0B00 AS Date), 230, N'Mutha', 2.0000, 5, 10.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'17c8c3d0-0973-40ce-8def-04d985ec802f', CAST(0x333A0B00 AS Date), 121, N'PC', 29.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1e979d27-56b6-4662-be9f-04ecd845f3fb', CAST(0x363A0B00 AS Date), 204, N'Jar (20Ltrs)', 36.0000, 60, 2160.0000, 4, N'9984', N'Admin', 17)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'15837a21-7e79-4960-a3a1-04f980ef7f4a', CAST(0x393A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b74a670f-024d-4615-bc32-0565a7f63873', CAST(0x343A0B00 AS Date), 230, N'Mutha', 2.0000, 5, 10.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'31a2c1f8-5073-4146-8d9e-0598be8fbff7', CAST(0x333A0B00 AS Date), 122, N'PC', 19.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aac0eac5-eeb7-483e-8528-059c7e8e47f0', CAST(0x363A0B00 AS Date), 199, N'RIM', 50.0000, 330, 16500.0000, 11, N'977', N'Admin', 21)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7a5f0599-52cb-4a8e-8845-064c5393cf2c', CAST(0x3C3A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'274023ed-a60f-45b9-a19f-06a05354ace5', CAST(0x333A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'', N'Admin', 6)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'648d90fd-00ce-4cd3-8863-06a6743573c4', CAST(0x373A0B00 AS Date), 223, N'KG', 5.0000, 90, 450.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ae78b708-ec57-4115-b95a-070c3ddf2c09', CAST(0x3C3A0B00 AS Date), 67, N'KG', 10.0000, 160, 1600.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd0610f3d-c5c6-4c3c-b17d-079f8cda3cee', CAST(0x3C3A0B00 AS Date), 282, N'PCS', 182.0000, 106.2, 19328.4000, 7, N'02', N'Arati Tiwary', 48)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bd8e9e03-3514-42fe-9107-07ba8eca0000', CAST(0x333A0B00 AS Date), 214, N'KG', 10.0000, 80, 800.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'86b00a1c-0489-4756-b2bb-0804978a5a5a', CAST(0x393A0B00 AS Date), 277, N'PKT', 2.0000, 30, 60.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e91726a8-16f3-4b1c-abbf-0818b9651c12', CAST(0x363A0B00 AS Date), 55, N'PKT', 4.0000, 160, 640.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7ef8dc23-f83a-4ea1-ab78-089109eb86ce', CAST(0x3C3A0B00 AS Date), 61, N'KG', 8.0000, 610, 4880.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ec4eb593-c51f-45cd-b080-08ac084b1d76', CAST(0x3C3A0B00 AS Date), 8, N'KG', 18.0000, 42, 756.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'12ea3abb-8bda-4e3e-83a8-08b4b1f85454', CAST(0x383A0B00 AS Date), 208, N'KG', 5.0000, 100, 500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'34034f8b-73e9-4da3-b68a-0935c7c70da7', CAST(0x3D3A0B00 AS Date), 245, N'pc', 15.0000, 70, 1050.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dfd32f08-50ff-4c60-81f5-093d79f9334b', CAST(0x3C3A0B00 AS Date), 215, N'Mutha', 3.0000, 3, 9.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'eee647bd-8fc7-4a1b-959b-09f11c206d86', CAST(0x363A0B00 AS Date), 206, N'kg', 1.0000, 100, 100.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bcee56af-790a-4ad7-b0ec-09f8ca4b83c9', CAST(0x363A0B00 AS Date), 226, N'kg', 2.0000, 200, 400.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'00b55a9b-5037-4d14-ac06-0a0be1a915e6', CAST(0x3C3A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6883,6885', N'Arati Tiwary', 45)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1b8e78d4-6ea7-43c7-9970-0a0cd46ce72e', CAST(0x373A0B00 AS Date), 204, N'Jar (20Ltrs)', 30.0000, 60, 1800.0000, 4, N'9987', N'Admin', 27)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'786bc656-dcd4-4ded-9dc9-0a338d82839a', CAST(0x343A0B00 AS Date), 45, N'PCS', 3.0000, 82, 246.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'09bfc383-6d68-460e-a7a9-0c0131af8f51', CAST(0x3D3A0B00 AS Date), 16, N'PKT', 50.0000, 32, 1600.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c2109498-fe8e-4285-8f31-0c246fbf3ddc', CAST(0x363A0B00 AS Date), 9, N'KG', 4.0000, 850, 3400.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'41905e3f-f5e1-46be-81db-0ca47fd589cf', CAST(0x393A0B00 AS Date), 242, N'kg', 0.5000, 1000, 500.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0314b1ee-78e9-4d04-bf0e-0cdb27687fa9', CAST(0x333A0B00 AS Date), 136, N'pc', 30.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1ef079de-0497-4c55-a29e-0d2845668ebf', CAST(0x363A0B00 AS Date), 218, N'KG', 17.0000, 620, 10540.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c3c6b8af-f90f-4ebc-9331-0decfd4bc38c', CAST(0x333A0B00 AS Date), 86, N'KG', 50.0000, 66, 3300.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'33dfd4ca-1b9d-4af1-bdf2-0e14d4b8e12e', CAST(0x363A0B00 AS Date), 59, N'PKT', 1.0000, 250, 250.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'466379b9-f63e-490b-8659-0e2ef2e4cd2f', CAST(0x333A0B00 AS Date), 162, N'PC', 8.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'71a9bdf9-787a-416e-8f5e-0e7fe8c63b1d', CAST(0x383A0B00 AS Date), 19, N'KG', 1.0000, 740, 740.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f03128b3-c82c-4d2f-b6e6-0ee2cbbc7f9f', CAST(0x3C3A0B00 AS Date), 25, N'PC', 1.0000, 480, 480.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5d3dbd06-09fc-40eb-83fe-0ee564d1f0ef', CAST(0x353A0B00 AS Date), 237, N'KG', 1.0000, 400, 400.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0621febb-f2af-4f58-8e3a-0f6a2f8b0d68', CAST(0x343A0B00 AS Date), 72, N'PKT', 2.0000, 80, 160.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cce6ac8b-39f1-4667-a8c0-0fe2382f2de5', CAST(0x363A0B00 AS Date), 53, N'BTL', 1.0000, 1065, 1065.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3c76029c-b5f7-469d-855c-0fe3b21d09f4', CAST(0x3D3A0B00 AS Date), 105, N'pkt', 12.0000, 31, 372.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a5fad821-186d-417f-9bb1-109a5db4e74d', CAST(0x333A0B00 AS Date), 72, N'PKT', 4.0000, 80, 320.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'73395226-f41d-42c4-8aca-10a2e8bef49a', CAST(0x353A0B00 AS Date), 211, N'KG', 62.5000, 30, 1875.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'089f8e5a-ad6d-4d45-99c4-120e0170c36a', CAST(0x343A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'F3881', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'91fba3ef-6fc9-41cc-bd7b-121a4618b37c', CAST(0x383A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c5777c23-5a48-4b54-89f0-1228d2382c93', CAST(0x373A0B00 AS Date), 36, N'PKT', 5.0000, 15, 75.0000, 2, N'e7785', N'Admin', 24)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd4a95c0f-af12-4433-9785-1237449d619e', CAST(0x393A0B00 AS Date), 9, N'KG', 7.0000, 850, 5950.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4350ddd7-92f0-4136-b833-135a589d9930', CAST(0x363A0B00 AS Date), 33, N'KG', 1.0000, 785, 785.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a2deeb26-adb0-4fb8-ab91-13d85a8f2e70', CAST(0x333A0B00 AS Date), 223, N'KG', 5.0000, 90, 450.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'63769dd6-83fa-4753-be4d-1403a2906a3c', CAST(0x3D3A0B00 AS Date), 266, N'kg', 1.0000, 190, 190.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'510ac01d-efa2-471d-83dc-147137fbfc94', CAST(0x373A0B00 AS Date), 240, N'Kally', 10.0000, 50, 500.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3c37e8f8-aa5c-4cac-8f52-15b2afe86599', CAST(0x3D3A0B00 AS Date), 247, N'pc', 5.0000, 225, 1125.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e8c820d0-fe5c-4eb3-80dd-15c4be117fe3', CAST(0x3D3A0B00 AS Date), 205, N'kg', 20.0000, 100, 2000.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0c91d68a-a79e-4569-83ce-16252b0da1ee', CAST(0x363A0B00 AS Date), 213, N'KG', 20.0000, 60, 1200.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4e68ee79-c795-4e91-b702-168a65acf742', CAST(0x383A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cd859f5c-65d6-4594-928e-169cccaa37fd', CAST(0x333A0B00 AS Date), 25, N'PC', 2.0000, 480, 960.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4b1daeda-c7b7-4813-a941-16be3ecba2a0', CAST(0x3A3A0B00 AS Date), 37, N'PC', 1.0000, 80, 80.0000, 2, N'bill no.8663,', N'Hari Devkota', 38)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7feb3830-51a8-4f4a-950a-171a35c1a1b5', CAST(0x333A0B00 AS Date), 92, N'PC', 2.0000, 150, 300.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'134524a3-9560-4680-8ec0-17de9a4e833d', CAST(0x383A0B00 AS Date), 27, N'PC', 4.0000, 41, 164.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bbf2331e-b126-4b37-83a3-1aa08169c92b', CAST(0x333A0B00 AS Date), 16, N'PKT', 50.0000, 32, 1600.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'adce63c0-1809-4947-a2e6-1aed3fa6537f', CAST(0x333A0B00 AS Date), 16, N'PKT', 90.0000, 32, 2880.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f18c14cd-324d-4dcc-96f8-1b3fa88d6599', CAST(0x363A0B00 AS Date), 216, N'kg', 4.0000, 235, 940.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'76932152-cfb2-4832-bcc6-1b68a1a46995', CAST(0x3D3A0B00 AS Date), 20, N'PKT', 1.0000, 500, 500.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2c4b1a2e-cb6e-467c-ab28-1c56d20084e2', CAST(0x383A0B00 AS Date), 8, N'KG', 5.0000, 42, 210.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c6a034ef-fa93-4caa-9d7c-1c8dc8b88bd7', CAST(0x393A0B00 AS Date), 12, N'PC', 3.0000, 136, 408.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e9405ecd-cf5c-4bbb-a606-1d836c3db60d', CAST(0x383A0B00 AS Date), 34, N'PC', 8.0000, 190, 1520.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1cfa8f11-eb03-4059-941c-1d91d7e0adfa', CAST(0x363A0B00 AS Date), 17, N'PC', 9.0000, 190, 1710.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'581c8101-75e0-4ac4-9c76-1de0715bce54', CAST(0x3C3A0B00 AS Date), 55, N'PKT', 60.0000, 10, 600.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f22d564c-1831-47cb-9b23-1de193446763', CAST(0x333A0B00 AS Date), 161, N'BUNDLE', 1.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'08c07f6e-c99b-4800-a636-1fd8cbe853de', CAST(0x333A0B00 AS Date), 90, N'PKT', 13.0000, 105, 1365.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'56577e15-1eac-43ff-a3fd-2092ea6b3607', CAST(0x383A0B00 AS Date), 35, N'PKT', 1.0000, 70, 70.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c511ad56-b59b-426d-8a5e-22dbb164f347', CAST(0x333A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3a809620-6de6-42df-9880-23148f754a25', CAST(0x333A0B00 AS Date), 73, N'PC', 6.0000, 22, 132.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f0d8e001-989e-49bd-a9cb-232e7fa0385b', CAST(0x363A0B00 AS Date), 59, N'PKT', 1.0000, 250, 250.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f891d387-6614-4ce2-8e6b-2354421e79eb', CAST(0x383A0B00 AS Date), 208, N'KG', 5.0000, 100, 500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ecaa7a4e-79b7-4687-9c39-23b1d2ac6e54', CAST(0x393A0B00 AS Date), 269, N'kg', 0.5000, 220, 110.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7d1decc0-4f38-446c-a7e1-24bf6a741f3e', CAST(0x333A0B00 AS Date), 195, N'PC', 20.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5d687466-55a8-4e1e-8b9e-261d091693a1', CAST(0x363A0B00 AS Date), 213, N'KG', 1.0000, 60, 60.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3de2b166-0a32-469a-8414-2672a8cf4216', CAST(0x333A0B00 AS Date), 174, N'PC', 3.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'269c5415-5470-4c50-8dd0-26d787dfe221', CAST(0x333A0B00 AS Date), 224, N'KG', 0.5000, 900, 450.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'251b671d-a3ce-4700-8fce-26f531595fa4', CAST(0x333A0B00 AS Date), 123, N'pc', 10.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5975bdd1-4cef-426f-ab3a-27105653b1ad', CAST(0x333A0B00 AS Date), 21, N'PC', 2.0000, 160, 320.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dbbbbed2-c16c-4eb1-93be-2767f164258b', CAST(0x333A0B00 AS Date), 199, N'RIM', 10.0000, 360, 3600.0000, 15, N'422', N'Admin', 5)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'112dcf0e-1a98-4543-82bd-27d807ba2b97', CAST(0x333A0B00 AS Date), 173, N'PC', 25.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'18c95950-14b6-4ce9-b089-27e321831d50', CAST(0x363A0B00 AS Date), 43, N'PCS', 4.0000, 120, 480.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'08111a29-e1be-4539-b158-2806ee34ac8b', CAST(0x363A0B00 AS Date), 55, N'PKT', 4.0000, 165, 660.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b426e5a6-a223-4bd6-a108-281dbc9a6337', CAST(0x3D3A0B00 AS Date), 3, N'pc', 6.0000, 35, 210.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'82f4d61a-fbcc-400f-b57c-28762267d2e4', CAST(0x353A0B00 AS Date), 71, N'KG', 0.5000, 320, 160.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2f52667e-09b9-4782-99c6-28b2b9c92000', CAST(0x383A0B00 AS Date), 17, N'PC', 6.0000, 190, 1140.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ef605641-e2bf-46f6-90b2-28b85b7a02ff', CAST(0x3D3A0B00 AS Date), 205, N'kg', 15.0000, 100, 1500.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a2cda32a-187a-4f92-9239-292fe56c36f7', CAST(0x353A0B00 AS Date), 3, N'pc', 12.0000, 50, 600.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aed75c82-85da-437a-a94c-297d644f63c7', CAST(0x333A0B00 AS Date), 100, N'PC', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9dd3a217-a4e5-4537-a797-29eaaf5055fe', CAST(0x363A0B00 AS Date), 227, N'kg', 4.0000, 240, 960.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1eaf9b39-f3fe-44ff-a1ae-2a67ee6b6753', CAST(0x383A0B00 AS Date), 211, N'KG', 25.0000, 75, 1875.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'10ce4df9-544c-41dc-81e0-2a798565f10e', CAST(0x363A0B00 AS Date), 43, N'PCS', 3.0000, 120, 360.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'72751ee8-adff-4be2-b3db-2a8b8fbf1f59', CAST(0x353A0B00 AS Date), 16, N'PKT', 40.0000, 32, 1280.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'96e9c1a7-d74b-4b7b-a539-2ac9e6ce454c', CAST(0x363A0B00 AS Date), 271, N'Dozen', 20.0000, 110, 2200.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c3f6a0df-30c4-4a71-b953-2ad71f912a6e', CAST(0x333A0B00 AS Date), 274, N'pcs', 60.0000, 27, 1620.0000, 15, N'422', N'Admin', 5)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fa77da96-c701-4b9c-a51d-2b5cf409513f', CAST(0x353A0B00 AS Date), 66, N'PC', 220.0000, 14, 3080.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f575b4a9-a300-4470-a410-2b5fd93a151b', CAST(0x353A0B00 AS Date), 76, N'JAR', 1.0000, 1295, 1295.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'76ab3fb2-d093-4230-92f9-2b9adb1abfbe', CAST(0x373A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4a11f8b8-931e-4104-8728-2ba9e976e79a', CAST(0x393A0B00 AS Date), 211, N'KG', 50.0000, 28, 1400.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'84900953-8a1c-44a7-a47b-2bfb5f9b0c80', CAST(0x3D3A0B00 AS Date), 88, N'PC', 12.0000, 10, 120.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f29d1314-ed40-4cb2-9470-2c0f870dea2e', CAST(0x333A0B00 AS Date), 207, N'kg', 10.0000, 60, 600.0000, 3, N'Bill no.1544', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3b36050f-36cb-49ed-80c5-2c8c79f2e2da', CAST(0x333A0B00 AS Date), 23, N'PC', 70.0000, 60, 4200.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd79a084d-ac5b-40d1-9bfc-2d0c14a061c0', CAST(0x353A0B00 AS Date), 34, N'PC', 4.0000, 190, 760.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b487497e-c64a-430f-93e6-2d25d2d319b1', CAST(0x383A0B00 AS Date), 265, N'kg', 25.0000, 80, 2000.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fe7e8310-2241-424f-8bbc-2d37dd25b0e8', CAST(0x333A0B00 AS Date), 222, N'KG', 2.0000, 650, 1300.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'20684ee7-1338-4a16-b561-2d96096b5949', CAST(0x333A0B00 AS Date), 169, N'PC', 15.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6c0a73ad-f58f-44dd-be7c-2e486617773f', CAST(0x333A0B00 AS Date), 231, N'PKT', 4.0000, 120, 480.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'20edbbda-4e9e-43a6-bfd1-2e526e9137b2', CAST(0x353A0B00 AS Date), 211, N'KG', 25.0000, 30, 750.0000, 3, N'1804', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2cb2cc7a-82cc-4b3d-a253-2ea4ab02a390', CAST(0x353A0B00 AS Date), 216, N'kg', 2.0000, 235, 470.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'37c81ff6-5718-430d-9456-2fcb8c1d0737', CAST(0x3C3A0B00 AS Date), 91, N'PKT', 0.5000, 1600, 800.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8b012b96-f91a-47b8-92af-2ffc58c7f38e', CAST(0x353A0B00 AS Date), 227, N'kg', 2.0000, 240, 480.0000, 3, N'1804', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8070a652-ef8b-445b-8474-3009e8e9168d', CAST(0x3C3A0B00 AS Date), 270, N'kg', 1.0000, 90, 90.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b421f299-0095-45e5-83dc-301c56e29eb2', CAST(0x333A0B00 AS Date), 94, N'PCS', 1.0000, 114, 114.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'089206b9-ab2c-4a29-a055-310502c2d1a5', CAST(0x3D3A0B00 AS Date), 17, N'PC', 4.0000, 195, 780.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3a29fa80-953a-4eec-aa44-311ec891a5f3', CAST(0x333A0B00 AS Date), 21, N'PC', 3.0000, 160, 480.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'79aa21d1-6005-4fee-8675-31652f81e6f7', CAST(0x363A0B00 AS Date), 8, N'KG', 4.0000, 46, 184.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'957e25de-e51d-484d-9650-321179177c9f', CAST(0x3C3A0B00 AS Date), 214, N'KG', 0.5000, 60, 30.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'970ae1c7-a5bc-4211-9ebf-3231851d389d', CAST(0x343A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'38277dc8-109d-404f-a3ee-3283197a2f7b', CAST(0x363A0B00 AS Date), 239, N'mutha', 150.0000, 50, 7500.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f40b8567-f3b1-4a4b-8b4b-332bdd99c89f', CAST(0x363A0B00 AS Date), 58, N'KG', 2.0000, 130, 260.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'683ec008-9a5b-4d50-a5dc-3333fbd2487a', CAST(0x3D3A0B00 AS Date), 20, N'PKT', 0.5000, 500, 250.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7fc5c3db-a746-4637-aa43-33a876e8231f', CAST(0x333A0B00 AS Date), 88, N'PC', 12.0000, 10, 120.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'026feef5-5e79-4f8b-a33c-3418bc85b7a1', CAST(0x3D3A0B00 AS Date), 134, N'pkt (1000pcs)', 1.0000, 9.73, 9.7300, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fb6f80b1-6afa-4553-96f7-343304a1753c', CAST(0x363A0B00 AS Date), 16, N'PKT', 50.0000, 32, 1600.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5e5d7703-c632-4cd6-8311-34339e63203c', CAST(0x363A0B00 AS Date), 49, N'BTL', 2.0000, 275, 550.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'16cf96ef-990c-4613-9fe7-349b550d84a7', CAST(0x3D3A0B00 AS Date), 204, N'Jar (20Ltrs)', 20.0000, 60, 1200.0000, 4, N'10061', N'Arati Tiwary', 49)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9cf38eff-4e2f-4046-bd54-366eed16b38b', CAST(0x3C3A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4592af5e-a661-486b-b5fa-36723bdf7a43', CAST(0x333A0B00 AS Date), 119, N'PC', 288.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'88e7391a-676c-45ef-8fdc-36f0175bf3f9', CAST(0x3D3A0B00 AS Date), 6, N'PC', 2.0000, 90, 180.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8255abc7-d926-4778-a4cd-3707dcd4de57', CAST(0x333A0B00 AS Date), 71, N'KG', 0.5000, 320, 160.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4df42a7a-382e-4cd4-8101-37310adb9fa7', CAST(0x333A0B00 AS Date), 198, N'PC', 350.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd7de9931-fe1d-461b-866b-3797e7551a3c', CAST(0x333A0B00 AS Date), 128, N'pc', 15.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1ac72040-83ec-45e8-9a88-383c3362587d', CAST(0x343A0B00 AS Date), 272, N'pc', 1.0000, 1600, 1600.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f813c7ed-6e73-482c-ba4b-383c8133212e', CAST(0x373A0B00 AS Date), 213, N'KG', 4.0000, 50, 200.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0058922d-414c-45fa-bd16-38440d8238ea', CAST(0x333A0B00 AS Date), 30, N'PKT', 1.0000, 320, 320.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'04031264-4b2d-4c31-b0f5-38ad7311d1f0', CAST(0x363A0B00 AS Date), 227, N'kg', 4.0000, 240, 960.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'65f0f388-44c9-44e8-ad24-38d85ee4a99f', CAST(0x333A0B00 AS Date), 117, N'PC', 288.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7d2e8c5d-13e7-44cf-8bdd-38e713580d57', CAST(0x3D3A0B00 AS Date), 258, N'pc', 5.0000, 5900, 29500.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c48f8f5e-e59a-4036-ac6f-390e8be0382e', CAST(0x343A0B00 AS Date), 40, N'LTR', 20.0000, 120, 2400.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46819dbf-bf4e-419d-8c7e-3a194e246a60', CAST(0x3C3A0B00 AS Date), 55, N'PKT', 60.0000, 10, 600.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'44f61623-ec3b-42b4-8344-3a9c3463b693', CAST(0x333A0B00 AS Date), 218, N'KG', 12.0000, 620, 7440.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f93b8808-ab0a-4b42-bc01-3bdfeed1f6c5', CAST(0x353A0B00 AS Date), 64, N'PCS', 2.0000, 45, 90.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'98942c03-e58c-4f9e-bb63-3bf5b6e86ddd', CAST(0x333A0B00 AS Date), 43, N'PCS', 4.0000, 120, 480.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7c800cf2-e69c-4b5d-8c23-3c683b840444', CAST(0x373A0B00 AS Date), 44, N'KGS', 10.0000, 580, 5800.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2249ffaa-2806-4a9c-abaa-3c69f688ae89', CAST(0x393A0B00 AS Date), 241, N'kg', 45.0000, 320, 14400.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b522b3b6-440a-4e39-a081-3c6e4751687a', CAST(0x383A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e15461dd-ca29-4be3-a392-3ca8d4856808', CAST(0x383A0B00 AS Date), 211, N'KG', 30.0000, 75, 2250.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'06e8201d-a3b2-4e69-84e5-3cdd70fd49aa', CAST(0x353A0B00 AS Date), 9, N'KG', 5.9700, 850, 5074.5000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'22de515f-d876-4215-97e6-3d24f5f8d3ce', CAST(0x383A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e2d56e96-39c1-4738-8583-3da2b1566a80', CAST(0x3D3A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'eec483a0-b6ad-4d8f-9050-3dae88ea1d08', CAST(0x333A0B00 AS Date), 62, N'BTL', 1.0000, 140, 140.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7d813602-9862-4c9f-8ee8-3dd22386c0cd', CAST(0x353A0B00 AS Date), 224, N'KG', 0.5000, 1000, 500.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2e6e02ec-be7c-4bd7-afaa-3de60b8e9f14', CAST(0x333A0B00 AS Date), 187, N'PC', 24.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'22362711-969e-4463-bd7e-3f139e3d71c3', CAST(0x383A0B00 AS Date), 213, N'KG', 10.0000, 60, 600.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'735ac94b-ea58-43f9-8b4e-3f2f39dd8c57', CAST(0x363A0B00 AS Date), 214, N'KG', 0.5000, 80, 40.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b99f9a78-b5ea-422e-af0d-3f9cd0b1f189', CAST(0x333A0B00 AS Date), 81, N'KG', 10.0000, 165, 1650.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c71695f2-1bda-410f-b62b-3fa11839d0a5', CAST(0x333A0B00 AS Date), 25, N'PC', 2.0000, 480, 960.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'561e2acd-af84-4db5-8916-4010fc28f45a', CAST(0x333A0B00 AS Date), 217, N'KG', 3.0000, 80, 240.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5c129300-4b6c-45fd-8cd8-40ee4e0b1fd3', CAST(0x363A0B00 AS Date), 63, N'KG', 1.0000, 280, 280.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e6e3ca2e-a041-4bc1-ad32-41c5d6607034', CAST(0x383A0B00 AS Date), 214, N'KG', 10.0000, 80, 800.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c202e85d-4553-4285-b515-41ee4f1ad1af', CAST(0x3B3A0B00 AS Date), 213, N'KG', 1.0000, 70, 70.0000, 3, N'1841,1842,1843, 2 (gram)', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9525d0e1-cc54-4cc3-b033-426355a3e487', CAST(0x3C3A0B00 AS Date), 43, N'PCS', 2.0000, 120, 240.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ff8a0c77-d421-463a-9d65-428610610ab0', CAST(0x333A0B00 AS Date), 43, N'PCS', 2.0000, 120, 240.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4b37a87d-a8db-4687-9cfb-4326b692b7c4', CAST(0x383A0B00 AS Date), 26, N'BTL', 2.0000, 30, 60.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ea074fcf-ec75-48b1-85cd-43a4aef6d68a', CAST(0x353A0B00 AS Date), 214, N'KG', 20.0000, 80, 1600.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fa4537f6-1302-41f1-b3f4-43baa1d72eac', CAST(0x343A0B00 AS Date), 214, N'KG', 0.5000, 80, 40.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'92bfd54b-8a2f-4362-85be-44099c9f50cd', CAST(0x3B3A0B00 AS Date), 37, N'PC', 1.0000, 80, 80.0000, 2, N'E7980', N'Arati Tiwary', 42)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'219984ec-bc0e-4583-b8d1-44301ab78099', CAST(0x333A0B00 AS Date), 148, N'pc', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f5eab1b2-4c1f-4536-a6cb-4605bcee88c0', CAST(0x383A0B00 AS Date), 9, N'KG', 5.0000, 850, 4250.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9706842b-874a-4d79-bbb3-469e0a09953a', CAST(0x333A0B00 AS Date), 105, N'pkt', 30.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'de6e25c7-e34a-46ee-94e2-46db825538b1', CAST(0x3D3A0B00 AS Date), 226, N'kg', 2.0000, 190, 380.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5d3d7ece-774d-4435-b0cd-47b2a0dde4f5', CAST(0x333A0B00 AS Date), 84, N'KG', 1.0000, 320, 320.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cd8380b9-e3b7-4827-8aee-47f6c59f73e2', CAST(0x333A0B00 AS Date), 131, N'pc', 3.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'43425502-7ec6-4eef-a5f6-481fe1bc4698', CAST(0x363A0B00 AS Date), 214, N'KG', 0.5000, 80, 40.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'da63d238-ea8b-4a8d-92c3-49c5e38e7488', CAST(0x353A0B00 AS Date), 3, N'pc', 12.0000, 50, 600.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3bc6eca1-33c2-490f-b372-49d64a2e2efd', CAST(0x363A0B00 AS Date), 52, N'PKT', 2.0000, 1790, 3580.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'07481a00-c7e3-46d6-803b-4a6dc09196b4', CAST(0x3D3A0B00 AS Date), 104, N'pkt', 24.0000, 23, 552.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1ae6fde3-e33d-4e01-9874-4a9c3e76a699', CAST(0x393A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6642', N'Hari Devkota', 35)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3cd61b0d-a5d7-4faa-b330-4aea46960abc', CAST(0x3D3A0B00 AS Date), 206, N'kg', 10.0000, 100, 1000.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a8687252-d5f2-4650-b33a-4b6326e7b4f7', CAST(0x383A0B00 AS Date), 29, N'KG', 0.5000, 500, 250.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6c0e7a00-d198-4078-aba4-4b6f313d9d98', CAST(0x383A0B00 AS Date), 265, N'kg', 20.0000, 80, 1600.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c999112a-7975-4828-a18a-4c08e51c49b3', CAST(0x3C3A0B00 AS Date), 206, N'kg', 1.0000, 100, 100.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f83b351a-5c21-4782-a6d2-4c10fec218fb', CAST(0x353A0B00 AS Date), 75, N'PC', 3.0000, 150, 450.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a16c6f6d-1fd1-414a-ae4e-4c2e352bb580', CAST(0x3D3A0B00 AS Date), 214, N'KG', 0.4000, 80, 32.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f2a34f83-483c-4374-88a1-4c34a954ffaf', CAST(0x363A0B00 AS Date), 230, N'Mutha', 2.0000, 5, 10.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cf0e86f6-c45f-4e4e-92d7-4c9eba137368', CAST(0x353A0B00 AS Date), 235, N'KG', 12.0000, 80, 960.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1a3615c0-10f1-4da7-aea0-4ce191e271ce', CAST(0x3C3A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b4952305-cfae-416f-90f2-4d93c1b84b56', CAST(0x363A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a8b89aab-87f3-4a01-b5c0-4e000aa51599', CAST(0x3A3A0B00 AS Date), 206, N'kg', 1.2000, 90, 108.0000, 3, N'Bill no.1840,1839', N'Hari Devkota', 41)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6f1949e6-a2e7-4ae1-aace-4e129650df99', CAST(0x3D3A0B00 AS Date), 204, N'Jar (20Ltrs)', 24.0000, 60, 1440.0000, 4, N'10061', N'Arati Tiwary', 49)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ad111849-ab2d-408e-8a88-4e1a42e6c829', CAST(0x3D3A0B00 AS Date), 214, N'KG', 15.0000, 75, 1125.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9e8a6032-630a-49f6-8e66-4e4204e2bf19', CAST(0x3D3A0B00 AS Date), 9, N'KG', 4.6000, 850, 3910.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'066fc524-197a-47b5-8772-4e61238b509e', CAST(0x333A0B00 AS Date), 147, N'pkt (100pcs)', 8.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5d2652fa-4dd7-4aa9-846b-4f5dcecd6c6f', CAST(0x383A0B00 AS Date), 224, N'KG', 0.5000, 1000, 500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4a44d2e5-571b-4f72-ad3a-4f8267f685ea', CAST(0x373A0B00 AS Date), 226, N'kg', 1.0000, 200, 200.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f0d0c30c-018e-43d1-80e8-4f91b10fa7c8', CAST(0x3B3A0B00 AS Date), 36, N'PKT', 5.0000, 15, 75.0000, 2, N'E7980', N'Arati Tiwary', 42)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dfae628a-a3a1-4654-be1d-4faf506368db', CAST(0x353A0B00 AS Date), 273, N'kg', 3.0000, 450, 1350.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cf1864c9-c5c0-4413-adec-5045614c69e9', CAST(0x3D3A0B00 AS Date), 227, N'kg', 2.0000, 240, 480.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'89101e54-5761-46f9-acd4-505309f26976', CAST(0x3C3A0B00 AS Date), 28, N'PKT', 50.0000, 35, 1750.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'91429449-4ef1-464d-84ed-509c02b7a812', CAST(0x3C3A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2bb888ea-9b76-40e3-81b8-5150dc4444c5', CAST(0x333A0B00 AS Date), 191, N'PC', 20.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a12d532d-347f-4a48-9f0d-51d964ee6f9d', CAST(0x3A3A0B00 AS Date), 214, N'KG', 0.4000, 75, 30.0000, 3, N'Bill no.1840,1839', N'Hari Devkota', 41)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'75c54c7f-4a42-45b2-91a8-5296b52c34fd', CAST(0x3D3A0B00 AS Date), 216, N'kg', 4.0000, 240, 960.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'55d1fd17-0511-42da-819a-52d273f957c3', CAST(0x3D3A0B00 AS Date), 115, N'PC', 100.0000, 23, 2300.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e9a6bb33-701c-4892-a860-52d6cb9b8144', CAST(0x353A0B00 AS Date), 75, N'PC', 3.0000, 150, 450.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'82006901-44f6-4042-b248-53594186f223', CAST(0x3C3A0B00 AS Date), 281, N'5 LTR', 1.0000, 325, 325.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3e92e049-3589-404f-8aa4-53b3bd587b06', CAST(0x3D3A0B00 AS Date), 58, N'KG', 9.0000, 128, 1152.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e2517ece-bc82-4be4-a388-542148f1dab6', CAST(0x3D3A0B00 AS Date), 117, N'PC', 1.0000, 1080, 1080.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'19277185-fb75-4151-acf2-54293dcaadcb', CAST(0x333A0B00 AS Date), 182, N'RIM', 1.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c40ba6c0-27e8-4331-bbd6-549c2cad0957', CAST(0x353A0B00 AS Date), 6, N'PC', 2.0000, 90, 180.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a6201031-7ab6-48bf-a038-54cc2d35da6b', CAST(0x393A0B00 AS Date), 8, N'KG', 4.0000, 42, 168.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ffb2dc55-2fae-4cd7-b7f5-554df10ff27b', CAST(0x333A0B00 AS Date), 212, N'KG', 100.0000, 85, 8500.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fad6154a-e4e8-4fa2-a56c-55965dbf71e5', CAST(0x3D3A0B00 AS Date), 209, N'KG', 30.0000, 25, 750.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'81287a4e-da95-4ce6-98b3-5639395c3a5e', CAST(0x3D3A0B00 AS Date), 244, N'pc', 40.0000, 40, 1600.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a6610472-cc28-4b6e-9227-56661e40a916', CAST(0x353A0B00 AS Date), 74, N'PKT', 8.0000, 310, 2480.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ea4409c0-96ec-4857-8fea-56a3d6670a3d', CAST(0x343A0B00 AS Date), 213, N'KG', 1.0000, 60, 60.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'28d3aa7b-b994-4029-be36-56c9821971f8', CAST(0x333A0B00 AS Date), 164, N'PC', 9.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2e837be9-6a0a-40ec-8364-56d1096b8ba8', CAST(0x333A0B00 AS Date), 97, N'PC', 35.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'05f1a56c-54ac-4d7e-b023-56dc46008044', CAST(0x363A0B00 AS Date), 62, N'BTL', 1.0000, 140, 140.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0c615f5a-2daa-4af5-9255-57c485ed0127', CAST(0x333A0B00 AS Date), 42, N'PKT', 60.0000, 70, 4200.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7b1ef07a-3f97-47fe-93c2-57e8f97f22e6', CAST(0x373A0B00 AS Date), 214, N'KG', 0.5000, 80, 40.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3716337a-0f0e-4a65-9ebc-5816997e44eb', CAST(0x3D3A0B00 AS Date), 248, N'pcs', 5.0000, 50, 250.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'325941a3-d888-4e4c-a944-582213eef535', CAST(0x353A0B00 AS Date), 31, N'PKT', 10.0000, 75, 750.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd12ea4db-86c1-46f9-8db8-58a7dc39e8db', CAST(0x3C3A0B00 AS Date), 23, N'PC', 45.0000, 60, 2700.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a5bb188e-e214-44d5-bd68-594b21216eae', CAST(0x333A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e6c2cd5a-97a8-4572-b3fa-5985179c9da0', CAST(0x3D3A0B00 AS Date), 102, N'PC', 20.0000, 75.21, 1504.2000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'71bc1e51-492a-45b1-824f-598b10a11e0e', CAST(0x3B3A0B00 AS Date), 230, N'Mutha', 2.0000, 6, 12.0000, 3, N'1841,1842,1843, ', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'04669b12-6986-4d89-9a38-59bfc2ad59ad', CAST(0x3C3A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e41d88df-023e-4aac-8b62-59ee749832aa', CAST(0x333A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3a0bc6aa-e0ad-4bb0-b0d1-59f83ca3de1c', CAST(0x3C3A0B00 AS Date), 44, N'KGS', 2.0000, 1300, 2600.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'41515e5a-8987-42ca-a706-5a80d4268390', CAST(0x333A0B00 AS Date), 185, N'PKT', 2.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9dac9ba9-5950-4abf-a288-5a8153ec17c8', CAST(0x383A0B00 AS Date), 255, N'pc', 18.0000, 350, 6300.0000, 9, N'1000', N'Admin', 31)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'82d18265-89a5-4508-a5d3-5a9e99f2d347', CAST(0x3D3A0B00 AS Date), 246, N'pc', 5.0000, 650, 3250.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2681423d-3e44-45b8-9d8d-5aa54be32234', CAST(0x333A0B00 AS Date), 102, N'PC', 100.0000, 4.75, 475.0000, 15, N'422', N'Admin', 5)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3cca6f17-a66c-468b-be1c-5b46ceb048d5', CAST(0x3C3A0B00 AS Date), 33, N'KG', 1.0000, 785, 785.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bd401a0e-bb99-410e-999b-5be96259b43b', CAST(0x3C3A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6883,6885', N'Arati Tiwary', 45)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a25762bb-c71d-40f3-b22f-5bf5f7139eb8', CAST(0x3C3A0B00 AS Date), 278, N'CAN', 12.0000, 105, 1260.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9860bf93-c7e9-4ae6-8114-5c460c969e11', CAST(0x343A0B00 AS Date), 80, N'BTL', 1.0000, 310, 310.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd9f87849-7160-4eb2-8430-5c7a2512c005', CAST(0x3C3A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'108', N'Arati Tiwary', 44)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'711e3614-c32a-408f-9359-5cad40f07382', CAST(0x3C3A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'73c9f80c-470f-455f-b1a8-5d74c13d7db1', CAST(0x3C3A0B00 AS Date), 9, N'KG', 5.2100, 850, 4428.5000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9b084cd6-8784-4979-8701-5e4f8cf58f16', CAST(0x343A0B00 AS Date), 79, N'KGS', 2.0000, 550, 1100.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'81f7fca5-28c9-4716-a4c5-5e7a54292476', CAST(0x353A0B00 AS Date), 67, N'KG', 9.0000, 160, 1440.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'54f028fc-ec2f-454f-93e2-5ebc232c16e8', CAST(0x353A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ad93ce25-0fb2-4dd8-b393-5ee43edaddb5', CAST(0x333A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1231b983-be37-45b2-8962-5f2143141b0e', CAST(0x363A0B00 AS Date), 241, N'kg', 5.0000, 310, 1550.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cd103327-73a9-4eef-a251-5f33a79af221', CAST(0x333A0B00 AS Date), 167, N'PC', 24.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1acfe21e-9ca7-4e4f-8147-5f5f548e2200', CAST(0x333A0B00 AS Date), 87, N'PC', 12.0000, 8, 96.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'158b019d-76ec-4822-a6ee-5fcf9e9e86f5', CAST(0x333A0B00 AS Date), 1, N'PC', 690.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b686ca89-1d84-4982-8b80-602acd2b4788', CAST(0x333A0B00 AS Date), 184, N'PC', 5.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9d86066d-d0c4-4105-9486-6060ee048625', CAST(0x393A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'105', N'Hari Devkota', 34)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b77c4fe1-f0a6-400a-a7d4-60624e3e7553', CAST(0x3D3A0B00 AS Date), 23, N'PC', 4.0000, 60, 240.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'14c87569-14b2-4397-bb19-60971164ac4b', CAST(0x3D3A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'afec9570-6180-45d0-90b4-60bc5a9e32b4', CAST(0x363A0B00 AS Date), 8, N'KG', 15.0000, 46, 690.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1664f83d-a4c5-49ca-b27d-61060aa44a2f', CAST(0x3D3A0B00 AS Date), 208, N'KG', 5.0000, 115, 575.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0bee0879-6e02-49e1-b107-611618567cdf', CAST(0x383A0B00 AS Date), 254, N'pc', 18.0000, 950, 17100.0000, 9, N'1000', N'Admin', 31)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2af797fd-51c8-4dba-b4f8-6124920ec416', CAST(0x393A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'57ff44a0-f5f5-4ca0-9d24-618e39a42958', CAST(0x363A0B00 AS Date), 23, N'PC', 40.0000, 60, 2400.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9010f895-928c-4a6b-86c7-61fcfc3e3811', CAST(0x363A0B00 AS Date), 214, N'KG', 10.0000, 80, 800.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8d06c74b-b775-4504-8ef9-6266807f728a', CAST(0x343A0B00 AS Date), 70, N'KG', 1.0000, 120, 120.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a5aa3d0d-c69f-4a11-a2c6-626e1ad06a62', CAST(0x333A0B00 AS Date), 145, N'Pkt (100pcs)', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'832ead54-e8c3-4b9d-a309-626e1def9f1d', CAST(0x333A0B00 AS Date), 168, N'PC', 4.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0d29d4b3-78bf-4314-93a6-628f1a3c7e1a', CAST(0x3A3A0B00 AS Date), 214, N'KG', 0.4000, 75, 30.0000, 3, N'Bill no.1840,1839', N'Hari Devkota', 41)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'eb61ba34-5714-4299-b618-6295ceef85fd', CAST(0x383A0B00 AS Date), 216, N'kg', 2.0000, 250, 500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'67015b03-74db-4ba7-831a-63500e5ce2f4', CAST(0x333A0B00 AS Date), 189, N'PC', 96.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'92e9c7a2-a893-44aa-a0d9-638983a56fe8', CAST(0x333A0B00 AS Date), 120, N'PC', 288.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0558a919-3fe5-43e7-95e3-63e399fdb824', CAST(0x383A0B00 AS Date), 266, N'kg', 1.0000, 200, 200.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'86dbea7d-2f7a-414a-ae0e-642fdec70bf9', CAST(0x393A0B00 AS Date), 217, N'KG', 5.0000, 120, 600.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3ad7a023-b823-469c-928b-650d78406e62', CAST(0x333A0B00 AS Date), 132, N'Pc', 7.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6a5cabd8-6214-4494-9de9-6579949cbed9', CAST(0x353A0B00 AS Date), 214, N'KG', 15.0000, 80, 1200.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c52bf2ad-246f-426c-aeaa-657c7c14943e', CAST(0x363A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd77072bf-12a2-4fa0-8d39-658bad1cefa9', CAST(0x3D3A0B00 AS Date), 271, N'Dozen', 19.0000, 100, 1900.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'01c9845d-1bf9-474f-b655-65b7a3ee43ed', CAST(0x373A0B00 AS Date), 37, N'PC', 1.0000, 80, 80.0000, 2, N'e7785', N'Admin', 24)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0b9c1991-e147-4bde-bff3-664fec70f0ab', CAST(0x3B3A0B00 AS Date), 224, N'KG', 1.0000, 20, 20.0000, 3, N'1841,1842,1843,', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'204b278f-583b-42dc-8a6f-6685d36d5770', CAST(0x383A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'101,102', N'Admin', 29)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b8819431-54e4-4a38-94b7-66daa77df435', CAST(0x393A0B00 AS Date), 204, N'Jar (20Ltrs)', 43.0000, 60, 2580.0000, 4, N'9997', N'Hari Devkota', 36)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6a900273-621f-49f5-a5eb-671ef503a9b1', CAST(0x363A0B00 AS Date), 61, N'KG', 7.0000, 610, 4270.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e00795b8-7073-4865-a2d1-67871a71ee36', CAST(0x373A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6880', N'Admin', 26)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5b139f62-14fd-41a1-895b-6865f5d04b9b', CAST(0x383A0B00 AS Date), 23, N'PC', 55.0000, 60, 3300.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'43052d90-fc01-4de4-85a6-69536edd5588', CAST(0x333A0B00 AS Date), 108, N'Pkt (12pcs)', 23.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'368fd858-e429-47ef-b22e-69e105840e7f', CAST(0x333A0B00 AS Date), 226, N'kg', 2.0000, 200, 400.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'50515104-2142-44a9-84af-69eb3f2d0626', CAST(0x3C3A0B00 AS Date), 36, N'PKT', 5.0000, 15, 75.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4f14e2a7-01f9-465d-85d7-6a0062a72e04', CAST(0x333A0B00 AS Date), 154, N'PC', 2000.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'baf52991-2f2f-4d1e-a77d-6a96c0aae6dd', CAST(0x3D3A0B00 AS Date), 144, N'Pkt (100pcs)', 3.0000, 376.11, 1128.3300, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'28617f0b-1853-4279-b6ca-6aca17de728c', CAST(0x333A0B00 AS Date), 96, N'PC', 1040.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1d753529-1b31-47e8-81ef-6b08649f7f0c', CAST(0x333A0B00 AS Date), 216, N'kg', 3.0000, 230, 690.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0a9df31b-9584-4c53-979c-6b7a74930976', CAST(0x363A0B00 AS Date), 43, N'PCS', 2.0000, 120, 240.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'855b7e83-d234-4577-ad43-6bdd3205bd7b', CAST(0x353A0B00 AS Date), 215, N'Mutha', 2.0000, 45, 90.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c8fd315e-5e7b-4a7e-b704-6d00b0a9950a', CAST(0x333A0B00 AS Date), 156, N'PC', 1600.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5b2720dc-7480-48b1-a45f-6d1b368b890e', CAST(0x333A0B00 AS Date), 98, N'PC', 20.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a35c6ef3-5991-477b-b993-6d9c5dc4b0a9', CAST(0x333A0B00 AS Date), 135, N'Pkt (1000pcs)', 18.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9f6d1d72-0c98-42ec-818e-6e3321c93568', CAST(0x333A0B00 AS Date), 17, N'PC', 9.0000, 195, 1755.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e7e1b635-a4b8-4a56-9850-6f26786b7b1d', CAST(0x353A0B00 AS Date), 40, N'LTR', 50.0000, 120, 6000.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a4395a67-6ad8-40a3-87df-6fefa3f81e67', CAST(0x3C3A0B00 AS Date), 8, N'KG', 14.0000, 46, 644.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b953fb49-4bc2-45f5-ac5f-706441249269', CAST(0x363A0B00 AS Date), 271, N'Dozen', 20.0000, 110, 2200.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cbd2034f-ea05-4977-bfc8-7070e99dd626', CAST(0x393A0B00 AS Date), 9, N'KG', 5.5200, 850, 4692.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2d93008b-573f-4af9-b21c-713036750719', CAST(0x3C3A0B00 AS Date), 215, N'Mutha', 1.0000, 20, 20.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f5d4de82-4afa-488a-b490-714e5edd96be', CAST(0x333A0B00 AS Date), 179, N'PC', 2.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f8c4770e-5fca-4eee-a2c5-71892ad28678', CAST(0x383A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'77c48876-044b-48e0-8feb-71b34186d717', CAST(0x333A0B00 AS Date), 129, N'pc', 7.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ebcffa31-adcf-463e-a158-71edc7984289', CAST(0x333A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'64a9d559-9cee-4203-9a38-720243282b92', CAST(0x383A0B00 AS Date), 266, N'kg', 1.0000, 200, 200.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'94920a73-668b-45e2-a2e6-725a1cefaf3e', CAST(0x3D3A0B00 AS Date), 145, N'Pkt (100pcs)', 5.0000, 519, 2595.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5fe84331-2a44-481d-b95e-72b0603bc511', CAST(0x363A0B00 AS Date), 61, N'KG', 7.0000, 610, 4270.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'850160c6-714a-42c1-ae8a-72b2b2a2a448', CAST(0x393A0B00 AS Date), 214, N'KG', 10.0000, 75, 750.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aff0966b-3f42-452a-9a15-745fa8b0e0d8', CAST(0x3C3A0B00 AS Date), 61, N'KG', 8.0000, 610, 4880.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'32dc00b1-3a25-4bb8-958e-74a38acc38f2', CAST(0x383A0B00 AS Date), 204, N'Jar (20Ltrs)', 19.0000, 60, 1140.0000, 4, N'9991', N'Admin', 28)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fdb2d833-253b-40dc-8255-74b5cd68915d', CAST(0x353A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'24d393ab-0c3e-4b73-b3de-756e41daca52', CAST(0x3D3A0B00 AS Date), 263, N'kg', 2.0000, 560, 1120.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c6516075-3866-4926-b298-75ccf60fb277', CAST(0x333A0B00 AS Date), 188, N'PC', 2400.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7db18db6-294e-43ae-9625-767f76fa615c', CAST(0x393A0B00 AS Date), 11, N'PC', 4.0000, 125, 500.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a7c61f7b-a0d8-4425-ba24-76df8ff42c8b', CAST(0x333A0B00 AS Date), 88, N'PC', 12.0000, 10, 120.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f4cc461f-ba22-4105-91e8-770507b39a3a', CAST(0x3D3A0B00 AS Date), 141, N'PC', 270.0000, 14.15, 3820.5000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd58bbcbb-9c30-4673-8eea-7761392d2817', CAST(0x343A0B00 AS Date), 61, N'KG', 3.0000, 610, 1830.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e47c1a25-d7d6-4c50-b021-7877e60daf8f', CAST(0x3D3A0B00 AS Date), 227, N'kg', 2.0000, 240, 480.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f8d9096e-d95a-4c2c-9b5e-7879c14ac79d', CAST(0x333A0B00 AS Date), 150, N'PC', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8f6f6557-8649-4fc1-a4ba-78c6c1f00a82', CAST(0x383A0B00 AS Date), 67, N'KG', 0.5000, 330, 165.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1cf05431-5da8-4f40-9c17-78d5abac184b', CAST(0x333A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'658e27b9-ec74-4711-8fed-793ab612e524', CAST(0x333A0B00 AS Date), 107, N'pkt (12Pcs)', 141.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1d04774a-51ab-4a59-bd9c-7986a01421eb', CAST(0x3C3A0B00 AS Date), 277, N'PKT', 2.0000, 30, 60.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e524f2ac-e4a0-44c8-b523-79b32e426a00', CAST(0x3C3A0B00 AS Date), 40, N'LTR', 50.0000, 120, 6000.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b97fc22d-f0a7-48da-84ef-7a62df04cabc', CAST(0x333A0B00 AS Date), 175, N'PC', 4.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'39ae9aa8-f66b-4c86-9568-7a9594b5e29b', CAST(0x3D3A0B00 AS Date), 5, N'PC', 2.0000, 175, 350.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ad6171e6-bb88-4ff6-b966-7ad2a8b2629b', CAST(0x393A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd2809132-1d8a-4bbb-ad6f-7b44a1078e63', CAST(0x373A0B00 AS Date), 222, N'KG', 1.0000, 625, 625.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'165634af-7b70-438a-8927-7b752f268234', CAST(0x3D3A0B00 AS Date), 263, N'kg', 2.0000, 560, 1120.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b526831c-fcd1-4bb9-88c4-7bd068737800', CAST(0x3C3A0B00 AS Date), 16, N'PKT', 3.0000, 32, 96.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5587a929-4d23-48eb-8cde-7c0c54f6d731', CAST(0x3D3A0B00 AS Date), 40, N'LTR', 50.0000, 120, 6000.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7e829c15-e903-4184-aca7-7c1787eafad7', CAST(0x353A0B00 AS Date), 65, N'KG', 10.0000, 120, 1200.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'715411ec-8526-4dcf-a43d-7c58ffd856b0', CAST(0x3C3A0B00 AS Date), 40, N'LTR', 60.0000, 120, 7200.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'438aee63-7c39-474b-8c51-7cbe1708a35a', CAST(0x363A0B00 AS Date), 44, N'KGS', 0.2600, 1200, 312.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f934a3bc-1e85-40ef-83c8-7e0442dbfa0c', CAST(0x373A0B00 AS Date), 215, N'Mutha', 2.0000, 5, 10.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9bdfd945-6531-4d7f-812a-7efb7c35f236', CAST(0x3C3A0B00 AS Date), 154, N'PC', 396.0000, 22.84, 9044.6400, 7, N'02', N'Arati Tiwary', 48)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e56a9e91-1bfe-4cbe-bf0a-7f3324fac6d9', CAST(0x383A0B00 AS Date), 33, N'KG', 1.0000, 785, 785.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9f56f05a-0f2f-46b8-aff1-7fe5b0a26fe3', CAST(0x333A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'db5e9d99-d0c6-4c53-a2d9-802342346d27', CAST(0x333A0B00 AS Date), 224, N'KG', 0.5000, 900, 450.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'315992e4-9d96-4ca2-b1fb-80c407c3e9dd', CAST(0x393A0B00 AS Date), 68, N'PKT', 10.0000, 240, 2400.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd5fc1de2-254f-447e-b1f5-80f90369be77', CAST(0x333A0B00 AS Date), 165, N'PC', 2.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a589c57e-29c6-44c4-ad7a-81a9085e582b', CAST(0x363A0B00 AS Date), 17, N'PC', 10.0000, 190, 1900.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c88b32e0-6ad9-4805-94eb-81bee2534dd0', CAST(0x333A0B00 AS Date), 102, N'PC', 50.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0fc5388f-0409-4264-89e5-81d7faef1abf', CAST(0x333A0B00 AS Date), 153, N'PCS', 250.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9c4295c9-ee44-4b5d-8c9b-82092d369432', CAST(0x393A0B00 AS Date), 211, N'KG', 50.0000, 28, 1400.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aeab5293-4b10-448c-b2f6-82275f12de2e', CAST(0x333A0B00 AS Date), 219, N'kg', 30.0000, 135, 4050.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'960b7b76-6d39-4646-b0d2-822b7eed6581', CAST(0x333A0B00 AS Date), 171, N'PC', 1000.0000, 0, 0.0000, 1, N' ', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e2e83c38-ae6f-457d-9faf-82432a95bb85', CAST(0x333A0B00 AS Date), 33, N'KG', 2.0000, 785, 1570.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'170aee43-5eef-43e6-aba0-83b6fe29d5b2', CAST(0x353A0B00 AS Date), 213, N'KG', 20.0000, 60, 1200.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6f13f7b4-24c1-45c0-b0a0-8451b1f6b4fc', CAST(0x363A0B00 AS Date), 240, N'Kally', 150.0000, 50, 7500.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46ce7fc5-87b9-4407-849c-84ab2cc7d02f', CAST(0x3D3A0B00 AS Date), 251, N'pc', 1.0000, 850, 850.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a998a0e5-a675-4430-b962-84bb55b57a70', CAST(0x353A0B00 AS Date), 224, N'KG', 0.5000, 1000, 500.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'33adb241-dff7-424a-9e02-8508558e694d', CAST(0x3D3A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2d2e459a-e9bc-45d5-95d3-852e87026f17', CAST(0x363A0B00 AS Date), 208, N'KG', 5.0000, 100, 500.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6b121007-beab-4e08-a8b3-8544d958498f', CAST(0x353A0B00 AS Date), 68, N'PKT', 5.0000, 160, 800.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bb38e7fe-648c-4a72-85d5-855fe98bddfd', CAST(0x383A0B00 AS Date), 263, N'kg', 2.0000, 550, 1100.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'91be7b0f-3c15-4f92-a8d8-85664722a071', CAST(0x3C3A0B00 AS Date), 230, N'Mutha', 3.0000, 7, 21.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1849c268-ed19-4f8a-a1bb-860e8f0c2930', CAST(0x383A0B00 AS Date), 23, N'PC', 40.0000, 60, 2400.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3631d1af-8736-4cda-a809-873aaa092dd9', CAST(0x383A0B00 AS Date), 31, N'PKT', 2.0000, 75, 150.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'726ecc4c-4d9e-410c-b1d8-873b34cd92c8', CAST(0x3B3A0B00 AS Date), 214, N'KG', 0.4000, 75, 30.0000, 3, N'1841,1842,1843, ', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fdc645a1-c11d-4ceb-9240-87729a5dd233', CAST(0x333A0B00 AS Date), 104, N'pkt', 30.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'07065bd0-68fe-4c0d-a731-879b2d58e731', CAST(0x353A0B00 AS Date), 34, N'PC', 6.0000, 190, 1140.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7c0e2a2d-dcdf-434b-b861-88766cb5df49', CAST(0x3C3A0B00 AS Date), 37, N'PC', 1.0000, 80, 80.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f9afbe67-4580-419e-a150-891d66873ce8', CAST(0x5C3A0B00 AS Date), 250, N'pc', 2.0000, 700, 1400.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'09d1df8a-a9e2-4583-8398-8977d3123d20', CAST(0x353A0B00 AS Date), 68, N'PKT', 2.0000, 160, 320.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f67c8b68-a527-4c80-8d4d-89decd405062', CAST(0x3D3A0B00 AS Date), 216, N'kg', 4.0000, 240, 960.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'55206232-adb4-44f3-a705-89edecaaaed2', CAST(0x393A0B00 AS Date), 214, N'KG', 0.4000, 75, 30.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'62d3fb0c-aa35-4a0f-9cc6-8a757ebab783', CAST(0x393A0B00 AS Date), 267, N'mutha', 200.0000, 15, 3000.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'78579a78-71b4-4185-b112-8b18c26bded0', CAST(0x363A0B00 AS Date), 46, N'PCS', 1.0000, 100, 100.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4900666a-c73c-48dc-9934-8b296c085b73', CAST(0x333A0B00 AS Date), 229, N'Ltrs', 1.0000, 575, 575.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c082d748-0600-4c5a-beff-8b419111609f', CAST(0x363A0B00 AS Date), 213, N'KG', 3.0000, 50, 150.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'998d00c6-2f25-40d8-9954-8b785a2253ed', CAST(0x363A0B00 AS Date), 226, N'kg', 1.0000, 200, 200.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'698507a0-cd4a-499c-bf45-8bda1e30cbed', CAST(0x383A0B00 AS Date), 212, N'KG', 10.0000, 85, 850.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'166d0939-4cd6-40c4-ae76-8c119f5940d8', CAST(0x333A0B00 AS Date), 228, N'kg', 20.0000, 80, 1600.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1397cf08-ccc7-4c0a-9fa1-8c1f3c99bee3', CAST(0x333A0B00 AS Date), 81, N'KG', 8.0000, 165, 1320.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'57d125e5-c8f8-43a2-b3b9-8ccd812763a8', CAST(0x363A0B00 AS Date), 206, N'kg', 25.0000, 100, 2500.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bc9a3b2a-0509-4280-a43c-8cce51fc951b', CAST(0x333A0B00 AS Date), 16, N'PKT', 40.0000, 32, 1280.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'28168da2-faa3-40ae-957b-8e4221392242', CAST(0x3C3A0B00 AS Date), 33, N'KG', 1.0000, 785, 785.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4434113f-0998-4508-b2fc-8e6377484fc5', CAST(0x383A0B00 AS Date), 216, N'kg', 4.0000, 250, 1000.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9780c4d3-2d5e-400a-ab5b-8e7838753817', CAST(0x333A0B00 AS Date), 144, N'Pkt (100pcs)', 2.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'20d38148-3e5c-49bb-949b-8ee1615d839d', CAST(0x3C3A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9a164c08-ff23-4bdf-aab9-8f4eb818c79b', CAST(0x363A0B00 AS Date), 207, N'kg', 3.5000, 50, 175.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'799dc5a0-ecd8-4c1d-84b1-8f524b005e80', CAST(0x363A0B00 AS Date), 211, N'KG', 50.0000, 28, 1400.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8d3bcdd3-6e7b-4ccc-bf2a-8f84be6a22a7', CAST(0x3C3A0B00 AS Date), 59, N'PKT', 2.0000, 70, 140.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46204eee-3372-4d78-9d94-8fa6085fde95', CAST(0x3D3A0B00 AS Date), 57, N'PKT', 2.0000, 1435, 2870.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'163f5dfb-bea4-46b9-af8e-90176242508b', CAST(0x383A0B00 AS Date), 28, N'PKT', 50.0000, 35, 1750.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b1eddce3-ce79-4312-9b3b-901b1f16ce10', CAST(0x3D3A0B00 AS Date), 215, N'Mutha', 3.0000, 10, 30.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'609c432c-7716-44bd-a877-907b67489218', CAST(0x333A0B00 AS Date), 83, N'KGS', 1.0000, 300, 300.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ddfcd4ff-7032-43be-b83a-92141f459791', CAST(0x393A0B00 AS Date), 268, N'kg', 200.0000, 15, 3000.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3ec87493-6ee5-4bda-aee7-9252d079bd69', CAST(0x333A0B00 AS Date), 178, N'PC', 2.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e459f407-725a-4edb-8798-92f97e3b8616', CAST(0x353A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6627', N'Admin', 11)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ac650bc4-f248-427e-8f54-930e26cc08f0', CAST(0x393A0B00 AS Date), 218, N'KG', 26.0000, 620, 16120.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3a5820ed-2eff-4682-bbb4-9343714d613e', CAST(0x363A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6876,6877,6627', N'Admin', 18)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'000f3b08-bee0-4ca1-b6a2-9360c6fde1c7', CAST(0x373A0B00 AS Date), 206, N'kg', 1.0000, 100, 100.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'825d6f57-b042-47be-a7ab-93a09b993e09', CAST(0x333A0B00 AS Date), 33, N'KG', 2.0000, 785, 1570.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5ab86bc0-203c-4755-9abe-9465658c5d1a', CAST(0x3D3A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'978e637d-40a1-4611-b171-9494a59aad51', CAST(0x3A3A0B00 AS Date), 230, N'Mutha', 2.0000, 6, 12.0000, 3, N'Bill no.1840,1839', N'Hari Devkota', 41)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'af3b7ed3-b119-4eba-ac01-94e18c86fcb2', CAST(0x333A0B00 AS Date), 214, N'KG', 10.0000, 80, 800.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'03a5dcc3-7881-449f-ae8c-953c2f331380', CAST(0x333A0B00 AS Date), 163, N'PC', 35.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9ead694a-50d3-4150-bdb0-9583bdfda3d4', CAST(0x333A0B00 AS Date), 101, N'PC', 60.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'21e5f654-1176-46bd-8a08-96157ff1b044', CAST(0x343A0B00 AS Date), 81, N'KG', 5.0000, 160, 800.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'44c28555-9a53-43ff-bd06-9641055ae0f3', CAST(0x3D3A0B00 AS Date), 118, N'Pc', 144.0000, 6.19, 891.3600, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'221d45e5-6171-45e8-b7c2-9677b1e1c06b', CAST(0x333A0B00 AS Date), 20, N'PKT', 1.0000, 500, 500.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c2a16490-5fb4-4231-bc54-96efe1af542c', CAST(0x393A0B00 AS Date), 33, N'KG', 2.0000, 785, 1570.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'40726cc5-20c6-4d32-9469-976c8ff7db71', CAST(0x363A0B00 AS Date), 56, N'PKT', 1.0000, 355, 355.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'967cef3e-c85c-4d18-981c-97731789a98e', CAST(0x333A0B00 AS Date), 124, N'Pc', 4.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dcc37ea9-299b-4453-9e15-97dc9a4bcad1', CAST(0x363A0B00 AS Date), 205, N'kg', 2.0000, 90, 180.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9dd1f0e6-8b1f-495c-8034-97e57cd1bc39', CAST(0x353A0B00 AS Date), 42, N'PKT', 60.0000, 70, 4200.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e8c16fa0-cf82-4127-aaaf-97f987bdbf56', CAST(0x333A0B00 AS Date), 206, N'kg', 12.0000, 100, 1200.0000, 3, N'Bill no.1544', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'45c98717-cc47-4642-9a4e-98de02b4e6a5', CAST(0x393A0B00 AS Date), 216, N'kg', 4.0000, 240, 960.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2ba2ee46-bf1c-4726-ba94-98f3d72d176b', CAST(0x3D3A0B00 AS Date), 271, N'Dozen', 22.0000, 100, 2200.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c4f1f522-02b4-4da4-ad68-990d83d5817a', CAST(0x353A0B00 AS Date), 40, N'LTR', 50.0000, 120, 6000.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f13197a9-e4fc-4f7c-8bed-99d10d18714b', CAST(0x393A0B00 AS Date), 28, N'PKT', 50.0000, 35, 1750.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0348dcae-92ee-48e0-a299-9a2909df8ba4', CAST(0x3A3A0B00 AS Date), 207, N'kg', 2.0000, 60, 120.0000, 3, N'Bill no.1840,1839', N'Hari Devkota', 41)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'97b3d711-105c-46a9-b720-9af66a3911dd', CAST(0x363A0B00 AS Date), 216, N'kg', 4.0000, 235, 940.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5f9b33ed-8ec1-4d2d-a743-9b5230490eef', CAST(0x393A0B00 AS Date), 218, N'KG', 27.0000, 620, 16740.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a7cedbf8-7b83-4be2-bb31-9b6958b26d54', CAST(0x3D3A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'51740267-9755-485f-86c5-9b97f216f1c0', CAST(0x333A0B00 AS Date), 126, N'pc', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fa7a0031-ca8a-416a-9901-9c28e8047cc6', CAST(0x393A0B00 AS Date), 276, N'PKT', 55.0000, 90, 4950.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'77bf32d1-ef3c-4f78-be95-9c8e5611555d', CAST(0x333A0B00 AS Date), 213, N'KG', 20.0000, 60, 1200.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6f8e2fcf-a155-407d-95ee-9c97de5bee66', CAST(0x393A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'64572479-cc7b-4dec-bdde-9cd14f6fd497', CAST(0x3D3A0B00 AS Date), 284, N'pc', 120.0000, 665, 79800.0000, 16, N'', N'Admin', 54)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5832e640-0c6b-4e98-a9ad-9cf40b90c64a', CAST(0x3B3A0B00 AS Date), 16, N'PKT', 3.0000, 32, 96.0000, 2, N'E7980', N'Arati Tiwary', 42)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'591bda3f-c837-4229-bb46-9d171449be01', CAST(0x373A0B00 AS Date), 241, N'kg', 5.0000, 310, 1550.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a347eb6f-4ec5-47e1-b2f9-9d27c66a2e99', CAST(0x3D3A0B00 AS Date), 205, N'kg', 1.2000, 90, 108.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1942b70a-cbe9-4a1b-9b59-9d2fffcff25f', CAST(0x343A0B00 AS Date), 230, N'Mutha', 2.0000, 5, 10.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b76e79c8-92cf-4175-8db6-9d31eee4e31a', CAST(0x383A0B00 AS Date), 8, N'KG', 15.0000, 42, 630.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0cc9945a-7078-404e-bce2-9de53a0485ba', CAST(0x373A0B00 AS Date), 40, N'LTR', 2.0000, 120, 240.0000, 2, N'e7785', N'Admin', 24)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0afdae5c-6099-4c49-9571-9e348ce41803', CAST(0x333A0B00 AS Date), 87, N'PC', 12.0000, 8, 96.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'19924c6a-1438-42f7-9961-9e377b4d571b', CAST(0x3A3A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'Bill no.6882', N'Hari Devkota', 40)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6509a7b6-1b86-427a-a09f-9ecbe32bbaf4', CAST(0x3C3A0B00 AS Date), 278, N'CAN', 10.0000, 105, 1050.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4a2a363b-8bee-44ec-b74a-9ed1380be4f3', CAST(0x333A0B00 AS Date), 138, N'pkt (500pcs)', 5000.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'519adba8-06fa-49c4-b8c9-9f3b50056540', CAST(0x383A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'101,102', N'Admin', 29)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd65bec43-fc64-4b5e-b44f-9f643539b8a2', CAST(0x333A0B00 AS Date), 82, N'PKT', 1.0000, 425, 425.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f25b1ecd-a94b-4b87-b750-9f9a74bb91b4', CAST(0x3C3A0B00 AS Date), 214, N'KG', 0.4000, 75, 30.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9c422b73-9ffb-478d-b95d-a000c71a06f4', CAST(0x353A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'097', N'Admin', 15)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bf02f00a-bd44-40a4-b904-a04d1b553212', CAST(0x333A0B00 AS Date), 23, N'PC', 70.0000, 60, 4200.0000, 2, N' Bill no.  I4321', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c07e3bc9-6a23-4bba-a748-a0c403c12824', CAST(0x333A0B00 AS Date), 91, N'PKT', 1.0000, 125, 125.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aa4494a4-10ae-419b-ab4d-a1bb31584d13', CAST(0x393A0B00 AS Date), 17, N'PC', 10.0000, 190, 1900.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'40b4a232-1421-4231-9566-a1c64f592420', CAST(0x3C3A0B00 AS Date), 17, N'PC', 10.0000, 195, 1950.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'785725fe-7d38-48a5-ac63-a28a434cf30a', CAST(0x333A0B00 AS Date), 192, N'PC', 38.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6ba27c2a-ea13-4114-9c9d-a412983dc543', CAST(0x3D3A0B00 AS Date), 101, N'PC', 20.0000, 75.21, 1504.2000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'89ba7019-ffbf-4df4-aae0-a52f1c6f6e24', CAST(0x373A0B00 AS Date), 227, N'kg', 2.0000, 240, 480.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'65acedee-067f-48a1-8d35-a595e5f19226', CAST(0x3D3A0B00 AS Date), 215, N'Mutha', 20.0000, 5, 100.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b1fca204-9ab3-486e-82ee-a59d25126243', CAST(0x333A0B00 AS Date), 166, N'PC', 10.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3454b88c-c2cd-4174-884b-a6abbb223ba3', CAST(0x393A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ff59e25d-1a04-49dd-9f27-a6db64e1b341', CAST(0x3C3A0B00 AS Date), 17, N'PC', 12.0000, 195, 2340.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'86422ee8-0235-4f4d-8617-a770a0772797', CAST(0x383A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'583f692d-dfad-4b64-b949-a7cf522ea260', CAST(0x383A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b58bd227-4503-42bf-9ed2-a7e136c930af', CAST(0x333A0B00 AS Date), 9, N'KG', 5.4800, 850, 4658.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f061d8ab-ab8b-414a-8bf6-a7f42513e335', CAST(0x353A0B00 AS Date), 28, N'PKT', 50.0000, 35, 1750.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd56dfb54-09d7-4a13-b73d-a82ac55550c4', CAST(0x333A0B00 AS Date), 209, N'KG', 25.0000, 25, 625.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3da50f67-2e44-465d-a64d-a89efd382bc9', CAST(0x383A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4b573d5d-fd1d-449b-84fd-a8bb9a2a783b', CAST(0x363A0B00 AS Date), 25, N'PC', 1.0000, 480, 480.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7fe4e1b4-fdc5-4d82-93a4-a8fcfe8a1c74', CAST(0x333A0B00 AS Date), 112, N'pc', 20.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0f5ab719-5149-4e5a-89e6-a909869ef89f', CAST(0x393A0B00 AS Date), 241, N'kg', 50.0000, 320, 16000.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0823d7af-b5c9-41b7-9eb6-a9b2fc4d9f44', CAST(0x343A0B00 AS Date), 16, N'PKT', 3.0000, 32, 96.0000, 2, N'F3881', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fe7d5aae-ef2e-49f1-8f5a-aa33039c4fca', CAST(0x393A0B00 AS Date), 268, N'kg', 12.0000, 70, 840.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6c6d0368-45bb-4935-93c2-aadcd8483e06', CAST(0x363A0B00 AS Date), 54, N'BTL', 4.0000, 280, 1120.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ad88b47b-2eee-487c-9be8-ab7622992214', CAST(0x333A0B00 AS Date), 170, N'PC', 450.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3295ba09-da07-4bfd-93c8-aba9076b1094', CAST(0x333A0B00 AS Date), 125, N'pc', 12.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8bb511ed-59c9-4440-bcb0-abdf35e25a3e', CAST(0x363A0B00 AS Date), 50, N'PC', 6.0000, 165, 990.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'391f3fef-1524-40b0-84a4-ac2bb114d18b', CAST(0x363A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6878', N'Admin', 18)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2f37b9b7-c247-47d9-b580-ac70445853ed', CAST(0x383A0B00 AS Date), 253, N'pc', 18.0000, 1575, 28350.0000, 9, N'1000', N'Admin', 31)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2e91f5a1-e877-408b-9a2d-ac804e7e7f28', CAST(0x383A0B00 AS Date), 18, N'KG', 1.0000, 76, 76.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'503f26b8-ae9f-43b5-a90f-ad15e2d19681', CAST(0x3C3A0B00 AS Date), 213, N'KG', 1.0000, 70, 70.0000, 3, N'1845,1846,1844', N'Arati Tiwary', 47)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'152a9db9-be9f-4245-9758-ad19c0feb08e', CAST(0x3C3A0B00 AS Date), 9, N'KG', 4.7100, 850, 4003.5000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'40ceaef4-78b3-474b-9425-ad7b18a5347f', CAST(0x393A0B00 AS Date), 68, N'PKT', 10.0000, 240, 2400.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'478d31d2-400d-4b76-9b8b-ad869ec966f5', CAST(0x333A0B00 AS Date), 186, N'PKT', 2.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c56dac9d-73f0-49b1-a717-adade6884b00', CAST(0x373A0B00 AS Date), 273, N'kg', 4.0000, 625, 2500.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'eed2c8a1-c60a-4ab1-a113-ae72fce30ad1', CAST(0x3C3A0B00 AS Date), 44, N'KGS', 2.0000, 1300, 2600.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ebfd9ef1-62ef-46d2-b67c-af035bb66ed6', CAST(0x343A0B00 AS Date), 77, N'PC', 20.0000, 190, 3800.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3c3dcad2-f819-4260-9b42-af1737625696', CAST(0x353A0B00 AS Date), 67, N'KG', 10.0000, 160, 1600.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd64f84ee-f1b1-4c3e-ae95-af3ad03d9f07', CAST(0x343A0B00 AS Date), 37, N'PC', 1.0000, 80, 80.0000, 2, N'F3881', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9d3c0aee-85cd-4609-8472-af8aa8c08bfc', CAST(0x343A0B00 AS Date), 220, N'mutha', 5.0000, 20, 100.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f458a8f1-4d4c-43ab-a61c-afac34087ab4', CAST(0x383A0B00 AS Date), 205, N'kg', 15.0000, 100, 1500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f0cdb22b-cd08-4d58-b41d-afe35d8af936', CAST(0x3D3A0B00 AS Date), 261, N'PC', 1.0000, 53.1, 53.1000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c88bb95b-51a3-440d-a0de-b010d35d5b59', CAST(0x373A0B00 AS Date), 38, N'PKT', 10.0000, 15, 150.0000, 2, N'e7785', N'Admin', 24)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'49d3513d-b2c5-45de-9e1b-b03f1ce8f04d', CAST(0x363A0B00 AS Date), 17, N'PC', 2.0000, 190, 380.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'515a43e8-a841-456a-a114-b0be87077f89', CAST(0x3D3A0B00 AS Date), 211, N'KG', 62.0000, 32.26, 2000.1200, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'36e72e77-08f4-4694-9597-b0c67b5fbb6e', CAST(0x3D3A0B00 AS Date), 266, N'kg', 1.0000, 190, 190.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'20b44b31-9c86-420e-8a34-b20997801d43', CAST(0x3B3A0B00 AS Date), 205, N'kg', 1.2000, 90, 108.0000, 3, N'1841,1842,1843, ', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'438e0a55-2b1c-4524-97fa-b25c242cf2ff', CAST(0x333A0B00 AS Date), 211, N'KG', 75.0000, 30, 2250.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3abba071-cafb-4bae-a77d-b2a1863fb552', CAST(0x373A0B00 AS Date), 228, N'kg', 7.0000, 80, 560.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c3a4b412-da27-4951-b113-b2a566bf4323', CAST(0x333A0B00 AS Date), 85, N'KG', 1.0000, 210, 210.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'738fcfee-f0ec-42b7-a0d7-b370cf7c1a48', CAST(0x3D3A0B00 AS Date), 283, N'KGS', 8.0000, 180, 1440.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ba22c318-f10b-4968-bf07-b40a6ee807e5', CAST(0x333A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f6f8a008-b4f5-462f-b9ce-b42a273d8618', CAST(0x383A0B00 AS Date), 14, N'KG', 10.0000, 194, 1940.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cc7fc4c9-0d5e-4a04-b81a-b475c0d66f41', CAST(0x333A0B00 AS Date), 190, N'PC', 5.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'29f1a863-3f79-4339-9bfc-b4e8158303ce', CAST(0x363A0B00 AS Date), 8, N'KG', 14.0000, 46, 644.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd0444998-fb22-4ec5-81d3-b51c9a7e636e', CAST(0x393A0B00 AS Date), 267, N'mutha', 200.0000, 15, 3000.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4bf9cbba-1d5a-4bae-aa9e-b6c936212606', CAST(0x333A0B00 AS Date), 197, N'PC', 8.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5d982e65-1cf9-4bab-b3db-b8348b7a83c6', CAST(0x333A0B00 AS Date), 114, N'pc', 1140.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4041cd03-b68a-4c3b-b128-b88680a4e95a', CAST(0x333A0B00 AS Date), 130, N'PC', 120.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8fe12017-b81f-4a77-8ed2-b88e9a7e8405', CAST(0x3C3A0B00 AS Date), 23, N'PC', 36.0000, 60, 2160.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dbe0524e-5361-457a-a269-b8c4633a6d13', CAST(0x3D3A0B00 AS Date), 131, N'pc', 20.0000, 66.25, 1325.0000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aa3996b8-f93f-4358-b99d-b9a92643c5e8', CAST(0x3C3A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'24017067-cb75-4ddf-bf19-ba26299a34c5', CAST(0x353A0B00 AS Date), 16, N'PKT', 60.0000, 32, 1920.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ea87dff8-69c6-4822-a2de-bab2c0ffc664', CAST(0x343A0B00 AS Date), 50, N'PC', 4.0000, 165, 660.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'02d99b05-0b16-4e80-9e9c-bb024042a2fa', CAST(0x333A0B00 AS Date), 141, N'PC', 216.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a63e57e3-30d1-4092-a51e-bb49992f07e8', CAST(0x3B3A0B00 AS Date), 214, N'KG', 2.0000, 15, 30.0000, 3, N'1841,1842,1843, ', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8b09ab69-6cf7-4906-a2bd-bb5dbe7a2d46', CAST(0x383A0B00 AS Date), 8, N'KG', 12.0000, 42, 504.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'32356f55-723f-4062-a800-bbf37a1e9740', CAST(0x3C3A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'49e77fbb-24c9-41f2-afc9-bd8e3b187eec', CAST(0x383A0B00 AS Date), 211, N'KG', 50.0000, 30, 1500.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fe8362c4-a430-4abe-a352-bdf67f9c2ab9', CAST(0x343A0B00 AS Date), 64, N'PCS', 2.0000, 45, 90.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0f0dfb11-7e94-4256-ad04-beea7f8f5e8f', CAST(0x373A0B00 AS Date), 224, N'KG', 0.5000, 900, 450.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0ac38000-bfba-4400-a8b0-bfc330d7e36e', CAST(0x343A0B00 AS Date), 214, N'KG', 0.5000, 80, 40.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'636da5fc-b580-410d-ba3e-bff8ccb13fb1', CAST(0x3D3A0B00 AS Date), 209, N'KG', 30.0000, 25, 750.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'333630c2-e331-4997-8e08-c1b10968e653', CAST(0x393A0B00 AS Date), 9, N'KG', 4.3300, 850, 3680.5000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0df9acf0-e0c1-4cf2-be25-c1dac2495be3', CAST(0x393A0B00 AS Date), 17, N'PC', 12.0000, 190, 2280.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'455e22a3-4f4a-4239-a615-c22219605fcb', CAST(0x383A0B00 AS Date), 212, N'KG', 55.0000, 85, 4675.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5cf8d145-9e4d-4a64-8add-c2802b7f65de', CAST(0x3D3A0B00 AS Date), 135, N'Pkt (1000pcs)', 1.0000, 48.67, 48.6700, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7b6802c5-f1f9-4647-b175-c2ff279eaf62', CAST(0x333A0B00 AS Date), 17, N'PC', 8.0000, 195, 1560.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'185c44bf-1c6f-49ab-b276-c36e2bbd35e1', CAST(0x383A0B00 AS Date), 256, N'pc', 18.0000, 250, 4500.0000, 9, N'1000', N'Admin', 31)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9885e5d1-c5a3-4a20-b476-c37f5b194641', CAST(0x383A0B00 AS Date), 205, N'kg', 20.0000, 100, 2000.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'5c43c3db-f13a-4b72-8507-c3bf41673d54', CAST(0x333A0B00 AS Date), 139, N'pc', 3000.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6b46b5d3-9d83-4e78-a227-c3ec80ebfa42', CAST(0x333A0B00 AS Date), 99, N'PC', 35.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'070c8f34-d7b8-4faf-b8f1-c49db883f1db', CAST(0x333A0B00 AS Date), 111, N'pc', 20.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'08429dac-4e6a-428d-b23d-c4b2aafa29cc', CAST(0x363A0B00 AS Date), 215, N'Mutha', 2.0000, 50, 100.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0c3d4e4d-fe24-48e5-92a2-c4f173943458', CAST(0x333A0B00 AS Date), 275, N'pcs', 130.0000, 70, 9100.0000, 15, N'422', N'Admin', 5)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c12d80d4-e81e-4fec-ba08-c589bba34336', CAST(0x383A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'62c6fb60-8cee-4716-872e-c6431bd972c0', CAST(0x333A0B00 AS Date), 116, N'pc', 60.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'49fbfda0-fe9c-4a6d-b56f-c650c5afec9a', CAST(0x383A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f1756006-fa43-4ae9-8310-c6570486a545', CAST(0x3D3A0B00 AS Date), 100, N'PC', 5.0000, 710.76, 3553.8000, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6487ad11-e6da-4822-b5ba-c6841656887a', CAST(0x353A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f21ae5d0-9485-434f-9264-c763ca68d6f5', CAST(0x343A0B00 AS Date), 36, N'PKT', 5.0000, 15, 75.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e7511569-d9cc-4cd3-8523-c8bd3f680cb0', CAST(0x393A0B00 AS Date), 10, N'PKT', 20.0000, 235, 4700.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fa073644-f3e4-4258-9daf-c919cab9cac7', CAST(0x333A0B00 AS Date), 21, N'PC', 1.0000, 160, 160.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0da972d2-1947-4ffa-9aa8-c9bcf5eaa3ce', CAST(0x333A0B00 AS Date), 227, N'kg', 2.0000, 240, 480.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f2bf25f4-5e43-4a9c-9f6a-c9ef8831efbd', CAST(0x333A0B00 AS Date), 113, N'pc', 95.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'47d10fe7-ec56-4def-9262-ca02db8d0b67', CAST(0x3D3A0B00 AS Date), 62, N'BTL', 2.0000, 140, 280.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'52d4c04f-1947-4b91-9513-ca5f6e01adb0', CAST(0x343A0B00 AS Date), 52, N'PKT', 4.0000, 1790, 7160.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f475b1da-4445-471e-8331-caf44b3b603d', CAST(0x353A0B00 AS Date), 70, N'KG', 2.0000, 120, 240.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'356eebf2-7f09-46da-86cd-caf5a772e87d', CAST(0x3C3A0B00 AS Date), 155, N'PC', 478.0000, 22.84, 10917.5200, 7, N'02', N'Arati Tiwary', 48)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8d8dce15-e25b-41e4-8d33-cbb343328260', CAST(0x3D3A0B00 AS Date), 87, N'PC', 12.0000, 8, 96.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'97f4bfbc-de31-4593-a42b-cbf6a2b77a27', CAST(0x353A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'12d6b522-f916-4827-9c8f-cc7743c1baf0', CAST(0x3C3A0B00 AS Date), 280, N'PKT', 10.0000, 190, 1900.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c0147ccc-77f5-4fab-9017-ccb281ac1bb9', CAST(0x353A0B00 AS Date), 235, N'KG', 10.0000, 80, 800.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dbc250d0-0093-4277-941f-cce0fdad94b3', CAST(0x373A0B00 AS Date), 227, N'kg', 0.5000, 250, 125.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c308121c-a22b-4285-89e7-ce5c0cc50a33', CAST(0x373A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6880', N'Admin', 26)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'67d82adb-fa35-4aa1-87ac-ceb6c368beb9', CAST(0x373A0B00 AS Date), 217, N'KG', 2.2000, 110, 242.0000, 3, N'1818', N'Admin', 25)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a910da2f-96c5-460f-bcbb-cfb0e80140ff', CAST(0x333A0B00 AS Date), 88, N'PC', 12.0000, 10, 120.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7fefa28c-00ad-4839-b9f0-d2ae10b46fc6', CAST(0x363A0B00 AS Date), 241, N'kg', 46.0000, 310, 14260.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e5129fa7-b7b6-40cb-a1aa-d30aa03c5471', CAST(0x393A0B00 AS Date), 15, N'JAR', 2.0000, 4250, 8500.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'89dbd34f-8410-4aed-a08c-d3b29bfb0770', CAST(0x3C3A0B00 AS Date), 158, N'PC', 440.0000, 22.84, 10049.6000, 7, N'02', N'Arati Tiwary', 48)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cb740762-67d3-4ff8-86fe-d3bbe57713d3', CAST(0x333A0B00 AS Date), 151, N'PC', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ab833276-de25-4637-bb75-d43008157b91', CAST(0x333A0B00 AS Date), 208, N'KG', 5.0000, 100, 500.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6aa1656e-b78a-46be-8fa2-d49e9f501eb7', CAST(0x333A0B00 AS Date), 56, N'PKT', 1.0000, 355, 355.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'122e1f5d-a081-49a1-95fb-d4bf1a6c1df9', CAST(0x3D3A0B00 AS Date), 7, N'PC', 12.0000, 20, 240.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'255d6126-f854-4be4-88d6-d5915e13abf9', CAST(0x353A0B00 AS Date), 216, N'kg', 4.0000, 235, 940.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2ceb62f1-131c-4167-a230-d5c175574ce1', CAST(0x393A0B00 AS Date), 242, N'kg', 0.5000, 1000, 500.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e9b5e9db-9c78-4369-a04d-d5ece739629d', CAST(0x393A0B00 AS Date), 270, N'kg', 1.2000, 100, 120.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'8ef8d5d3-c5cc-4df9-89e1-d62f6140218a', CAST(0x353A0B00 AS Date), 60, N'PC', 2.0000, 41, 82.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'438642a0-ad89-4d93-8937-d6328a7dafae', CAST(0x333A0B00 AS Date), 177, N'PC', 55.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b1fcff9e-d447-4b70-b928-d644747948ad', CAST(0x333A0B00 AS Date), 33, N'KG', 1.0000, 785, 785.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aff94122-1a77-4e1d-acaa-d65c9220ff6d', CAST(0x333A0B00 AS Date), 193, N'PKT', 1.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b07cfbbd-120f-4160-8807-d69545e4bd21', CAST(0x373A0B00 AS Date), 16, N'PKT', 3.0000, 32, 96.0000, 2, N'e7785', N'Admin', 24)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7312c404-5379-4b8a-bda9-d69a46657502', CAST(0x363A0B00 AS Date), 57, N'PKT', 1.0000, 1435, 1435.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd15d12a6-04b4-41fa-9b65-d6af3ffec377', CAST(0x3D3A0B00 AS Date), 58, N'KG', 8.0000, 128, 1024.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'664a5c88-e336-40ac-856c-d792cc199572', CAST(0x353A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ef00103c-fd46-4b9f-8e33-d87c975408cc', CAST(0x393A0B00 AS Date), 213, N'KG', 20.0000, 60, 1200.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6fed64da-620a-4dc2-89c6-d92ef71d6a42', CAST(0x333A0B00 AS Date), 205, N'kg', 20.0000, 95, 1900.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'366f8e81-9f8a-49d0-8f3b-d9403d67d8fa', CAST(0x353A0B00 AS Date), 204, N'Jar (20Ltrs)', 31.0000, 60, 1860.0000, 4, N'9979', N'Admin', 12)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'747eddc0-37cd-4247-9331-da2ab3198a2c', CAST(0x353A0B00 AS Date), 64, N'PCS', 2.0000, 45, 90.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0f4eaa82-9a6c-4398-bd90-da3c234941bc', CAST(0x343A0B00 AS Date), 78, N'KGS', 2.0000, 1250, 2500.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'9c06c62c-dcef-46b1-9684-da8b8bd00d8f', CAST(0x363A0B00 AS Date), 230, N'Mutha', 2.0000, 5, 10.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3cc45a4b-dc72-4d23-8b5d-da8e2967edcb', CAST(0x3D3A0B00 AS Date), 260, N'PC', 1.0000, 23.89, 23.8900, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'def3134e-07c3-4fbb-a35c-db0b7a08cf9a', CAST(0x3D3A0B00 AS Date), 4, N'PC', 3.0000, 95, 285.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cff2e077-f240-46ec-b5a2-dbf5aeb91321', CAST(0x333A0B00 AS Date), 143, N'pc', 1.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3b94e653-66eb-4771-9f62-dd16bf7f81e4', CAST(0x353A0B00 AS Date), 212, N'KG', 25.0000, 90, 2250.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'257924df-5ef8-4adb-aec0-dd65c14be9fa', CAST(0x3D3A0B00 AS Date), 9, N'KG', 4.6000, 850, 3910.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'205c47df-1e3b-4d98-a72d-de081849c8bd', CAST(0x333A0B00 AS Date), 155, N'PC', 200.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46ffd18f-fcc6-48cd-a998-de6e5c33245d', CAST(0x3D3A0B00 AS Date), 23, N'PC', 40.0000, 60, 2400.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'681f0df3-0e25-4591-8954-deedd83afdf0', CAST(0x3D3A0B00 AS Date), 259, N'PC', 1.0000, 61.95, 61.9500, 8, N'008,009,010(13% vat included)', N'Arati Tiwary', 52)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a2dd22c7-f3a7-4f25-9b40-defa294fb9e4', CAST(0x363A0B00 AS Date), 214, N'KG', 10.0000, 80, 800.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4b8e9fa0-fb18-434f-87a3-defefc83b349', CAST(0x3D3A0B00 AS Date), 179, N'pc', 4.0000, 25, 100.0000, 12, N'bill no. 13,16,17', N'Admin', 53)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a717fc74-5d3b-48b5-9e31-df6231ea2c37', CAST(0x333A0B00 AS Date), 96, N'PC', 10.0000, 360, 3600.0000, 15, N'422', N'Admin', 5)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c639ac20-8948-4b19-93b3-dfe2cb1a7c33', CAST(0x363A0B00 AS Date), 23, N'PC', 40.0000, 60, 2400.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2c3a7f3b-a987-4d8d-90e9-e0dba691ab1d', CAST(0x333A0B00 AS Date), 183, N'PC', 5.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'307af8e3-4e1f-4da8-ba56-e16835c347cd', CAST(0x353A0B00 AS Date), 215, N'Mutha', 2.0000, 45, 90.0000, 3, N'1802', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'720be15b-5f2f-4c08-8d0c-e23a9ed2fc43', CAST(0x353A0B00 AS Date), 216, N'kg', 1.5000, 235, 352.5000, 3, N'1804', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'599b2704-058e-4565-8500-e25a5f5530d6', CAST(0x363A0B00 AS Date), 51, N'PC', 4.0000, 25, 100.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1e0d9c52-2708-415c-b1d2-e32d385f9386', CAST(0x353A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6877', N'Admin', 11)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'071d9cb0-fc07-4b41-8096-e3abcffa215c', CAST(0x3D3A0B00 AS Date), 224, N'KG', 1.0000, 1000, 1000.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'37b0e318-23b9-4367-bc75-e3f94ca58836', CAST(0x383A0B00 AS Date), 206, N'kg', 8.0000, 100, 800.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'afdbcd2b-7db4-487e-a7b8-e4067da77f0d', CAST(0x333A0B00 AS Date), 172, N'PC', 600.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'222884f5-0675-4f29-bf4b-e41910be6aa2', CAST(0x3A3A0B00 AS Date), 16, N'PKT', 3.0000, 32, 96.0000, 2, N'bill no.8663,', N'Hari Devkota', 38)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b258c1fc-baa9-4e06-8926-e43790715f09', CAST(0x333A0B00 AS Date), 137, N'pc', 12.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bea94cac-5f51-4c78-bbfd-e49c384769dd', CAST(0x393A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'cffa6d9f-dae7-4a90-8477-e521afaaa80a', CAST(0x393A0B00 AS Date), 269, N'kg', 0.5000, 220, 110.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3ad56f58-415f-461a-8a48-e533b51cfc60', CAST(0x383A0B00 AS Date), 44, N'KGS', 2.0000, 550, 1100.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e1f47077-e4e5-4c7c-bcc8-e561bb465f8b', CAST(0x333A0B00 AS Date), 57, N'PKT', 1.0000, 1435, 1435.0000, 2, N' Bill no.  H7990', N'Admin', 4)
GO
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4be08f0c-a9ba-4d28-a621-e6084c670c42', CAST(0x383A0B00 AS Date), 212, N'KG', 45.0000, 85, 3825.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'797103fa-1e1b-47ac-95cd-e642a5c8192a', CAST(0x363A0B00 AS Date), 27, N'PC', 2.0000, 41, 82.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd66b2f89-5def-4d21-a113-e69360090b4a', CAST(0x383A0B00 AS Date), 20, N'PKT', 1.0000, 500, 500.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6ac93b03-bc57-4a6c-8a3f-e6dabddf57d4', CAST(0x353A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2b0da7f4-d929-4f52-bc2a-e7114d2539bf', CAST(0x353A0B00 AS Date), 65, N'KG', 8.0000, 120, 960.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3e6563ca-ca6e-4393-9869-e7e86363f499', CAST(0x393A0B00 AS Date), 91, N'PKT', 0.5000, 1600, 800.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b1868525-6504-4fda-b31d-e80e7c835be0', CAST(0x333A0B00 AS Date), 149, N'PC', 1955.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f40d63f2-9d2d-4aa1-b719-e84cee2b5d00', CAST(0x383A0B00 AS Date), 67, N'KG', 0.5000, 330, 165.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'990e54ff-6230-4f49-943b-e8c2ead8c3d1', CAST(0x333A0B00 AS Date), 71, N'KG', 0.5000, 320, 160.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6dc4f94d-b90f-431c-8f88-e9f8199c5507', CAST(0x333A0B00 AS Date), 208, N'KG', 5.0000, 100, 500.0000, 3, N'Bill no.1546', N'Admin', 3)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f65b333f-bceb-4afd-9b9b-ea5953945ed1', CAST(0x363A0B00 AS Date), 262, N'Tanker', 0.0000, 0, 0.0000, 6, N'6878,6879', N'Admin', 18)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd3f33a25-a3cb-44dd-8c91-ea6594408910', CAST(0x3D3A0B00 AS Date), 40, N'LTR', 54.0000, 120, 6480.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ff2384c5-57df-4e99-81c2-ea8a3ee521b7', CAST(0x353A0B00 AS Date), 66, N'PC', 200.0000, 14, 2800.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'bcf2e407-9625-4a71-8fd1-eafbd2fad074', CAST(0x363A0B00 AS Date), 227, N'kg', 0.4000, 240, 96.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3ca7c910-d678-49a3-8dff-eb036fc4fe39', CAST(0x333A0B00 AS Date), 103, N'PC', 6.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7ac51a89-fb82-47c6-b380-eb059c8afd81', CAST(0x353A0B00 AS Date), 243, N'box (300m)', 1.0000, 9000, 9000.0000, 14, N'002', N'Admin', 16)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'74150484-3d7d-4058-8809-eb78a12183f7', CAST(0x333A0B00 AS Date), 109, N'Pkt', 12.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c9f51afe-7c12-4d91-8c53-eba42588b3f6', CAST(0x393A0B00 AS Date), 33, N'KG', 2.0000, 785, 1570.0000, 2, N'Bill no.8617,3568,4830,4819,8712,4077', N'Hari Devkota', 33)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e616c186-2886-42a8-8e5e-ebeaa108ac8e', CAST(0x363A0B00 AS Date), 42, N'PKT', 3.0000, 70, 210.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aef8b6f2-6480-459d-872c-ec33be39702c', CAST(0x383A0B00 AS Date), 206, N'kg', 3.0000, 35, 105.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd950d0bf-8c81-4ec3-9bc5-ec4f357b0714', CAST(0x363A0B00 AS Date), 24, N'KG', 0.2000, 300, 60.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'46a60b56-74bd-46e6-b528-ec575d88efeb', CAST(0x353A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7de7cbf7-fa13-4990-8d55-ec6d726ef0ac', CAST(0x353A0B00 AS Date), 212, N'KG', 40.0000, 90, 3600.0000, 3, N'1803', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6882be5c-902a-4802-8884-ec8e354a0ad8', CAST(0x363A0B00 AS Date), 249, N'pc', 1.0000, 3400, 3400.0000, 13, N'107', N'Admin', 20)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd4c7bda1-4170-46c3-b30b-ecf959b40d65', CAST(0x353A0B00 AS Date), 226, N'kg', 2.0000, 190, 380.0000, 3, N'1804', N'Admin', 13)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4e1306ba-f211-4d25-bb15-ed299be19274', CAST(0x363A0B00 AS Date), 13, N'BORA', 1.0000, 2100, 2100.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a7432fdb-1970-45f3-882e-ed7a8cfb9bc0', CAST(0x3D3A0B00 AS Date), 206, N'kg', 10.0000, 100, 1000.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e92e250c-ee55-4efd-a99e-edaac3d42a8d', CAST(0x363A0B00 AS Date), 206, N'kg', 20.0000, 100, 2000.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1177884e-0ad8-4b87-8427-edd28144d29e', CAST(0x333A0B00 AS Date), 10, N'PKT', 20.0000, 235, 4700.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dd3bdcca-fe77-4314-b8db-ee53dc014601', CAST(0x3D3A0B00 AS Date), 23, N'PC', 55.0000, 60, 3300.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b45e858b-7fab-49d1-8a33-ee9c04729c59', CAST(0x3D3A0B00 AS Date), 208, N'KG', 5.0000, 115, 575.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'dcfe9b5d-fb4f-4f58-a768-ef3525782dcb', CAST(0x333A0B00 AS Date), 95, N'PCS', 12.0000, 103, 1236.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'aca46f7f-bfca-4a2e-9012-ef5b51f576fd', CAST(0x383A0B00 AS Date), 14, N'KG', 9.0000, 194, 1746.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2d55df85-af0e-41e0-94dc-ef83877d27cd', CAST(0x363A0B00 AS Date), 218, N'KG', 17.0000, 620, 10540.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'fb70fa09-c488-47a9-b313-efbe7a47abe6', CAST(0x333A0B00 AS Date), 20, N'PKT', 1.0000, 500, 500.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'ae30f0d6-2d73-48f3-9422-f02e16b4ebba', CAST(0x333A0B00 AS Date), 196, N'PC', 8.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'1f5cdd97-304c-4483-8f4f-f0715c0370d9', CAST(0x383A0B00 AS Date), 214, N'KG', 0.5000, 70, 35.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'63de5a03-2d30-42cf-a906-f07590c4b654', CAST(0x353A0B00 AS Date), 69, N'PKT', 6.0000, 275, 1650.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b6e49eae-f1bd-4978-bf8d-f080452b5f2e', CAST(0x333A0B00 AS Date), 180, N'PC', 4.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e71b9af5-24d4-4d98-9d65-f08e86c7d127', CAST(0x333A0B00 AS Date), 133, N'PC', 56.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'31dd86cf-d1a8-4d99-8873-f0b0bef06dee', CAST(0x393A0B00 AS Date), 216, N'kg', 4.0000, 240, 960.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b81d6400-d8af-49fe-9d78-f0f6662fe901', CAST(0x363A0B00 AS Date), 58, N'KG', 2.0000, 130, 260.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a89383bb-0c07-4128-a91c-f17c44218726', CAST(0x333A0B00 AS Date), 13, N'BORA', 2.0000, 2100, 4200.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'c30ee760-c440-4828-9d7b-f1a45e531ae1', CAST(0x363A0B00 AS Date), 45, N'PCS', 4.0000, 82, 328.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'23cb9892-894a-4979-98c9-f2416a724a0d', CAST(0x383A0B00 AS Date), 15, N'JAR', 1.0000, 4250, 4250.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b1b2fd38-4109-411c-9c29-f3122e2e2e15', CAST(0x3A3A0B00 AS Date), 36, N'PKT', 5.0000, 15, 75.0000, 2, N'bill no.8663,', N'Hari Devkota', 38)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'3ad18095-4f23-4346-add5-f341cc8de739', CAST(0x363A0B00 AS Date), 242, N'kg', 0.5000, 1000, 500.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'751e4f7b-5530-488c-ac26-f37293e34baf', CAST(0x393A0B00 AS Date), 214, N'KG', 15.0000, 75, 1125.0000, 3, N'Bill no,1833,1831,1830,1832,1834,1835,1836,1837 ', N'Hari Devkota', 37)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7ede0c3a-3e1a-45a5-8717-f3e9732de880', CAST(0x3C3A0B00 AS Date), 7, N'PC', 200.0000, 20, 4000.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'2f6e7463-fdd9-4860-b79b-f43a85985dc4', CAST(0x333A0B00 AS Date), 106, N'pkt(12pcs)', 125.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b7471d6a-5460-4b90-b3a3-f449e674b907', CAST(0x343A0B00 AS Date), 236, N'KG', 4.0000, 25, 100.0000, 3, N'1547 (munta)', N'Admin', 10)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'31f86318-e964-440a-b0de-f45f9c7ce273', CAST(0x333A0B00 AS Date), 204, N'Jar (20Ltrs)', 34.0000, 60, 2040.0000, 4, N'9974', N'Admin', 8)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'25ade760-2fc0-47f5-962e-f49a1b97cbf1', CAST(0x333A0B00 AS Date), 176, N'PC', 50.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'06c866e4-d28f-4d1e-a46e-f5203c266e85', CAST(0x353A0B00 AS Date), 73, N'PC', 12.0000, 22, 264.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'80a2db11-0497-44f8-ab3c-f5b750a959de', CAST(0x383A0B00 AS Date), 19, N'KG', 1.0000, 740, 740.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'4eef761a-e9dc-436a-97f0-f5f3198d65cf', CAST(0x3D3A0B00 AS Date), 211, N'KG', 62.5000, 32, 2000.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'f36a82d8-3a75-471e-9262-f641ee45e8e5', CAST(0x353A0B00 AS Date), 72, N'PKT', 8.0000, 80, 640.0000, 2, N'E7620', N'Admin', 14)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'92332edf-a23d-4c03-9299-f783f76248f0', CAST(0x333A0B00 AS Date), 118, N'Pc', 80.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'70973254-9260-488a-b03f-f786d33f2b92', CAST(0x333A0B00 AS Date), 181, N'PC', 1.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'a44251e4-d3b2-4373-94af-f7c0b0c07f17', CAST(0x343A0B00 AS Date), 53, N'BTL', 1.0000, 1065, 1065.0000, 2, N'J2583', N'Admin', 9)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'347698c2-c8b4-402a-870d-f858c6744c95', CAST(0x383A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N'h8535', N'Admin', 30)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b30777aa-e9e5-4857-b767-f9c80795ad0b', CAST(0x3A3A0B00 AS Date), 204, N'Jar (20Ltrs)', 31.0000, 60, 1860.0000, 4, N'bill no.10060', N'Hari Devkota', 39)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'906a6a10-77b8-4221-a44a-fa4a6733a4bc', CAST(0x333A0B00 AS Date), 93, N'PKT', 2.0000, 190, 380.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7f373484-c473-45d4-9870-fb4c95ff9cc8', CAST(0x333A0B00 AS Date), 152, N'PC', 0.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'0e586386-dd1a-4a76-b2ac-fb7a05685ccf', CAST(0x333A0B00 AS Date), 140, N'pc', 2.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'160595b0-5617-4b6b-bb94-fba057661fce', CAST(0x333A0B00 AS Date), 127, N'PC', 130.0000, 0, 0.0000, 1, N' ', N'Ruby Shrestha', 1)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'53cb3a3a-9e6e-4d4a-9b6d-fbe7364a5cf6', CAST(0x363A0B00 AS Date), 241, N'kg', 45.0000, 310, 13950.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'66c87c8e-a577-4af5-be30-fcd40a157998', CAST(0x333A0B00 AS Date), 159, N'PC', 12.0000, 0, 0.0000, 1, N'', N'Arati Tiwary', 2)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'd61926ae-f061-48ed-8ca4-fd1818a81c8e', CAST(0x363A0B00 AS Date), 48, N'PC', 20.0000, 30, 600.0000, 2, N'e7646', N'Admin', 23)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'38595c3a-bfae-408e-9c80-fd364b0dd6a3', CAST(0x333A0B00 AS Date), 22, N'PC', 1.0000, 350, 350.0000, 2, N' Bill no.  H7990', N'Admin', 4)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b378fc46-52f0-4aaf-b6a7-fd540dfbf797', CAST(0x3C3A0B00 AS Date), 43, N'PCS', 6.0000, 120, 720.0000, 2, N'J3934,H8814,J3959,J3960', N'Arati Tiwary', 46)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'e4baee9c-318b-41c1-b736-fe29d041cc40', CAST(0x3B3A0B00 AS Date), 206, N'kg', 1.0000, 100, 100.0000, 3, N'1841,1842,1843, ', N'Arati Tiwary', 43)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'550d3c36-fe3e-472c-829e-fe8cb6d415ed', CAST(0x333A0B00 AS Date), 202, N'Tanker', 1.0000, 1800, 1800.0000, 5, N'094', N'Admin', 7)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'88e3fec4-4abf-41bd-916d-fea8e12a34c9', CAST(0x3D3A0B00 AS Date), 214, N'KG', 10.0000, 75, 750.0000, 3, N'1848,1847', N'Arati Tiwary', 51)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'7f2cb5b3-1023-4241-bda1-fee9f6665d47', CAST(0x383A0B00 AS Date), 206, N'kg', 10.0000, 100, 1000.0000, 3, N'1826', N'Admin', 32)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'6061b83e-3e31-47fd-9020-fef4318393bc', CAST(0x3D3A0B00 AS Date), 283, N'KGS', 8.0000, 180, 1440.0000, 2, N'I5173,I5151,I5150', N'Arati Tiwary', 50)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'48f095d4-495a-4f2b-bb03-ff16f0a78d8b', CAST(0x363A0B00 AS Date), 205, N'kg', 5.0000, 90, 450.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'563f7f6c-18fe-44ba-a1d5-ff6e82fefbfd', CAST(0x363A0B00 AS Date), 238, N'Mutha', 4.0000, 25, 100.0000, 3, N'1815', N'Admin', 22)
INSERT [dbo].[tbl_ReceivedItem] ([ReceivedId], [ReceivedDate], [ItemId], [Unit], [Quantity], [Rate], [Amount], [VendorId], [Remarks], [ReceivedBy], [GRN_NO]) VALUES (N'b3d2d39e-0eea-4bb1-b0d4-ffa122b522b3', CAST(0x353A0B00 AS Date), 262, N'Tanker', 1.0000, 2450, 2450.0000, 6, N'6376', N'Admin', 11)
SET IDENTITY_INSERT [dbo].[tbl_ReceivedItem] OFF
SET IDENTITY_INSERT [dbo].[tbl_transaction] ON 

INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (45, N'28617f0b-1853-4279-b6ca-6aca17de728c', 1, 0, 96, CAST(0x333A0B00 AS Date), 1040.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (46, N'2e837be9-6a0a-40ec-8364-56d1096b8ba8', 1, 0, 97, CAST(0x333A0B00 AS Date), 35.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (47, N'6b46b5d3-9d83-4e78-a227-c3ec80ebfa42', 1, 0, 99, CAST(0x333A0B00 AS Date), 35.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (48, N'5b2720dc-7480-48b1-a45f-6d1b368b890e', 1, 0, 98, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (49, N'aed75c82-85da-437a-a94c-297d644f63c7', 1, 0, 100, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (50, N'9ead694a-50d3-4150-bdb0-9583bdfda3d4', 1, 0, 101, CAST(0x333A0B00 AS Date), 60.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (51, N'c88b32e0-6ad9-4805-94eb-81bee2534dd0', 1, 0, 102, CAST(0x333A0B00 AS Date), 50.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (52, N'3ca7c910-d678-49a3-8dff-eb036fc4fe39', 1, 0, 103, CAST(0x333A0B00 AS Date), 6.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (53, N'fdc645a1-c11d-4ceb-9240-87729a5dd233', 1, 0, 104, CAST(0x333A0B00 AS Date), 30.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (54, N'9706842b-874a-4d79-bbb3-469e0a09953a', 1, 0, 105, CAST(0x333A0B00 AS Date), 30.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (55, N'2f6e7463-fdd9-4860-b79b-f43a85985dc4', 1, 0, 106, CAST(0x333A0B00 AS Date), 125.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (56, N'658e27b9-ec74-4711-8fed-793ab612e524', 1, 0, 107, CAST(0x333A0B00 AS Date), 141.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (57, N'43052d90-fc01-4de4-85a6-69536edd5588', 1, 0, 108, CAST(0x333A0B00 AS Date), 23.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (58, N'74150484-3d7d-4058-8809-eb78a12183f7', 1, 0, 109, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (59, N'066fc524-197a-47b5-8772-4e61238b509e', 1, 0, 147, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (60, N'070c8f34-d7b8-4faf-b8f1-c49db883f1db', 1, 0, 111, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (61, N'7fe4e1b4-fdc5-4d82-93a4-a8fcfe8a1c74', 1, 0, 112, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (62, N'f2bf25f4-5e43-4a9c-9f6a-c9ef8831efbd', 1, 0, 113, CAST(0x333A0B00 AS Date), 95.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (63, N'5d982e65-1cf9-4bab-b3db-b8348b7a83c6', 1, 0, 114, CAST(0x333A0B00 AS Date), 1140.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (64, N'62c6fb60-8cee-4716-872e-c6431bd972c0', 1, 0, 116, CAST(0x333A0B00 AS Date), 60.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (65, N'219984ec-bc0e-4583-b8d1-44301ab78099', 1, 0, 148, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (66, N'65f0f388-44c9-44e8-ad24-38d85ee4a99f', 1, 0, 117, CAST(0x333A0B00 AS Date), 288.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (67, N'92332edf-a23d-4c03-9299-f783f76248f0', 1, 0, 118, CAST(0x333A0B00 AS Date), 80.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (68, N'4592af5e-a661-486b-b5fa-36723bdf7a43', 1, 0, 119, CAST(0x333A0B00 AS Date), 288.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (69, N'92e9c7a2-a893-44aa-a0d9-638983a56fe8', 1, 0, 120, CAST(0x333A0B00 AS Date), 288.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (70, N'17c8c3d0-0973-40ce-8def-04d985ec802f', 1, 0, 121, CAST(0x333A0B00 AS Date), 29.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (71, N'31a2c1f8-5073-4146-8d9e-0598be8fbff7', 1, 0, 122, CAST(0x333A0B00 AS Date), 19.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (72, N'251b671d-a3ce-4700-8fce-26f531595fa4', 1, 0, 123, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (73, N'967cef3e-c85c-4d18-981c-97731789a98e', 1, 0, 124, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (74, N'3295ba09-da07-4bfd-93c8-aba9076b1094', 1, 0, 125, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (75, N'160595b0-5617-4b6b-bb94-fba057661fce', 1, 0, 127, CAST(0x333A0B00 AS Date), 130.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (76, N'51740267-9755-485f-86c5-9b97f216f1c0', 1, 0, 126, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (77, N'd7de9931-fe1d-461b-866b-3797e7551a3c', 1, 0, 128, CAST(0x333A0B00 AS Date), 15.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (78, N'77c48876-044b-48e0-8feb-71b34186d717', 1, 0, 129, CAST(0x333A0B00 AS Date), 7.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (79, N'4041cd03-b68a-4c3b-b128-b88680a4e95a', 1, 0, 130, CAST(0x333A0B00 AS Date), 120.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (80, N'cd8380b9-e3b7-4827-8aee-47f6c59f73e2', 1, 0, 131, CAST(0x333A0B00 AS Date), 3.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (81, N'3ad7a023-b823-469c-928b-650d78406e62', 1, 0, 132, CAST(0x333A0B00 AS Date), 7.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (82, N'e71b9af5-24d4-4d98-9d65-f08e86c7d127', 1, 0, 133, CAST(0x333A0B00 AS Date), 56.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (83, N'989fad88-6a38-4c2e-888b-01f1cdf933ae', 1, 0, 134, CAST(0x333A0B00 AS Date), 137.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (84, N'a35c6ef3-5991-477b-b993-6d9c5dc4b0a9', 1, 0, 135, CAST(0x333A0B00 AS Date), 18.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (85, N'7f373484-c473-45d4-9870-fb4c95ff9cc8', 1, 0, 152, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (86, N'0314b1ee-78e9-4d04-bf0e-0cdb27687fa9', 1, 0, 136, CAST(0x333A0B00 AS Date), 30.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (87, N'b258c1fc-baa9-4e06-8926-e43790715f09', 1, 0, 137, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (88, N'4a2a363b-8bee-44ec-b74a-9ed1380be4f3', 1, 0, 138, CAST(0x333A0B00 AS Date), 5000.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (89, N'5c43c3db-f13a-4b72-8507-c3bf41673d54', 1, 0, 139, CAST(0x333A0B00 AS Date), 3000.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (90, N'0e586386-dd1a-4a76-b2ac-fb7a05685ccf', 1, 0, 140, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (91, N'7d1decc0-4f38-446c-a7e1-24bf6a741f3e', 1, 0, 195, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (92, N'ae30f0d6-2d73-48f3-9422-f02e16b4ebba', 1, 0, 196, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (93, N'4bf9cbba-1d5a-4bae-aa9e-b6c936212606', 1, 0, 197, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (94, N'4df42a7a-382e-4cd4-8101-37310adb9fa7', 1, 0, 198, CAST(0x333A0B00 AS Date), 350.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (95, N'02d99b05-0b16-4e80-9e9c-bb024042a2fa', 1, 0, 141, CAST(0x333A0B00 AS Date), 216.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (96, N'cff2e077-f240-46ec-b5a2-dbf5aeb91321', 1, 0, 143, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (97, N'a5aa3d0d-c69f-4a11-a2c6-626e1ad06a62', 1, 0, 145, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (98, N'9780c4d3-2d5e-400a-ab5b-8e7838753817', 1, 0, 144, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (99, N'158b019d-76ec-4822-a6ee-5fcf9e9e86f5', 1, 0, 1, CAST(0x333A0B00 AS Date), 690.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (100, N'cb740762-67d3-4ff8-86fe-d3bbe57713d3', 1, 0, 151, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (101, N'b1868525-6504-4fda-b31d-e80e7c835be0', 1, 0, 149, CAST(0x333A0B00 AS Date), 1955.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (102, N'f8d9096e-d95a-4c2c-9b5e-7879c14ac79d', 1, 0, 150, CAST(0x333A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (103, N'0fc5388f-0409-4264-89e5-81d7faef1abf', 2, 0, 153, CAST(0x333A0B00 AS Date), 250.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (104, N'4f14e2a7-01f9-465d-85d7-6a0062a72e04', 2, 0, 154, CAST(0x333A0B00 AS Date), 2000.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (105, N'205c47df-1e3b-4d98-a72d-de081849c8bd', 2, 0, 155, CAST(0x333A0B00 AS Date), 200.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (106, N'c8fd315e-5e7b-4a7e-b704-6d00b0a9950a', 2, 0, 156, CAST(0x333A0B00 AS Date), 1600.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (107, N'66c87c8e-a577-4af5-be30-fcd40a157998', 2, 0, 159, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (108, N'f22d564c-1831-47cb-9b23-1de193446763', 2, 0, 161, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (109, N'466379b9-f63e-490b-8659-0e2ef2e4cd2f', 2, 0, 162, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (110, N'03a5dcc3-7881-449f-ae8c-953c2f331380', 2, 0, 163, CAST(0x333A0B00 AS Date), 35.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (111, N'd5fc1de2-254f-447e-b1f5-80f90369be77', 2, 0, 165, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (112, N'28d3aa7b-b994-4029-be36-56c9821971f8', 2, 0, 164, CAST(0x333A0B00 AS Date), 9.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (113, N'b1fca204-9ab3-486e-82ee-a59d25126243', 2, 0, 166, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (114, N'cd103327-73a9-4eef-a251-5f33a79af221', 2, 0, 167, CAST(0x333A0B00 AS Date), 24.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (115, N'832ead54-e8c3-4b9d-a309-626e1def9f1d', 2, 0, 168, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (116, N'20684ee7-1338-4a16-b561-2d96096b5949', 2, 0, 169, CAST(0x333A0B00 AS Date), 15.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (117, N'ad88b47b-2eee-487c-9be8-ab7622992214', 2, 0, 170, CAST(0x333A0B00 AS Date), 450.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (118, N'960b7b76-6d39-4646-b0d2-822b7eed6581', 2, 0, 171, CAST(0x333A0B00 AS Date), 1000.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (119, N'afdbcd2b-7db4-487e-a7b8-e4067da77f0d', 2, 0, 172, CAST(0x333A0B00 AS Date), 600.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (120, N'112dcf0e-1a98-4543-82bd-27d807ba2b97', 2, 0, 173, CAST(0x333A0B00 AS Date), 25.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (121, N'3de2b166-0a32-469a-8414-2672a8cf4216', 2, 0, 174, CAST(0x333A0B00 AS Date), 3.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (122, N'b97fc22d-f0a7-48da-84ef-7a62df04cabc', 2, 0, 175, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (123, N'25ade760-2fc0-47f5-962e-f49a1b97cbf1', 2, 0, 176, CAST(0x333A0B00 AS Date), 50.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (124, N'438642a0-ad89-4d93-8937-d6328a7dafae', 2, 0, 177, CAST(0x333A0B00 AS Date), 55.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (125, N'3ec87493-6ee5-4bda-aee7-9252d079bd69', 2, 0, 178, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (126, N'f5d4de82-4afa-488a-b490-714e5edd96be', 2, 0, 179, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (127, N'b6e49eae-f1bd-4978-bf8d-f080452b5f2e', 2, 0, 180, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (128, N'70973254-9260-488a-b03f-f786d33f2b92', 2, 0, 181, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (129, N'19277185-fb75-4151-acf2-54293dcaadcb', 2, 0, 182, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (130, N'2c3a7f3b-a987-4d8d-90e9-e0dba691ab1d', 2, 0, 183, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (131, N'b686ca89-1d84-4982-8b80-602acd2b4788', 2, 0, 184, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (132, N'478d31d2-400d-4b76-9b8b-ad869ec966f5', 2, 0, 186, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (133, N'41515e5a-8987-42ca-a706-5a80d4268390', 2, 0, 185, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (134, N'2e6e02ec-be7c-4bd7-afaa-3de60b8e9f14', 2, 0, 187, CAST(0x333A0B00 AS Date), 24.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (135, N'c6516075-3866-4926-b298-75ccf60fb277', 2, 0, 188, CAST(0x333A0B00 AS Date), 2400.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (136, N'67015b03-74db-4ba7-831a-63500e5ce2f4', 2, 0, 189, CAST(0x333A0B00 AS Date), 96.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (137, N'cc7fc4c9-0d5e-4a04-b81a-b475c0d66f41', 2, 0, 190, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (138, N'2bb888ea-9b76-40e3-81b8-5150dc4444c5', 2, 0, 191, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (139, N'785725fe-7d38-48a5-ac63-a28a434cf30a', 2, 0, 192, CAST(0x333A0B00 AS Date), 38.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (140, N'aff94122-1a77-4e1d-acaa-d65c9220ff6d', 2, 0, 193, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (566, N'ab833276-de25-4637-bb75-d43008157b91', 3, 0, 208, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (567, N'ad93ce25-0fb2-4dd8-b393-5ee43edaddb5', 4, 0, 13, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (568, N'cd859f5c-65d6-4594-928e-169cccaa37fd', 4, 0, 25, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 480.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (569, N'b99f9a78-b5ea-422e-af0d-3f9cd0b1f189', 4, 0, 81, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 165.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (570, N'bbf2331e-b126-4b37-83a3-1aa08169c92b', 4, 0, 16, CAST(0x333A0B00 AS Date), 50.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (571, N'9f56f05a-0f2f-46b8-aff1-7fe5b0a26fe3', 4, 0, 15, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (572, N'990e54ff-6230-4f49-943b-e8c2ead8c3d1', 4, 0, 71, CAST(0x333A0B00 AS Date), 0.5000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (573, N'bf02f00a-bd44-40a4-b904-a04d1b553212', 4, 0, 23, CAST(0x333A0B00 AS Date), 70.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (574, N'e8c16fa0-cf82-4127-aaaf-97f987bdbf56', 3, 0, 206, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (575, N'f29d1314-ed40-4cb2-9470-2c0f870dea2e', 3, 0, 207, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (576, N'9f6d1d72-0c98-42ec-818e-6e3321c93568', 4, 0, 17, CAST(0x333A0B00 AS Date), 9.0000, 0.0000, 195.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (577, N'e2e83c38-ae6f-457d-9faf-82432a95bb85', 4, 0, 33, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (578, N'eec483a0-b6ad-4d8f-9050-3dae88ea1d08', 4, 0, 62, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 140.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (579, N'fb70fa09-c488-47a9-b313-efbe7a47abe6', 4, 0, 20, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (580, N'd65bec43-fc64-4b5e-b44f-9f643539b8a2', 4, 0, 82, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 425.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (581, N'609c432c-7716-44bd-a877-907b67489218', 4, 0, 83, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 300.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (582, N'5d3d7ece-774d-4435-b0cd-47b2a0dde4f5', 4, 0, 84, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (583, N'0058922d-414c-45fa-bd16-38440d8238ea', 4, 0, 30, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (584, N'a5fad821-186d-417f-9bb1-109a5db4e74d', 4, 0, 72, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (585, N'c3a4b412-da27-4951-b113-b2a566bf4323', 4, 0, 85, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 210.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (586, N'e1f47077-e4e5-4c7c-bcc8-e561bb465f8b', 4, 0, 57, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 1435.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (587, N'c3c6b8af-f90f-4ebc-9331-0decfd4bc38c', 4, 0, 86, CAST(0x333A0B00 AS Date), 50.0000, 0.0000, 66.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (588, N'6aa1656e-b78a-46be-8fa2-d49e9f501eb7', 4, 0, 56, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 355.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (589, N'98942c03-e58c-4f9e-bb63-3bf5b6e86ddd', 4, 0, 43, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (590, N'1cf05431-5da8-4f40-9c17-78d5abac184b', 4, 0, 21, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (591, N'0afdae5c-6099-4c49-9571-9e348ce41803', 4, 0, 87, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 8.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (592, N'7fc5c3db-a746-4637-aa43-33a876e8231f', 4, 0, 88, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (593, N'38595c3a-bfae-408e-9c80-fd364b0dd6a3', 4, 0, 22, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (594, N'1177884e-0ad8-4b87-8427-edd28144d29e', 4, 0, 10, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (595, N'3a809620-6de6-42df-9880-23148f754a25', 4, 0, 73, CAST(0x333A0B00 AS Date), 6.0000, 0.0000, 22.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (596, N'906a6a10-77b8-4221-a44a-fa4a6733a4bc', 4, 0, 93, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (597, N'ba22c318-f10b-4968-bf07-b40a6ee807e5', 4, 0, 13, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (598, N'adce63c0-1809-4947-a2e6-1aed3fa6537f', 4, 0, 16, CAST(0x333A0B00 AS Date), 90.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (599, N'ebcffa31-adcf-463e-a158-71edc7984289', 4, 0, 15, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (600, N'0c615f5a-2daa-4af5-9255-57c485ed0127', 4, 0, 42, CAST(0x333A0B00 AS Date), 60.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (601, N'08c07f6e-c99b-4800-a636-1fd8cbe853de', 4, 0, 90, CAST(0x333A0B00 AS Date), 13.0000, 0.0000, 105.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (602, N'c07e3bc9-6a23-4bba-a748-a0c403c12824', 4, 0, 91, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 125.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (603, N'3a29fa80-953a-4eec-aa44-311ec891a5f3', 4, 0, 21, CAST(0x333A0B00 AS Date), 3.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (604, N'a7c61f7b-a0d8-4425-ba24-76df8ff42c8b', 4, 0, 88, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (605, N'825d6f57-b042-47be-a7ab-93a09b993e09', 4, 0, 33, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (606, N'c71695f2-1bda-410f-b62b-3fa11839d0a5', 4, 0, 25, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 480.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (607, N'7feb3830-51a8-4f4a-950a-171a35c1a1b5', 4, 0, 92, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 150.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (608, N'a89383bb-0c07-4128-a91c-f17c44218726', 4, 0, 13, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (609, N'1397cf08-ccc7-4c0a-9fa1-8c1f3c99bee3', 4, 0, 81, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 165.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (610, N'a5bb188e-e214-44d5-bd68-594b21216eae', 4, 0, 15, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (611, N'bc9a3b2a-0509-4280-a43c-8cce51fc951b', 4, 0, 16, CAST(0x333A0B00 AS Date), 40.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (612, N'3b36050f-36cb-49ed-80c5-2c8c79f2e2da', 4, 0, 23, CAST(0x333A0B00 AS Date), 70.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (613, N'7b6802c5-f1f9-4647-b175-c2ff279eaf62', 4, 0, 17, CAST(0x333A0B00 AS Date), 8.0000, 0.0000, 195.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (614, N'ff8a0c77-d421-463a-9d65-428610610ab0', 4, 0, 43, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (615, N'fa073644-f3e4-4258-9daf-c919cab9cac7', 4, 0, 21, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (616, N'b1fcff9e-d447-4b70-b928-d644747948ad', 4, 0, 33, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (617, N'221d45e5-6171-45e8-b7c2-9677b1e1c06b', 4, 0, 20, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (618, N'6c0a73ad-f58f-44dd-be7c-2e486617773f', 4, 0, 231, CAST(0x333A0B00 AS Date), 4.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (619, N'8255abc7-d926-4778-a4cd-3707dcd4de57', 4, 0, 71, CAST(0x333A0B00 AS Date), 0.5000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (620, N'b58bd227-4503-42bf-9ed2-a7e136c930af', 4, 0, 9, CAST(0x333A0B00 AS Date), 5.4800, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (621, N'b6c7f55e-f4df-4df1-9cd4-02b0f3cac5c6', 4, 0, 234, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 55.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (622, N'5975bdd1-4cef-426f-ab3a-27105653b1ad', 4, 0, 21, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (623, N'a910da2f-96c5-460f-bcbb-cfb0e80140ff', 4, 0, 88, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (624, N'b421f299-0095-45e5-83dc-301c56e29eb2', 4, 0, 94, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 114.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (625, N'dcfe9b5d-fb4f-4f58-a768-ef3525782dcb', 4, 0, 95, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 103.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (626, N'1acfe21e-9ca7-4e4f-8147-5f5f548e2200', 4, 0, 87, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 8.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (627, N'd56dfb54-09d7-4a13-b73d-a82ac55550c4', 3, 0, 209, CAST(0x333A0B00 AS Date), 25.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (628, N'438e0a55-2b1c-4524-97fa-b25c242cf2ff', 3, 0, 211, CAST(0x333A0B00 AS Date), 75.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (629, N'ffb2dc55-2fae-4cd7-b7f5-554df10ff27b', 3, 0, 212, CAST(0x333A0B00 AS Date), 100.0000, 0.0000, 85.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (630, N'77bf32d1-ef3c-4f78-be95-9c8e5611555d', 3, 0, 213, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (631, N'bd8e9e03-3514-42fe-9107-07ba8eca0000', 3, 0, 214, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (632, N'c511ad56-b59b-426d-8a5e-22dbb164f347', 3, 0, 215, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (633, N'db5e9d99-d0c6-4c53-a2d9-802342346d27', 3, 0, 224, CAST(0x333A0B00 AS Date), 0.5000, 0.0000, 900.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (634, N'1d753529-1b31-47e8-81ef-6b08649f7f0c', 3, 0, 216, CAST(0x333A0B00 AS Date), 3.0000, 0.0000, 230.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (635, N'af3b7ed3-b119-4eba-ac01-94e18c86fcb2', 3, 0, 214, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (636, N'6fed64da-620a-4dc2-89c6-d92ef71d6a42', 3, 0, 205, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 95.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (637, N'44f61623-ec3b-42b4-8344-3a9c3463b693', 3, 0, 218, CAST(0x333A0B00 AS Date), 12.0000, 0.0000, 620.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (638, N'aeab5293-4b10-448c-b2f6-82275f12de2e', 3, 0, 219, CAST(0x333A0B00 AS Date), 30.0000, 0.0000, 135.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (639, N'6dc4f94d-b90f-431c-8f88-e9f8199c5507', 3, 0, 208, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (640, N'fe7e8310-2241-424f-8bbc-2d37dd25b0e8', 3, 0, 222, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 650.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (641, N'a2deeb26-adb0-4fb8-ab91-13d85a8f2e70', 3, 0, 223, CAST(0x333A0B00 AS Date), 5.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (642, N'269c5415-5470-4c50-8dd0-26d787dfe221', 3, 0, 224, CAST(0x333A0B00 AS Date), 0.5000, 0.0000, 900.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (643, N'e41d88df-023e-4aac-8b62-59ee749832aa', 3, 0, 215, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (644, N'368fd858-e429-47ef-b22e-69e105840e7f', 3, 0, 226, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (645, N'0da972d2-1947-4ffa-9aa8-c9bcf5eaa3ce', 3, 0, 227, CAST(0x333A0B00 AS Date), 2.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (646, N'166d0939-4cd6-40c4-ae76-8c119f5940d8', 3, 0, 228, CAST(0x333A0B00 AS Date), 20.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (647, N'4900666a-c73c-48dc-9934-8b296c085b73', 3, 0, 229, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 575.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (648, N'a717fc74-5d3b-48b5-9e31-df6231ea2c37', 5, 0, 96, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 360.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (649, N'274023ed-a60f-45b9-a19f-06a05354ace5', 6, 0, 262, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (650, N'550d3c36-fe3e-472c-829e-fe8cb6d415ed', 7, 0, 202, CAST(0x333A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (651, N'31f86318-e964-440a-b0de-f45f9c7ce273', 8, 0, 204, CAST(0x333A0B00 AS Date), 34.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (652, N'089f8e5a-ad6d-4d45-99c4-120e0170c36a', 9, 0, 13, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (653, N'0823d7af-b5c9-41b7-9eb6-a9b2fc4d9f44', 9, 0, 16, CAST(0x343A0B00 AS Date), 3.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (654, N'f21ae5d0-9485-434f-9264-c763ca68d6f5', 9, 0, 36, CAST(0x343A0B00 AS Date), 5.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (655, N'd64f84ee-f1b1-4c3e-ae95-af3ad03d9f07', 9, 0, 37, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (656, N'ea4409c0-96ec-4857-8fea-56a3d6670a3d', 10, 0, 213, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (657, N'9d3c0aee-85cd-4609-8472-af8aa8c08bfc', 10, 0, 220, CAST(0x343A0B00 AS Date), 5.0000, 0.0000, 20.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (658, N'fa4537f6-1302-41f1-b3f4-43baa1d72eac', 10, 0, 214, CAST(0x343A0B00 AS Date), 0.5000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (659, N'1942b70a-cbe9-4a1b-9b59-9d2fffcff25f', 10, 0, 230, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (660, N'b7471d6a-5460-4b90-b3a3-f449e674b907', 10, 0, 236, CAST(0x343A0B00 AS Date), 4.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (661, N'0ac38000-bfba-4400-a8b0-bfc330d7e36e', 10, 0, 214, CAST(0x343A0B00 AS Date), 0.5000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (662, N'b74a670f-024d-4615-bc32-0565a7f63873', 10, 0, 230, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (663, N'8d06c74b-b775-4504-8ef9-6266807f728a', 9, 0, 70, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (664, N'fe8362c4-a430-4abe-a352-bdf67f9c2ab9', 9, 0, 64, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 45.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (665, N'0621febb-f2af-4f58-8e3a-0f6a2f8b0d68', 9, 0, 72, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (666, N'970ae1c7-a5bc-4211-9ebf-3231851d389d', 9, 0, 15, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (667, N'c48f8f5e-e59a-4036-ac6f-390e8be0382e', 9, 0, 40, CAST(0x343A0B00 AS Date), 20.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (668, N'ebfd9ef1-62ef-46d2-b67c-af035bb66ed6', 9, 0, 77, CAST(0x343A0B00 AS Date), 20.0000, 0.0000, 190.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (669, N'02e10928-8f35-4578-a988-00d56e4d0b13', 9, 0, 19, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 740.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (670, N'1ac72040-83ec-45e8-9a88-383c3362587d', 9, 0, 272, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 1600.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (671, N'0f4eaa82-9a6c-4398-bd90-da3c234941bc', 9, 0, 78, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 1250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (672, N'9b084cd6-8784-4979-8701-5e4f8cf58f16', 9, 0, 79, CAST(0x343A0B00 AS Date), 2.0000, 0.0000, 550.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (673, N'd58bbcbb-9c30-4673-8eea-7761392d2817', 9, 0, 61, CAST(0x343A0B00 AS Date), 3.0000, 0.0000, 610.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (674, N'786bc656-dcd4-4ded-9dc9-0a338d82839a', 9, 0, 45, CAST(0x343A0B00 AS Date), 3.0000, 0.0000, 82.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (675, N'a44251e4-d3b2-4373-94af-f7c0b0c07f17', 9, 0, 53, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 1065.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (676, N'9860bf93-c7e9-4ae6-8114-5c460c969e11', 9, 0, 80, CAST(0x343A0B00 AS Date), 1.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (677, N'ea87dff8-69c6-4822-a2de-bab2c0ffc664', 9, 0, 50, CAST(0x343A0B00 AS Date), 4.0000, 0.0000, 165.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (678, N'52d4c04f-1947-4b91-9513-ca5f6e01adb0', 9, 0, 52, CAST(0x343A0B00 AS Date), 4.0000, 0.0000, 1790.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (679, N'21e5f654-1176-46bd-8a08-96157ff1b044', 9, 0, 81, CAST(0x343A0B00 AS Date), 5.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (680, N'e459f407-725a-4edb-8798-92f97e3b8616', 11, 0, 262, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (681, N'366f8e81-9f8a-49d0-8f3b-d9403d67d8fa', 12, 0, 204, CAST(0x353A0B00 AS Date), 31.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (682, N'8b012b96-f91a-47b8-92af-2ffc58c7f38e', 13, 0, 227, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (683, N'1e0d9c52-2708-415c-b1d2-e32d385f9386', 11, 0, 262, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (684, N'b3d2d39e-0eea-4bb1-b0d4-ffa122b522b3', 11, 0, 262, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (685, N'd4c7bda1-4170-46c3-b30b-ecf959b40d65', 13, 0, 226, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (686, N'20edbbda-4e9e-43a6-bfd1-2e526e9137b2', 13, 0, 211, CAST(0x353A0B00 AS Date), 25.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (687, N'dfae628a-a3a1-4654-be1d-4faf506368db', 13, 0, 273, CAST(0x353A0B00 AS Date), 3.0000, 0.0000, 450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (688, N'720be15b-5f2f-4c08-8d0c-e23a9ed2fc43', 13, 0, 216, CAST(0x353A0B00 AS Date), 1.5000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (689, N'9cf16383-b91c-4d62-a00d-033ea55d3526', 13, 0, 236, CAST(0x353A0B00 AS Date), 30.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (690, N'ea074fcf-ec75-48b1-85cd-43a4aef6d68a', 13, 0, 214, CAST(0x353A0B00 AS Date), 20.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (691, N'cf0e86f6-c45f-4e4e-92d7-4c9eba137368', 13, 0, 235, CAST(0x353A0B00 AS Date), 12.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (692, N'3b94e653-66eb-4771-9f62-dd16bf7f81e4', 13, 0, 212, CAST(0x353A0B00 AS Date), 25.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (693, N'307af8e3-4e1f-4da8-ba56-e16835c347cd', 13, 0, 215, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 45.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (694, N'7d813602-9862-4c9f-8ee8-3dd22386c0cd', 13, 0, 224, CAST(0x353A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (695, N'2cb2cc7a-82cc-4b3d-a253-2ea4ab02a390', 13, 0, 216, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (696, N'170aee43-5eef-43e6-aba0-83b6fe29d5b2', 13, 0, 213, CAST(0x353A0B00 AS Date), 20.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (697, N'6a5cabd8-6214-4494-9de9-6579949cbed9', 13, 0, 214, CAST(0x353A0B00 AS Date), 15.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (698, N'73395226-f41d-42c4-8aca-10a2e8bef49a', 13, 0, 211, CAST(0x353A0B00 AS Date), 62.5000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (699, N'855b7e83-d234-4577-ad43-6bdd3205bd7b', 13, 0, 215, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 45.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (700, N'a998a0e5-a675-4430-b962-84bb55b57a70', 13, 0, 224, CAST(0x353A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (701, N'7de7cbf7-fa13-4990-8d55-ec6d726ef0ac', 13, 0, 212, CAST(0x353A0B00 AS Date), 40.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (702, N'c0147ccc-77f5-4fab-9017-ccb281ac1bb9', 13, 0, 235, CAST(0x353A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (703, N'255d6126-f854-4be4-88d6-d5915e13abf9', 13, 0, 216, CAST(0x353A0B00 AS Date), 4.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (704, N'5d3dbd06-09fc-40eb-83fe-0ee564d1f0ef', 13, 0, 237, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 400.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (705, N'f575b4a9-a300-4470-a410-2b5fd93a151b', 14, 0, 76, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 1295.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (706, N'06e8201d-a3b2-4e69-84e5-3cdd70fd49aa', 14, 0, 9, CAST(0x353A0B00 AS Date), 5.9700, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (707, N'664a5c88-e336-40ac-856c-d792cc199572', 14, 0, 13, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (708, N'72751ee8-adff-4be2-b3db-2a8b8fbf1f59', 14, 0, 16, CAST(0x353A0B00 AS Date), 40.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (709, N'8ef8d5d3-c5cc-4df9-89e1-d62f6140218a', 14, 0, 60, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 41.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (710, N'54f028fc-ec2f-454f-93e2-5ebc232c16e8', 14, 0, 22, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (711, N'a2cda32a-187a-4f92-9239-292fe56c36f7', 14, 0, 3, CAST(0x353A0B00 AS Date), 12.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (712, N'747eddc0-37cd-4247-9331-da2ab3198a2c', 14, 0, 64, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 45.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (713, N'07065bd0-68fe-4c0d-a731-879b2d58e731', 14, 0, 34, CAST(0x353A0B00 AS Date), 6.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (714, N'2b0da7f4-d929-4f52-bc2a-e7114d2539bf', 14, 0, 65, CAST(0x353A0B00 AS Date), 8.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (715, N'6487ad11-e6da-4822-b5ba-c6841656887a', 14, 0, 15, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (716, N'ff2384c5-57df-4e99-81c2-ea8a3ee521b7', 14, 0, 66, CAST(0x353A0B00 AS Date), 200.0000, 0.0000, 14.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (717, N'c40ba6c0-27e8-4331-bbd6-549c2cad0957', 14, 0, 6, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (718, N'81f7fca5-28c9-4716-a4c5-5e7a54292476', 14, 0, 67, CAST(0x353A0B00 AS Date), 9.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (719, N'6b121007-beab-4e08-a8b3-8544d958498f', 14, 0, 68, CAST(0x353A0B00 AS Date), 5.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (720, N'63de5a03-2d30-42cf-a906-f07590c4b654', 14, 0, 69, CAST(0x353A0B00 AS Date), 6.0000, 0.0000, 275.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (721, N'e9a6bb33-701c-4892-a860-52d6cb9b8144', 14, 0, 75, CAST(0x353A0B00 AS Date), 3.0000, 0.0000, 150.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (722, N'e7e1b635-a4b8-4a56-9850-6f26786b7b1d', 14, 0, 40, CAST(0x353A0B00 AS Date), 50.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (723, N'9dd1f0e6-8b1f-495c-8034-97e57cd1bc39', 14, 0, 42, CAST(0x353A0B00 AS Date), 60.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (724, N'6ac93b03-bc57-4a6c-8a3f-e6dabddf57d4', 14, 0, 13, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (725, N'f475b1da-4445-471e-8331-caf44b3b603d', 14, 0, 70, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (726, N'3c3dcad2-f819-4260-9b42-af1737625696', 14, 0, 67, CAST(0x353A0B00 AS Date), 10.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (727, N'24017067-cb75-4ddf-bf19-ba26299a34c5', 14, 0, 16, CAST(0x353A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (728, N'97f4bfbc-de31-4593-a42b-cbf6a2b77a27', 14, 0, 15, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (729, N'325941a3-d888-4e4c-a944-582213eef535', 14, 0, 31, CAST(0x353A0B00 AS Date), 10.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (730, N'82f4d61a-fbcc-400f-b57c-28762267d2e4', 14, 0, 71, CAST(0x353A0B00 AS Date), 0.5000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (731, N'fa77da96-c701-4b9c-a51d-2b5cf409513f', 14, 0, 66, CAST(0x353A0B00 AS Date), 220.0000, 0.0000, 14.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (732, N'd79a084d-ac5b-40d1-9bfc-2d0c14a061c0', 14, 0, 34, CAST(0x353A0B00 AS Date), 4.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (733, N'7e829c15-e903-4184-aca7-7c1787eafad7', 14, 0, 65, CAST(0x353A0B00 AS Date), 10.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (734, N'f061d8ab-ab8b-414a-8bf6-a7f42513e335', 14, 0, 28, CAST(0x353A0B00 AS Date), 50.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (735, N'f93b8808-ab0a-4b42-bc01-3bdfeed1f6c5', 14, 0, 64, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 45.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (736, N'f36a82d8-3a75-471e-9262-f641ee45e8e5', 14, 0, 72, CAST(0x353A0B00 AS Date), 8.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (737, N'06c866e4-d28f-4d1e-a46e-f5203c266e85', 14, 0, 73, CAST(0x353A0B00 AS Date), 12.0000, 0.0000, 22.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (738, N'fdb2d833-253b-40dc-8255-74b5cd68915d', 14, 0, 21, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (739, N'46a60b56-74bd-46e6-b528-ec575d88efeb', 14, 0, 22, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (740, N'da63d238-ea8b-4a8d-92c3-49c5e38e7488', 14, 0, 3, CAST(0x353A0B00 AS Date), 12.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (741, N'c4f1f522-02b4-4da4-ad68-990d83d5817a', 14, 0, 40, CAST(0x353A0B00 AS Date), 50.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (742, N'a6610472-cc28-4b6e-9227-56661e40a916', 14, 0, 74, CAST(0x353A0B00 AS Date), 8.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (743, N'09d1df8a-a9e2-4583-8398-8977d3123d20', 14, 0, 68, CAST(0x353A0B00 AS Date), 2.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (744, N'f83b351a-5c21-4782-a6d2-4c10fec218fb', 14, 0, 75, CAST(0x353A0B00 AS Date), 3.0000, 0.0000, 150.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (745, N'9c422b73-9ffb-478d-b95d-a000c71a06f4', 15, 0, 202, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (746, N'7ac51a89-fb82-47c6-b380-eb059c8afd81', 16, 0, 243, CAST(0x353A0B00 AS Date), 1.0000, 0.0000, 9000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (747, N'561e2acd-af84-4db5-8916-4010fc28f45a', 3, 0, 217, CAST(0x333A0B00 AS Date), 3.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (748, N'c3f6a0df-30c4-4a71-b953-2ad71f912a6e', 5, 0, 274, CAST(0x333A0B00 AS Date), 60.0000, 0.0000, 27.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (749, N'2681423d-3e44-45b8-9d8d-5aa54be32234', 5, 0, 102, CAST(0x333A0B00 AS Date), 100.0000, 0.0000, 4.7500)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (750, N'dbbbbed2-c16c-4eb1-93be-2767f164258b', 5, 0, 199, CAST(0x333A0B00 AS Date), 10.0000, 0.0000, 360.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (751, N'0c3d4e4d-fe24-48e5-92a2-c4f173943458', 5, 0, 275, CAST(0x333A0B00 AS Date), 130.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (752, N'1e979d27-56b6-4662-be9f-04ecd845f3fb', 17, 0, 204, CAST(0x363A0B00 AS Date), 36.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (753, N'f65b333f-bceb-4afd-9b9b-ea5953945ed1', 18, 0, 262, CAST(0x363A0B00 AS Date), 0.0000, 0.0000, 0.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (754, N'391f3fef-1524-40b0-84a4-ac2bb114d18b', 18, 0, 262, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (763, N'6882be5c-902a-4802-8884-ec8e354a0ad8', 20, 0, 249, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 3400.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (764, N'aac0eac5-eeb7-483e-8528-059c7e8e47f0', 21, 0, 199, CAST(0x363A0B00 AS Date), 50.0000, 0.0000, 330.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (889, N'563f7f6c-18fe-44ba-a1d5-ff6e82fefbfd', 22, 0, 238, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (890, N'735ac94b-ea58-43f9-8b4e-3f2f39dd8c57', 22, 0, 214, CAST(0x363A0B00 AS Date), 0.5000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (891, N'9c06c62c-dcef-46b1-9684-da8b8bd00d8f', 22, 0, 230, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (892, N'7fefa28c-00ad-4839-b9f0-d2ae10b46fc6', 22, 0, 241, CAST(0x363A0B00 AS Date), 46.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (893, N'eee647bd-8fc7-4a1b-959b-09f11c206d86', 22, 0, 206, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (894, N'43425502-7ec6-4eef-a5f6-481fe1bc4698', 22, 0, 214, CAST(0x363A0B00 AS Date), 0.5000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (895, N'f2a34f83-483c-4374-88a1-4c34a954ffaf', 22, 0, 230, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (896, N'3ad18095-4f23-4346-add5-f341cc8de739', 22, 0, 242, CAST(0x363A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (897, N'53cb3a3a-9e6e-4d4a-9b6d-fbe7364a5cf6', 22, 0, 241, CAST(0x363A0B00 AS Date), 45.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (898, N'08429dac-4e6a-428d-b23d-c4b2aafa29cc', 22, 0, 215, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (899, N'998d00c6-2f25-40d8-9954-8b785a2253ed', 22, 0, 226, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (900, N'9dd3a217-a4e5-4537-a797-29eaaf5055fe', 22, 0, 227, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 240.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (901, N'38277dc8-109d-404f-a3ee-3283197a2f7b', 22, 0, 239, CAST(0x363A0B00 AS Date), 150.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (902, N'a2dd22c7-f3a7-4f25-9b40-defa294fb9e4', 22, 0, 214, CAST(0x363A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (903, N'e92e250c-ee55-4efd-a99e-edaac3d42a8d', 22, 0, 206, CAST(0x363A0B00 AS Date), 20.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (904, N'97b3d711-105c-46a9-b720-9af66a3911dd', 22, 0, 216, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (905, N'9a164c08-ff23-4bdf-aab9-8f4eb818c79b', 22, 0, 207, CAST(0x363A0B00 AS Date), 3.5000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (906, N'48f095d4-495a-4f2b-bb03-ff16f0a78d8b', 22, 0, 205, CAST(0x363A0B00 AS Date), 5.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (907, N'2d2e459a-e9bc-45d5-95d3-852e87026f17', 22, 0, 208, CAST(0x363A0B00 AS Date), 5.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (908, N'b953fb49-4bc2-45f5-ac5f-706441249269', 22, 0, 271, CAST(0x363A0B00 AS Date), 20.0000, 0.0000, 110.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (909, N'2d55df85-af0e-41e0-94dc-ef83877d27cd', 22, 0, 218, CAST(0x363A0B00 AS Date), 17.0000, 0.0000, 620.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (910, N'5d687466-55a8-4e1e-8b9e-261d091693a1', 22, 0, 213, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (911, N'1231b983-be37-45b2-8962-5f2143141b0e', 22, 0, 241, CAST(0x363A0B00 AS Date), 5.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (912, N'1ef079de-0497-4c55-a29e-0d2845668ebf', 22, 0, 218, CAST(0x363A0B00 AS Date), 17.0000, 0.0000, 620.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (913, N'96e9c1a7-d74b-4b7b-a539-2ac9e6ce454c', 22, 0, 271, CAST(0x363A0B00 AS Date), 20.0000, 0.0000, 110.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (914, N'6f13f7b4-24c1-45c0-b0a0-8451b1f6b4fc', 22, 0, 240, CAST(0x363A0B00 AS Date), 150.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (915, N'57d125e5-c8f8-43a2-b3b9-8ccd812763a8', 22, 0, 206, CAST(0x363A0B00 AS Date), 25.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (916, N'9010f895-928c-4a6b-86c7-61fcfc3e3811', 22, 0, 214, CAST(0x363A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (917, N'0c91d68a-a79e-4569-83ce-16252b0da1ee', 22, 0, 213, CAST(0x363A0B00 AS Date), 20.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (918, N'799dc5a0-ecd8-4c1d-84b1-8f524b005e80', 22, 0, 211, CAST(0x363A0B00 AS Date), 50.0000, 0.0000, 28.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (919, N'c082d748-0600-4c5a-beff-8b419111609f', 22, 0, 213, CAST(0x363A0B00 AS Date), 3.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (920, N'dcc37ea9-299b-4453-9e15-97dc9a4bcad1', 22, 0, 205, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (921, N'f18c14cd-324d-4dcc-96f8-1b3fa88d6599', 22, 0, 216, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (922, N'04031264-4b2d-4c31-b0f5-38ad7311d1f0', 22, 0, 227, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (923, N'bcee56af-790a-4ad7-b0ec-09f8ca4b83c9', 22, 0, 226, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (924, N'bcf2e407-9625-4a71-8fd1-eafbd2fad074', 22, 0, 227, CAST(0x363A0B00 AS Date), 0.4000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (925, N'e616c186-2886-42a8-8e5e-ebeaa108ac8e', 23, 0, 42, CAST(0x363A0B00 AS Date), 3.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (926, N'b07cfbbd-120f-4160-8807-d69545e4bd21', 24, 0, 16, CAST(0x373A0B00 AS Date), 3.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (927, N'c5777c23-5a48-4b54-89f0-1228d2382c93', 24, 0, 36, CAST(0x373A0B00 AS Date), 5.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (928, N'01c9845d-1bf9-474f-b655-65b7a3ee43ed', 24, 0, 37, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (929, N'c88bb95b-51a3-440d-a0de-b010d35d5b59', 24, 0, 38, CAST(0x373A0B00 AS Date), 10.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (930, N'0cc9945a-7078-404e-bce2-9de53a0485ba', 24, 0, 40, CAST(0x373A0B00 AS Date), 2.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (931, N'000f3b08-bee0-4ca1-b6a2-9360c6fde1c7', 25, 0, 206, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (932, N'7b1ef07a-3f97-47fe-93c2-57e8f97f22e6', 25, 0, 214, CAST(0x373A0B00 AS Date), 0.5000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (933, N'f934a3bc-1e85-40ef-83c8-7e0442dbfa0c', 25, 0, 215, CAST(0x373A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (934, N'dbc250d0-0093-4277-941f-cce0fdad94b3', 25, 0, 227, CAST(0x373A0B00 AS Date), 0.5000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (935, N'f813c7ed-6e73-482c-ba4b-383c8133212e', 25, 0, 213, CAST(0x373A0B00 AS Date), 4.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (936, N'7c800cf2-e69c-4b5d-8c23-3c683b840444', 25, 0, 44, CAST(0x373A0B00 AS Date), 10.0000, 0.0000, 580.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (937, N'4a44d2e5-571b-4f72-ad3a-4f8267f685ea', 25, 0, 226, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (938, N'89ba7019-ffbf-4df4-aae0-a52f1c6f6e24', 25, 0, 227, CAST(0x373A0B00 AS Date), 2.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (939, N'3abba071-cafb-4bae-a77d-b2a1863fb552', 25, 0, 228, CAST(0x373A0B00 AS Date), 7.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (940, N'c56dac9d-73f0-49b1-a717-adade6884b00', 25, 0, 273, CAST(0x373A0B00 AS Date), 4.0000, 0.0000, 625.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (941, N'd2809132-1d8a-4bbb-ad6f-7b44a1078e63', 25, 0, 222, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 625.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (942, N'76ab3fb2-d093-4230-92f9-2b9adb1abfbe', 25, 0, 215, CAST(0x373A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (943, N'0f0dfb11-7e94-4256-ad04-beea7f8f5e8f', 25, 0, 224, CAST(0x373A0B00 AS Date), 0.5000, 0.0000, 900.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (944, N'510ac01d-efa2-471d-83dc-147137fbfc94', 25, 0, 240, CAST(0x373A0B00 AS Date), 10.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (945, N'67d82adb-fa35-4aa1-87ac-ceb6c368beb9', 25, 0, 217, CAST(0x373A0B00 AS Date), 2.2000, 0.0000, 110.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (946, N'591bda3f-c837-4229-bb46-9d171449be01', 25, 0, 241, CAST(0x373A0B00 AS Date), 5.0000, 0.0000, 310.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (947, N'c308121c-a22b-4285-89e7-ce5c0cc50a33', 26, 0, 262, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (948, N'e00795b8-7073-4865-a2d1-67871a71ee36', 26, 0, 262, CAST(0x373A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (949, N'1b8e78d4-6ea7-43c7-9970-0a0cd46ce72e', 27, 0, 204, CAST(0x373A0B00 AS Date), 30.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (950, N'0a9df31b-9584-4c53-979c-6b7a74930976', 23, 0, 43, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (951, N'4e1306ba-f211-4d25-bb15-ed299be19274', 23, 0, 13, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (952, N'fb6f80b1-6afa-4553-96f7-343304a1753c', 23, 0, 16, CAST(0x363A0B00 AS Date), 50.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (953, N'57ff44a0-f5f5-4ca0-9d24-618e39a42958', 23, 0, 23, CAST(0x363A0B00 AS Date), 40.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (954, N'a589c57e-29c6-44c4-ad7a-81a9085e582b', 23, 0, 17, CAST(0x363A0B00 AS Date), 10.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (955, N'10ce4df9-544c-41dc-81e0-2a798565f10e', 23, 0, 43, CAST(0x363A0B00 AS Date), 3.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (956, N'4b573d5d-fd1d-449b-84fd-a8bb9a2a783b', 23, 0, 25, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 480.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (957, N'afec9570-6180-45d0-90b4-60bc5a9e32b4', 23, 0, 8, CAST(0x363A0B00 AS Date), 15.0000, 0.0000, 46.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (958, N'33dfd4ca-1b9d-4af1-bdf2-0e14d4b8e12e', 23, 0, 59, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (959, N'e91726a8-16f3-4b1c-abbf-0818b9651c12', 23, 0, 55, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (960, N'b81d6400-d8af-49fe-9d78-f0f6662fe901', 23, 0, 58, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 130.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (961, N'05f1a56c-54ac-4d7e-b023-56dc46008044', 23, 0, 62, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 140.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (962, N'4350ddd7-92f0-4136-b833-135a589d9930', 23, 0, 33, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (963, N'6a900273-621f-49f5-a5eb-671ef503a9b1', 23, 0, 61, CAST(0x363A0B00 AS Date), 7.0000, 0.0000, 610.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (964, N'5c129300-4b6c-45fd-8cd8-40ee4e0b1fd3', 23, 0, 63, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 280.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (965, N'c52bf2ad-246f-426c-aeaa-657c7c14943e', 23, 0, 13, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (966, N'bb5bf6eb-6479-45d4-9feb-0366eecf7172', 23, 0, 16, CAST(0x363A0B00 AS Date), 70.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (967, N'08111a29-e1be-4539-b158-2806ee34ac8b', 23, 0, 55, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 165.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (968, N'40726cc5-20c6-4d32-9469-976c8ff7db71', 23, 0, 56, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 355.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (969, N'7312c404-5379-4b8a-bda9-d69a46657502', 23, 0, 57, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 1435.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (970, N'f40b8567-f3b1-4a4b-8b4b-332bdd99c89f', 23, 0, 58, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 130.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (971, N'c2109498-fe8e-4285-8f31-0c246fbf3ddc', 23, 0, 9, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (972, N'29f1a863-3f79-4339-9bfc-b4e8158303ce', 23, 0, 8, CAST(0x363A0B00 AS Date), 14.0000, 0.0000, 46.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (973, N'1cfa8f11-eb03-4059-941c-1d91d7e0adfa', 23, 0, 17, CAST(0x363A0B00 AS Date), 9.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (974, N'f0d8e001-989e-49bd-a9cb-232e7fa0385b', 23, 0, 59, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (975, N'797103fa-1e1b-47ac-95cd-e642a5c8192a', 23, 0, 27, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 41.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (976, N'b4952305-cfae-416f-90f2-4d93c1b84b56', 23, 0, 21, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (977, N'5fe84331-2a44-481d-b95e-72b0603bc511', 23, 0, 61, CAST(0x363A0B00 AS Date), 7.0000, 0.0000, 610.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (978, N'c639ac20-8948-4b19-93b3-dfe2cb1a7c33', 23, 0, 23, CAST(0x363A0B00 AS Date), 40.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (979, N'18c95950-14b6-4ce9-b089-27e321831d50', 23, 0, 43, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (980, N'49d3513d-b2c5-45de-9e1b-b03f1ce8f04d', 23, 0, 17, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (981, N'438aee63-7c39-474b-8c51-7cbe1708a35a', 23, 0, 44, CAST(0x363A0B00 AS Date), 0.2600, 0.0000, 1200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (982, N'c30ee760-c440-4828-9d7b-f1a45e531ae1', 23, 0, 45, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 82.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (983, N'd950d0bf-8c81-4ec3-9bc5-ec4f357b0714', 23, 0, 24, CAST(0x363A0B00 AS Date), 0.2000, 0.0000, 300.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (984, N'79aa21d1-6005-4fee-8675-31652f81e6f7', 23, 0, 8, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 46.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (985, N'78579a78-71b4-4185-b112-8b18c26bded0', 23, 0, 46, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (986, N'd61926ae-f061-48ed-8ca4-fd1818a81c8e', 23, 0, 48, CAST(0x363A0B00 AS Date), 20.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (987, N'5e5d7703-c632-4cd6-8311-34339e63203c', 23, 0, 49, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 275.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (988, N'8bb511ed-59c9-4440-bcb0-abdf35e25a3e', 23, 0, 50, CAST(0x363A0B00 AS Date), 6.0000, 0.0000, 165.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (989, N'599b2704-058e-4565-8500-e25a5f5530d6', 23, 0, 51, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (990, N'3bc6eca1-33c2-490f-b372-49d64a2e2efd', 23, 0, 52, CAST(0x363A0B00 AS Date), 2.0000, 0.0000, 1790.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (991, N'cce6ac8b-39f1-4667-a8c0-0fe2382f2de5', 23, 0, 53, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 1065.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (992, N'6c6d0368-45bb-4935-93c2-aadcd8483e06', 23, 0, 54, CAST(0x363A0B00 AS Date), 4.0000, 0.0000, 280.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (993, N'648d90fd-00ce-4cd3-8863-06a6743573c4', 25, 0, 223, CAST(0x373A0B00 AS Date), 5.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (994, N'32dc00b1-3a25-4bb8-958e-74a38acc38f2', 28, 0, 204, CAST(0x383A0B00 AS Date), 19.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (995, N'519adba8-06fa-49c4-b8c9-9f3b50056540', 29, 0, 202, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (996, N'22de515f-d876-4215-97e6-3d24f5f8d3ce', 30, 0, 13, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (997, N'f6f8a008-b4f5-462f-b9ce-b42a273d8618', 30, 0, 14, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 194.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (998, N'23cb9892-894a-4979-98c9-f2416a724a0d', 30, 0, 15, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (999, N'f8c4770e-5fca-4eee-a2c5-71892ad28678', 30, 0, 16, CAST(0x383A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1000, N'2f52667e-09b9-4782-99c6-28b2b9c92000', 30, 0, 17, CAST(0x383A0B00 AS Date), 6.0000, 0.0000, 190.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1001, N'2f37b9b7-c247-47d9-b580-ac70445853ed', 31, 0, 253, CAST(0x383A0B00 AS Date), 18.0000, 0.0000, 1575.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1002, N'0bee0879-6e02-49e1-b107-611618567cdf', 31, 0, 254, CAST(0x383A0B00 AS Date), 18.0000, 0.0000, 950.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1003, N'9dac9ba9-5950-4abf-a288-5a8153ec17c8', 31, 0, 255, CAST(0x383A0B00 AS Date), 18.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1004, N'185c44bf-1c6f-49ab-b276-c36e2bbd35e1', 31, 0, 256, CAST(0x383A0B00 AS Date), 18.0000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1005, N'4be08f0c-a9ba-4d28-a621-e6084c670c42', 32, 0, 212, CAST(0x383A0B00 AS Date), 45.0000, 0.0000, 85.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1006, N'455e22a3-4f4a-4239-a615-c22219605fcb', 32, 0, 212, CAST(0x383A0B00 AS Date), 55.0000, 0.0000, 85.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1007, N'4434113f-0998-4508-b2fc-8e6377484fc5', 32, 0, 216, CAST(0x383A0B00 AS Date), 4.0000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1008, N'b522b3b6-440a-4e39-a081-3c6e4751687a', 32, 0, 215, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1009, N'5d2652fa-4dd7-4aa9-846b-4f5dcecd6c6f', 32, 0, 224, CAST(0x383A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1010, N'9885e5d1-c5a3-4a20-b476-c37f5b194641', 32, 0, 205, CAST(0x383A0B00 AS Date), 20.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1011, N'7f2cb5b3-1023-4241-bda1-fee9f6665d47', 32, 0, 206, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1012, N'e6e3ca2e-a041-4bc1-ad32-41c5d6607034', 32, 0, 214, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1013, N'64a9d559-9cee-4203-9a38-720243282b92', 32, 0, 266, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1014, N'e15461dd-ca29-4be3-a392-3ca8d4856808', 32, 0, 211, CAST(0x383A0B00 AS Date), 30.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1015, N'12ea3abb-8bda-4e3e-83a8-08b4b1f85454', 32, 0, 208, CAST(0x383A0B00 AS Date), 5.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1016, N'bb38e7fe-648c-4a72-85d5-855fe98bddfd', 32, 0, 263, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 550.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1017, N'6c0e7a00-d198-4078-aba4-4b6f313d9d98', 32, 0, 265, CAST(0x383A0B00 AS Date), 20.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1018, N'b487497e-c64a-430f-93e6-2d25d2d319b1', 32, 0, 265, CAST(0x383A0B00 AS Date), 25.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1019, N'1eaf9b39-f3fe-44ff-a1ae-2a67ee6b6753', 32, 0, 211, CAST(0x383A0B00 AS Date), 25.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1020, N'37b0e318-23b9-4367-bc75-e3f94ca58836', 32, 0, 206, CAST(0x383A0B00 AS Date), 8.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1021, N'f891d387-6614-4ce2-8e6b-2354421e79eb', 32, 0, 208, CAST(0x383A0B00 AS Date), 5.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1022, N'f458a8f1-4d4c-43ab-a61c-afac34087ab4', 32, 0, 205, CAST(0x383A0B00 AS Date), 15.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1023, N'eb61ba34-5714-4299-b618-6295ceef85fd', 32, 0, 216, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1024, N'22362711-969e-4463-bd7e-3f139e3d71c3', 32, 0, 213, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1025, N'3ad56f58-415f-461a-8a48-e533b51cfc60', 32, 0, 44, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 550.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1026, N'0558a919-3fe5-43e7-95e3-63e399fdb824', 32, 0, 266, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 200.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1027, N'aef8b6f2-6480-459d-872c-ec33be39702c', 32, 0, 206, CAST(0x383A0B00 AS Date), 3.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1028, N'1f5cdd97-304c-4483-8f4f-f0715c0370d9', 32, 0, 214, CAST(0x383A0B00 AS Date), 0.5000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1029, N'aa597900-ac74-419d-96f6-03b9c2ddc6e8', 32, 0, 230, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1030, N'49e77fbb-24c9-41f2-afc9-bd8e3b187eec', 32, 0, 211, CAST(0x383A0B00 AS Date), 50.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1031, N'698507a0-cd4a-499c-bf45-8bda1e30cbed', 32, 0, 212, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 85.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1032, N'3a5820ed-2eff-4682-bbb4-9343714d613e', 18, 0, 262, CAST(0x363A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1033, N'f5eab1b2-4c1f-4536-a6cb-4605bcee88c0', 30, 0, 9, CAST(0x383A0B00 AS Date), 5.0000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1034, N'2c4b1a2e-cb6e-467c-ab28-1c56d20084e2', 30, 0, 8, CAST(0x383A0B00 AS Date), 5.0000, 0.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1035, N'4e68ee79-c795-4e91-b702-168a65acf742', 30, 0, 21, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1036, N'aca46f7f-bfca-4a2e-9012-ef5b51f576fd', 30, 0, 14, CAST(0x383A0B00 AS Date), 9.0000, 0.0000, 194.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1037, N'b76e79c8-92cf-4175-8db6-9d31eee4e31a', 30, 0, 8, CAST(0x383A0B00 AS Date), 15.0000, 0.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1038, N'5ab4ae45-da10-46ab-855f-01eca00fabe1', 30, 0, 25, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 480.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1039, N'91fba3ef-6fc9-41cc-bd7b-121a4618b37c', 30, 0, 15, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1040, N'4b37a87d-a8db-4687-9cfb-4326b692b7c4', 30, 0, 26, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1041, N'134524a3-9560-4680-8ec0-17de9a4e833d', 30, 0, 27, CAST(0x383A0B00 AS Date), 4.0000, 0.0000, 41.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1042, N'163f5dfb-bea4-46b9-af8e-90176242508b', 30, 0, 28, CAST(0x383A0B00 AS Date), 50.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1043, N'a8687252-d5f2-4650-b33a-4b6326e7b4f7', 30, 0, 29, CAST(0x383A0B00 AS Date), 0.5000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1044, N'9099c315-d96c-4f94-bbd7-013aeaf0c5f3', 30, 0, 30, CAST(0x383A0B00 AS Date), 10.0000, 0.0000, 18.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1045, N'3da50f67-2e44-465d-a64d-a89efd382bc9', 30, 0, 21, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1046, N'80a2db11-0497-44f8-ab3c-f5b750a959de', 30, 0, 19, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 740.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1047, N'3631d1af-8736-4cda-a809-873aaa092dd9', 30, 0, 31, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1048, N'e56a9e91-1bfe-4cbe-bf0a-7f3324fac6d9', 30, 0, 33, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1049, N'347698c2-c8b4-402a-870d-f858c6744c95', 30, 0, 22, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1050, N'5b139f62-14fd-41a1-895b-6865f5d04b9b', 30, 0, 23, CAST(0x383A0B00 AS Date), 55.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1051, N'e9405ecd-cf5c-4bbb-a606-1d836c3db60d', 30, 0, 34, CAST(0x383A0B00 AS Date), 8.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1052, N'f40d63f2-9d2d-4aa1-b719-e84cee2b5d00', 30, 0, 67, CAST(0x383A0B00 AS Date), 0.5000, 0.0000, 330.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1053, N'56577e15-1eac-43ff-a3fd-2092ea6b3607', 30, 0, 35, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1054, N'49fbfda0-fe9c-4a6d-b56f-c650c5afec9a', 30, 0, 13, CAST(0x383A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1055, N'583f692d-dfad-4b64-b949-a7cf522ea260', 30, 0, 16, CAST(0x383A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1056, N'2e91f5a1-e877-408b-9a2d-ac804e7e7f28', 30, 0, 18, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 76.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1057, N'8b09ab69-6cf7-4906-a2bd-bb5dbe7a2d46', 30, 0, 8, CAST(0x383A0B00 AS Date), 12.0000, 0.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1058, N'71a9bdf9-787a-416e-8f5e-0e7fe8c63b1d', 30, 0, 19, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 740.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1059, N'd66b2f89-5def-4d21-a113-e69360090b4a', 30, 0, 20, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1060, N'c12d80d4-e81e-4fec-ba08-c589bba34336', 30, 0, 21, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1061, N'86422ee8-0235-4f4d-8617-a770a0772797', 30, 0, 22, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1062, N'1849c268-ed19-4f8a-a1bb-860e8f0c2930', 30, 0, 23, CAST(0x383A0B00 AS Date), 40.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1063, N'8f6f6557-8649-4fc1-a4ba-78c6c1f00a82', 30, 0, 67, CAST(0x383A0B00 AS Date), 0.5000, 0.0000, 330.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1064, N'204b278f-583b-42dc-8a6f-6685d36d5770', 29, 0, 202, CAST(0x383A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1065, N'fa7a0031-ca8a-416a-9901-9c28e8047cc6', 33, 0, 276, CAST(0x393A0B00 AS Date), 55.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1066, N'9d86066d-d0c4-4105-9486-6060ee048625', 34, 0, 202, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1067, N'1ae6fde3-e33d-4e01-9874-4a9c3e76a699', 35, 0, 262, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1068, N'b8819431-54e4-4a38-94b7-66daa77df435', 36, 0, 204, CAST(0x393A0B00 AS Date), 43.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1069, N'4a11f8b8-931e-4104-8728-2ba9e976e79a', 37, 0, 211, CAST(0x393A0B00 AS Date), 50.0000, 0.0000, 28.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1070, N'ddfcd4ff-7032-43be-b83a-92141f459791', 37, 0, 268, CAST(0x393A0B00 AS Date), 200.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1071, N'45c98717-cc47-4642-9a4e-98de02b4e6a5', 37, 0, 216, CAST(0x393A0B00 AS Date), 4.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1072, N'850160c6-714a-42c1-ae8a-72b2b2a2a448', 37, 0, 214, CAST(0x393A0B00 AS Date), 10.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1073, N'15837a21-7e79-4960-a3a1-04f980ef7f4a', 37, 0, 215, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1074, N'ecaa7a4e-79b7-4687-9c39-23b1d2ac6e54', 37, 0, 269, CAST(0x393A0B00 AS Date), 0.5000, 0.0000, 220.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1075, N'2ceb62f1-131c-4167-a230-d5c175574ce1', 37, 0, 242, CAST(0x393A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1076, N'62d3fb0c-aa35-4a0f-9cc6-8a757ebab783', 37, 0, 267, CAST(0x393A0B00 AS Date), 200.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1077, N'aa4494a4-10ae-419b-ab4d-a1bb31584d13', 33, 0, 17, CAST(0x393A0B00 AS Date), 10.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1078, N'315992e4-9d96-4ca2-b1fb-80c407c3e9dd', 33, 0, 68, CAST(0x393A0B00 AS Date), 10.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1079, N'e5129fa7-b7b6-40cb-a1aa-d30aa03c5471', 33, 0, 15, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1080, N'd4a95c0f-af12-4433-9785-1237449d619e', 33, 0, 9, CAST(0x393A0B00 AS Date), 7.0000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1081, N'3e6563ca-ca6e-4393-9869-e7e86363f499', 33, 0, 91, CAST(0x393A0B00 AS Date), 0.5000, 0.0000, 1600.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1082, N'c9f51afe-7c12-4d91-8c53-eba42588b3f6', 33, 0, 33, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1083, N'2af797fd-51c8-4dba-b4f8-6124920ec416', 33, 0, 21, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1084, N'f13197a9-e4fc-4f7c-8bed-99d10d18714b', 33, 0, 28, CAST(0x393A0B00 AS Date), 50.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1085, N'86b00a1c-0489-4756-b2bb-0804978a5a5a', 33, 0, 277, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1086, N'46e4d418-1d8a-4c44-b7a4-036b86a023e7', 33, 0, 276, CAST(0x393A0B00 AS Date), 65.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1087, N'40ceaef4-78b3-474b-9425-ad7b18a5347f', 33, 0, 68, CAST(0x393A0B00 AS Date), 10.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1088, N'0df9acf0-e0c1-4cf2-be25-c1dac2495be3', 33, 0, 17, CAST(0x393A0B00 AS Date), 12.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1089, N'6f8e2fcf-a155-407d-95ee-9c97de5bee66', 33, 0, 15, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1090, N'ad6171e6-bb88-4ff6-b966-7ad2a8b2629b', 33, 0, 21, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1091, N'bea94cac-5f51-4c78-bbfd-e49c384769dd', 33, 0, 22, CAST(0x393A0B00 AS Date), 1.0000, 0.0000, 350.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1092, N'c2a16490-5fb4-4231-bc54-96efe1af542c', 33, 0, 33, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1093, N'a6201031-7ab6-48bf-a038-54cc2d35da6b', 33, 0, 8, CAST(0x393A0B00 AS Date), 4.0000, 0.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1094, N'cbd2034f-ea05-4977-bfc8-7070e99dd626', 33, 0, 9, CAST(0x393A0B00 AS Date), 5.5200, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1095, N'e7511569-d9cc-4cd3-8523-c8bd3f680cb0', 33, 0, 10, CAST(0x393A0B00 AS Date), 20.0000, 0.0000, 235.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1096, N'333630c2-e331-4997-8e08-c1b10968e653', 33, 0, 9, CAST(0x393A0B00 AS Date), 4.3300, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1097, N'7db18db6-294e-43ae-9625-767f76fa615c', 33, 0, 11, CAST(0x393A0B00 AS Date), 4.0000, 0.0000, 125.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1098, N'c6a034ef-fa93-4caa-9d7c-1c8dc8b88bd7', 33, 0, 12, CAST(0x393A0B00 AS Date), 3.0000, 0.0000, 136.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1099, N'222884f5-0675-4f29-bf4b-e41910be6aa2', 38, 0, 16, CAST(0x3A3A0B00 AS Date), 3.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1100, N'b1b2fd38-4109-411c-9c29-f3122e2e2e15', 38, 0, 36, CAST(0x3A3A0B00 AS Date), 5.0000, 0.0000, 15.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1101, N'4b1daeda-c7b7-4813-a941-16be3ecba2a0', 38, 0, 37, CAST(0x3A3A0B00 AS Date), 1.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1102, N'b30777aa-e9e5-4857-b767-f9c80795ad0b', 39, 0, 204, CAST(0x3A3A0B00 AS Date), 31.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1103, N'19924c6a-1438-42f7-9961-9e377b4d571b', 40, 0, 262, CAST(0x3A3A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1104, N'a8b89aab-87f3-4a01-b5c0-4e000aa51599', 41, 0, 206, CAST(0x3A3A0B00 AS Date), 1.2000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1105, N'0d29d4b3-78bf-4314-93a6-628f1a3c7e1a', 41, 0, 214, CAST(0x3A3A0B00 AS Date), 0.4000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1106, N'978e637d-40a1-4611-b171-9494a59aad51', 41, 0, 230, CAST(0x3A3A0B00 AS Date), 2.0000, 0.0000, 6.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1107, N'0348dcae-92ee-48e0-a299-9a2909df8ba4', 41, 0, 207, CAST(0x3A3A0B00 AS Date), 2.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1108, N'a12d532d-347f-4a48-9f0d-51d964ee6f9d', 41, 0, 214, CAST(0x3A3A0B00 AS Date), 0.4000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1109, N'd0444998-fb22-4ec5-81d3-b51c9a7e636e', 37, 0, 267, CAST(0x393A0B00 AS Date), 200.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1110, N'751e4f7b-5530-488c-ac26-f37293e34baf', 37, 0, 214, CAST(0x393A0B00 AS Date), 15.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1111, N'ef00103c-fd46-4b9f-8e33-d87c975408cc', 37, 0, 213, CAST(0x393A0B00 AS Date), 20.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1112, N'fe7d5aae-ef2e-49f1-8f5a-aa33039c4fca', 37, 0, 268, CAST(0x393A0B00 AS Date), 12.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1113, N'31dd86cf-d1a8-4d99-8873-f0b0bef06dee', 37, 0, 216, CAST(0x393A0B00 AS Date), 4.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1114, N'3454b88c-c2cd-4174-884b-a6abbb223ba3', 37, 0, 215, CAST(0x393A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1115, N'cffa6d9f-dae7-4a90-8477-e521afaaa80a', 37, 0, 269, CAST(0x393A0B00 AS Date), 0.5000, 0.0000, 220.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1116, N'86dbea7d-2f7a-414a-ae0e-642fdec70bf9', 37, 0, 217, CAST(0x393A0B00 AS Date), 5.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1117, N'41905e3f-f5e1-46be-81db-0ca47fd589cf', 37, 0, 242, CAST(0x393A0B00 AS Date), 0.5000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1118, N'ac650bc4-f248-427e-8f54-930e26cc08f0', 37, 0, 218, CAST(0x393A0B00 AS Date), 26.0000, 0.0000, 620.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1119, N'5f9b33ed-8ec1-4d2d-a743-9b5230490eef', 37, 0, 218, CAST(0x393A0B00 AS Date), 27.0000, 0.0000, 620.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1120, N'2249ffaa-2806-4a9c-abaa-3c69f688ae89', 37, 0, 241, CAST(0x393A0B00 AS Date), 45.0000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1121, N'0f5ab719-5149-4e5a-89e6-a909869ef89f', 37, 0, 241, CAST(0x393A0B00 AS Date), 50.0000, 0.0000, 320.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1122, N'9c4295c9-ee44-4b5d-8c9b-82092d369432', 37, 0, 211, CAST(0x393A0B00 AS Date), 50.0000, 0.0000, 28.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1123, N'e9b5e9db-9c78-4369-a04d-d5ece739629d', 37, 0, 270, CAST(0x393A0B00 AS Date), 1.2000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1124, N'55206232-adb4-44f3-a705-89edecaaaed2', 37, 0, 214, CAST(0x393A0B00 AS Date), 0.4000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1125, N'5832e640-0c6b-4e98-a9ad-9cf40b90c64a', 42, 0, 16, CAST(0x3B3A0B00 AS Date), 3.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1126, N'f0d0c30c-018e-43d1-80e8-4f91b10fa7c8', 42, 0, 36, CAST(0x3B3A0B00 AS Date), 5.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1127, N'92bfd54b-8a2f-4362-85be-44099c9f50cd', 42, 0, 37, CAST(0x3B3A0B00 AS Date), 1.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1128, N'e4baee9c-318b-41c1-b736-fe29d041cc40', 43, 0, 206, CAST(0x3B3A0B00 AS Date), 1.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1129, N'a63e57e3-30d1-4092-a51e-bb49992f07e8', 43, 0, 214, CAST(0x3B3A0B00 AS Date), 2.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1130, N'0b9c1991-e147-4bde-bff3-664fec70f0ab', 43, 0, 224, CAST(0x3B3A0B00 AS Date), 1.0000, 0.0000, 20.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1131, N'c202e85d-4553-4285-b515-41ee4f1ad1af', 43, 0, 213, CAST(0x3B3A0B00 AS Date), 1.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1132, N'20b44b31-9c86-420e-8a34-b20997801d43', 43, 0, 205, CAST(0x3B3A0B00 AS Date), 1.2000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1133, N'726ecc4c-4d9e-410c-b1d8-873b34cd92c8', 43, 0, 214, CAST(0x3B3A0B00 AS Date), 0.4000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1134, N'71bc1e51-492a-45b1-824f-598b10a11e0e', 43, 0, 230, CAST(0x3B3A0B00 AS Date), 2.0000, 0.0000, 6.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1135, N'd9f87849-7160-4eb2-8430-5c7a2512c005', 44, 0, 202, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 1800.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1136, N'bd401a0e-bb99-410e-999b-5be96259b43b', 45, 0, 262, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1137, N'00b55a9b-5037-4d14-ac06-0a0be1a915e6', 45, 0, 262, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 2450.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1138, N'50515104-2142-44a9-84af-69eb3f2d0626', 46, 0, 36, CAST(0x3C3A0B00 AS Date), 5.0000, 0.0000, 15.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1139, N'b526831c-fcd1-4bb9-88c4-7bd068737800', 46, 0, 16, CAST(0x3C3A0B00 AS Date), 3.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1140, N'7c0e2a2d-dcdf-434b-b861-88766cb5df49', 46, 0, 37, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1141, N'711e3614-c32a-408f-9359-5cad40f07382', 46, 0, 13, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1142, N'32356f55-723f-4062-a800-bbf37a1e9740', 46, 0, 13, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1143, N'ae78b708-ec57-4115-b95a-070c3ddf2c09', 46, 0, 67, CAST(0x3C3A0B00 AS Date), 10.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1144, N'04669b12-6986-4d89-9a38-59bfc2ad59ad', 46, 0, 16, CAST(0x3C3A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1145, N'8fe12017-b81f-4a77-8ed2-b88e9a7e8405', 46, 0, 23, CAST(0x3C3A0B00 AS Date), 36.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1146, N'7a5f0599-52cb-4a8e-8845-064c5393cf2c', 46, 0, 15, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1147, N'40b4a232-1421-4231-9566-a1c64f592420', 46, 0, 17, CAST(0x3C3A0B00 AS Date), 10.0000, 0.0000, 195.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1148, N'9525d0e1-cc54-4cc3-b033-426355a3e487', 46, 0, 43, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1149, N'6509a7b6-1b86-427a-a09f-9ecbe32bbaf4', 46, 0, 278, CAST(0x3C3A0B00 AS Date), 10.0000, 0.0000, 105.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1150, N'715411ec-8526-4dcf-a43d-7c58ffd856b0', 46, 0, 40, CAST(0x3C3A0B00 AS Date), 60.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1151, N'ec4eb593-c51f-45cd-b080-08ac084b1d76', 46, 0, 8, CAST(0x3C3A0B00 AS Date), 18.0000, 0.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1152, N'581c8101-75e0-4ac4-9c76-1de0715bce54', 46, 0, 55, CAST(0x3C3A0B00 AS Date), 60.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1153, N'73c9f80c-470f-455f-b1a8-5d74c13d7db1', 46, 0, 9, CAST(0x3C3A0B00 AS Date), 5.2100, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1154, N'7ef8dc23-f83a-4ea1-ab78-089109eb86ce', 46, 0, 61, CAST(0x3C3A0B00 AS Date), 8.0000, 0.0000, 610.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1155, N'8d3bcdd3-6e7b-4ccc-bf2a-8f84be6a22a7', 46, 0, 59, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1156, N'28168da2-faa3-40ae-957b-8e4221392242', 46, 0, 33, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1157, N'37c81ff6-5718-430d-9456-2fcb8c1d0737', 46, 0, 91, CAST(0x3C3A0B00 AS Date), 0.5000, 0.0000, 1600.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1158, N'89101e54-5761-46f9-acd4-505309f26976', 46, 0, 28, CAST(0x3C3A0B00 AS Date), 50.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1159, N'1d04774a-51ab-4a59-bd9c-7986a01421eb', 46, 0, 277, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 30.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1160, N'20d38148-3e5c-49bb-949b-8ee1615d839d', 46, 0, 21, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1161, N'3a0bc6aa-e0ad-4bb0-b0d1-59f83ca3de1c', 46, 0, 44, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 1300.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1162, N'91429449-4ef1-464d-84ed-509c02b7a812', 46, 0, 13, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1163, N'12d6b522-f916-4827-9c8f-cc7743c1baf0', 46, 0, 280, CAST(0x3C3A0B00 AS Date), 10.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1164, N'd12ea4db-86c1-46f9-8db8-58a7dc39e8db', 46, 0, 23, CAST(0x3C3A0B00 AS Date), 45.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1165, N'b378fc46-52f0-4aaf-b6a7-fd540dfbf797', 46, 0, 43, CAST(0x3C3A0B00 AS Date), 6.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1166, N'f03128b3-c82c-4d2f-b6e6-0ee2cbbc7f9f', 46, 0, 25, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 480.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1167, N'1a3615c0-10f1-4da7-aea0-4ce191e271ce', 46, 0, 15, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 4250.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1168, N'e524f2ac-e4a0-44c8-b523-79b32e426a00', 46, 0, 40, CAST(0x3C3A0B00 AS Date), 50.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1169, N'a4395a67-6ad8-40a3-87df-6fefa3f81e67', 46, 0, 8, CAST(0x3C3A0B00 AS Date), 14.0000, 0.0000, 46.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1170, N'46819dbf-bf4e-419d-8c7e-3a194e246a60', 46, 0, 55, CAST(0x3C3A0B00 AS Date), 60.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1171, N'152a9db9-be9f-4245-9758-ad19c0feb08e', 46, 0, 9, CAST(0x3C3A0B00 AS Date), 4.7100, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1172, N'aff0966b-3f42-452a-9a15-745fa8b0e0d8', 46, 0, 61, CAST(0x3C3A0B00 AS Date), 8.0000, 0.0000, 610.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1173, N'3cca6f17-a66c-468b-be1c-5b46ceb048d5', 46, 0, 33, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 785.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1174, N'7ede0c3a-3e1a-45a5-8717-f3e9732de880', 46, 0, 7, CAST(0x3C3A0B00 AS Date), 200.0000, 0.0000, 20.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1175, N'aa3996b8-f93f-4358-b99d-b9a92643c5e8', 46, 0, 21, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1176, N'a25762bb-c71d-40f3-b22f-5bf5f7139eb8', 46, 0, 278, CAST(0x3C3A0B00 AS Date), 12.0000, 0.0000, 105.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1177, N'eed2c8a1-c60a-4ab1-a113-ae72fce30ad1', 46, 0, 44, CAST(0x3C3A0B00 AS Date), 2.0000, 0.0000, 1300.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1178, N'9cf38eff-4e2f-4046-bd54-366eed16b38b', 46, 0, 16, CAST(0x3C3A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1179, N'ff59e25d-1a04-49dd-9f27-a6db64e1b341', 46, 0, 17, CAST(0x3C3A0B00 AS Date), 12.0000, 0.0000, 195.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1180, N'82006901-44f6-4042-b248-53594186f223', 46, 0, 281, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 325.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1181, N'503f26b8-ae9f-43b5-a90f-ad15e2d19681', 47, 0, 213, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1182, N'8070a652-ef8b-445b-8474-3009e8e9168d', 47, 0, 270, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1183, N'f25b1ecd-a94b-4b87-b750-9f9a74bb91b4', 47, 0, 214, CAST(0x3C3A0B00 AS Date), 0.4000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1184, N'91be7b0f-3c15-4f92-a8d8-85664722a071', 47, 0, 230, CAST(0x3C3A0B00 AS Date), 3.0000, 0.0000, 7.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1185, N'dfd32f08-50ff-4c60-81f5-093d79f9334b', 47, 0, 215, CAST(0x3C3A0B00 AS Date), 3.0000, 0.0000, 3.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1186, N'c999112a-7975-4828-a18a-4c08e51c49b3', 47, 0, 206, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1187, N'2d93008b-573f-4af9-b21c-713036750719', 47, 0, 215, CAST(0x3C3A0B00 AS Date), 1.0000, 0.0000, 20.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1188, N'957e25de-e51d-484d-9650-321179177c9f', 47, 0, 214, CAST(0x3C3A0B00 AS Date), 0.5000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1189, N'd0610f3d-c5c6-4c3c-b17d-079f8cda3cee', 48, 0, 282, CAST(0x3C3A0B00 AS Date), 182.0000, 0.0000, 106.2000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1190, N'89dbd34f-8410-4aed-a08c-d3b29bfb0770', 48, 0, 158, CAST(0x3C3A0B00 AS Date), 440.0000, 0.0000, 22.8400)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1191, N'9bdfd945-6531-4d7f-812a-7efb7c35f236', 48, 0, 154, CAST(0x3C3A0B00 AS Date), 396.0000, 0.0000, 22.8400)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1192, N'356eebf2-7f09-46da-86cd-caf5a772e87d', 48, 0, 155, CAST(0x3C3A0B00 AS Date), 478.0000, 0.0000, 22.8400)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1193, N'16cf96ef-990c-4613-9fe7-349b550d84a7', 49, 0, 204, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1194, N'b426e5a6-a223-4bd6-a108-281dbc9a6337', 50, 0, 3, CAST(0x3D3A0B00 AS Date), 6.0000, 0.0000, 35.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1195, N'def3134e-07c3-4fbb-a35c-db0b7a08cf9a', 50, 0, 4, CAST(0x3D3A0B00 AS Date), 3.0000, 0.0000, 95.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1196, N'39ae9aa8-f66b-4c86-9568-7a9594b5e29b', 50, 0, 5, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 175.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1197, N'88e7391a-676c-45ef-8fdc-36f0175bf3f9', 50, 0, 6, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1198, N'122e1f5d-a081-49a1-95fb-d4bf1a6c1df9', 50, 0, 7, CAST(0x3D3A0B00 AS Date), 12.0000, 0.0000, 20.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1199, N'738fcfee-f0ec-42b7-a0d7-b370cf7c1a48', 50, 0, 283, CAST(0x3D3A0B00 AS Date), 8.0000, 0.0000, 180.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1200, N'b77c4fe1-f0a6-400a-a7d4-60624e3e7553', 50, 0, 23, CAST(0x3D3A0B00 AS Date), 4.0000, 0.0000, 60.0000)
GO
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1201, N'6061b83e-3e31-47fd-9020-fef4318393bc', 50, 0, 283, CAST(0x3D3A0B00 AS Date), 8.0000, 0.0000, 180.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1202, N'ef605641-e2bf-46f6-90b2-28b85b7a02ff', 51, 0, 205, CAST(0x3D3A0B00 AS Date), 15.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1203, N'2ba2ee46-bf1c-4726-ba94-98f3d72d176b', 51, 0, 271, CAST(0x3D3A0B00 AS Date), 22.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1204, N'3cd61b0d-a5d7-4faa-b330-4aea46960abc', 51, 0, 206, CAST(0x3D3A0B00 AS Date), 10.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1205, N'1664f83d-a4c5-49ca-b27d-61060aa44a2f', 51, 0, 208, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 115.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1206, N'ad111849-ab2d-408e-8a88-4e1a42e6c829', 51, 0, 214, CAST(0x3D3A0B00 AS Date), 15.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1207, N'636da5fc-b580-410d-ba3e-bff8ccb13fb1', 51, 0, 209, CAST(0x3D3A0B00 AS Date), 30.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1208, N'515a43e8-a841-456a-a114-b0be87077f89', 51, 0, 211, CAST(0x3D3A0B00 AS Date), 62.0000, 0.0000, 32.2600)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1209, N'de6e25c7-e34a-46ee-94e2-46db825538b1', 51, 0, 226, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1210, N'cf1864c9-c5c0-4413-adec-5045614c69e9', 51, 0, 227, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1211, N'65acedee-067f-48a1-8d35-a595e5f19226', 51, 0, 215, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 5.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1212, N'e47c1a25-d7d6-4c50-b021-7877e60daf8f', 51, 0, 227, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1213, N'33adb241-dff7-424a-9e02-8508558e694d', 51, 0, 215, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1214, N'071d9cb0-fc07-4b41-8096-e3abcffa215c', 51, 0, 224, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 1000.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1215, N'f67c8b68-a527-4c80-8d4d-89decd405062', 51, 0, 216, CAST(0x3D3A0B00 AS Date), 4.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1216, N'165634af-7b70-438a-8927-7b752f268234', 51, 0, 263, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 560.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1217, N'63769dd6-83fa-4753-be4d-1403a2906a3c', 51, 0, 266, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1218, N'a7432fdb-1970-45f3-882e-ed7a8cfb9bc0', 51, 0, 206, CAST(0x3D3A0B00 AS Date), 10.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1219, N'fad6154a-e4e8-4fa2-a56c-55965dbf71e5', 51, 0, 209, CAST(0x3D3A0B00 AS Date), 30.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1220, N'e8c820d0-fe5c-4eb3-80dd-15c4be117fe3', 51, 0, 205, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1221, N'b45e858b-7fab-49d1-8a33-ee9c04729c59', 51, 0, 208, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 115.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1222, N'75c54c7f-4a42-45b2-91a8-5296b52c34fd', 51, 0, 216, CAST(0x3D3A0B00 AS Date), 4.0000, 0.0000, 240.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1223, N'4eef761a-e9dc-436a-97f0-f5f3198d65cf', 51, 0, 211, CAST(0x3D3A0B00 AS Date), 62.5000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1224, N'9e686fc3-1e98-4a8e-8e85-026452b585bc', 51, 0, 215, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1225, N'88e3fec4-4abf-41bd-916d-fea8e12a34c9', 51, 0, 214, CAST(0x3D3A0B00 AS Date), 10.0000, 0.0000, 75.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1226, N'36e72e77-08f4-4694-9597-b0c67b5fbb6e', 51, 0, 266, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 190.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1227, N'd77072bf-12a2-4fa0-8d39-658bad1cefa9', 51, 0, 271, CAST(0x3D3A0B00 AS Date), 19.0000, 0.0000, 100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1228, N'24d393ab-0c3e-4b73-b3de-756e41daca52', 51, 0, 263, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 560.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1229, N'7d2e8c5d-13e7-44cf-8bdd-38e713580d57', 52, 0, 258, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 5900.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1230, N'e6c2cd5a-97a8-4572-b3fa-5985179c9da0', 52, 0, 102, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 75.2100)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1231, N'f4cc461f-ba22-4105-91e8-770507b39a3a', 52, 0, 141, CAST(0x3D3A0B00 AS Date), 270.0000, 0.0000, 14.1500)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1232, N'55d1fd17-0511-42da-819a-52d273f957c3', 52, 0, 115, CAST(0x3D3A0B00 AS Date), 100.0000, 0.0000, 23.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1233, N'dbe0524e-5361-457a-a269-b8c4633a6d13', 52, 0, 131, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 66.2500)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1234, N'6ba27c2a-ea13-4114-9c9d-a412983dc543', 52, 0, 101, CAST(0x3D3A0B00 AS Date), 20.0000, 0.0000, 75.2100)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1235, N'94920a73-668b-45e2-a2e6-725a1cefaf3e', 52, 0, 145, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 519.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1236, N'baf52991-2f2f-4d1e-a77d-6a96c0aae6dd', 52, 0, 144, CAST(0x3D3A0B00 AS Date), 3.0000, 0.0000, 376.1100)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1237, N'07481a00-c7e3-46d6-803b-4a6dc09196b4', 52, 0, 104, CAST(0x3D3A0B00 AS Date), 24.0000, 0.0000, 23.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1238, N'f0cdb22b-cd08-4d58-b41d-afe35d8af936', 52, 0, 261, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 53.1000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1239, N'681f0df3-0e25-4591-8954-deedd83afdf0', 52, 0, 259, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 61.9500)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1240, N'3cc45a4b-dc72-4d23-8b5d-da8e2967edcb', 52, 0, 260, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 23.8900)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1241, N'5cf8d145-9e4d-4a64-8add-c2802b7f65de', 52, 0, 135, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 48.6700)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1242, N'026feef5-5e79-4f8b-a33c-3418bc85b7a1', 52, 0, 134, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 9.7300)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1243, N'f1756006-fa43-4ae9-8310-c6570486a545', 52, 0, 100, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 710.7600)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1244, N'3c76029c-b5f7-469d-855c-0fe3b21d09f4', 52, 0, 105, CAST(0x3D3A0B00 AS Date), 12.0000, 0.0000, 31.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1245, N'44c28555-9a53-43ff-bd06-9641055ae0f3', 52, 0, 118, CAST(0x3D3A0B00 AS Date), 144.0000, 0.0000, 6.1900)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1246, N'e2517ece-bc82-4be4-a388-542148f1dab6', 52, 0, 117, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 1080.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1255, N'81287a4e-da95-4ce6-98b3-5639395c3a5e', 53, 0, 244, CAST(0x3D3A0B00 AS Date), 40.0000, 0.0000, 40.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1256, N'34034f8b-73e9-4da3-b68a-0935c7c70da7', 53, 0, 245, CAST(0x3D3A0B00 AS Date), 15.0000, 0.0000, 70.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1257, N'82d18265-89a5-4508-a5d3-5a9e99f2d347', 53, 0, 246, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 650.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1258, N'3c37e8f8-aa5c-4cac-8f52-15b2afe86599', 53, 0, 247, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 225.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1259, N'3716337a-0f0e-4a65-9ebc-5816997e44eb', 53, 0, 248, CAST(0x3D3A0B00 AS Date), 5.0000, 0.0000, 50.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1260, N'f9afbe67-4580-419e-a150-891d66873ce8', 53, 0, 250, CAST(0x5C3A0B00 AS Date), 2.0000, 0.0000, 700.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1261, N'46ce7fc5-87b9-4407-849c-84ab2cc7d02f', 53, 0, 251, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1262, N'4b8e9fa0-fb18-434f-87a3-defefc83b349', 53, 0, 179, CAST(0x3D3A0B00 AS Date), 4.0000, 0.0000, 25.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1264, N'6f1949e6-a2e7-4ae1-aace-4e129650df99', 49, 0, 204, CAST(0x3D3A0B00 AS Date), 24.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1265, N'683ec008-9a5b-4d50-a5dc-3333fbd2487a', 50, 0, 20, CAST(0x3D3A0B00 AS Date), 0.5000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1266, N'e2d56e96-39c1-4738-8583-3da2b1566a80', 50, 0, 13, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1267, N'3e92e049-3589-404f-8aa4-53b3bd587b06', 50, 0, 58, CAST(0x3D3A0B00 AS Date), 9.0000, 0.0000, 128.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1268, N'09bfc383-6d68-460e-a7a9-0c0131af8f51', 50, 0, 16, CAST(0x3D3A0B00 AS Date), 50.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1269, N'd3f33a25-a3cb-44dd-8c91-ea6594408910', 50, 0, 40, CAST(0x3D3A0B00 AS Date), 54.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1270, N'46204eee-3372-4d78-9d94-8fa6085fde95', 50, 0, 57, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 1435.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1271, N'84900953-8a1c-44a7-a47b-2bfb5f9b0c80', 50, 0, 88, CAST(0x3D3A0B00 AS Date), 12.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1272, N'14c87569-14b2-4397-bb19-60971164ac4b', 50, 0, 21, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 160.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1273, N'8d8dce15-e25b-41e4-8d33-cbb343328260', 50, 0, 87, CAST(0x3D3A0B00 AS Date), 12.0000, 0.0000, 8.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1274, N'46ffd18f-fcc6-48cd-a998-de6e5c33245d', 50, 0, 23, CAST(0x3D3A0B00 AS Date), 40.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1275, N'257924df-5ef8-4adb-aec0-dd65c14be9fa', 50, 0, 9, CAST(0x3D3A0B00 AS Date), 4.6000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1276, N'089206b9-ab2c-4a29-a055-310502c2d1a5', 50, 0, 17, CAST(0x3D3A0B00 AS Date), 4.0000, 0.0000, 195.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1277, N'a7cedbf8-7b83-4be2-bb31-9b6958b26d54', 50, 0, 13, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 2100.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1278, N'5ab86bc0-203c-4755-9abe-9465658c5d1a', 50, 0, 16, CAST(0x3D3A0B00 AS Date), 60.0000, 0.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1279, N'd15d12a6-04b4-41fa-9b65-d6af3ffec377', 50, 0, 58, CAST(0x3D3A0B00 AS Date), 8.0000, 0.0000, 128.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1280, N'5587a929-4d23-48eb-8cde-7c0c54f6d731', 50, 0, 40, CAST(0x3D3A0B00 AS Date), 50.0000, 0.0000, 120.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1281, N'47d10fe7-ec56-4def-9262-ca02db8d0b67', 50, 0, 62, CAST(0x3D3A0B00 AS Date), 2.0000, 0.0000, 140.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1282, N'76932152-cfb2-4832-bcc6-1b68a1a46995', 50, 0, 20, CAST(0x3D3A0B00 AS Date), 1.0000, 0.0000, 500.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1283, N'dd3bdcca-fe77-4314-b8db-ee53dc014601', 50, 0, 23, CAST(0x3D3A0B00 AS Date), 55.0000, 0.0000, 60.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1284, N'9e8a6032-630a-49f6-8e66-4e4204e2bf19', 50, 0, 9, CAST(0x3D3A0B00 AS Date), 4.6000, 0.0000, 850.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1285, N'a347eb6f-4ec5-47e1-b2f9-9d27c66a2e99', 51, 0, 205, CAST(0x3D3A0B00 AS Date), 1.2000, 0.0000, 90.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1286, N'b1eddce3-ce79-4312-9b3b-901b1f16ce10', 51, 0, 215, CAST(0x3D3A0B00 AS Date), 3.0000, 0.0000, 10.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1287, N'a16c6f6d-1fd1-414a-ae4e-4c2e352bb580', 51, 0, 214, CAST(0x3D3A0B00 AS Date), 0.4000, 0.0000, 80.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (1288, N'64572479-cc7b-4dec-bdde-9cd14f6fd497', 54, 0, 284, CAST(0x3D3A0B00 AS Date), 120.0000, 0.0000, 665.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (2358, N'0701d2eb-0024-47bb-9d54-89f8bb3fc5d3', 0, 4, 8, CAST(0x833A0B00 AS Date), 0.0000, 2.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (2359, N'923d22ba-d279-48dc-8957-0c6036592e92', 0, 4, 8, CAST(0x833A0B00 AS Date), 0.0000, 8.0000, 42.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (2360, N'aeff5cfe-0594-4423-89d9-3c0ec6cdf6ea', 0, 1, 16, CAST(0x853A0B00 AS Date), 0.0000, 75.0000, 32.0000)
INSERT [dbo].[tbl_transaction] ([id], [transactionId], [grn], [isn], [itemId], [Date], [recQuantity], [issQuantity], [rate]) VALUES (2361, N'9e8c0604-b84f-43e1-b2a7-54fdb2d573e6', 0, 1, 16, CAST(0x853A0B00 AS Date), 0.0000, 500.0000, 32.0000)
SET IDENTITY_INSERT [dbo].[tbl_transaction] OFF
INSERT [dbo].[tbl_UserInfo] ([Id], [FullName], [UserName], [Password], [UserType], [DeptId]) VALUES (N'60ee4ccd-bbfb-47d9-9d2c-06524a454cd0', N'Admin', N'admin', N'admin@ullens', N'Admin', 1)
INSERT [dbo].[tbl_UserInfo] ([Id], [FullName], [UserName], [Password], [UserType], [DeptId]) VALUES (N'9b2183db-bbd2-4bff-b359-37d213e77ffd', N'Ruby Shrestha', N'ruby', N'iam@ullens', N'User', 1)
INSERT [dbo].[tbl_UserInfo] ([Id], [FullName], [UserName], [Password], [UserType], [DeptId]) VALUES (N'6918e82b-cfb5-4087-a980-96f6ca98769f', N'Admin', N'admin', N'superAdmin@ullens', N'admin', 1)
INSERT [dbo].[tbl_UserInfo] ([Id], [FullName], [UserName], [Password], [UserType], [DeptId]) VALUES (N'49c0d2ee-f632-413a-9956-9b660f9466ff', N'Arati Tiwary', N'arati', N'iam@ullens', N'User', 1)
INSERT [dbo].[tbl_UserInfo] ([Id], [FullName], [UserName], [Password], [UserType], [DeptId]) VALUES (N'c6a9c08d-af31-4235-8da2-ccc1b21071fb', N'Hari Devkota', N'hari', N'iam@ullens', N'User', 1)
SET IDENTITY_INSERT [dbo].[tbl_Vendor] ON 

INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (1, N'Opening Balance', N'NA', N'123456')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (2, N'Ram Store', N'Khumaltar', N'5570717')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (3, N'Ramesh Khadya Store', N'Khumaltar', N'5570623')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (4, N'Pashupati Marketing and sales', N'Putalisadak,Kathmandu', N'4240695')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (5, N'Manandhar Drinking water supplier', N'Taukhel,Godawari', N'5560719')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (6, N'Jalbire water supplier', N'Swombhu', N'4285038')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (7, N'Sparsha Printers', N'Lalitpur', N'9851017896')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (8, N'Khushi International', N'Kathmandu', N'4241411')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (9, N'Best Tailor', N'Kumaripati', N'5537940')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (10, N'R.B Drycleaning', N'Sanepa', N'9841267132')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (11, N'Astalaxmi Books and Stationery General Suppliers', N'Pulchowk,Lalitpur', N'5542249')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (12, N'Chitra Store', N'Kathmandu', N'1234567')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (13, N'B.S.B Traders', N' Kathmandu', N'123456')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (14, N'Silk Road Investment and Trading PTV.LTD', N'New Road', N'4233018')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (15, N'RIKESH BOOKS', N'Khumaltar-15, lalitpur', N'9841453729')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (16, N'Pasupati traders and suppliers', N'Lalitpur', N'015570724')
INSERT [dbo].[tbl_Vendor] ([VendorId], [VendorName], [Address], [PhoneNo]) VALUES (17, N'Anmol Enterprises', N'Jawalakhel', N'015570724')
SET IDENTITY_INSERT [dbo].[tbl_Vendor] OFF
ALTER TABLE [dbo].[tbl_Balance]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
ALTER TABLE [dbo].[tbl_BalanceDetail]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
ALTER TABLE [dbo].[tbl_IssuedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([ItemId])
REFERENCES [dbo].[tbl_Item] ([ItemId])
GO
ALTER TABLE [dbo].[tbl_ReceivedItem]  WITH CHECK ADD FOREIGN KEY([VendorId])
REFERENCES [dbo].[tbl_Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[tbl_UserInfo]  WITH CHECK ADD FOREIGN KEY([DeptId])
REFERENCES [dbo].[tbl_Department] ([DeptId])
GO
USE [master]
GO
ALTER DATABASE [IMS] SET  READ_WRITE 
GO
