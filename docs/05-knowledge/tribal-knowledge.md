# Tribal knowledge

Check-first rules, fix recipes, known issues, vocabulary and non-obvious behaviours that live in people's heads and Slack threads rather than in documentation.

Last reviewed: 23 September 2026
Sources: Slack `#app-support`, `#datascript-requests`, `#pending-funding-checks`, `#refund-supports`, `#solutions_memorandum` and related channels

Harvested 2026-09-23 from Slack, window 2025-09-01 to 2026-09-23.
Private repo. Customer names, emails, phone numbers and addresses stripped.
Horizon IDs kept as worked examples.

---

## 1. "Check this first" rules

| Situation | Check this first | Source |
| --- | --- | --- |
| Direct debit rejected | Read the rejection reason. `incorrect_account_number` means the bank account number on the bank statement is genuinely wrong. "This should be the first thing we check before raising this as an issue." | Rusty, 2026-05-26, `#app-support` |
| Email not delivered | DNC flag in Horizon, then the SendGrid **Bounces** suppression list, then the bounce reason (`550 no such user here`, `user unknown`) | Michael Dela Torre, repeatedly |
| SMS not received | Twilio shows sent without errors -> it is almost never us. Check spam. | Ron / Rusty |
| Funding failing on an APY or S1 app | `CustomerEmail` and `CustomerContactNo` rows for the customer, and whether a row exists for the app's `BrandId` | Albert Rick, Jef Sumarago |
| Anything showing on the CRD Credit Card tab | It lives in **E6**, not Horizon. A Horizon data fix will not fix it. | Rusty, 2026-07-02 |
| Scheduled payment not cancelled after early payment | Is the product CRD? Different rules apply (bill satisfaction, not custom/partial). | Rusty, 2026-05-28 |
| Payment method will not schedule | Does it match the **default** payment method on the account? | Rusty, 2026-08-12 |
| Overdue fee complaint | Was the account in overdue stage? OD fee is every 14 days in overdue stage regardless of payments. | Rusty, 2026-09-01 |
| Sentry alert | Read the `notes:` routing line and the `State` / `First Seen` fields before treating it as new | `#app-support-sentry-error-logs` |
| Report from Ops that a rule is broken | Reproduce on a second example. Rusty has been caught by "2 invalid examples by coincidence on the same day". | Rusty, 2026-08-13 |
| Before escalating to Tops | "I prefer to check thoroughly before involving them, especially since so many of those are agent error or expected behaviour." | Rusty, 2026-08-04 |

---

## 2. Recurring fix recipes

### 2.1 BrandId missing on CustomerEmail / CustomerContactNo (funding blocker)

**Symptom.** Funding fails, or Horizon shows the customer's contact details
under one brand while the application sits under another. Seen repeatedly for
**APY** apps whose contact rows are set up under **MME**.

**Why.** Zepto requires contact details at fund submission. The funding code
looks them up in `CustomerContactNo` and `CustomerEmail` **matching on
BrandId**. Albert Rick, 2026-08-13:

> "kaya may checking kami ng contact details kasi sa zepto pre required yung
> contact details during fund submission. kaya doon ko kinukuha sa
> customercontactno and customeremail na table by matching sa brandid"

**Check.**
```sql
SELECT * FROM CustomerContactNo WHERE CustomerId = {custId}
SELECT * FROM CustomerEmail     WHERE CustomerId = {custId}
```
plus the application's BrandId:
```sql
USE Horizon2;
DECLARE @appIdWithCorrectTo BIGINT = 10003052950;
DECLARE @custId BIGINT;

SELECT @custId = app.CustomerId
FROM [Application] app WITH (NOLOCK)
WHERE app.ApplicationId = @appIdWithCorrectTo;

SELECT app.ApplicationId, app.CustomerId, app.BrandId, app.DateCreated
FROM [Application] app WITH (NOLOCK)
WHERE app.CustomerId = @custId
ORDER BY app.DateCreated ASC;

SELECT * FROM [CustomerEmail] ce WITH (NOLOCK) WHERE ce.CustomerId = @custId;
```

