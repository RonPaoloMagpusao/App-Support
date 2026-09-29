# Mobile app shows something different from Horizon

The customer's app shows a term, date, payment method or loan that does not match Horizon.

Last reviewed: 23 September 2026
Sources: MHD precedent index (MHD-36092, MHD-35653, MHD-35324, MHD-31877); tribal knowledge (Slack); investigation handover notes 11 September 2026

## Symptoms

- "App says 3 years but the contract says 43 months."
- "App shows the last repayment date as 2030 but the loan is 36 months."
- "App shows upcoming repayments as direct debit, but Horizon has direct credit."
- "Customer can't see their car loan in the app."
- "Payment reminder notification shows 01/01/1900."

## Triage, in order

1. **Does Horizon agree with the contract?** Check the application's term, schedule and payment method in Horizon against the credit contract.
   - Horizon and contract disagree: a **data** problem. Go to step 2.
   - Horizon and contract agree, only the app differs: a **display or API** problem. Go to step 3.
2. **Stale data on the Transaction tab.** MHD-35653: the Transaction tab held a stale 36-month term against an actual 42-month amortisation, so the app showed a last repayment date of 17/01/2030. Fixed by datafix under MHD-35277, tracked as MHD-35509. Raise a datafix: [../03-procedures/datafix-request.md](../03-procedures/datafix-request.md).
3. **Known display defects.** Match against the list below before escalating. If it matches, link the ticket to the existing one and tell the reporter it is a known display issue with no impact on what the customer is charged.
4. **New display issue.** Escalate to the mobile team with: application ID, what the app shows (screenshot), what Horizon holds, the platform (iOS or Android) and app version.

## Known display defects

| Symptom | Cause | Ticket | Status |
| --- | --- | --- | --- |
| "3 years" for a 43-month loan | API `DurationInYears` returns a rounded-down string; the accurate months value is sent but never displayed. iOS regressed to match Android via MMM-9350 in May 2025 | MHD-36092, MMM-16301 | Selected for Development. Backend and Mobile have not agreed which fix to take. See [../07-open-items/investigations-in-flight.md](../07-open-items/investigations-in-flight.md) |
| Upcoming repayments shown as DD when Horizon has DC (LID 10001905418) | Not identified | MHD-35324 | Waiting for Confirmation since August 2026; reporter has chased four times |
| Payment reminder push shows `01/01/1900` | The default null date leaking through: the date field resolved to nothing. Worked example: app 10002905649, txn 109263685, where the DD had correctly been cancelled (reported 2026-08-24) | No ticket found | Cosmetic, but tell the reporter the payment was cancelled correctly |
| Customer cannot see a car loan in the app (10002815976 / 10002453373) | Not recorded | MHD-31877 | Closed same day, 2026-04-14 |

## Not a defect

- A "3 years" display on MHD-36092 is not a data problem: Horizon holds 43 months everywhere. **No datafix.** Do not confuse it with MHD-35653.

## Open defects

- MHD-36092 is a disclosure mismatch against the credit contract for every loan whose term is not a whole number of years. Nobody has counted the affected loans. See [../07-open-items/open-defects-and-risks.md](../07-open-items/open-defects-and-risks.md) Tier 1.2.
