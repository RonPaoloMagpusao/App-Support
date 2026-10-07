# SQL datafix catalogue (legacy raw scripts)

The master catalogue of roughly 100 raw SQL datafix scripts. Archive material: read the warnings in datafix-routing.md before using any item.

Last reviewed: 7 October 2026
Sources: Confluence AS page 519602304, mirrored 23 September 2026; items 72 and 73 of the second sequence added 7 October 2026 from the 28 Sep 2026 version. Edits here do not flow back to Confluence.

- Space: AS · Page id: 519602304 · Last updated: 28 Sep 2026 · Author: Michael Dela Torre
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/519602304/SQL+Data+Fix+scripts

The maintained union set of App Support raw data fixes, roughly 100 numbered items keyed to
historical MHD tickets. Reproduced below in full, with credentials, customer emails, customer
phone numbers and customer addresses redacted.

Caveat on numbering: the source page renders as two numbered sequences (1 to 28, then a second
sequence restarting at 1 and running to 73). The Datafix catalogue page refers to item numbers
above 72, so item numbers quoted elsewhere do not map cleanly onto the numbering shown here.
Confirm by symptom text, not by number.

## Source page body

### Overview:

Application Support team is available to assist with data fix issues. This document shows the past events of data fix issues and their corresponding solution. This will serve as a valuable reference for any future occurrences. You can try using  Search/Find (Ctrl+F) and type the keyword of the Data Fix and it may be here already. This document will be update from time to time.

### SQL scripts:

1. Use this for testing

```
BEGIN TRAN

SELECT ApplicationId, TransactionId, TransactionStatusId, Notes FROM [Transaction] Where TransactionId = 48236402

UPDATE [Transaction] SET TransactionStatusId = '1003', Notes = NULL Where TransactionId = 48236402

SELECT ApplicationId, TransactionId, TransactionStatusId, Notes FROM [Transaction] Where TransactionId = 48236402

ROLLBACK TRAN
```

```
BEGIN TRAN

Do insert/update here

ROLLBACK TRAN
--COMMIT TRAN
```
2. Remove file from this Account

```
USE Horizon2

--backup
SELECT * INTO FileUpload_MHD20870a FROM FileUpload WHERE FileUploadId IN (20419179, 20419178) and ApplicationId = 10002351763
DELETE FROM FileUpload WHERE FileUploadId IN (20419179, 20419178) and ApplicationId = 10002351763

SELECT * INTO FileUpload_MHD20870b FROM FileUpload WHERE FileUploadId IN (20444637) and ApplicationId = 10002354087
DELETE FROM FileUpload WHERE FileUploadId IN (20444637) and ApplicationId = 10002354087

SELECT * INTO FileUpload_MHD20870c FROM FileUpload WHERE FileUploadId IN (20436154) and ApplicationId = 10002353318
DELETE FROM FileUpload WHERE FileUploadId IN (20436154) and ApplicationId = 10002353318

--test
SELECT ApplicationId, DateCreated, FileUploadId, Description FROM FileUpload 
WHERE ApplicationId in (10002351763, 10002354087, 10002353318) 
and FileUploadId in (20436154, 20444637, 20419178, 20419179)
```
3. Remove bank account from this Application

```
use Horizon2
--Backup
select * into ApplicationBank_MHD12380 From [ApplicationBank] where ApplicationBankId = 1195813 and CustomerId = 737255
--Delete
delete from [ApplicationBank] where ApplicationBankId = 1195813 and CustomerId = 737255
--Testing
select * From [ApplicationBank] where CustomerId = 737255
```
4. No allocation for.. date and application

```
EXEC UpdateAllocation 71275461
```
5. Update offer to

```
use Horizon2
SELECT * INTO Application_MHD12195 FROM [Application] WHERE ApplicationId =  10002096232
UPDATE [Application] SET OfferedAmount = '10248.57' WHERE ApplicationId =  10002096232
```
6. Update phone / contact number from this Application

```
USE Horizon2
SELECT * INTO CustomerContactNo_MHD16174 FROM CustomerContactNo WHERE CustomerId = 543632
UPDATE CustomerContactNo SET Number = '04XXXXXXXX' WHERE CustomerContactNoId = 1014453 and CustomerId = 543632
--For Testing
SELECT * FROM CustomerContactNo WHERE  CustomerId = 543632
```
7. Remove decision result for bank statements to be submitted

```
use Horizon2
SELECT * INTO Application_MHD12402 FROM [Application] WHERE ApplicationId =  10002099743
UPDATE [Application] SET DeclineReasonId = NULL and EngineResultTypeId = '10001' WHERE ApplicationId =  10002099743
```
8. Remove duplicate LOC headers from Account / Application

```
DECLARE @appId BIGINT = <ApplicationId>;
DROP TABLE IF EXISTS #DuplicateHeaders
SELECT
    AH.ApplicationId
    , AH.AmortizationHeaderId
    , AH.AmortizationStatusId
    , AH.AmortizationHeaderName
    , AH.StartDate
    , AH.DateCreated
    , AH.OpenningBalance
    , AH.CurrentBalance
    , ROW_NUMBER() OVER (PARTITION BY CONCAT(AH.AmortizationHeaderName,AH.StartDate) ORDER BY AH.DateCreated DESC) VersionNumber
    , CASE WHEN ROW_NUMBER() OVER (PARTITION BY CONCAT(AH.AmortizationHeaderName,AH.StartDate) ORDER BY AH.DateCreated DESC) > 1 THEN 'Duplicate' ELSE '' END AS 'IsDuplicate'           
INTO #DuplicateHeaders
FROM AmortizationHeader AH
    INNER JOIN [Application] APP ON APP.ApplicationId = AH.ApplicationId
WHERE 
    AH.ApplicationId = @appId 
    AND AH.AmortizationStatusId IN (31002,31006,31005)
ORDER BY AH.AmortizationHeaderName ASC

UPDATE AH
    SET AH.AmortizationStatusId = 31003
FROM AmortizationHeader AH
INNER JOIN #DuplicateHeaders DUP ON DUP.AmortizationHeaderId = AH.AmortizationHeaderId
    AND DUP.IsDuplicate = 'Duplicate'
    AND AH.ApplicationId = @AppId

DECLARE @CalculateWithrawalAllocationAll TABLE ([Name] varchar(300)) 
INSERT INTO @CalculateWithrawalAllocationAll  
EXEC CalculateWithrawalAllocationAll @AppId

DECLARE @CalculateWithrawalAllocation_AnnualFee_All TABLE ([Name] varchar(300)) 
INSERT INTO @CalculateWithrawalAllocation_AnnualFee_All  

EXEC CalculateWithrawalAllocation_AnnualFee_All @AppId
EXEC UpdateMinimumPaymentAmount @AppId, 1, 'Fix duplicate headers'
```
9. Update CreditLimit from an application.

```
use Horizon2
SELECT * INTO CreditLimit_MHD12525 FROM CreditLimit WHERE ApplicationId =  10001486129
UPDATE CreditLimit SET AvailableLimitAmount = '19500' WHERE ApplicationId =  10001486129 and CustomerId = 521673
```
10. Update Commission for an PartnershipApplication 

```
use Horizon2
SELECT * INTO PartnershipApplication_MHD12195 FROM PartnershipApplication WHERE ApplicationId =  10002100587
UPDATE PartnershipApplication SET Commission = '1780' WHERE ApplicationId =  10002100587
```
11. Update Duration for an application

```
use Horizon2
SELECT * INTO Application_MHD12195 FROM [Application] WHERE ApplicationId =  10002092141
UPDATE [Application] SET Duration = '60 months' WHERE ApplicationId =  10002092141
```
12. Update Autopay vehicle detail

```
use Horizon2
select * into MHD_12776 From AutopayVehicleDetail where AutopayVehicleDetailID =  54795
update AutopayVehicleDetail set RegisteredPlate = '1VM1OZ' where AutopayVehicleDetailID =  54795

-- Get AutopayVehicleDetailId
DECLARE @AutopayVehicleDetailId bigint

select @AutopayVehicleDetailId=AutopayVehicleDetailId from AutopayApplication where ApplicationId = 10001585377
select AutopayVehicleDetailId,EngineNumber,YearOfManufacture,AutopayVehicleDetailId,RegisteredPlate,NVIC,VIN,VehicleClass,MakeCode,MakeDescription,ModelCode,ModelDescription,BodyType,Transmission, *
 from AutopayVehicleDetail where AutopayVehicleDetailID = @AutopayVehicleDetailId
```
13. Reverse DDAC and Reverse Payment (just edit note for the second part or ask Michael)

```
USE Horizon2

DECLARE @Apps TABLE (ApplicationId BIGINT, TransactionId BIGINT)

INSERT INTO @Apps
VALUES
(10001261184,71125450), 
(10001261184,71125451)

DECLARE @MyCursor CURSOR	
DECLARE @ProdTypeId AS INT
DECLARE @AppId BIGINT 
DECLARE @TranId BIGINT
DECLARE @ProductType VARCHAR(20)

BEGIN

	SET @MyCursor = CURSOR FOR

	SELECT ApplicationId, TransactionId
	FROM @Apps
		
	OPEN @MyCursor
	FETCH NEXT FROM @MyCursor
	INTO @AppId, @TranId

		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT INTO [Transaction](ApplicationId, TranAmount, TranDate, Principal, EFee, Interest, Charge, DateSubmitted, DateProcessed, TransactionStatusId, TransactionTypeId, Notes, DateCreated, CreatedByUserId, ExtraFunds, Excess, Recoveries, AccountKeepingFee, AnnualFee, VirtualPrincipal, GstFee, MerchantFeeAmount, AdminFee, BrokerFee)
			SELECT ApplicationId, 
					TranAmount * -1,  
					CAST(GETDATE() AS DATE), 
					Principal * -1, 
					EFee * -1, 
					Interest * -1, 
					Charge * -1, 
					GETDATE(), 
					GETDATE(), 
					1003, 
					36, 
					'Reversed DDAC TranId: ' + CAST(@TranId AS VARCHAR(50)), 
					GETDATE(), 
					10, 
					ExtraFunds * -1, 
					Excess * -1, 
					Recoveries * -1, 
					AccountKeepingFee * -1, 
					AnnualFee * -1, 
					VirtualPrincipal * -1, 
					GstFee * -1, 
					MerchantFeeAmount * -1, 
					AdminFee * -1, 
					BrokerFee * -1
			FROM [Transaction]
			WHERE ApplicationId = @AppId AND TransactionId = @TranId

			EXEC UpdateAmounts @AppId

			SELECT @ProductType = PT.Description FROM [Application] App 
			INNER JOIN ProductType PT ON App.ProductTypeId = PT.ProductTypeId
			WHERE ApplicationId = @AppId

			IF (@ProductType = 'MACC' OR @ProductType = 'PL' OR @ProductType = 'APY') --ELSE IF MACCPLAPY, Process Actualization and Overpayments
			BEGIN
				INSERT INTO BackgroundTask (ApplicationId, TaskTypeId, StatusId,  DateCreated, CreatedByUserId)
				VALUES (@AppId, 129, 40001, GETDATE(), 1)
			END
					
		FETCH NEXT FROM @MyCursor
		INTO @AppId, @TranId
  
		END

	CLOSE @MyCursor
	DEALLOCATE @MyCursor

END

-- Fix for 10001255014, reverse payment
INSERT INTO [Transaction](ApplicationId, TranAmount, TranDate, Principal, EFee, Interest, Charge, DateSubmitted, DateProcessed, TransactionStatusId, TransactionTypeId, Notes, DateCreated, CreatedByUserId, ExtraFunds, Excess, Recoveries, AccountKeepingFee, AnnualFee, VirtualPrincipal, GstFee, MerchantFeeAmount, AdminFee, BrokerFee)
SELECT ApplicationId, 
		TranAmount * -1,  
		CAST(GETDATE() AS DATE), 
		Principal * -1, 
		EFee * -1, 
		Interest * -1, 
		Charge * -1, 
		GETDATE(), 
		GETDATE(), 
		1003, 
		36, 
		'Reverse Payment TranId: 71653986',
		GETDATE(), 
		10, 
		ExtraFunds * -1, 
		Excess * -1, 
		Recoveries * -1, 
		AccountKeepingFee * -1, 
		AnnualFee * -1, 
		VirtualPrincipal * -1, 
		GstFee * -1, 
		MerchantFeeAmount * -1, 
		AdminFee * -1, 
		BrokerFee * -1
FROM [Transaction]
WHERE ApplicationId = 10001255014 AND TransactionId = 71653986

EXEC UpdateAmounts 10001255014
```
14. Reverse Write Off

