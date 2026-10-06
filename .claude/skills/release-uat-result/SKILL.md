---
name: release-uat-result
description: 'Record a UAT or post-deployment test result on a Jira ticket in the App Support house format, and check a release ticket against the MHD release process. Use when Ron says he tested something, asks to post test results, is the Post Deployment Tester on a release, or asks whether a release ticket is ready.'
---

# Release and UAT

Source of truth: `docs/03-procedures/release-and-uat.md`. Statuses: `docs/03-procedures/jira-conventions.md` section 2.

## A. Post a test result

1. Get from Ron (ask for anything missing, never invent it): ticket key, environment, browser and version, the cases run and their outcomes, the application ID for production tests, attached evidence.
2. Build the comment in this exact order:

   ```
   Test Result: Passed | Failed
   AUT: <application under test> (<ticket>, <one-line change>)
   Browser Used: <browser and version>
   Test Environment: <QA | Integration | Production>, <host URL>
   Test Evidences:
     - <case>: <outcome> (screenshot attached)
   Notes:
     - <side effects, out-of-scope findings, follow-ups>
   ```

   Hosts: QA `https://qa-horizon.moneyme.net/`, Integration `https://integration-horizon.moneyme.net/` (UAT), Production `https://horizon.moneyme.com.au`.
3. Push for edge cases: test at, above and below any limit the change touches, and sanity-check shared components (see the HOR-8167 and MMM-9350 lessons in the procedure). If only the happy path was tested, say so in Notes.
4. Show Ron the comment, then post it with `addCommentToJiraIssue`.
5. Post-deployment test on a release: after posting, look up transitions and move to **Post-Deployment Test Successful** or **Failed** only if Ron says to; QA or the SM usually owns that move.

## B. Check a release ticket is ready

Read the MHD Change Request and report against the checklist: Release Notes link in the Azure Devops field; PR screenshots (one per PR); Post Deployment Tester set; planned end date on or before release date; linked stories or bugs carrying QA evidence; Urgency matches release type (Scheduled Low to Medium, Out-of-Schedule and Hotfix High to Critical, with the `Out-of-Schedule_Release` label); status Awaiting Implementation before release. Cutoff is the Wednesday before the fortnightly Tuesday release. Report gaps; do not edit the ticket unless asked.

Never reuse an MHD release ticket; a new change means a new ticket.
