# Application stuck at a stage

Applications that will not advance: Signed Off, App-esign Accepted, Pre-Settlement, and contracts that never send.

Last reviewed: 23 September 2026
Sources: Confluence 3131015188 section 04, Confluence 1293647889, Confluence 942047312, MHD issue catalogue theme 9, team procedures (Slack) section 4

42 tickets or 8.4 per cent in the twelve months to August 2026, almost always the same sentence
(Confluence 3131015188).

## Symptoms

- "Application 10003024984 is stuck at the 'signed off' stage"
- "Investigate and resolve application stuck at 'Signed Off' status"
- "Investigate application stuck in 'app-esign accepted' stage"
- "Investigate application stuck in pre-settlement status"
- "Contract missing" / "contract not sent"
- "Can't cancel the application" / "workflow didn't fire"
- "The app got to signed off before disbursement details were added (D2C app), might need an update processed in back end?"

## Triage, in order

1. **Work [funding-and-disbursement.md](funding-and-disbursement.md) first.** Most "stuck at
   Signed Off" tickets are a funding problem wearing a stage label. Run through retry, the float
   limit, an open task blocking completion and already-funded-in-Zepto **before** you consider
   deleting anything (Confluence 3131015188 section 04).
2. **Open the Tasks tab.** Stuck applications usually have an unresolved or failed task
   (MHD issue catalogue theme 9). Query it directly with
   `TaskTypeId IN (65, 77, 118, 176) AND [Status] = 'Open'` (Confluence 2385150262).
3. **Confirm which stage it is actually on.** Stage `39` is Signed Off, stage `38` is Fund Sent
   (Confluence 1293647889). Stage 38 is also the `ToStageId` the contract generation workflow
   keys on, which matters for the contract variant below.
4. **Check Zepto.** If the funded date and contract end date are both present, the money has gone.
   Move the stage, do not re-fund (Confluence 2385150262).
5. **For a contract that never sent, look for `Review - Contract Sending Failed`.** The error
   detail is in the task notes. Fix the underlying data first, usually a missing address, email
   or contact, then use the Send (Resend) Contract and Close Task script
   (Confluence 942047312). Michael Dela Torre's standing guidance: *"we should make sure that it's
   cleared first. There will be additional info in Notes, if the error message is about mobile or
   email, we should let the agent fix it first"* (MHD-32267).
6. **If the contract task is clean, check the generator.** Azure subscription
   `d2c61912-1986-42ce-ae47-24f987ce73aa`, resource group `MoneyMe_New`,
   `Microsoft.Web/sites/azf-contract-generator-prod`, then the `ApplicationContract` table for a
   created record. There is sometimes a delay (Confluence 942047312).
7. **For PL Broker and other products not yet on the contract revamp**, check whether the
   generating workflow picked the application up. `ApplicationTypeId` should be `87003` and
   `PartnershipApplication.StatusId` should be in `(63006, 63007)`. `WorkflowId` 1258 and 1259
   generate the loan agreement for BrandId 1. No row in `ApplicationWorkFlow` means the workflow
   never selected it (Confluence 942047312).

## Root causes seen

1. **Orphan `Funding` and `FundingScheduling` rows.** The disbursements were replaced after sign
   off and the old rows survived, blocking the new funding run (MHD-35218, MHD-35132, MHD-36609
   on application 10003084267).
2. **Funding halted mid-flight on a server timeout.** Funds already left via Zepto, the completion
   fields never reached a terminal state, so the application never advanced and no comms or
   contracts generated. This one also needed a BrandId 5 contact and email on the customer
   (MHD-35863, application 10003038152).
3. **An open task blocking completion.** Most commonly `Review - Funding Follow up`,
   `Review - Funding Failed` or, for CRD PayAnyone, a stale failed task from an earlier attempt
   (MHD-35999).
4. **Missing BrandId 5 contact rows** on an APY or S1 application, so Zepto cannot be given the
   contact details it requires at fund submission (Albert Rick, `#app-support`, 2026-08-13;
   MHD-35863, MHD-35970).
