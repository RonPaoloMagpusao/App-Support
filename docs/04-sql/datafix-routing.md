# Datafix routing reference

Symptom to fix routing for production datafixes: what is not a datafix, composite patterns, which stored procedure to use, and which raw scripts are unsafe.

Last reviewed: 23 September 2026
Sources: Confluence AS page 3117842457, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 3117842457 · Last updated: 21 Aug 2026 · Author: Michael Dela Torre
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/3117842457/Datafix+catalogue+symptom+routing+reference

**What this is.** The routing layer between a ticket symptom and the right source, plus the
read only lookup queries that resolve the IDs a fix needs. Used by the MHD Ticket
Investigator agent, and directly useful to a human covering App Support. This page holds no
script bodies; always take those from the live source pages, which change.

## Part 0: Knowledge sources and precedence

Everything lives under SQL Data Fix scripts (page 519602304):

| Page | Holds | Freshness |
| --- | --- | --- |
| Store Procedures for App Support (2485059655) | 16 parameterised `dbo.AppSupport_*` procedures. The safe path. | Aug 2026, current |
| SQL Data Fix scripts (519602304) *(the parent)* | ~97 raw ad hoc fixes keyed to historical MHD tickets. The union set of everything App Support does. | Aug 2026, maintained |
| Common Login SQL Data Fix Scripts (1398210569) | 8 login fixes plus **the login diagnostic query**, which has no procedure equivalent. | Mar 2025, stale but uniquely useful |
| APY / SPL vehicles updates (1397882974) | 4 items: vehicle field corrections and a PPSR insert template. | Mar 2025, stale |
| Incorrect URL ID Fix (1409351844) | `EquifaxTransaction` ID verification link fix, **with a named approval gate**. | Feb 2025 |

**Precedence:**

1. **A stored procedure if one exists.** Parameterised, keyed on both parent and child ID,
   and they fix real bugs present in the raw equivalents. The parent page is mid migration
   toward them; its item 47 already delegates to `AppSupport_MoveAppToCustomer`.
2. **Else the parent page**, the maintained union set.
3. **Else the topic pages**, and read those for diagnostics, symptom narrative and approval
   gates regardless of where the fix comes from.

### Three rules that apply to every source

**Never reuse a literal from these pages.** They are archives: every ApplicationId,
CustomerId, email, plate, VIN and backup table name belongs to a different historical ticket.
Some snippets contain live typos: the Incorrect URL ID page's update variant sets an
ApplicationId one digit longer than its own verification query checks. Take the shape, derive
the values.

**Never copy a password or hash out of the wiki.** Several items embed real hashes and even
plaintext staff passwords (items 44 and 94 on the parent page).
`[CREDENTIAL REDACTED - see Confluence page 519602304]`. Do not repeat them anywhere; flag it
as a hygiene problem instead.

**Add a backup before any EXEC that writes.** The procedures take none, except
`AppSupport_DeleteFundingRecords`. Follow the raw scripts' house convention:
`SELECT * INTO CustomerEmail_MHD35866 FROM CustomerEmail WHERE CustomerId = <CustomerId>;`
Table name suffixed with the ticket, hyphen stripped.

## Part 1: Not a datafix

Check this **before** routing anywhere. A meaningful share of tickets that sound like
datafixes are not, and running an `UPDATE` on production when the real answer was "it's on the
bounce list" is the worst outcome available.

| Symptom | What it usually actually is | Remedy |
| --- | --- | --- |
| "Emails are failing to send" / "not receiving comms", but the address on file is already correct | The address is on the **bounce suppression list** | Remove from the bounces list, ask requester to retry. No SQL. Precedent: MHD-35847 |
| "Can't log in with their email" and the account turns out to be OzMoney / MOM / Autopay | **Brand confusion.** MME, OzMoney and Autopay logins are separate; `CustomerAccount` is keyed on (Username, BrandId) | Tell the requester which portal to use. If they changed their email it must also be changed on an MME application to sync. Precedent: MHD-35866 |
| Wrong template, wrong merge tag, wrong wording in a comms email | Template or code defect | Raise/link a G1 or AMZ ticket. Needs a release |
| Ticket titled `[X - Code Release]` or `[X - Database Release]` | It is a **release ticket**, not an incident | Follow the release process |
| "Contract missing" / "contract not sent" | Multi step investigation with its own runbook | See "How to investigate missing contract", TECHNOLOGY space page 942047312 |
| Something visible and editable in the Horizon UI | An agent can just do it in the front end | Do not reach for SQL when a UI action exists |

