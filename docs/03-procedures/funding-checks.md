# Funding checks

Working `#pending-funding-checks`: reading the hourly bot, triaging a stuck application, and knowing when no datafix is needed at all.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` section 4; `harvest/slack-tribal-knowledge.md` sections 1, 2 and 3.1; `harvest/confluence-content.md` (Cover Runbook 3131015188 section 01, Pending Funding and Refund support 2385150262); `harvest/confluence-systems-reference.md` sections 3 and 11.

Channel: `#pending-funding-checks`, ID `C05J8HEVC81`, private, created 2023-07-20 by Lary Rosario.

Funding is the single biggest bucket of App Support work: 58 tickets, 11.6 per cent of Ron's last twelve months (Confluence 3131015188).

## 1. The automated signal

An hourly bot post, on the hour, every hour including overnight:

```
*Stuck in funding for 20 mins:*  {N}
```

Observed range in September 2026: 4 to 12.

**The count alone is not actionable.** It is a count, not a list. Overnight it typically plateaus (for example 12 for eight consecutive hours) and then falls during Sydney business hours as the funding team works the queue. Do not chase a rising overnight number; do look at it if it stays high through the Sydney working day.

## 2. The human request shape

Reporters are the funding and settlements team: Tom Tredinnick, Jamie Nguyen, Mitchell McLeod, Serena Rossi. Typical:

```
hey team {horizon link to /Task/ApplicationTasks/{appId} or /Stage/ApplicationStages/{appId}}
this ones stucked at signed off. can i get someone to have a look pls.
will need this fixed asap. broker has folowed up
```

They state the deadline where there is one, for example "needs to fund by EOD as payout letter expires". Treat a stated deadline as the urgency declaration.

## 3. Understand the designed flow first

Albert Rick Martires' description of how disbursement funding actually runs (Confluence 2385150262, 3131015188):

- **First disbursement:** validate (raise a task if it fails), fund to Zepto, generate amortisation, create money out, **move to Fund Sent**.
- **Every disbursement after that:** validate (raise a task if it fails), fund to Zepto.

So an application can legitimately sit at **Fund Sent with a later disbursement still unfunded**, held by a validation task. **That is the designed flow, not a defect.** It is the question Ops asks most often about partially funded loans.

## 4. The triage ladder, as practised

Work down this list. A good share of "the app is stuck funding" reports need **no datafix at all**.

### Step 1: identify the blocking task

Common named tasks:

- **`Review - Funding Follow up`.** An open task blocks funding; closing it lets the application proceed. Ron, 2026-06-17: *"It's already implemented. I think we just need to close the Funding Follow up task and it should fund afterwards."*
- **`Review - Funding Failed`.** Causes include the float limit, a Zepto funding failure, or insufficient funds.
- `Review - Funding Failed` on **CRD Payanyone** applications is often **safe to close in bulk** (Albert Rick, 2026-07-23).

### Step 2: read the task note, because several notes mean "no fix needed"

| Task note | Verdict |
| --- | --- |
| `Float account reached set limit of 400,000.00` (or 150,000 on other products) | **Safe to retry, no datafix.** A Payment API validation rule caps the amount funded per 5 minutes per product; for APY that is $400,000. The payment never reached Zepto, so nothing is half done. Albert changed the handling in August 2026 so the real message appears in the task notes rather than the old generic text, specifically to stop App Support datafixing these (Confluence 3131015188 B) |
| PayAnyone stuck at **Authorized** instead of Cleared (CRD) | **Close the task, do not datafix.** An earlier PayAnyone failed and raised a funding failed task; the retry succeeded but a funding condition blocks completion while the old task is open. Permanent fix is API-6134. Sample: MHD-35999 |
| `Invalid Funding BSB Format. [ 033089]`, note the leading space | The SortCode was saved with a space. Strip it on `Horizon2.dbo.CommissionBank`, then ask Ops to complete the outstanding task. Jeff Lu loads this data. Sample: MHD-35359 |
| `Invalid Funding BSB (Returned by Third Party AusPayNet)` | Genuinely invalid at AusPayNet. **Not a datafix.** Correct bank details must be supplied |
| Insufficient funds | The generic "safe to close" text is still attached, so open `fundingactivity` to find the actual cause before answering Ops. Albert has this as a fix target (Confluence 3131015188 J) |

### Step 3: check whether funding actually completed

Albert Rick, 2026-09-22: *"it looks like all funding steps is completed for this app. so moving to Fund Sent is okay"*.

**Check Zepto before re-running anything.** If the funded date and contract end date are both present, the money has gone. Do not re-run funding; move the application to **Fund Sent** (Jamie does the stage move). Samples: MHD-35863, MHD-35970.

### Step 4: known cause, D2C disbursement details added after Signed off

