# Horizon database

The `Horizon2` schema as App Support uses it: the tables we touch, their key columns, the reference value tables, and how an id on screen maps to an id in the database.

Last reviewed: 23 September 2026

Sources: Confluence 3117842457 (Datafix catalogue), 2485059655 (Store Procedures for App Support), 2385150262 (Pending Funding and Refund support), 519602304 (SQL Data Fix scripts), 1398210569 (Common Login SQL Data Fix Scripts), 1079312385 and 1079181314 (Comms and Twilio), 899317845 (App Support Daily Alerts), 942047312 (missing contract), 3131015188 (Cover Runbook); [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 2, 3, 7 and 9; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md).

## Databases

| Database | What lives there |
| --- | --- |
| `Horizon2` | The main application database. Almost every App Support fix targets it |
| `Horizon2_QA` | QA copy (Confluence 426082342) |
| `Payment` | `Payment.dbo.PaymentAccountFunding`, `Payment.dbo.PaymentAccount`, `Payment.dbo.SplitAccount` (Confluence 2385150262, 3117842457) |
| `Communication` | Twilio and comms plumbing: `EventLog`, `Configuration`, `OperatingHours`, `SpecialSchedule`, `CampaignHeader`, `LiveCampaign`, `CampaignDialer`, `HorizonSmsStatusLog` (Confluence 1079181314, 1079312385) |

Scripts that cross databases must qualify the name. `Payment.dbo.SplitAccount` is a different database from `Horizon2`, and item 95 on the SQL catalogue mutates it (Confluence 519602304).

## Spellings that will trip you up

| Written as | Not |
| --- | --- |
| `Amortization` | Amortisation. The table, the Jira project (AMZ) and the Jira text search are all the American spelling. `text ~ "Amortization"` returns 183 issues, `amortisation` returns 11 ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)) |
| `[Transaction].Notes` (plural) | `Note` |
| `Task.Note` (singular) | `Notes` |
| `WrittenOfRemainingPrincipalBalance` | `WrittenOffRemainingPrincipalBalance`. **Both columns exist on `[Transaction]`**, one with the typo and one without (Confluence 519602304, item at lines 2281 to 2292 of the extract). Copy the column list exactly; do not "correct" it |
| `CalculateWithrawalAllocationAll` | `CalculateWithdrawal...`. The misspelling is in the real procedure name |
| `[Transaction]` in brackets | `Transaction`. Reserved word |
| `Canceled` and `Cancelled` | Both exist as Jira status spellings; grep for both ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)) |

---

## Customer and identity

Nothing in the codebase keeps `CustomerEmail`, `CustomerContactNo` and `CustomerAccount.Username` in sync (MHD-35810 / PER-8863). This is the single most common cause of repeat "email updated but comms still wrong" tickets (Confluence 3117842457).

### `Customer`

| Column | Notes |
| --- | --- |
| `CustomerId` | Key |
| `FirstName`, `LastName` | `FirstName LIKE '%wagtest%'` marks a test customer. Every sweep query filters these out |
| `IsTest` | Test flag |
| `IsDonotContact` | DNC. Checked first on any "comms not delivered" ticket |

### `CustomerAccount`

The **login** credential. Keyed on (`Username`, `BrandId`), so MME, OzMoney, SocietyOne and Autopay logins are separate accounts for the same human.

| Column | Notes |
| --- | --- |
| `CustomerAccountId`, `CustomerId`, `BrandId` | |
| `Username`, `Password` | Password is encrypted. Never copy a hash out of the wiki |
| `IsActive` | A deactivated row is the usual cause of "forgot password does nothing" |
| `DateCreated`, `CreatedByUserId` | |
| `LastLoginDate`, `LastLoginIp`, `LastLoginAttemptDate` | Login history is only visible within 7 days (Confluence 3131015188) |
| `IsMobileVerified`, `IsPINChanged` | |

### `CustomerEmail`

