# Environments and URLs

Production, QA and integration environments with their URLs, internal API base URLs, Azure resources, third party consoles, and the Jira, Confluence and Slack coordinates App Support works from.

Last reviewed: 23 September 2026

Sources: Confluence 426082342 (APY Environments and Credentials), 3131015188 (App Support Cover Runbook), 264175641 (Account Escalations in Slack), 1772126209 (Payment Channels), 550961514 (MoneyMe API's), 1078689857 (Comms API Support), 1079181314 and 1079312385 (Twilio, Comms), 3071442984 (Replace Sentry by Uptrace), 1409351830 (Uptime), 454590514 (Ticket Handling), 519602304 (SQL Data Fix scripts), 2524381287 (Reoccurring DataFix process), 1409351766 (DataFix Guide), 498401800 (Data Fix Manual); [01-systems/README.md](README.md) sections 6 and 9; [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 6 and 7; [03-procedures/README.md](../03-procedures/README.md) section 6; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md); [06-reference/confluence-index.md](../06-reference/confluence-index.md).

## Credentials

None are recorded here. Confluence 426082342 publishes dozens of QA **and production** portal usernames and passwords in plain text, plus EDX/PPSR, ID Kit, Illion and Swagger basic auth credentials. `[CREDENTIAL REDACTED - Confluence page 426082342]`. This is a known, unresolved finding ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 1.1). Get access through the owning team or the password manager, never from that page.

## Horizon

| Environment | URL | Source |
| --- | --- | --- |
| Production | `https://horizon.moneyme.com.au` | Confluence 3131015188, 264175641, 1772126209 (the App Support and Ops pages) |
| Production | `https://horizon4.moneyme.com.au/` and `https://horizon4.moneyme.com.au/Application/Applications` | Confluence 426082342 (the APY page) |
| Production | `https://horizon-az.moneyme.com.au` | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7 only |
| QA | `https://qa-horizon.moneyme.net/` | Confluence 426082342 |
| Integration | `https://integration-horizon.moneyme.net/` | Confluence 426082342 |

**The sources disagree on the production host.** The App Support and Ops pages use `horizon.moneyme.com.au`; the APY Environments page, updated 26 August 2026, uses `horizon4.moneyme.com.au`. Slack describes all three production hosts as live front ends onto the same Horizon. App Support uses `horizon.moneyme.com.au` daily. Unverified: whether `horizon4` and `horizon-az` are aliases, regional or load-balanced front ends, or legacy hosts kept alive. Confirm with the Horizon team (Ricky) before putting either alternative in a runbook.

Note the domain split: production is `moneyme.com.au`, QA and integration are `moneyme.net`.

## Customer, partner and payment front ends

| System | Environment | URL | Source |
| --- | --- | --- | --- |
| APY Partner Portal | Production | `https://www.autopay.com.au/login` | Confluence 426082342 |
| APY Partner Portal | QA | `https://qa-autopay.moneyme.com.au/` | Confluence 426082342, Environments table |
| APY Website | QA | `https://qa-autopay.moneyme.net/` | Confluence 426082342, URL reference table |
| APY Website | Integration | `https://integration-autopay.moneyme.net/` | Confluence 426082342 |
| APY Website | Production | `https://www.autopay.com.au/` | Confluence 426082342 |
| Autoscan | Production | `https://www.autopay.com.au/application/quote-applicant-details?bid=APYNSW11003` | Confluence 426082342 |
| Autoscan | QA | `https://qa-autopay.moneyme.com.au/application/quote-applicant-details` | Confluence 426082342 |
| APY Decline Page | Production | `https://www.moneyme.com.au/application/applicationdecline` | Confluence 426082342 |
| APY Decline Page | QA | `https://qa-application.moneyme.net/application/applicationdecline` | Confluence 426082342 |
| Customer Portal | Production | `https://web2.moneyme.com.au/login` | Confluence 426082342 |
| Customer Portal | QA | `https://dev-www.moneyme.net/` | Confluence 426082342 |
| ECA / payment portal | Production | `https://application.moneyme.com.au/payment-portal?aie=...&SourceId=...` | [01-systems/README.md](README.md) section 6; originating page not identified |
| ECA view | Production | `https://application.moneyme.com.au/eca/eca-view-app?aie=...` | As above |
| Minified payment link | Production | `https://moneyme.com.au/u?c=<code>` | As above. The shortened link used in SMS and email; each is unique to the ApplicationId (Confluence 1772126209) |
| Partnership portal | Production | `https://partnership.moneyme.com.au/` | Confluence 519602304, item 67 |