If a symptom is in neither Part 1 nor the routing tables, verdict **Unknown**. Escalate rather
than improvise.

## Part 1.5: Recurring composite patterns

### Pattern A: "We updated the email in Horizon but comms still go to the old address"

The most common MHD datafix by volume. Precedents: MHD-35773, MHD-35754, MHD-35641, MHD-35596.

**Tells:** the requester says they already changed it in the UI; the old address still "pops
up" when composing; or the UI threw "Oops, Something went wrong" on save.

There are **three** places the address lives, and nothing in the codebase keeps them in sync,
stated explicitly in MHD-35810 / PER-8863:

| Table | Holds | Fix |
| --- | --- | --- |
| `CustomerEmail` | the comms address | `AppSupport_UpdateCustomerEmail` |
| `CustomerContactNo` | the SMS number | `AppSupport_UpdateCustomerContactNumber` |
| `CustomerAccount.Username` | the **login** credential, keyed on (Username, BrandId) | `AppSupport_UpdateCustomerAccount`: read the Row 6 warning first |

So **always run the Pass A lookups for all three tables**, not just the one the ticket names.
Then look for these three failure shapes:

1. **Leftover active row.** The UI inserted a new `CustomerEmail` row but the old one is still
   `IsActive = 1`, so comms pick the wrong one. Deactivate the stale row, do not just update
   the new one.
2. **Wrong brand.** The new address landed on one `BrandId` and comms read another. Fix the
   row on the brand that is actually sending.
3. **Login left behind.** `CustomerEmail` is correct but `CustomerAccount.Username` still
   holds the old address, so login and passcode reset still fail. *This is why "email updated"
   tickets come back*: MHD-35641 is exactly this.

If the requester mentions passcode reset, login or the mobile app *at all*, treat
`CustomerAccount` as in scope even if they only asked about email.

### Pattern B: Passcode reset / forgot password fails outright

**Symptom:** "Multiple active account found", "Multiple Inactive account found", or reset
silently does nothing.

**Cause:** more than one `CustomerAccount` row shares the same (Username, BrandId). Both
`ChangeCustomerPasscodeAsync` and Web2 forgot password abort on a `Count() != 1` check. Login
reads are non deterministic while duplicates exist, so the customer can even be authenticated
against the wrong row.

**Start with the diagnostic, not a fix.** Common Login SQL Data Fix Scripts item 1 takes one
ApplicationId and returns Application+Brand, every `CustomerAccount` row (with `BrandId`,
`Username`, `IsActive`, `LastLoginDate`, `IsPINChanged`), every `CustomerContactNo` and
`CustomerEmail` row, plus a fuzzy username join that surfaces sibling customers sharing the
email. No stored procedure does this. Run it before deciding anything.

Three sub cases with different fixes:

**B1: Genuine duplicate account for the same customer.** The documented technique is *not* to
delete the loser: it **renames the losing row's username** so the mobile app's credential
lookup can no longer match it. From the parent page item 28:

> If it has a duplicate account, and the duplicate has Credit Score only (from Mar 2024
> backwards), update this duplicate's username (e.g. `testing@gmail.com_duplicate`) so Mobile
> can't get this as the validated creds.

Pick the loser by which row is older or has only a Credit Score. Run it through
`AppSupport_UpdateCustomerAccount` with `@Username = 'x@y.com_duplicate'`, keyed on both
`@CustomerId` and `@CustomerAccountId`, not the raw `UPDATE` on the page, which omits the
`CustomerAccountId` predicate and rewrites every brand row.

**B2: Username ≠ email.** Parent page item 77: "Multiple Inactive account found; the error
shows when the username and the email address are different. Update the Username." Same
procedure, set the username to the real email.

**B3: `wagtest*` or other test customers squatting the username in production.** The
MHD-35810 / PER-8863 shape. It needed a Change Request. **Not** a routine datafix: diagnose
and escalate for a CR.

Note what none of these do: there is no dedupe or merge of the `CustomerAccount` rows
themselves. B1 neutralises the loser by renaming it. If the loans need to end up on one
customer, that is a separate `AppSupport_MoveAppToCustomer` call.

