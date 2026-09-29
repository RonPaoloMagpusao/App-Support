-- Ticket: MHD-35969
-- Reverse write-off for applications 10002731004 and 10002731026.
-- Corrected, re-run-safe revision of the script originally attached 2026-08-24.
--
-- Changes vs the original:
--   1. Backup tables are no longer dropped at the start. They are created only if
--      missing, so a re-run cannot destroy the previous run's backup.
--   2. @AmortizationId is reset to NULL at the top of every loop iteration. In the
--      original it was declared once outside the loop and only ever assigned, so an
--      application with no matching TransactionTypeId 14 / TransactionStatusId 1003
--      transaction inherited the previous application's id and ran the Amortization
--      delete against the wrong row.
--   3. Amortization and AmortizationHistory are now backed up before deletion. The
--      original deleted from both with no backup at all.
--   4. Backup inserts are guarded with NOT EXISTS so a re-run cannot duplicate
--      backup rows.
--   5. Added a verify block with count assertions scoped to the rows actually changed.
--
-- Not covered by backups: dbo.UpdateAmounts writes derived balances on Application.
-- That is recalculated, not restored, so an undo means re-running UpdateAmounts.

USE Horizon2;

BEGIN TRAN;

-- ---------------------------------------------------------------------------
-- 1. Target applications
-- ---------------------------------------------------------------------------
DECLARE @AffectedApps TABLE (ApplicationId BIGINT, IsProcessed BIT);
DECLARE @CurrentAppId  BIGINT;
DECLARE @AmortizationId BIGINT;

INSERT INTO @AffectedApps (ApplicationId, IsProcessed)
SELECT CAST([Value] AS BIGINT), 0
FROM dbo.fn_SplitString('10002731004,10002731026', ',');

-- ---------------------------------------------------------------------------
-- 2. Backup tables: create only if missing, never drop
-- ---------------------------------------------------------------------------
IF OBJECT_ID('dbo.TransactionHistory_MHD35969') IS NULL
BEGIN
    SELECT * INTO TransactionHistory_MHD35969 FROM TransactionHistory WHERE 1 = 0;
    ALTER TABLE TransactionHistory_MHD35969 ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

IF OBJECT_ID('dbo.Transaction_MHD35969') IS NULL
BEGIN
    SELECT * INTO Transaction_MHD35969 FROM [Transaction] WHERE 1 = 0;
    ALTER TABLE Transaction_MHD35969 ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

IF OBJECT_ID('dbo.AdditionalData_MHD35969') IS NULL
BEGIN
    SELECT * INTO AdditionalData_MHD35969 FROM AdditionalData WHERE 1 = 0;
    ALTER TABLE AdditionalData_MHD35969 ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

IF OBJECT_ID('dbo.ApplicationWorkFlow_MHD35969') IS NULL
BEGIN
    SELECT * INTO ApplicationWorkFlow_MHD35969 FROM ApplicationWorkFlow WHERE 1 = 0;
    ALTER TABLE ApplicationWorkFlow_MHD35969 ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

IF OBJECT_ID('dbo.ApplicationWorkFlow2_MHD35969') IS NULL
BEGIN
    SELECT * INTO ApplicationWorkFlow2_MHD35969 FROM ApplicationWorkFlow2 WHERE 1 = 0;
    ALTER TABLE ApplicationWorkFlow2_MHD35969 ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

-- The Amortization rows that will be removed, resolved up front so each backup
-- can be taken with a single SELECT ... INTO. Do NOT back these up inside the
-- loop with an INSERT: SELECT INTO copies the IDENTITY property onto the backup
-- table, and the insert then fails with "An explicit value for the identity
-- column ... can only be specified when a column list is used and
-- IDENTITY_INSERT is ON."
IF OBJECT_ID('tempdb..#AmortIds') IS NOT NULL DROP TABLE #AmortIds;
CREATE TABLE #AmortIds (AmortizationId BIGINT PRIMARY KEY);

INSERT INTO #AmortIds (AmortizationId)
SELECT DISTINCT t.AmortizationId
FROM [Transaction] t WITH (NOLOCK)
JOIN @AffectedApps a ON a.ApplicationId = t.ApplicationId
WHERE t.TransactionTypeId = 14
  AND t.TransactionStatusId = 1003
  AND t.AmortizationId IS NOT NULL;

