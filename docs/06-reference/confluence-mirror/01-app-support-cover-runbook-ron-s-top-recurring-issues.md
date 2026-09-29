# App Support Cover Runbook: Ron's Top Recurring Issues

Mirror of the Confluence page "App Support Cover Runbook: Ron's Top Recurring Issues".

Last reviewed: 23 September 2026
Sources: Confluence AS page 3131015188, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS (Platform and Support) · Page id: 3131015188 · Last updated: 26 Aug 2026
- Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/3131015188/App+Support+Cover+Runbook+Ron+s+Top+Recurring+Issues

**Purpose.** So App Support BAU can be picked up by someone else while Ron Magpusao is on
VL/SL. Covers the recurring issue types that account for roughly two thirds of his ticket
volume, with the symptom, sample tickets, root cause and the exact fix for each.

**Owner:** Ron Paolo Miguel Magpusao · **Backup:** Michael Dela Torre · **Manager:** Julius Serrano

## How this page was built

All 801 Jira issues raised by Ron between Oct 2023 and 26 Aug 2026 were pulled and grouped
into recurring issue types. Ranking is based on the **last twelve months only**
(Sep 2025 to Aug 2026, 508 tickets, averaging 42/month) because the all time list is
distorted by work that no longer exists: the LoC Shuffle Script ran 33 times up to
Mar 2025 and has not appeared since.

Section 01 (Funding and disbursement) is written from the working thread with
**Albert Rick Martires**, who owns the Payment API and funding path.

**Eleven sections, not ten.** Customer login sits at 11 by ticket count only because OTP and
SMS cases get filed under Comms (06). Counted together it is about 39 tickets in the last
twelve months, which would place it around 6th. Most login work never becomes a ticket at
all because account unblocks run through G3APIBot in Slack. Treat it as a top five item.

## Start here before touching anything

1. **Run the AI investigator first.** In Claude, type `investigate MHD-35773` (substitute the
   ticket). It reads the ticket and its comments, routes the symptom against the documented
   datafixes, and hands back lookup queries, a backup statement, the filled in fix,
   verification steps, a backout plan and a risk rating. It has no database access and never
   executes anything. See page 3116564495.
2. **Prefer the parameterised procedures over raw SQL.** Sixteen `dbo.AppSupport_*`
   procedures cover the most common fixes. See page 2485059655.
3. **Search the historical catalogue before writing anything new.** Ctrl+F on
   SQL Data Fix scripts (page 519602304). Take the *shape* of a script, never the literal
   IDs, emails or plate numbers.
4. **Nothing runs in prod by your own hand.** Attach the script to the current monthly
   umbrella ticket, then request execution in `#datascript-requests`.

## The data fix workflow

1. Write the script and attach it to the current monthly umbrella ticket. As of August 2026
   that is MHD-35277 · [App Support] Data Fix - 2026-Aug. A new one is created each month.
2. Number it sequentially within that ticket ("Data fix # 1", "# 2"...). DB Portal
   auto reviews and posts a verdict.
3. Post in `#datascript-requests` tagging **Victor Alvarez** and **Krizza Rosales**:
   "Hi @Victor @Krizza need your help running Data fix # N in prod please. Please do not
   close the ticket. Thank you!" plus the ticket link.
4. Comment back on the originating ticket, "Done implementing the fix for this request.
   Thanks!", and close it. Leave the monthly umbrella ticket open.

**Two landmines.** `AppSupport_UpdateCustomerAccount` has no parameter defaults: it
overwrites `Username`, `Password`, `BrandId` and `IsActive` together, so a wrong `@Password`
resets the customer's login. And "Incorrect URL ID Fix" carries a named approval gate:
**Jeffrey Lu** and **Jon Wu** plus the DB team must sign off, regardless of how low risk the
change looks.

---

## 01 · Funding and disbursement

58 tickets · 11.6%, the single biggest bucket. Reported in `#pending-funding-checks`, or
Albert sends the scripts straight to you in Slack.

### Understand the flow before you fix anything

Albert's description of how disbursement funding actually runs:

- **First disbursement:** validate (raise a task if it fails) → fund to Zepto → generate
  amortisation → create money out → **move to Fund Sent**
