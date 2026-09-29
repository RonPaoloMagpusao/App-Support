# Reoccurring DataFix process (Operations view)

Mirror of the Confluence page "Reoccurring DataFix process (Operations view)".

Last reviewed: 23 September 2026
Sources: Confluence OP page 2524381287, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: OP (Operations) · Page id: 2524381287 · Last updated: 9 Feb 2026 · Author: Rebecca Sampson
- URL: https://moneyme1.atlassian.net/wiki/spaces/OP/pages/2524381287/Reoccurring+DataFix+process

This is the Operations facing statement of the monthly umbrella ticket process, and the
counterpart to the App Support side of the same workflow. Scope is **APY and PL**.

One MHD parent ticket per month holds approval for all known issues requiring a **DataFix**,
defined here as "a manual correction made by the tech team to existing data where the system
cannot automatically resolve the issue".

**Critical issues.** Anything **impacting funding, payments or application progression** goes
directly into the app-support Slack channel (`GG7HL6CTE`). The team notifies the reporter in
the thread when the fix is implemented. **Ops does not have to create a ticket for urgent
fixes; the tech team does this.**

**Non-urgent issues.** Logged via the MME Help Desk portal
(https://moneyme1.atlassian.net/servicedesk/customer/portal/1), still monitored closely.

## Issues covered by the monthly parent ticket

- Update Customer account
- Create Customer account
- Remove Duplicate Customer
- Update Contact Number
- Update Email Address
- Remove Duplicate Email Address
- Move application to current account (Merge account)
- Remove incorrect uploaded file(s)
- PL/SPL Remove PPSR and Set Vehicle Asset Status to Removed
- APY Remove PPSR and Set Vehicle Asset Status to Removed
- Update PPSR (EdxRegistration)
- Change to Default (DC) Payment Method
- Remove Obsolete Disbursement from Disbursement Table (Funding Failed)

## Raising a non-urgent ticket

1. Go to the MME Help Desk portal.
2. Raise a **Report a System problem** ticket.
3. Fill out the required fields:
   - Title: `[APY] [Datafix] AppID - description`
   - Description must include the **App ID**, and **what the current data is and what it should
     be**
   - Urgency: High
   - Impact and Severity can be left blank
4. The team picks the request up from their dashboard, adds it to the monthly MHD Data Fix
   ticket, and notifies the requester of updates and resolution in the ticket comments.

---
