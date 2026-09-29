# Ticket Handling (Manual)

Mirror of the Confluence page "Ticket Handling (Manual)".

Last reviewed: 23 September 2026
Sources: Confluence AS page 454590514, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 454590514 · Last updated: 1 Aug 2024 · Author: Ron Paolo Miguel Magpusao
- Contributors: Ron Paolo Miguel Magpusao, Anna Paulene Pascual, Michael Dela Torre
- Reviewer: Julius Serrano · Team: Application Support
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/454590514/Ticket+Handling+Manual

## Overview

Application Support performs or processes level 1 and 2 support tickets created in MHD and
resolves issues in a timely and efficient manner. The team also monitors, manages and responds
to problems and incidents via Jira and Slack. Depending on the ticket, the team may need to
replicate issues or bugs, raise tickets and follow through with the appropriate teams until the
problem is resolved.

## Application Support queues

- **New and Pending Tickets**: Jira filter `10200`. All new and existing tickets related to
  Application Support.
- **Unassigned tickets**: `moneyme1.atlassian.net/jira/servicedesk/projects/MHD/queues/custom/20`.
  Newly created tickets that are unassigned.
- **Aging Tickets**:
  `moneyme1.atlassian.net/jira/servicedesk/projects/MHD/section/problems/custom/88`.
  Tickets that are pending and have not been updated for more than 30 days.

Check all three queues daily at 8am.

## Related references

- **MME Help Center**: `moneyme1.atlassian.net/servicedesk/customer/portals`. Where users
  create or report an issue or incident.
- **MoneyMe Tech Team** directory: `moneyme1.atlassian.net/wiki/x/S4lq` (also at
  TECHNOLOGY space page 6981963). Used to work out which team or person can resolve a reported
  issue.
- **Ticket Urgency**: MHD space page 398622726. Critical, High, Medium or Low.
- **Ticket Severity**: `moneyme1.atlassian.net/wiki/x/L4CMFg`. Sev 1 to Sev 5.

## Ticket information template

> Hi there, can you provide us the following information below if possible? This is to help us
> with the investigation.
>
> - Application ID:
> - Screenshot/video of the issue/error:
> - Number of affected users:
> - Affected Platform (Mobile/Web):
> - Description of the issue:
> - Troubleshooting steps done:
> - Expected Outcome:

## How to handle a new ticket

1. The user creates a ticket in Jira or through the MME Help Center.
2. Go to **Jira > MME Help Desk Service Project > Queues > Unassigned tickets** to view the
   newly created ticket.
3. Open the ticket, assign it to yourself or to the correct dev/team, and change the status to
   **Work in Progress**. Check the urgency and acknowledge or resolve accordingly.
4. Check the ticket details are correct: assignee, request type, reporter, request participants.
5. Understand and analyse the issue described. Urgency, severity and impact are on the
   description tab. Contact the reporter on Slack if more information is needed, and add an
   internal note recording that.
6. Link similar or related issues; use them as a guide.
7. View the activity tab for additional information.
8. Add an internal note with what you found in your investigation.
9. If you have a workaround or resolution, reply to the reporter with the fix and confirm it
   works. Set the status to **Waiting for Customer** and add an internal note.
   - If you cannot fix it with the resources you have, use the MoneyMe Tech Team directory to
     find the right dev or team and contact them on Slack.
     - If the issue is in their scope, ask for the link to their dashboard, replicate or create
       a ticket there, link it to yours, and set the status to **Pending** or
       **Selected for Development**.
     - If they fixed it without needing a ticket, note the resolution on your ticket, reply to
       the reporter, and set the status to **Waiting for Customer**.
10. Once the reporter confirms the issue is resolved, set the status to **Completed, Closed**.

---