- **Every disbursement after that:** validate (raise a task if it fails) → fund to Zepto

So an application can legitimately sit at **Fund Sent with a later disbursement still
unfunded**, held by a validation task. That is the designed flow, not a defect. This is the
question Ops asks most often about partially funded loans.

### A · Retry Funding: the default fix, and the one you will run most

**Symptom.** A funding follow up task was raised and the application has not funded.

```sql
DECLARE @ApplicationId BIGINT = 10003035734;
DECLARE @FundingId     BIGINT = 1517941;
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@ApplicationId AS NVARCHAR(20)), ' - Retry Funding');
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentSubmissionStatus] @ApplicationId, @FundingId, 91001, NULL, NULL, @Notes;
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] @ApplicationId, @FundingId, 0
```

**Both statements are required.** The second one, `IsProcessed` back to `0`, is what lets the
process pick the record up again. Running only the first will look like it worked and will
not retry.

### B · "Float account reached set limit of 400,000.00": safe to retry, no data fix

**The single biggest source of "the app is stuck funding" reports, and as of August 2026 it
needs no data fix at all.**

**Cause.** A long standing Payment API validation rule caps the amount funded per 5 minutes
per product. For APY that is $400,000. When an application hits the cap the validation
message comes back and a task is raised. **The payment never reached Zepto**, so it is safe
to retry.

**Fix.** Retry it. Albert changed the handling so the real message now appears in the task
notes rather than the old generic text, specifically to stop App Support data fixing these.
If Ops asks, that message means "safe to retry", not "stuck". Raised with Jamie.

### C · No TransactionId mapped in the Funding record

**Cause.** The funding record is created but the TransactionId is never mapped to it. Albert
sweeps for these and sends batches, typically 8 to 29 at a time, roughly weekly.

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateTransactionId] 10003029182, 1516235, 108844212
```

Arguments are `ApplicationId, FundingId, TransactionId`. **Run in batches of 10 with an
interval between batches**: Ron's own practice on the large lists, and it avoids the float limit.

Sample tickets: MHD-35904 (29 records), MHD-35207.

### D · PayAnyone stuck at Authorized (CRD): close the task, do not data fix

**Symptom.** A PayAnyone transaction sits at *Authorised* instead of *Cleared*, and funding
appears stuck.

**Cause.** An earlier PayAnyone failed and raised a funding failed task. The customer retried
and that one succeeded, but a condition in funding blocks completion while the old task is
still open.

**Fix.** Close the funding failed / funding follow up task at
`horizon.moneyme.com.au/Task/ApplicationTasks/<id>`. Nothing else. Albert hit this three
times in one month; the permanent fix is API-6134, Remove unnecessary condition blocking CRD
Pay Anyone funding events.

Sample ticket: MHD-35999.

### E · Invalid Funding BSB

Two different messages that need two different responses.

`Invalid Funding BSB Format. [ 033089]`, note the leading space. The SortCode was saved with
a space in it, and it will keep re raising the funding follow up until fixed:

```sql
SELECT CommissionBankId, LeadSourceId, SortCode
FROM Horizon2.dbo.CommissionBank
WHERE LeadSourceId = 8187;
```

Strip the space, then ask Ops to complete the outstanding task. Jeff Lu loads this data.
Sample: MHD-35359.

`Invalid Funding BSB (Returned by Third Party AusPayNet) | Sort Code: 201086`, genuinely
invalid at AusPayNet. Not a data fix; the correct bank details have to be supplied.

### F · Application cancelled but funding still live

```sql
DECLARE @datecompleted DATETIME = GETDATE()
EXEC Horizon2.[dbo].[FundingDataFixUpdatePaymentFundingStatus]
     10002964942, 1501936, 91004, 1, 0, @datecompleted,
     'Application: 10002964942 - Application is cancelled',
     'Application: 10002964942 - Application is cancelled'
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10002964942, 1501936, 1
```

Sample ticket: MHD-35069.

### G · Already funded in Zepto but the stage never moved

**Check Zepto first.** If the funded date and contract end date are both present, the money
has gone: do not re run funding. Move the application to **Fund Sent** stage (Jamie does the
stage move).

One recurring variant will not go through until the customer has a **brand id 5 contact and
email**: add those first. Samples: MHD-35863, MHD-35970.

### H · IsProcessed stuck on FundingScheduling for one disbursement

```sql
EXEC Horizon2.[dbo].[FundingDataFixUpdateIsProcessed] 10003031096, 1516542, 0
```

### I · Delete funding records: last resort, ask first

```sql
EXEC dbo.AppSupport_DeleteFundingRecords
    @ApplicationId = 10000000000,
    @MHDTicket     = 'MHD-00000',  -- backup will NOT run if this is empty
    @CreateBackup  = 1,
    @CloseTask     = 1;
