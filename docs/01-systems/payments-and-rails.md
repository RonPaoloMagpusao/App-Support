# Payments and rails

Every payment rail Horizon uses, which products ride on it, its timing and clearing windows, the failure modes we see, and the error strings that identify each one.

Last reviewed: 23 September 2026

Sources: Confluence 580845583 (Zepto Process), 2286321665 (Zepto / Split Account Task Handling Guide), 1772126209 (Payment Channels), 2385150262 (Pending Funding and Refund support), 3131015188 (App Support Cover Runbook), 426082342 (APY Environments); [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 2, 6, 7 and 9; [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) sections 2 to 7.

## Name warning

The Cover Runbook's section heading spells it **Ezdebit**. The database column is `Application.EzidebitAccountId` and the stage register spells the transaction types **Ezi Sched** and **Ezi Live**. The provider is Ezidebit. Search for both spellings.

## The rails at a glance

| Rail | What it is | Products | Identifier in Horizon |
| --- | --- | --- | --- |
| Zepto | The funding and direct debit provider. Money out and money in | All current products | `Payment.dbo.PaymentAccountFunding`, reference form `PB.19ctj7` |
| Split | Zepto's debit account construct. "Split account" is the customer's debit mandate | All current products | `Application.SplitAccountId`, `Payment.dbo.SplitAccount`, Debit Accounts tab |
| Split Sched | Scheduled direct debit through Split | All current products | Transaction type `Split Sched` |
| Split Live | Ad hoc / immediate debit through Split | All current products | Transaction type `Split Live` |
| Split Auto Retry | Automatic retry of a failed Split debit | All current products | Transaction type `Split Auto Retry` |
| Ezidebit | Legacy direct debit | Legacy accounts | `Application.EzidebitAccountId`, types `Ezi Sched`, `Ezi Live` |
| Direct Debit Auto Retry | Legacy DD retry | Legacy accounts | Transaction type |
| Direct Credit | Customer bank transfer into MoneyMe's account | All | Transaction type `Direct Credit`, `TransactionTypeId = 1` |
| Stripe / Auto Stripe / Debit Card Sched | Scheduled debit card payments | Built for CRD, works on any product | Default payment method `Debit Card Sched` |
| Eway | Card payments | MME card payments | `Application.EwayAccountId`, Eway log on the transaction |
| Credit Card | Agent and self service card payments | All | Transaction type `Credit Card` |
| PayAnyone | Customer initiated transfer via an SMS link | CRD | `PATransaction` |
| NPP, EFT fallback | The underlying transfer network used by Zepto for money out | All | Not surfaced in Horizon |
| BPAY | SocietyOne legacy. Not supported, only reconciled | SocietyOne legacy | Arrives as Direct Credit |
| PayTo | In flight, not yet in support scope | | |
| E6 | The card issuing platform behind CRD and Virtual Cards | CRD, Freestyle Virtual Cards | Credit Card tab |

---

## Zepto

### What it is

MoneyMe connects to Zepto to send funds out (disbursement, refunds) and to direct debit customers (Confluence 580845583). Zepto is where funding and refunds are actually paid out ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7).

Integration shape:

- We create a profile/account for the customer in Zepto so we can fund and debit them. We send the customer's name, email, bank sort code and account number.
- Zepto's API is protected by **OAuth2**. Credentials come from Zepto and are configured in their portal; MoneyMe holds an admin account there. `[CREDENTIAL REDACTED - Confluence page 580845583]`
- We **IP whitelist** Zepto's static IP on the API they connect to.
- Zepto connects back **via webhook**. The endpoint is publicly available and protected by IP whitelisting plus an **HMAC** hash verifying payload integrity.
- Every other endpoint requires OAuth2, so Zepto cannot reach them.

Because Zepto requires contact details at fund submission, funding reads `CustomerContactNo` and `CustomerEmail` matching on the application's BrandId. A missing brand row blocks funding. See `horizon-database.md`.

### Timing

