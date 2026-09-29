# Pending Funding and Refund support

Mirror of the Confluence page "Pending Funding and Refund support".

Last reviewed: 23 September 2026
Sources: Confluence AS page 2385150262, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 2385150262 · Last updated: 26 Aug 2026 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/2385150262/Pending+Funding+and+Refund+support

**What this page is.** The sweep queries for finding stuck funding and refunds, plus the data
fixes for each cause. The triage section is the part to read first: a good share of "the app
is stuck funding" reports need **no data fix at all**.

Source for the triage notes: working thread with **Albert Rick Martires** (G3 Engineering),
who owns the Payment API and funding path.

## How disbursement funding actually runs

- **First disbursement:** validate (raise a task if it fails) → fund to Zepto → generate
  amortisation → create money out → **move to Fund Sent**
- **Every disbursement after that:** validate (raise a task if it fails) → fund to Zepto

An application can legitimately sit at **Fund Sent with a later disbursement still unfunded**,
held by a validation task. That is the designed flow, not a defect.

## Triage, check these before writing a data fix

### 1. Task note says "Float account reached set limit of 400,000.00" → safe to retry, no data fix

One of the biggest single sources of "stuck funding" reports; has not needed a data fix since
August 2026. A long standing Payment API validation rule caps the amount funded per 5 minutes
per product; for APY that is $400,000. When an application hits the cap the validation message
comes back and a task is raised. **The payment never reached Zepto**, so nothing is half done.
Retry it. Volume is rising as application volume rises.

### 2. PayAnyone stuck at Authorized instead of Cleared (CRD) → close the task, do not data fix

An earlier PayAnyone failed and raised a funding failed / funding follow up task. The customer
retried and that attempt succeeded, but a condition in funding blocks completion while the old
task is still open. Close the open task at
`horizon.moneyme.com.au/Task/ApplicationTasks/<id>`. The drill down query's
`TaskTypeId IN (65, 77, 118, 176) AND [Status] = 'Open'` block is exactly what surfaces this.
Permanent fix: API-6134.

### 3. Already funded in Zepto but the stage never moved → move the stage, do not re-fund

Check Zepto first. If the funded date and contract end date are both present, the money has
gone. Move the application to **Fund Sent** (Jamie does the stage move). One recurring variant
will not go through until the customer has a **brand id 5 contact and email**.

### 4. Invalid Funding BSB, two different messages, two different responses

`Invalid Funding BSB Format. [ 033089]`, note the leading space. The SortCode was saved with a
space in it and will keep re raising the funding follow up until fixed:

```sql
SELECT CommissionBankId, LeadSourceId, SortCode
FROM Horizon2.dbo.CommissionBank
WHERE LeadSourceId = 8187;
```

Strip the space, then ask Ops to complete the outstanding task.

`Invalid Funding BSB (Returned by Third Party AusPayNet) | Sort Code: 201086`, genuinely
invalid at AusPayNet. Not a data fix.

### 5. Insufficient funds → check FundingActivity for the real cause

The task notes still carry the generic "safe to close" text, so the actual reason is only
visible in `FundingActivity`.

## Funding status IDs

| ID | Meaning |
| --- | --- |
| `91001` | Reset. Restarts the funding process from the beginning. This is the retry value. |
| `91004` | Cancelled / stopped. Used when the application itself was cancelled. |
| `91005` | Mark as funded. Use when a PaymentAccountFunding record already exists. |
| `91007` | Where a successful retry lands. Republishes the FundSentEvent. |

## Sweep query, applications with pending funding