The **comms** address. Not the login.

| Column | Notes |
| --- | --- |
| `CustomerEmailId`, `CustomerId`, `BrandId` | One active row per brand is the convention |
| `EmailTypeId` | |
| `EmailAddress` | |
| `IsActive`, `DateCreated` | |

### `CustomerContactNo`

The **SMS** number.

| Column | Notes |
| --- | --- |
| `CustomerContactNoId`, `CustomerId`, `BrandId` | |
| `ContactNoTypeId` | |
| `Number` | |
| `IsActive` | Multiple active mobile numbers for one brand cause the merge tag error. There should be only one active mobile per brand (Confluence 1079312385) |
| `Invalid` | |
| `DateCreated` | |

**Funding depends on these two tables.** Zepto requires contact details at fund submission, and the funding code looks them up in `CustomerContactNo` and `CustomerEmail` **matching on the application's BrandId** (Albert Rick Martires, `#app-support`, 2026-08-13). An APY or SocietyOne application whose contact rows were created under MME will not fund. Fix by inserting a row for the missing brand, not by overwriting: the goal is one email and one contact row surviving per brand (Ron, 2026-09-10). Worked examples: MHD-34560, customer 1025655, customer 2150384, application 10003052950.

### `CustomerBank`

Unused for QA test customers; only `dbo.ApplicationBank` carries the record there (Confluence 426082342).

---

## Application

### `Application`

The central record. Full published column list is on Confluence 3117842457. Columns that matter in support:

| Column | Notes |
| --- | --- |
| `ApplicationId` | 11 digits, `10003xxxxxx` in current ranges |
| `BrandId`, `CustomerId`, `LeadSourceId` | |
| `RequestedAmount`, `OfferedAmount`, `FundedAmount` | |
| `ProductTypeId` | The normal product discriminator |
| `ProductId` | **`111` is CRD and NULL for everything else.** Use `ProductTypeId` for everything else (Rusty, 2026-09-22) |
| `Duration`, `InterestRate` | |
| `StatusId` | See the status register in `horizon.md` |
| `DeclineReasonId`, `FundedDate`, `RepaidDate` | |
| `ArrearsLevelId`, `ArrearsBalance`, `ArrearsBalanceV1`, `ArrearsBalanceV2` | |
| `ContractStartDate`, `ContractEndDate` | The arrears calculation is anchored to the Contract End Date ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 9) |
| `EzidebitAccountId`, `SplitAccountId`, `EwayAccountId`, `DebitCardAccountId` | One per rail. See `payments-and-rails.md` |
| `BrokerFee`, `Commission` | |
| `WriteOffTypeId` | |
| `DisablePaymentSubmission` | Blocks all future payment submission. Carried over wrongly by the CCC to CRD migration (MHD-34668) |
| `DisableArrearsCapture` | |
| `ApplicationTypeId` | `87003` = PL Broker (Confluence 942047312) |
| `VehicleAssetId`, `PartnerUserId`, `ApplicationGUID`, `CRN`, `OriginallySPL` | |
| `sf_*` block | Salesforce mapping columns from the SocietyOne era |

### `ApplicationAddress`, `ApplicationBusiness`

Address and business details. Both are routine datafix targets, for example the ABN Active Since date correction on MHD-34134 (application 10002987390).

### `ApplicationBank`

The bank record funding uses. In QA it holds the bank-feed mock fixture; `AccountNumberEncrypted` holds the account number (Confluence 426082342).

### `ApplicationStage`

Stage history. `ToStageId`, `IsActive`.

### `ApplicationWorkFlow`, `ApplicationWorkFlow2`

Which workflows have run against an application. `ApplicationWorkFlow2` joins `Workflow2`.

### `ApplicationCharge`

Charges. The recurring zero-interest-rate defect lives here (MHD-34728, account 10002996207).

### `ApplicationContract`

Generated contracts. See the missing contract investigation, Confluence 942047312.

