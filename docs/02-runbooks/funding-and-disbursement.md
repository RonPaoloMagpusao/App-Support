# Funding and disbursement

Applications that will not fund, funding tasks that will not clear, and the Zepto disbursement path.

Last reviewed: 23 September 2026
Sources: Confluence 3131015188 section 01, Confluence 2385150262, Confluence 2286321665, team procedures (Slack) section 4, tribal knowledge (Slack) section 3.1, MHD issue catalogue theme 9

The biggest bucket by volume, 58 tickets or 11.6 per cent in the twelve months to August 2026
(Confluence 3131015188). Intake is `#pending-funding-checks`, or Albert Rick Martires sends the
scripts straight to you in Slack.

## Symptoms

- "This one's stuck at signed off. can i get someone to have a look pls. will need this fixed asap, broker has followed up"
- "Reprocess application for funding"
- "please help us run the data fix SP to delete the funding records to reprocess the app for funding"
- "Investigate application stuck in 'app-esign accepted' stage" / "stuck in pre-settlement status"
- Task note: "Float account reached set limit of 400,000.00"
- Task note: `Invalid Funding BSB Format. [ 033089]`
- Task note: `Invalid Funding BSB (Returned by Third Party AusPayNet) | Sort Code: 201086`
- "Insufficient funds"
- "Insert Equifax Score" (the highest-frequency single request in this theme)
- "Refund Funding Error 'No Bank Account'"
- Bot post in `#pending-funding-checks`: "*Stuck in funding for 20 mins:* {N}"

## Understand the flow before you fix anything

Albert Rick Martires' description of how disbursement funding actually runs
(Confluence 2385150262):

- **First disbursement:** validate, raise a task if it fails, then fund to Zepto, generate
  amortisation, create money out, move to Fund Sent.
- **Every disbursement after that:** validate, raise a task if it fails, then fund to Zepto.

So an application can legitimately sit at **Fund Sent with a later disbursement still unfunded**,
held by a validation task. That is the designed flow, not a defect. It is the question Ops asks
most often about partially funded loans.

## Triage, in order

1. **Identify the blocking task.** Tasks tab, `horizon.moneyme.com.au/Task/ApplicationTasks/<id>`.
   Named tasks you will see: `Review - Funding Follow up`, `Review - Funding Failed`,
   `Review - Contract Sending Failed`, `Error Split Create/Update Account`. Ron, 2026-06-17,
   `#pending-funding-checks`: *"It's already implemented. I think we just need to close the
   Funding Follow up task and it should fund afterwards."* Closing a task is far cheaper than
   deleting and re-funding, and is often the whole fix.
2. **Read the task note verbatim.** "Float account reached set limit of 400,000.00" means the
   Payment API's per-product 5-minute cap was hit, the payment never reached Zepto, and it is
   **safe to retry with no datafix**. Albert changed the handling so the real message now
   appears in the task notes specifically to stop App Support datafixing these
   (Confluence 3131015188 section 01-B, Confluence 2385150262).
3. **Check Zepto before you re-run anything.** If the funded date and contract end date are both
   present, the money has gone. Move the application to Fund Sent rather than re-funding.
   Jamie Nguyen does the stage move (Confluence 2385150262). Precedents MHD-35863, MHD-35970.
4. **For an APY or S1 branded application, check the BrandId 5 contact rows.** Zepto requires
   contact details at fund submission and the funding code looks them up in `CustomerContactNo`
   and `CustomerEmail` **matching on BrandId** (Albert Rick, `#app-support`, 2026-08-13). If the
   rows exist only under BrandId 1, funding will not go through. See
   [customer-and-company-data.md](customer-and-company-data.md).
5. **Run the drill-down query** for the application: `Funding`, `FundingScheduling`,
   `FundingActivity`, `disbursement`, `PATransaction`, and open tasks with
   `TaskTypeId IN (65, 77, 118, 176) AND [Status] = 'Open'` (Confluence 2385150262). The task
   block is exactly what surfaces the PayAnyone-at-Authorized case.
6. **For "insufficient funds", open `FundingActivity`.** The task notes still carry the generic
   "safe to close" text, so the actual reason is only visible there
   (Confluence 3131015188 section 01-J). Albert has this as his next fix target.
7. **Only then consider a datafix.** The sweep query for all pending funding across the book is
   on Confluence 2385150262 and in [../04-sql/diagnostics/](../04-sql/diagnostics/).

## Root causes seen