| Thing | Timing | Source |
| --- | --- | --- |
| Zepto next response | Normally **17:30 on the due date**. A 03:30 response means Zepto is running late and usually resolves itself | Rusty, `#app-support`, 2026-08-14 |
| Split Sched processing | Was after **17:30**. Since 2026-08-26 processes from as early as **08:00** | Rusty, `#solutions_memorandum`, 2026-08-26 |
| Split Sched clearing | **2 business days**. Bill satisfaction logic has to allow for this | Rusty, `#app-support-crd`, 2026-07-22 |
| Late dishonours | Arrive **weeks to months** later, in batches. December 2025 dishonours dated 31/12/2025 arrived in February 2026, 19 of them | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 8 and 9; MHD-30342, MHD-30348, COL-4101 |

### The float limit

A Payment API validation rule caps the amount funded **per 5 minutes per product**. For APY the cap is **$400,000**.

- Error string: `Float account reached set limit of 400,000.00`, in the task notes.
- **The payment never reached Zepto, so it is safe to retry.** No data fix is needed (Confluence 3131015188, section 01-B).
- Albert changed the handling so the real message now appears in the task notes rather than the old generic text, specifically to stop App Support data fixing these.
- Bulk runs should be spaced 5 minutes apart, or run in batches of 10 with an interval between batches.

This is the single biggest source of "the app is stuck funding" reports.

### Confirmation of Payee

CoP validation runs on the Zepto side. QA test accounts are whitelisted past it with `AddCoPAccountWhitelistFromDisbursement`, which writes to `dbo.CoPAccountWhitelist` (Confluence 2385150262). **QA only.**

### Escalation and the verification emails

Production Zepto concerns escalate to the **CTO and Lary** (Confluence 426082342). Zepto emails MoneyMe to verify funding when a customer's bank flags it, most often personal loans and the deposit, and also loan repayments in suspected mule account cases. Suspected mule accounts are consulted with Louise before responding (Confluence 2760769540).

---

## Split accounts and their tasks

Two Horizon tasks carry Split failures (Confluence 2286321665).

### Task: Action - Check Split Account

Generated when a payment fails with a terminal Split error code.

| Error code | Meaning | Action |
| --- | --- | --- |
| `incorrect_bsb` | Invalid BSB or account number | Review bank statements and uploaded docs; if unclear, contact the customer; update Application > Bank Details; confirm the Debit Accounts tab shows the Split account **Active** |
| `payment_stopped` | Customer or bank has stopped or blocked the debit | Outbound call; ask for the stop to be removed or for new details; update Bank Details; validate in Debit Accounts |
| `account_closed` | Account no longer active | Obtain a replacement account; update Bank Details; validate in Debit Accounts |
| `incorrect_account_number` | The account number on the bank statement is genuinely wrong. "This should be the first thing we check before raising this as an issue" (Rusty, `#app-support`, 2026-05-26) | Not a defect. Get correct details |

Close out by confirming the Split account is active, the next scheduled debit aligns with the updated details, and a note records the error code, actions taken, contact attempts and updated details.

### Task: Error Split Create/Update Account

Raised when Horizon tries to create or update a Split account and creation fails at the provider. Usually immediately after funding, when the first debit account is being created, before any schedule or transactions exist.

**The fix is to close the task.** Closing it forces Horizon to re-attempt the Split account creation; that is expected behaviour, not a workaround. Then check the Debit Accounts tab shows an Active Split account and the Transactions tab has a repayment schedule. If it is still missing after the retry, note it and escalate to Product Support or Tech.

This task also blocks transactions loading on the account, because there is no valid Split account to debit against (Rusty, 2025-09-18, task 10002547581).

### Accounts on manual repayments

If an account has been paying manually for 2 to 3 months, update the default payment method to match how they are actually paying (DC or CC), send Email Template **2017 - Switch to Manual Payments (Good Standing Order)** with the substituted wording, clear the task, and note it (Confluence 2286321665).

---

## Direct debit behaviour that is working as designed

