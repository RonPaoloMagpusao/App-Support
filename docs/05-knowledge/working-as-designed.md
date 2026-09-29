# Working as designed

Behaviours that look like defects but are confirmed as intended, with who ruled and where. Check here before raising a Problem.

Last reviewed: 23 September 2026
Sources: Slack tribal knowledge, Rusty's rulings, Jira MHD cross-cutting rules

## From team practice and Slack

Consolidated from Rusty's rulings. Full quotes and permalinks are in
[05-knowledge/rusty-rulings.md](rusty-rulings.md).

1. **Overdue fee charged while the customer is paying.** OD fee is charged every
   14 days while the account is in overdue stage, regardless of payments. DH fee
   is separate and only on rejection. Do not waive.
2. **"Interest Free Expiry" on CRD.** A reallocation from an interest-free
   bucket to an interest-bearing bucket, not a duplicate charge. Interest only
   ever shows on statement issue day.
3. **LOC/Freestyle repayments creeping up.** Design limitation of the old
   product. Shuffling does not change the amount. Apply a payment setting.
4. **`incorrect_account_number` DD rejection.** The customer's account number is
   wrong.
5. **"SMS not received".** Almost always not on our side.
6. **Debits taken before a third-party payment arrangement started.** Valid.
7. **Accounts in Hardship or DNC as at Feb 2025 not getting the monthly fee
   increase.** They were deliberately excluded.
8. **A transaction that is not in Horizon.** "If it's not in Horizon, we
   probably can't see it." Not a Horizon defect.
9. **Repeated `reset` commands for the same email in `#unblock-account-request`.**
   Normal.
10. **Long-standing `comms-api` Sentry alerts** (`NotRegistered`, `APNs device
    token is disabled`, first seen 2022-11-15, 1 user affected). Noise.
11. **CRD scheduled MMP not cancelling via custom/partial rules.** Those rules
    do not apply to CRD at all; CRD cancels on bill satisfaction. (The
    cancellation still failing after bill satisfaction **is** a defect,
    MHD-33265.)

---

## Rulings by Rusty

Use these to close tickets confidently.

| Report | Rusty's verdict | Date | Channel |
| --- | --- | --- | --- |
| Overdue fees charged while customer is clearing payments | Working as expected/intended, do not waive | 2026-09-01 | `#app-support` |
| Interest Free Expiry looks like a duplicate charge | It is a reallocation, not a duplicate | 2026-07-02 | `#solutions_memorandum` |
| "SMS not received" | "Like most 'SMS not received' issues, this was not an issue on our side" (customer was somewhere very remote; the app funded) | 2026-09-03 | `#app-support` |
| DD rejected with `incorrect_account_number` | The account number on the bank statement is simply wrong | 2026-05-26 | `#app-support` |
| Customer disputing a regular debit taken before they entered a payment arrangement with Betterway | "These debits are valid, and there was no duplication or other legitimate issues." | 2026-08-19 | `#app-support` |
| Accounts in Hardship not getting the monthly fee increase | "I am almost certain I have seen this exactly once before, and I do believe it is valid." Anything in HS or DNC as of Feb 2025 was excluded from the increase. | 2026-09-15 | `#app-support` |
| Mobile app shows nothing for a transaction that is not in Horizon | "If it's not in Horizon, we probably can't see it." | 2026-09-22 | DM |
| Two applications sharing the same bank statement | "This is a very unsophisticated attempt at fraud. We will never receive ID." | 2026-08-31 | `#app-support` |

One general statement, 2026-03-31 (DM with Ron), on a behaviour Ron queried:
> "Yep, it's working exactly as designed and intended"
(The specific subject of that message was not captured in the search result, so
do not cite it against any particular behaviour.)

---

## Cross-cutting rules from MHD tickets

These came up repeatedly across themes and are the kind of thing that saves an hour of investigation.

| Rule | Source |
| --- | --- |
| A proposed payment not processed within **3 working days** is rejected as "Payment not actioned". | MHD-36283, MHD-34734 |
| On an **overdue-stage** account only **retry** transactions can be auto-cancelled. Ad hoc payments cannot. | MHD-36283 |
| Payments always allocate to the **oldest outstanding amount first**. | MHD-35381 |
| An **OD fee is charged every 14 days** while an account sits in Overdue, regardless of payments. A **DH fee** is charged only when a payment rejects. | MHD-36206 |
| **Overdue + Rejected payment = no stage move** to Fund Sent. | MHD-32117, MHD-34734 |
| Check arrears on the **Scheduled and Due summary**, not the amortisation screen. | MHD-36790 |
| The Application Comms list view **caps at 21 rows**. Click Load More. | MHD-36668 |
| **Cancelled transactions do not display** in the Horizon transaction grid. | MHD-36618 |
| Contact records are **per brand**. Update all of them. | MHD-36009 |
| Three decimal places on a Split Sched amount means a **recreated amortisation**. | MHD-36446 |
| `PaymentRef` format is `<applicationId>-<transactionId>`. | MHD-35514, MHD-36618 |
| Freestyle is being discontinued. Freestyle-only defects will generally **not** be fixed; use manual scheduling or Payment upload. | MHD-35019, MHD-36071, MHD-36270 |
| Search `Amortization`, not `amortisation`. The system uses US spelling. | This harvest |