**Two QA hosts for the APY front end, on one page.** Confluence 426082342 lists `qa-autopay.moneyme.com.au` in its Environments table (as the Partner Portal) and `qa-autopay.moneyme.net` in its URL reference table (as the APY Website). It is unclear whether these are the same application on two domains or two applications. Unverified. Confirm with the Autopay QA team (Melissa Pabillano authored the page).

The ECA and payment portal URLs carry an `aie` parameter that identifies the application. Do not paste a live one into a ticket or this repo.

## Internal APIs

### QA base URLs

Source: Confluence 550961514 (January 2024, QA only, several rows blank).

| Project | QA base URL |
| --- | --- |
| Amortization | blank on the page |
| AmortizationV2 | `https://api-amortization-v2-qa.azurewebsites.net/` |
| Application | `https://api-application-qa.azurewebsites.net/` |
| Bank Statement | blank |
| Bills Engine | `https://qa-api-billsengine.azurewebsites.net/` |
| Collection | `https://moneyme-collection-api-qa.azurewebsites.net/` |
| Communication | `https://api-communication-qa.azurewebsites.net/`, Swagger at `/swagger/ui/index` |
| DecisionEngine | `https://api-decision-engine-qa.azurewebsites.net/` |
| Equifax | blank |
| FreeStyle | `https://api-freestyle-qa.azurewebsites.net/` |
| Funding | blank |
| GlassGuide | blank |
| Mobile | `https://api-mobile-qa.azurewebsites.net/`, Swagger at `/swagger/index.html` |
| Payment | blank |
| Settings | blank |
| Sypht | blank |

Other QA endpoints:

| Endpoint | URL | Source |
| --- | --- | --- |
| Amortization Swagger (monthly repayment, balloon, total repayments) | `https://qa-microservice.moneyme.net/Amortization/swagger/ui/index` | Confluence 426082342. Basic auth `[CREDENTIAL REDACTED - Confluence page 426082342]` |
| Glass's Guide Swagger (odometer adjustment) | `https://qa-microservice.moneyme.net/GlassGuide/swagger/ui/index` | Confluence 426082342. Basic auth `[CREDENTIAL REDACTED - Confluence page 426082342]` |
| SPV API | `spv-api-qa.azurewebsites.net` | [01-systems/README.md](README.md) section 6 |
| Mobile API bank-feed mock | `POST /api/v1/application/{id}/bankstatements/default`, `GET /api/v1/application/{id}/bankaccounts`, `POST /api/v1/bankaccount` on the Mobile API | Confluence 426082342 |

### Production base URLs

**None are recorded in any harvested page.** Unverified. Only production resource names are known (below). Confirm production API hosts from the Azure portal or the owning teams.

## Azure resources

| Resource | Purpose | Source |
| --- | --- | --- |
| Subscription `d2c61912-1986-42ce-ae47-24f987ce73aa` | Holds the Comms and contract generator resources | Confluence 1078689857 |
| Resource group `MicroserviceLive2` > `mme-communications-live` | Comms API app service; logs in App Service Editor > Log | Confluence 1078689857 |
| `api-communication2-prod` | Second comms host, owner of `messagingqueue2` | Confluence 1079312385 |
| Queues `messagingqueue`, `messagingqueue2` | Comms message queues | Confluence 1079312385 |
| Resource group `MoneyMe_New` > `azf-contract-generator-prod` | Contract generator Azure Function | [01-systems/README.md](README.md) section 6 |
| `azf-affiliate-v2-prod` | The Affiliate worker | [01-systems/README.md](README.md) section 6 |
| `livemoneymestorage` > table `TwilioLogException` | Twilio exception log | Confluence 1079181314 |
| `qa-ae-svc-soa-bus` | SOA NServiceBus host in QA | [01-systems/README.md](README.md) section 6 |
| `cache-moneyme-prod.redis.cache.windows.net:6380` | Production Redis used by the Decision Engine; seen in `RedisConnectionException` alerts | [03-procedures/README.md](../03-procedures/README.md) section 6.2 |
| Azure App Config / Key Vault | Holds the Uptrace collector endpoint and credentials | Confluence 3071442984 |