### `AdditionalData`

Typed key/value per application or customer.

| `AdditionalDataTypeId` | Meaning |
| --- | --- |
| `8` | Marketing Opt Out Internal |
| `16` | Marketing Opt Out External |
| `32` | Default payment method. `Value = 4` is Default / DC |
| `125` | CRD migration marker. Rows removed when a migration is reversed (Rusty, 2026-07-02, applications 10002935544, 10002906204, 10002922604, 10002927915, 10002930191, 10002936868) |

`AppSupport_UpdateToDefaultPaymentMethod` has **no INSERT path**. If there is no `AdditionalDataTypeId = 32` row at all, the EXEC silently does nothing and a raw INSERT is required (Confluence 3131015188, MHD-35706).

### `PartnershipApplication`

Partner and broker applications. `StatusId IN (63006, 63007)` gates contract generation (Confluence 942047312).

---

## Money

### `[Transaction]`

Reserved word, always bracketed.

| Column | Notes |
| --- | --- |
| `TransactionId` | The id shown on the Horizon transactions page |
| `ApplicationId` | |
| `TransactionStatusId` | `1005` = Cancelled, `1003` = the cleared / processed value used in every insert sample |
| `TransactionTypeId` | See the reference table below |
| `TranAmount`, `TranDate`, `DateSubmitted`, `DateProcessed`, `DateCreated` | |
| `Notes` | **Plural.** Where the MHD number goes |
| `Principal`, `EFee`, `Interest`, `Charge`, `VirtualPrincipal`, `Excess`, `Recoveries` | Allocation buckets |
| `AccountKeepingFee`, `AnnualFee`, `GstFee`, `MerchantFeeAmount`, `AdminFee`, `BrokerFee` | |
| `IsReversed` | Set to 1 on the reversing row |
| `AmortizationId` | Links the transaction to its amortisation row |
| `WrittenOffRemainingPrincipalBalance` and `WrittenOfRemainingPrincipalBalance` | Two columns, one typo, both real |

After any transaction change, run `EXEC UpdateAmounts @AppId` to re-derive account amounts.

### `TransactionHistory`

Shadow history of `[Transaction]`. Backed up and deleted alongside it in write-off reversal scripts (Confluence 519602304, MHD-26144, MHD-20061).

### `Amortization`, `AmortizationHeader`

Note the spelling. Any reversal data fix on `[Transaction]` needs a matching amortisation record or the schedule silently diverges (Tops, `#app-support`, 2026-02-11). September 2026 had a dedicated script for this: `Soft Execution - MHD36494 - Create amort counterpart for Bulk Dishonour Fee Update - Sep2026.sql`.

Cancelling proposed or scheduled amortisation takes two steps, both required (Jess Leal, 2026-06-05):

1. Set the affected amortisation rows to status **35005 (Cancelled)**.
2. Add the note **"Cancel all proposed schedule"** to those rows.

Step 2 is what stops Horizon regenerating them.

`AmortizationHeader` carries `VariationType`, `VariationDate`, `IsOriginal`, `IsDPDHeader`, `Note` (Confluence 519602304).

### `Funding`

| Column | Notes |
| --- | --- |
| `FundingId` | The id passed to every `FundingDataFix*` procedure |
| `ApplicationId`, `TransactionId`, `Amount`, `AccountName` | `TransactionId` unmapped is a known recurring defect |
| `IsCompleted`, `IsSuccessful`, `DateCompleted` | `ISNULL(IsCompleted, 0) = 0` is the sweep predicate |
| `PaymentFundingId` | Joins `Payment.dbo.PaymentAccountFunding.PaymentAccountFundingId` |
| `DateCreated` | |

### `FundingScheduling`

Carries `IsProcessed`. Setting it back to `0` is what lets the funding process pick the record up again. A retry that sets only the payment submission status will look like it worked and will not retry (Confluence 3131015188).