**Fix.** Insert (do not overwrite) a row for the missing brand. The convention
is one contact row and one email row **per brand**: *"ang goal is may matitira po
na email per brand"* (Ron, 2026-09-10). BrandId **5** is the one repeatedly
inserted for APY/S1 apps; BrandId **1** is MME.

**Worked examples.** MHD-34560 (2026-07-23), customer 1025655 (2026-07-10),
customer 2150384 (2026-08-24), app 10003052950 (2026-08-24).

**Longer-term fix under discussion** (Jef Sumarago, 2026-08-14): have the API
always create a BrandId 5 record on contact and email so funding never has to
patch it.

### 2.2 Transaction reversal needs an amortisation counterpart

Any reversal data fix on `[Transaction]` needs a matching amortisation record,
or the amort schedule silently diverges. Tops, 2026-02-11:

> "need din magkaron ng record ang reversal sa amortization"

September 2026 had a dedicated script for exactly this:
`Soft Execution - MHD36494 - Create amort counterpart for Bulk Dishonour Fee
Update - Sep2026.sql`.

### 2.3 Cancelling proposed/scheduled amortisation

Two steps, both required (Jess Leal, 2026-06-05):

1. Update status of affected amorts to **35005 (Cancelled)**.
2. Add the note **"Cancel all proposed schedule"** to those amorts.

Step 2 is what stops Horizon regenerating them. Without it, new proposed
schedules reappear.

### 2.4 Funding stuck at Signed off: reprocess the funding records

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] {ApplicationId}, {FundingRecordId}, 0
```
Worked example: `EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10003091206, 1533539, 0`
(Albert Rick, 2026-09-21). Then close the `Review - Funding Failed` / funding
follow-up task.

### 2.5 CRD junk transactions created by a bulk transaction upload

When Rusty bulk-uploads Direct Credit transactions (TranType 1) to Horizon,
Horizon spawns interest and allocation transactions that must be removed. His
own selector:

```sql
USE Horizon2
SELECT * FROM [Transaction]
INNER JOIN Horizon2.dbo.Task T ON T.ApplicationId = App.ApplicationId
WHERE ApplicationId IN (10002494594)
  AND app.ProductId <> 111
  AND TransactionTypeId IN (18, 28, 32)
  AND TranDate = '2026-09-22 00:00:00.000'
```

Rules he stated alongside it (2026-09-22):
- `TransactionTypeId IN (18, 28, 32)` = the allocate/reallocate/interest noise.
- **`ProductId = 111` is CRD**, and is `NULL` for everything else.
  > "yes, productid is mainly 111 for CRD and NULL otherwise"
  > "We normally use ProductTypeId for everything else"
- **CRD should return none** from that query: *"CRD just doesn't have the same
  interest adjustment and reallocation processes, so should be none."*
- Remove Daily Interest / Unallocated Interest / Allocated Interest rows; **do
  not touch the Direct Credit row**.
- Changing a transaction's trantype to "refund" is equivalent to cancelling both
  the original and the refund pair: *"changing the trantype of 110246491 to
  refund is the same as cancelling both 110200251 & 110246491. Same outcome
  either way."*

### 2.6 Clearing a stuck `Error Split Create/Update Account` task

That task blocks transactions loading on the account, because there is no valid
Split account to direct debit. Clearing the task unblocks it. Rusty, 2025-09-18,
task 10002547581.

### 2.7 Removing a reversed CRD migration

```sql
SELECT * FROM AdditionalData
WHERE AdditionalDataTypeId = 125
  AND ApplicationId IN (10002935544, 10002906204, 10002922604,
                        10002927915, 10002930191, 10002936868)
