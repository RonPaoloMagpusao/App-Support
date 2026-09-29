# Customer and company data

Contact details that will not stick, per-brand record gaps, merges, ABN and entity corrections, and vehicle, PPSR and ID verification records.

Last reviewed: 23 September 2026
Sources: Confluence 3117842457 Parts 1.5, 2, 2b, 3, Confluence 3131015188 sections 02, 07, 09, Confluence 2485059655, MHD issue catalogue theme 4, tribal knowledge (Slack) section 3.1

The largest single stream of datafixes (MHD issue catalogue theme 4). "Email updated in Horizon but
comms still go to the old address" is the most common MHD datafix by volume
(Confluence 3117842457 Pattern A).

## Symptoms

- "Old Email Still Pop Up after updating with new one"
- "Email reverting to old email address"
- "Unable to edit contact details on Customer tab for specific record"
- "Oops, Something went wrong" when saving the Customer tab
- "Insert BrandId 5 contact and email to <app id>"
- "Review Funding Follow up: Please check customer contact details"
- "Request to remove the mobile number as the number belongs to someone else"
- "Please update the ABN Active Since date to 08 Jun 2022"
- "Wrong address / business address / entity name on the contract"
- "Merge duplicate accounts" / "app under the wrong customer"
- "Note / email on the wrong account" / "email not in the comms tab"
- "Updating the VIN on one application incorrectly updates the others"
- "Wrong rego plate / VIN / vehicle on the loan"
- "Update fuel type" / "remove EV discount"
- "Please fix the seller details on this application"
- "Discharge PPSR on these repaid loans, unable to do it via the UI"
- "Resend the ID verification link, it's pointing at the wrong customer"
- "Wrong bank account on the loan"

## Triage, in order

1. **Resolve the identifier in the ticket before anything else.** Which ID a Horizon URL carries
   depends on the path. `/Application/Application/<id>`, `/Note/ApplicationNotes/<id>`,
   `/Task/ApplicationTasks/<id>` and `/Communication/ApplicationComms/<id>` carry an
   **ApplicationId**. `/Customer/CustomerDetails/<id>` is **ambiguous**: the number is 11 digits,
   the same shape as an ApplicationId, while real `CustomerId` values are 6 to 7 digits. Test it
   against `[Application]` and `CustomerEmail` before passing it anywhere as `@CustomerId`
   (Confluence 3117842457 Part 3).
2. **Is there a UI action?** Something visible and editable in Horizon should be done by the agent
   in the front end. Do not reach for SQL when a UI action exists (Confluence 3117842457 Part 1).
   The exception: Horizon will not persist edits to asset and seller fields past a certain
   application stage, which is why those become datafixes (MHD-35191).
3. **For any contact change, run the Pass A lookups for all three tables**, not just the one the
   ticket names. The address lives in `CustomerEmail` (comms), `CustomerContactNo` (SMS) and
   `CustomerAccount.Username` (login, keyed on Username and BrandId), and nothing in the codebase
   keeps them in sync (MHD-35810, PER-8863). Order by `BrandId, IsActive DESC, DateCreated DESC`
   and look at **every brand's row**, not just the active one.
4. **Look for the three failure shapes** (Confluence 3117842457 Pattern A):
   1. Leftover active row: the UI inserted a new `CustomerEmail` row and the old one is still
      `IsActive = 1`.
   2. Wrong brand: the new address landed on one `BrandId` and comms read another.
   3. Login left behind: `CustomerEmail` is correct but `CustomerAccount.Username` still holds the
      old address. If the requester mentions passcode reset, login or the mobile app at all, treat
      `CustomerAccount` as in scope. See
      [login-passcode-and-account-access.md](login-passcode-and-account-access.md).
5. **For an APY or S1 funding blocker, confirm the BrandId 5 rows are really absent.** Confirm
   BrandId 1 rows exist and BrandId 5 rows do not, or you create the duplicate you will be fixing
   next week (Confluence 3117842457 Pattern C).
6. **For a VIN change spreading across applications**, query `AutopayVehicleDetail` by VIN and
   `AutopayApplication` by `AutopayVehicleDetailId`, and check PPSRs and loan agreements for the
   individual VINs (MHD-36240).
7. **Read the request body carefully.** MHD-35191 arrived with its fields transposed, an email
   address in the Mobile field and a phone number in the Email field. Working it from the text
   alone writes the email into the mobile column.

## Root causes seen

1. **Per-brand contact desync.** MHD-36009, application 10003012512: *"the old address was still
   held on the customer's SocietyOne (SOC) brand contact record, the update was applied to the
   MoneyMe and OzMoney records but not SOC."*
