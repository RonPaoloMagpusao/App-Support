# DataFix Guide

Mirror of the Confluence page "DataFix Guide".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1409351766, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1409351766 · Last updated: 31 Dec 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1409351766/DataFix+Guide

Ten step process. Note this is the older, approval heavy variant; the Cover Runbook
(page 3131015188) documents the current monthly umbrella ticket workflow, which differs.

1. **Ticket creation.** Create a DataFix ticket in Jira. Include the issue description, steps
   to reproduce, the desired fix approach or script outline, and supporting context such as
   data samples or screenshots.
2. **Ticket review.** Check all required information is present, the problem and fix approach
   are clearly defined, and the required approvers (**Jeffrey Lu**, **Jon Wu**) are listed.
3. **Obtain approval from Jeffrey Lu and Jon Wu.** Slack channel `C056NTCCX96`.
4. **Approval confirmation.** Update the ticket status to "Approved" and record both approvals.
5. **Collaboration with the DB team.** Slack channel `C02HB99AXDX`.
6. **DB team review and preparation.** They verify the script works as intended and introduces
   no unintended changes: verify against a test environment where possible, review the impact
   on production data, confirm backups are in place.
7. **Run the DataFix script.** The DB team runs it in the appropriate environment, monitors for
   errors and ensures data integrity.
8. **Post fix validation.** Check the impacted data points, run queries to confirm no
   unintended changes, test the application for side effects or regressions.
9. **Ticket closure.** Document the outcome, attach logs or screenshots, set status Resolved or
   Closed.
10. **Communication and documentation.** Notify the requester, document the steps taken, and
    schedule a follow up review if needed.

---