```
`AdditionalDataTypeId = 125` is the migration marker. Rusty asked for these rows
to be removed after a migration was reversed (2026-07-02).

---

## 3. Known issues and open defects seen in the window

| Issue | Ticket | Status as at harvest |
| --- | --- | --- |
| CRD scheduled MMP not cancelled after bill satisfied | **MHD-33265** | Raised to CRD team 2026-05-28; recurring reports through 2026-08 |
| Recurrence of a previously fixed CRD issue | **MHD-36573**, prior fix **CRD-2422** | Re-raised 2026-09-16 by Rusty |
| Negative "Outstanding charges" on SOA (PaidChargeAmount > TotalChargeAmount) | **CL-628** | Open, individual accounts fixed manually |
| Split Sched rejecting on date when it should not | **COL-3475** | Rusty added symptoms 2025-11-27 (txns 99697633, 100518211, 99200209) |
| CRD bug queued for backlog, "in ~3 months it will be a bigger priority" | **CL-215** | Raised 2026-06-24 |
| Overdue fee $5.00 instead of $35.00 | **MHD-33684** | Raised 2026-06-17 |
| Comms template 341 (MME 1014, Confirmation of Change of Direct Debit Details) overwritten with an unrelated MOM template in prod | **FE-5360** | Fixed in prod by Rusty 2025-10-29, process investigation requested |
| Horizon transactional email quarantined as spam, MAIL FROM / DKIM misalignment | **MHD-26581** | Raised 2025-09-19 |
| SOA file upload blocked by 10MB limit | **HOR-8167** | Raised 2026-07-14, requested increase to 20MB |
| Apps shuffled same day as funding, missing Dealer/Broker Fee (84 apps) | **AMZ-10685** | Bulk shuffle ticket raised 2026-09-15 |
| Balloon/date-related arrears issues on FS | (investigated by Jess Leal) | 2026-07-14 |
| Customer can still see migrated Freestyle payment schedule showing the wrong amount |, | Rusty, 2026-05-26: "I would think it should be hidden" |
| Emails rendering `&nbsp;` as `?` (U+FFFD replacement characters baked into the message body) |, | Template 201122; fixed by replacing 11 `&nbsp;` instances with plain spaces / `white-space:nowrap` spans, 2026-09-16. Advice: **avoid `&nbsp;` in Horizon email templates.** |
| Luxury Escapes CRD funded email using generic template 201185 instead of branded 201265 |, | Raised 2026-08-19 |
| Horizon tabs not populating, needing several refreshes, worse on CRD |, | Raised May, followed up 14 & 18 May, 3 & 20 July, escalated again 2026-08-05 by Raina. Suspected E6 data not loading / timeout too short. Long-running. |
| `Fee interest` cannot be waived via Cancel Money Out | related to **CL-516** | Rusty, 2026-09-21 |
| CRD with `DisablePaymentSubmission = true` not rejecting automatically |, | Rusty requested a list 2026-09-15 to quantify balance/arrears/stage impact |

---

## 4. System and product vocabulary

| Term | Meaning |
| --- | --- |
| **Horizon / Horizon2** | The loan and application system. `horizon.moneyme.com.au`, `horizon4.moneyme.com.au`, `horizon-az.moneyme.com.au` are all live front ends onto it. Database `Horizon2`. |
| **CRD** | Credit card product. `ProductId = 111`. NULL for other products. |
| **LOC / Freestyle (FS)** | The legacy line-of-credit product being migrated to CRD |
| **AMZ** | Amortisation |
| **APY** | Autopay (car loans) |
| **PL** | Personal Loans |
| **SPL** | Secured Personal Loan (SPL Broker, D2C private sale, etc.) |
| **E6** | External card platform partner. Declared **source of truth** for CRD balances and card transactions. Anything on the Credit Card tab lives here. |
| **Split / Zepto** | Payment gateways. "Split Sched" and "Split Live" are transaction types; Zepto is where funding and refunds are actually paid out. |
| **NPP** | New Payments Platform. Instant, API-based. EFT is the fallback. |
| **MMP** | Minimum Monthly Payment (CRD) |
| **DH fee** | Dishonour fee, charged when a payment rejects |
| **OD fee** | Overdue fee, charged every 14 days in overdue stage |
| **CED** | Contract End Date |
| **PP** | Payment Plan |
| **DNC** | Do Not Contact |
| **HS** | Hardship |
| **DPD** | Days Past Due |
| **MB** | Bank statement data on the application |
| **ECA** | The self-service web payment portal |
| **Shuffle** | Regenerate the repayment schedule |
| **CV** | Contract Variation |
| **Soft execution** | Run a data fix script inside a transaction and return the result set without committing |
| **Special Handling** | The stage that replaced "Suspended". Unlike Suspended it is **designed to keep payments active**, which caught the Collections team out in June 2026. |
| **G3APIBot** | Slack bot. `reset {email}` in `#unblock-account-request`; also serves G3/API QA requests in `#api-to-fe`. |
| **Uptrace** | OpenTelemetry-based observability replacing Sentry on several services |

