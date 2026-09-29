# Monitoring

Sentry, Uptrace, Uptime Robot, Application Insights and FullStory: what each covers, what lands where, and what App Support is expected to do with each.

Last reviewed: 23 September 2026

Sources: Confluence 3071442984 (Horizon, Replace Sentry by Uptrace), 1409548294 (Sentry Monitoring), 1409351830 (Uptime: Site Monitoring), 899317845 (App Support Daily Alerts), 3131015188 (App Support Cover Runbook), 1079312385 (Comms Known Issue and Resolution); [03-procedures/README.md](../03-procedures/README.md) section 6; [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 1, 2, 4 and 6; [07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.4.

## Summary

| Tool | Covers | Where alerts land | App Support's job |
| --- | --- | --- | --- |
| Sentry | Error tracking for Horizon, BankStatement and the services not yet migrated | `#app-support-sentry-error-logs` (ID `C05PPSLUJ1K`) | Triage every new alert, route by the `notes:` line, ignore known noise |
| Uptrace | OpenTelemetry traces, errors, metrics and logs for migrated services | Dashboards in Uptrace. No Slack feed is documented | Know which services moved, so a missing Sentry alert is not read as "all clear" |
| Uptime Robot | HTTP(s) availability of sites | A Slack channel via Incoming Webhook (`#uptime-alerts` is the page's example) | Investigate down alerts |
| Application Insights | Azure-native telemetry | Azure portal | Fallback for the Affiliate worker gap, and for runs Uptrace missed |
| FullStory | Session replay of customer web sessions | FullStory | Login and journey investigations: see where the customer actually stopped |

---

## Sentry (being retired)

### What it is

| Item | Value |
| --- | --- |
| Organisation | `societyone.sentry.io` |
| Known projects | `twilio-web` (id 6704642), `comms-api` (id 6704643), `decision-engine-api`, `mailbox-downloader-azfunc`, `horizon-web`, `AmortizationV2`, mobile projects |
| Slack channel | `#app-support-sentry-error-logs`, ID `C05PPSLUJ1K`, public, created 2023-08-28 by Julius Serrano. The Confluence page records it only by ID |
| Team admin | Ron and Michael hold **Team Admin** at `https://societyone.sentry.io/settings/teams/mme/members/` and can add people |
| Access requests | Per the "Sentry Access" page, AS 1822621788 |

The project ids for `twilio-web` and `comms-api` come from Confluence 1079181314 and 1078689857. The other project names come from alerts observed in the channel ([03-procedures/README.md](../03-procedures/README.md) section 6.2).

### What lands in the channel

Each post carries the exception type, source file or endpoint, message, Events count, Users Affected, State (`New` / `Ongoing`), First Seen, Project, Alert rule and Short ID.

Two alert rules dominate:

- **`[App Support] Frequent Error`**, which carries a routing note in the alert body:
  - `notes: @channel please check and coordinate with the PL Team on the issue` (for `decision-engine-api`)
  - `notes: @channel please check and coordinate with the Team on the issue` (for `mailbox-downloader-azfunc`, `horizon-web`)
- **`TEST`**, the `comms-api` rule. High volume, low value.

### Projects and where they route

| Sentry project | Typical error | Route to |
| --- | --- | --- |
| `decision-engine-api` | `StackExchange.Redis.RedisConnectionException` on `POST /api/decision-engine/run-enginename`, Redis `cache-moneyme-prod.redis.cache.windows.net:6380` socket closed | **PL team**, per the alert note |
| `comms-api` | `FirebaseAdmin.Messaging.FirebaseMessagingException` (`NotRegistered`, `APNs device token is disabled.`); `System.Net.Http.HttpRequestException` 400 from `AdapterOauthClientBase.Post` | Comms team. See the noise rule below |
| `mailbox-downloader-azfunc` | `Microsoft.Exchange.WebServices.Data.ServiceXmlDeserializationException` ("The expected XML node type was Element, but the actual type is EndElement.") in `EwsEmailClient` | Comms / platform. Note inbound email is owned by the Horizon team (Confluence 1078689857) |
| `horizon-web` | `System.Net.Http.HttpRequestException` 400 on `POST /Transaction/ReverseSpecificTransaction` | Horizon team |
| mobile projects | App crashes | `#app-support-mobile-team`, cc Aus |
| `AmortizationV2` | SSL `The remote certificate is invalid because of errors in the certificate chain: NotTimeValid` | `#amortization-app-support` |
| `twilio-web` | Twilio web client errors | Comms / Twilio team |

### Triage rules

1. **Read the `notes:` line.** The alert tells you which team to coordinate with.
2. **Read `State` and `First Seen` before treating an alert as new** ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 1).
3. `State: Ongoing` + `First Seen: 2022-11-15` + thousands of events + `Users Affected: 1` is noise, not an incident. The `comms-api` Firebase `NotRegistered` / `APNs device token is disabled` pair has been firing since 2022 against a single user. Do not raise a ticket each time.
4. `State: New` + `First Seen: Just now` is what to look at.
5. **Correlate with a customer-facing symptom before escalating.** Precedent: on 2026-04-30 Ron tied a Sentry alert to a Twilio outage ("Sentry also sent this before Twilio started failing").
6. If an expected alert is missing, check whether that service has moved to Uptrace.

The Confluence Sentry Monitoring page (1409548294, December 2024) is an eleven step generic procedure: open the channel, click through, review stack trace, events, users and tags, assign or acknowledge, report status back in Slack, track, resolve and document in Sentry. It names no MoneyMe project, DSN or alert rule, and is being overtaken by the migration ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.4).

### Why Sentry cannot be switched off yet

`MoneyMe.Horizon` and `MoneyMe.BankStatement` are both .NET Framework 4.6.1 and neither has started the migration, so Sentry stays until they move. `MoneyMe.Horizon` is the largest single piece of work remaining (Confluence 3071442984, as at 3 September 2026).

Do not add Sentry to any new or upgraded host. `MoneyMe.Core.Logging.Sentry`, `Sentry.AspNetCore`, `UseSentry()` and `AddSentryLogger()` are deprecated at MoneyMe.

### The sources disagree on how much is still on Sentry

- **Confluence 3071442984**: "Sentry references remaining: zero across every repository on the register." Only Horizon and BankStatement are still on Sentry.
- **`#app-support-sentry-error-logs`, observed in the harvest window**: alerts still arrive from `decision-engine-api`, `comms-api`, `mailbox-downloader-azfunc`, `AmortizationV2` and mobile projects.
- **Slack announcements**: Twilio2 logging (G1-6164, MHD-34768), MoneyMe.Communications (G1-6177, MHD-34989) and the MFA API have moved to Uptrace. `#g3-announcements`, 2026-09-03: "Sentry has now been removed, so Uptrace is the only thing watching it" (said of the MFA API).

Reading: the Confluence register covers **Horizon services only**. Decision Engine, AmortizationV2, the mailbox downloader and the mobile apps are not on it, so "zero remaining" is true of the register, not of the estate. The `comms-api` alerts conflict with the Communications migration unless they pre-date MHD-34989. Unverified: which Sentry projects are still receiving events today. Confirm from the Sentry organisation's project list, sorted by last event.

---

## Uptrace (the replacement)

### What it is

OpenTelemetry-based observability replacing Sentry across Horizon services. The Sentry removal and OTel wiring ride inside each host's isolated model / .NET 10 upgrade (Confluence 3071442984, owner Ricky, Technical Lead, Horizon).

| Item | Value |
| --- | --- |
| Platform | `app.uptrace.dev` |
| QA project | **8391** |
| PROD project | **8392** |
| Telemetry library | `MoneyMe.Core.Opentelemetry` **1.0.4**, owns the OTLP exporter |
| Collector | Shared by roughly 30 MoneyMe services. Endpoint and credentials come from Azure App Config / Key Vault. `[CREDENTIAL REDACTED - never committed, lives in Key Vault]` |
| Register last verified | 3 September 2026 |

### Services on the register

| Project | Platform | Highest env | Dashboards |
| --- | --- | --- | --- |
| `MoneyMe.CollectionReminder.AzureFunc` | Azure Functions isolated net10.0 | QA | Collection Reminder: Health (QA) id 53614, the template later boards copied |
| `MoneyMe.Affiliate.AzureFunc` | Azure Functions isolated net10.0 | PROD | 54262 (QA), 54418 (Prod). **httpclient spans only** |
| `MoneyMe.Workflow.AzureFunc` | Azure Functions isolated net10.0 | QA | Workflow: Health (QA) id 53705 |
| `MoneyMe.BankStatement.AzureFunc` | Azure Functions isolated net10.0 | QA | 53777 |
| `MoneyMe.SurveyMonkey.AzureFunc` | Azure Functions isolated net10.0 | PROD | 54007 (QA), 54193 (Prod). First Horizon service in the initiative to reach production |
| `MoneyMe.Search.Api` | ASP.NET Core net8.0 | QA | 54415. Code not yet merged; release rides on MHD-31486 |
| `MoneyMe.Search.AzureFunc` | Azure Functions isolated net8.0 | DEV only | 54416, empty by construction |
| `MoneyMe.Affiliate.Api` | ASP.NET Core net10.0 | PROD | 54261 (QA), 54417 (Prod) |
| `MoneyMe.BankStatement.V2` | Web API + NServiceBus, net10.0 | DEV only | Greenfield |
| `MoneyMe.Workflow.V3` | Web API + NServiceBus, net10.0 | DEV only | Greenfield |

Reporting to PROD 8392 as at 3 September 2026: `MoneyMe.SurveyMonkey.AzureFunc`, `MoneyMe.Affiliate.Api`, `MoneyMe.Affiliate.AzureFunc`. Not wired yet: `MoneyMe.ExternalAgency.AzureFunc`, `MoneyMe.Mailbox.AzureFunc`.

### Confirming a service is really reporting

```sql
count() | group by service_name | group by deployment_environment_name
```

If the service name does not come back, it is not on Uptrace whatever the code says.

Gotchas:

1. **QA project 8391 receives both `qa` and `development` telemetry**, because developers running locally against QA back ends export into it. Filter on `deployment_environment_name = "qa"`.
2. **Scope every grouped panel by service at the query level** with a top level `where service_name = "<service>"`. Filtering inside the metric expression scopes the value but not the grouping, so a grouped panel enumerates all ~30 services sharing the project.

### Known gap: the Affiliate worker

`MoneyMe.Affiliate.AzureFunc` emits **only `httpclient` spans** in both QA and production: no `funcs` span, no `db:microsoft.sql_server` span, even on runs that provably queried `Horizon2_QA`. Sampling, `SqlInstrumentation.Enabled` and exporter health have been ruled out. The Google Ads API-sunset monitor queries Uptrace and would not fire from the deployed worker. **Read deployed worker behaviour from Application Insights, not Uptrace.** `MoneyMe.Affiliate.Api` is not affected.

### What App Support does with Uptrace

Nothing is documented. There is no App Support runbook for Uptrace: how to get access, which project to open, or how to find an error for a given application ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.4). Unverified: whether App Support has Uptrace logins. Confirm with Ricky. Until then, use it to confirm whether a service is reporting, and route errors to the owning team.