```
USE Horizon2
declare @AffectedApps table(ApplicationId bigint, IsProcessed bit)
insert into @AffectedApps
	select [Value], 0 from dbo.fn_SplitString('10001390518', ',')
select * from @AffectedApps
declare @CurrentAppId bigint
WHILE EXISTS(SELECT 1 FROM @AffectedApps WHERE IsProcessed=0)
BEGIN
	select top 1 @CurrentAppId=ApplicationId FROM @AffectedApps WHERE IsProcessed=0
	select * into TransactionHistory_MHD20061 from TransactionHistory where TransactionId IN(select TransactionId from [Transaction] where ApplicationId=@CurrentAppId and TransactionTypeId IN(14,23))
	delete from TransactionHistory where TransactionId IN(select TransactionId from [Transaction] where ApplicationId=@CurrentAppId and TransactionTypeId IN(14,23))
	select * into Transaction_MHD20061 from [Transaction] where ApplicationId=@CurrentAppId and TransactionTypeId IN(14,23)
	delete from [Transaction] where ApplicationId=@CurrentAppId and TransactionTypeId IN(14,23)
    EXEC dbo.UpdateAmounts @ApplicationId, 1
	select * into AdditionalData_MHD20061 from AdditionalData where ApplicationId=@CurrentAppId and AdditionalDataTypeId=35
	delete from AdditionalData where ApplicationId=@CurrentAppId and AdditionalDataTypeId=35
	select * into ApplicationWorkFlow_MHD20061 from ApplicationWorkFlow where ApplicationId=@CurrentAppId AND WorkflowId IN(364,365,1317)
	delete from ApplicationWorkFlow where ApplicationId=@CurrentAppId AND WorkflowId IN(364,365,1317)
	select * into ApplicationWorkFlow2_MHD20061 from ApplicationWorkFlow2 where ApplicationId=@CurrentAppId AND WorkflowId IN(select WorkflowId from Workflow2 where [Name] like '%write%')
	delete from ApplicationWorkFlow2 where ApplicationId=@CurrentAppId AND WorkflowId IN(select WorkflowId from Workflow2 where [Name] like '%write%')
	UPDATE @AffectedApps SET IsProcessed=1 WHERE ApplicationId=@CurrentAppId
END
```
15. Reverse Writeoff V2

```
USE Horizon2;

BEGIN TRANSACTION;  -- Start transaction so COMMIT/ROLLBACK works

-- Step 0: Drop backup tables if they exist
IF OBJECT_ID('TransactionHistory_MHD26144') IS NOT NULL DROP TABLE TransactionHistory_MHD26144;
IF OBJECT_ID('Transaction_MHD26144') IS NOT NULL DROP TABLE Transaction_MHD26144;
IF OBJECT_ID('AdditionalData_MHD26144') IS NOT NULL DROP TABLE AdditionalData_MHD26144;
IF OBJECT_ID('ApplicationWorkFlow_MHD26144') IS NOT NULL DROP TABLE ApplicationWorkFlow_MHD26144;
IF OBJECT_ID('ApplicationWorkFlow2_MHD26144') IS NOT NULL DROP TABLE ApplicationWorkFlow2_MHD26144;

-- Step 1: Declare variables
DECLARE @AffectedApps TABLE (ApplicationId BIGINT, IsProcessed BIT);
DECLARE @CurrentAppId BIGINT;
DECLARE @AmortizationId BIGINT;

-- Step 2: Populate ApplicationIds
INSERT INTO @AffectedApps (ApplicationId, IsProcessed)
SELECT CAST([Value] AS BIGINT), 0
FROM dbo.fn_SplitString(
    '10001205567,10001647737,10002037806,10002065922,10002149143,10002236812,10002357722',
    ','
);

-- Step 3: Create empty backup tables
SELECT * INTO TransactionHistory_MHD26144 FROM TransactionHistory WHERE 1 = 0;
SELECT * INTO Transaction_MHD26144 FROM [Transaction] WHERE 1 = 0;
SELECT * INTO AdditionalData_MHD26144 FROM AdditionalData WHERE 1 = 0;
SELECT * INTO ApplicationWorkFlow_MHD26144 FROM ApplicationWorkFlow WHERE 1 = 0;
SELECT * INTO ApplicationWorkFlow2_MHD26144 FROM ApplicationWorkFlow2 WHERE 1 = 0;

-- Step 4: Process each application
WHILE EXISTS (SELECT 1 FROM @AffectedApps WHERE IsProcessed = 0)
BEGIN
    SELECT TOP 1 @CurrentAppId = ApplicationId
    FROM @AffectedApps
    WHERE IsProcessed = 0;

    -- Get AmortizationId
    SELECT @AmortizationId = AmortizationId
    FROM [Transaction] WITH (NOLOCK)
    WHERE ApplicationId = @CurrentAppId 
      AND TransactionTypeId = 14 
      AND TransactionStatusId = 1003;

    -- === TransactionHistory Backup ===
    SET IDENTITY_INSERT TransactionHistory_MHD26144 ON;
    INSERT INTO TransactionHistory_MHD26144 (
        TransactionHistoryId,TransactionId,UpdateSettingId,FieldName,FromValue,ToValue,DateCreated,CreatedByUserId
    )
    SELECT 
        TransactionHistoryId,TransactionId,UpdateSettingId,FieldName,FromValue,ToValue,DateCreated,CreatedByUserId
    FROM TransactionHistory
    WHERE TransactionId IN (
        SELECT TransactionId 
        FROM [Transaction]
        WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23)
    );
    SET IDENTITY_INSERT TransactionHistory_MHD26144 OFF;

    DELETE FROM TransactionHistory
    WHERE TransactionId IN (
        SELECT TransactionId 
        FROM [Transaction]
        WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23)
    );

    -- === Transaction Backup ===
    SET IDENTITY_INSERT Transaction_MHD26144 ON;
    INSERT INTO Transaction_MHD26144 (
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
        TransactionId,TransactionNo,ApplicationId,TranAmount,TranDate,Principal,EFee,Interest,Charge,
        DateSubmitted,DateProcessed,OrderId,TransactionStatusId,TransactionTypeId,Notes,DateCreated,CreatedByUserId,
        IsDishonourCharge,AmortizationId,IsDailyInterestCalc,IsAdhocPayment,forLateFeeProcess,IsLateFeeAdded,CreditCardPaymentId,
        ExtraFunds,Excess,Recoveries,WithinDiscountPeriod,IsRescheduled,IsReversed,NoDDAutoRetry,RetryCounter,
        RetriedTransactionId,TrustName,MercantileAgentId,AccountKeepingFee,AnnualFee,CardPaymentTracker,DisableStageMovement,
        DisableDishonourFee,InterestFree,VirtualPrincipal,DisableSystemUpdate,GstFee,ExcludeInArrears,MerchantFeeAmount,AdminFee,
        DisableArrearsCapture,BrokerFee,WrittenOffRemainingPrincipalBalance,WrittenOffDealerBrokerRemainingBalance,Source,
        WrittenOfRemainingPrincipalBalance,sf_tranid,sf_createdbyid,TriggeredByTransactionId,ParentId,Version
    FROM [Transaction]
    WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23);
    SET IDENTITY_INSERT Transaction_MHD26144 OFF;

    DELETE FROM [Transaction]
    WHERE ApplicationId = @CurrentAppId AND TransactionTypeId IN (14, 23);

    -- Delete Amortization if needed
    IF (@AmortizationId > 0)
    BEGIN
        DELETE FROM AmortizationHistory WHERE AmortizationId = @AmortizationId;
        DELETE FROM Amortization WHERE AmortizationId = @AmortizationId;
    END

    EXEC dbo.UpdateAmounts @CurrentAppId, 1;

    -- === AdditionalData Backup ===
    SET IDENTITY_INSERT AdditionalData_MHD26144 ON;
    INSERT INTO AdditionalData_MHD26144 (
        AdditionalDataId,CustomerId,ApplicationId,AdditionalDataTypeId,Value,DateCreated,CreatedByUserId
    )
    SELECT 
        AdditionalDataId,CustomerId,ApplicationId,AdditionalDataTypeId,Value,DateCreated,CreatedByUserId
    FROM AdditionalData
    WHERE ApplicationId = @CurrentAppId AND AdditionalDataTypeId = 35;
    SET IDENTITY_INSERT AdditionalData_MHD26144 OFF;

    DELETE FROM AdditionalData
    WHERE ApplicationId = @CurrentAppId AND AdditionalDataTypeId = 35;

    -- === ApplicationWorkFlow Backup ===
    SET IDENTITY_INSERT ApplicationWorkFlow_MHD26144 ON;
    INSERT INTO ApplicationWorkFlow_MHD26144 (
        ApplicationWorkFlowId,ApplicationId,WorkFlowId,DateProcessed,RunCount
    )
    SELECT 
        ApplicationWorkFlowId,ApplicationId,WorkFlowId,DateProcessed,RunCount
    FROM ApplicationWorkFlow
    WHERE ApplicationId = @CurrentAppId AND WorkflowId IN (364, 365, 1317);
    SET IDENTITY_INSERT ApplicationWorkFlow_MHD26144 OFF;

    DELETE FROM ApplicationWorkFlow
    WHERE ApplicationId = @CurrentAppId AND WorkflowId IN (364, 365, 1317);

    -- === ApplicationWorkFlow2 Backup ===
    SET IDENTITY_INSERT ApplicationWorkFlow2_MHD26144 ON;
    INSERT INTO ApplicationWorkFlow2_MHD26144 (
        ApplicationWorkFlowId,ApplicationId,WorkFlowId,DateProcessed,RunCount
    )
    SELECT 
        ApplicationWorkFlowId,ApplicationId,WorkFlowId,DateProcessed,RunCount
    FROM ApplicationWorkFlow2
    WHERE ApplicationId = @CurrentAppId
      AND WorkflowId IN (SELECT WorkflowId FROM Workflow2 WHERE [Name] LIKE '%write%');
    SET IDENTITY_INSERT ApplicationWorkFlow2_MHD26144 OFF;

    DELETE FROM ApplicationWorkFlow2
    WHERE ApplicationId = @CurrentAppId
      AND WorkflowId IN (SELECT WorkflowId FROM Workflow2 WHERE [Name] LIKE '%write%');

    -- Mark processed
    UPDATE @AffectedApps
    SET IsProcessed = 1
    WHERE ApplicationId = @CurrentAppId;
END

-- ===== Toggle here =====
COMMIT;   -- Uncomment this to save changes
--ROLLBACK;   -- Leave this for testing (undo changes)
```
16. Update Requested Amount

