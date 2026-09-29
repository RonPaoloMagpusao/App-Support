# Hardship and arrangements

Hardship arrangements, payment plans, AFCA and external arrangements that will not set up, debit the wrong amount, or behave unexpectedly on exit.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 8, Confluence 1293647889, Confluence 3117842457 Part 2b, Rusty's rulings (Slack) sections 8.4, 8.5, 13, tribal knowledge (Slack) section 9

18 Problems on `hardship` in the window (MHD issue catalogue theme 8), small but high-consequence,
because hardship customers are the ones most harmed by a wrong debit.

## Symptoms

- "Unable to implement hardship arrangement"
- "System Debiting Incorrect Hardship Arrangement Amount"
- "Unable to set up the arrangement in Amort Tab"
- "Unable to submit the Hardship form"
- "Could not pause fortnightly payments; next due keeps showing $40.74"
- "Can't tag $80 as the ongoing payment amount"
- "Hold interest for the hardship period"
- "Repayment jumped right after the customer came off hardship"
- "Payment plan still active after the customer paid"
- "Customer disputes debits taken before their Betterway arrangement started"
- "Account moved out of hardship on its own"

## Triage, in order

1. **For a debit short of the approved amount, check the include-fee flag.** On MHD-30961 the
   approved arrangement was $150 a month and the system captured $145. The $5 gap was the monthly
   fee, because the amount had been set with the include-fee flag false.
2. **For an LOC or Freestyle arrangement that shows the full schedule, check whether anything is
   scheduled at all.** Horizon gets confused when an LOC has nothing scheduled and shows the full
   schedule (Josh Allen, MHD-36270).
3. **For a repayment jump after hardship exit, check for an adhoc shuffle on exit.** On MHD-36071 a
   shuffle three days after the customer exited hardship produced a 123 per cent increase. Do the
   12/26 arithmetic in [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md).
4. **Check the stage and how long it has been there.** Hardship stages move automatically on fixed
   timers, see Not a defect. Confluence 1293647889 is the authoritative list.
5. **For a CRD account, go to [crd-credit-card.md](crd-credit-card.md).** Arrears reset on CRD is a
   hardship mechanism and clear-arrears payment plans on CRD have their own rules.
6. **For a payment plan that stayed active after a payment, work the allocation.** Payments go to the
   oldest outstanding amount first, and a payment plan covers arrears only (MHD-35381). See
   [arrears-overdue-and-stage-transitions.md](arrears-overdue-and-stage-transitions.md).

## Root causes seen

1. **Amount set exclusive of the monthly fee** (MHD-30961, account 10000796502). Not a defect.
2. **LOC with nothing scheduled shows the full schedule** (MHD-36270, application 10001806432).
3. **The ongoing payment amount cannot be tagged after the manual first payment.** The reporter on
   MHD-36270 could set the next due date but not tag $80 as ongoing, and the schedule kept showing
   $40.74. A display issue only.
4. **Hardship exit followed by an unconverted shuffle** (MHD-36071). The shuffle defect, not a
   hardship defect, but hardship exit is when it bites.

## The fix

| Root cause | Action |
| --- | --- |
| Short by the monthly fee | **Config change**, set the amount to $150 explicitly if you want $150 debited (MHD-30961) |
| LOC showing the full schedule | **Config change.** Josh Allen: *"please manually add the first expected payment, then it will display correctly. Horizon gets confused when an LOC has nothing scheduled, so it shows the full schedule. Adding in the first payment manually shows it where to start, and removes the confusion."* |
| Ongoing amount tag not sticking | **No action.** Josh Allen: *"as long as the payment setting stays in place, the repayments will actually process for $80. This is just a display issue, and due to Freestyle being phased out, it is not likely to be fixed."* |
| Jump after hardship exit | **Config change**, continuous payment setting at the correctly converted amount (MHD-36071) |
| Hold interest for the hardship period | **Datafix**, raw script territory, SQL Data Fix scripts item 40 (Confluence 3117842457). Note the arrears calculation is anchored to the CED, so an interest hold after a variation makes it expect a higher balance than the account holds (Rusty, 2026-07-15) |
| Unable to submit the hardship form | Unverified: MHD-35690 is the only instance and its root cause was not read. **Escalate** with the application ID until a pattern is established |