### `FundingActivity`

The real reason a funding attempt failed. The task note still carries generic "safe to close" text for insufficient funds, so open this table before responding to Ops.

### `FundingAppIssue`

Overfunding issues: `ApplicationId`, `Amount`, `ErrorNotes`, `DateCreated`.

### `Disbursement`

Disbursement rows. `DisbursementId` is the argument to `AddCoPAccountWhitelistFromDisbursement`.

### `PATransaction`

Pay Anyone transactions. Cancelled with `PATransactionDataFixUpdateTransaction` using status `67006`.

### `Refund`, `RefundActivity`

`RefundId`, `RefundTaskId` (TaskTypeId 219), `ReviewRefundErrorTaskId` (TaskTypeId 220), `PaymentFundingId`, `IsCompleted`, `IsSuccessful`, `DateCreated`.

### `CommissionBank`

Broker and dealer commission bank details: `CommissionBankId`, `LeadSourceId`, `SortCode`. The leading-space BSB bug lives here (MHD-35359, LeadSourceId 8187).

### `CoPAccountWhitelist`

Confirmation of Payee whitelist. QA only.

### `Payment.dbo.PaymentAccountFunding`

`PaymentAccountFundingId`, `PaymentReference` (form `PB.19ctj7`), `DebitReference`, `DebitStatus`, `CreditReference`, `CreditStatus`, `IsFundingCompleted`, `IsFundingSuccessful`, `DateCompleted`.

### `Payment.dbo.PaymentAccount`

`externalid` holds the Horizon ApplicationId as a string. `paymentaccountid` is a GUID.

### `Payment.dbo.SplitAccount`

Split (Zepto) account records. Referenced as `SA.SplitAccountId`, `SA.AgreementStatus` in the diagnostic queries.

---

## Assets and PPSR

### `vehicleAsset`

PL and SPL vehicle. `VehicleAssetStatusTypeId`, `VehicleStatusDate`. `102005` = Removed.

### `AutopayApplication`

APY equivalent, carries the same two columns, plus `Duration`, `CreditScore`, `RiskBand`.

### `AutopayVehicleDetail`

APY vehicle attributes: plate, VIN, fuel type. Fuel type and EV discount corrections land here (MHD-33222).

### `EdxRegistration`

PPSR registrations: `RegistrationTypeId` (79001 in the published sample), `RegistrationId` (GUID placeholder `00000000-0000-0000-0000-000000000000`, keep as is), `RegistrationNumber`, `Status`, `IsFinalStatus`, `EsisId`, `RegistrationStartDate`, `RegistrationEndDate`, `RegistrationChangeNumber`, `IsDischarged`, `DateDischarged`.

### `EdxSearch`

PPSR searches. Checked when an APY application is stuck.

---

## Tasks, notes, comms and files

### `Task`

| Column | Notes |
| --- | --- |
| `TaskId`, `ApplicationId`, `TaskTypeId` | |
| `[Status]` | The string `'Open'` or `'Closed'`, not an id |
| `IsActive`, `ClosedByUserId`, `DateClosed` | |
| `Note` | **Singular**, unlike `[Transaction].Notes` |

### `Note`

Application notes. Moved between applications by raw UPDATE (MHD-35066).

### `InboundEmail`

Inbound emails. Moved between applications by raw UPDATE.

### `[Message]`

Outbound message log. Queried by ApplicationId: `SELECT TOP 100 * FROM dbo.[Message] WITH (NOLOCK) WHERE ApplicationId = <id>`. The `MessageId` joins `Communication.dbo.HorizonSmsStatusLog`.

### `FileUpload`

Uploaded documents. Deletion via `AppSupport_DeleteFileUpload` is irreversible and has no inverse procedure.

### `CommsMuteRule`