```
use Horizon2
SELECT * INTO Application_MHD13244 FROM [Application] WHERE ApplicationId = 10002130880 and CustomerId = 1655566
UPDATE [Application] SET RequestedAmount = '70000.00' WHERE ApplicationId = 10002130880 and CustomerId = 1655566
```
17. Update Transaction Status 

```
use Horizon2

--1005	Cancelled
SELECT ApplicationId, TransactionId, TransactionStatusId, Notes INSERT INTO Transaction_MHD13532 FROM [Transaction] Where TransactionId IN (71280063,71922017,72215170)

UPDATE [Transaction] SET TransactionStatusId = '1005', Notes = 'Cancelling negative amounts in merchant credit' WHERE TransactionId IN (71280063,71922017,72215170)

Exec UpdateAmounts 10001312761
GO
Exec UpdateAmounts 10001453316
GO
Exec UpdateAmounts 10001322282
GO
```
18. Remove Decision Result (Decline) For Bank statements to be submitted

```
use Horizon2

select * into Application_MHD13766 From [Application] where ApplicationId = 10002146905

UPDATE [Application] SET DeclineReasonId = NULL, EngineResultTypeId = 10001 WHERE ApplicationId = 10002146905
```
19. Update Application Address

```
Use Horizon2
SELECT * INTO ApplicationAddress_MHD13657 FROM ApplicationAddress WHERE CustomerId = 1450731 and ApplicationAddressId = 1459542
UPDATE [ApplicationAddress] SET AddressLine2 = '<no>', AddressLine3 = '<street>', City = '<suburb>', PostalCode = '<postcode>', Country = 'Australia'
WHERE CustomerId = 1450731 and ApplicationAddressId = 1459542
```
20. Update Business Address

```
Use Horizon2
SELECT * INTO ApplicationBusiness_MHD13391 FROM ApplicationBusiness WHERE ApplicationBusinessId = 12937
UPDATE [ApplicationBusiness] SET AddressLine2 = '<no>' WHERE ApplicationBusinessId = 12937
```
21. Run Header Allocation script

```
Use Horizon2
GO

DECLARE @ApplicationId BIGINT = 10001415439

EXEC CalculateWithrawalAllocationAll @ApplicationId

EXEC CalculateWithrawalAllocation_AnnualFee_All @ApplicationId

EXEC UpdateMinimumPaymentAmount @ApplicationId, 1, 'Re run allocation'

GO
```
22. Check Shuffle script results

```
use Horizon2
SELECT AmortizationHeaderId, ApplicationId, AmortizationStatusId, PayfrequencyId, NextPayDate, Duration FROM AmortizationHeader Where ApplicationId = 10001378316 AND AmortizationStatusId IN (31002,31006,31007)
```
23. Update Broker Fee (Commission has computation, do not copy)

```
use Horizon2
select * into MHD_14485_AutopayApplication from AutopayApplication where applicationId in (10002178488,10002135772)
update AutopayApplication set BrokerFee = 250, EstablishmentFee = 350, Commission = 250 where applicationID = 10002178488 and AutopayApplicationID = 62852
update AutopayApplication set BrokerFee = 440, EstablishmentFee = 440, Commission = 1240 where applicationID = 10002135772 and AutopayApplicationID = 60269
```
24. Unable to change default payment method

```
use Horizon2
SELECT * INTO AdditionalData_MHD22302 FROM AdditionalData Where AdditionalDataTypeId = 32 and ApplicationId = 10001210502
UPDATE AdditionalData SET Value = 4 WHERE AdditionalDataTypeId = 32 and ApplicationId = 10001210502
--Test
SELECT * FROM AdditionalData WHERE AdditionalDataTypeId = 32 and ApplicationId = 10001210502
```
25. get List of payment methods

```
use Horizon2
Select * from TransactionType
```
26. Arrears Level removal request (M0, M1, M2, M3)

```
USE Horizon2
SELECT * INTO MHD_19652 FROM [Application] WHERE ApplicationId = 10001512905
UPDATE [Application] SET ArrearsLevelId = NULL, ArrearsStandingId = NULL WHERE ApplicationId = 10001512905
```
27. Update Customer Account (Status - IsActive)

```
USE Horizon2
SELECT * INTO CustomerAccount_MHD18513 FROM CustomerAccount WHERE CustomerId = 1630821
UPDATE CustomerAccount SET IsActive = 1 WHERE CustomerId = 1630821 and CustomerAccountId = 1513229

-- For Testing
SELECT *  FROM CustomerAccount WHERE CustomerId = 1630821
```
28. Unable to login due to duplicate account
    1. Check if Customer has a duplicate account
    2. If has a duplicate account, and the duplicate has Credit Score only (From Mar 2024 backwards), update this duplicate's username (ex. testing@gmail.com\_duplicate) so Mobile can't get this as the validated creds. (You can check credit score on Horizon)
    3. 

```
Use Horizon2

SELECT TOP 100
c.isActive, 
c.CustomerId,
ce.EmailAddress,
ce.BrandId,
ca.Username username,
ca.BrandId as accountBrand,
ce.isActive as emailIsActive,
ccn.Number,
ccn.isActive as ContactStatus, 
c.isTest,
ccn.* FROM Customer c 
LEFT JOIN CustomerEmail ce ON c.CustomerId = ce.CustomerId
LEFT JOIN CustomerContactNo ccn ON c.CustomerId = ccn.CustomerId
LEFT JOIN CustomerAccount ca ON ca.CustomerId = c.CustomerId
WHERE 
username LIKE '%<insert_email or username>%'
ORDER BY c.DateCreated DESC
```

If anyone asks why we are allowed to update the Credit Score, it's because these are old accounts and we have a new Credit Score now

1. Update Username with Duplicate Account

```
use Horizon2
SELECT * INTO CustomerAccount_MHD14526 FROM CustomerAccount WHERE CustomerId = 1321329
UPDATE CustomerAccount SET Username = 'customer@example.com_duplicate' WHERE CustomerAccountId = 1202867 and CustomerId = 1321329
```
2. Check / Investigate Customer Account using ApplicationId

```
USE Horizon2
-- Check LID / Customer Account
DECLARE @CurrentCustomerId bigint, @TestApplicationId bigint, @CurrentBrandId int, @CurrentEmail varchar(255)
-- Insert ApplicationId @ Line 5
SELECT top 1 @TestApplicationId=ApplicationId FROM [Application] WHERE ApplicationId = --insert ApplicationId
SELECT top 1 @CurrentBrandId = BrandId FROM [Application] WHERE ApplicationId = @TestApplicationId
SELECT a.CustomerId, a.ApplicationId, a.BrandId, b.Code, b.Description, a.StatusId, d.Description FROM [Application] a 
JOIN [Brand] b ON a.BrandId=b.BrandId
JOIN [Status] d ON a.StatusId=d.StatusId WHERE ApplicationId = @TestApplicationId
SELECT top 1 @CurrentCustomerId=CustomerId FROM [Application] WHERE ApplicationId = @TestApplicationId
SELECT top 1 @CurrentEmail=Username FROM [CustomerAccount] WHERE CustomerId = @CurrentCustomerId
SELECT CustomerAccountId, BrandId, CustomerId, Username, IsActive, DateCreated, CreatedByUserId, LastLoginDate, LastLoginIp, LastLoginAttemptDate, IsMobileVerified, IsPINChanged, * 
FROM CustomerAccount WHERE CustomerId = @CurrentCustomerId
SELECT IsActive AS IsContactActive, CustomerContactNoId, CustomerId, BrandId AS ContactBrandId, Number, DateCreated AS ContactDateCreated
FROM CustomerContactNo WHERE CustomerId = @CurrentCustomerId
SELECT IsActive AS IsEmailActive, CustomerEmailId, CustomerId, BrandId AS EmailBrandId, EmailAddress, DateCreated AS EmailDateCreated 
FROM CustomerEmail WHERE CustomerId = @CurrentCustomerId
SELECT top 100 
c.isActive, 
c.CustomerId,
ce.EmailAddress,
ce.BrandId,
ca.Username username,
ca.BrandId as accountBrand,
ce.isActive as emailIsActive,
ccn.Number,
ccn.isActive as ContactStatus, 
c.isTest,
ccn.* FROM Customer c 
LEFT JOIN CustomerEmail ce ON c.CustomerId = ce.CustomerId
LEFT JOIN CustomerContactNo ccn ON c.CustomerId = ccn.CustomerId
LEFT JOIN CustomerAccount ca ON ca.CustomerId = c.CustomerId
WHERE username LIKE '%' + @CurrentEmail + '%';
```
3.  Remove/Move Note from an application. (In this scenario, we are moving the note to a wagtest account instead of deleting it)

```
Use Horizon2

Select * INTO Note_MHD15473 FROM Note WHERE ApplicationId = 10002149318 and NoteId IN (23451388 , 23451401)

Update Note SET ApplicationId = '10001810571' WHERE ApplicationId = 10002149318 and NoteId IN (23451388 , 23451401)
```
4. Lookup ID type 

```
SELECT * FROM LookupType WHERE LookupTypeId = 14
SELECT * FROM Lookup WHERE LookupTypeId = 14
```
5.  Remove/Move email from an application. (In this scenario, we are moving the email to a wagtest account instead of deleting it)

```
Use Horizon2

Select * INTO InboundEmail_MHD15408 FROM InboundEmail WHERE ApplicationId = 10000728543 and InboundEmailId IN (1077924 , 1078995)

Update InboundEmail SET ApplicationId = '10001557793' WHERE ApplicationId = 10000728543 and InboundEmailId IN (1077924 , 1078995)
```
6. Contract Variation to reset DPD for Write off account  
Get the results from this script, confirm with Jess. If good, change ‘ROLLBACK’ → to ‘COMMIT’