IF OBJECT_ID('dbo.Amortization_MHD35969') IS NOT NULL
    DROP TABLE Amortization_MHD35969;
SELECT a.*, GETDATE() AS BackupRunAt
INTO Amortization_MHD35969
FROM Amortization a
JOIN #AmortIds i ON i.AmortizationId = a.AmortizationId;

IF OBJECT_ID('dbo.AmortizationHistory_MHD35969') IS NOT NULL
    DROP TABLE AmortizationHistory_MHD35969;
SELECT ah.*, GETDATE() AS BackupRunAt
INTO AmortizationHistory_MHD35969
FROM AmortizationHistory ah
JOIN #AmortIds i ON i.AmortizationId = ah.AmortizationId;

-- ---------------------------------------------------------------------------
-- 3. Process each application
-- ---------------------------------------------------------------------------
WHILE EXISTS (SELECT 1 FROM @AffectedApps WHERE IsProcessed = 0)
BEGIN
    SELECT TOP 1 @CurrentAppId = ApplicationId
    FROM @AffectedApps
    WHERE IsProcessed = 0;

    -- Reset per iteration. Without this an app with no matching write-off
    -- transaction inherits the previous app's AmortizationId.
    SET @AmortizationId = NULL;

    SELECT @AmortizationId = AmortizationId
    FROM [Transaction] WITH (NOLOCK)
    WHERE ApplicationId = @CurrentAppId
      AND TransactionTypeId = 14
      AND TransactionStatusId = 1003;

    -- === TransactionHistory ===
    SET IDENTITY_INSERT TransactionHistory_MHD35969 ON;
    INSERT INTO TransactionHistory_MHD35969 (
        TransactionHistoryId, TransactionId, UpdateSettingId, FieldName, FromValue, ToValue, DateCreated, CreatedByUserId
    )
    SELECT
        th.TransactionHistoryId, th.TransactionId, th.UpdateSettingId, th.FieldName, th.FromValue, th.ToValue, th.DateCreated, th.CreatedByUserId
    FROM TransactionHistory th
    WHERE th.TransactionId IN (
            SELECT TransactionId FROM [Transaction]
            WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23)
          )
      AND NOT EXISTS (
            SELECT 1 FROM TransactionHistory_MHD35969 b
            WHERE b.TransactionHistoryId = th.TransactionHistoryId
          );
    SET IDENTITY_INSERT TransactionHistory_MHD35969 OFF;

    DELETE FROM TransactionHistory
    WHERE TransactionId IN (
        SELECT TransactionId FROM [Transaction]
        WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23)
    );

    -- === Transaction ===
    SET IDENTITY_INSERT Transaction_MHD35969 ON;
    INSERT INTO Transaction_MHD35969 (
        TransactionId,TransactionNo,ApplicationId,TranAmount,TranDate,Principal,EFee,Interest,Charge,
        DateSubmitted,DateProcessed,OrderId,TransactionStatusId,TransactionTypeId,Notes,DateCreated,CreatedByUserId,
        IsDishonourCharge,AmortizationId,IsDailyInterestCalc,IsAdhocPayment,forLateFeeProcess,IsLateFeeAdded,CreditCardPaymentId,
        ExtraFunds,Excess,Recoveries,WithinDiscountPeriod,IsRescheduled,IsReversed,NoDDAutoRetry,RetryCounter,
        RetriedTransactionId,TrustName,MercantileAgentId,AccountKeepingFee,AnnualFee,CardPaymentTracker,DisableStageMovement,
        DisableDishonourFee,InterestFree,VirtualPrincipal,DisableSystemUpdate,GstFee,ExcludeInArrears,MerchantFeeAmount,AdminFee,
        DisableArrearsCapture,BrokerFee,WrittenOffRemainingPrincipalBalance,WrittenOffDealerBrokerRemainingBalance,Source,
        WrittenOfRemainingPrincipalBalance,sf_tranid,sf_createdbyid,TriggeredByTransactionId,ParentId,Version
    )
    SELECT
        t.TransactionId,t.TransactionNo,t.ApplicationId,t.TranAmount,t.TranDate,t.Principal,t.EFee,t.Interest,t.Charge,
        t.DateSubmitted,t.DateProcessed,t.OrderId,t.TransactionStatusId,t.TransactionTypeId,t.Notes,t.DateCreated,t.CreatedByUserId,
        t.IsDishonourCharge,t.AmortizationId,t.IsDailyInterestCalc,t.IsAdhocPayment,t.forLateFeeProcess,t.IsLateFeeAdded,t.CreditCardPaymentId,
        t.ExtraFunds,t.Excess,t.Recoveries,t.WithinDiscountPeriod,t.IsRescheduled,t.IsReversed,t.NoDDAutoRetry,t.RetryCounter,
        t.RetriedTransactionId,t.TrustName,t.MercantileAgentId,t.AccountKeepingFee,t.AnnualFee,t.CardPaymentTracker,t.DisableStageMovement,
        t.DisableDishonourFee,t.InterestFree,t.VirtualPrincipal,t.DisableSystemUpdate,t.GstFee,t.ExcludeInArrears,t.MerchantFeeAmount,t.AdminFee,
        t.DisableArrearsCapture,t.BrokerFee,t.WrittenOffRemainingPrincipalBalance,t.WrittenOffDealerBrokerRemainingBalance,t.Source,
        t.WrittenOfRemainingPrincipalBalance,t.sf_tranid,t.sf_createdbyid,t.TriggeredByTransactionId,t.ParentId,t.Version
    FROM [Transaction] t
    WHERE t.ApplicationId = @CurrentAppId
      AND t.TransactionTypeId IN (14, 23)
      AND NOT EXISTS (
            SELECT 1 FROM Transaction_MHD35969 b WHERE b.TransactionId = t.TransactionId
          );
    SET IDENTITY_INSERT Transaction_MHD35969 OFF;

    DELETE FROM [Transaction]
    WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23);

    -- === Amortization / AmortizationHistory ===
    -- Already backed up in section 2, before the loop.
    IF (@AmortizationId > 0)
    BEGIN
        DELETE FROM AmortizationHistory WHERE AmortizationId = @AmortizationId;
        DELETE FROM Amortization        WHERE AmortizationId = @AmortizationId;
    END

    EXEC dbo.UpdateAmounts @CurrentAppId, 1;

    -- === AdditionalData (type 35) ===
    SET IDENTITY_INSERT AdditionalData_MHD35969 ON;
    INSERT INTO AdditionalData_MHD35969 (
        AdditionalDataId, CustomerId, ApplicationId, AdditionalDataTypeId, Value, DateCreated, CreatedByUserId
    )
    SELECT
        ad.AdditionalDataId, ad.CustomerId, ad.ApplicationId, ad.AdditionalDataTypeId, ad.Value, ad.DateCreated, ad.CreatedByUserId
    FROM AdditionalData ad
    WHERE ad.ApplicationId = @CurrentAppId
      AND ad.AdditionalDataTypeId = 35
      AND NOT EXISTS (
            SELECT 1 FROM AdditionalData_MHD35969 b WHERE b.AdditionalDataId = ad.AdditionalDataId
          );
    SET IDENTITY_INSERT AdditionalData_MHD35969 OFF;

    DELETE FROM AdditionalData
    WHERE ApplicationId = @CurrentAppId AND AdditionalDataTypeId = 35;

    -- === ApplicationWorkFlow (364, 365, 1317) ===
    SET IDENTITY_INSERT ApplicationWorkFlow_MHD35969 ON;
    INSERT INTO ApplicationWorkFlow_MHD35969 (
        ApplicationWorkFlowId, ApplicationId, WorkFlowId, DateProcessed, RunCount
    )
    SELECT
        awf.ApplicationWorkFlowId, awf.ApplicationId, awf.WorkFlowId, awf.DateProcessed, awf.RunCount
    FROM ApplicationWorkFlow awf
    WHERE awf.ApplicationId = @CurrentAppId
      AND awf.WorkflowId IN (364, 365, 1317)
      AND NOT EXISTS (
            SELECT 1 FROM ApplicationWorkFlow_MHD35969 b
            WHERE b.ApplicationWorkFlowId = awf.ApplicationWorkFlowId
          );
    SET IDENTITY_INSERT ApplicationWorkFlow_MHD35969 OFF;

    DELETE FROM ApplicationWorkFlow
    WHERE ApplicationId = @CurrentAppId AND WorkflowId IN (364, 365, 1317);

    -- === ApplicationWorkFlow2 (write-off workflows) ===
    SET IDENTITY_INSERT ApplicationWorkFlow2_MHD35969 ON;
    INSERT INTO ApplicationWorkFlow2_MHD35969 (
        ApplicationWorkFlowId, ApplicationId, WorkFlowId, DateProcessed, RunCount
    )
    SELECT
        awf2.ApplicationWorkFlowId, awf2.ApplicationId, awf2.WorkFlowId, awf2.DateProcessed, awf2.RunCount
    FROM ApplicationWorkFlow2 awf2
    WHERE awf2.ApplicationId = @CurrentAppId
      AND awf2.WorkflowId IN (SELECT WorkflowId FROM Workflow2 WHERE [Name] LIKE '%write%')
      AND NOT EXISTS (
            SELECT 1 FROM ApplicationWorkFlow2_MHD35969 b
            WHERE b.ApplicationWorkFlowId = awf2.ApplicationWorkFlowId
          );
    SET IDENTITY_INSERT ApplicationWorkFlow2_MHD35969 OFF;

    DELETE FROM ApplicationWorkFlow2
    WHERE ApplicationId = @CurrentAppId
      AND WorkflowId IN (SELECT WorkflowId FROM Workflow2 WHERE [Name] LIKE '%write%');

    UPDATE @AffectedApps
    SET IsProcessed = 1
    WHERE ApplicationId = @CurrentAppId;
