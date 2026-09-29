# Issue intake and triage

How an issue reaches App Support, how it is picked up, how it is prioritised, and where it goes when it leaves.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` sections 1 and 10; `harvest/jira-raw-notes.md`; `harvest/confluence-systems-reference.md` sections 10 and 11; `harvest/confluence-content.md` (Ticket Handling Manual 454590514, Guide on Assessing a Support Ticket 1002766337, App Support Ticket Triage 2910191688, Reoccurring DataFix process 2524381287); `harvest/slack-tribal-knowledge.md` section 6.

## 1. How an issue arrives

Two front doors, and they behave differently.

**Slack, `#app-support`** (`GG7HL6CTE`, private, created 2019-02-15 by Jonathan Wu). This is where most work arrives. Reporters are Ops, Collections, Payments, Brokers and Partnerships, IDR and Complaints. They normally paste a Horizon deep link:

- `/Note/ApplicationNotes/{appId}`
- `/Transaction/Transactions/{appId}`
- `/Task/ApplicationTasks/{appId}`
- `/Stage/ApplicationStages/{appId}`
- `/Communication/ApplicationComms/{appId}`

**The MME Help Desk portal**, `https://moneyme1.atlassian.net/servicedesk/customer/portal/1`. Non-urgent requests are logged here directly (Confluence 2524381287).

The Operations-facing rule is explicit: anything **impacting funding, payments or application progression** goes into `#app-support` in Slack, and **Ops does not have to create a ticket for urgent fixes, the tech team does** (Confluence 2524381287). Everything else goes through the portal.

## 2. Pickup and the alert bot

1. A reporter posts in `#app-support`.
2. A bot auto-replies in-thread with the standing acknowledgement, unchanged all year:

   > Hi @{reporter}! Thanks for reporting this issue. The @app-support team will look into it. Please let us know if this is urgent or impacting multiple users so we can prioritize accordingly. Any additional information you can share would also be greatly appreciated. Thanks!

   The mention is the user group `S064ZJSAJ4X`.

3. App Support picks the issue up. Pickup fires an alert into `#app-support-issue-alerts` (`C05S9EFD738`) in this exact shape:

   > Hi team, @Ron is now looking into the issue @{reporter} reported. {permalink back to the `#app-support` message}

   Observed pickup names in the harvest window: Ron, Michael Dela Torre.

4. If it needs a ticket, a **Problem** is created in Jira project **MHD**. The Jira Slack integration then mirrors the whole lifecycle into `#app-support-issue-alerts`: `created a Problem`, `Waiting for Support`, the automation comment, `Waiting for Customer`, and so on.
5. New Problems default to **Unassigned, Priority Low**. Unassigned MHD tickets also surface in `#platform-unassigned-mhd-alerts`.

Note that the bot acknowledgement is not a pickup. An unacknowledged thread with a bot reply is still untriaged.

## 3. Information to collect before investigating

The Ticket Handling Manual template, used verbatim when chasing a reporter (Confluence 454590514):

> Hi there, can you provide us the following information below if possible? This is to help us with the investigation.
>
> - Application ID:
> - Screenshot/video of the issue/error:
> - Number of affected users:
> - Affected Platform (Mobile/Web):
> - Description of the issue:
> - Troubleshooting steps done:
> - Expected Outcome:

For Twilio and Comms there is a narrower list (Confluence 1002766337): for Twilio, the agent names, date and time, agent location, and the number called or calling; for Comms, the ApplicationID, date and time, TemplateId and optionally CustomerId.

## 4. Priority and urgency: the real convention

**MHD Priority is effectively unused as a triage signal.** Every Problem read in the Jira harvest was `Low`, including one carrying an IDR dispute and a media escalation threat ([03-procedures/jira-conventions.md](jira-conventions.md)). High and Highest appear almost exclusively on Change Requests and releases. Critical, 267 issues in twelve months, is concentrated in the security and Threat Intelligence feed, not in support tickets.