```sql
SELECT A.BrandId,
P.ProductTypeId,
P.[Description],
C.FirstName,
C.LastName,
F.*,
FS.IsProcessed,
PAF.PaymentReference,
PAF.DebitReference,
PAF.DebitStatus,
PAF.CreditReference,
PAF.CreditStatus,
PAF.IsFundingCompleted,
PAF.IsFundingSuccessful,
PAF.DateCompleted
FROM Horizon2.dbo.Funding F WITH (NOLOCK)
    INNER JOIN Horizon2.dbo.Application A WITH (NOLOCK) ON F.ApplicationId = A.ApplicationId
    INNER JOIN Horizon2.dbo.ProductType P WITH (NOLOCK) ON P.ProductTypeId = A.ProductTypeId
    INNER JOIN Horizon2.dbo.Customer C WITH (NOLOCK) ON A.CustomerId = C.CustomerId
    LEFT JOIN Horizon2.dbo.FundingScheduling FS WITH (NOLOCK) ON F.FundingId = FS.FundingId
    LEFT JOIN Payment.dbo.PaymentAccountFunding PAF WITH (NOLOCK) ON F.PaymentFundingId = PAF.PaymentAccountFundingId
WHERE F.DateCreated >= '2023-07-01'
    AND (C.FirstName NOT LIKE '%wagtest%')
    AND ISNULL(F.IsCompleted, 0) = 0
    AND F.DateCreated <= DATEADD(MINUTE, -20, GETDATE())
ORDER BY P.Description, F.DateCreated DESC
```

## Drill-down, check one application from the sweep

```sql
DECLARE @AppId BIGINT = 10002474210

SELECT TOP 10 * FROM Horizon2.dbo.Funding
WHERE ApplicationId = @AppId ORDER BY DateCreated DESC

SELECT TOP 10 * FROM Horizon2.dbo.FundingScheduling
WHERE ApplicationId = @AppId ORDER BY DateCreated DESC

SELECT * FROM Horizon2.dbo.FundingActivity
WHERE ApplicationId = @AppId ORDER BY DateCreated DESC

IF (EXISTS (SELECT 1 FROM horizon2.dbo.disbursement WHERE applicationid = @AppId))
BEGIN
    SELECT * FROM horizon2.dbo.disbursement WHERE applicationid = @AppId
END

IF (EXISTS(SELECT 1 FROM Horizon2.dbo.PATransaction WHERE ApplicationId = @AppId))
BEGIN
    SELECT * FROM Horizon2.dbo.PATransaction WHERE ApplicationId = @AppId
END

IF (EXISTS(SELECT * FROM Horizon2.dbo.Task WHERE ApplicationId = @AppId AND TaskTypeId IN (65, 77, 118, 176) AND [Status] = 'Open'))
BEGIN
    SELECT * FROM Horizon2.dbo.Task
    WHERE ApplicationId = @AppId
    AND TaskTypeId IN (65, 77, 118, 176)
    AND [Status] = 'Open'
END

-- SELECT * FROM payment.dbo.paymentaccountfunding WHERE paymentreference = 'PB.xxxxxx'
```

## Funding data fixes

### Retry funding, the default fix

```sql
-- if NOT funded in zepto: reset DateSubmitted and PaymentFundingId
DECLARE @ApplicationId BIGINT = 10003035734;
DECLARE @FundingId     BIGINT = 1517941;
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@ApplicationId AS NVARCHAR(20)), ' - Retry Funding');
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentSubmissionStatus] @ApplicationId, @FundingId, 91001, NULL, NULL, @Notes;
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] @ApplicationId, @FundingId, 0
```

**It will not double fund.** Setting the status to `91001` restarts the process from the
beginning; it moves back to `91007` and republishes the FundSentEvent. That republish is also
how a **missing amortisation** gets generated.

**Space bulk runs 5 minutes apart** so you do not re trip the float account limit (MHD-35294).
On long lists, run in batches of 10 with an interval between batches.

### Already funded in Zepto with a PaymentAccountFunding record, mark it funded

```sql
DECLARE @ApplicationId BIGINT = 10002686038;
DECLARE @FundingId BIGINT = 1435022;
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@ApplicationId AS NVARCHAR(20)), ' - FundTransferDone');
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentSubmissionStatus] @ApplicationId, @FundingId, 91005, '2025-11-28 08:52:02.153', 'C61F05DB-C084-45B3-BCAB-07FA1A699BB3', @Notes
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] @ApplicationId, @FundingId, 1
```

### No TransactionId mapped to the Funding record

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateTransactionId] 10003029182, 1516235, 108844212
```

Arguments are `ApplicationId, FundingId, TransactionId`. Samples: MHD-35904 (29 records),
MHD-35207.

### Application cancelled but funding still live

```sql
DECLARE @datecompleted DATETIME = GETDATE()
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentFundingStatus]
     10002964942, 1501936, 91004, 1, 0, @datecompleted,
     'Application: 10002964942 - Application is cancelled',
     'Application: 10002964942 - Application is cancelled'
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10002964942, 1501936, 1
```

### IsProcessed stuck on FundingScheduling for a single disbursement

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10003031096, 1516542, 0
```