```
USE Horizon2
GO
BEGIN TRANSACTION
DROP TABLE IF EXISTS #AffectedApplicationsForSOC1Migration
CREATE TABLE #AffectedApplicationsForSOC1Migration (ApplicationId BIGINT, IsProcessed BIT DEFAULT 0)
INSERT INTO #AffectedApplicationsForSOC1Migration (ApplicationId)
SELECT ApplicationId FROM Application WITH (NOLOCK) WHERE ApplicationId IN (
10001560041
)
DECLARE @ActiveHeaderStatusId INT = 31002;
DECLARE @BatchUnprocessedAppsCount INT
-- BEFORE DATA FIX
SELECT AmortizationHeaderId, ApplicationId, VariationType, VariationDate, DateCreated, IsDpdHeader, Note, AmortizationStatusId, IsOriginal FROM AmortizationHeader 
WHERE ApplicationId IN (SELECT ApplicationId FROM #AffectedApplicationsForSOC1Migration)
AND AmortizationStatusId = @ActiveHeaderStatusId
ORDER BY ApplicationId
SELECT ApplicationId, ContractVariationDate FROM Application WHERE ApplicationId IN (SELECT ApplicationId FROM #AffectedApplicationsForSOC1Migration)
ORDER BY ApplicationId
-- BATCH UPDATES
DROP TABLE IF EXISTS #NextBatchOfAppsToUpdate;
CREATE TABLE #NextBatchOfAppsToUpdate(ApplicationId BIGINT, IsProcessed BIT DEFAULT 0) 
INSERT INTO #NextBatchOfAppsToUpdate (ApplicationId)
SELECT TOP 5 ApplicationId From #AffectedApplicationsForSOC1Migration Where IsProcessed = 0
SET @BatchUnprocessedAppsCount = (SELECT COUNT(ApplicationId) FROM #NextBatchOfAppsToUpdate)
WHILE (@BatchUnprocessedAppsCount > 0)
	BEGIN 
		UPDATE APP
		SET APP.ContractVariationDate = AH.DateCreated
		FROM Application APP
		INNER JOIN AmortizationHeader AH ON APP.ApplicationId = AH.ApplicationId
		WHERE APP.ApplicationId IN (SELECT ApplicationId FROM #NextBatchOfAppsToUpdate)
		AND AmortizationStatusId = @ActiveHeaderStatusId
		AND (IsDPDHeader = 0 OR IsDPDHeader IS NULL)
		UPDATE AmortizationHeader
		SET VariationType = 'Contract', VariationDate = DateCreated, IsOriginal = 0, IsDPDHeader = 1, Note = CONCAT('Amortization for DPD | ', Note)
		WHERE ApplicationId IN (SELECT ApplicationId FROM #NextBatchOfAppsToUpdate)
		AND AmortizationStatusId = @ActiveHeaderStatusId
		AND (IsDPDHeader = 0 OR IsDPDHeader IS NULL)
		UPDATE #AffectedApplicationsForSOC1Migration 
		SET IsProcessed = 1
		WHERE ApplicationId IN (SELECT ApplicationId FROM #NextBatchOfAppsToUpdate)
		DELETE FROM #NextBatchOfAppsToUpdate
		INSERT INTO #NextBatchOfAppsToUpdate (ApplicationId)
		SELECT TOP 5 ApplicationId From #AffectedApplicationsForSOC1Migration Where IsProcessed = 0
		SET @BatchUnprocessedAppsCount = (SELECT COUNT(ApplicationId) FROM #NextBatchOfAppsToUpdate)
	END
-- AFTER BATCH UPDATES
SELECT AmortizationHeaderId, ApplicationId, VariationType, VariationDate, DateCreated, IsDpdHeader, Note, AmortizationStatusId, IsOriginal FROM AmortizationHeader
WHERE ApplicationId IN (SELECT ApplicationId FROM #AffectedApplicationsForSOC1Migration)
AND AmortizationStatusId = @ActiveHeaderStatusId
ORDER BY ApplicationId
SELECT ApplicationId, ContractVariationDate FROM Application WHERE ApplicationId IN (SELECT ApplicationId FROM #AffectedApplicationsForSOC1Migration)
ORDER BY ApplicationId
ROLLBACK
--COMMIT
```
7. Resend contract (after updating APR and reshuffling)

```
USE Horizon2

DECLARE @ApplicationId BIGINT = 10002066320
DECLARE @UseOrginalAmortization BIT = 1 -- Set to 1 if we use the IsOrginal AmortizationHeader else it will use the current active AmortizationHeader

SELECT * FROM ApplicationContract WHERE ApplicationId = @ApplicationId

---UNCOMMENT THIS TO RESEND
INSERT INTO ApplicationContract 
(ApplicationId, CreatedDate, CreatedByUserId, IsResend, UseOriginalAmortization)
VALUES
(@ApplicationId, GETDATE(), 1, 1, @UseOrginalAmortization)

SELECT * FROM ApplicationContract WHERE ApplicationId = @ApplicationId
```
8. No BrandId = 1 or 2 and account is not active (invalid email/passcode)

```
USE Horizon2
SELECT * INTO CustomerAccount_MHD16167 FROM CustomerAccount WHERE CustomerId = 57501
UPDATE CustomerAccount SET IsActive = 1 WHERE CustomerId = 57501
UPDATE CustomerAccount SET BrandId = 1 WHERE CustomerId = 57501
```
9. Create an account directly into DB (Used for SOC migrated accounts w/o MME accounts; Account details are all NA)

```
USE Horizon2
INSERT INTO CustomerAccount (CustomerId, BrandId, Username, Password, IsActive, DateCreated, CreatedByUserId)
VALUES (232497, 1, 'customer@example.com', '[CREDENTIAL REDACTED - see Confluence page 519602304]', 1, GETDATE(), 1);
```
10. PPSR and Vehicle Update

```
use Horizon2
select * into MHD_16836_AutopayVehicleDetail From AutopayVehicleDetail where AutopayVehicleDetailId = 106945
update AutopayVehicleDetail set VIN = 'KNARH81BWR5292113', YearOfManufacture = 2024, RegisteredPlate = '2AD8AC' where AutopayVehicleDetailId = 106945
-- [EdxRegistration]
INSERT INTO [dbo].[EdxRegistration]
           ([RegistrationTypeId]
           ,[EdxSearchId]
           ,[ApplicationId]
           ,[RegistrationId]
           ,[RegistrationNumber]
           ,[Status]
           ,[IsFinalStatus]
           ,[EsisId]
           ,[RegistrationStartDate]
           ,[RegistrationEndDate]
           ,[RegistrationChangeNumber]
           ,[Request]
           ,[Response]
           ,[IsDischarged]
           ,[DateDischarged]
           ,[StatusRequest]
           ,[StatusResponse]
           ,[DischargeRequest]
           ,[DischargeResponse]
           ,[CreatedByUserId]
           ,[DateCreated]
           ,[ModifiedByUserId]
           ,[DateModified])
     VALUES
           (79001 --<RegistrationTypeId, int,>
           ,NULL --<EdxSearchId, bigint,>
           ,10002136475 --<ApplicationId, bigint,>
           ,'00000000-0000-0000-0000-000000000000' --<RegistrationId, varchar(100),> leave it as is
           ,'202406270025785' --<RegistrationNumber, varchar(100),>
           ,'Confirmed' --<Status, varchar(100),>
           ,1 --IsFinalStatus, bit,>
           ,8205000 --<EsisId, bigint,>
           ,'2024-06-27' --<RegistrationStartDate, datetime,> yyyy/mm/dd
           ,'2031-06-27'--<RegistrationEndDate, datetime,> yyyy/mm/dd
           ,81856983  --<RegistrationChangeNumber, bigint,>
           ,NULL --<Request, varchar(max),>
           ,NULL --<Response, varchar(max),>
           ,0 --<IsDischarged, bit,>
           ,NULL --<DateDischarged, datetime,>
           ,NULL --<StatusRequest, varchar(max),>
           ,NULL --<StatusResponse, varchar(max),>
           ,NULL --<DischargeRequest, varchar(max),>
           ,NULL --<DischargeResponse, varchar(max),>
           ,10 --<CreatedByUserId, int,>
           ,GETDATE() --<DateCreated, datetime,>
           ,NULL --<ModifiedByUserId, int,>
           ,NULL --<DateModified, datetime,>
		   )
GO
```
11. Remove duplicate reversal transaction

```
USE Horizon2
UPDATE [Transaction] SET ApplicationId = 10002146851 
WHERE TransactionId = 106100374 and ApplicationId = 10001515721 --Edit this; the transaction to remove

exec UpdateAmounts 10001515721

SELECT * FROM [Transaction] WHERE TransactionId = 106100374 and ApplicationId = 10001515721 -- should be Empty
SELECT * FROM [Transaction] WHERE TransactionId = 106100374 and ApplicationId = 10002146851
```
12. Change Broker Details - Update Application Creator

```
use Horizon2

select ApplicationId, PartnerUserId INTO Application_MHD16899 FROM [Application] WHERE ApplicationId IN (10002242088,
10002239373)
Update Application SET PartnerUserId = 10248 WHERE ApplicationId IN (10002242088,
10002239373)

SELECT * FROM partneruser WHERE Username = 'customer@example.com'
```
13. Hold Daily Interest from Date to Date

```
USE Horizon2

INSERT INTO AmortizationHoldInterest (Applicationid, IsActive, StartDate, EndDate)
VALUES (10001372301, 1, '2024-07-01', '2025-07-15')
```
14. Remove the DeclineReasonId and clear the DEResult

```
USE [Horizon2]
GO
/****======== Backup Data ==========****/

SELECT	*
INTO Application_MHD17000
FROM [Application]
WHERE ApplicationId = 10002242826

/****======== Actual Updating of Data ==========****/
GO
UPDATE [Application]
	SET DeclineReasonId = NULL
		,EngineResultTypeId = NULL
WHERE ApplicationId = 10002242826

/****======== Please send a screenshot of the result ==========****/
SELECT	ApplicationId
		,DeclineReasonId
		,EngineResultTypeId
FROM [Application]
WHERE ApplicationId = 10002242826
```
15. Update Transaction Status

```
Use Horizon2

SELECT * FROM [Transaction] Where TransactionId = 81913852 and ApplicationId = 10002121232
UPDATE [Transaction] SET TransactionStatusId = '1005', Notes = 'Cancelled. Already added the correct entry for the payment received. MHD-17109' Where TransactionId = 81913852 and ApplicationId = 10002121232
```
16. Update the ABN active since date

```
use Horizon2
select * into MHD17786_ApplicationBusiness From ApplicationBusiness where ApplicationBusinessId = 18963
update ApplicationBusiness set DateActiveSince = '2005-04-01 00:00:00.000' where ApplicationBusinessId = 18963

--Use this to Find ApplicationBusinessId 
use Horizon2
Select * From AutopayApplication  Where ApplicationId = 10002257922
```
17. Reset Horizon PW (Prod - create a CR/DF ticket)

```
USE Horizon2

DECLARE @userId INT = 0
SELECT @userId = UserId FROM [User] WHERE Username = 'lary' --  --Double check username before running

UPDATE [User] SET 
FailedLogin = 0
WHERE UserId = @userId

UPDATE webpages_Membership SET 
PasswordChangedDate = NULL,
[Password] = '[CREDENTIAL REDACTED - see Confluence page 519602304]', -- [CREDENTIAL REDACTED - see Confluence page 519602304]
PasswordFailuresSinceLastSuccess = 0
WHERE UserId = @userId

select * from [User] where UserId = @userId
select * from [webpages_Membership] where UserId = @userId
```
18. Change Plate for SPL Accounts

```
use Horizon2
select * into MHD18048_vehicleAsset from vehicleAsset where vehicleassetId = 9160
update vehicleAsset set RegisteredPlate = '<PLATE>' WHERE vehicleassetId = 9160

-- Get vehicleassetId (change the where to any info available that matches a record)
select * from vehicleAsset where VIN = 204823984792364827
```
19. Update Merge tag sourceSQL