### Pattern C: "Review Funding Follow up: Please check customer contact details"

An Autopay application is missing its `BrandId 5` contact rows. Precedents: MHD-35757,
MHD-35758. Fix is `AppSupport_InsertApyContactNEmail`, copying the values, including
`DateCreated`, from the customer's existing `BrandId 1` rows. Routine, but confirm the
`BrandId 5` rows really are absent first, or you create the duplicate you will be fixing next
week.

### Pattern D: Batch PPSR discharge on repaid loans

Requester supplies a table of ApplicationIds and discharge dates, "unable to do it via the UI
as the loan is repaid". Precedent: MHD-35624.

Split by product: SPL/PL → `AppSupport_PLRemovePPSR`, APY → `AppSupport_APYRemovePPSR`, and
emit **one EXEC block per application**, never a loop. Each needs its own `TaskId` and the
operator's `@ClosedByUserId`.

Note the split: the PPSR procedures handle the *discharge*, and `AppSupport_UpdatePPSR`
handles a *re registration insert*, but neither touches the **vehicle's own fields**. If the
ticket also says the plate or VIN is wrong, that half comes from the vehicles page
(`AutopayVehicleDetail` for APY, `vehicleAsset` for SPL) and has no procedure. A "wrong car on
the loan" ticket usually needs both halves.

### Pattern E: "The ID verification link points at the wrong customer / won't resend"

Reads on a ticket as "can you resend the ID verification link for app 100024xxxxx, it's
pointing at the wrong customer" or "the customer can't complete the ID check". Usually arrives
from the app support Slack channel, APY side, and it **blocks settlement** because ID
verification is a funding gate.

Cause: `EquifaxTransaction` holds MoneyMe's identity verification calls, with the ApplicationId
in `referenceID` (as a string) and `equifaxTransactionId` per attempt. Either the reference was
written with a wrong or truncated ApplicationId, or a stale row exists and Equifax will not
issue a fresh link while it is there.

Two strategies on the Incorrect URL ID Fix page: delete the row so a new link can issue
(default), or repoint `ReferenceId` to keep the existing link. Check `referenceID` for *all*
`equifaxTransactionId` rows first; there may be several to clear.

**This one has a named approval gate.** The page requires approval from **Jeffrey Lu and Jon
Wu**, and says to run it **with assistance from the DB team**. Surface that instead of
presenting a runnable fix. It is the only page in the tree that names approvers.

## Part 2: Stored procedure routing

Prefer these over any raw equivalent.

| # | Symptom keywords | Procedure | Op | Risk |
| --- | --- | --- | --- | --- |
| 1 | update contact number, wrong mobile, new phone number, SMS going to old number | `AppSupport_UpdateCustomerContactNumber` | UPDATE | Low |
| 2 | duplicate mobile, two numbers on file, remove number | `AppSupport_DeleteCustomerContactNumber` | DELETE | High |
| 3 | update email address, comms going to old email, wrong email on file, customer changed email | `AppSupport_UpdateCustomerEmail` | UPDATE | Low |
| 4 | duplicate email, two email addresses, remove email | `AppSupport_DeleteCustomerEmail` | DELETE | High |
| 5 | merge account, transfer application, app under the wrong customer, duplicate customer profile | `AppSupport_MoveAppToCustomer` | UPDATE | Medium |
| 6 | can't log in, wrong login username, portal login, app login, activate/deactivate account, **read the Row 6 warning** | `AppSupport_UpdateCustomerAccount` | UPDATE | Medium |
| 7 | wrong document uploaded, incorrect file, remove attachment | `AppSupport_DeleteFileUpload` | DELETE | High |
| 8 | no portal account, customer has no login, create login | `AppSupport_InsertCustomerAccount` | INSERT | Medium |
| 9 | remove PPSR + PL/SPL, discharge PPSR, vehicle asset status to removed | `AppSupport_PLRemovePPSR` | UPDATE ×3 | High |
| 10 | remove PPSR + APY/Autopay | `AppSupport_APYRemovePPSR` | UPDATE ×3 | High |
| 11 | PPSR missing, re register PPSR, EdxRegistration missing | `AppSupport_UpdatePPSR` | INSERT | High |
| 12 | change to default payment method, set to DC, direct debit default | `AppSupport_UpdateToDefaultPaymentMethod` | UPDATE | Medium |
| 13 | Horizon permission, can't see tab, access denied, AFCA arrangement tab | `AppSupport_InsertRoleAccess` | INSERT | Medium |
| 14 | cancel a transaction **record**, **not** refunds, see warning | `AppSupport_CancelTransaction` | UPDATE | Medium |
| 15 | retry funding, funding stuck, funding failed | `AppSupport_DeleteFundingRecords` | DELETE | High |
| 16 | "Review Funding Follow up: Please check customer contact details", APY missing contact/email | `AppSupport_InsertApyContactNEmail` | INSERT ×2 | Medium |