## Not a defect

- **Hardship Requested (31) moving to Overdue.** It raises "Awaiting Hardship Docs" with a due date
  of plus 21 days, and moves to Overdue after 35 days in the stage, or plus 14 days from that due
  date (Confluence 1293647889).
- **Hardship Declined (33) holding for 14 days.** Incomplete applications move here on the Awaiting
  Hardship Doc due date. The customer gets a declined email and stays 14 days, which protects them
  from collection activity, before moving back to Overdue. If documents arrive while here, the
  system moves it back to Hardship Under Review and raises a task (Confluence 1293647889).
- **Hardship Approved - Missed Payment (113) and External (134) moving on.** After more than 28 days
  they move to Overdue (113) or External - 14 Day Hold (134). If more than 80 per cent of the last
  rejected payment (113) or expected monthly payment (134) clears, they return to Hardship Approved
  (Confluence 1293647889).
- **AFCA Arrangement (121) and AFCA In Progress (120) not pausing interest.** Interest should not be
  paused. A modal offers DNC, Suppress CCR, Disable Annual Fee and Disable Account Keeping Fee, and
  those are de-selected on exit if they were not selected before AFCA. A proposed payment moving to
  Rejected in AFCA Arrangement auto-moves the account to AFCA Arrangement Broken (122), with no
  automatic movement out (Confluence 1293647889).
- **External - LOA Received (127)** selects DNC and sets payments to Direct Credit, and auto-moves to
  External - 14 Day Hold after 60 days (Confluence 1293647889).
- **Accounts in Hardship or DNC as at February 2025 not getting the monthly fee increase.**
  Deliberately excluded. Rusty, `#app-support`, 2026-09-15: *"I am almost certain I have seen this
  exactly once before, and I do believe it is valid."*
- **Debits taken before a third-party arrangement started.** *"These debits are valid, and there was
  no duplication or other legitimate issues"* (Rusty, `#app-support`, 2026-08-19). We stop direct
  debits as soon as Betterway notifies us (MHD-35813).
- **A payment plan that stays active after the customer pays the current bill.** It covers arrears
  only and is cancelled when arrears clear (MHD-35381).
- **Special Handling does not pause payments.** The old Suspended stage paused them; Special
  Handling keeps them running. Moving a batch of pre-sale accounts to Special Handling in June 2026
  needed an urgent datafix to cancel active schedules (tribal knowledge (Slack) section 9).

## Precedents

- MHD-30961: account 10000796502, $145 debited against a $150 arrangement, include-fee flag false.
- MHD-36270: application 10001806432, LOC showing the full schedule, ongoing amount tag not sticking.
- MHD-36071: hardship exit followed by an unconverted adhoc shuffle.
- MHD-30381: "Unable to set up the arrangement in Amort Tab".
- MHD-35690: "Unable to submit the Hardship form", application 10002755169. Root cause not verified.
- MHD-33537, MHD-31062, MHD-30000: arrears and DPD disputes during arrangements.
- MHD-36206: fees waived by Jason McGuire because a Courtesy Variation forced a Financial-Support
  customer ahead of schedule. See [fees-and-charges.md](fees-and-charges.md).
- MHD-35813: Betterway arrangement, both debits valid.

## Open defects

- **The LOC ongoing-amount tag display issue will not be fixed**, because Freestyle is being phased
  out (Josh Allen, MHD-36270).
- **The shuffle frequency-conversion defect lands hardest on customers exiting hardship.** No ticket,
  no detection. See [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md).
- **No manual trigger for the CRD arrears reset.** Rusty asked on 2026-06-09 for a way to trigger the
  hardship bill-deactivation process without moving the stage through Hardship. No ticket recorded.
  See [crd-credit-card.md](crd-credit-card.md).