**Urgency is the field that carries meaning.** It is a custom field with its own SLA table and its own saved filters. The monthly Selected for Development reminder queries `Urgency in (High, Critical)` and never Priority, precisely because every ticket in that filter is Priority Low regardless of real urgency (see [`monthly-sfd-reminder-email.md`](monthly-sfd-reminder-email.md)).

Consequence worth stating plainly: anyone outside App Support who sorts the MHD backlog by Priority sees the entire list as bottom of the backlog. This is a field hygiene defect in the MHD scheme, not a reflection of the work.

### Urgency SLAs

From the MHD Ticket Urgency page (Confluence 398622726):

| Urgency | Response | Resolution |
| --- | --- | --- |
| Critical | 4 hours | 6 hours |
| High | 6 hours | 8 hours |
| Medium | 40 hours | 48 hours |
| Low | 240 hours | 240 hours |

### How urgency is actually set

- **The reporter declares it.** The intake bot explicitly asks whether the issue is urgent or impacting multiple users. That declaration is the primary driver (`#app-support`, standing bot text).
- **Direct debit issues are always urgent.** Rusty's standing rule (`#app-support`, 2026-07-01).
- **Anything that can move money to the wrong place is urgent by default.** Rebecca Sampson, 2026-09-17, after an application funded to the wrong bank account because a dealer lead source update sat in the queue:

  > "Can you please treat any requests for updates to dealer lead sources to be URGENT so that we don't have to muck around fixing funding issues after the event? ... when making these requests, can you please mark them as Urgent so the request doesn't get lost in amongst all the others"

  Ron's reply set the precedent: *"This is noted. Will set this type of requests to urgent next time. Datafix was implemented around 4pm PH time yesterday. I guess that was too late."*

- **Requests not marked urgent can miss the SQL dev window and slip a day.** The window is Mon to Fri, 12:00 to 13:00 and 16:00 to 17:00 Sydney time. See [`datafix-request.md`](datafix-request.md).

### Urgency and impact definitions

Used across the Comms runbooks (Confluence, Urgency and impact guide):

- **Urgency.** HIGH = the affected user can no longer perform primary work functions. MEDIUM = work functions impaired but a workaround exists. LOW = an inconvenience.
- **Impact.** HIGH = system-wide (business unit, department, area or location). MEDIUM = multiple users. LOW = single user.

Ops raising a non-urgent datafix through the portal are told to set **Urgency: High** and leave Impact and Severity blank (Confluence 2524381287), which further dilutes Urgency as a signal on portal-raised tickets. Treat Urgency as reliable on App Support's own tickets and sanity-check it on portal intake.

## 5. Problem versus Incident

**Incident is effectively dead in MHD.** 16 issues in twelve months against 2,252 Problems ([03-procedures/jira-conventions.md](jira-conventions.md)).

Everything is raised as a **Problem**, including events that are plainly incidents by any normal definition:

- a bulk Zepto dishonour affecting 185 accounts (MHD-36494)
- a 123 per cent repayment increase on a hardship customer (MHD-36071)
- a silent debit a year after loan closure with an IDR dispute attached (MHD-36446)

In practice, **Problem** in MHD means "anything reported to App Support", not the ITIL sense of an underlying cause behind repeated incidents. There is no incident, major-incident or severity process visible in the ticket data.

**Practical rule as things stand:** raise a Problem. Do not reach for Incident expecting a different workflow, because there is not one. If the event is genuinely major, the escalation happens in Slack (`#solutions_memorandum`, `#crd_firefighters`, the owning team channel) and the ticket is documentation, not the response mechanism.

**Unverified:** whether the MHD Incident type carries a distinct workflow or SLA at all. It was not exercised often enough in the harvest window to tell.

The second consequence of everything being a Low-priority Problem is that no field separates "one customer's SOA will not load" from "185 accounts were wrongly debited". Only the summary text distinguishes them. Write summaries accordingly.

## 6. Handling the ticket

