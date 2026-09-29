# Amortisation, shuffle and schedules

Repayment amounts that change when they should not, terms that display wrong, and schedules that fire late or twice.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 5, MHD open threads Tier 1, Rusty's rulings (Slack) sections 9, 10, tribal knowledge (Slack) sections 3.3, 9, Confluence 546701313

The theme with the deepest precedent chain and the clearest unfixed defect. Search `Amortization`,
not `amortisation`: the system uses US spelling.

## Symptoms

- "The repayment amount increased following a system adhoc shuffle"
- "Repayment amount remains unchanged"
- "The amount remains fixed at $300 after shuffling account from minimum payment $300 FN to Monthly"
- "Unable to Shuffle on the 15th of the month" / "Unable to shuffle to the correct date"
- "Unable to shuffle LOC"
- "Repayments too high"
- "It's showing that loan term is 3 years when it should be displayed as 3 years and 7 months or 43 months"
- "The app shows a last repayment date of 17/01/2030"
- "A payment came out more than a year after the last activity on the account"
- "Duplicate repayment schedules on LOC"
- "Duplicate transactions right after a shuffle"
- "The schedule is short by the Dealer/Broker Fee"

## Triage, in order

1. **For any amount change, do the arithmetic first.** Compare the pre-shuffle contractual
   instalment and frequency against the post-shuffle rows in the Transaction tab. A correct
   conversion from monthly to fortnightly is roughly the monthly figure times 12/26. **If the
   post-shuffle fortnightly figure is close to the old monthly figure, the frequency label changed
   and the amount did not convert.** That is the unfixed defect at 5a below (MHD-36071).
2. **For a term that looks wrong, check four places:** Application Overview, Application details,
   Amortisation (Payment Count) and the Transaction tab. If all four agree with the credit
   contract and only the mobile app disagrees, it is MHD-36092 and **no datafix is required**. If
   Horizon and the contract disagree, it is MHD-35653 and it **is** a datafix (MHD issue catalogue
   theme 5b).
3. **Look at the decimal places.** Three decimal places on a Split Sched amount, for example
   $186.672 rather than $186.67, means a recreated amortisation holding a computed value rather
   than a transaction amount rounded to cents. If you see three decimals, suspect a recreated
   schedule (MHD-36446).
4. **Check the gap since the last activity.** A long dormancy followed by a sudden debit is the
   AMZ-7074 long tail at 5c below.
5. **Check whether the shuffle happened on the funding day.** Shuffling the same day as funding,
   before the Dealer/Broker Fee is charged, leaves that amount out of the schedule
   (Rusty, `#app-support`, 2026-09-14).
6. **Check whether the account was shuffled twice in quick succession.** Both shuffles trigger the
   transactions to load, which produces duplicates. *"It's very rare, so the fix is low priority
   for now"* (Rusty, `#app-support`, 2026-09-01).
7. **For LOC and Freestyle, stop and read 5d.** Shuffling an LOC does nothing for the amount.

## Root causes seen

### 5a. Adhoc shuffle changes the frequency label without recalculating the instalment

The clearest worked example is MHD-36071, account 10001184043, Freestyle CCC, MME, limit $19,750,
balance $20,382.53, APR 19.49 per cent.

- 04/05/2026 contractual repayment $1,065.40 **monthly**.
- 18/06 to 18/08/2026 hardship arrangement $295 a month, three payments, all cleared.
- 21/08/2026 10:10 the adhoc shuffle runs and creates two rows: Split Sched $1,097.598 on 09/09
  and 23/09, labelled **fortnightly**.
- Both figures are monthly instalments amortised over the same horizon. $1,065.40 against the May
  balance gives 22.5 months, $1,097.598 against the August balance gives 22.3 months. The 3 per
  cent difference is entirely balance growth.
- A correct fortnightly conversion would be roughly **$499.00** ($1,065.40 x 12/26 = $491.72).
- Customer impact: $12,784.80 a year became $28,537.55 a year, a **123 per cent increase**,
  applied three days after the customer exited hardship.

**Do not conflate this with the fix released 14/05/2026 referenced on MHD-31974.** That addressed
shuffles **overriding existing arrangements**, a different failure mode. The frequency-conversion
defect is separate and still live.

### 5b. Loan term shown wrong in the mobile app

MHD-36092, application 10003066205. The server sends two fields in the same response.
`DurationInYears` carries "3 years", rounded down, and is what both iOS and Android wire to the
Term row. A separate months field carries the accurate "43 months" and is delivered but never
displayed. Both arrive as plain text rather than numbers, so neither app can convert. Neither app
performs any calculation.

History, from the RCA by Paul LV Jain:

- Android has always shown whole years.
- Before May 2025 iOS read the accurate months field and correctly showed "43 months".
- May 2025, a "Platform disparity" review flagged the disagreement, ranked it low priority, and
  marked **Android as correct**, citing a Figma design that no longer exists.
- 21/05/2025, **MMM-9350** changed iOS to match Android, one line swapping the accurate months
  field for the rounded years one.
- It passed QA, UAT and production checks because every test account happened to have a whole-year
  term.