2. **Missing brand contact row entirely.** Funding looks contact details up in `CustomerContactNo`
   and `CustomerEmail` matching on BrandId, and Zepto requires them at fund submission. Seen
   repeatedly for APY applications whose contact rows are set up under MME (Albert Rick, 2026-08-13;
   MHD-35757, MHD-35758, MHD-34560).
3. **Unvalidated free-text entry.** A mobile keyed against the wrong customer (MHD-35960).
4. **ABR cancellation resetting the Active Since date.** A brief ABR cancellation resets it; on
   MHD-34134 the ABN was cancelled for only four days in May 2026. There is no self-service re-sync,
   so every correction becomes a manual datafix (MHD-34134, MHD-34459, MHD-34022).
5. **Duplicate customer records.** Horizon creates a new customer record instead of matching the
   existing one at application time (MHD-34750).
6. **Shared foreign key across applications.** MHD-36240: three funded Autopay applications
   (10002846570, 10002847296, 10002846116) all pointed at `AutopayVehicleDetailId` 233752, so
   editing the VIN on one changed all of them. A fourth, 10002851749, was also attached. Correct IDs
   were 247005, 234651 and 234467, and two duplicate rows held the same VIN. Traced back to datafixes
   performed during the **April 2026 Glass Guide outage**. PPSRs and loan agreements still held the
   correct individual VINs, which is how it was confirmed as a Horizon-side data problem and not a
   contract problem.
7. **Stale or wrong `EquifaxTransaction` reference.** The ApplicationId sits in `referenceID` as a
   string, one row per `equifaxTransactionId`. Either it was written wrong or truncated, or a stale
   row exists and Equifax will not issue a fresh link while it is there. ID verification is a
   funding gate, so this **blocks settlement** (Confluence 3117842457 Pattern E).

## The fix

All of these are **datafixes** under the current monthly umbrella ticket unless stated. Backup
convention first: `SELECT * INTO CustomerEmail_MHD35866 FROM CustomerEmail WHERE CustomerId = <CustomerId>;`,
table name suffixed with the ticket, hyphen stripped (Confluence 3117842457). Procedures and
templates are indexed in [../04-sql/README.md](../04-sql/README.md).

| Root cause | Action |
| --- | --- |
| Leftover active email row | `AppSupport_UpdateCustomerEmail` with `@IsActive = 0` on the stale row. Deactivate it, do not just update the new one |
| Wrong brand | `AppSupport_UpdateCustomerEmail` or `AppSupport_UpdateCustomerContactNumber` on the row for the brand that is actually sending |
| Login left behind | `AppSupport_UpdateCustomerAccount`. Read the warning in the login runbook first: it overwrites Username, Password, BrandId and IsActive together |
| Missing BrandId 5 rows | `AppSupport_InsertApyContactNEmail`, copying the BrandId 1 values including `DateCreated`. Items 16 and 17 on the source page call the **same** procedure, which writes both a `CustomerContactNo` and a `CustomerEmail` row at BrandId 5, although item 17's heading says "Email" only. Insert, do not overwrite: *"ang goal is may matitira po na email per brand"* (Ron, 2026-09-10) |
| Wrong mobile on a customer | **Neutralise, do not delete.** `AppSupport_UpdateCustomerContactNumber @NewNumber = '0400000000', @IsActive = 1`. For an email the placeholder is `mail@mail.com` (MHD-35960) |
| ABN Active Since | No procedure. Verify the correct date against the ABR record first, then a targeted UPDATE (MHD-34134) |
| Address, business address, entity name on the contract | Raw script territory, parent page items 19, 20, 43, 48, 89 |
| Duplicate customer | `AppSupport_MoveAppToCustomer @ApplicationId, @CustomerId`, then `EXEC dbo.UpdateAmounts @ApplicationId, 1`. The procedure does not recalculate balances |
| Note or email on the wrong account | No procedure. `UPDATE Note SET ApplicationId = <target> WHERE NoteId = <id>;` and `UPDATE InboundEmail SET ApplicationId = <target> WHERE InboundEmailId = <id>;`, parent page items 30 and 32 (MHD-35066). Avoid item 66, which nulls `ApplicationId` on `InboundEmail` with no backup at all |
| Shared `AutopayVehicleDetailId` | Repoint each application to its correct `AutopayVehicleDetailId` and remove the duplicate row once no application references it (MHD-36240) |
| Wrong plate, VIN or vehicle | No procedure. APY is `AutopayVehicleDetail`, SPL is `vehicleAsset`; see the vehicles page (Confluence 1397882974) and parent items 12, 37, 45, 97. Vehicles page item 3 compares an unquoted numeric literal to the varchar `VIN` column: quote it |
| Fuel type, EV discount | Update the vehicle attribute **and remove any pricing concession tied to it**. Fixing the field alone would have left an unearned EV discount on the loan (MHD-33222) |
| Seller details | Manual datafix, after checking for transposed fields (MHD-35191) |
| Batch PPSR discharge | SPL/PL `AppSupport_PLRemovePPSR`, APY `AppSupport_APYRemovePPSR`. **One EXEC block per application, never a loop.** Each needs its own `TaskId` (open `TaskTypeId = 178`) and your own `@ClosedByUserId`. `VehicleAssetStatusTypeId 102005` is Removed (MHD-35624). A "wrong car on the loan" ticket usually needs both the PPSR half and the vehicle-field half |
| PPSR missing, re-register | `AppSupport_UpdatePPSR`, which is a bare INSERT into `EdxRegistration` despite its name. Re-running duplicates the row |
| ID verification link | **Escalate.** Incorrect URL ID Fix (Confluence 1409351844) has a named approval gate: **Jeffrey Lu and Jon Wu** must approve and it runs with the DB team, regardless of how low risk it looks. Default strategy is delete the row so a new link can issue; alternative is repoint `ReferenceId`. Check `referenceID` for all `equifaxTransactionId` rows first |
| Wrong bank account on the loan | Raw script territory, parent items 3, 85, 98. Item 85 is explicitly interim, "while dev fix is not yet released". Check whether the release has landed |