```

Use when the disbursements have been replaced and the old funding rows are blocking the
re run. **Confirm with Albert before deleting**: his answer is often "close lang ng task"
instead, and closing the task is far cheaper than deleting and re funding.

### J · Insufficient funds

Frequent, and not yet cleanly handled. The task notes still carry the generic "safe to close"
text, so you have to open `fundingactivity` to find the actual cause. Albert has this as his
next fix target. Until then, check the activity record before responding to Ops.

### Funding status IDs

| ID | Meaning |
| --- | --- |
| `91001` | Reset. Restarts the funding process from the beginning. This is the retry value. |
| `91004` | Cancelled / stopped. Used when the application itself was cancelled. |
| `91005` | Mark as funded (when a PaymentAccountFunding record already exists). |
| `91007` | Where a successful retry lands. Republishes the FundSentEvent. |

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

**Escalate funding to Albert Rick Martires** (Senior .Net Developer / Team Lead, G3
Engineering). He owns the Payment API and funding path, sweeps for broken funding records
himself, and sends the scripts. If a funding symptom is not on this page, ask him before
writing anything.

---

## 02 · Customer and company data corrections

44 tickets · 8.8%

**How it arrives.** A direct instruction from Ops, not a bug report: "Please update the ABN
Active Since date to 08 Jun 2022", "Request to remove the mobile number ... as the number
belongs to [customer name removed]". Occasionally it surfaces as a UI blocker instead: the
Customer tab simply will not save.

### Sample ticket A, MHD-35960: remove incorrect mobile number from a customer

**Cause.** Unvalidated free text entry: a mobile keyed against the wrong customer.

**Fix.** *Neutralise, do not delete.* The number was overwritten with a placeholder rather
than removed (for an email the placeholder is `mail@mail.com`):

```sql
EXEC dbo.AppSupport_UpdateCustomerContactNumber
    @CustomerId          = 000000,
    @CustomerContactNoId = 000000,
    @NewNumber           = '0400000000',
    @IsActive            = 1;

SELECT * FROM CustomerContactNo WHERE CustomerId = 000000;
```

Equivalents for the other contact fields: `AppSupport_DeleteCustomerContactNumber`,
`AppSupport_UpdateCustomerEmail`, `AppSupport_DeleteCustomerEmail`.

### Sample ticket B, MHD-34134: data fix ABN Active Since date for application 10002987390

**Cause.** A brief ABR cancellation resets the active since date; in this case the ABN was
cancelled for only four days in May 2026. There is no self service re sync, so every
correction becomes a manual data fix. See also MHD-34459 and MHD-34022.

**Fix.** There is no `AppSupport_` procedure for this. Verify the correct date against the
ABR record first, then apply a targeted UPDATE and attach the script to the monthly datafix
ticket.

---

## 03 · Transaction reversal, duplicates and cancellation

43 tickets · 8.6%

**How it arrives.** Two shapes: internal undo requests ("Cancel the funding as the
application has been cancelled") and external duplicate claims, most often "Zepto has raised
a DDR Dispute claiming they are duplicates".

### Sample ticket A, MHD-34308: cancel pending Pay Anyone transactions for account 10002957600

**Cause.** Pay Anyone SMS transactions stranded at the provider: pending over 24 hours and
not appearing in Zepto, so they can neither complete nor be retried by the customer.

```sql
EXEC [dbo].[PATransactionDataFixUpdateTransaction] <ApplicationId>, <TransactionId>, 67006, 1, NULL, NULL;
EXEC Horizon2.[dbo].[ComputeSlidingLimit] <ApplicationId>, 1, 1;
```

For a plain transaction cancellation (sets `TransactionStatusId = 1005`):

```sql
EXEC dbo.AppSupport_CancelTransaction
    @TransactionId = 000000,
    @ApplicationId = 10000000000,
    @Notes         = 'MHD-xxxxx cancelled per request';
