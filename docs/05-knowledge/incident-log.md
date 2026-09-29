# Incident log

Incidents declared and explained in the window, with impact, cause and what App Support had to do.

Last reviewed: 23 September 2026
Sources: Slack, mostly Rusty's announcements in `#solutions_memorandum` and `#app-support`; see each entry

## Horizon outage Friday 19 June 2026, ~450 transactions

- Date: **2026-06-23**
- Channel: `#solutions_memorandum`
- Quote (verbatim):
  > "We had a Horizon outage on Friday the 19th which has caused around 450
  > transactions to not update properly in Horizon.
  >
  > These can be identified with a transaction date of 19/06 but submitted date
  > of 23/06.
  >
  > - Some direct debits were submitted correctly on 19/06, but their status was
  >   not updated to pending. (Scenario 1)
  >   - The status on these will be updated today.
  >   - Any of these that were cancelled by agents or adhoc will still be updated
  >     to cleared or pending, so should be no lingering issue there.
  > - Some direct debits were not submitted (Scenario 2)
  >   - These have been submitted this morning.
  >   - Any of these that were cancelled by agents or ad hoc payments have not
  >     been submitted, so should be no issue there
  >
  > These scenarios will look identical in Horizon, and the team are still
  > working through the fix, so their status may be pending now, but the cleared
  > or rejected update might happen later today, or by Thursday morning depending
  > on the scenario."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1782180038032239
- Scope, in thread: "Yes across all products. Root cause was apparently some
  Horizon outage."

## E6 data issue on CRD, 10-11 September 2026

- Date: **2026-09-11**
- Channel: `#solutions_memorandum`
- Quote:
  > "FYI we have an issue with some data from E6 causing problems on CRD
  >
  > For example:
  > - Statements from yesterday and today were issued showing no rewards for the
  >   month.
  > - Payment allocations from yesterday were not processed overnight.
  > These will be rectified today, and should not cause any major issue.
  >
  > For example, customer will still get their expected cashback when they pay
  > their MMP. As far as we are currently aware, these are only delays, and
  > display issues."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1789084579119529

## Incorrect CRD reward credit on 1 June 2026

- Date: **2026-06-04**
- Channel: `#solutions_memorandum`
- Quote:
  > "On 01/06 all CRD customers received an incorrect 'reward' credit that you
  > may see on Horizon.
  >
  > If the customer closes their account, they may have an incorrect excess
  > balance.
  > At this stage, we are unable to process refunds for closed accounts.
  > If a large refund is expected (Unlikely) or a customer specifically requests
  > a refund, please escalate and we can make an exception.
  >
  > We are working with our card partner E6 to resolve these..."
- Cause, stated same day in `#app-support-crd`:
  > "There was an issue in E6 where they added an incorrect reward credit to all
  > customer accounts."
- Reversal note (2026-06-29, `#app-support-crd`): the reversal should have been
  capped at 1% of the credit limit, matching the cap on the original cashback;
  some reversals were wrong and needed further fixing.

## Payment migration to the new internal (event-driven) system

Three announcements, all `#solutions_memorandum`:

- **2026-08-12**: 2000 payments migrated, "should not impact you or customers at
  all". https://moneymefinance.slack.com/archives/CFY7LHEJW/p1786485720659689
- **2026-08-26**: restart, 100 payments, "This time we think there may be some
  impact, so please let us know if we get any calls about payments coming out
  earlier than expected".
  https://moneymefinance.slack.com/archives/CFY7LHEJW/p1787714287127569
- **2026-09-04**: "again/still rolling out the payment migration".
  https://moneymefinance.slack.com/archives/CFY7LHEJW/p1788489731875159

**Symptom to watch for:** "payments coming out earlier than expected". This is
the migration, combined with the Split Sched 8am change (section 4.3).

## Freestyle / LOC to CRD migration: pending DD blocks migration

- Date: **2026-06-18**
- Channel: `#solutions_memorandum`
- Quote:
  > "We attempted to migrate 50 Freestyle/LOC tonight, and 22 were skipped due to
  > pending DD. We will try all of those again on Tuesday next week. Just letting
  > you know in case customers follow up about the delay.
  >
  > Please let these customers know they should not make any further direct
  > debits, and please cancel/disable any retry or other DD that might be
  > scheduled to prevent further delays."

## CRD refunds released but frozen

- Date: **2026-09-17**
- Channel: `#solutions_memorandum`
- Quote:
  > "Refunds for CRD have been released to Horizon overnight.
  >
  > Please do not process any refunds at this stage, and continue to escalate for
  > now.
  >
  > We need to test and make sure everything is working, and also clean up the
  > backlog from escalations etc to make sure the excess balances in Horizon are
  > accurate before we can return to BAU for refunds."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1789603795129409
- **Status as at harvest (2026-09-23): still the standing instruction.**

---