## Databases

| Database | Environment |
| --- | --- |
| `Horizon2` | Production |
| `Horizon2_QA` | QA |
| `Payment` | Production |
| `Communication` | Production |

See `horizon-database.md`. No database server names or connection strings are recorded here, by rule.

## Third party consoles

| Console | URL | Notes |
| --- | --- | --- |
| SendGrid | `https://app.sendgrid.com/` | OTP to phone on login (Confluence 1060864395) |
| Twilio Console | `https://console.twilio.com/` | Monitor > Messaging |
| Twilio status | `https://status.twilio.com/` | |
| Twilio network test | `https://networktest.twilio.com/` | |
| Twilio error dictionary | `https://www.twilio.com/docs/api/errors` | |
| Sentry | `https://societyone.sentry.io/` | Projects `twilio-web` (6704642), `comms-api` (6704643); team admin at `/settings/teams/mme/members/` |
| Uptrace | `app.uptrace.dev` | QA project 8391, PROD project 8392 |
| Uptime Robot | `https://dashboard.uptimerobot.com/login` | |
| EDX / PPSR (ESIS) | `https://web.uat.esisweb.com.au` | UAT. Production contact is Cal (Confluence 426082342) |
| MoneyMe ID Kit | `https://moneyme.idkit.co/portal/login` | Biometrics / Equifax. Production contact Bec or Cal |
| Zepto | Portal URL not recorded | Production escalation is the CTO and Lary (Confluence 426082342) |
| E6, Mastercard | Not recorded | App Support holds no login. Mastercard admin is Julius Serrano ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 6.3) |

## Jira

| Item | Value | Source |
| --- | --- | --- |
| Site | `https://moneyme1.atlassian.net` | |
| cloudId | `d9911a71-58c8-4d3c-a772-0f89702b5921` | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| App Support project | **MHD**, MME Help Desk | |
| MME Help Center (customer portal) | `https://moneyme1.atlassian.net/servicedesk/customer/portal/1`; a ticket is at `/servicedesk/customer/portal/1/MHD-xxxxx` | Confluence 2036138487, 2524381287; [03-procedures/README.md](../03-procedures/README.md) |
| Help Center portal list | `moneyme1.atlassian.net/servicedesk/customer/portals` | Confluence 454590514 |
| New and Pending Tickets | Filter `10200` | Confluence 454590514 |
| Unassigned tickets | `/jira/servicedesk/projects/MHD/queues/custom/20` | Confluence 454590514 |
| Aging Tickets (no update in 30+ days) | `/jira/servicedesk/projects/MHD/section/problems/custom/88` | Confluence 454590514 |
| Release Board | RB, board 81 | [01-systems/README.md](README.md) section 10 |
| Monthly datafix umbrella | `[App Support] Data Fix - YYYY-Mon`. September 2026 is **MHD-36184**; August 2026 was MHD-35277 | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |

Queues are checked daily at 8am (Confluence 454590514).

The umbrella key changes every month. Find the current one with `project = MHD AND summary ~ "App Support Data Fix" ORDER BY created DESC`, and query both `Blocks` and `Cover` links to enumerate its children ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).

### MHD issue type ids

| Id | Type |
| --- | --- |
| 10130 | Problem |
| 10125 | `- Service Request` (leading hyphen and space; quote it in JQL) |
| 10128 | Change Request with Approvals |
| 10129 | Change Request Data Fix/External with Multiple Approvals |
| 10053 | Production Support (HOR, not MHD) |

Source: [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md).

## Confluence

Site: `https://moneyme1.atlassian.net/wiki`. Page URLs follow `/wiki/spaces/<KEY>/pages/<id>/<title>`.

| Space | Name | Relevance |
| --- | --- | --- |
| `AS` | Platform and Support (homepage "App Support") | The App Support space |
| `TO` | Tech Ops | Holds a **duplicate copy of most AS pages**, frozen at 2025-07-04. Different page ids, stale content, no warning. Prefer the AS copy ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 6.1) |
| `HOR` | Horizon | Stage and status registers, payment channels, business rules |
| `TECHNOLOGY` | Technology | Engineering: Twilio, Braze, Uptrace migration, G3APIBot |
| `OP` | Operations | Ops runbooks, Zepto / Split tasks, escalations |
| `MHD` | MME Help Desk | Urgency and SLA |
| `IR` | Incident Report | Incident process |
| `AUT` | Autopay | APY environments |
| `APL` | Credit Card | CRD statements, Mastercard, Sardine |
| `PL` | Personal Loans | PL releases, SEON |

