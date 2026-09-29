# Incident Report Process

Mirror of the Confluence page "Incident Report Process".

Last reviewed: 23 September 2026
Sources: Confluence IR page 601653285, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: IR (Incident Report) · Page id: 601653285 · Last updated: 31 Mar 2026 · Author: Anna Paulene Pascual
- URL: https://moneyme1.atlassian.net/wiki/spaces/IR/pages/601653285/Incident+Report+Process

Referenced from the App Support "Application Support Process" page as the detailed process flow
and guide for incident reports.

## Create the ticket in Jira

1. Go to Jira and click Create.
2. Fill out the necessary details for the ticket/incident.
3. Double check the details and fill in anything missing.
4. After investigating, update or add information to the ticket for tracking.
5. Use the ticket to work with the people affected and with the leads/devs working on it.

## Create the incident report

1. Go to Confluence and open the **Incident Report** space.
2. Create a child page under `Incident report FY00 > Month`. If the month page does not exist,
   create the child directly under `Incident report FY00`.
3. Create the incident report as a child page for that month, or copy the
   **Template** (IR space page 594411943). Using the template is recommended.
4. Document and explain the incident in detail, in plain language.
5. Refer to the severity level table on the page.
6. **Update the document once the incident is resolved**, including the workaround used to fix
   it temporarily. The page explicitly flags this step as important, and says to update the
   report both during and after the work.

## Sending the email

Create a new email in Outlook, put the leads and stakeholders in To or Cc, put the incident
name in the subject, and use this body structure:

| Field | |
| --- | --- |
| **System (Affected Service):** | |
| **Severity:** | **Date/Time of Occurrence:** |
| **Priority:** | **Status:** |
| **Functionality:** | |
| **Impact:** | |
| **Customers Affected:** | |
| **How was the issue identified?** | |
| **Event Description:** | |
| **Initial Assessment / Potential Root Cause:** | |
| **Steps taken:** | |
| **Ticket Raised for this Incident:** | |
| **Assigned Team/Person:** | |

Fields are optional; add or remove based on the incident report template.

## Working on the incident

1. Once identified, contact the lead or dev who handles the system or process involved.
2. Ask for updates and information to add to the incident report while working with them.
3. Once resolved or a workaround is found, confirm it fixed the issue and update the incident
   report with the steps.
4. Go back to the lead or dev if the resolution or workaround did not work.

## Creating an incident report from a reporter's lodged ticket

Required fields for the reporter: System (Affected Services), Impact, Priority, Event
Description, Date of Detection.

Fields the support team fills in on Jira: Functionality, Number of Customers Impacted,
Secondary Impacts, How was the issue identified?, Initial Assessment / Potential Root Cause,
Date of Action, Assigned Team/Person (Next Action), Action Taken, Workaround, Resolution, Date
of Resolution.

Also add any linked or related tickets via Link work item in Jira. An automated comment is
added linking back to this process page.

---