```
USE Horizon2

DECLARE @MergeTagToUpdate NVARCHAR(200)
DECLARE @NewTagToUpdate NVARCHAR(200) = '[Application].[S21Completed]'

SET @MergeTagToUpdate = @NewTagToUpdate
UPDATE MergeTag SET IsActive = 0 WHERE  IsActive = 1 AND Tag = @MergeTagToUpdate

INSERT INTO [MergeTag] ([Name], [Tag], [Type], [SourceSimple], [SourceComplex], [SourceSql], [Format], [IsActive], [DateCreated], [CreatedByUserId], [DateModified], [ModifiedByUserId]) 
SELECT TOP 1 [Name], @MergeTagToUpdate, [Type], [SourceSimple], [SourceComplex], 
'SELECT ISNULL(sd1.DateSent, ISNULL(sd2.DateCreated, ISNULL(sd3.DateSent, sd4.DateClosed)))
FROM [Application] a
LEFT JOIN
  (SELECT TOP 1 m.DateSent,
              m.ApplicationId
   FROM CommsTemplate ct
   INNER JOIN [Message] m ON ct.CommsTemplateId = m.CommsTemplateId
   WHERE m.ApplicationId = @AppId
     AND ct.CommsTypeId = 4001
     AND ct.TemplateId IN (156,
                           2171,
                           2172,
                           3031,
                           3032,
                           3033,
                           3034,
						   10480,
						   10481)
     AND m.DateSent IS NOT NULL
   ORDER BY m.DateSent DESC) sd1 ON sd1.ApplicationId = a.ApplicationId
LEFT JOIN
  (SELECT TOP 1 DateCreated,
              ApplicationId
   FROM Note
   WHERE ApplicationId = @AppId
     AND NoteHeaderId = 14
     AND (BODY LIKE ''%s21d final notice%'' OR BODY LIKE ''%s21d document%'')
   ORDER BY DateCreated DESC) sd2 ON sd2.ApplicationId = a.ApplicationId
LEFT JOIN
  (SELECT TOP 1 ad2.ApplicationId,
              CONVERT(DATETIME, ad2.Value, 103) AS DateSent
   FROM AdditionalData ad1
   INNER JOIN AdditionalData ad2 ON ad2.ApplicationId = ad1.ApplicationId
   AND ad2.additionalDataTypeId = 24
   WHERE ad1.ApplicationId = @AppId
     AND ad2.ApplicationId = @AppId
     AND ad1.AdditionalDataTypeId = 22
     AND ad1.[Value] = ''36003'') sd3 ON sd3.ApplicationId = a.ApplicationId
LEFT JOIN
  (SELECT TOP 1 ApplicationId,
              DateClosed
   FROM Task
   WHERE ApplicationId = @AppId
     AND TaskTypeId = 57
     AND DateClosed IS NOT NULL
   ORDER BY DateClosed DESC) sd4 ON sd4.ApplicationId = a.ApplicationId
WHERE a.ApplicationId = @AppId', 

[Format], 1, GETDATE(), 1, GETDATE(), 1 
FROM MergeTag WHERE  IsActive = 0 AND Tag = @MergeTagToUpdate
ORDER BY DateCreated DESC

SELECT * FROM MergeTag 
WHERE [Tag] IN (@NewTagToUpdate)
--AND IsActive = 1
ORDER BY DateCreated DESC
```
20.  Move application to a different account / Merge 

```
USE Horizon2

EXEC AppSupport_MoveAppToCustomer
    @ApplicationId = 10002667735, --App to move
    @CustomerId = 20319; --Main account

--Test
SELECT ApplicationId, CustomerId FROM [Application] WHERE ApplicationId = 10002667735
```
21. Update EntityName (or any application business details)

```
USE Horizon2
--Find ApplicationBusinessId
SELECT ApplicationBusinessId FROM AutopayApplication WHERE ApplicationId = --Insert ApplicationId
SELECT * INTO ApplicationBusiness_MHD18200 FROM ApplicationBusiness WHERE ApplicationBusinessId = 19520
UPDATE ApplicationBusiness SET EntityName = 'F.M NASH & R.E NASH' WHERE ApplicationBusinessId = 19520
SELECT EntityName FROM ApplicationBusiness WHERE ApplicationBusinessId = 19520
```
22. Update Risk Rating

```
use Horizon2

Select * Into AutopayApplication_MHD18245 From AutopayApplication where ApplicationId in (10002274294, 10002274255, 10002275066, 10002276417)
Update AutopayApplication set RiskBand = 'AA' where ApplicationId = 10002274294	and AutopayApplicationID = 76226
Update AutopayApplication set RiskBand = 'AA' where ApplicationId = 10002274255	and AutopayApplicationID = 76213
Update AutopayApplication set RiskBand = 'A' where ApplicationId = 10002275066	and AutopayApplicationID = 76354
Update AutopayApplication set RiskBand = 'A' where ApplicationId = 10002276417	and AutopayApplicationID = 76479

Select * Into Application_MHD18245 From Application where ApplicationId in (10002274294, 10002274255, 10002275066, 10002276417)
Update Application set ProductTypeId = 2190 where ApplicationId = 10002274294
Update Application set ProductTypeId = 2190 where ApplicationId = 10002274255
Update Application set ProductTypeId = 2191 where ApplicationId = 10002275066
Update Application set ProductTypeId = 2191 where ApplicationId = 10002276417

Select * from ProductType where Description = 'APY'
Select RiskBand, * From AutopayApplication where ApplicationId in (10002274294, 10002274255, 10002275066, 10002276417)
```
23. Update Mobile Number (MME) - Issue: Mobile number field in Horizon Web is showing the old mobile number

```
USE Horizon2
SELECT * INTO CustomerContactNo_MHD18687 FROM CustomerContactNo WHERE CustomerId = 247657 and CustomerContactNoId = 2218404
UPDATE CustomerContactNo SET Number = '04XXXXXXXX' WHERE CustomerId = 247657 and CustomerContactNoId = 2218404
SELECT Number FROM CustomerContactNo WHERE CustomerId = 247657 and CustomerContactNoId = 2218404
```
24. Check if accoutn has logged in successfully

```
declare @username varchar(max) = 'customer@example.com'

select * from customerloginaudit cla where cla.CustomerAccountId = (
select ca.CustomerAccountId from customeraccount ca where ca.username = @username)
and cla.Message = 'Login successful' and Notes like '%Device Info%'
order by cla.DateCreated desc
```
25. Change email

```
use Horizon2
SELECT * INTO CustomerEmail_MHD18403 FROM CustomerEmail WHERE CustomerId = 1366710
UPDATE CustomerEmail SET EmailAddress = 'customer@example.com' WHERE CustomerEmailId in (1694160,2342407,2669376) and CustomerId = 1366710
-- Testing
SELECT * FROM CustomerEmail WHERE CustomerId = 1366710
```
26. Unable to change payment method; but no AdditionalDataTypeId = 32

```
use Horizon2
INSERT INTO AdditionalData (ApplicationId, AdditionalDataTypeId, Value, DateCreated, CreatedByUserId)
VALUES (10000619501, 32, 4, GETDATE(), 1)
--For testing
SELECT * FROM AdditionalData WHERE AdditionalDataTypeId = 32 and ApplicationId = 10000619501 
```
27. Investigate missing amount on Available Balance (EML Transactions)

```
declare @appid bigint = 10001543203

select abs(amountvalueminor)/100.00 as Amount,LogicalTransactionId from EmlWebhook eh1 where eh1.ExternalAccountId in(
select ea.ExternalAccountId from EmlAccount ea where ea.ApplicationId = @appid
) and
eh1.DelegationRequestId is not null
and not exists(select top 1 1 from emlwebhook eh where eh.LogicalTransactionId = eh1.LogicalTransactionId and NewState in ('cleared','declined'))

select ExternalAccountId,LogicalTransactionId,ABS(AmountValueMinor)/100.00 as Amount,[description],OldState,NewState,CreatedDate from EmlWebhook where LogicalTransactionId = 6950316476 order by CreatedDate
```
28. Find APY Vehicle Detail Id, given Application ID

```
USE Horizon2
DECLARE @apyvehicleid int, @appid BIGINT 
SET @appid = 10002136475
SELECT top 1 @apyvehicleid=AutopayVehicleDetailId FROM AutopayApplication WHERE ApplicationId = @appid
SELECT * FROM AutopayVehicleDetail WHERE AutopayVehicleDetailId = @apyvehicleid
```
29. Update Email Address

```
USE Horizon2
SELECT * INTO CustomerEmail_MHD20936 FROM CustomerEmail WHERE CustomerId = 1756934 and CustomerEmailId IN (2369734, 2372999, 2423940, 2573942)
UPDATE CustomerEmail SET EmailAddress = 'customer@example.com' WHERE CustomerId = 1756934 and CustomerEmailId IN (2369734, 2372999, 2423940, 2573942)
SELECT EmailAddress FROM CustomerEmail WHERE CustomerId = 1756934 and CustomerEmailId IN (2369734, 2372999, 2423940, 2573942)
```
30. Unlink Email from an app to another app.

```
USE Horizon2
GO
--Backup
SELECT * INTO InboundEmail_MHD20529 FROM InboundEmail iml WHERE iml.InboundEmailId=1166216

--Update InboundEmail
UPDATE iml SET iml.ApplicationId=2000098707, iml.Note=iml.Note + '|Manual|2000098707' FROM InboundEmail iml WHERE iml.InboundEmailId=1166216

--Raise new email task
INSERT INTO Task (ApplicationId,TaskTypeId,[Status],DateCreated,CreatedByUserId,DueDate,Note)
VALUES(2000098707,17,'Open',GETDATE(),1,DATEADD(MINUTE,10,GETDATE()),'MessageId:1166216')
```
31. Find EWAY Transaction via App ID

```
USE Horizon2
select DateCreated AS 'RequestDate', CreditCardPaymentId, ApplicationId, ScheduledAmount, ResultText, ResultCode, NameOnCard, BankReceiptId, PayerName, APIResponse, *
from CreditCardPayment where applicationId = 10001611889 ORDER BY DateCreated DESC
```
32. Update Incorrect URL / ID link Datafix - check referenceId first for equifaxtransactionId, remove all links

```
USE Horizon2
SELECT * INTO MHD22451_EquifaxTransaction FROM EquifaxTransaction WHERE referenceID = '10002406358' AND equifaxTransactionId = 209415
DELETE FROM EquifaxTransaction WHERE referenceID = '10002406358' AND equifaxTransactionId = 209415
--Testing
SELECT * FROM EquifaxTransaction WHERE referenceID = '10002406358' AND equifaxTransactionId = 209415
```
33. Email sent not reflecting on comms tab (Confirm if the app is currently on 117 stage or Arrears Referred to External. This means that we can no longer contact the customer since the customer has already been passed to an External Agency.)

```
Select * from ApplicationStage where applicationid = 10001667785 and IsActive = 1 
```
34. Update Transaction status in Freestyle Tab.

```
Use Horizon2
--Backup
SELECT * INTO EmlWebhook_MHD20994 FROM EmlWebhook Where logicaltransactionid = 6169014874 and EmlWebHookId = 15697953
--Update
Update EmlWebhook SET NewState = 'reversed' Where logicaltransactionid = 6169014874 and EmlWebHookId = 15697953
--Testing
SELECT NewState,logicaltransactionid,* FROM EmlWebhook Where logicaltransactionid = 6169014874 
```
35. Cancel Pending PayAnyone Transaction

```
USE Horizon2
GO

-- Find PATransaction Id
SELECT TransactionId FROM PATransaction WHERE ApplicationId = 10002268142

EXEC [dbo].[PATransactionDataFixUpdateTransaction] 10002268142, 433572, 67006, 1, NULL, NULL -- Change ApplicationId, TransactionId
EXEC Horizon2.[dbo].[ComputeSlidingLimit] 10002268142, 1, 1
```
36. Remove Duplicate Transaction (cancelled out interest sample)

