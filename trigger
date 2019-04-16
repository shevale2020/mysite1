USE [AMS]
GO
/****** Object:  Trigger [dbo].[insert_Staff_table]    Script Date: 4/16/2019 11:07:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[insert_Staff_table] ON [dbo].[Staff]
	AFTER INSERT
	AS
	BEGIN

		INSERT INTO
		Users
		(
		  [UserName],[Passward],[FullName],[StaffID],[IsAdmin],[IsEnabled],[CreatedBy]
		  ,[CreatedOn],[ModifiedBy],[ModifiedOn],[Role]
		)
		SELECT
			[StaffUserName],[StaffPassword],[StaffName],[StaffID],
			Case when Role='A' then 1 else 0 end ,
			IsActive,
			[CreatedBy],[CreatedOn]
			,[ModifiedBy],[ModifiedOn],[Role]
		FROM
			inserted 

			

	END
