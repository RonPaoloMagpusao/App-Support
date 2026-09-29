# Horizon, Replace Sentry by Uptrace

Mirror of the Confluence page "Horizon, Replace Sentry by Uptrace".

Last reviewed: 23 September 2026
Sources: Confluence TECHNOLOGY page 3071442984, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: TECHNOLOGY · Page id: 3071442984 · Last updated: 3 Sep 2026 · Owner: Ricky (Technical Lead, Horizon)
- URL: https://moneyme1.atlassian.net/wiki/spaces/TECHNOLOGY/pages/3071442984/Horizon+-+Replace+Sentry+by+Uptrace
- Document status: DRAFT, but maintained as a living register

**This page matters to App Support because it changes where errors are looked up.** The
App Support "Sentry Monitoring" page (1409548294) is being overtaken by this migration.

## The initiative

Retire Sentry across Horizon services and standardise error capture, traces, metrics and logs
on **OpenTelemetry → Uptrace**. The Sentry removal and OTel wiring rides inside the isolated
model / .NET 10 upgrade of each host.

| Item | Detail |
| --- | --- |
| Observability platform | Uptrace QA, project **8391**; Uptrace PROD, project **8392** (app.uptrace.dev) |
| Telemetry library | `MoneyMe.Core.Opentelemetry` **1.0.4**, owns the OTLP exporter. `CollectorEndpoint` is resolved by the package; credentials come from Azure App Config / Key Vault |
| Being retired | `MoneyMe.Core.Logging.Sentry`, `Sentry.AspNetCore`, `UseSentry()`, `AddSentryLogger()` |
| Register last verified | 3 Sep 2026 |

## Where it stands (as at 3 Sep 2026)

- **Projects moved:** 10 entries across 8 repositories, 5 Azure Function hosts, 2 ASP.NET Core
  APIs, 1 wired but undeployed worker, and 2 greenfield solutions.
- **Reporting to Uptrace QA (8391):** 7.
- **Reporting to Uptrace PROD (8392):** 3, `MoneyMe.SurveyMonkey.AzureFunc`,
  `MoneyMe.Affiliate.Api`, `MoneyMe.Affiliate.AzureFunc`.
- **Sentry references remaining:** zero across every repository on the register.
- **Still on Sentry:** `MoneyMe.Horizon` and `MoneyMe.BankStatement`, both .NET Framework
  4.6.1. **Neither has started, so Sentry cannot be switched off.** `MoneyMe.Horizon` is the
  core Horizon application and the largest single piece of work remaining.
- **Not wired yet:** `MoneyMe.ExternalAgency.AzureFunc`, `MoneyMe.Mailbox.AzureFunc` (isolated
  model done, no OTel).
- No schema or infrastructure change: a package swap and host wiring only. The OTLP collector
  already exists and is shared by roughly 30 MoneyMe services.

## Services on the register