- **Automatic payments only work if they match the default payment method.** You cannot schedule a Split Sched DD on a customer whose default is Debit Card Sched, and vice versa. To schedule the other method you must change the default to match. No ETA on a fix (Rusty, `#solutions_memorandum`, 2026-08-12 and 2026-08-21; live example transaction page 10002828260).
- **Horizon will not submit a DD when the balance is $0.** If a CRD customer has a $0 balance and a payout figure is generated to capture unbilled interest, the customer must pay manually. Tell them up front (Rusty, `#solutions_memorandum`, 2026-09-08).
- **Horizon does not instantly cancel a scheduled payment when a customer pays ad hoc.** It does cancel, but not immediately. Do not raise a defect on the basis of checking straight after the payment ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 9).
- **The non-CRD cancellation rule.** An ad hoc self service payment should cancel an upcoming Direct Credit dated in the future, dated today, or up to 3 business days in the past. Rusty verified in the same thread that the rule was working in the vast majority of cases and that two Ops reports that day were invalid examples by coincidence (2026-08-13). Verified-good examples: 10003031354, 10002965976, 10002895294, 10002750980, 10002749746, 10002810327, 10002813134. Rules documented at Confluence OP 44630030, Partial and Custom Payment Rules.
- **CRD does not use the custom/partial rules at all.** CRD cancels on bill satisfaction. Cancellation still failing after bill satisfaction **is** a defect, MHD-33265 (Rusty, 2026-05-28).
- **Debits taken before a third party payment arrangement started are valid.** We stop direct debits as soon as Betterway notifies us; the notification often arrives after the debits have processed (MHD-35813). Roughly one in seven duplicate claims needs no data fix at all.

### DisablePaymentSubmission

Rusty's own spec of intended versus actual behaviour (`#horizon-collections-team`, 2026-03-17):

> Intention: we submit a payment to Zepto and get a response with one of the listed reasons, account closed being the main scenario. We then prevent future submission and immediately reject the transaction. To reset, the bank account must be changed, which creates a Split Create/Update Account task and sets Disable Payment Submission to false.
>
> Problem: the customer contacts us before the Zepto response arrives and gives the new account. The Split Create/Update Account task is raised. Later the payment is rejected, and the **new** account is set to Disable Payment Submission.

So `DisablePaymentSubmission` can land on the wrong, new bank account. The requested rule is: when a payment is rejected for a relevant reason, if the Split account was already updated, do not disable submission on the new account.

Separate open thread: CRD accounts with `DisablePaymentSubmission = true` are not rejecting automatically. Rusty asked for a list on 2026-09-15 to quantify the balance, arrears and stage impact.

The CCC to CRD migration script carries `DisablePaymentSubmission` over from the original CCC application, so a pre migration "payment denied" event blocks all future submissions. Fix: set it to `NULL` and switch the default payment mode from Split Sched to Direct Credit (MHD-34668).

### Card payment racing the direct debit

If a customer pays by card at the same moment Horizon submits the DD to Split, the card payment cancels the DD locally but the DD has already gone to Split, so it never updates to pending then cleared. The fix is a data fix on the cancelled DD to cleared (Rusty, `#unsaved-card-payments`, 2026-02-25, customer paid at 05:28).

---

## Ezidebit

Legacy direct debit provider. Surfaces as `Application.EzidebitAccountId` and transaction types `Ezi Sched` and `Ezi Live`. Both types are in the list eligible to auto-move an AFCA Arrangement account to AFCA Arrangement Broken on rejection (Confluence 1293647889).

No current Ezidebit runbook exists in the sources. Unverified: whether any live product still debits through Ezidebit or whether it is dormant on legacy accounts only. Confirm by counting recent transactions of those types.

---

## Direct Credit

### What it is

The customer transfers to MoneyMe's own bank account. Account name **MONEYME**, BSB **062104**, account **10233152** (Confluence 1772126209).

### How it lands in Horizon

Daily downloads of CommBiz (CBA business banking) transaction data produce a batch upload file, created by Raina. Remaining unallocated payments are shared with Ops for manual allocation.

