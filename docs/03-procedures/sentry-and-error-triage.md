# Sentry and error triage

Reading `#app-support-sentry-error-logs`: what lands there, where each project routes, what is noise, and where monitoring is moving.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` section 6; `harvest/confluence-systems-reference.md` section 5; `harvest/confluence-content.md` (Sentry Monitoring 1409548294, Uptime Site Monitoring 1409351830, Guide on Assessing a Support Ticket 1002766337); `#g3-announcements` 2026-09-03.

Channel: `#app-support-sentry-error-logs`, ID `C05PPSLUJ1K`, public, created 2023-08-28 by Julius Serrano. The Confluence page records it only by Slack ID, not by name.

## 1. What lands there

Sentry alerts from the `societyone` Sentry org. Each post carries:

- exception type
- the source file or endpoint
- the message
- Events count
- Users Affected
- State (`New` or `Ongoing`)
- First Seen
- Project
- Alert rule
- Short ID

Two alert rules dominate.

**`[App Support] Frequent Error`** carries a routing note in the alert body:

- `notes: @channel please check and coordinate with the PL Team on the issue` (for `decision-engine-api`)
- `notes: @channel please check and coordinate with the Team on the issue` (for `mailbox-downloader-azfunc` and `horizon-web`)

**`TEST`** is the `comms-api` rule. High volume, low value.

## 2. Projects and where each routes

| Sentry project | Typical error | Route to |
| --- | --- | --- |
| `decision-engine-api` | `StackExchange.Redis.RedisConnectionException` on `POST /api/decision-engine/run-enginename`, Redis `cache-moneyme-prod.redis.cache.windows.net:6380` socket closed | **PL team**, per the alert note |
| `comms-api` | `FirebaseAdmin.Messaging.FirebaseMessagingException` (`NotRegistered`, `APNs device token is disabled.`); `System.Net.Http.HttpRequestException` 400 from `AdapterOauthClientBase.Post` | Comms team. See the noise rule below |
| `mailbox-downloader-azfunc` | `Microsoft.Exchange.WebServices.Data.ServiceXmlDeserializationException` ("The expected XML node type was Element, but the actual type is EndElement.") in `EwsEmailClient` | Comms and platform |
| `horizon-web` | `System.Net.Http.HttpRequestException` 400 on `POST /Transaction/ReverseSpecificTransaction` | Horizon team |
| mobile projects | app crashes | `#app-support-mobile-team`, cc Aus |
| `AmortizationV2` | SSL `The remote certificate is invalid because of errors in the certificate chain: NotTimeValid` | `#amortization-app-support` |
| `twilio-web` (id 6704642) | Twilio web errors | Comms team. Also check Azure Table `livemoneymestorage` > `TwilioLogException` (Confluence 1002766337) |

Project links used in the runbooks:

- `https://societyone.sentry.io/projects/comms-api/?project=6704643`
- `https://societyone.sentry.io/projects/twilio-web/?project=6704642`

## 3. Triage rules that emerged

1. **Read the `notes:` line.** The alert tells you which team to coordinate with. That is the routing decision already made.
2. **`State: Ongoing` plus `First Seen: 2022-11-15` plus thousands of events plus `Users Affected: 1` is noise, not an incident.** The `comms-api` Firebase `NotRegistered` / `APNs device token is disabled` pair has been firing since 2022 against a single user. **Do not raise a ticket each time.**
3. **`State: New` plus `First Seen: Just now` is what to look at.** That is the whole filter for a morning sweep.
4. **Correlate with the customer-facing symptom before escalating.** Precedent: 2026-04-30, Ron tied a Sentry alert to a Twilio outage (*"Sentry also sent this before Twilio started failing"*). An alert with no reported symptom behind it is usually not worth a ticket; an alert that explains a live `#app-support` report is worth escalating immediately.
5. **Five occurrences of a Twilio web error is the threshold** at which the Comms Team needs to step in. Log the first instance and flag it, but it can otherwise be ignored (Confluence 1002766337).
6. **Check whether the service has moved to Uptrace** before treating a missing alert as "nothing is wrong". See section 5.