### Warnings on specific rows

**Row 6: `AppSupport_UpdateCustomerAccount` overwrites everything you pass.** It is a flat
`UPDATE CustomerAccount SET BrandId=…, Username=…, Password=…, IsActive=…` and **no parameter
has a default**. There is no "update just the username" mode. You must supply `@Password`;
omitting or guessing it silently resets the customer's web portal *and* mobile app credential.
`@BrandId` must be the row's real current brand, or the login moves to another brand. The most
damaging procedure in the catalogue to run carelessly.

**Row 6 does not fix passcodes.** There is no passcode column and no passcode procedure.
"Customer can't reset their passcode" is **Pattern B**.

**Rows 2, 4 and 7 are irreversible.** No `@CreateBackup` flag, no inverse. There is *no* insert
procedure for a BrandId 1 `CustomerEmail` or `CustomerContactNo` row;
`AppSupport_InsertApyContactNEmail` hardcodes `BrandId 5`, so it is **not** a restore path.
Capture the full row with `SELECT *` first. Where the goal is just "stop using this address",
prefer row 1 or 3 with `@IsActive = 0`.

**Row 14 moves no money.** It only sets `TransactionStatusId = 1005` and writes `@Notes`. No
refund, reversal, reallocation or reconciliation. If the requester wants money returned, route
to payments/collections.

**Row 11 has no existence check.** `AppSupport_UpdatePPSR` is a bare `INSERT` into
`EdxRegistration` despite its name. Re running duplicates the row.

### Notes

- **9 vs 10**: same shape, different second table. PL/SPL updates `vehicleAsset`; APY updates
  `AutopayApplication`.
- **16**: items 16 and 17 on the source page call the *same* procedure, which writes **both** a
  `CustomerContactNo` and a `CustomerEmail` row at `BrandId 5`. Item 17's heading says "Email"
  only; do not be misled.
- **15**: `@MHDTicket` is concatenated into dynamic DDL to name backup tables, so **strip the
  hyphen**: `'MHD35866'`. A hyphen is an invalid identifier and fails the batch (safely, before
  the DELETEs, but it stalls the fix). Always leave `@CreateBackup = 1`.
- **The procedures do not recalculate balances.** `AppSupport_CancelTransaction` and
  `AppSupport_MoveAppToCustomer` change rows without re deriving amounts; the raw scripts they
  replaced called `EXEC dbo.UpdateAmounts @ApplicationId, 1` afterwards. Include it, or the
  account still looks wrong to the customer.