```
USE Horizon2
DECLARE @TranIdToFix INT = 90140239 -- Transaction to Fix/Remove
DECLARE @AppIdToFix BIGINT = (SELECT TOP 1 [ApplicationId] FROM [Transaction] WHERE TransactionId = @TranIdToFix) -- AppId of the Transaction to Fix
DECLARE @AppIdAmortToFix BIGINT = (SELECT TOP 1 [AmortizationId] FROM [Transaction] WHERE TransactionId = @TranIdToFix)
-- App Id where the transaction will be moved
DECLARE @WagtestAppId BIGINT = 10001566128 -- App Id to Move the Transaction
DECLARE @AmortIdHeaderWagtest BIGINT = 10003110143 -- This is header to use to move the amort data
-- Update Transaction to be removed on the app
UPDATE [Transaction] SET ApplicationId = @WagtestAppId WHERE TransactionId = @TranIdToFix
IF (@AppIdAmortToFix IS NOT NULL)
BEGIN
	-- Update Amort Id from the transaction that will be moved
	UPDATE [Amortization] SET ApplicationId = @WagtestAppId, AmortizationHeaderId = @AmortIdHeaderWagtest WHERE AmortizationId = @AppIdAmortToFix
END
exec UpdateAmounts @AppIdToFix
```
37. Unable to cancel application

```
USE Horizon2
--Backup
SELECT * INTO ApplicationStage_MHD22054 FROM ApplicationStage WHERE ApplicationId = 10002397539
--Update
INSERT INTO ApplicationStage (ApplicationId, FromStageId, ToStageId, RollBackTo, IsActive, DateCreated, CreatedByUserId)
VALUES (10002397539, 1, 18, 1, 1, GETDATE(), 1)
--Test
SELECT * FROM ApplicationStage WHERE ApplicationId = 10002397539
```
38.  Error when accepting offer

```
use Horizon2
-- Check if there is existing PayFrequency
select PayFrequencyId,* From AutopayApplication where applicationID =10002418100
-- Get customerid and employmentId 
select * from Application where ApplicationId = 10002418100
-- Get correct PayFrequencyId
select * from Employment where employmentId = 3356180 and customerId = 1894027

-- Backup
select * Into AutopayApplication_MHD22987 From AutopayApplication where applicationID =10002418100

-- Update
update AutopayApplication set PayFrequencyId = 12003 where applicationID =10002418100
```
39. Unlink email and put back in email tray

```
USE Horizon2
GO
UPDATE ib SET ApplicationId = NULL 
FROM InboundEmail ib WHERE ib.InboundEmailId in (1227910,1227894,1227743,1227724,1227693,1227657,1227652,1227651,1227646,1227638,1227626,1227612,1227611,1227610,1227607,1227601,1227576,1227525,1227519) 
AND ib.ApplicationId = 10002191603
--END
```
40. Allocate merchant credit (given transaction ID)

```
EXEC UpdateAllocation 92773525
```
41. Reverse Merchant Credit (given transaction ID / find merchant credit that has no Allocations via  )

```
DECLARE @TranId BIGINT = 71613685
DECLARE @AppId BIGINT = 10001037782
DECLARE @UserId BIGINT = 1
DECLARE @TranAmount MONEY
DECLARE @notes VARCHAR(500) = 'Payment reversed due to no allocation Reversed from: 71613685 | MHD-21177'
SELECT @TranAmount = TranAmount
FROM [Transaction]
WHERE TransactionId = @tranId 
AND ApplicationId = @appId
BEGIN TRAN
	--Reversed Transaction
	INSERT INTO [Transaction] (ApplicationId
	, TranAmount
	, TranDate
	, DateProcessed
	, DateCreated
	, TransactionStatusId
	, TransactionTypeId
	, CreatedByUserId
	, Notes
	, IsReversed)
	SELECT @appId 'ApplicationId'
	, @TranAmount * -1 'TranAmount'
	, CAST(GETDATE() AS DATE) --TranDate
	, GETDATE() 'DateProcessed'
	, GetDate() 'DateCreated'
	, 1003 'TransactionStatusId'
	, 36 'TransactionTypeId' --36 Reverse
	, @UserId 'CreatedByUserId'
	, @notes 'Notes'
	, 1 'IsReversed'
	FROM [Transaction]
	WHERE TransactionId = @tranId 
	AND ApplicationId = @appId
	--Merchant Credit Transaction to excess
	INSERT INTO [Transaction] (ApplicationId
	, TranAmount
	, Excess
	, TranDate
	, DateProcessed
	, DateCreated
	, TransactionStatusId
	, TransactionTypeId
	, CreatedByUserId
	, Notes)
	VALUES (@AppId
	, @TranAmount --TranAmount
	, @TranAmount --Excess
	, CAST(GETDATE() AS DATE) --TranDate
	, GETDATE() --DateProcessed
	, GETDATE() --DateCreated
	, 1003 --TranstatusId
	, 83 --83 Merchant Creadit
	, @UserId --CreatedByUserId
	, 'Allocation Datafix for TranId: 71613685 | MHD-21177'
	)
COMMIT TRAN
EXEC UpdateAmounts @AppId
```
42. Update duration for APY

```
use Horizon2
--Backup
SELECT * INTO Application_MHD24460 FROM Application WHERE ApplicationId =  10002464746
SELECT * INTO AutopayApplication_MHD24460 FROM AutopayApplication WHERE ApplicationId =  10002464746
SELECT * INTO AdditionalData_MHD24460 FROM AdditionalData WHERE ApplicationId =  10002464746
--Update
UPDATE AutopayApplication SET Duration = '48 months' WHERE ApplicationId =  10002464746
UPDATE AdditionalData SET Value = '48 months' WHERE ApplicationId =  10002464746 and AdditionalDataId = 39407741
--Testing
SELECT * FROM Application WHERE ApplicationId =  10002464746
SELECT * FROM AutopayApplication WHERE ApplicationId = 10002464746
SELECT * FROM AdditionalData WHERE ApplicationId =  10002464746
```
43. Update RepaidDate

```
Use Horizon2
-- Backup
SELECT * INTO Application_MHD24826 FROM [Application] WHERE ApplicationId = 10001654479 
-- Update
UPDATE [Application] SET RepaidDate = '2025-05-09 09:49:24.070' WHERE ApplicationId = 10001654479 
-- Testing
SELECT RepaidDate,* FROM [Application] WHERE ApplicationId = 10001654479
```
44. DE 1 failed to run 

```
use Horizon2

SELECT * INTO [Application_MHD25045] FROM [Application] WHERE ApplicationId = 10002487902
UPDATE [Application] SET ProductTypeId = 3891, OfferedAmount = 100000, RequestedAmount = 150000
WHERE ApplicationId = 10002487902

SELECT * INTO AutopayApplication_MHD25045 FROM AutopayApplication WHERE ApplicationId = 10002487902
UPDATE AutopayApplication SET CreditScore = 1062, RiskBand = 'AA' WHERE ApplicationId = 10002487902

-- ProductTypeId = 3891, OfferedAmount = 100000, RequestedAmount = 150000
select ProductTypeId,OfferedAmount,RequestedAmount,* From Application where applicationID = 10002487902
-- CreditScore = 1062, RiskBand = 'AA'
select CreditScore,* From autopayApplication where applicationID = 10002487902
```
45. Add permission(s) to multiple Roles in Horizon Web via script (edit the IDs accordingly)

```
USE Horizon2
/*RoleId IN (39,40,41,47,49,50,53,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71)
Did not include Roles: Solutions 1, 2, 3, 4, 5, Admin, Compliance and Marketing Basic, Marketing + LR
because it has been done manually
SELECT * FROM webpages_Roles ORDER BY RoleId --Roles; RoleId
SELECT * FROM RoleAccess WHERE RoleId = 36 --Update/Insert; RoleId, TabId, AccessLevelId
SELECT * FROM Tab WHERE TabId = 295 --Permission; TabId */

--TabId 295 = Stages_AFCA_Arrangement, 296 = Stages_AFCA_Arrangement_Broken;
--AccessLevelId 1 = View

INSERT INTO RoleAccess (RoleId, TabId, AccessLevelId)
SELECT RoleId, TabId, 1 AS AccessLevelId
FROM (
    SELECT value AS RoleId
    FROM (VALUES 
        (39), (40), (41), (47), (49), (50), (53), (55), (56), (57), (58), (59),
        (60), (61), (62), (63), (64), (65), (66), (67), (68), (69), (70), (71)
    ) AS Roles(value)
) AS RoleList
CROSS JOIN (
    SELECT value AS TabId
    FROM (VALUES (295), (296)) AS Tabs(value)
) AS TabList
WHERE NOT EXISTS (
    SELECT 1
    FROM RoleAccess ra
    WHERE ra.RoleId = RoleList.RoleId
      AND ra.TabId = TabList.TabId
      AND ra.AccessLevelId = 1
);
```
46. Add new allocated transaction (Only use this if the transaction with no allocation is old and is already cancelled)

```
--87	Allocated VirtualPrincipal
DECLARE @AppId BIGINT = 10001183602 --Production AppId

DECLARE @Note VARCHAR(1000) = 'MHD-24895' ---> Change this with the MHD Ticket Number
DECLARE @Amount MONEY = 306.789
DECLARE @CreatedByUserId INT = 171 --Joshua.Allen

INSERT INTO [Transaction] (ApplicationId, TranDate, TranAmount, VirtualPrincipal, TransactionStatusId, TransactionTypeId, DateProcessed, Notes, DateCreated, CreatedByUserId)
SELECT @AppId 'ApplicationId'
	, CAST(GETDATE() AS DATE) 'TranDate'
	, @Amount 'TranAmount'
	, @Amount 'VirtualPrincipal'
	, 1003 'TransactionStatusId'
	, 87 'TransactionTypeId'
	, GETDATE() 'DateProcessed'

	, @Note 'Note'
	, GETDATE() 'DateCreated'
	, @CreatedByUserId 'CreatedByUserId'

EXEC UpdateAmounts 10001183602
```
47. Email link; Relink email; Move Email to given ApplicationId; Update Message via MessageId  
Update email in Customer account and retain only 1 active email per type (deactivate others)

```
USE Horizon2
GO
--Backup
SELECT * INTO Message_MHD25172 FROM [Message] WHERE MessageId = 65665613

--Update Message
UPDATE [Message] SET ApplicationId = 10000978845 FROM [Message] WHERE MessageId = 65665613
```
48. Link IdrComplaint to ApplicationId

```
USE Horizon2
--complaint details
SELECT * FROM IdrComplaint WHERE IdrComplaintId = 12600
--backup
SELECT * INTO IdrComplaint_MHD25475 FROM IdrComplaint WHERE IdrComplaintId = 12600

--linking
UPDATE i set i.ApplicationId=10001560041 FROM IdrComplaint i WHERE i.IdrComplaintId=12600 and i.ApplicationId is null
```
49. check permission that a group does not have in Horizon

