# How to investigate missing contract

Mirror of the Confluence page "How to investigate missing contract".

Last reviewed: 23 September 2026
Sources: Confluence TECHNOLOGY page 942047312, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: TECHNOLOGY · Page id: 942047312 · Last updated: 29 Jan 2025 · Author: Lary Rosario
- URL: https://moneyme1.atlassian.net/wiki/spaces/TECHNOLOGY/pages/942047312/How+to+investigate+missing+contract

Referenced from the Datafix catalogue as the runbook for "contract missing" / "contract not
sent" tickets, which are explicitly *not* a plain datafix.

1. **Check the task tab for an open task named "Review - Contract Sending Failed".**
   - Error detail is in the task notes.
   - Fix the underlying issue first, usually missing data such as address, email or contact.
   - Then use the **Send (Resend) Contract and Close Task** script.
   - A hard to find variant is `Error Message: Value cannot be null. (Parameter 'text')`.
     Usually caused by decryption of the bank account number,
     `security.DecryptAsync(bank.AccountNumberEncrypted)`. Check the bank accounts on the
     application for missing data, fix, then resend. If the banks are fine, check other parts
     of the flow for a decryption step.
2. **Check whether the Azure function is running:** subscription
   `d2c61912-1986-42ce-ae47-24f987ce73aa`, resource group `MoneyMe_New`,
   `Microsoft.Web/sites/azf-contract-generator-prod`.
3. **Check the `ApplicationContract` table** for a created record. There is sometimes a delay;
   check on the Azure function whether the product or brand is already supported on the revamp.

## For PL Broker or other products not yet migrated to the revamp

Check the `Workflow` table for the active workflows, filtered by brand (example below is
MoneyMe, `BrandId = 1`).

```sql
USE Horizon2

DECLARE @appId BIGINT = 0
SELECT ApplicationTypeId, * FROM [Application] WHERE ApplicationId = @appId
-- should be ApplicationTypeId = 87003
SELECT StatusId, ApplicationId FROM PartnershipApplication WHERE ApplicationId = @appId
-- should be PartnerApp.StatusId IN (63006, 63007)
SELECT * FROM ApplicationWorkFlow WHERE WorkFlowId IN (1258, 1259) AND ApplicationId = <appId>
-- no record returned means the workflow did not pick it up.
-- a record here means there was an error while generating the PDF.
-- Get logs from the BGP workflow via Julius, based on date.
```

Find the workflows that generate the loan agreement:

```sql
SELECT * FROM Workflow
WHERE BrandId = 1
AND IsActive = 1
AND CAST(Actions AS NVARCHAR(MAX)) LIKE '%GenerateLoanAgreementDocITextSharp%'
```

Narrow by ApplicationTypeId (87003 for PL Broker), which returns WorkflowIds 1258 and 1259:

```sql
SELECT * FROM Workflow
WHERE BrandId = 1
AND IsActive = 1
AND CAST(Actions AS NVARCHAR(MAX)) LIKE '%GenerateLoanAgreementDocITextSharp%'
AND CriteriaSql LIKE '%87003%'
```

Check whether either workflow ran on the application:

```sql
SELECT * FROM ApplicationWorkFlow
WHERE ApplicationId = <appId> AND WorkFlowId IN (1258, 1259)
```

If nothing returns, get the workflow's own selection query out of the stored procedure:

```sql
EXEC GetWorkFlowApplicationsTest 1259, 100
```

which yields:

```sql
SELECT DISTINCT TOP 100 App.ApplicationId FROM [Application] App
LEFT JOIN ProductType PT ON App.ProductTypeId = PT.ProductTypeId
INNER JOIN PartnershipApplication PartnerApp ON PartnerApp.ApplicationId = App.ApplicationId
INNER JOIN ApplicationStage AppStg ON App.ApplicationId = AppStg.ApplicationId AND AppStg.IsActive = 1
WHERE AppStg.ToStageId = 38
AND App.FundedDate IS NOT NULL
AND DATEDIFF(DAY, App.FundedDate, GETDATE()) < 30
AND (App.IsRefinance IS NULL OR App.IsRefinance <> 1)
AND App.ApplicationTypeId = 87003
AND PartnerApp.StatusId IN (63006, 63007)
AND (PT.[Description] IS NULL OR PT.[Description] <> 'SACC')
AND App.BrandId = 1
AND NOT EXISTS(SELECT 1 FROM ApplicationWorkFlow WITH (NOLOCK)
               WHERE ApplicationId = App.ApplicationId AND WorkFlowId = 1259)
```

Add `AND App.ApplicationId = <appId>` and then comment out the conditions one at a time until
the application appears; that identifies which criterion excluded it. In the worked example the
failing criterion was the funded date window:
`AND DATEDIFF(DAY, App.FundedDate, GETDATE()) < 30`.

To fix, either:
  a. **Adjust the 30 day window in the workflow's CriteriaSql** to cover the account (for
     example 63 days), then move it back to 30 afterwards. **This is the safer option.**
  b. Adjust `Application.FundedDate` so it fits the 30 day window.

For option (a) follow "How to add new workflow" (TECHNOLOGY page 479363489), item 3, Update the
Criteria SQL on the Workflow. Roll the change back after, since only one account is affected.

Last resort: check the logs in the BGP Workflow on the remote server, via Julius, for errors
related to the application.

---