- **Row 12 fails when the row is absent.** It only `UPDATE`s, and raises "No application found
  for the given ApplicationId" when no `AdditionalData` row exists for `AdditionalDataTypeId =
  32`. On that error, fall back to parent page item 53, which inserts it.
- **Column name trap:** `[Transaction]` has `Notes` (plural); `Task` has `Note` (singular).
- **Item 18 on the source page is empty**: the catalogue is actively being extended.

## Part 2b: Raw script territory

The 16 procedures cover contact details, logins, PPSR removal, files, permissions, transaction
cancellation and funding retry. **Everything below has no procedure**; it lives only as raw SQL
on the parent page (519602304). Item numbers are that page's numbering.

| Symptom cluster (requester's words) | Items |
| --- | --- |
| "Payment received but not showing / not allocated", "merchant credit not applied", "available balance wrong" | 4, 67, 68, 73 |
| "Direct debit taken in error", "payment needs reversing", "double payment", "duplicate transaction" | 13, 38, 63, 68 |
| "Account written off in error", "write-off needs reversing", "DPD wrong after write-off" | 14, 15, 33 |
| "Pending PayAnyone transfer stuck, cancel it" | 62 |
| "Freestyle / EML card transaction status wrong", "money missing from Freestyle balance" | 54, 61 |
| "Duplicate repayment schedules on LOC", "minimum payment wrong" | 8, 21, 22 |
| "Hold interest for the hardship period" | 40 |
| "Contract needs resending" | 34 |
| "Offer / requested amount wrong", "loan term wrong on contract" | 5, 11, 16, 69 |
| "Credit limit / available limit wrong" | 9 |
| "Broker commission / broker fee / establishment fee wrong", "commission paid to wrong bank" | 10, 23, 93, 96 |
| "Wrong bank account on the loan", "direct debit hitting the wrong account", "remove dealership bank details" | 3, 85, 98 |
| "Declined for bank statements, customer wants to resubmit / reopen" | 7, 18, 41, 71 |
| "Wrong address / business address / ABN date / entity name on the contract" | 19, 20, 43, 48, 89 |
| "Remove arrears level M0–M3", "arrears showing incorrectly" | 26 |
| "Loan repaid date wrong", "account showing closed incorrectly" | 70, 92 |
| "Wrong rego plate / VIN / vehicle on the loan" (APY and SPL) | 12, 37, 45, 97, and the vehicles page |
| "PPSR not registered", "vehicle still encumbered" | 37, 79, 82 |
| "ID verification link points at the wrong customer / won't resend" | 59, and the URL ID page (approval gate) |
| "Note / email on the wrong account", "email not in the comms tab", "put the email back in the tray" | 30, 32, 57, 60, 66, 74 |
| "Complaint not linked to the account" (IDR / AFCA) | 75 |
| "Can't cancel the application", "app stuck in the wrong stage", "workflow didn't fire" | 64, 87, 88 |
| "Error when accepting the offer" (missing PayFrequency) | 65 |
| "Merge tag / email template showing the wrong value" | 46, 89, 90 |
| "Wrong lead source / referrer / risk band / product type on an APY app" | 49, 71, 80 |
| "Wrong broker on the application" | 39 |
| "Split / direct debit account failed to create", "duplicate Split agreement" | 81, 84, 95 |
| "Staff locked out of Horizon", "no partnership portal access", "missing permission" | 44, 72, 76, 94 |
| "Blacklist a car dealership" | 78 |

### Diagnostics worth knowing

| Purpose | Where |
| --- | --- |
| **Login / account investigation**: one ApplicationId in; Application+Brand, all `CustomerAccount`, `CustomerContactNo`, `CustomerEmail` rows and a fuzzy username join out | Login page item 1, the single most useful diagnostic in the tree |
| Login audit | Parent items 29, 51 |
| Decrypt a stored password (investigation only) | Parent item 91 |
| EML / Freestyle state | Parent item 54 |
| EWAY | Parent item 58 |
| Stuck APY / EdxSearch | Parent item 79 |
| Funded loans with no direct debit account | Parent item 84 |
| Workflow by template | Parent item 90 |
| Vehicle record from an ApplicationId | Vehicles page item 4 |

### Raw script landmines

The parent page is an archive being migrated. Roughly six of ~97 items use an explicit
transaction; the rest are `SELECT * INTO` then a bare `UPDATE`/`DELETE`, so a mis scoped
`WHERE` is permanent the moment it runs. Wrap anything you hand over in `BEGIN TRAN` with the
`COMMIT` left commented.

**Item 14 is broken, always use item 15 instead.** "Reverse Write Off" deletes across five
tables in a `WHILE` loop with no transaction and references an undeclared variable, so the
batch fails *after* the deletes have committed. Item 15 ("Reverse Writeoff V2") is the
corrected rewrite, but it ships with `COMMIT;` uncommented against its own comment, so
re comment it before handing it over.

- **Item 82** has `AND IsDischarged = 0 OR IsDischarged IS NULL` unparenthesised, so the backup
  `SELECT` scoops rows from other applications. Prefer the PPSR procedures.
- **Items 5, 35 and login page item 5** do `UPDATE CustomerAccount … WHERE CustomerId = x` with
  no `CustomerAccountId`, rewriting every brand row for that customer. Exactly the bug
  `AppSupport_UpdateCustomerAccount` was written to fix.
- **Item 96** declares the same `SELECT * INTO` backup name twice, so the second throws and the
  write proceeds unbacked. Its verification comments also disagree with the values the code sets.
- **Item 66** nulls `ApplicationId` on `InboundEmail` rows with no backup at all.
- **Item 17** is not valid T-SQL as published.
- **Item 95** mutates a second database (`Payment.dbo.SplitAccount`).
- **Item 85** is explicitly interim, "while dev fix is not yet released". Check whether the
  release has landed.
- **Vehicles page item 3** compares an unquoted numeric literal to the varchar `VIN` column.
  Quote it.

## Part 3: Pass A lookup queries

Run these first to resolve the IDs a fix needs. `SELECT` only, so safe against production.

### Resolve the identifier in the ticket

Tickets carry a Horizon URL, and **which ID it is depends on the path**.

`/Application/Application/<id>`, `/Note/ApplicationNotes/<id>`, `/Task/ApplicationTasks/<id>`,
`/Communication/ApplicationComms/<id>` → **ApplicationId**:

```sql
USE Horizon2;
SELECT ApplicationId, CustomerId
FROM [Application]
WHERE ApplicationId = <ApplicationId from ticket>;
```

`/Customer/CustomerDetails/<id>` → **ambiguous.** The number is 11 digits, the same shape as an
ApplicationId, while `CustomerId` values in the page samples are 6 to 7 digits. Do **not** pass
it straight in as `@CustomerId`. Test it:

```sql
USE Horizon2;
-- Is it an ApplicationId?
SELECT ApplicationId, CustomerId FROM [Application] WHERE ApplicationId = <id from URL>;
-- Or is it genuinely a CustomerId?
SELECT CustomerId FROM CustomerEmail WHERE CustomerId = <id from URL>;
```

Whichever returns a row settles it. If neither does, read the CustomerId off the Horizon
screen; guessing contaminates every downstream parameter.

### Email rows, procedures 3, 4

```sql
USE Horizon2;
SELECT CustomerEmailId, CustomerId, BrandId, EmailTypeId, EmailAddress, IsActive, DateCreated
FROM CustomerEmail
WHERE CustomerId = <CustomerId>
ORDER BY BrandId, IsActive DESC, DateCreated DESC;
```

Read off the `CustomerEmailId` of the row to change, plus the **current** `EmailAddress`, that
is the backout value. Watch for more than one active row, and rows on a different `BrandId`
than the complaint.

### Contact number rows, procedures 1, 2

```sql
USE Horizon2;
SELECT CustomerContactNoId, CustomerId, BrandId, ContactNoTypeId, Number, IsActive, DateCreated
FROM CustomerContactNo
WHERE CustomerId = <CustomerId>
ORDER BY BrandId, IsActive DESC, DateCreated DESC;
```

### Login account rows, procedures 6, 8

Prefer the login page's item 1 diagnostic, which does all of this from an ApplicationId. If you
only have a CustomerId:

```sql
USE Horizon2;
SELECT CustomerAccountId, CustomerId, BrandId, Username, IsActive, DateCreated
FROM CustomerAccount
WHERE CustomerId = <CustomerId>;