| Column | Notes |
| --- | --- |
| `CriteriaSql` | SQL fragment evaluated per rule with the send's values injected. Returns BIT, `1` = muted |
| `AllowedTemplateSettingsId` | Template ids exempt from that rule |
| `Priority` | **Lower number means higher priority** |
| `BrandId` | `-1` means all brands |
| `IsActive` | |

### `CommsMuteTemplate`

Added for white label credit card comms suppression under HOR-8583 / HOR-8694, released via MHD-36342 (Confluence 3159327598).

### `Workflow`, `Workflow2`, `ApplicationWorkFlow`

Workflow definitions carry `Actions`, `CriteriaSql`, `BrandId`, `IsActive`. Per-application runs live in `ApplicationWorkFlow` / `ApplicationWorkFlow2`.

---

## Scoring and decisioning

### `VedaScore`

`ApplicationId`, `CustomerId`, `Score`, `VersionId`. Veda Score = Comprehensive Score = Version 3. Inserted with `AppSupport_InsertVedaScore` (Confluence 899317845), which is **not** listed on the stored procedure page.

### `EquifaxTransaction`

Identity verification calls. `referenceID` holds the ApplicationId **as a string**; `equifaxTransactionId` is per attempt.

### `Brand`

`BrandId`, `Code`, `Description`. See `brands-products-entities.md`.

### `ProductType`

`ProductTypeId`, `[Description]`. Joined into the funding sweep to label the product.

---

## Reference values

### TransactionStatusId

| Value | Meaning | Confidence |
| --- | --- | --- |
| `1003` | Cleared / processed. Used in every insert and restore sample | Unverified: the value is never named on any page. Confirm against the status lookup table before relying on the label |
| `1005` | Cancelled | Stated (Confluence 2485059655) |

Horizon UI transaction states seen in tickets: Proposed, Pending, Authorised, Cleared, Rejected, Cancelled. Unverified: the full id mapping for Proposed, Pending, Authorised and Rejected is not published anywhere in the sources.

### TransactionTypeId

| Value | Meaning | Source |
| --- | --- | --- |
| `1` | Direct Credit (the type Rusty bulk-uploads) | Rusty, `#app-support`, 2026-09-22 |
| `14` | Used with `TransactionStatusId 1003` to locate the funding / write-off transaction and its `AmortizationId` | Confluence 519602304, MHD-26144 |
| `18`, `28`, `32` | Allocate / reallocate / interest noise spawned by a bulk transaction upload. Remove the Daily Interest, Unallocated Interest and Allocated Interest rows, do **not** touch the Direct Credit row | Rusty, 2026-09-22 |
| `23` | Paired with 14 in write-off reversal backups and deletes | Confluence 519602304 |
| `36` | Reverse | Confluence 519602304, MHD-21177 |
| `83` | Merchant Credit | Confluence 519602304, MHD-21177 |
| `87` | Allocated VirtualPrincipal | Confluence 519602304, MHD-24895 |

CRD should return nothing from the 18/28/32 selector: CRD does not have the same interest adjustment and reallocation processes (Rusty, 2026-09-22). Changing a transaction's type to "refund" is equivalent to cancelling both the original and the refund pair; same outcome either way (Rusty, same thread).

### AmortizationStatusId

| Value | Meaning | Source |
| --- | --- | --- |
| `35005` | Cancelled | Jess Leal, `#app-support`, 2026-06-05 |
| `31003` | Seen set on `AmortizationHeader.AmortizationStatusId` in a published script; meaning not stated | Confluence 519602304. Unverified |

### Funding and refund status ids

| Value | Meaning |
| --- | --- |
| `91001` | Reset. Restarts the funding process from the beginning. The retry value. Does not double fund |
| `91004` | Cancelled / stopped. Used when the application itself was cancelled. Also the status returned with "Your bank account has insufficient funds" |
| `91005` | Mark as funded, when a `PaymentAccountFunding` record already exists |
| `91007` | Where a successful retry lands. Republishes the `FundSentEvent`, which is also how a missing amortisation gets generated |

