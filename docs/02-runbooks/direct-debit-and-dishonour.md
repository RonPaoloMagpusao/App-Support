# Direct debit and dishonour

Debits that fail, debits that should have been cancelled and did not, payments stuck in Proposed, and Zepto late dishonour batches.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 6, Rusty's rulings (Slack) sections 2, 3, 4, 6, Confluence 2286321665, Confluence 3131015188 section 05, Confluence 1772126209

Rusty's standing priority call: *"Direct debit issues are always urgent"* (`#app-support`,
2026-07-01).

## Symptoms

- "Scheduled direct debits are being rejected with 'Add Payment Denied'"
- "Direct debit has been pending since 07/08/2026"
- "Direct Debit payments for several accounts are still in 'Proposed' status despite the scheduled payment date having passed"
- "Direct debit keeps on reversing even though its well-funded"
- "The customer paid early and the direct debit came out anyway"
- "Customer got a missed-payment notification and a dishonour fee after they had already paid"
- "Zepto has raised a DDR Dispute claiming they are duplicates"
- "Payments are coming out earlier than expected"
- "Nothing debits on this account at all"
- "Error Split Create/Update Account task keeps coming back"
- "Late dishonour file from Zepto, please reverse these"
- "DD rejected: `incorrect_account_number`"

## Triage, in order

1. **Read the rejection reason before anything else.** Rusty, `#app-support`, 2026-05-26:
   *"The DD outcome we have gotten both times we have tried is `incorrect_account_number`. This
   is the response Zepto/Split is getting from the customers bank and passing to us. When I check
   the MB, the account number is just wrong. This should be the first thing we check before
   raising this as an issue."* This ends a large share of investigations.
2. **Pull the provider payload.** `PaymentRef` is in the form `<applicationId>-<transactionId>`
   (MHD-35514, MHD-36618). The worked example from MHD-35514, application 10002269829,
   transaction 108364618:

   ```
   "FailureReason": "Authoriser contact (...) bank account (...) is blocked and not eligible (Non-debitable account type).",
   "PaymentRef": "10002269829-108364618",
   "PaymentAmount": 1079.17,
   "PaymentStatusId": 27007,
   "Provider": { "Name": "Split", "AccountId": 446967 }
   ```

3. **Check the database for cancelled rows.** **Cancelled transactions do not display in the
   Horizon transaction grid** (MHD-36618). A payment that appears to have vanished may be a
   cancelled row you can only see in the database. The worked example:
   `108348993 | $834.47 | 2026-08-04 | CANCELLED DUE TO PAYMENT UPLOAD TOOL | TranId: 108528370`.
4. **Establish the product before you judge a non-cancellation.** The rules differ, see the table
   under Root causes. Rusty, `#app-support`, 2026-05-28: the normal custom and partial rules do
   not apply to CRD.
5. **Check the default payment method matches.** *"Automatic payments only work if they match the
   default payment method. So for example we can't schedule a Split Sched DD if the customer
   normally pays by Debit Card Sched"* (Rusty, `#solutions_memorandum`, 2026-08-12, restated
   2026-08-21). If you need to schedule the other method you must also change the default.
6. **Check whether an `AdditionalDataTypeId = 32` row exists at all.** If not, nothing debits and
   `AppSupport_UpdateToDefaultPaymentMethod` will silently do nothing, because it has no INSERT
   path (MHD-35706, Confluence 3117842457).
7. **Check the timings before declaring a delay.** Split Sched clears in 2 business days
   (Rusty, 2026-07-22). Zepto's next response is normally 17:30 on the due date; a 03:30 response
   means Zepto is running late and usually resolves itself (Rusty, 2026-08-14). Split Sched now
   processes from as early as 08:00, changed 2026-08-26 from after 17:30 (Rusty,
   `#solutions_memorandum`).