-- Is the username contested across the brand? This is what breaks forgot-password.
SELECT CustomerAccountId, CustomerId, BrandId, Username, IsActive
FROM CustomerAccount
WHERE Username = '<username/email>';
```

More than one row for the same (Username, BrandId) is the bug, not the fix. `wagtest*` or other
test customers holding the username is the MHD-35810 pattern.

**Never print, log or comment a `Password` value**, which is why it is not in the SELECT. But
note the consequence: `AppSupport_UpdateCustomerAccount` *requires* `@Password` and overwrites
it, and Pass A cannot supply it. The operator must read the existing encrypted value in their
own session and fill it in themselves.

### APY BrandId 5 gap, procedure 16

```sql
USE Horizon2;
SELECT CustomerEmailId, BrandId, EmailTypeId, EmailAddress, IsActive, DateCreated
FROM CustomerEmail      WHERE CustomerId = <CustomerId>;
SELECT CustomerContactNoId, BrandId, ContactNoTypeId, Number, IsActive, DateCreated
FROM CustomerContactNo  WHERE CustomerId = <CustomerId>;
```

Confirm `BrandId 1` rows exist and `BrandId 5` rows do not, then copy the `BrandId 1` values,
including `DateCreated`, into the EXEC.

### Uploaded file, procedure 7

```sql
USE Horizon2;
SELECT * FROM FileUpload WHERE ApplicationId = <ApplicationId>;
```

Identify the wrong file positively before deleting, and **keep the full output**: the delete is
irreversible and this is the only record of what was there.

### Transaction, procedure 14

```sql
USE Horizon2;
SELECT TransactionId, ApplicationId, TransactionStatusId, TranAmount, TranDate, Notes
FROM [Transaction]
WHERE ApplicationId = <ApplicationId>
ORDER BY TranDate DESC;
```

Cancelled status is `1005`. Record the current `TransactionStatusId` for backout, and remember
to pair the fix with `EXEC dbo.UpdateAmounts @ApplicationId, 1`.

### Open task and PPSR state, procedures 9, 10

```sql
USE Horizon2;
SELECT TaskId, ApplicationId, TaskTypeId, [Status], IsActive
FROM Task
WHERE ApplicationId = <ApplicationId> AND [Status] = 'Open' AND TaskTypeId = 178;