| Project | Platform | Highest env | Notes |
| --- | --- | --- | --- |
| `MoneyMe.CollectionReminder.AzureFunc` | Azure Functions isolated net10.0 | QA | Dashboard **Collection Reminder: Health (QA)** id 53614, the template every later board copied |
| `MoneyMe.Affiliate.AzureFunc` (replaces `MoneyMe.Affiliate.NetCore`) | Azure Functions isolated net10.0 | PROD | Dashboards 54262 (QA) and 54418 (Prod). **httpclient spans only**, see caveat |
| `MoneyMe.Workflow.AzureFunc` | Azure Functions isolated net10.0 | QA | Dashboard **Workflow: Health (QA)** id 53705 |
| `MoneyMe.BankStatement.AzureFunc` | Azure Functions isolated net10.0 | QA | Dashboard id 53777 |
| `MoneyMe.SurveyMonkey.AzureFunc` | Azure Functions isolated net10.0 | PROD | Dashboards 54007 (QA) and 54193 (Prod). First Horizon service in this initiative to reach production |
| `MoneyMe.Search.Api` | ASP.NET Core net8.0 | QA | Dashboard 54415. **Code not yet merged**, both PRs still open; QA was deployed from the feature branch. Release rides on MHD-31486 |
| `MoneyMe.Search.AzureFunc` | Azure Functions isolated net8.0 | DEV only | Dashboard 54416, empty by construction. No deployment pipeline, never run in any environment |
| `MoneyMe.Affiliate.Api` (replaces legacy `MoneyMe.Affiliate` API) | ASP.NET Core net10.0 | PROD | Dashboards 54261 (QA) and 54417 (Prod). First ASP.NET Core entry in production, first through a `deploy` slot swap |
| `MoneyMe.BankStatement.V2` (revamp of `MoneyMe.BankStatement`) | Web API + NServiceBus, net10.0 | DEV only | Greenfield, OTel from the start. Shipping V2 retires Sentry from the bank statement stack |
| `MoneyMe.Workflow.V3` (event-driven workflow engine) | Web API + NServiceBus, net10.0 | DEV only | Greenfield, separate from `MoneyMe.Workflow.AzureFunc` |

## Known gap that affects error investigation

`MoneyMe.Affiliate.AzureFunc` **reports but not completely.** In both QA and production, the
deployed worker emits **only `httpclient` spans**: no `funcs` span, no
`db:microsoft.sql_server` span, even across timer runs that provably queried Horizon2_QA.
Sampling, `SqlInstrumentation.Enabled` and exporter health have all been ruled out.

**Consequence:** the Google Ads API-sunset monitor queries Uptrace and only the worker runs
that pipeline, so **that monitor would not fire from the deployed worker**. Until it is
resolved, **read deployed worker behaviour from Application Insights, not Uptrace.** The
caveat belongs to the worker alone; `MoneyMe.Affiliate.Api` emits `httpserver` and SQL spans in
both environments.

Leading, untested hypothesis: the Functions worker creates its invocation `Activity` from a
source the TracerProvider never registers, so under `ParentBased` sampling every child span
inherits an unsampled parent and is dropped, which would explain HTTP client spans surviving
because those start their own root.

## Confirming a service is really reporting

Run against Uptrace QA. If the service name does not come back, it is not on Uptrace whatever
the code says.

```sql
count() | group by service_name | group by deployment_environment_name
```

Two gotchas before reading a dashboard:

1. **QA project 8391 receives both `qa` and `development` telemetry.** Developers running a
   host locally against QA back ends export into the same project. Filter on
   `deployment_environment_name = "qa"` to isolate genuinely QA-deployed activity.
2. **Scope every grouped panel by service at the query level.** Filtering inside the metric
   expression scopes the value but not the grouping, so a grouped panel enumerates all ~30
   services sharing the project. Each grouped panel needs its own top level
   `where service_name = "<service>"`.

## How a project gets onto the register

1. Remove every `Sentry.*` and `MoneyMe.Core.Logging.Sentry` package reference and the
   `UseSentry` / `AddSentryLogger` wiring from all hosts.
2. Add `MoneyMe.Core.Opentelemetry` **1.0.4** to every host project and register it in the
   composition root. The package owns the exporter; do not register an OTLP exporter by hand.
3. Align the `OpenTelemetry` section of each `appsettings.<Env>.json` to the library
   documentation (TECHNOLOGY page 2529755256). Collector endpoint and credentials come from App
   Config / Key Vault and must never be committed.
4. Deploy to QA, then confirm the service is genuinely emitting. A successful build is not proof.
5. Author the health dashboard as YAML, commit it under `docs/uptrace/` in the repo, and publish
   it to project 8391.
6. Add the row to the register.

**Do not add Sentry to any new or upgraded host.** `MoneyMe.Core.Logging.Sentry`,
`Sentry.AspNetCore`, `UseSentry()` and `AddSentryLogger()` are deprecated at MoneyMe.

---