- 01/09/2026 a customer reports it.

Code refs examined: iOS `moneyme_ios` master at `0a3877ab2` (19/08/2026), Android
`moneyme_android` origin/master at `7d08e1eaa` (30/08/2026).

**Distinguish from MHD-35653.** There the Transaction tab genuinely held a stale 36-month term
against an actual 42-month amortisation, showing a last repayment date of 17/01/2030. That **was**
a datafix, executed under MHD-35277 and tracked as MHD-35509.

### 5c. Dormant schedule, then a surprise debit

MHD-36446, SocietyOne account 2000019464, IDR dispute 21134, customer threatened media escalation.
A payment of $186.672 was taken on 07/09/2026, more than a year after the last activity.

- Funded 10/03/2021, contract end 24/02/2026.
- Last normal fortnightly debit 12/08/2025.
- 15/08/2025 the customer paid $5,000 by card to close the account, leaving a residual of $355.36
  ($168.70 principal plus $186.66 interest).
- Then **374 days of nothing**. No debits, no comms, no collection activity.
- 24/08/2026 03:00, the system wrote off the remaining principal of $168.70.
- 24/08/2026 03:03, three minutes later, it created a new Split Sched for $186.672 dated
  07/09/2026.
- That cleared 09/09 09:38. The "Your SocietyOne loan is Repaid!" email went out at 09:45, seven
  minutes after the money had gone.

Root cause is **AMZ-7074**, "Cancel and Create Schedule instead of updating", Done, AmortizationV2.
The old behaviour: when a customer near the end of their loan made an ad hoc card payment,
amortisation schedules already picked up by the Transaction Loader were cancelled **but not
replaced** with new Proposed schedules. The residual was left with nothing scheduled against it,
which is why there was nothing to collect and nothing to send comms about. AMZ-7074 only acts
during actualisation when a payment amount changes, so this account stayed dormant a further
306 days. The write-off on 24/08/2026 was the first amount change, and the corrected system then
created the schedule that should have existed since August 2025.

AMZ-7074 carries a `covers` link to **MHD-27965**, "Payment schedule stopped for 6months", closed
at Low. Same family.

### 5d. LOC and Freestyle repayments drifting upward

Not a per-account defect. Rusty, `#app-support`, 2026-05-06:

> "We (Gelo) know that LOC payments are cooked. This is a huge part of why we built a new product.
> If we need repayments to stay the same, we just need to use a payment setting. They can increase
> massively if a customer has fallen behind by a lot, or even if they just use the account a lot
> over a long period. The design just was not effective over a long period of time. Our first step
> should always just be 'Does this make sense?' And then apply a payment setting. Shuffling an LOC
> does nothing for the amount."

### 5e. Shuffle on the funding day

*"It was shuffled the same day it was funded, before the Dealer/Broker Fee was charged, so that
$990.00 was not included in the schedule"* (Rusty, `#app-support`, 2026-09-14). 84 applications
were found in the same state and a bulk shuffle ticket raised as **AMZ-10685**.

## The fix

| Root cause | Action |
| --- | --- |
| Shuffle frequency-conversion defect | **Config change**, apply a **continuous payment setting** at the correct amount. Josh Allen on MHD-30258: *"Unfortunately your workaround is the only option we have in this case."* On MHD-36071 the team's position was that Freestyle is being discontinued and hardship applications migrated, so no fix is expected. Agents should manually schedule payments, or use Payment upload for bulk scheduling |
| Term wrong in the app only | **No action** in Horizon. The data is correct. Escalate to Mobile, `#app-support-mobile-team`, cc Aus, Paul, Stefan. Tracked as MHD-36092 and MMM-16301 |
| Term wrong in Horizon | **Datafix** to correct the loan term on the Transaction tab (MHD-35653, executed under MHD-35277 as MHD-35509) |
| Recreated dormant schedule | **Escalate** to the Amortisation team, `#amortization-app-support`. On MHD-36446 the agreed acceptance criteria were: refund the $186.67, give the customer a plain-language explanation, and respond to IDR dispute 21134 |
| LOC drift | **Config change**, apply a payment setting. If the reporter says "repayments too high", assign to Josh Allen (Confluence 546701313) |
| Shuffle on funding day | **Config change**, re-shuffle. Bulk case handled under AMZ-10685 |
| Double shuffle duplicates | **Datafix**, cancel the duplicate proposed schedules, see below |
| "Unable to shuffle LOC" | **Config change**, run the background shuffle script. If no frequency is given, confirm with the requester (MHD-12686, Confluence 546701313). The engine procedures are SQL Data Fix scripts items 8, 21, 22: `CalculateWithrawalAllocationAll`, `UpdateMinimumPaymentAmount`, `UpdateAmounts`. The misspelling is in the real procedure name (Confluence 3131015188) |
| Rate changed, schedule must follow | **Escalate** to Rusty (Josh Allen). Not a plain UPDATE, the loan has to be shuffled against the new APR (MHD-34449). See [fees-and-charges.md](fees-and-charges.md) |

**Cancelling proposed or scheduled amortisation takes two steps, both required** (Jess Leal,
`#datascript-requests`, 2026-06-05):