### Delete funding records, last resort

```sql
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10000000000,
    @MHDTicket     = 'MHD-00000',  -- backup will NOT run if this is empty
    @CreateBackup  = 1,
    @CloseTask     = 1;
```

Ask Albert before deleting. Always pass `@MHDTicket`; the backup tables are named after it and
the procedure errors without it.

### Funded but no PaymentAccountFunding record

```sql
-- Sample for PL/SPL/APY, MHD-28180
SELECT * FROM payment.dbo.paymentaccount WHERE externalid = '10001172258'
SELECT * FROM payment.dbo.paymentaccountfunding
WHERE paymentaccountid = '2AC066FE-88BF-4310-A43F-AECAC5BB6DAD' AND PaymentReference = 'PB.19jm2q'
```

### QA only: whitelist a test account past Zepto CoP validation

```sql
DECLARE @id BIGINT;
EXEC dbo.AddCoPAccountWhitelistFromDisbursement
     @DisbursementId  = 19136,
     @CreatedByUserId = 1,
     @Description     = 'MME QA Test Account to Whitelist',
     @CoPAccountWhitelistId = @id OUTPUT;
SELECT * FROM dbo.CoPAccountWhitelist WHERE CoPAccountWhitelistId = @id;
```

## Sweep query, applications with pending Refund

```sql
SELECT R.*
FROM Horizon2.dbo.Refund R WITH (NOLOCK)
INNER JOIN Horizon2.dbo.Task T WITH (NOLOCK) ON T.TaskId = R.RefundTaskId
INNER JOIN Horizon2.dbo.Application A WITH (NOLOCK) ON R.ApplicationId = A.ApplicationId
INNER JOIN Horizon2.dbo.Customer C WITH (NOLOCK) ON A.CustomerId = C.CustomerId
LEFT JOIN Horizon2.dbo.Task ET WITH (NOLOCK) ON R.ReviewRefundErrorTaskId = ET.TaskId AND ET.TaskTypeId = 220
LEFT JOIN Payment.dbo.PaymentAccountFunding PAF WITH (NOLOCK) ON R.PaymentFundingId = PAF.PaymentAccountFundingId
WHERE R.IsCompleted = 0 AND R.IsSuccessful = 0
AND R.DateCreated <= DATEADD(MINUTE, -30, GETDATE())
AND (C.FirstName NOT LIKE '%wagtest%')
AND T.TaskTypeId = 219
AND T.Status = 'Open'
ORDER BY R.DateCreated DESC

SELECT * FROM payment.dbo.paymentaccountfunding WHERE paymentreference = 'PB.19ctj7'

SELECT * FROM horizon2.dbo.refundactivity WHERE refundid = 25389 ORDER BY datecreated DESC
```

## Refund data fixes

**Funded in Zepto, PaymentAccountFunding exists, but the Refund table was not updated:**

```sql
DECLARE @AppId BIGINT = 10001985427
DECLARE @RefundId BIGINT = 25362
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@AppId AS NVARCHAR(20)), ' - RefundFundTransferDone');
EXEC Horizon2.[dbo].[RefundDataFixUpdateIsProcessed] @AppId, @RefundId, 1
EXEC [Horizon2].[dbo].[RefundDataFixUpdatePaymentSubmissionStatus] @AppId, @RefundId, 91005, '2025-11-27 08:52:05.247', '340FD10D-C901-4865-B129-A61CA7E8923C', @Notes
```

**Not funded in Zepto, error in the Payment API, reset to retry:**

```sql
DECLARE @AppId BIGINT = 10002674557
DECLARE @RefundId BIGINT = 25389
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@AppId AS NVARCHAR(20)), ' - RefundFundTransferDone');
EXEC [Horizon2].[dbo].[RefundDataFixUpdatePaymentSubmissionStatus] @AppId, @RefundId, 91001, NULL, NULL, @Notes
```

**Funded in Zepto but no data in the PaymentAccountFunding table:** see MHD-28180 attachments
DataFix-MHD-28180-*.sql.

Refund task types: `TaskTypeId 219` = refund task, `TaskTypeId 220` = review refund error task.

---