Sources: Confluence 2385150262, 3131015188, 426082342.

### TaskTypeId

| Value | Meaning |
| --- | --- |
| `65`, `77` | Funding tasks, closed on retry by `AppSupport_DeleteFundingRecords` |
| `65`, `77`, `118`, `176` | The set the funding drill-down checks for open blocking tasks |
| `178` | PPSR / vehicle review task |
| `219` | Refund task |
| `220` | Review refund error task |

### Workflow ids

| Value | Meaning | Source |
| --- | --- | --- |
| `1258`, `1259` | Contract generation, MoneyMe and PL Broker. Keyed on `ToStageId = 38` | Confluence 942047312 |
| `364`, `365`, `1317` | Deleted from `ApplicationWorkFlow` in write-off reversal scripts | Confluence 519602304, MHD-20061 / MHD-26144 |
| `100202` | Updated in a published workflow script; purpose not stated | Confluence 519602304. Unverified |
| `Workflow2` rows `WHERE [Name] LIKE '%write%'` | The write-off workflow family, deleted from `ApplicationWorkFlow2` on reversal | Confluence 519602304 |

### PartnershipApplication statuses

| Value | Meaning |
| --- | --- |
| `63006`, `63007` | The statuses that gate contract generation |

### Other reference values

| Meaning | Value | Source |
| --- | --- | --- |
| Vehicle asset status Removed | `VehicleAssetStatusTypeId = 102005` | 2485059655 |
| PA transaction status used on cancel | `67006` | 3131015188 |
| Payment method Default (DC) | `AdditionalDataTypeId = 32`, `Value = 4` | 2485059655 |
| Access level View | `AccessLevelId = 1` | 2485059655 |
| PPSR registration type in the sample | `RegistrationTypeId = 79001` | 2485059655 |
| PPSR registration GUID placeholder | `00000000-0000-0000-0000-000000000000` | 2485059655 |
| PL Broker application type | `ApplicationTypeId = 87003` | 942047312 |
| CRD product | `ProductId = 111`, NULL for all other products | Rusty, 2026-09-22 |
| Tab ids for AFCA stages | `295` Stages_AFCA_Arrangement, `296` Stages_AFCA_Arrangement_Broken | 2485059655 |
| Twilio line types | `ConfigurationSettingId` `1001` Brand line, `1005` Customer line, `1006` Partner line | 1079181314 |
| Twilio inbound on/off | `SettingId = 1002` in `Communication.Configuration` | 1079181314 |
| Twilio campaign status | `0` live, `1` open, `2` cancelled, `3` completed, `4` closed | 1079181314 |

Treat all reference values as observed in the documentation, not guaranteed current. If a value looks wrong for the case in front of you, verify with a `SELECT` (Confluence 3117842457).

---

## How ids on screen map to ids in the database

| On screen | Column | Note |
| --- | --- | --- |
| Application URL `/Application/Application/10003038152` | `Application.ApplicationId` | 11 digits |
| Task URL `/Task/ApplicationTasks/<id>` | `Task.TaskId` | |
| Notes URL `/Note/ApplicationNotes/<id>` | `Note` rows for that **ApplicationId**, not a NoteId | |
| Comms URL `/Communication/ApplicationComms/<id>` | `[Message]` rows for that ApplicationId | |
| Customer URL `/Customer/CustomerDetails/<id>` | **Ambiguous.** 11 digits, while sample CustomerIds are 6 to 7 digits. Resolve it with a `SELECT` before using it as `@CustomerId` (Confluence 3117842457) | |
| Transaction id on the Transactions tab | `[Transaction].TransactionId` | 8 to 9 digits, for example 109263685 |
| Funding record id in Albert's scripts | `Funding.FundingId` | 7 digits, for example 1533539 |
| Zepto payment reference | `Payment.dbo.PaymentAccountFunding.PaymentReference` | Form `PB.19ctj7` |
| Payment account in the Payment database | `Payment.dbo.PaymentAccount.externalid` | Holds the ApplicationId as a string |
| Equifax reference | `EquifaxTransaction.referenceID` | Holds the ApplicationId as a string |