END

-- ---------------------------------------------------------------------------
-- 4. Verify: rows backed up, and nothing left behind on the target apps
-- ---------------------------------------------------------------------------
SELECT 'Transaction'          AS TableName,
       (SELECT COUNT(*) FROM Transaction_MHD35969 b
         WHERE b.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps))         AS BackedUpRows,
       (SELECT COUNT(*) FROM [Transaction] t
         WHERE t.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)
           AND t.TransactionTypeId IN (14, 23))                                      AS ShouldNowBeZero
UNION ALL
SELECT 'TransactionHistory',
       (SELECT COUNT(*) FROM TransactionHistory_MHD35969),
       (SELECT COUNT(*) FROM TransactionHistory th
         JOIN Transaction_MHD35969 b ON b.TransactionId = th.TransactionId)
UNION ALL
SELECT 'AdditionalData',
       (SELECT COUNT(*) FROM AdditionalData_MHD35969 b
         WHERE b.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)),
       (SELECT COUNT(*) FROM AdditionalData ad
         WHERE ad.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)
           AND ad.AdditionalDataTypeId = 35)
UNION ALL
SELECT 'ApplicationWorkFlow',
       (SELECT COUNT(*) FROM ApplicationWorkFlow_MHD35969 b
         WHERE b.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)),
       (SELECT COUNT(*) FROM ApplicationWorkFlow awf
         WHERE awf.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)
           AND awf.WorkflowId IN (364, 365, 1317))
UNION ALL
SELECT 'ApplicationWorkFlow2',
       (SELECT COUNT(*) FROM ApplicationWorkFlow2_MHD35969 b
         WHERE b.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)),
       (SELECT COUNT(*) FROM ApplicationWorkFlow2 awf2
         WHERE awf2.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)
           AND awf2.WorkflowId IN (SELECT WorkflowId FROM Workflow2 WHERE [Name] LIKE '%write%'))
UNION ALL
SELECT 'Amortization',
       (SELECT COUNT(*) FROM Amortization_MHD35969),
       (SELECT COUNT(*) FROM Amortization a
         JOIN Amortization_MHD35969 b ON b.AmortizationId = a.AmortizationId);

COMMIT;
-- ROLLBACK;