8. **Do not check for cancellation immediately after the customer pays.** Horizon does cancel a
   scheduled payment when a customer pays ad hoc, but not instantly (Michael Dela Torre, quoted in
   Rusty's rulings (Slack) 2.1; reference is Confluence 1742962798).

## Root causes seen

### Add Payment Denied

The customer's nominated account is not debitable. Provider-side block, so Horizon showing the
right bank details proves nothing. MHD-36618, application 10002220007, debited successfully seven
months in a row from 12/07/2024 to 13/01/2025, then every scheduled Split payment was denied from
12/02/2025 onward, twelve in a row with no successes. Bank details in Horizon were correct, NAB,
Split Account Active and set as Default. Re-adding the direct debit on 22/06/2026 did not help,
which is what confirms the block is provider-side.

### Scheduled debit not cancelled after an early payment

This varies by product, and that is the important part.

| Product | Behaviour | Source |
| --- | --- | --- |
| Personal Loan | An early payment covering the next repayment **does** cancel the upcoming direct debit. Under the existing rules an ad hoc self-service payment cancels an upcoming Direct Credit dated in the future, dated today, or up to 3 business days in the past | Rusty, `#horizon-collections-team`, 2026-08-13; Confluence 44630030 |
| Freestyle | The Custom Amount option is a one-off payment against the balance and does not touch the scheduled debit. Next Repayment is not available for Freestyle in the app, so the customer cannot adjust it themselves | MHD-35019 |
| CRD | The ad hoc payment rules do not apply. CRD cancels on **bill satisfaction**. If the bill is satisfied and the MMP is not cancelled, that **is** a defect | Rusty, `#app-support`, 2026-05-28, MHD-33265 |
| Overdue-stage accounts, any product | Only **retry** transactions can be auto-cancelled. An ad hoc payment continues as Proposed and is rejected after 3 working days as "Payment not actioned" | MHD-36283 |

The overdue case in full, Michael Dela Torre on MHD-36283 after checking with the dev team:
*"the debit card live was supposed to cancel the direct credit transaction because it can cover
the direct credit. The only problem is the stage of the app before it happens. Since the app's on
the overdue stage, we have special rules around it and we can only cancel retry transactions.
Instead, the transaction continued as proposed and was rejected after 3 working days, because of
our business rule that is 'Payment not actioned'."*

### Card payment racing the direct debit

If a customer pays by card at the same moment Horizon submits the DD to Split, the card payment
cancels the DD locally but the DD has already gone to Split, so it never updates to pending then
cleared (Rusty, `#unsaved-card-payments`, 2026-02-25). The fix is a datafix on the cancelled DD
to "cleared".

### Nothing debits at all

The mandate is accepted but the Default Payment Mode was never written. MHD-35706 describes it as
*"a cohort based issue affecting specific onboarding batches"*, and the linked MHD-34569 listed
12 applications missing configuration. **Always widen the blast radius**: the ticket asks
explicitly to check other applications from the same cohort before their transaction dates. This
class is never a single account (Confluence 3131015188 section 05).

For CRD migrated from CCC, the migration script carries `DisablePaymentSubmission` over from the
original CCC application, and a pre-migration "payment denied" event then blocks all future
submissions (MHD-34668).

### Payments stuck in Proposed

MHD-34293, 01/07/2026, covered six accounts at once: 10002249595, 10002270641, 10002970835,
2000186241, 10002967754, 10002852548. Escalated to Tops and fixed by Tops and Harvey within a day.
**No root cause was recorded, which is a gap.** Also MHD-34732.

### Split account tasks

`Action - Check Split Account` is generated when a payment fails with a terminal Split error code:
`incorrect_bsb`, `payment_stopped`, `account_closed`. `Error Split Create/Update Account` appears
when Horizon's attempt to create or update the Split account fails at the provider, usually
immediately after funding. That task blocks transactions loading, because there is no valid Split
account to debit (Rusty, `#app-support`, 2025-09-18, task 10002547581; Confluence 2286321665).

### Zepto bulk late dishonour recoveries

A recurring batch operation, not a defect. Late returns have arrived dated up to 6 weeks earlier
(MHD-30342, MHD-30348, COL-4101).

The standing execution plan, recorded by Jess Leal on both MHD-30926 and MHD-36494:

1. Run the Soft Execution Script **after** running the Collections team's script.
2. Amortisation team verifies the results.
3. Run the Actual Execution Script.
4. Amortisation team actualises the affected applications.

Christopher Enriquez's instruction on both: *"Please run this before the amortization scripts."*
Backups are taken as `Transaction_MHD<ticket number>`.

**The standing blocker, and the thing to check first:** the file Collections supplies usually
carries only Amount and Zepto PR Ref, with **no ApplicationId or TransactionId**, so the payments
cannot be located in Horizon. On MHD-36494 the file had 185 rows totalling $78,611.86 and had to
be sent back for the account mapping. The precedent for supplying the mapping is MHD-14377.

## The fix

| Root cause | Action |
| --- | --- |
| `incorrect_account_number` | **No action.** The account number is wrong. Ops obtains correct details from the customer |
| Add Payment Denied, non-debitable account | **No action on our side.** The customer nominates a different debitable account. Take the immediate payment by card or bank transfer. Any further attempt on the existing direct debit fails identically |
| Early payment, PL | **No action.** Working as designed |
| Early payment, Freestyle | **No action available.** Known limitation, no fix planned, Freestyle is being discontinued. Manual schedule edit as the workaround (MHD-35019) |
| Early payment, CRD, bill satisfied | **Config change** in the short term, the agent cancels it. Rusty: *"Yeah mate, please cancel!"* Permanent fix shipped as CRD-2459 in release MHD-33404 |
| Early payment, overdue stage | **No action.** Explain the 3-working-day and retry-only rules (MHD-36283) |
| Card payment raced the DD | **Datafix** on the cancelled DD to cleared (Rusty, 2026-02-25) |
| Missing Default Payment Mode | **Datafix**, `EXEC dbo.AppSupport_UpdateToDefaultPaymentMethod @ApplicationId = 1000123456;`. If no `AdditionalDataTypeId = 32` row exists the EXEC does nothing; use SQL Data Fix scripts item 53 to insert. Detection query is item 84. Then sweep the cohort |
| CRD migrated from CCC, blocked submission | **Datafix**, set `DisablePaymentSubmission` to NULL and switch the default payment mode from Split Sched to Direct Credit (MHD-34668) |
| Stuck in Proposed | **Escalate** to Tops (Christopher Enriquez) and Harvey Dacutanan. Note Harvey is on EOM cashflow reports at month end and effectively unavailable then |
| `Error Split Create/Update Account` | **Config change**, close the task, which forces Horizon to re-attempt creation. Then check the Debit Accounts tab for an Active Split account and the Transactions tab for a populated schedule (Confluence 2286321665) |
| `Action - Check Split Account` | **No datafix.** Ops works the error code: `incorrect_bsb` review documents and update Bank Details, `payment_stopped` outbound call to have the stop removed, `account_closed` obtain a replacement account (Confluence 2286321665) |
| Zepto late dishonour batch | **Datafix**, the four-step execution plan above. Every reversal needs an amortisation counterpart, or the schedule silently diverges (Tops, 2026-02-11). September 2026 used `Soft Execution - MHD36494 - Create amort counterpart for Bulk Dishonour Fee Update - Sep2026.sql` |

Templates live in [../04-sql/datafix-templates/](../04-sql/datafix-templates/). Rails and timings
are in [../01-systems/payments-and-rails.md](../01-systems/payments-and-rails.md).

**Two questions Michael Dela Torre raised on MHD-36494 that should be asked on every batch**,
because the customers are not at fault:

- Should dishonour fees be suppressed on the reversals?
- Should stage movement and arrears capture be disabled, so that 185 accounts do not move into
  collections at once?

Neither was answered on the ticket. They should be standing policy, not a per-batch judgement.

## Not a defect

- **`incorrect_account_number` rejections.** The customer's account number is wrong
  (Rusty, `#app-support`, 2026-05-26).
- **Debits taken before a third-party payment arrangement started.** *"These debits are valid, and
  there was no duplication or other legitimate issues"* (Rusty, `#app-support`, 2026-08-19).
  MHD-35813 is the worked example: both debits were valid, the customer entered a Betterway
  arrangement after they had processed, and we stop direct debits as soon as Betterway notifies
  us. Roughly one in seven duplicate claims needs no datafix at all.
- **A scheduled payment not cancelling the instant the customer pays.** It does cancel, just not
  instantly. Do not raise a defect on the basis of checking straight after the payment
  (tribal knowledge (Slack) section 9).
- **Payments coming out earlier than expected, since 2026-08-26.** Split Sched now processes from
  08:00 instead of after 17:30, and the payment migration to the event-driven system was rolling
  out at the same time (Rusty, `#solutions_memorandum`, 2026-08-26 and 2026-09-04).
- **A Zepto response at 03:30 instead of 17:30.** Zepto running late. Outside our control and it
  usually clears the same day (Rusty, 2026-08-14).
- **Horizon not submitting a DD when the balance is $0** on a CRD payout figure. The customer must
  pay manually. Tell them up front (Rusty, `#solutions_memorandum`, 2026-09-08).
- **The `Error Split Create/Update Account` task being closed to trigger a retry.** That is the
  expected handling, not a workaround (Confluence 2286321665).

## Precedents

- MHD-35514: "Add Payment Denied", application 10002269829, non-debitable account.
- MHD-36618: twelve consecutive denied Split payments, application 10002220007. MHD-36607 and
  MHD-36629 are separate reports against the same account in the same week; MHD-36629 was closed
  as Duplicate.
- MHD-36283: ad hoc payment 109268769 rejected rather than cancelled on an overdue account.
- MHD-33265: CRD scheduled DD not cancelled after an advance payment, application 10002813976.
  Permanent fix CRD-2459, released in MHD-33404 with release task RB-1558. Further related
  release MHD-35241.
- MHD-35019: PL cancelled, Freestyle did not, on the same customer.
- MHD-35706: missing Default Payment Mode, cohort-based. Linked MHD-34569 listed 12 applications.
- MHD-34668: CRD migrated from CCC with `DisablePaymentSubmission` carried over.
- MHD-34293, MHD-34732: payments stuck in Proposed.
- MHD-36494, MHD-30926, MHD-30048, MHD-30342, MHD-30348, MHD-28907, MHD-35813, MHD-14377: Zepto
  bulk late dishonour recoveries.
- MHD-35707, MHD-35890, MHD-36766, MHD-36623, MHD-36693, MHD-35631, MHD-34447, MHD-34761,
  MHD-32507, MHD-31613, MHD-32196, MHD-35062: further direct debit tickets in the window.

## Open defects

- **MHD-36693**, "BRAND (MME /PL) | 10003003669 | ISSUE DD was no cancelled", Waiting for Customer,
  a fresh instance of the overdue-stage cancellation gap at 17/09/2026.
- **MHD-36766**, "Direct debit error, 10002975361", Waiting for Customer.
- **COL-3475**, Split Sched rejecting on date when it should not. Rusty added symptoms 2025-11-27,
  transactions 99697633, 100518211, 99200209.
- **`DisablePaymentSubmission` landing on the wrong account.** Rusty's own spec, 2026-03-17: when a
  customer gives new bank details before Zepto's rejection response arrives, the **new** account
  gets the flag. His stated requirement, *"WHEN a payment is rejected for a relevant reason, IF the
  Split account was already updated, THEN do not disable submission on the new account"*, is not
  built. He also asked on 2026-09-15 for a list of CRD accounts with
  `DisablePaymentSubmission = true` because *"these payments should be rejecting (But are not
  rejecting automatically)"*.
- **MHD-34293 recorded no root cause** for six accounts stuck in Proposed. If it recurs there is
  nothing to go on.
- **Collections keeps supplying Zepto files with no ApplicationId or TransactionId.** Every batch
  stalls until the mapping is requested and re-supplied. A file format standard would remove this
  entirely. No ticket exists (MHD-36494, MHD-14377).
- **MHD-31962**, "Fix the payment method back to DD, 10002045721", Selected for Development, 160
  days as at harvest.