### Identifying it

Payment type **Direct Credit** added by the payment upload tool with status Cleared. Narrow by file upload title **DC Upload**, or by upload agent, at `/PaymentFileUpload/PaymentFileUploads`. Agents also add Direct Credit payments directly, also with status Cleared.

### Caveat

Other upload types arrive through the same channel and look the same:

- **Dividends from external arrangements**: external hardship providers, external debt collectors and debt agreement facilitators pay periodic amounts that are uploaded this way.
- **BPAY payments**: SocietyOne used to offer BPAY. MoneyMe does not support it, but stray BPAY payments landing in the SocietyOne payment account from open accounts are reconciled and allocated.

### Failure mode: junk transactions from a bulk upload

When Direct Credit transactions (`TransactionTypeId = 1`) are bulk uploaded, Horizon spawns interest and allocation transactions that must be removed: `TransactionTypeId IN (18, 28, 32)`. Remove the Daily Interest, Unallocated Interest and Allocated Interest rows. **Do not touch the Direct Credit row.** CRD should return nothing from that selector (Rusty, 2026-09-22, worked example application 10002494594).

---

## Stripe, Auto Stripe and Debit Card Sched

- Auto Stripe is the scheduled debit card mechanism; the Horizon default payment method is called **Debit Card Sched**.
- It was **built for CRD but is not CRD-only**. Rusty: "we do have one non-CRD app with Debit Card Sched as the default payment method (and it works) ... Although auto Stripe was built for CRD, it can and should work across all products" (`#horizon-collections-team`, 2026-08-26; transaction ids 109171848, 109194954; transaction page 10000648562).
- Stripe is also recorded as the IVR payment path in the Credit Card space (Confluence 3131015188).
- **Retries exist for Debit Card Sched** since July 2026. Dishonour fees are **not** added to retries or arrears for CRD; the retry amount should equal the original payment. Retries are on a different cycle for instant payment methods (Rusty, `#solutions_memorandum`, 2026-07-21; reference doc Confluence OP 3033497726, Debit Card Repayments Automatic Retires, the misspelling is in the page title).
- Horizon carries a `Stripe_Accounts` permission tab; granting view on it to all roles was an August 2026 datafix ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).
- CRD cashback grace period: roughly **2 business days** after the MMP due date for instant methods such as Debit Card Sched. Temporarily **7 days** over Easter 2026, which broke forgiven interest and cashback for some customers and needed a data fix. Internal only, do not tell customers (Rusty, `#solutions_memorandum`, 2026-05-28; `#crd_firefighters`, 2026-04-22).

---

## PayAnyone

Customer initiated transfer, sent via an SMS link, used on CRD.

### Failure mode A: stuck at Authorized instead of Cleared

An earlier PayAnyone failed and raised a funding failed task. The customer retried and that attempt succeeded, but a condition in funding blocks completion while the old task is still open.

**Fix: close the funding failed / funding follow up task. Nothing else. Do not data fix.** The permanent fix is API-6134, "Remove unnecessary condition blocking CRD Pay Anyone funding events". Albert hit this three times in one month. Sample MHD-35999 (Confluence 3131015188, section 01-D).

### Failure mode B: stranded at the provider

Pay Anyone SMS transactions pending over 24 hours and not appearing in Zepto, so they can neither complete nor be retried by the customer. Cancel with `PATransactionDataFixUpdateTransaction` using status `67006`, then `ComputeSlidingLimit`. Sample MHD-34308, account 10002957600 (Confluence 3131015188, section 03).

"Pending PayAnyone transfer stuck, cancel it" is item 62 on the SQL Data Fix scripts catalogue.

---

## NPP and the EFT fallback

The best mechanism explanation in the sources, from Rusty (DM, 2026-08-24), on what happens when funds go to a bank account that does not exist:

- We send funds via **NPP**, received virtually instantly. NPP works via API and only works if the account exists.
- If there is an issue with the NPP transfer, **Zepto is set to fall back to old school EFT**, which takes up to 2 business days to be received. The fallback exists to cover an NPP system outage.
- So for a non-existent account: 1 to 2 business days for the funds to reach the other bank, then 1 to 2 business days for them to be returned. **3 to 5 business days total** before the money bounces back.
- Horizon has a process to automatically credit the amount back to the account. Rusty was not sure it is active for CRD. It definitely worked for Freestyle, though it may have only raised a task for an agent to fix manually. Unverified: whether auto credit-back is live for CRD. Confirm with the CRD team before promising a customer an automatic return.
- If the bank details **did** exist, the money lands instantly in someone else's account. We can only ask the recipient to return it. We cannot force them.

---

## Card payments and the self service channels

Source: Confluence 1772126209.

| Initiator | Channel | Login | Payment types | Notes |
| --- | --- | --- | --- | --- |
| Customer | Payment Portal | No | Portal | The URL used in all comms: reminder SMS and email, collection comms, default notices (email versions), agent-sent comms. Shortened for SMS and email. Each URL is unique to the ApplicationId |
| Customer | ECA (Web), card | Yes | Partial ("pay my next payment"), Custom, Full | |
| Customer | ECA (Web), direct debit | Yes | Partial, Custom, Full | ECA still allows DD for the next payment. **Deliberately disabled in the mobile app** because of cancellation and pending time problems when customers pay early close to the submission time of their next payment |
| Customer | Direct Credit | No | Bank transfer | See above |
| Customer | App, card | Yes | Partial, Custom, Full | |
| Customer | App, direct debit | Yes | Custom, Full only | |
| Agent | Over the phone, card | n/a | | The agent uses a payment page built into the Twilio window. Arrives in Horizon as an "ECA User" payment with a **blank** Payment Type |
| Agent | Over the phone or email, direct debit | n/a | | The agent creates the DD on Horizon's transaction page |

Identifying a self service payment: read the Payment Type captured on the transaction receipt or note. A note is posted to the account after each payment, in addition to the transaction records (MoneyIn entry, Eway log).

- Card with Payment Type **Payment Portal**: they used the payment portal link.
- Card with Payment Type **Partial**: they selected "pay my next payment".
- DD with Payment Type **Custom**: they nominated a custom amount.
- DD with Payment Type **Full**: they nominated a full payment.
- Blank Payment Type: mobile app, or the Twilio integration channel. Back end tables distinguish the source.

---

## E6 and CRD payment allocation