---

## 5. Seasonal and calendar effects

- **Easter**: the CRD payment grace period was extended to 7 days in April 2026,
  which broke forgiven interest and cashback for some customers and needed a
  data fix. Expect the same class of issue around any grace-period change.
- **End of month**: Harvey is on EOM cashflow reports; payments escalation
  capacity drops.
- **Philippine public holidays**: the AU side posts a heads-up in
  `#autopay_feedback` that resolution will be slower. Worth doing the reverse.
- **Christmas/New Year**: December 2025 saw a batch of Zepto **late dishonours**
  arrive in February 2026 dated 31/12/2025 (19 of them), all needing reversal.
  Late dishonour recoveries arrive in bulk and long after the fact.

---

## 6. Non-obvious behaviours worth remembering

1. **Late dishonours arrive weeks or months later.** Zepto "late return
   recoveries" have arrived dated up to 6 weeks earlier. They come in batches and
   need bulk reversal, each with an amortisation counterpart.
   (MHD-30342, MHD-30348, COL-4101.)
2. **Horizon does not instantly cancel a scheduled payment when a customer pays
   ad hoc.** It does cancel, but not instantly. Do not raise a defect on the
   basis of checking straight after the payment.
3. **Two shuffles in quick succession duplicate loaded transactions.** Very rare,
   low priority, but it explains "duplicate transactions" reports.
4. **Shuffling on the funding day misses the Dealer/Broker Fee** and produces a
   short schedule.
5. **An account moved manually to Repaid is not actually closed.** Only the payout
   process closes a credit card account.
6. **A Horizon-side deletion of a CRD transaction does not fix it**, because the
   record still exists in E6.
7. **The arrears calculation is anchored to the CED.** An interest hold applied
   after a variation makes the arrears calculation expect a higher balance than
   the account holds, and shows up as a CED discrepancy too (Rusty, 2026-07-15).
8. **`DisablePaymentSubmission` can land on the wrong (new) bank account** if the
   customer gives new details before the rejection response comes back from
   Zepto. See [05-knowledge/rusty-rulings.md](rusty-rulings.md) section 6.
9. **The mobile app's payment reminder push can render `01/01/1900`.** That is
   the default null date leaking through, i.e. the date field resolved to
   nothing. Worked example: app 10002905649, txn 109263685 (the DD had correctly
   been cancelled), reported 2026-08-24.
10. **Settlement confirmation emails can re-fire months later** as pure
    duplicates with no account change behind them. Worked example: loan settled
    17 July 2026, repaid 14 August, settlement emails re-sent in the early hours
    of 16 September. Verify before treating as a new event.
11. **Interest-bearing display on CRD only ever moves on statement day.** Any
    "interest appeared out of nowhere" report should be checked against the
    statement date first.
12. **`Special Handling` keeps payments running.** The old `Suspended` stage
    paused them. Moving a batch of pre-sale accounts to Special Handling in
    June 2026 required an urgent datafix to cancel active schedules before a
    separate fix went live that would have let those payments submit.
13. **Avoid `&nbsp;` in Horizon email templates.** It can end up as U+FFFD
    replacement characters rendering as boxed question marks in Outlook.
14. **`ProductId` is 111 for CRD and NULL otherwise.** Use `ProductTypeId` for
    everything else.

Timings and batch windows are in [batch-jobs-and-timings.md](batch-jobs-and-timings.md). Working-as-designed behaviours are in [working-as-designed.md](working-as-designed.md). Ownership is in [escalation-map.md](escalation-map.md).