```

### Sample ticket B, MHD-35813: duplicate direct debit transactions for Zepto DDR Dispute

**Outcome: no fix required.** Both debits were valid. The customer entered a Betterway
payment arrangement *after* the debits had already processed. We stop direct debits as soon
as Betterway notifies us, and that notification arrived late.

**Lesson.** Roughly one in seven of these needs no data fix at all. Confirm the duplicate is
real against the account and the payment arrangement timeline *before* writing anything.

---

## 04 · Application stuck at the wrong stage

42 tickets · 8.4%, almost always the same sentence: "Application 10003024984 is stuck at the
'signed off' stage".

**Work section 01 first.** Most "stuck at Signed Off" tickets are a funding problem wearing a
stage label. Run through 01-A (retry), 01-B (float limit), 01-D (open task blocking
completion) and 01-G (already funded in Zepto) before you consider deleting anything.

### Sample ticket A, MHD-35218 / MHD-35132: stuck at Signed Off after disbursements changed

**Cause.** The disbursements were replaced after sign off and the old `Funding` and
`FundingScheduling` rows survived, blocking the new funding run.

**Fix.** `AppSupport_DeleteFundingRecords`, see 01-I above, including the "ask Albert first"
caveat.

### Sample ticket B, MHD-35863: data fix for application 10003038152 stuck in Signed Off status

**Cause.** Funding halted mid flight on a server timeout. The funds had *already left via
Zepto*, but the completion fields never reached a terminal state, so the application never
advanced and no comms or contracts were generated. This one also needed a brand id 5 contact
and email on the customer.

**Fix.** See 01-G: confirm in Zepto, then move the stage rather than re running the transfer.

---

## 05 · Direct debit and payment failure (Zepto, Ezdebit, Split Sched)

40 tickets · 8.0%

**How it arrives.** A payment that silently did not happen: "direct debit has been pending
since 07/08/2026", "still showing a 'proposed' status", "Zepto funding failed".

### Sample ticket A, MHD-35706: missing Default Payment Mode for DD transactions

**Cause.** The mandate is accepted but the Default Payment Mode was never written, so nothing
debits. Described in the ticket as "a cohort based issue affecting specific onboarding
batches". The linked MHD-34569 listed 12 applications missing configuration.

```sql
EXEC dbo.AppSupport_UpdateToDefaultPaymentMethod @ApplicationId = 1000123456;
```

The procedure has **no INSERT path**. If the application has no `AdditionalDataTypeId = 32`
row at all, the EXEC silently does nothing and you need the raw INSERT (item 53 on the SQL
Data Fix scripts page). Check with the detection query at item 84 first.

**Always widen the blast radius.** The ticket asks explicitly to "check other applications
from the same cohort to prevent future failures before their transaction dates". This class
is never a single account.

### Sample ticket B, MHD-34668: update default payment method from Split Sched to Direct Credit for CRD accounts

**Cause.** The CCC→CRD migration script carries `DisablePaymentSubmission` over from the
original CCC application. A pre migration "payment denied" event then blocks all future
submissions.

**Fix.** Set `DisablePaymentSubmission` to `NULL`, and switch the default payment mode from
Split Sched to Direct Credit. Split Sched cannot process while the flag blocks submission.

---

## 06 · Comms delivery, email, SMS and notices

37 tickets · 7.4%

### Sample ticket A, MHD-35539: investigate in SendGrid

**Cause.** Once an address lands on a SendGrid suppression list (**Bounced**, **Blocked** or
**Spam Reports**) every future email to it fails silently, and the send path keeps retrying it.

**Fix.** Find the address in SendGrid, remove it from whichever list it is on, then tell the
requester to retry. There is no self serve button in Horizon yet: MHD-35799 requests one and
is still Pending.

### Sample ticket B, MHD-35362: SMS login failure for customer application 10002405188

**Outcome: no fault found**, the largest single bucket here. Delivery logs showed every OTP
delivered; the messages were spam filed or blocked customer side. See section 11 for the full
triage.

---

## 07 · Account, application and profile merges

34 tickets · 6.8%, the all time number one at 79 tickets, but only 43% of those fall in the
last twelve months.

### Sample ticket A, MHD-34750: merge duplicate production accounts to resolve Forgot Password error

**Cause.** Two customer records exist for one person under separate CIDs, one carrying the
mobile number and one without, and the API pulls the record missing the phone number. Horizon
creates a new customer record instead of matching the existing one at application time.

```sql
EXEC AppSupport_MoveAppToCustomer
    @ApplicationId = 10000000000,  -- app to move
    @CustomerId    = 0000000;      -- main account