E6 is the external card issuing platform and the declared **source of truth** for CRD balances and card transactions. Anything on the Credit Card tab lives in E6, not Horizon, and a Horizon data fix will not change it. A Horizon-side deletion of a CRD transaction does not fix it, because the record still exists in E6 (Rusty, 2026-07-02; [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 1, 7 and 9).

| Thing | Timing |
| --- | --- |
| CRD payment allocations | Processed **overnight**, off a **daily report from E6** (Rusty, 2026-05-22) |
| CRD statements | Monthly. Interest only ever appears in MoneyOut **on the day a statement is issued** (Rusty, 2026-07-02) |
| CRD annual fee | Charged at the **end of the first statement**, not on funding day, changed around 2026-07-02 |
| CRD auto refund | Runs at most **once per 24 hours** per account, although the task may raise more than once (James Wiles, 2026-08-27) |

App Support does not hold E6 or Mastercard logins. Rusty, 2026-09-22: "We could get you logins to E6 and Mastercard, but I don't think it's beneficial, yet." Mastercard admin is Julius Serrano. For E6 updates, ask Mhars Pabalan how he does it. For card network forensics, Murdo is "the final boss of CRD transactions".

---

## Funding and disbursement flow

Albert Rick Martires' description of how disbursement funding actually runs (Confluence 2385150262, 3131015188):

- **First disbursement:** validate, raising a task if it fails, then fund to Zepto, generate amortisation, create money out, move to **Fund Sent**.
- **Every disbursement after that:** validate, raising a task if it fails, then fund to Zepto.

So an application can legitimately sit at **Fund Sent with a later disbursement still unfunded**, held by a validation task. That is the design, not a defect. It is the question Ops asks most often about partially funded loans.

### Retry semantics

Setting the funding status to `91001` restarts the process from the beginning. It does **not** double fund. The record moves to `91007` and republishes the `FundSentEvent`, which is also how a missing amortisation gets generated. `FundingDataFixUpdateIsProcessed` set to `0` is required alongside it, or the retry never happens.

### Error strings and what each one means

| String | Meaning | Response |
| --- | --- | --- |
| `Float account reached set limit of 400,000.00` | Payment API per-5-minute per-product cap. Never reached Zepto | Retry. No data fix |
| `Invalid Funding BSB Format. [ 033089]` (note the leading space) | The SortCode was saved with a space in `CommissionBank`. Will keep re-raising the funding follow up until fixed | Strip the space, then ask Ops to complete the outstanding task. Jeff Lu loads this data. Sample MHD-35359, LeadSourceId 8187 |
| `Invalid Funding BSB (Returned by Third Party AusPayNet) \| Sort Code: 201086` | Genuinely invalid at AusPayNet | Not a data fix. Correct bank details must be supplied |
| "insufficient funds" in the task note | The generic note text. The real cause is in `FundingActivity` | Open `FundingActivity` before responding to Ops. Albert has this as his next fix target |
| `91004, "Your bank account has insufficient funds"` | The QA-side symptom when the Zepto test fund source runs dry. On 2026-05-12 this rejected the whole QA estate, because about 84% of QA apps share one bank fixture | QA only. Incident QAAUTO-1148 |
| `Review - Funding Failed` / `Review Funding Follow up: Please check customer contact details` | A funding validation task. The contact variant means the customer is missing a `CustomerEmail` or `CustomerContactNo` row for the application's BrandId | Insert the missing brand row, then reprocess |

### Already funded in Zepto but the stage never moved

Check Zepto first. If the funded date and contract end date are both present, the money has gone: do **not** re-run funding. Move the application to Fund Sent. One recurring variant will not go through until the customer has a BrandId 5 contact and email; add those first. Samples MHD-35863 (application 10003038152, funding halted mid flight on a server timeout), MHD-35970.

### Monitoring bots

| Bot | Cadence | Channel |
| --- | --- | --- |
| "Stuck in funding for 20 mins" | Hourly, on the hour, 24/7 | `#pending-funding-checks` |
| "Stuck refund for 30 mins" | Hourly, on the hour, 24/7 | `#refund-supports` |

Albert also sweeps for unmapped TransactionIds himself and sends batches of 8 to 29, roughly weekly.

---

## Fees attached to the rails

| Fee | When | Note |
| --- | --- | --- |
| DH (dishonour) fee | When a payment rejects | Not added to CRD retries |
| OD (overdue) fee | Every 14 days while the account is in Overdue stage, regardless of whether the customer is paying | Working as designed. Do not waive (Rusty, 2026-09-01; Confluence OP 121831888, Overdue Fee Structures) |

Known defect: overdue fee charged at $5.00 instead of $35.00, MHD-33684, raised 2026-06-17.

---

## Contradictions and open questions

- **Ezdebit versus Ezidebit**: the Cover Runbook (Confluence 3131015188) spells it Ezdebit in the section 05 heading; the database column and the stage register spell it Ezidebit / Ezi. Same provider.
- **Zepto Process page is stale.** Confluence 580845583 was last updated February 2024 and predates the Split migration, PayTo and the Payment V3 event contracts ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) section 5). Treat its mechanics as directionally right and its detail as unconfirmed.
- **Auto credit-back on a bounced NPP transfer**: confirmed for Freestyle, unconfirmed for CRD (Rusty's own uncertainty, 2026-08-24).
- **No refund process documentation exists.** The only refund content is the datafix half on Confluence 2385150262. Who approves a refund, the customer facing steps, and how a refund differs from a transaction cancellation (which moves no money) are undocumented ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.9).