## 4. The documented eleven-step procedure

The Sentry Monitoring page (Confluence 1409548294, 31 Dec 2024) is written at a generic level and names no MoneyMe Sentry projects, DSNs or alert rules. The operationally useful parts:

1. Open the channel and find the alert.
2. Click through to the Sentry issue link.
3. Review the error message, stack trace, events, timestamp and affected environment.
4. Check occurrence count, user impact, and tags or custom metadata (version, release, environment).
5. Assign or acknowledge the issue.
6. Communicate status back to the Slack channel.
7. Track the resolution and watch for regressions.
8. Mark the issue Resolved in Sentry and document what was done in the issue comments.

Steps 3, 4 and 6 are the ones that matter in practice. The rest is boilerplate.

**Access.** Sentry team membership is managed at `https://societyone.sentry.io/settings/teams/mme/members/`. **Ron and Michael hold Team Admin** and can add people. Access is otherwise requested per the Sentry Access page (Confluence 1822621788).

## 5. The Sentry to Uptrace transition

**Sentry is being decommissioned in places.** Several services have already moved to **Uptrace / OpenTelemetry**:

| Service | Ticket |
| --- | --- |
| Twilio2 logging | G1-6164, MHD-34768 |
| MoneyMe.Communications | G1-6177, MHD-34989 |
| MFA API | announced `#g3-announcements`, 2026-09-03: *"Sentry has now been removed, so Uptrace is the only thing watching it"* |

**Uptrace**, the replacement (Confluence, systems reference section 5):

- Platform `app.uptrace.dev`. **QA project `8391`**, **PROD project `8392`**.
- Telemetry library `MoneyMe.Core.Opentelemetry` **1.0.4** owns the OTLP exporter. The collector endpoint and credentials come from Azure App Config and Key Vault. `[CREDENTIAL REDACTED]`
- Confirm a service is reporting:

  ```
  count() | group by service_name | group by deployment_environment_name
  ```

- QA project 8391 receives both `qa` and `development` telemetry. Filter on `deployment_environment_name = "qa"`.
- **Still on Sentry as at 3 Sep 2026:** `MoneyMe.Horizon` and `MoneyMe.BankStatement`, both .NET Framework 4.6.1. Sentry cannot be switched off until those move.
- **Known gap:** `MoneyMe.Affiliate.AzureFunc` emits `httpclient` spans only, in both QA and production. Read deployed worker behaviour from **Application Insights**, not Uptrace.

**Practical consequence.** If you expect an alert and it is not there, the service may have moved. Check Uptrace before concluding that nothing happened. The inverse also holds: a service that has moved will stop producing the Slack alerts this channel is built around, so channel silence is not evidence of health.

## 6. Adjacent monitoring

- **Uptime Robot**, dashboard `https://dashboard.uptimerobot.com/login`. HTTP(s) monitors, typically 5 minute intervals, alerting into Slack via an Incoming Webhook. Its up and down alerts arrive in MHD as tickets; closing those is a separate SOP, see [`jira-monitor-ticket-closure.md`](jira-monitor-ticket-closure.md). The Confluence page (1409351830) does not list which MoneyMe sites are actually monitored, which is a gap.
- **Application Insights**, the fallback for the Affiliate worker telemetry gap and for runs Uptrace missed (Confluence 3071442984).
- **FullStory**, session replay, used in login investigations to see where the customer actually stopped (Confluence 3131015188).

## 7. Related

- Comms and Twilio triage in depth: [`../02-runbooks/`](../02-runbooks/).
- Which team owns which service: [`../05-knowledge/`](../05-knowledge/).
- Raising the ticket once an alert is real: [`issue-intake-and-triage.md`](issue-intake-and-triage.md).