Resolving the identifier in the ticket is Pass A of the datafix catalogue (Confluence 3117842457, Part 3). Do it before writing anything: Ops send whichever number was on their screen.

---

## Stored procedures

### The `AppSupport_*` family, all on `Horizon2`

Source: Confluence 2485059655.

`AppSupport_UpdateCustomerContactNumber`, `AppSupport_DeleteCustomerContactNumber`, `AppSupport_UpdateCustomerEmail`, `AppSupport_DeleteCustomerEmail`, `AppSupport_MoveAppToCustomer`, `AppSupport_UpdateCustomerAccount`, `AppSupport_DeleteFileUpload`, `AppSupport_InsertCustomerAccount`, `AppSupport_PLRemovePPSR`, `AppSupport_APYRemovePPSR`, `AppSupport_UpdatePPSR`, `AppSupport_UpdateToDefaultPaymentMethod`, `AppSupport_InsertRoleAccess`, `AppSupport_CancelTransaction`, `AppSupport_DeleteFundingRecords`, `AppSupport_InsertApyContactNEmail`.

Also referenced but not on that page: `AppSupport_InsertVedaScore` (Confluence 899317845).

Backout caveat: fifteen of the sixteen take no backup. `AppSupport_DeleteCustomerContactNumber`, `AppSupport_DeleteCustomerEmail` and `AppSupport_DeleteFileUpload` are irreversible deletes with no inverse, and there is **no insert procedure for a BrandId 1 `CustomerEmail` or `CustomerContactNo` row**, so there is no restore path at all. Capture the row with `SELECT *` first ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.10).

`AppSupport_CancelTransaction` moves no money. It only sets `TransactionStatusId = 1005` and writes `@Notes` (Confluence 3117842457).

`AppSupport_DeleteFundingRecords` will **not** create a backup if `@MHDTicket` is empty.

### Funding and refund datafix procedures

Source: Confluence 2385150262.

`FundingDataFixUpdatePaymentSubmissionStatus`, `FundingDataFixUpdateIsProcessed`, `FundingDataFixUpdateTransactionId`, `FundingDataFixUpdatePaymentFundingStatus`, `RefundDataFixUpdateIsProcessed`, `RefundDataFixUpdatePaymentSubmissionStatus`, `PATransactionDataFixUpdateTransaction`, `AddCoPAccountWhitelistFromDisbursement`.

### Engine and utility procedures

`UpdateAmounts` (re-derives account amounts, must be called after transaction changes), `ComputeSlidingLimit`, `CalculateWithrawalAllocationAll` (misspelling is in the real name), `UpdateMinimumPaymentAmount`, `usp_CanCustomerBeContacted`, `GetWorkFlowApplicationsTest`, `EncryptTextNoPWD`, `DecryptTextNoPWD`.

---

## Backup convention

`SELECT * INTO <Table>_MHD<ticket> FROM <Table> WHERE <key> = <value>;` with the hyphen stripped from the ticket number, for example `CustomerEmail_MHD35866`, `fundingactivity_MHD35277`, `Application_MHD12195` (Confluence 3131015188).

Known problem: nobody owns cleanup of these tables. They persist in production, contain full customer rows including encrypted bank account numbers, and have accumulated over three years of monthly datafix tickets ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 1.2).

## Credentials

Several source pages publish live credentials in plain text, including encrypted Horizon staff passwords with the plaintext written next to them in a comment. `[CREDENTIAL REDACTED - Confluence pages 426082342, 519602304, 1398210569, 2485059655]`. Never copy a password or hash out of the wiki into a script, a ticket or this repo. Flag it as a hygiene problem instead (Confluence 3117842457).
