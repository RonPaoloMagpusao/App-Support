# Arrears, overdue and stage transitions

Arrears resets, accounts that will not leave Overdue, and arrears figures that look wrong but are not.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue themes 7, 13, MHD open threads 2.4, Confluence 1293647889, Confluence 546701313, Confluence 3117842457, Rusty's rulings (Slack) sections 7, 8.4, 8.5

300 Problems on `arrears` in the window, the second-largest theme (MHD issue catalogue theme 7).
Fees charged while overdue are in [fees-and-charges.md](fees-and-charges.md). CRD arrears resets
are in [crd-credit-card.md](crd-credit-card.md).

## Symptoms

- "Reset Arrears to $0 for Write off account"
- "Applied Variation for WO account" / "Apply contract vary for Write off account"
- "Removed arrears to write-off account"
- "Please reset the arrears balance" / "Request to reset overdue balance"
- "did not auto move to FS"
- "Investigate account status transition to FS when arrears are paid in full"
- "LID stuck in Overdue stage despite $0.00 arrears"
- "Overdue still showing after contract variation"
- "The account keeps appearing in outbound collections campaigns even though it's paid up"
- "Payment plan stayed active after the customer paid early"
- "Arrears not showing even though no payment was made"
- "Mobile app not showing overdue balance"
- "Remove stage" (usually alongside a reverse write-off request)

## Triage, in order

1. **Verify arrears on the Scheduled and Due summary, not the amortisation screen.** Michael Dela
   Torre on MHD-36790: the amortisation screen *"is where this sort of thing has been misread
   before"*. Settle the actual number first.
2. **Is it a written-off account asking for a $0 reset?** Routine request, not a defect. Apply a
   contract variation (MHD-36602). The reporter normally shuffles the scheduled payment first.
3. **For "did not move to FS", look for a rejected payment alongside the clearing one.** The
   recorded rule on MHD-32117: *"the stage did not automatically move to FS due to the rejected
   payment. The workflow logic is: **Overdue + Rejected payment = no stage move**."* A proposed
   payment not processed within 3 working days is itself rejected as "Not processed in last
   3 days", which is often where the rejection comes from (MHD-34734).
4. **Check the stage history** for whether earlier moves were made by System User or by a person.
   If earlier transitions moved automatically, the automation works in the normal case and you are
   looking at the rejected-payment exception (MHD-34734).
5. **Check the clearing date against the transaction date** on the payment that cleared the
   arrears. On MHD-36790 the retry's clearing date was 11/09, not 09/09, which was its transaction
   date. That gap is the basis of the newer, unconfirmed hypothesis below.
6. **For a payment plan that stayed active, work the allocation arithmetic.** Payments always go to
   the **oldest outstanding amount first** (MHD-35381). See Not a defect.
7. **For stage behaviour you do not recognise, read the stage notes on Confluence 1293647889**
   before calling it a defect. Stage 56 is Overdue, 38 is Fund Sent, 65 is Overdue hold.
8. **For "LOC arrears" with no other detail**, it can generally be filed and safely ignored,
   **except** if the arrears is very large, such as equal to the current balance, which may
   indicate a larger issue (Confluence 546701313).

## Root causes seen

1. **Overdue plus a rejected payment blocks the move to Fund Sent.** MHD-34734, account
   10002120225, showed it recurring:
   - 09/07/2026, auto-moved to Overdue because a scheduled Direct Credit (transaction 107630018)
     sat unprocessed and was marked Rejected, "Not processed in last 3 days".
   - 10/07/2026, a separate ad hoc payment (transaction 108582314) cleared and brought arrears to
     $0.00.
   - The stage stayed on Overdue until Jonathan Flack moved it manually on 15/07/2026 (Overdue to
     Payment Plan to Fund Sent). The same manual move had been needed on 11/05/2026.
   - Earlier transitions on the same account (31/12/2025, 26/09/2025, 14/11/2025) moved
     automatically via System User.
2. **Second hypothesis, newer and not confirmed: the "paid today" check reads the wrong date.** On
   MHD-36790, 22/09/2026, APY account 10002108249, Michael Dela Torre recorded that the Overdue to
   Fund Sent move requires four conditions, one of which is that the last successful payment is
   dated today. He suspects that check reads the **transaction date rather than the clearing
   date**. On that account direct debits consistently take two to four days to settle, so the
   condition could never be met on the day the money lands. Unverified: raised with the Horizon
   workflow team, who asked for a second example to pin it down. A second account showing a
   late-settling DD that cleared arrears and did not move would confirm it.
3. **The two explanations may both be true, or may be one mechanism seen twice.** The sources do
   not reconcile them. Treat the rejected-payment rule as the documented rule and the date
   hypothesis as open (MHD open threads 2.4).
4. **Write-off accounts carrying residual arrears.** Routine. A few a week (MHD issue catalogue
   theme 7a).
5. **Incorrect stage movement causing a write-off.** "Remove stage" normally accompanies a reverse
   write-off request, because an incorrect stage movement caused the write-off and prevents future
   account access (Confluence 546701313, MHD-12322). Moving into Settlement (66), Bankruptcy (41),
   Deceased Estate (123), Fraud and WriteOff (42) or Written Off (48) triggers a write-off
   transaction (Confluence 1293647889).

## The fix