---

## Uptime Robot

Dashboard: `https://dashboard.uptimerobot.com/login` (Confluence 1409351830).

- HTTP(s) monitors, typically at a 5 minute interval.
- Green is up, red is down. Uptime statistics and logs show how often a site goes down.
- Alerts go to Slack via an Incoming Webhook configured under My Settings > Notifications > Add Notification > Slack. The page uses `#uptime-alerts` as its example channel.
- Alert messages carry the site URL, the status change and the timestamp.
- On a down alert, open the monitor logs for downtime history and outage duration, then investigate server status and network connectivity.

Unverified: which MoneyMe sites are actually monitored and which Slack channel receives the alerts. The page lists neither. Confirm by logging in to the dashboard.

---

## Application Insights

Azure's native telemetry. In the sources it appears only as:

- The fallback for the `MoneyMe.Affiliate.AzureFunc` telemetry gap.
- The place that captured every step of a run Uptrace missed (Confluence 3071442984).

For the Comms API, the equivalent evidence is the file logs in App Service Editor rather than Application Insights (Confluence 1078689857). See `communications.md`.

Unverified: which resources have Application Insights enabled and whether App Support has read access. Confirm in the Azure portal under subscription `d2c61912-1986-42ce-ae47-24f987ce73aa`.

---

## FullStory