1. **Float account 5-minute cap reached.** Task note names it. The payment never reached Zepto.
   The single biggest source of "the app is stuck funding" reports and as of August 2026 it needs
   no datafix at all (Confluence 3131015188 section 01-B).
2. **PayAnyone stuck at Authorized instead of Cleared, CRD.** An earlier PayAnyone failed and
   raised a funding failed task. The customer retried and succeeded, but a condition in funding
   blocks completion while the old task is still open (MHD-35999). Albert hit this three times in
   one month.
3. **No TransactionId mapped in the Funding record.** The funding record is created and the
   TransactionId is never mapped to it. Albert sweeps for these and sends batches of 8 to 29,
   roughly weekly (MHD-35904 with 29 records, MHD-35207).
4. **SortCode saved with a leading space.** `Invalid Funding BSB Format. [ 033089]`. It will keep
   re-raising the funding follow up until fixed (MHD-35359).
5. **Genuinely invalid BSB at AusPayNet.** `Invalid Funding BSB (Returned by Third Party
   AusPayNet)`. Not a datafix, the correct bank details have to be supplied
   (Confluence 2385150262).
6. **Orphan funding records after disbursements were changed.** The disbursements were replaced
   after sign off and the old `Funding` and `FundingScheduling` rows survived, blocking the new
   run (MHD-35218, MHD-35132, MHD-36609). Related known trigger: D2C applications that reached
   Signed Off before disbursement details were added (Tom Tredinnick, `#pending-funding-checks`,
   2026-08-28; Albert Rick's verdict on the 2026-09-08 instance was *"it won's fund ok"*).
7. **Funding halted mid-flight on a server timeout.** The funds had already left via Zepto but the
   completion fields never reached a terminal state, so the application never advanced and no
   comms or contracts generated (MHD-35863, application 10003038152).
8. **NULL `applicationbankid`.** Bank details visible on screen, the reference NULL underneath,
   producing "No Bank Account" on refund funding (MHD-36658, application 10002815000).
9. **Missing Equifax score on a funded application.** Recurs constantly and is always closed by
   inserting the score (MHD-34765, application 10003014669, closed in two minutes).
10. **Application cancelled but funding still live** (MHD-35069).

## The fix

**Retry funding, the default and the one you will run most.** Both statements are required. The
second, `IsProcessed` back to `0`, is what lets the process pick the record up again. Running only
the first will look like it worked and will not retry (Confluence 3131015188 section 01-A).

```sql
DECLARE @ApplicationId BIGINT = 10003035734;
DECLARE @FundingId     BIGINT = 1517941;
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@ApplicationId AS NVARCHAR(20)), ' - Retry Funding');
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentSubmissionStatus] @ApplicationId, @FundingId, 91001, NULL, NULL, @Notes;
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] @ApplicationId, @FundingId, 0
```

It will not double fund. Status `91001` restarts from the beginning, moves to `91007` and
republishes the FundSentEvent. That republish is also how a **missing amortisation** gets
generated. Space bulk runs 5 minutes apart so you do not re-trip the float cap (MHD-35294), and on
long lists run in batches of 10 (Confluence 2385150262).

| Root cause | Action |
| --- | --- |
| Float cap | **No action**, retry. Tell Ops the message means "safe to retry", not "stuck" |
| PayAnyone at Authorized | **Config change**, close the funding failed task at `/Task/ApplicationTasks/<id>`. Nothing else. Permanent fix is API-6134 |
| No TransactionId mapped | **Datafix**, `EXEC Horizon2.[dbo].[FundingDataFixUpdateTransactionId] 10003029182, 1516235, 108844212`. Arguments are ApplicationId, FundingId, TransactionId |
| SortCode with a space | **Datafix**, strip the space in `Horizon2.dbo.CommissionBank` keyed on `LeadSourceId`, then ask Ops to complete the outstanding task. Jeff Lu loads this data |
| Invalid BSB at AusPayNet | **No action** on our side. Correct bank details must be supplied |
| Orphan funding records | **Datafix**, `EXEC dbo.AppSupport_DeleteFundingRecords @ApplicationId, @MHDTicket, @CreateBackup = 1, @CloseTask = 1`. Last resort, **confirm with Albert first**: his answer is often "close lang ng task" |
| Already funded in Zepto | **Config change**, move the stage to Fund Sent. Do not re-run funding. Or mark funded with status `91005` where a `PaymentAccountFunding` record exists |
| IsProcessed stuck on one disbursement | **Datafix**, `EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10003031096, 1516542, 0` |
| Application cancelled, funding live | **Datafix**, `FundingDataFixUpdatePaymentFundingStatus` with status `91004`, then `FundingDataFixUpdateIsProcessed ... , 1` (MHD-35069) |
| Missing Equifax score | **Datafix**, insert the score under the monthly umbrella |
| NULL `applicationbankid` | **Datafix**, populate the reference. MHD-36658 ran under MHD-36184 |
| Insufficient funds | **Escalate** after reading `FundingActivity`. Albert Rick Martires |

`@MHDTicket` is concatenated into dynamic DDL to name backup tables, so **strip the hyphen**:
`'MHD35866'`. A hyphen is an invalid identifier and fails the batch safely but stalls the fix.
Always leave `@CreateBackup = 1`, and note the backup will not run if `@MHDTicket` is empty
(Confluence 3117842457, Confluence 2485059655).

### Funding status IDs

| ID | Meaning |
| --- | --- |
| `91001` | Reset. Restarts funding from the beginning. The retry value |
| `91004` | Cancelled or stopped. Used when the application itself was cancelled |
| `91005` | Mark as funded, where a `PaymentAccountFunding` record already exists |
| `91007` | Where a successful retry lands. Republishes the FundSentEvent |

Source: Confluence 2385150262 and Confluence 3131015188. Both pages agree.

### Escalation

**Albert Rick Martires**, Senior .Net Developer and Team Lead, G3 Engineering, owns the Payment
API and funding path. He sweeps for broken funding records himself and sends the scripts. If a
funding symptom is not on this page, ask him before writing anything. Deeper dev and QA questions
go to `#funding-dev-qa-supports`. Horizon task closures are done by Gabriel Pavlovic and
Jamie Nguyen. Script execution in prod goes through Victor Alvarez and Krizza Rosales in
`#datascript-requests`.

## Not a defect

- **Fund Sent with a later disbursement unfunded.** Designed flow, first disbursement moves the
  stage, subsequent ones only validate and fund (Albert Rick, Confluence 2385150262).
- **"Float account reached set limit of 400,000.00".** A validation rule, not a failure. Safe to
  retry (Confluence 3131015188 section 01-B).
- **The hourly "Stuck in funding for 20 mins" count.** Not actionable on its own. It plateaus
  overnight and falls during Sydney business hours as the funding team works the queue
  (`#pending-funding-checks`, observed September 2026).
- **`Review - Funding Failed` on CRD PayAnyone applications** is often safe to close in bulk
  (Albert Rick, `#pending-funding-checks`, 2026-07-23).

## Precedents

- MHD-36609: application 10003084267 stuck at Signed Off, orphan funding records, deleted by SP.
- MHD-35863: application 10003038152, funding halted on a server timeout after Zepto had paid.
- MHD-35218, MHD-35132: stuck at Signed Off after disbursements were replaced.
- MHD-35999: CRD PayAnyone at Authorized, fixed by closing the task.
- MHD-35904, MHD-35207: batches of funding records with no TransactionId mapped.
- MHD-35359: SortCode saved with a leading space on `LeadSourceId` 8187.
- MHD-35069: application cancelled with funding still live.
- MHD-35294: the precedent for spacing bulk retries 5 minutes apart.
- MHD-34765, MHD-36712, MHD-36559, MHD-36129, MHD-36041, MHD-35896, MHD-35709, MHD-35571,
  MHD-35497, MHD-35187, MHD-35155, MHD-35077, MHD-34362, MHD-34324, MHD-34285, MHD-34204,
  MHD-34091, MHD-33837, MHD-33781, MHD-33355: missing Equifax score, all closed by insert.
- MHD-36658: NULL `applicationbankid` producing "No Bank Account".
- MHD-28180: funded in Zepto but no `PaymentAccountFunding` record.

## Open defects

- **API-6134**, remove the unnecessary condition blocking CRD Pay Anyone funding events. Until it
  lands, the PayAnyone-at-Authorized case will keep recurring.
- **Nobody has asked why funded applications keep arriving without an Equifax score.** Roughly
  twenty tickets in the window, every one closed by inserting the score, no ticket raised against
  the cause (MHD open threads Tier 4).
- **Insufficient-funds task notes still carry the generic "safe to close" text**, so the real cause
  is only in `FundingActivity`. Albert's next fix target, no ticket recorded
  (Confluence 3131015188 section 01-J).
- **MHD-35062**, Split Create/Update Account tasks regenerating on CRD accounts, Selected for
  Development since 27/07/2026. See [crd-credit-card.md](crd-credit-card.md).
- **MHD-34644**, the Horizon file upload limit parent, Selected for Development and never closed
  although the code shipped.