```
use Horizon2

DECLARE @oldRole NVARCHAR(32) = 'Product QA Collections' -- origin role
DECLARE @oldRoleId INT

DECLARE @newRole NVARCHAR(59) = 'App Support' -- destination role
DECLARE @newRoleId INT 

SELECT TOP 1 @oldRoleId = RoleId FROM webpages_Roles  WHERE RoleName = @oldRole
SELECT TOP 1 @newRoleId = RoleId FROM webpages_Roles  WHERE RoleName = @newRole
SELECT * FROM webpages_Roles WHERE RoleId IN (@oldRoleId, @newRoleId) ORDER BY RoleId 

SELECT @newRoleId, RA.TabId, AccessLevelId,t.TabName FROM RoleAccess RA
INNER JOIN Tab t on t.TabId=ra.TabId
WHERE RA.RoleId = @oldRoleId
AND NOT EXISTS(SELECT 1 FROM RoleAccess RAI WHERE RAI.RoleId = @newRoleId AND RAI.TabId = RA.TabId AND RAI.AccessLevelId = RA.AccessLevelId)
```
50. Multiple Inactive account found; Check carefully, the error shows when the username and the email address are different. Update the Username.

```
use Horizon2
SELECT * INTO CustomerAccount_MHD14526 FROM CustomerAccount WHERE CustomerId = 1321329
UPDATE CustomerAccount SET Username = '<insert email address>' WHERE CustomerAccountId = 1202867 and CustomerId = 1321329
```
51. Blacklist car dealership

```
USE HORIZON2

DECLARE @Name varchar(50) 
DECLARE @LegalName varchar(50)
DECLARE @ABN varchar(50)
DECLARE @BSB varchar(50)
DECLARE @AccountNumber varchar(50)

SET @Name = '<DEALERSHIP_NAME>'
SET @LegalName = '<DEALERSHIP_LEGAL_NAME>'
SET @ABN = '<ABN>'
SET @BSB = '<BSB>'
SET @AccountNumber = '<ACCOUNT_NUMBER>'

INSERT INTO BlacklistedDealership(Name, LegalName, ABN, BSB, 
									AccountNumber ,DateCreated, CreatedByUserId, IsActive)
						VALUES(@Name, @LegalName, @ABN, @BSB, 
									@AccountNumber ,GETDATE(), 1, 1);
```
52. Check why APY app is stuck in a certain stage

```
use Horizon2
select * From EdxSearch where applicationId in (10002554475,10002550935 )
select * From EdxRegistration where applicationId in (10002554475,10002550935 )
```
53. Change Leadsource APY

```
USE Horizon2 
--Backup
SELECT * INTO Application_MHD26972 FROM Application WHERE applicationID = 10002583086;
SELECT * INTO AutopayApplication_MHD26972 FROM AutopayApplication WHERE applicationID = 10002583086;
--Update
UPDATE Application SET leadSourceId = 5905 WHERE applicationID = 10002583086;
UPDATE AutopayApplication SET leadSourceId = 5905 WHERE applicationID = 10002583086;
--Testing
SELECT Createdbyuserid,leadSourceId,* FROM Application WHERE applicationID = 10002583086;
SELECT leadSourceId,* FROM AutopayApplication WHERE applicationID = 10002583086;
select leadSourceId,* From leadSource where description like '%Bendigo%'
select leadSourceId,* From leadSource where description like '%Green RV%'
SELECT * FROM [PartnerUser] WHERE Lastname LIKE '%Ketlon%' and brandid = 5;
select * from MultiDealership WHERE partneruserid = 16233; 
select leadSourceId,* From leadSource where Leadsourceid = 2258
SELECT * FROM [PartnerUser] WHERE partneruserid = 16233
```
54. Update splitaccountid

```
Use Horizon2
-- Backup
SELECT * INTO Application_MHD27047 FROM Application Where ApplicationId = 10002547581
-- Update
UPDATE [Application] SET SplitAccountId = 1025 Where ApplicationId = 10002547581
-- Testing
SELECT ApplicationId, SplitAccountId FROM Application Where ApplicationId = 10002547581
```
55. Remove PPSR and Set Vehicle Status to Removed

```
USE Horizon2

SELECT ApplicationId, IsDischarged, DateDischarged INTO EdxRegistration_MHD27200 FROM EdxRegistration
WHERE ApplicationId in (
2000179246
)
AND IsDischarged = 0 OR IsDischarged IS NULL
ORDER BY ApplicationId DESC;

UPDATE EdxRegistration SET IsDischarged = 1, DateDischarged = '2025-09-22 09:37:00' WHERE ApplicationId = 2000179246;

SELECT VehicleAssetStatusTypeId, VehicleStatusDate INTO vehicleAsset_MHD27200 FROM vehicleAsset WHERE applicationID in (
2000179246
)

UPDATE vehicleAsset SET VehicleAssetStatusTypeId = 102005, VehicleStatusDate = '2025-09-22 09:37:00' WHERE ApplicationId = 2000179246;
```
56. Blank / Null password

```
SELECT Horizon2.dbo.EncryptTextNoPWD('1234') -- get the hash for a temp passcode

UPDATE CustomerAccount
SET [Password] = '[CREDENTIAL REDACTED - see Confluence page 519602304]'
WHERE CustomerId = 1993643
```
57. Get funded loans that have NO Split nor Ezidebit accounts

```
--Get funded loans that have NO Split nor Ezidebit accounts
select A.ApplicationId, A.CustomerId, Ts.TaskId, A.FundedDate, PT.[Description] 'Product', S.[Description] 'Status', A.CurrentBalance, AD32.[Value] 'DefaultPaymentMode',
	CASE WHEN T.ApplicationId IS NULL THEN 'False' ELSE 'True' END 'IsWrittenOff', Ts.Note, Ts.DueDate, SA.SplitAccountId, SA.AgreementStatus
from [Application] A
	inner join Customer C ON A.CustomerId=C.CustomerId
	inner join ProductType PT ON A.ProductTypeId=PT.ProductTypeId
	inner join [Status] S ON A.StatusId=S.StatusId
	left join [AdditionalData] AD32 ON A.ApplicationId=AD32.ApplicationId and AD32.AdditionalDataTypeId=32 --DefaultPaymentMode
	left join [Transaction] T ON A.ApplicationId=T.ApplicationId AND T.TransactionStatusId=1003 and T.TransactionTypeId=14
	left join [Task] Ts ON A.ApplicationId=Ts.ApplicationId AND Ts.TaskTypeId=150 and Ts.[Status]='Open'
	left join SplitAccount SA ON A.SplitAccountId=SA.SplitAccountId
where A.FundedDate is not null
	and C.FirstName not like '%wagtest%'
	and A.StatusId not in(10,6,5,11)
	and PT.[Description] <> 'LST'
	and A.SplitAccountId is null
	and A.EzidebitAccountId is null
	and (AD32.[Value] is null or AD32.[Value] not in('3','4'))
	and A.FundedDate < cast(getdate() as date)
	--and Note is not null
	and A.ApplicationId NOT IN(10001871338,10001871349,10001992450, 10002253148,10001794597)
	and A.ApplicationId NOT IN(10001061490) --RentReady App
	--and Ts.Note like 'Exception%'
order by A.FundedDate
```
58. Set as Current bank details - Data fix (while dev fix is not yet released)

```
USE Horizon2

declare @appId bigint  = 10002675188 -- Application to investiagte or fix

select ApplicationBankId, CustomerId, * from [Application]
where ApplicationId = @appId

--From the list of this banks select which one to be assigned then get the ApplicationBankId
select * from ApplicationBank 
where CustomerId = (select CustomerId from [Application] where ApplicationId = @appId)

declare @appBankId bigint = 1269781 -- the value here should from the list above select query where we want the assigment goes

update [Application] set ApplicationBankId = @appBankId
where ApplicationId = @appId

select ApplicationBankId, CustomerId, * from [Application]
where ApplicationId = @appId
```
59. Get PaymentReqRef from SplitPayment

```
USE Horizon2
SELECT PaymentReqRef FROM [SplitPayment] WHERE PaymentRef = '10001071695-99977014'
```
60. Update Application Stage

```
USE Horizon2
SELECT * INTO ApplicationStage_MHD28121 FROM ApplicationStage WHERE ApplicationId = 10002646968 AND IsActive = 1
UPDATE ApplicationStage SET IsActive = 0 FROM ApplicationStage WHERE ApplicationStageId = 24106652
INSERT INTO ApplicationStage (ApplicationId, FromStageId, ToStageId, RollBackTo, IsActive, DateCreated, CreatedByUserId)
VALUES (10002646968, 39, 38, 39, 1, GETDATE(), 1)
UPDATE [Application] SET StatusId = 7 WHERE ApplicationId = 10002646968

--Test
SELECT * FROM ApplicationStage WHERE ApplicationId = 10002646968 AND IsActive = 1
SELECT StatusId FROM [Application] WHERE ApplicationId = 10002646968
```
61. Reset workflow

```
USE Horizon2;
GO

-- Backup
SELECT *
INTO ApplicationWorkflow2_MHD29205
FROM ApplicationWorkflow2
WHERE WorkflowId = 100202
  AND ApplicationId IN (
      10002710158,
      10002709207,
      10002710131,
	  10002709151
  );

-- Delete
DELETE FROM ApplicationWorkflow2
WHERE WorkflowId = 100202
  AND ApplicationId IN (
      10002710158,
      10002709207,
      10002710131,
	  10002709151
  );

-- Verify Results
SELECT *
FROM ApplicationWorkflow2
WHERE WorkflowId = 100202
  AND ApplicationId IN (
      10002710158,
      10002709207,
      10002710131,
	  10002709151
  );
```
62. Update EntityName to correct names in Email templates

```
USE Horizon2
declare @AppId BIGINT = 10002674198
--Get ApplicationBusiness Id
SELECT AB.ApplicationBusinessId, AB.EntityName
FROM ApplicationBusiness AB
INNER JOIN AutopayApplication AA
    ON AA.ApplicationBusinessId = AB.ApplicationBusinessId
WHERE AA.ApplicationId = @AppId;

--Backup
SELECT * INTO ApplicationBusiness_MHD29460 FROM ApplicationBusiness 
WHERE ApplicationBusinessId = 44346

--Update
UPDATE ApplicationBusiness SET EntityName = 'JULIA LAGARDE'  
WHERE ApplicationBusinessId = 44346

--Get SourceSql from dbo.Mergetag
--SELECT SourceSql FROM dbo.mergetag WHERE tag = '[Application].[Business].[EntityName]' and isactive = 1
```
63. Check Horizon Workflow via TemplateId

```
use Horizon2
go

declare @templateId varchar(10) = '1671'
select * from WorkFlow where CAST(Actions as varchar(max)) like '%SendNotification%>'+@templateid+'<%' and IsActive=1
select * from WorkFlow2 where (CAST(Actions as varchar(max)) like '%SendEmail%>'+@templateid+'<%' OR CAST(Actions as varchar(max)) like '%SendSms%>'+@templateid+'<%' OR CAST(Actions as varchar(max)) like '%SendPushNotification%>'+@templateid+'<%') and IsActive=1
```
64. Decrypt Password

```
USE Horizon2
SELECT dbo.DecryptTextNoPWD('[CREDENTIAL REDACTED - see Confluence page 519602304]') AS Password
```
65. Update Repaid date to NULL