SELECT ApplicationId, IsDischarged, DateDischarged FROM EdxRegistration WHERE ApplicationId = <ApplicationId>;
-- PL/SPL:
SELECT VehicleAssetStatusTypeId, VehicleStatusDate FROM vehicleAsset       WHERE ApplicationId = <ApplicationId>;
-- APY:
SELECT VehicleAssetStatusTypeId, VehicleStatusDate FROM AutopayApplication WHERE ApplicationId = <ApplicationId>;
```

Both procedures also need `@ClosedByUserId`, the Horizon user id of the person doing the fix.
No query resolves it; use your own rather than copying the samples.
`VehicleAssetStatusTypeId 102005` = Removed.

### Funding records, procedure 15

```sql
USE Horizon2;
SELECT * FROM funding            WHERE applicationid = <ApplicationId>;
SELECT * FROM fundingscheduling  WHERE applicationid = <ApplicationId>;
SELECT * FROM fundingactivity    WHERE applicationid = <ApplicationId>;
SELECT TaskId, TaskTypeId, [Status], IsActive FROM dbo.Task
WHERE ApplicationId = <ApplicationId> AND TaskTypeId IN (65, 77) AND IsActive = 1;
```

### Roles, tabs, permissions, procedure 13

```sql
USE Horizon2;
SELECT * FROM webpages_Roles ORDER BY RoleId;
SELECT * FROM Tab WHERE TabId IN (<TabIds>);
SELECT * FROM RoleAccess WHERE RoleId IN (<RoleIds>);
```

Known: `TabId 295` = Stages_AFCA_Arrangement, `296` = Stages_AFCA_Arrangement_Broken,
`AccessLevelId 1` = View.

### Payment method, procedure 12

```sql
USE Horizon2;
SELECT ApplicationId, AdditionalDataTypeId, Value
FROM [AdditionalData]
WHERE ApplicationId = <ApplicationId> AND AdditionalDataTypeId = 32;
```

`Value = 4` is the Default (DC) payment method. If no row comes back, the procedure will fail;
use parent page item 53 to insert it.

## Part 4: Reference values

| Meaning | Value |
| --- | --- |
| BrandId, MoneyMe *(inference: samples show `@BrandId = 1` but never name brand 1)* | `1` |
| BrandId: Autopay (APY) | `5` |
| Vehicle asset status: Removed | `VehicleAssetStatusTypeId = 102005` |
| Transaction status: Cancelled | `TransactionStatusId = 1005` |
| PPSR / vehicle review task type | `TaskTypeId = 178` |
| Funding task types closed on retry | `TaskTypeId IN (65, 77)` |
| Payment method: Default (DC) | `AdditionalDataTypeId = 32`, `Value = 4` |
| Access level: View | `AccessLevelId = 1` |
| PPSR registration GUID placeholder | `'00000000-0000-0000-0000-000000000000'` (keep as is) |
| PPSR registration type (fixed in page sample) | `RegistrationTypeId = 79001` |

Treat all of Part 4 as observed in the doc, not guaranteed current. If a value looks wrong for
the case in front of you, verify with a `SELECT`.

---