5. **D2C disbursement details added after Signed Off.** Albert Rick's verdict on the 2026-09-08
   instance was *"it won's fund ok"*, and the fix is the delete-funding-records datafix
   (`#pending-funding-checks`, 2026-08-28 and 2026-09-08).
6. **Contract workflow excluded the application by its own criteria.** On the worked example in
   Confluence 942047312 the failing criterion was the funded-date window,
   `AND DATEDIFF(DAY, App.FundedDate, GETDATE()) < 30`.
7. **`Review - Contract Sending Failed` with `Error Message: Value cannot be null.
   (Parameter 'text')`.** Usually caused by decryption of the bank account number,
   `security.DecryptAsync(bank.AccountNumberEncrypted)`. Check the bank accounts on the
   application for missing data, fix, then resend (Confluence 942047312).

## The fix

| Root cause | Action |
| --- | --- |
| Orphan funding rows | **Datafix**, `AppSupport_DeleteFundingRecords`. Confirm with Albert Rick Martires first, since the answer is often "close the task" instead. See [../04-sql/README.md](../04-sql/README.md) |
| Funding halted after Zepto paid | **Config change**, move the stage to Fund Sent. Jamie Nguyen does the stage move. Do not re-run the transfer |
| Open blocking task | **No action beyond closing the task** at `horizon.moneyme.com.au/Task/ApplicationTasks/<id>` |
| Missing BrandId 5 rows | **Datafix**, `AppSupport_InsertApyContactNEmail`, copying the BrandId 1 values including `DateCreated`. See [customer-and-company-data.md](customer-and-company-data.md) |
| Contract task not cleared | **No action beyond clearing the task**, after fixing whatever the note names |
| Workflow criteria excluded the application | **Config change**, widen the workflow's `CriteriaSql` window, for example 30 days to 63, then roll it back. This is the safer of the two options on Confluence 942047312. The alternative, adjusting `Application.FundedDate`, changes customer-facing data |
| Nothing above fits | **Escalate.** Funding path to Albert Rick Martires. Stage moves to Jamie Nguyen. BGP workflow logs via Julius Serrano |

Raw-script territory for the remainder: "Can't cancel the application", "app stuck in the wrong
stage", "workflow didn't fire" are SQL Data Fix scripts items 64, 87 and 88. There is no stored
procedure (Confluence 3117842457, Part 2b).

## Not a defect

- **Fund Sent with a later disbursement still unfunded**, held by a validation task. That is the
  designed flow (Albert Rick, Confluence 2385150262).
- **A delay between funding and the `ApplicationContract` row appearing.** Check the Azure function
  before treating it as missing (Confluence 942047312).
- **Post-funding stage movements that look wrong.** Read the behaviour notes on
  Confluence 1293647889 first. Overdue hold (65) is entered automatically when a payment for more
  than 80 per cent of arrears is made, External - 14 Day Hold (129) auto-moves to Overdue after
  14 days, and Hardship Declined (33) deliberately holds an account 14 days to protect it from
  collection activity.

## Precedents

- MHD-36609: application 10003084267 stuck at Signed Off, orphan funding records.
- MHD-35863: application 10003038152, server timeout after Zepto had already paid, plus a missing
  BrandId 5 contact and email.
- MHD-35218 and MHD-35132: stuck at Signed Off after disbursements were changed.
- MHD-35970: already funded in Zepto, stage never moved, BrandId 5 variant.
- MHD-32267: application 10002867333, loan agreement template 2146 never sent, uncleared
  `Review - Contract Sending Failed` task.
- MHD-35658, MHD-36527: further contract-sending failures.
- MHD-36412, MHD-36393, MHD-34489, MHD-33741, MHD-33742, MHD-31677, MHD-36600, MHD-36797: further
  funding and stage tickets in the window.

## Open defects

- **MHD-31915**, "Overdue still showing after contract variation", Selected for Development since
  April 2026, 161 days as at harvest.
- **MHD-34329**, "Decline on S1 app issue", Selected for Development, 83 days.
- **The D2C "disbursement details added after Signed Off" path has no permanent fix.** It is
  handled by datafix each time (`#pending-funding-checks`, 2026-09-08).