Session replay, used in login investigations to see where the customer actually stopped (Confluence 3131015188). Useful because a "successful login" in our data only means the password was accepted and the customer reached the OTP step, not that they got in.

Unverified: FullStory URL, which web properties are instrumented, and how access is granted. None is recorded in the sources.

---

## Other feeds App Support watches

These are Slack bot feeds rather than monitoring tools, but they are where much of the monitoring signal actually arrives.

| Feed | Cadence | Channel | Source |
| --- | --- | --- | --- |
| `[AP]` daily checks: apps funded without Equifax score, pending DD over 2 days, funded but not in Funded status, APY/PL overfunding, commission overfunding, funded apps with no MoneyOut | Daily | `#app-support-daily-alerts` | Confluence 899317845 |
| "No MoneyOut" false positives | Appear when transactions are made before **07:04 Philippine time** | `#app-support-daily-alerts` | Confluence 899317845 |
| "Stuck in funding for 20 mins" | Hourly, on the hour, 24/7 | `#pending-funding-checks` | observed |
| "Stuck refund for 30 mins" | Hourly, on the hour, 24/7 | `#refund-supports` | observed |
| Bulk message backlog | On backlog | `#comms-daily-check` | Confluence 1079312385 |
| Threat Intelligence Review tickets from `defender-noreply@microsoft.com` | Continuous, 437 in the window | MHD project | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md). Exclude from support metrics |
