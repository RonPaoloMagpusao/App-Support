# 03 Procedures

How the MoneyMe App Support team actually works: intake, triage, datafixes, funding, refunds, unblocks, Sentry, Jira and releases.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` sections 1 to 10; `harvest/jira-raw-notes.md`; `harvest/confluence-systems-reference.md` sections 10 to 13; `harvest/confluence-content.md` (Cover Runbook 3131015188, Ticket Handling Manual 454590514, Daily Alerts 899317845, New Release Process 2036138487, Reoccurring DataFix process 2524381287); `harvest/slack-tribal-knowledge.md` section 6.

## What is in this folder

| File | Covers |
| --- | --- |
| [`issue-intake-and-triage.md`](issue-intake-and-triage.md) | `#app-support` intake, pickup and the alert bot, Urgency versus Priority, urgency SLAs, Problem versus Incident, escalation destinations |
| [`datafix-request.md`](datafix-request.md) | `#datascript-requests`, the monthly umbrella ticket, request templates, the two competing "current" processes |
| [`funding-checks.md`](funding-checks.md) | `#pending-funding-checks`, the hourly bot, the triage ladder, the brand-id gotcha |
| [`account-unblock-and-reset.md`](account-unblock-and-reset.md) | `#unblock-account-request` and G3APIBot |
| [`refund-support.md`](refund-support.md) | `#refund-supports`, the CRD standing instruction, refund failure modes |
| [`sentry-and-error-triage.md`](sentry-and-error-triage.md) | `#app-support-sentry-error-logs`, project routing, Sentry to Uptrace |
| [`jira-conventions.md`](jira-conventions.md) | MHD issue types, statuses, resolutions, labels, comment visibility, linking, JQL library |
| [`jira-monitor-ticket-closure.md`](jira-monitor-ticket-closure.md) | SOP for closing MHD tickets: update the reporter, Completed then Closed, plus bulk-closing monitor up/down tickets |
| [`monthly-sfd-reminder-email.md`](monthly-sfd-reminder-email.md) | SOP for the monthly Selected for Development reminder email |
| [`release-and-uat.md`](release-and-uat.md) | Release types, MHD change request fields, post-deployment testing, house test result format |

Related folders: [`../02-runbooks/`](../02-runbooks/) for symptom-driven fixes, [`../04-sql/`](../04-sql/) for scripts and stored procedures, [`../05-knowledge/`](../05-knowledge/) for tribal knowledge and system behaviour.

## The daily loop

Two Confluence pages set the cadence: the Ticket Handling Manual says check all three Jira queues **daily at 8am** (Confluence 454590514), and the Daily Alerts page sets the `[AP]` alert sweep (Confluence 899317845). Everything else is channel-driven and continuous.

### Morning, in this order

1. **`#app-support-daily-alerts`**, the six `[AP]` checks (Confluence 899317845).

   - `[AP] App(s) Funded - without Equifax Score`: insert the missing score, see [`../04-sql/`](../04-sql/).
   - `[AP] Pending DD (2 days transaction)`: expected value is `0`; flag the team if not.
   - `[AP] Funded - NOT in Funded Status`: check Horizon, usually passes to Ops.
   - `[AP] APY/PL - Overfunding` and `[AP] Commission - Overfunding`: look for duplicate amounts on the Transactions tab, raise a Jira ticket.
   - `[AP] APY/PL Funded Apps - No MoneyOut`: usually a false positive when the transactions were made before **07:04 Philippine time** (Confluence 899317845).

2. **Jira MHD queues** (Confluence 454590514).

   | Queue | Where |
   | --- | --- |
   | New and Pending Tickets | filter `10200` |
   | Unassigned tickets | `/jira/servicedesk/projects/MHD/queues/custom/20` |
   | Aging Tickets, no update in 30+ days | `/jira/servicedesk/projects/MHD/section/problems/custom/88` |

   Also watch `#platform-unassigned-mhd-alerts`, which surfaces unassigned MHD tickets in Slack (`#app-support`, observed).

3. **`#app-support`** backlog from overnight. Pick up anything unclaimed; pickup fires the alert into `#app-support-issue-alerts`. See [`issue-intake-and-triage.md`](issue-intake-and-triage.md).

4. **`#pending-funding-checks`**. The hourly `Stuck in funding for 20 mins: {N}` count is not itself actionable; work the human requests in the channel. See [`funding-checks.md`](funding-checks.md).

5. **`#refund-supports`**. Same shape, `Stuck refund for 30 mins: {N}`. Note the standing CRD instruction not to process refunds. See [`refund-support.md`](refund-support.md).

6. **`#app-support-sentry-error-logs`**. Filter for `State: New` and `First Seen: Just now`; the long-running `comms-api` Firebase pair is noise. See [`sentry-and-error-triage.md`](sentry-and-error-triage.md).

### Through the day

- **`#app-support`** is continuous intake. The bot acknowledges; a human still has to pick up.
- **Datafix windows.** SQL Dev looks at new `#datascript-requests` posts Mon to Fri, **12:00 to 13:00** and **16:00 to 17:00 Sydney time** (channel purpose). Anything landing after roughly 16:00 PH slips a day (Ron, `#datascript-requests`, 2026-09-17). Write and post the script before the afternoon window.
- **`#unblock-account-request`** needs no App Support action; G3APIBot handles it. Watch only for bot failure. See [`account-unblock-and-reset.md`](account-unblock-and-reset.md).
- **`#autopay_feedback`** for broker, dealer and Autopay intake. Owners are Rebecca Sampson (Bec), Jef Sumarago and Hayley Smith ([03-procedures/README.md](README.md) section 9).
- **`#solutions_memorandum`** for standing Ops rulings from Rusty (Joshua Allen), Raina Schmidt, Bec and Ethan Campbell. Standing instructions such as the CRD refund freeze and the SOA generation ban originate here.
- **`#datascript-requests`** follow-ups: when a datafix errors, the SQL dev names the datafix number in channel. Fix and re-request.

### End of month

- The monthly `[App Support] Data Fix - YYYY-Mon` umbrella moves Implementing to Deployment Completed and a new one auto-creates on the 1st at about 09:00 ([03-procedures/jira-conventions.md](jira-conventions.md)).
- Harvey Dacutanan is on EOM cashflow reports and is effectively unavailable for payments escalations then (Rusty, 2026-07-01). Plan around it.
- The Selected for Development reminder email drafts on the 29th, see [`monthly-sfd-reminder-email.md`](monthly-sfd-reminder-email.md).

## Ownership at a glance

| Area | Owner |
| --- | --- |
| Is this a defect, product behaviour | Rusty (Joshua Allen), Product Owner |
| Funding | Albert Rick Martires |
| Horizon core, transactions, payments | Christopher "Tops" Enriquez, Harvey Dacutanan |
| Comms, Twilio, SendGrid | Hazelrey Cate Erasmo (Haze), Dave |
| Amortisation | Jess Leal |
| SQL execution | Victor Anthony Alvarez, Maria Krizza Rosales; urgent, meghashree |
| App Support | Ron Magpusao, Michael Dela Torre, Lary Rosario, Aina Kristina Dilao |
| Manager | Julius Serrano |

Full map in [`../05-knowledge/`](../05-knowledge/) and `harvest/slack-tribal-knowledge.md` section 6.