```

The procedure raises an error if it matches zero rows, which is your safety net against a
wrong ID.

### Sample ticket B, MHD-35066: merge application note to customer record

There is **no procedure** for notes or emails. These are raw updates (items 30 and 32 on the
SQL Data Fix scripts page):

```sql
UPDATE Note         SET ApplicationId = <target> WHERE NoteId = <id>;
UPDATE InboundEmail SET ApplicationId = <target> WHERE InboundEmailId = <id>;
```

---

## 08 · Rates, fees and loan terms

33 tickets · 6.6%

### Sample ticket A, MHD-34728: zero interest rate on ApplicationCharge for account 10002996207

**Cause.** The rate fails to populate on the charge record. The ticket asks to "apply the
existing fix script": a known recurring defect with an established workaround.

**Fix.** Apply the existing fix script, **then rerun the Funding Event.** The rerun is load
bearing; the data fix alone is not sufficient.

### Sample ticket B, MHD-34449: update interest rate for account 10003003090

**Cause.** Approved at 19.35% instead of 17.35% because of an erroneous payslip load: bad
income data drove a risk priced rate.

**Fix.** *Not a plain UPDATE.* The loan has to be shuffled in Horizon against the new APR so
the schedule re amortises. Escalate to Rusty (Joshua Allen) rather than running it self serve.

---

## 09 · Vehicle, asset and seller details

24 tickets · 4.8%

### Sample ticket A, MHD-33222: update fuel type and remove EV discount

**Fix.** Update the vehicle attribute **and remove any pricing concession tied to it.**
Correcting the vehicle from electric to petrol also required removing the EV discount; fixing
the field alone would have left an unearned discount on the loan.

### Sample ticket B, MHD-35191: manual data fix for seller details on application 10003030283

**Cause.** Horizon will not persist edits to asset and seller fields past a certain
application stage, which is why all of these become data fixes rather than user edits.

**Read the request body carefully.** This ticket arrived with its fields transposed, an email
address in the Mobile field and a phone number in the Email field. Working it from the text
alone writes the email address into the mobile column.

---

## 10 · Horizon platform and UI errors

23 tickets · 4.6%, a catch all bucket, but two causes in it are concrete and reusable.

### Sample ticket A, MHD-35818: infinite loading on 'calculating your finance details'

**Cause.** `IsEditedVehicleDetails` incorrectly set to `1` on a pre approval application.
**Fix:** reset the flag. The permanent fix was requested and not delivered, so expect this to
recur.

### Sample ticket B, MHD-35954: Android Virtual Card provisioning failure

**Cause.** A repeat customer case where a new account was never created in **E6** (the card
issuing platform). **Fix:** "Update the customer number in E6 (append with X) and create a
new application from scratch, which creates a new E6 account."

---

## 11 · Customer login failures

About 39 tickets when OTP cases are counted in. Ranked 11th only because OTP and SMS cases
file under 06. In practice this is a top five item, and most of it never becomes a ticket at
all: account unblocks and resets run through **G3APIBot** in `#unblock-account-request`.

**How it arrives.** From Ops in `#app-support`: "we have a customer unable to login to the
app. No duplicate mobile/email found."

### Triage checklist, in this order

1. **Duplicate customer account**: duplicate mobile or email. The most common real cause; if
   found, it becomes issue 07.