Tom, 2026-08-28: *"got to signed off before disbursement details were added (D2C app) might need an update processed in back end?"*. Albert Rick's verdict on the 2026-09-08 instance: *"it won's fund ok"*, and the fix is the reprocess datafix below.

### Step 5: the standard reprocess fix

Albert Rick's request wording, repeatedly:

> "please help us run the data fix SP to delete the funding records to reprocess the app for funding"

The exact call he supplied on 2026-09-21:

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10003091206, 1533539, 0
```

Arguments observed as `ApplicationId, FundingId, flag`.

The fuller **retry funding** pair, which is the one you will run most (Confluence 3131015188 A):

```sql
DECLARE @ApplicationId BIGINT = 10003035734;
DECLARE @FundingId     BIGINT = 1517941;
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@ApplicationId AS NVARCHAR(20)), ' - Retry Funding');
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentSubmissionStatus] @ApplicationId, @FundingId, 91001, NULL, NULL, @Notes;
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] @ApplicationId, @FundingId, 0
```

**Both statements are required.** The second, `IsProcessed` back to `0`, is what lets the process pick the record up again. Running only the first will look like it worked and will not retry.

Funding status IDs:

| ID | Meaning |
| --- | --- |
| `91001` | Reset. Restarts funding from the beginning. This is the retry value |
| `91004` | Cancelled or stopped. Used when the application itself was cancelled |
| `91005` | Mark as funded, where a `PaymentAccountFunding` record already exists |
| `91007` | Where a successful retry lands. Republishes the FundSentEvent |

**No TransactionId mapped to the funding record.** Albert sweeps for these and sends batches of 8 to 29, roughly weekly:

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateTransactionId] 10003029182, 1516235, 108844212
```

Run in **batches of 10 with an interval between batches**, which is Ron's own practice on the large lists and avoids the float limit. Samples: MHD-35904 (29 records), MHD-35207.

**Deleting funding records is the last resort.** Confirm with Albert first; his answer is often *"close lang ng task"*, and closing the task is far cheaper than deleting and re-funding (Confluence 3131015188 I). The backup will **not** run if `@MHDTicket` is empty.

Full script set in [`../04-sql/datafix-templates/`](../04-sql/datafix-templates/); symptom routing in [`../02-runbooks/`](../02-runbooks/).

### Step 6: close the task

Closing the `Review - Funding Failed` or `Review - Funding Follow up` task so the application proceeds is usually done by the funding or Ops side, Gabriel Pavlovic or Jamie Nguyen.

### Step 7: confirm in channel

Say so explicitly when it lands. Albert Rick: *"Yep this is Funded now. Thanks Ron."* and *"Confirming these two apps are funded now"*. The channel is the record; silent fixes get re-reported.

## 5. Who to tag

| Role | Person |
| --- | --- |
| Funding technical owner in this channel | **Albert Rick Martires** (`U03B04FUGDS`, Senior .Net Developer, Team Lead, G3 Engineering) |
| Runs the datafix SP request | **Ron** / **Michael** (via `#datascript-requests`) |
| Closes the Horizon tasks | **Gabriel Pavlovic**, **Jamie Nguyen** |
| Stage moves | **Jamie Nguyen** |
| Deeper funding dev and QA questions | `#funding-dev-qa-supports` |
| Other funding channels | `#app-support-funding`, `#funding-issues`, `#horizon-funding-team` |

## 6. The brand-id gotcha

**Check this before anything else when funding fails on an APY or S1 branded application.**

Zepto requires customer contact details at fund submission, and Horizon looks them up **by BrandId**. If the customer's `CustomerEmail` and `CustomerContactNo` rows exist only under a different brand (typically MME), the lookup returns nothing and funding fails or the application will not progress.

Check: does a row exist in `CustomerEmail` and in `CustomerContactNo` for the application's `BrandId`? If not, insert the per-brand contact and email rows. This appears in the monthly umbrella children as `Insert BrandId 5 contact and email` (MHD-35277 children, [03-procedures/jira-conventions.md](jira-conventions.md)).

One recurring "already funded in Zepto but the stage never moved" variant will not progress until the customer has a **brand id 5 contact and email**; add those first (Confluence 3131015188 G, samples MHD-35863 and MHD-35970).

Documented by Albert Rick and Jef Sumarago in `#funding-dev-qa-supports`. Full recipe in [`../05-knowledge/`](../05-knowledge/) and [`../02-runbooks/`](../02-runbooks/).

## 7. Cadence notes

- The hourly bot runs 24/7.
- Albert Rick's unmapped-TransactionId sweep lands roughly **weekly**, in batches of 8 to 29 (Confluence 3131015188).
- Any datafix has to fit the SQL dev window, Mon to Fri 12:00 to 13:00 and 16:00 to 17:00 Sydney time. A funding request arriving late in the PH afternoon will not land until the next day unless it is flagged urgent. See [`datafix-request.md`](datafix-request.md).
