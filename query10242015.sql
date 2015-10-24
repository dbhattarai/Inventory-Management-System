--Alter Table Userinfo

Alter TABLE [dbo].[tbl_UserInfo]
	 add [Salt] [nvarchar](50) NULL


-- Alter Proc procUserInfo

USE [IMS]
GO
/****** Object:  StoredProcedure [dbo].[procUserInfo]    Script Date: 10/24/2015 17:16:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[procUserInfo]
(
	@Username varchar(30)
	--@Password varchar(30)
	--@role varchar(30)
)
AS
BEGIN

    SELECT * from tbl_UserInfo WHERE Username=@Username --AND Password=@Password
	
END

--Alter proc Save user

USE [IMS]
GO
/****** Object:  StoredProcedure [dbo].[procSaveUser]    Script Date: 10/24/2015 23:36:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[procSaveUser]
(
@FullName nvarchar(50)
,@UserName nvarchar(50)
,@Password nvarchar(50)
,@salt nvarchar(50)
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
,Salt = @salt
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
	Salt,
	UserType,
	DeptId,
	Id
	)
	values
	(
	@FullName,
	@UserName,
	@Password,
	@salt,
	@UserType,
	@DeptId,
	@UserId
	)
	select SCOPE_IDENTITY()
end	
END