Source: [06-reference/confluence-index.md](../06-reference/confluence-index.md).

Short links recorded on Confluence 454590514: MoneyMe Tech Team directory `moneyme1.atlassian.net/wiki/x/S4lq` (also TECHNOLOGY page 6981963); Ticket Severity `moneyme1.atlassian.net/wiki/x/L4CMFg`.

Key page ids for App Support: 3131015188 (Cover Runbook), 3117842457 (Datafix catalogue), 2485059655 (Store Procedures), 519602304 (SQL Data Fix scripts), 2385150262 (Pending Funding and Refund support), 1293647889 (Stage and Status Logs), 1772126209 (Payment Channels), 426082342 (APY Environments), 3071442984 (Sentry to Uptrace).

## Slack

Workspace: `moneymefinance.slack.com`. Permalinks follow `/archives/<channel id>/p<ts>`.

| Channel | ID | Purpose | Source |
| --- | --- | --- | --- |
| `#app-support` | `GG7HL6CTE` | Main intake, and where Ops post critical datafixes | Confluence 2524381287; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| `#app-support-sentry-error-logs` | `C05PPSLUJ1K` | Sentry alerts | Confluence 1409548294 |
| `#app-support-daily-alerts` | | `[AP]` daily alert feed | Confluence 899317845 |
| `#datascript-requests` | Unverified; `C07JY7GMEMT` is cited on datascript and escalation tickets | Production script execution. Tag Victor Alvarez and Krizza Rosales. Window Mon to Fri 12:00 to 13:00 and 16:00 to 17:00 Sydney time | Confluence 3131015188; [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 2; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| `#pending-funding-checks` | Unverified; `C05J8HEVC81` is cited on funding and stage-stuck tickets | Funding queue, hourly "stuck in funding" bot | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| `#refund-supports` | Unverified; `C0C1ETVFW87` is cited on refund tickets | Refund queue, hourly "stuck refund" bot | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| `#unblock-account-request` | | Account unblocks via G3APIBot, `reset {email}` | Confluence 3131015188 |
| `#autopay_feedback` | | Autopay data fix requests; the AU side posts Philippine public holiday heads-ups here | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 8 |
| `#app-support-mobile-team` | | Mobile app issues; Aus, Paul, Stefan | Confluence 3131015188 |
| `#app-support-crd` | `C0ANUL7JYR3` | CRD support | [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) section 4.1 |
| `#solutions_memorandum` | `CFY7LHEJW` | Ops announcements and product rulings | [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) |
| `#horizon-collections-team` | `C03K89BMFAL` | Collections and payment rules | [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) |
| `#tech-cab-approval-followups` | | Release CAB approvals | Confluence 498401800 |
| `#comms-daily-check` | | Bulk message queue monitoring | Confluence 1079312385 |
| `#mme-solutions` / `mme_solutions` | | Operations account escalations | Confluence 264175641 |
| (Jeffrey Lu / Jon Wu datafix approval) | `C056NTCCX96` | Old CR approval route | Confluence 1409351766 |
| (DB team) | `C02HB99AXDX` | Database team | Confluence 1409351766 |
| (Broker and Autopay issues) | `C03DYRHJ1C6` | Inferred from tickets | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| (Equifax and credit score) | `C06LR1SJJ8Y` | Inferred from tickets | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |

Channel ids marked "inferred from tickets" come from the "Issue created in Slack from a message" link at the foot of MHD descriptions; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) infers each channel's purpose from the tickets that cite it and does not name the channel. Confirm by opening the id in Slack.

Other working channels named in the sources: `#app-support-funding`, `#funding-dev-qa-supports`, `#funding-issues`, `#horizon-funding-team`, `#crd_firefighters`, `#twilio-team`, `#app-support-twilio-comms`, `#twilio-tech-app-support`, `#twilio-tech-ops-workgroup`, `#comms-fixing`, `#amortization-app-support`, `#customer-retention`, `#g3-announcements`, `#net-devs-only`, `#api-to-fe`, `#collections-payments-daily-support-team`, `#unsaved-card-payments` ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 6; [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md)).