From the Ticket Handling Manual (Confluence 454590514), condensed to what is actually done:

1. Open the unassigned ticket from the queue. Assign it to yourself or the correct team and move it to **Work in Progress**.
2. Check the ticket details: assignee, request type, reporter, request participants.
3. Read the description tab for urgency, severity and impact. Chase the reporter on Slack if information is missing, and record that you did in an internal note.
4. Link similar or related issues and use them as a guide. See the precedent index in [`../05-knowledge/`](../05-knowledge/).
5. Add an internal note with what the investigation found. Structure it per [`jira-conventions.md`](jira-conventions.md).
6. If you have a fix or workaround, reply to the reporter, confirm it works, set **Waiting for Customer**, and add an internal note.
7. If it is outside App Support's scope, use the MoneyMe Tech Team directory (`moneyme1.atlassian.net/wiki/x/S4lq`, TECHNOLOGY page 6981963) to find the right team, raise or link a ticket in their project, and set **Pending** or **Selected for Development**.
8. Once the reporter confirms, set **Completed** then **Closed**.

Before escalating, filter out noise. The App Support Ticket Triage page (Confluence 2910191688) asks four questions:

- Is this a known incident already being handled by another team?
- Is this a hotfix or deployment side effect that engineering owns?
- Is this expected behaviour from a feature, not actually a bug?
- Is this a misrouted report belonging to a different team?

Rusty's own standard applies here too: *"Reproduce on a second example"*, after being caught by two invalid examples coinciding on one day (2026-08-13), and *"I prefer to check thoroughly before involving them, especially since so many of those are agent error or expected behaviour"* on escalating to Tops (2026-08-04).

## 7. Escalation destinations

| Question or area | Go to |
| --- | --- |
| Product behaviour, "is this a defect?" | **Rusty (Joshua Allen)**, Product Owner for Prod Support, COL, AMZ, CRD |
| Payments, transactions, Horizon core | **Christopher "Tops" Enriquez**, **Harvey Dacutanan** |
| Funding | **Albert Rick Martires**; `#pending-funding-checks`, `#app-support-funding`, `#funding-dev-qa-supports` |
| Horizon task closure, funding ops | **Gabriel Pavlovic**, **Jamie Nguyen** |
| Comms templates, SendGrid, Twilio | `#app-support-twilio-comms`, `#twilio-team`; **Hazelrey Cate Erasmo (Haze)**, **Dave** |
| Mobile app | `#app-support-mobile-team`, **Aus** |
| CRD | `#app-support-crd`, `#crd_firefighters`; card forensics to **Murdo** ("the final boss of CRD transactions", Rusty) |
| Amortisation | **Jess Leal**, `#amortization-app-support` |
| Autopay, car loans, brokers | `#autopay_feedback`; **Rebecca Sampson (Bec)**, **Jef Sumarago**, **Hayley Smith** |
| Decision Engine, credit policy | **Ethan Campbell**, **Joanne Nguyen**, **Ulysses Consador**, **Alyssa (Aly) Ventura**, **Marvin Martin** |
| SQL execution | **Victor Anthony Alvarez**, **Maria Krizza Rosales**; urgent, **meghashree (Megha)** |
| Database permissions (unmask and similar) | **Jeffrey Lu** approves, Victor grants |
| Release CAB approval | `#tech-cab-approval-followups`: Jon, Julius, Fred, Jeffrey Lu |
| Complaints and IDR | **Raina Schmidt** |
| Ops-wide announcements | `#solutions_memorandum` |

**Access boundary worth knowing:** anything on the CRD Credit Card tab lives in **E6**, not Horizon, and a Horizon datafix will not touch it (Rusty, 2026-07-02). App Support holds no E6 or Mastercard logins; Mastercard admin is Julius Serrano, and for E6 updates ask Mhars Pabalan (Rusty, 2026-09-22).

Full ownership map in [`../05-knowledge/`](../05-knowledge/).
