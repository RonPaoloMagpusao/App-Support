# App Support stored procedures

The sixteen `dbo.AppSupport_*` stored procedures on Horizon2: execute samples, full bodies and warnings.

Last reviewed: 23 September 2026
Sources: Confluence AS page 2485059655, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 2485059655 · Last updated: 15 Sep 2026 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/2485059655/Store+Procedures+for+App+Support+-+Common+datafixes

Sixteen parameterised `dbo.AppSupport_*` procedures, all on database `Horizon2`. The page has
numbered items 1 to 18 (items 16 and 17 both call the same procedure; item 18 is a repeat of
15 with flag variations; item 19 is empty). Each item has an execute sample and the full
`CREATE OR ALTER PROCEDURE` body.

Note on redaction: the source page's execute samples for items 6 and 8 contain real encrypted
password values. `[CREDENTIAL REDACTED - see Confluence page 2485059655]` is used below in
their place.

## 1. Update contact number and IsActive

```sql
EXEC dbo.AppSupport_UpdateCustomerContactNumber
    @CustomerId = 000000,
    @CustomerContactNoId = 000000,
    @NewNumber = '04000000',
    @IsActive = 1;

SELECT * FROM CustomerContactNo WHERE CustomerId = <CustomerId>;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_UpdateCustomerContactNumber
(
    @CustomerId BIGINT,
    @CustomerContactNoId BIGINT,
    @NewNumber VARCHAR(20),
    @IsActive BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE CustomerContactNo
        SET Number   = @NewNumber,
            IsActive = @IsActive
        WHERE CustomerContactNoId = @CustomerContactNoId
          AND CustomerId = @CustomerId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 2. Delete duplicate customer number

```sql
EXEC dbo.AppSupport_DeleteCustomerContactNumber
    @CustomerId = 00000,
    @CustomerContactNoId = 000000;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_DeleteCustomerContactNumber