```
USE [Horizon2]

BEGIN TRANSACTION

-- PRE-CHECKING ---
SELECT 'Pre-Update Checking' 'Remarks', ApplicationId, RepaidDate from Horizon2.dbo.[Application] where ApplicationId IN (10002810504)

-- Create a backup data.
SELECT * INTO Horizon2.dbo.Application_MHD29431 FROM Horizon2.dbo.[Application] WHERE ApplicationId IN (10002810504)

-- UPDATING --
UPDATE a SET a.RepaidDate = NULL FROM Horizon2.dbo.[Application] a WHERE a.ApplicationId IN (10002810504)

---- REVERTING --
--UPDATE A1 SET A1.RepaidDate = A2.RepaidDate 
--FROM Horizon2.dbo.[Application] A1 WITH (NOLOCK)
--INNER JOIN Horizon2.dbo.Application_MHD29431 A2 WITH (NOLOCK) ON A1.ApplicationId = A2.ApplicationId

-- POST-CHECKING ---
SELECT 'Post-Update Checking' 'Remarks', ApplicationId, RepaidDate from Horizon2.dbo.[Application] where ApplicationId IN (10002810504)

COMMIT
```
66. Update Bank Details (APY & MME apps only)

```
USE Horizon2
SELECT * INTO Commissionbank_MHD32263 FROM Commissionbank WHERE LeadsourceId = 6523
UPDATE Commissionbank SET Sortcode = '062589' WHERE LeadsourceId = 6523
SELECT * FROM Commissionbank WHERE LeadsourceId = 6523

-- FIND LeadsourceId via AppID
--SELECT * FROM Commission WHERE ApplicationId = 10002835269
```
67. Access to <https://partnership.moneyme.com.au/> 

```
declare @brandId int = 1,
@leadSourceId int = 206,
@userName nvarchar(150) = 'janna.flores@moneyme.com.au',
@firstName nvarchar(150) = 'Janna',
@lastName nvarchar(150) = 'Flores',
@emailAddress nvarchar(150) = 'janna.flores@moneyme.com.au',
@password nvarchar(300) = '[CREDENTIAL REDACTED - see Confluence page 519602304]',
@isAdmin bit = 0;
	    
--Encrypted : [CREDENTIAL REDACTED - see Confluence page 519602304]
--Password : [CREDENTIAL REDACTED - see Confluence page 519602304] 

insert into PartnerUser(BrandId,LeadSourceId,Username,FirstName,LastName,EmailAddress,[Password],IsActive,IsAdmin,DateCreated,CreatedByUserId)
values (@brandId,@leadSourceId,@userName,@firstName,@lastName,@emailAddress,@password,1,@isAdmin,GETDATE(),1)
```
68. SplitAccount ReCreation

```
Use Horizon2
GO

DECLARE @AppId BIGINT = 10002710060 --edit this accdgly
DECLARE @SplitAccount INT 
DECLARE @SplitContactId Uniqueidentifier
DECLARE @MHDTicketNumber VARCHAR(50) = 'MHD-32158' --edit this accdgly

SELECT @SplitAccount = SplitAccountId
FROM Application Where ApplicationId = @AppId

SELECT @SplitContactId = SplitContactId FROM SplitAccount where SplitAccountId = @SplitAccount

----SET status to cancelled and 
UPDATE SplitAccount SET AgreementStatus = 'cancelled' where SplitAccountId = @SplitAccount

----Set SplitAccountId reference in Application to NULL
UPDATE Application SET SplitAccountId = NULL Where ApplicationId = @AppId

---Move the old Splitaccount to a unused brand in this case RentReady
---327AF52B-781B-4562-9A3D-30D8D55264C8 this is rentready organization that nobody is using
Update Payment.dbo.SplitAccount set OrganizationId = '327AF52B-781B-4562-9A3D-30D8D55264C8' 
where SplitContactId = @SplitContactId

---Close all open task related to error account
--UPDATE [Task] SET [Status] = 'Closed', DateClosed = GETDATE(), ClosedByUserId = 1
--WHERE TaskId = 10416139 and ApplicationId = @AppId

--Raise CreationTask
--149	Split Create/Update Account
INSERT INTO Task (ApplicationId, TaskTypeId, [Priority], [Status], DateCreated, CreatedByUserId, Note)
VALUES (@AppId, 149, 'High', 'Open', GETDATE(), 1, @MHDTicketNumber)

SELECT TST.[Description] 'TaskName', TS.* 
FROM [Task] TS
INNER JOIN TaskType TST on TST.TaskTypeId = TS.TaskTypeId
Where ApplicationId = @AppId AND [Status] = 'Open'

SELECT SplitAccountId, SplitContactId, AgreementStatus FROM SplitAccount where SplitAccountId = @SplitAccount
SELECT SplitContactId, AgreementStatus FROM Payment.dbo.SplitAccount Where SplitContactId = @SplitContactId
SELECT ApplicationId, SplitAccountId FROM Application Where ApplicationId = @AppId
```
69. DataFix 0 APR and 0 Establishment Fee

```
USE Horizon2;
GO
-- ============================================================
-- Backup records before modification
-- MHD33766
-- ============================================================

-- Backup: Establishment Fee (ChargeId 112)
  SELECT * INTO ApplicationCharge_MHD33766
    FROM ApplicationCharge
    WHERE ApplicationChargeId = 688742
      AND ChargeId = 112
      AND ApplicationId = 10002962397;

-- Backup: APR Interest (ChargeId 105)
  SELECT * INTO ApplicationCharge_MHD33766
    FROM ApplicationCharge
    WHERE ApplicationChargeId = 688739
      AND ChargeId = 105
      AND ApplicationId = 10002962397;

GO

-- ============================================================
-- Updates
-- ============================================================

-- Update Establishment Fee: Amount = 395.00
UPDATE ApplicationCharge
SET Amount = 395.00
WHERE ApplicationChargeId = 688742
  AND ChargeId = 112
  AND ApplicationId = 10002962397;

-- Update APR Interest: Rate = 0.1233
UPDATE ApplicationCharge
SET Rate = 0.1695
WHERE ApplicationChargeId = 688739
  AND ChargeId = 105
  AND ApplicationId = 10002962397;

GO

-- ============================================================
-- Verification
-- ============================================================

-- Verify: Establishment Fee (ChargeId 112) ? Amount should be 495.00
SELECT * FROM ApplicationCharge
WHERE ApplicationChargeId = 688742
  AND 
  ChargeId = 112
  AND ApplicationId = 10002962397;

-- Verify: APR Interest (ChargeId 105) ? Rate should be 0.1817
SELECT * FROM ApplicationCharge
WHERE ApplicationChargeId = 688739
  AND
  ChargeId = 105
  AND ApplicationId = 10002962397;
```
70. Update Caravan to New (82001); Update VehicleConditionTypeId

```sql
USE Horizon2

--Backup
SELECT * INTO AutopayApplication_MHD34698 FROM AutopayApplication WHERE ApplicationId = 10003012912
--Update
UPDATE AutopayApplication SET VehicleConditionTypeId = 82001 WHERE ApplicationId = 10003012912
--Check
SELECT VehicleConditionTypeId, * FROM AutopayApplication WHERE ApplicationId = 10003012912
```
71. Remove dealership bank details

```sql
use Horizon2
--Backup
select * into ApplicationBank_MHD33598 From [ApplicationBank] where ApplicationBankId = 882049 and CustomerId = 868894
--Delete
delete from [ApplicationBank] where ApplicationBankId = 882049 and CustomerId = 868894
--Testing
select * From [ApplicationBank] where CustomerId = 868894
```
72. Transaction Reversal (edit appid, transactionid, and MHD#)

```sql
Use Horizon2
GO

DECLARE @AppId BIGINT = 10002053866
DECLARE @FOR_REVERSAL_TranId BIGINT = 110353178
DECLARE @DATAFIXNOTES VARCHAR(500) = 'Reverse Payment TranId: ' + CAST(@FOR_REVERSAL_TranId AS VARCHAR) + ' | MHD-36922'

IF(NOT EXISTS(SELECT ApplicationId,TransactionId
				FROM [Transaction]
				WHERE ApplicationId = 10002053866 AND Notes like '%MHD-36922%'))
BEGIN
	SELECT 'Not Exists' AS [CHECK]

	INSERT INTO [Transaction](ApplicationId, TranAmount, TranDate, Principal, EFee, Interest, Charge, DateSubmitted, DateProcessed, TransactionStatusId, TransactionTypeId, Notes, DateCreated, CreatedByUserId, ExtraFunds, Excess, Recoveries, AccountKeepingFee, AnnualFee, VirtualPrincipal, GstFee, MerchantFeeAmount, AdminFee, BrokerFee)
	SELECT ApplicationId,
			TranAmount * -1,
			CAST(GETDATE() AS DATE),
			Principal * -1,
			EFee * -1,
			Interest * -1,
			Charge * -1,
			GETDATE(),
			GETDATE(),
			1003,
			36,
			@DATAFIXNOTES,
			GETDATE(),
			10,
			ExtraFunds * -1,
			Excess * -1,
			Recoveries * -1,
			AccountKeepingFee * -1,
			AnnualFee * -1,
			VirtualPrincipal * -1,
			GstFee * -1,
			MerchantFeeAmount * -1,
			AdminFee * -1,
			BrokerFee * -1
	FROM [Transaction]
	WHERE ApplicationId = @AppId AND TransactionId = @FOR_REVERSAL_TranId

	EXEC UpdateAmounts @AppId

END
ELSE
BEGIN
	SELECT 'Already Exists' AS [CHECK]

	SELECT ApplicationId, 
	TranAmount, 
	TranDate, 
	Principal, EFee, Interest, Charge, ExtraFunds, Excess, Recoveries, AccountKeepingFee, AnnualFee, VirtualPrincipal, GstFee, MerchantFeeAmount, AdminFee, BrokerFee
	DateSubmitted, DateProcessed, TransactionStatusId, TransactionTypeId, Notes, DateCreated, CreatedByUserId
	FROM [Transaction]
	WHERE ApplicationId = @AppId AND Notes like '%MHD-36922%'
END
```

> **Mirror note, not on the source page.** Two defects as published: the `IF NOT EXISTS` check
> hardcodes `ApplicationId = 10002053866` instead of `@AppId`, so on any other application it
> tests the wrong app and can insert a second reversal; and the `ELSE` `SELECT` is missing a comma
> after `BrokerFee`, so `DateSubmitted` becomes a column alias. The `INSERT` also runs outside a
> transaction. Replace the hardcoded id with `@AppId` and wrap in `BEGIN TRAN` before use.

73. Move CLI request to Underwriting (StatusRequestId 51012); Update CreditLimitRequestInfo

```sql
USE Horizon2
--MHD-37036 Move CLI request to UW; App 10002930839, CreditLimitRequestInfoId 198087; StatusRequestId 51012 = UW
--Find
SELECT StatusRequestId, * FROM CreditLimitRequestInfo WHERE ApplicationId = 10002930839
--Backup
SELECT * INTO CreditLimitRequestInfo_MHD37036 FROM CreditLimitRequestInfo WHERE CreditLimitRequestInfoId = 198087
--Update
BEGIN TRAN
UPDATE CreditLimitRequestInfo SET StatusRequestId = 51012 WHERE CreditLimitRequestInfoId = 198087
--Check (1 row, StatusRequestId = 51012), then COMMIT; anything else ROLLBACK
SELECT StatusRequestId, * FROM CreditLimitRequestInfo WHERE CreditLimitRequestInfoId = 198087
--COMMIT TRAN
--ROLLBACK TRAN
```
74.

###  **Team**

| **Contributors** | @Michael Dela Torre@Ron Paolo Miguel Magpusao |
| --- | --- |
| **Reviewer** | @Julius Serrano |
| **Team** | **Application Support** |

---