| Root cause | Action |
| --- | --- |
| Arrears reset on a written-off account | **Config change**, apply a contract variation to reset arrears to $0.00 (MHD-36602, raised 10:17, done 16:16 the same day) |
| Stuck in Overdue with $0.00 arrears | **Config change**, move the stage manually. There is no automated remedy today. Note the evidence on the ticket and, if the DD settled days after its transaction date, add it to MHD-36790 as the second example the workflow team asked for |
| Arrears level wrong, "remove arrears level M0 to M3" | **Datafix**, raw script territory, SQL Data Fix scripts item 26. No stored procedure (Confluence 3117842457) |
| Account written off in error | **Datafix**, reverse write-off. See [refunds-and-reversals.md](refunds-and-reversals.md). Use item 15, never item 14 |
| Incorrect stage causing the write-off | **Datafix** alongside the reverse write-off, per MHD-12322 |
| Arrears calculation looks off after an interest hold | **Escalate** to Rusty (Josh Allen). The calculation is anchored to the CED (Rusty, 2026-07-15) |

Stage moves are done by Jamie Nguyen or the reporting team. Anything touching
`application.ArrearsLevelId` or `application.ArrearsStandingId` directly: Rusty named those fields
with an explicit hedge, *"You may need to ask Gil or Harvey or someone senior like that"*
(DM with Ron, 2026-07-08). Confirm with Tops or Harvey Dacutanan before writing a datafix against
them.

## Not a defect

- **Early payment absorbed by arrears, payment plan still active.** MHD-35381, application
  10002937235. Payments always go to the oldest outstanding amount first. A customer a month
  behind who pays the current month's minimum has it absorbed by the previous statement, so the
  scheduled direct debit still runs, rejects, and triggers a $15 dishonour fee. The payment plan
  correctly stays active because it covers arrears only and runs alongside normal monthly
  minimums; it is cancelled only when arrears clear. Josh Allen's arithmetic on that ticket:

  > Arrears = 602.89 − 50.25 − 50.25 + 629.51 August bill due − 629.51 August payment made = 502.39 arrears
  >
  > "Even though the July bill is now 'satisfied' and the $502.39 is against the August bill, the
  > total arrears amount is the same. We certainly don't need to cancel the PP every month and
  > create it again."

  He added that the team is working on this so the behaviour will change and align with other
  products. **Tell customers with arrears that they must cover arrears plus the current month's
  minimum, or call to have the debit cancelled.** The customer on MHD-35381 had been told on 07/07
  that paying after the statement is issued stops the direct debit, which is true only when the
  account is up to date. The $15 fee was waived on that basis.
- **Overdue hold (65) instead of Fund Sent.** If the current stage is Overdue and a payment for
  more than 80 per cent of the arrears balance is made, the stage moves to Overdue hold. Overdue
  comms do not send and the Overdue Account Fee does not apply (Confluence 1293647889).
- **Hardship Declined (33) holding for 14 days before returning to Overdue.** Deliberate
  protection from collection activity (Confluence 1293647889).
- **External - 14 Day Hold (129) auto-moving to Overdue after 14 days**, reinstating interest and
  fee settings and raising a "Review - Shuffle Schedule" task (Confluence 1293647889).
- **Accounts at Arrears Referred to External (117) not receiving comms.** DD reminders continue,
  other auto comms pause, and we can no longer contact the customer directly
  (Confluence 1293647889).

## Precedents

- MHD-36602: SocietyOne PL Broker 10002127727, reset arrears to $0 on a written-off account.
- MHD-36819, MHD-33703, MHD-35578, MHD-34516, MHD-31716, MHD-31732, MHD-31457, MHD-31354: further
  write-off arrears resets and variations.
- MHD-35710, MHD-35501, MHD-35367, MHD-35206, MHD-34601, MHD-33862, MHD-33638, MHD-36573,
  MHD-35594, MHD-34738, MHD-34629, MHD-34064, MHD-33839, MHD-33744: arrears reset requests,
  root cause not verified.
- MHD-32117: LID 10002525753 stuck in Overdue despite $0.00 arrears. The rule is recorded here.
- MHD-34734: account 10002120225, the rule recurring twice on one account.
- MHD-36790: APY 10002108249, the clearing-date hypothesis. Open.
- MHD-36600: LID 10002258706, stage transition failure to FS.
- MHD-33036, MHD-31915, MHD-30935, MHD-35433, MHD-31967: further stage and arrears display tickets.
- MHD-35381: payment plan stayed active after an early payment was allocated to arrears.
- MHD-12322: "Remove stage" alongside a reverse write-off.

## Open defects

- **MHD-36790**, Waiting for Customer. The Horizon workflow team asked for a second example to
  confirm the clearing-date hypothesis and as at 22/09/2026 nobody had supplied one. That is a
  cheap, high-value action. If the hypothesis is right, every account whose DD settles late will
  need a manual stage move indefinitely.
- **Stage-transition rework.** Josh Allen said on MHD-32117 (April 2026) that stage-transition
  workflows were being reworked, expected "by end of this year". As of MHD-34734 (16/07/2026) it
  had not landed. No ticket key recorded.
- **MHD-31967**, "Arrears not showing even though no payment was made", Selected for Development
  since 16/04/2026.
- **MHD-31915**, "Overdue still showing after contract variation, 10001661291", Selected for
  Development, 161 days as at harvest.
- **MHD-36808**, reset arrears of $142.75 showing on the customer app for 10002955931, Waiting for
  Customer.
- **The consequence of all of the above**: cleared accounts keep appearing in outbound collections
  campaigns until someone moves them by hand.