2. **Mismatch between the mobile number and email** on the account.
3. **Empty or NULL password.**
4. **Last login attempt in the DB**, and whether it succeeded. Login history is only visible
   **within 7 days**.
5. **FullStory session replay**: shows where the customer actually stopped. In one case it
   showed the SMS was triggered but the customer never entered the code.

**Two things that mislead people constantly.**

The verification code is **always SMS, never email**.

A "successful login" in our data only means the **password was accepted and they reached the
OTP step**. It does not mean they got in. Quoting a successful login timestamp at Ops without
that caveat causes arguments.

### Sample ticket A, MHD-34426: customer login failure after duplicate ID fix

**Cause.** A prior duplicate ID data fix left the login path pointing at the wrong record.
Check the duplicate/merge history before assuming the app is at fault.

### Sample ticket B, MHD-34604 / MMM-15339: incorrect login prompt for customer without an active CRD account

**Cause.** A PL only customer is served a CRD prompt on login. Not a data fix: raise to the
mobile team.

**Fix.** Post in `#app-support-mobile-team` with the application note link and the MHD
ticket, cc Aus / Paul / Stefan. Related: MHD-35643, customer can log in on web but not on the
iOS app.

### Most common outcome: no fault on our side

The OTP was delivered and the customer has MoneyMe blocked or spam filed. What to tell Ops:

- Ask the customer to search their SMS app for messages from **"MONEYME"**.
- On Android: Google Messages → profile icon → **Spam & Blocked**.
- Customers with poor repayment history often block us deliberately, which is why delivery
  shows successful on our side and they still see nothing.

Paste the delivery log and the last login timestamp into the ticket as evidence and close. Do
not write a data fix for this.

Reference: Common Login SQL Data Fix Scripts (page 1398210569).

## What is no longer on the list

| Issue type | All time | Last 12m | What changed |
| --- | --- | --- | --- |
| **LoC Shuffle Script** | 33 | 0 | A standing scheduled run from Jan 2024 to Mar 2025, then gone entirely. If a "LOC unable to shuffle" ticket does appear, the engine procs are on the SQL Data Fix scripts page (items 8, 21, 22): `CalculateWithrawalAllocationAll`, `UpdateMinimumPaymentAmount`, `UpdateAmounts`. Note the misspelling is in the real procedure name. |
| **Identity verification (ID Kit / URL ID)** | 32 | 5 | "Incorrect URL ID Fix" was a repeat item through late 2024 and early 2025, now a trickle. Remember the Jeffrey Lu / Jon Wu / DB team approval gate if one appears. |

## Who to escalate to

| Situation | Go to |
| --- | --- |
| Anything funding or Payment API, including scripts not on this page | Albert Rick Martires (G3 Engineering). He owns this path and usually finds the broken records before we do. |
| Running any script in prod | Victor Alvarez, Krizza Rosales, `#datascript-requests` |
| Stage moves; rate changes needing a re shuffle; "repayments too high" | Jamie (stage moves), Joshua Allen / Rusty (rates, Ops judgement) |
| Mobile app and login prompts | `#app-support-mobile-team`, Aus, Paul, Stefan |
| Late dishonour, reverse DDAC / reverse payment | Michael Dela Torre |
| Twilio / SMS | Ask the reporter for a network test first, then the Comms Team (Jap / Aina) |
| Incorrect URL ID Fix | Jeffrey Lu and Jon Wu plus the DB team, mandatory, regardless of risk rating |
| Split account creation failures, debit account errors | Christopher Enriquez (queries), Jess Leal (debit account errors) |
| Anything you cannot identify | Julius Serrano, do not improvise a production data fix |

## Known gaps recorded on this page

In seven of seventeen tickets sampled across merges, rates, assets and platform bugs, **the
SQL was pasted as a screenshot rather than text**, so it cannot be searched or reused. If you
close a ticket during cover, paste the script as a code block.

Several recurring defects (zero rate `ApplicationCharge`, `IsEditedVehicleDetails`, `TinyUrl`,
and the CRD PayAnyone blocking condition in API-6134) are being data fixed each time rather
than permanently fixed. And the most valuable funding knowledge on this page came out of a
Slack thread, not the tickets.

---