**Rows 2, 4 and 7 are irreversible.** `AppSupport_DeleteCustomerContactNumber`,
`AppSupport_DeleteCustomerEmail` and `AppSupport_DeleteFileUpload` have no backup flag and no
inverse. There is **no** insert procedure for a BrandId 1 `CustomerEmail` or `CustomerContactNo`
row, and `AppSupport_InsertApyContactNEmail` hardcodes BrandId 5, so it is not a restore path.
Capture the full row with `SELECT *` first. Where the goal is only "stop using this address", prefer
the update procedure with `@IsActive = 0` (Confluence 3117842457).

**Merge tag with mobile number errors** mean the customer has more than one active mobile number
on a brand. There should be only one active mobile number per brand (Confluence 1079312385).

## Not a defect

- **"Can't log in with their email" on an OzMoney, MOM or Autopay account.** Brand confusion. MME,
  OzMoney and Autopay logins are separate (MHD-35866).
- **Two applications sharing the same bank statement.** *"This is a very unsophisticated attempt at
  fraud. We will never receive ID"* (Rusty, `#app-support`, 2026-08-31). Not a data problem.

## Precedents

- MHD-36009: SOC brand contact record left holding the old address, application 10003012512.
- MHD-35773, MHD-35754, MHD-35641, MHD-35596: Pattern A email desync.
- MHD-35757, MHD-35758, MHD-34560: insert BrandId 5 contact and email.
- MHD-35960: incorrect mobile neutralised with a placeholder.
- MHD-34134, MHD-34459, MHD-34022: ABN Active Since corrections.
- MHD-34750: duplicate production accounts merged.
- MHD-35066: application note merged to the right customer record.
- MHD-36240: shared `AutopayVehicleDetailId` across four Autopay applications.
- MHD-33222: fuel type updated and EV discount removed.
- MHD-35191: seller details on application 10003030283, fields transposed in the request.
- MHD-35624: batch PPSR discharge on repaid loans.
- MHD-35810, PER-8863: the three tables are not kept in sync.
- MHD-32624: duplicate mobile across two customers.
- MHD-36037, MHD-35692, MHD-35970, MHD-30694: further contact and brand tickets. For lead source
  and dealership corrections (MHD-35305, MHD-36653, MHD-36686) see
  [broker-and-partner.md](broker-and-partner.md).
- MHD-35572, MHD-36049, MHD-36128, MHD-36200, MHD-35797: customer and application moves.

## Open defects

- **Nothing keeps `CustomerEmail`, `CustomerContactNo` and `CustomerAccount.Username` in sync.**
  Stated explicitly in MHD-35810 and PER-8863. Every "email updated" ticket is a symptom.
- **The API does not always create a BrandId 5 contact and email record.** Jef Sumarago proposed on
  2026-08-14 that it should, so funding never has to patch it. Under discussion, no ticket recorded.
- **No self-service ABN re-sync from the ABR.** Every correction is manual (MHD-34134).
- **Horizon does not match an existing customer at application time**, creating duplicates
  (MHD-34750). No ticket found.
- **No procedure exists for ABN, entity, vehicle, note or email-tray corrections.** All raw script,
  and roughly six of about 97 raw items use an explicit transaction. Wrap anything you hand over in
  `BEGIN TRAN` with the `COMMIT` commented out (Confluence 3117842457 Part 2b).