1. Update the status of the affected amorts to **35005 (Cancelled)**.
2. Add the note **"Cancel all proposed schedule"** to those amorts.

Step 2 is what stops Horizon regenerating them. Without it, new proposed schedules reappear.

Any reversal datafix on `[Transaction]` also needs a matching amortisation record, or the schedule
silently diverges (Tops, 2026-02-11: *"need din magkaron ng record ang reversal sa amortization"*).
Templates in [../04-sql/datafix-templates/](../04-sql/datafix-templates/). Rusty's rulings in full
are in [../05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md).

## Not a defect

- **LOC and Freestyle repayment amounts creeping upward.** Design limitation of the old product.
  Apply a payment setting (Rusty, `#app-support`, 2026-05-06).
- **Shuffling an LOC not changing the amount.** Same ruling, same source.
- **Duplicate transactions after two shuffles in quick succession.** Very unlucky timing. Either
  shuffling faster or slower would avoid it, and the fix is low priority (Rusty, `#app-support`,
  2026-09-01).
- **An arrears figure that disagrees with the balance after an interest hold.** The arrears
  calculation is anchored to the CED, so an interest hold applied after a variation makes it expect
  a higher balance than the account holds, and shows up as a CED discrepancy too (Rusty,
  2026-07-15).

## Precedents

- MHD-36071: Freestyle account 10001184043, monthly to fortnightly, amount not converted. Full
  analysis, workaround applied, auto-closed.
- MHD-30258, 06/02/2026: Freestyle adhoc shuffle, $299.48 to $507.81 fortnightly, loan
  10001620977. Josh Allen confirmed the workaround was the only option. Closed same day.
- MHD-31738, 08/04/2026: $300 fortnightly to $397.20 monthly, should have been roughly $650, loan
  10001749537. Escalated to Collections, never root-caused, auto-closed after 39 days. The
  reporter's point is worth keeping: *"We do not process manual adjustments for Freestyle account.
  The update should be automatically generated once the shuffling process in Horizon has been
  completed."*
- MHD-35875, 20/08/2026: fortnightly to monthly, amount did not change at all, loan 10001306925.
  Auto-closed after six days with no investigation recorded.
- MHD-31974: the 14/05/2026 fix for shuffles overriding existing arrangements. Different failure
  mode, do not conflate.
- MHD-36092, MMM-9350, MMM-16301: the mobile loan-term disclosure mismatch.
- MHD-35653, MHD-35277, MHD-35509: stale 36-month term in Horizon against a 42-month amortisation.
- MHD-36446, AMZ-7074, MHD-27965: dormant schedule recreated and debited 374 days later.
- AMZ-10685: bulk shuffle for 84 applications that missed the Dealer/Broker Fee.
- MHD-12686: "Unable to shuffle LOC", the background shuffle script precedent.
- MHD-36006, MHD-36011, MHD-34725, MHD-34602, MHD-34449, MHD-34321, MHD-34131, MHD-33009,
  MHD-33162, MHD-32598, MHD-31364, MHD-31109, MHD-31110, MHD-28152, MHD-35208, MHD-33786,
  MHD-34522, MHD-32466, MHD-30381, MHD-35504, MHD-36564: further schedule tickets in the window,
  root cause not verified.

## Open defects

- **The shuffle frequency-conversion defect has no ticket and no detection.** Four reports in seven
  months, all closed, none fixed. The accepted position is that Freestyle is being discontinued.
  The risk that position does not cover: the workaround depends on somebody noticing. Nobody has
  run a query across shuffled accounts to find out how many were debited the wrong amount
  (MHD open threads 1.1).
- **MHD-36092**, Selected for Development, linked MMM-16301 To Do. Two viable fixes are on the
  table and nobody has picked one: correct what `DurationInYears` returns server-side, or point the
  apps at the months field they already receive. The RCA lands on the first without reconciling the
  second. This is a **disclosure mismatch against the credit contract**, not cosmetic, and it
  affects every loan whose term is not a whole number of years. Nobody has counted how many.
  Unverified: the mobile team could not confirm from the apps alone that the server genuinely
  sends both values in the same response. A test account with a non-whole-year term would confirm
  it.
- **How many accounts were left unscheduled by the pre-AMZ-7074 behaviour is unknown.** Each is
  waiting for its next amount change to trigger a surprise debit (MHD open threads 1.3).
- **The comms gap on recreated schedules is itself a defect and has no ticket.** On MHD-36446 the
  customer received no pre-debit notice, although every other debit in the life of that loan had an
  Upcoming Payment DD email and an SMS reminder.
- **The Freestyle Amortization page is unusable for CCC accounts.** It returns *"Something is wrong
  with the input request. (Inner Exception: No Product Context associated with Product Name & Brand
  ID 'CCC-1')"* on both horizon and horizon4. **App Support cannot verify Freestyle schedules
  through the UI at all.** Found on MHD-36071. Ron said he would raise it separately, no ticket
  found.
- **Customers can still see a migrated Freestyle payment schedule showing the wrong amount.** No
  ticket. Rusty, 2026-05-26: *"I would think it should be hidden."*