(
    @CustomerId BIGINT,
    @CustomerContactNoId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM CustomerContactNo
        WHERE CustomerContactNoId = @CustomerContactNoId
          AND CustomerId = @CustomerId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 3. Update email address and IsActive

```sql
EXEC dbo.AppSupport_UpdateCustomerEmail
    @CustomerId = 000000,
    @CustomerEmailId = 000000,
    @EmailAddress = 'sample@example.com',
    @IsActive = 1;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_UpdateCustomerEmail
(
    @CustomerId BIGINT,
    @CustomerEmailId BIGINT,
    @EmailAddress VARCHAR(255),
    @IsActive BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE CustomerEmail
        SET EmailAddress = @EmailAddress,
            IsActive     = @IsActive
        WHERE CustomerEmailId = @CustomerEmailId
          AND CustomerId = @CustomerId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 4. Delete duplicate email address

```sql
EXEC dbo.AppSupport_DeleteCustomerEmail
    @CustomerId = 00000,
    @CustomerEmailId = 0000000;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_DeleteCustomerEmail
(
    @CustomerId BIGINT,
    @CustomerEmailId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM CustomerEmail
        WHERE CustomerEmailId = @CustomerEmailId
          AND CustomerId = @CustomerId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 5. Merge account or transfer application

```sql
USE Horizon2

EXEC AppSupport_MoveAppToCustomer
    @ApplicationId = 0000000000, -- app to move
    @CustomerId = 00000;         -- main account

-- Test
SELECT ApplicationId, CustomerId FROM [Application] WHERE ApplicationId = <ApplicationId>;
```

```sql
USE Horizon2
CREATE OR ALTER PROCEDURE dbo.AppSupport_MoveAppToCustomer
    @ApplicationId BIGINT,
    @CustomerId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        UPDATE [Application]
        SET CustomerId = @CustomerId
        WHERE ApplicationId = @ApplicationId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('No application found for the given ApplicationId.', 16, 1);
        END;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        DECLARE
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
```

## 6. Update customer account, the most dangerous procedure here

```sql
EXEC dbo.AppSupport_UpdateCustomerAccount
    @CustomerId = 000000,
    @CustomerAccountId = 00000000,
    @BrandId = 1,
    @Username = 'sample@example.com',
    @Password = '[CREDENTIAL REDACTED - see Confluence page 2485059655]',
    @IsActive = 1;

SELECT * FROM CustomerAccount WHERE CustomerId = <CustomerId>;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_UpdateCustomerAccount
(
    @CustomerId BIGINT,
    @CustomerAccountId BIGINT,
    @BrandId SMALLINT,
    @Username VARCHAR(255),
    @Password VARCHAR(255),
    @IsActive BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE CustomerAccount
        SET BrandId   = @BrandId,
            Username  = @Username,
            Password  = @Password,
            IsActive  = @IsActive
        WHERE CustomerId = @CustomerId
          AND CustomerAccountId = @CustomerAccountId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

No parameter has a default. Every call overwrites BrandId, Username, Password and IsActive
together.

## 7. Remove incorrect uploaded file

```sql
EXEC dbo.AppSupport_DeleteFileUpload
    @ApplicationId = 0000000000,
    @FileUploadId = 0000000;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_DeleteFileUpload
(
    @ApplicationId BIGINT,
    @FileUploadId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM FileUpload
        WHERE ApplicationId = @ApplicationId
          AND FileUploadId = @FileUploadId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 8. Create customer account

```sql
EXEC dbo.AppSupport_InsertCustomerAccount
    @CustomerId = 00000,
    @BrandId = 1,
    @Username = 'sample@example.com',
    @Password = '[CREDENTIAL REDACTED - see Confluence page 2485059655]',
    @IsActive = 1,
    @CreatedByUserId = 1;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_InsertCustomerAccount
(
    @CustomerId BIGINT,
    @BrandId SMALLINT,
    @Username VARCHAR(255),
    @Password VARCHAR(255),
    @IsActive BIT,
    @CreatedByUserId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO CustomerAccount
        (CustomerId, BrandId, Username, Password, IsActive, DateCreated, CreatedByUserId)
        VALUES
        (@CustomerId, @BrandId, @Username, @Password, @IsActive, GETDATE(), @CreatedByUserId);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 9. PL/SPL remove PPSR and set vehicle asset status to Removed

```sql
EXEC dbo.AppSupport_PLRemovePPSR
    @EdxApplicationId = 0000000000,
    @VehicleApplicationId = 00000000000,
    @TaskApplicationId = 00000000000,
    @TaskId = 00000,
    @ClosedByUserId = 00;

SELECT ApplicationId, IsDischarged, DateDischarged FROM EdxRegistration WHERE ApplicationId = <id>;
SELECT VehicleAssetStatusTypeId, VehicleStatusDate FROM vehicleAsset WHERE ApplicationId = <id>;
SELECT * FROM Task WHERE ApplicationId = <id> AND Status = 'Open' AND TaskTypeId = 178;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_PLRemovePPSR
(
    @EdxApplicationId BIGINT,
    @VehicleApplicationId BIGINT,
    @TaskApplicationId BIGINT,
    @TaskId INT,
    @ClosedByUserId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Discharge EdxRegistration
        UPDATE EdxRegistration
        SET IsDischarged = 1,
            DateDischarged = GETDATE()
        WHERE ApplicationId = @EdxApplicationId;

        -- 2. Update vehicleAsset status
        UPDATE vehicleAsset
        SET VehicleAssetStatusTypeId = 102005,
            VehicleStatusDate = GETDATE()
        WHERE ApplicationId = @VehicleApplicationId;

        -- 3. Close Task
        UPDATE Task
        SET [Status] = 'Closed',
            ClosedByUserId = @ClosedByUserId,
            DateClosed = GETDATE()
        WHERE ApplicationId = @TaskApplicationId
          AND TaskId = @TaskId
          AND [Status] = 'Open';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 10. APY remove PPSR and set vehicle asset status to Removed

Identical shape to 9 but the second UPDATE targets `AutopayApplication` instead of
`vehicleAsset`. Parameters: `@EdxApplicationId`, `@AutopayApplicationId`,
`@TaskApplicationId`, `@TaskId`, `@ClosedByUserId`.

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_APYRemovePPSR
(
    @EdxApplicationId BIGINT,
    @AutopayApplicationId BIGINT,
    @TaskApplicationId BIGINT,
    @TaskId INT,
    @ClosedByUserId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE EdxRegistration
        SET IsDischarged = 1, DateDischarged = GETDATE()
        WHERE ApplicationId = @EdxApplicationId;

        UPDATE AutopayApplication
        SET VehicleAssetStatusTypeId = 102005, VehicleStatusDate = GETDATE()
        WHERE ApplicationId = @AutopayApplicationId;

        UPDATE Task
        SET [Status] = 'Closed', ClosedByUserId = @ClosedByUserId, DateClosed = GETDATE()
        WHERE ApplicationId = @TaskApplicationId AND TaskId = @TaskId AND [Status] = 'Open';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 11. Update PPSR (in fact an INSERT into EdxRegistration)

```sql
EXEC dbo.AppSupport_UpdatePPSR
    @RegistrationTypeId = 79001,
    @ApplicationId = 0000000000,             -- only edit this
    @RegistrationNumber = '00000000000000',  -- only edit this
    @Status = 'Confirmed',
    @IsFinalStatus = 1,
    @EsisId = 0000,                          -- only edit this
    @RegistrationStartDate = '2024-06-27',   -- only edit this
    @RegistrationEndDate = '2031-06-27',     -- only edit this
    @RegistrationChangeNumber = 0000000,     -- only edit this
    @IsDischarged = 0,
    @DateDischarged = NULL,
    @CreatedByUserId = 10;
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_UpdatePPSR
(
    @RegistrationTypeId INT,
    @ApplicationId BIGINT,
    @RegistrationNumber VARCHAR(100),
    @Status VARCHAR(100),
    @IsFinalStatus BIT,
    @EsisId BIGINT,
    @RegistrationStartDate DATETIME,
    @RegistrationEndDate DATETIME,
    @RegistrationChangeNumber BIGINT,
    @IsDischarged BIT = 0,
    @DateDischarged DATETIME = NULL,
    @CreatedByUserId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [dbo].[EdxRegistration]
        (RegistrationTypeId, ApplicationId, RegistrationId, RegistrationNumber, Status,
         IsFinalStatus, EsisId, RegistrationStartDate, RegistrationEndDate,
         RegistrationChangeNumber, IsDischarged, DateDischarged, CreatedByUserId, DateCreated)
        VALUES
        (@RegistrationTypeId, @ApplicationId,
         '00000000-0000-0000-0000-000000000000', -- keep as is
         @RegistrationNumber, @Status, @IsFinalStatus, @EsisId, @RegistrationStartDate,
         @RegistrationEndDate, @RegistrationChangeNumber, @IsDischarged, @DateDischarged,
         @CreatedByUserId, GETDATE());
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 12. Change to Default (DC) payment method

```sql
EXEC dbo.AppSupport_UpdateToDefaultPaymentMethod @ApplicationId = 1000123456
```

```sql
USE Horizon2
CREATE OR ALTER PROCEDURE dbo.AppSupport_UpdateToDefaultPaymentMethod
    @ApplicationId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        UPDATE [AdditionalData] SET Value = 4
        WHERE AdditionalDataTypeId = 32 AND ApplicationId = @ApplicationId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('No application found for the given ApplicationId.', 16, 1);
        END;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
```

## 13. Add Horizon permission

```sql
EXEC dbo.AppSupport_InsertRoleAccess
    @RoleIds = '70,71',
    @TabIds = '295,296',
    @AccessLevelId = 1;

SELECT * FROM webpages_Roles ORDER BY RoleId;  -- Roles; RoleId
SELECT * FROM RoleAccess WHERE RoleId = 36;    -- Update/Insert; RoleId, TabId, AccessLevelId
SELECT * FROM Tab WHERE TabId = 295;           -- Permission; TabId

-- TabId 295 = Stages_AFCA_Arrangement, 296 = Stages_AFCA_Arrangement_Broken
-- AccessLevelId 1 = View
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_InsertRoleAccess
(
    @RoleIds NVARCHAR(MAX),
    @TabIds NVARCHAR(MAX),
    @AccessLevelId INT = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        CREATE TABLE #RoleList (RoleId INT);
        INSERT INTO #RoleList (RoleId) SELECT value FROM STRING_SPLIT(@RoleIds, ',');

        CREATE TABLE #TabList (TabId INT);
        INSERT INTO #TabList (TabId) SELECT value FROM STRING_SPLIT(@TabIds, ',');

        INSERT INTO RoleAccess (RoleId, TabId, AccessLevelId)
        SELECT r.RoleId, t.TabId, @AccessLevelId
        FROM #RoleList r CROSS JOIN #TabList t
        WHERE NOT EXISTS (
            SELECT 1 FROM RoleAccess ra
            WHERE ra.RoleId = r.RoleId AND ra.TabId = t.TabId AND ra.AccessLevelId = @AccessLevelId
        );

        DROP TABLE #RoleList;
        DROP TABLE #TabList;
    END TRY
    BEGIN CATCH
        DROP TABLE IF EXISTS #RoleList;
        DROP TABLE IF EXISTS #TabList;
        THROW;
    END CATCH
END;
GO
```

## 14. Cancel transaction and add notes (reason + MHD ticket number)

```sql
EXEC dbo.AppSupport_CancelTransaction
    @TransactionId = 00000000,     -- edit this
    @ApplicationId = 00000000000,  -- edit this
    @Notes = 'Cancelling this due to'; -- edit this, add ticket (MHD-XXXXX) and reason

SELECT TransactionStatusId, TransactionId, ApplicationId, TranAmount, TranDate, Notes
FROM [Transaction]
WHERE TransactionId = <id> AND ApplicationId = <id>;

EXEC UpdateAmounts <ApplicationId>;
GO
```

```sql
USE Horizon2;
GO
CREATE OR ALTER PROCEDURE dbo.AppSupport_CancelTransaction
(
    @TransactionId BIGINT,
    @ApplicationId BIGINT,
    @Notes VARCHAR (500)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [Transaction]
        SET TransactionStatusId = '1005',
            Notes = @Notes
        WHERE TransactionId = @TransactionId
          AND ApplicationId = @ApplicationId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
```

## 15. Delete funding records

```sql
-- With backup and close tasks
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10000000000,
    @MHDTicket     = 'MHD0000', -- backup will not run if this is empty
    @CreateBackup  = 1,         -- 1 if backup, 0 if skip
    @CloseTask     = 1;         -- 1 if close, 0 if skip
```

```sql
CREATE PROCEDURE dbo.AppSupport_DeleteFundingRecords
    @ApplicationId BIGINT,
    @MHDTicket     NVARCHAR(20) = NULL,   -- required if @CreateBackup = 1
    @CreateBackup  BIT = 1,               -- 1 = create backups (default), 0 = skip
    @CloseTask     BIT = 1                -- 1 = close tasks (default), 0 = skip
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SQL NVARCHAR(MAX);

    -- Guard: ticket must be provided if backup is enabled
    IF @CreateBackup = 1 AND (@MHDTicket IS NULL OR LTRIM(RTRIM(@MHDTicket)) = '')
    BEGIN
        RAISERROR('@MHDTicket is required when @CreateBackup = 1.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Backup tables (optional)
        IF @CreateBackup = 1
        BEGIN
            SET @SQL = N'SELECT * INTO fundingactivity_' + @MHDTicket +
                       N' FROM fundingactivity WHERE applicationid = ' + CAST(@ApplicationId AS NVARCHAR(20));
            EXEC sp_executesql @SQL;

            SET @SQL = N'SELECT * INTO fundingscheduling_' + @MHDTicket +
                       N' FROM fundingscheduling WHERE applicationid = ' + CAST(@ApplicationId AS NVARCHAR(20));
            EXEC sp_executesql @SQL;

            SET @SQL = N'SELECT * INTO funding_' + @MHDTicket +
                       N' FROM funding WHERE applicationid = ' + CAST(@ApplicationId AS NVARCHAR(20));
            EXEC sp_executesql @SQL;
        END

        DELETE FROM fundingactivity   WHERE applicationid = @ApplicationId;
        DELETE FROM fundingscheduling WHERE applicationid = @ApplicationId;
        DELETE FROM funding           WHERE applicationid = @ApplicationId;

        -- Close related tasks (optional)
        IF @CloseTask = 1
        BEGIN
            UPDATE dbo.Task
            SET [Status]       = 'Closed',
                ClosedByUserId = 1,
                DateClosed     = GETDATE(),
                Note           = 'Retry Funding - Closing task to Retry (' + @MHDTicket + ')' + CHAR(13) + CHAR(10) + ISNULL(Note, '')
            WHERE ApplicationId = @ApplicationId
              AND TaskTypeId IN (65, 77)
              AND IsActive = 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
```

## 16 and 17. Insert BrandId = 5 customer contact and email

Triggered by the task "Review Funding Follow up: Please check customer contact details!"
Items 16 and 17 on the page call the same procedure; it writes both a `CustomerContactNo` row
and a `CustomerEmail` row at `BrandId 5`.

```sql
EXEC dbo.AppSupport_InsertApyContactNEmail
    @CustomerId = 0000000,      -- copy from the BrandId 1 row
    @ContactNoTypeId = 0000,    -- copy from the BrandId 1 row
    @EmailTypeId = 0000,        -- copy from the BrandId 1 row
    @Number = '0400000000',     -- copy from the BrandId 1 row
    @EmailAddress = 'email',    -- copy from the BrandId 1 row
    @DateCreated = '2026-03-06 11:14:08.883'; -- copy from the BrandId 1 row

SELECT * FROM CustomerEmail     WHERE CustomerId = 000000;
SELECT * FROM CustomerContactNo WHERE CustomerId = 000000;
```

```sql
USE Horizon2
CREATE OR ALTER PROCEDURE dbo.AppSupport_InsertApyContactNEmail
    @CustomerId BIGINT,
    @ContactNoTypeId INT,
    @EmailTypeId INT,
    @Number VARCHAR(50),
    @EmailAddress VARCHAR(100),
    @DateCreated DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO [CustomerContactNo]
            (BrandId, CustomerId, ContactNoTypeId, Number, IsActive, DateCreated, CreatedByUserId)
        VALUES
            (5, @CustomerId, @ContactNoTypeId, @Number, 1, @DateCreated, 1);

        INSERT INTO [CustomerEmail]
            (BrandId, CustomerId, EmailTypeId, EmailAddress, IsActive, DateCreated, CreatedByUserId)
        VALUES
            (5, @CustomerId, @EmailTypeId, @EmailAddress, 1, @DateCreated, 1);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
```

## 18. Delete funding records to fund an app (consult Albert, or if Albert requests help)

```sql
-- With backup and close tasks
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10002975686, @MHDTicket = 'MHD0000', @CreateBackup = 1, @CloseTask = 1;

-- Skip backup, still close tasks
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10002975686, @MHDTicket = 'MHD0000', @CreateBackup = 0, @CloseTask = 1;

-- Skip both backup and task close
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10002975686, @CreateBackup = 0, @CloseTask = 0;
```

Item 19 on the source page is empty.

---
