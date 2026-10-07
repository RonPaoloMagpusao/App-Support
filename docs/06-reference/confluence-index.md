# Confluence index

Every Confluence page relevant to App Support, by space, with a verdict on whether it is worth reading.

Last reviewed: 23 September 2026
Sources: Confluence, moneyme1.atlassian.net, 23 September 2026

Harvested 23 September 2026 from https://moneyme1.atlassian.net/wiki (cloudId
`d9911a71-58c8-4d3c-a772-0f89702b5921`). Read only: no Confluence page was created, edited or
commented on.

Page URLs follow the pattern
`https://moneyme1.atlassian.net/wiki/spaces/<SPACE>/pages/<page id>/<slug>`, so the space key
plus page id in the tables below resolves to the live page. The slug is omitted for brevity.

## Verdict key

| Verdict | Meaning |
| --- | --- |
| **mirror** | Copy the substance into the private repo, close to verbatim. Operationally load bearing. |
| **summarise** | Worth carrying across, but condensed. Usually a process page with a lot of ceremony, or a periodic record with a few durable facts in it. |
| **reference only** | Leave in Confluence, link to it from the repo. Useful context, but it changes on someone else's schedule or belongs to another team. |
| **skip** | Not worth mirroring. Recurring logs, empty templates, sprint notes, superseded drafts, or content with no App Support relevance. |

---

## 1. Spaces found

`getConfluenceSpaces` returned 56 global spaces. There is **no space literally named
"App Support"**. The App Support space is **`AS`, whose display name is now "Platform and
Support"** and whose homepage is still titled "App Support". That is the primary target.

### Primary and directly relevant

| Key | Name | Status | Why it matters | Pages found |
| --- | --- | --- | --- | --- |
| `AS` | Platform and Support (homepage "App Support") | current | **The App Support space.** Runbooks, datafix catalogues, stored procedures, comms and Twilio guides, release process, ticket handling, KPI history. | 125 |
| `HOR` | Horizon | current | Horizon feature and business-rule documentation: stage and status registers, fees, payment channels, customer level management, CRC/CCC, SPL/UPL workflow rules. | 129 |
| `TECHNOLOGY` | Technology | current | Engineering home. Twilio platform docs, contract generator, Braze scheduler, Sentry to Uptrace migration, API BOT Knowledge Vault, G3APIBot, sprint goals. | large, sampled via CQL |
| `TO` | Tech Ops | current | Holds a **duplicated copy of most AS pages**, re-parented under a "Platform and Support" page on 2025-07-04, plus the Tech Support Officer BAU handover. Otherwise daily security operations logs. | 250+ (paginated) |
| `OP` | Operations | current | The Ops-facing counterparts: Reoccurring DataFix process, Zepto/Split Account task handling, Account Escalations in Slack, the Zepto reference page. | sampled via CQL |
| `MHD` | MME Help Desk | current | Ticket urgency and SLA definitions, help desk request types. | sampled via CQL |
| `IR` | Incident Report | current | Incident Report Process and the incident report template. | sampled via CQL |

### Adjacent and worth linking

| Key | Name | Relevance |
| --- | --- | --- |
| `AUT` | Autopay | APY environments and credentials, AutoGrab/LVR, broker API authentication, underwriting backlog. |
| `APL` | Credit Card | CRD Statement of Account, Mastercard APIs, Google Pay provisioning, Sardine tokenisation. |
| `PL` | Personal Loans | PL release pages including SEON fraud integration and the OneDebt validation fix. |
| `COL` | Collections | Collections process material. |
| `Comms`, `CG` | Communications, Communications (G4) | Comms platform documentation. |
| `DD` | Data Dictionary | Table and column reference. |
| `DI` | Data Intelligence | Reporting and data platform. |
| `DE` | Decision Engine | Decisioning rules. |
| `FS` | Functional & Product Specification | Product specs. |
| `TS` | Technical Support | IT helpdesk how-tos; one App Support relevant page (Horizon error code for SSO). |
| `TPM` | Tech Project Management | Helpdesk Ticket Process, release and PM frameworks. |
| `QAT`, `QAAUT`, `QSI2` | QA spaces | Test data, environments, Maestro setup. |
| `RCT` | Risk and Compliance Team | Zepto suspicious activity notifications. |
| `PE` | Product Enhancement | Horizon 3.0 updates, Unblocking customers proposal. |
| `Cybersecur` | Cybersecurity | SSDLC, incident response templates. |
| `MMEPAY`, `AUT`, `LST`, `LSP`, `PBM` | Autopay / ListReady / Lead Sell / Broker Marketing | product spaces, low App Support value. |

### Archived spaces (read only, listed for completeness)

`MTO` (MME Tech operations), `MOBILE` (Mobile Releases), `TEC` (TechOps), `STT` (S1/MME Tech
Teams), `AD` (Azure DevOps), `MK` (Manila KK), `DM1` (D2C Marketing), `MIH` (MoneyMe Internal
Helpdesk).

### Not relevant

`HR`, `MH`, `MAR`, `AM`, `CMT`, `UD`, `EXPT`, `PEN`, `ITSAMPLE`, `SUPPORT`, `TC`, `G`, `PROD`,
`FAQ`, `DM`, `PT`, `ONBOARDING`, `CS`, `CS1`, `SS`, `JAR1`.

---

## 2. Priority list, the pages to mirror first

These are the pages read in full during this harvest. Extracted content is in
[06-reference/confluence-mirror/README.md](confluence-mirror/README.md).

| # | Space | Title | Page id | Updated | One line | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | AS | App Support Cover Runbook, Ron's Top Recurring Issues | 3131015188 | 2026-08-26 | The eleven recurring issue types that make up two thirds of ticket volume, with symptom, cause, exact fix and escalation for each | **mirror, the single most valuable page in the tree** |
| 2 | AS | Datafix catalogue, symptom routing reference | 3117842457 | 2026-08-21 | Routes a ticket symptom to the right fix source; Pass A lookup queries; landmines in the raw scripts; reference IDs | **mirror** |
| 3 | AS | Store Procedures for App Support - Common datafixes | 2485059655 | 2026-09-15 | The 16 parameterised `dbo.AppSupport_*` procedures with EXEC samples and full CREATE bodies | **mirror** |
| 4 | AS | SQL Data Fix scripts | 519602304 | 2026-09-28 | The ~100 item master catalogue of raw fixes keyed to historical MHD tickets | **mirror, with redaction**, contains plaintext passwords and hashes |
| 5 | AS | Pending Funding and Refund support | 2385150262 | 2026-08-26 | Sweep and drill-down queries for stuck funding and refunds, plus the fix for each cause | **mirror** |
| 6 | AS | Common Login SQL Data Fix Scripts | 1398210569 | 2025-03-13 | Eight login fixes plus the single most useful diagnostic query in the tree | **mirror, with redaction**, contains a password hash |
| 7 | AS | App Support Daily Alerts | 899317845 | 2026-01-22 | What each `[AP]` alert in `#app-support-daily-alerts` means and what to run | **mirror** |
| 8 | AS | [Twilio] Known Issue and Resolution | 1079181314 | 2024-10-23 | Twilio call and campaign troubleshooting with `Communication` DB queries and config IDs | **mirror** |
| 9 | AS | [Comms] Known Issue and Resolution | 1079312385 | 2024-09-11 | CommsMuteRule logic, SendGrid suppressions, queue backlog workaround, merge tag errors | **mirror** |
| 10 | AS | [Comms API] Support | 1078689857 | 2024-09-11 | DNC and marketing opt-out checks, Azure log keywords, Twilio console checks | **mirror** |
| 11 | AS | Ticket Handling (Manual) | 454590514 | 2024-08-01 | The queues, the SLA check cadence, the information template and the new ticket workflow | **mirror** |
| 12 | AS | Guide on Assessing a Support Ticket | 1002766337 | 2024-09-11 | What to collect before escalating a Twilio or Comms ticket, and the Sentry project links | **mirror** |
| 13 | AS | App Support - Data Fix Manual | 498401800 | 2024-01-12 | The Change Request ticket field values, implementation/test/rollback plan formats, approval channels | **mirror** |
| 14 | AS | Common issues in App Support | 546701313 | 2025-12-01 | The older symptom to action triage table | **mirror**, short and still used |
| 15 | AS | DataFix Guide | 1409351766 | 2024-12-31 | The older ten step approval heavy datafix process | **summarise**, superseded in practice by the monthly umbrella ticket |
| 16 | AS | Zepto Process | 580845583 | 2024-02-06 | How MoneyMe integrates with Zepto: OAuth2, webhooks, IP whitelisting, HMAC | **mirror** |
| 17 | AS | MoneyMe API's | 550961514 | 2024-01-24 | QA base URLs for 16 internal APIs | **mirror**, but stale, production URLs missing |
| 18 | AS | New Release Process | 2036138487 | 2025-09-01 | Current release process end to end, with status names and cutoff rules | **mirror** |
| 19 | AS | Release Process | 995033259 | 2025-07-30 | The superseded version of the same | **skip**, keep only the delta, noted in the content file |
| 20 | AS | Sentry Monitoring | 1409548294 | 2024-12-31 | Eleven generic steps for working a Sentry alert | **summarise**, generic, and overtaken by the Uptrace migration |
| 21 | AS | Uptime: Site Monitoring | 1409351830 | 2024-12-31 | Uptime Robot setup and Slack webhook alerting | **summarise**, no list of monitored sites |
| 22 | AS | Sendgrid | 1060864395 | 2024-09-04 | Three steps to find an address in SendGrid Activity | **mirror**, tiny; merge with the Comms page |
| 23 | AS | Frequently raised tickets for manual processing | 882868262 | 2024-06-20 | Two saved JQL queries for automation candidates | **mirror**, the JQL is the content |
| 24 | AS | 🏢 Tech & Product Team Directory | 456556548 | 2026-04-21 | Who owns what across 17 teams; the escalation map | **mirror** |
| 25 | AS | App Support Ticket Triage | 2910191688 | 2026-06-03 | Intro to filtering noise before escalating to App Support | **summarise**, parent page only, children carry the substance |
| 26 | OP | Reoccurring DataFix process | 2524381287 | 2026-02-09 | The Ops-facing monthly umbrella ticket process and the list of covered fixes | **mirror** |
| 27 | OP | Zepto/Split Account Task Handling Guide | 2286321665 | 2026-08-24 | The two Split account Horizon tasks, error codes and the "close the task to retry" behaviour | **mirror** |
| 28 | OP | Account Escalations in Slack | 264175641 | 2026-07-03 | The Ops escalation matrix and the Slack compliance rules on customer data | **mirror** |
| 29 | IR | Incident Report Process | 601653285 | 2026-03-31 | How to raise, document and communicate an incident | **mirror** |
| 30 | MHD | Urgency | 398622726 | 2023-09-27 | Critical/High/Medium/Low definitions with response and resolution SLAs | **mirror** |
| 31 | HOR | Stage & Status Logs | 1293647889 | 2026-02-18 | The authoritative active status and stage registers with behaviour per stage | **mirror, highest value page outside AS** |
| 32 | HOR | Payment Channels | 1772126209 | 2025-04-03 | Every way money reaches an account and how to identify the channel afterwards | **mirror** |
| 33 | TECHNOLOGY | How to investigate missing contract | 942047312 | 2025-01-29 | The contract-not-sent runbook, including the workflow criteria elimination method | **mirror** |
| 34 | TECHNOLOGY | Horizon - Replace Sentry by Uptrace | 3071442984 | 2026-09-03 | Living register of the Sentry to Uptrace migration; changes where errors are looked up | **mirror** |
| 35 | TECHNOLOGY | G3APIBot, How to Teach the Bot New Facts | 2994733113 | 2026-07-05 | How the Slack bot used for unblocks learns and is corrected | **mirror** |
| 36 | AUT | APY Environments and Credentials | 426082342 | 2026-08-26 | APY and Horizon environment URLs, test fixtures, ABNs, wagtest naming | **mirror environments and fixtures only; never mirror the credentials** |
| 37 | TO | BAU Task Handover - Tech Support Officer | 2378465296 | 2026-01-30 | The Tech Support Officer BAU categories and Jira ticket filters | **summarise** |
| 38 | AS | Application Support Process | 502825229 | 2025-03-31 | Top level process page; body is a diagram plus two links | **reference only**, the diagram is an image, not text |

### Read but thin, or intentionally not read in full

| Space | Title | Page id | Note | Verdict |
| --- | --- | --- | --- | --- |
| AS | MHD Ticket Investigator, AI agent runbook | 3116564495 | Parent of the Datafix catalogue; describes the `investigate MHD-xxxxx` agent flow summarised on the Cover Runbook | mirror |
| AS | Investigation output format | 3117154358 | The shape of a completed investigation write-up | mirror |
| AS | Application Support Process Flow | 1224704086 | Diagram page | reference only |
| AS | Split Sched / CRD Payment Processing Failures (9-15 July 2026) | 3022159961 | Incident write-up behind Cover Runbook issue 05 | mirror |
| AS | June / July Ticket Triage | 2909765695 / 3022389323 | Monthly triage records | summarise into a pattern list |
| AS | Selected for development *(13 dated pages)* | 890863871 and children | Rolling lists of tickets pushed to dev | skip, superseded each cycle |
| AS | Q2 FY24 to Q3 FY25 KPI Achievements *(6 pages)* | under 457474081 | Quarterly KPI records | skip, historical reporting |
| AS | Progress trackers (monthly, 2026) | under 2875293732 | Monthly activity logs | skip, but useful as evidence of recurring work volume |

---

## Full page inventory by space

### Space `AS` (125 pages returned)

| Space | Title | Page id | Last updated | Verdict |
| --- | --- | --- | --- | --- |
| AS | September Progress Tracker 2026 | 3155787864 | 2026-09-21 | summarise |
| AS | Store Procedures for App Support - Common datafixes | 2485059655 | 2026-09-15 | mirror |
| AS | Pending Funding and Refund support | 2385150262 | 2026-08-26 | mirror |
| AS | App Support Cover Runbook, Ron's Top Recurring Issues | 3131015188 | 2026-08-26 | mirror |
| AS | Datafix catalogue, symptom routing reference | 3117842457 | 2026-08-20 | mirror |
| AS | MHD Ticket Investigator, AI agent runbook (App Support cover) | 3116564495 | 2026-08-20 | mirror |
| AS | Investigation output format, what a completed MHD investigation looks like | 3117154358 | 2026-08-20 | reference only |
| AS | August Progress Tracker 2026 | 3068297553 | 2026-08-19 | summarise |
| AS | SQL Data Fix scripts | 519602304 | 2026-09-28 | mirror |
| AS | July Progress Tracker 2026 | 2982773887 | 2026-07-22 | summarise |
| AS | Split Sched / CRD Payment Processing Failures (9-15 July 2026) | 3022159961 | 2026-07-16 | mirror |
| AS | July Ticket Triage | 3022389323 | 2026-07-16 | mirror |
| AS | MHD Problem Tickets: H1 2025 vs H1 2026 | 2983264317 | 2026-07-01 | reference only |
| AS | MHD Problem Ticket Time Savings Analysis | 2983297077 | 2026-07-01 | reference only |
| AS | June Progress Tracker 2026 | 2901639189 | 2026-07-01 | summarise |
| AS | June Ticket Triage | 2909765695 | 2026-06-03 | mirror |
| AS | App Support Ticket Triage | 2910191688 | 2026-06-03 | mirror |
| AS | May Progress Tracker 2026 | 2875523138 | 2026-06-03 | summarise |
| AS | Monthly Tracker | 2875293732 | 2026-06-01 | summarise |
| AS | 🏢 Tech & Product Team Directory | 456556548 | 2026-04-21 | mirror |
| AS | Conditional Policy Exemption | 1947467836 | 2026-03-08 | summarise |
| AS | WinSCP Setup Guide - FileZilla alternative | 2590048345 | 2026-02-23 | summarise |
| AS | App Support Daily Alerts | 899317845 | 2026-01-21 | mirror |
| AS | Remove establishment fee for eligible customers | 2043445262 | 2026-01-15 | mirror |
| AS | Common issues in App Support | 546701313 | 2025-12-01 | mirror |
| AS | Selected for development 30/10/25 | 2232844289 | 2025-10-30 | mirror |
| AS | HID Portal and Skytunnel - Door Access | 1795325953 | 2025-10-20 | summarise |
| AS | Selected for development 04/09/25 | 2072051799 | 2025-09-04 | mirror |
| AS | New Release Process | 2036138487 | 2025-09-01 | mirror |
| AS | Release Process | 995033259 | 2025-07-30 | mirror |
| AS | Sophos - OpenVPN - Add Mac Address | 1904181354 | 2025-05-27 | summarise |
| AS | LOC - SOA request with target date only | 1896612474 | 2025-05-22 | mirror |
| AS | Arrears Balance Issue | 1895563267 | 2025-05-21 | mirror |
| AS | Sophos - OpenVPN Access | 1763017178 | 2025-05-07 | summarise |
| AS | How to generate SOA for old accounts with lots of transactions | 1843462801 | 2025-04-30 | mirror |
| AS | Sentry Access | 1822621788 | 2025-04-23 | mirror |
| AS | Sophos - OpenVPN - Reset password | 1806139408 | 2025-04-15 | summarise |
| AS | Q3 FY25 KPI Achievements | 1429307393 | 2025-03-31 | skip, recurring log / template / out of scope |
| AS | Add a Permission for a Group in Horizon | 1763737619 | 2025-03-31 | summarise |
| AS | Add a user in Horizon | 1762853068 | 2025-03-31 | summarise |
| AS | Update an App in Kandji | 1763508243 | 2025-03-31 | summarise |
| AS | Reset a User’s Password in Microsoft Intune | 1762427113 | 2025-03-31 | summarise |
| AS | Add a New User in Microsoft Intune & Assign Permissions | 1763278882 | 2025-03-31 | summarise |
| AS | Add Users to a Group in Microsoft Intune | 1763377176 | 2025-03-31 | summarise |
| AS | Manually Update Apps in Microsoft Intune Using TeamViewer | 1762951246 | 2025-03-31 | summarise |
| AS | Microsoft Intune Application Updates | 1762820263 | 2025-03-31 | summarise |
| AS | Kandji - MacOS Migration | 1761640527 | 2025-03-31 | summarise |
| AS | Workstation Patch Management | 1763737604 | 2025-03-31 | summarise |
| AS | Application Support Process | 502825229 | 2025-03-31 | mirror |
| AS | Laptop Setup | 1762525185 | 2025-03-31 | summarise |
| AS | APY / SPL vehicles updates SQL DF Scripts | 1397882974 | 2025-03-17 | mirror |
| AS | Common Login SQL Data Fix Scripts | 1398210569 | 2025-03-13 | mirror |
| AS | Incorrect URL ID Fix | 1409351844 | 2025-02-26 | mirror |
| AS | Download Files in Emails | 1615003784 | 2025-02-20 | mirror |
| AS | Q2 FY25 KPI Achievements | 1206059081 | 2025-01-08 | skip, recurring log / template / out of scope |
| AS | Uptime: Site Monitoring | 1409351830 | 2024-12-31 | mirror |
| AS | Sentry Monitoring | 1409548294 | 2024-12-31 | mirror |
| AS | Download and Upload BPAY Files | 1409417316 | 2024-12-31 | mirror |
| AS | DataFix Guide | 1409351766 | 2024-12-31 | mirror |
| AS | Selected for development 12/05/24 | 1333919810 | 2024-12-24 | mirror |
| AS | Interest Adjuster Manual | 1375600813 | 2024-12-19 | mirror |
| AS | Misplaced Amortization | 1354432513 | 2024-12-19 | mirror |
| AS | Selected for development 11/05/24 | 1238564882 | 2024-11-05 | mirror |
| AS | Application Support Process Flow | 1224704086 | 2024-10-31 | mirror |
| AS | Q1 FY25 KPI Achievements | 927006812 | 2024-10-25 | skip, recurring log / template / out of scope |
| AS | Selected for development 10/22/24 | 1193738243 | 2024-10-23 | mirror |
| AS | [Twilio] Known Issue and Resolution | 1079181314 | 2024-10-22 | mirror |
| AS | Selected for development 10/08/24 | 1159168001 | 2024-10-22 | mirror |
| AS | Selected for development tickets | 890863871 | 2024-10-08 | mirror |
| AS | Selected for development 09/24/24 | 1114865738 | 2024-09-24 | mirror |
| AS | APY Update Loan Contract (with APR adjustment) | 1108574342 | 2024-09-20 | mirror |
| AS | APR Decrease | 883589121 | 2024-09-20 | mirror |
| AS | Kill Stuck Actualization Background Process | 606470186 | 2024-09-20 | mirror |
| AS | APY APR Adjustment Recovery Part 2 | 695599120 | 2024-09-20 | mirror |
| AS | APY APR Adjustment Recovery Part 1 | 883228674 | 2024-09-20 | mirror |
| AS | [Comms API] Support | 1078689857 | 2024-09-11 | mirror |
| AS | [Comms] Known Issue and Resolution | 1079312385 | 2024-09-11 | mirror |
| AS | Guide on Assessing a Support Ticket | 1002766337 | 2024-09-11 | mirror |
| AS | Sendgrid | 1060864395 | 2024-09-04 | mirror |
| AS | Selected for development 09/03/24 | 1058111523 | 2024-09-03 | mirror |
| AS | Selected for development 08/21/24 | 1025474917 | 2024-08-21 | mirror |
| AS | Reset Password for Azure Non-Prod VM access | 1021444330 | 2024-08-20 | summarise |
| AS | ARL SFTP | 994934833 | 2024-08-08 | summarise |
| AS | Release | 994673032 | 2024-08-08 | reference only |
| AS | Ticket Handling (Manual) | 454590514 | 2024-08-01 | mirror |
| AS | Selected for development 07/30/24 | 967934109 | 2024-07-30 | mirror |
| AS | Selected for development 07/16/24 | 928382977 | 2024-07-30 | mirror |
| AS | Azure Non-Prod - Add Account Access on VM | 955744306 | 2024-07-24 | summarise |
| AS | Server Patch - Azure Non-Prod | 954597377 | 2024-07-23 | summarise |
| AS | Q4 FY24 KPI Achievements | 715948157 | 2024-07-04 | skip, recurring log / template / out of scope |
| AS | Frequently raised tickets for manual processing | 882868262 | 2024-06-20 | reference only |
| AS | Banking Jobs (AM) Manual | 457375748 | 2024-06-06 | mirror |
| AS | Salesforce - Fields and Timings | 845774904 | 2024-06-06 | summarise |
| AS | Bulk Arrears Balance Calculation | 818184275 | 2024-05-27 | mirror |
| AS | Banking Jobs (PM) Manual | 457441396 | 2024-05-21 | mirror |
| AS | Jira SLA issue | 762610577 | 2024-05-06 | summarise |
| AS | Remove Files in Emails | 755367940 | 2024-04-29 | mirror |
| AS | Salesforce - Add BSB number manually. | 602341440 | 2024-04-17 | summarise |
| AS | S1 Login Issue | 635339117 | 2024-04-02 | mirror |
| AS | Q3 FY24 KPI Achievements | 601817089 | 2024-04-02 | skip, recurring log / template / out of scope |
| AS | Access to Archived Email/SMS/File | 672891346 | 2024-03-19 | mirror |
| AS | Release Notes | 642842776 | 2024-03-07 | reference only |
| AS | Wrong Arrears Balance shown | 629309479 | 2024-03-05 | mirror |
| AS | Decline Email | 629407821 | 2024-03-05 | mirror |
| AS | Bug Triage | 629407776 | 2024-02-28 | mirror |
| AS | Release Notes - Release Board - RB Sprint 1 - 23/02/24 - Feb 23 07:20 | 616431704 | 2024-02-22 | skip, recurring log / template / out of scope |
| AS | Salesforce - Generate Loan Contract | 587071590 | 2024-02-08 | summarise |
| AS | Zepto Process | 580845583 | 2024-02-06 | mirror |
| AS | SSL Certificate Expired in Salesforce | 565772317 | 2024-01-30 | summarise |
| AS | MoneyMe API's | 550961514 | 2024-01-24 | mirror |
| AS | Salesforce - Grant SocietyOne Access | 544374789 | 2024-01-22 | summarise |
| AS | App Support - Data Fix Manual | 498401800 | 2024-01-12 | mirror |
| AS | Q2 FY24 KPI Achievements | 456294950 | 2024-01-12 | skip, recurring log / template / out of scope |
| AS | Salesforce - UAT Account Refresh Issue | 515113020 | 2024-01-10 | summarise |
| AS | Data Fix Guide | 502956379 | 2023-12-22 | mirror |
| AS | Salesforce - Update Company Branch | 497811529 | 2023-12-22 | summarise |
| AS | Template / Guide | 502923634 | 2023-12-22 | skip, recurring log / template / out of scope |
| AS | KPI Quarterly Reports | 457474081 | 2023-12-22 | reference only |
| AS | Salesforce Guide | 502890827 | 2023-12-22 | summarise |
| AS | APY Support - Data Fix (Manual) | 459407409 | 2023-12-19 | mirror |
| AS | Salesforce Banking Jobs | 457539616 | 2023-11-14 | mirror |
| AS | App Support | 456425844 | 2023-11-13 | reference only |
| AS | Get the most out of your documentation space | 456425911 | 2023-11-13 | skip, recurring log / template / out of scope |
| AS | Template - Error documentation | 456425897 | 2023-11-13 | skip, recurring log / template / out of scope |
| AS | Template - Product roadmap | 456425883 | 2023-11-13 | skip, recurring log / template / out of scope |

### Space `HOR` (129 pages returned)

| Space | Title | Page id | Last updated | Verdict |
| --- | --- | --- | --- | --- |
| HOR | Horizon Stand Up Tracking | 249922541 | 2026-09-22 | skip, recurring log / template / out of scope |
| HOR | [BS-NET10] MoneyMe.AzureFunctions/MoneyMe.BankStatement → MoneyMe.BankStatement.AzureFunc Migration Docs | 2886926439 | 2026-05-26 | reference only |
| HOR | CCR - Action Plan: Open Items | 437945008 | 2026-03-17 | reference only |
| HOR | Login Email Templates | 2663547077 | 2026-03-13 | reference only |
| HOR | Additional columns for Partner, Partner User, and PartnerUserRecord tables | 2572091479 | 2026-02-18 | reference only |
| HOR | Stage & Status Logs | 1293647889 | 2026-02-17 | mirror |
| HOR | Secret Provider Project Handover | 1941340167 | 2025-12-02 | reference only |
| HOR | Project Handover – Improving End-to-End Security | 1985774210 | 2025-07-17 | reference only |
| HOR | Workflow Migration Project Handover | 1941372933 | 2025-07-04 | reference only |
| HOR | Horizon Project Handover | 1940161249 | 2025-06-18 | summarise |
| HOR | Suspension and Usage Controls | 425263360 | 2025-06-18 | reference only |
| HOR | Secured PPSR Updates Workflow | 1060864230 | 2025-06-13 | mirror |
| HOR | Requirements - Concurrent Cross Default Action | 1769963685 | 2025-04-24 | reference only |
| HOR | Repossession Fees - New Charge Types | 1810169917 | 2025-04-22 | reference only |
| HOR | Equifax Alerts - Commercial Monitoring | 1615265823 | 2025-04-17 | reference only |
| HOR | Equifax Alerts - Consumer Individual Monitoring | 1672904715 | 2025-04-17 | reference only |
| HOR | Duplicate Active Phone Number Issue | 1677426700 | 2025-04-09 | reference only |
| HOR | [QA Findings] Duplicate Active Phone Number Issue | 1757151337 | 2025-04-03 | reference only |
| HOR | Payment Channels | 1772126209 | 2025-04-03 | mirror |
| HOR | Application Level - Stage Movement Update | 1384382551 | 2025-03-27 | reference only |
| HOR | Active Accounts | 1384251537 | 2025-03-27 | reference only |
| HOR | Bank Details | 1383399589 | 2025-03-21 | reference only |
| HOR | Account Details | 1383071929 | 2025-03-21 | reference only |
| HOR | Address Details | 1383399579 | 2025-03-21 | reference only |
| HOR | Contact Details | 1383628887 | 2025-03-21 | reference only |
| HOR | Commercial Alerts - Details | 1720746055 | 2025-03-17 | reference only |
| HOR | Transaction report from MME > Partner | 1619362146 | 2025-02-27 | reference only |
| HOR | External Referral Partner - Guide | 1619820634 | 2025-02-27 | reference only |
| HOR | Daily payment remittance report from Partner > MME | 1641742472 | 2025-02-27 | reference only |
| HOR | Daily data report from Partner > MME | 1641873436 | 2025-02-27 | reference only |
| HOR | Recall report from MME > Partner | 1641578502 | 2025-02-26 | reference only |
| HOR | Daily report from MME > Partner | 1620082689 | 2025-02-26 | reference only |
| HOR | Account Details - Edit Changes | 1159758111 | 2025-02-13 | reference only |
| HOR | Fee Revamp - Ops Training Page | 1579680103 | 2025-02-12 | reference only |
| HOR | Fee Revamp Project - Requirements | 1579679995 | 2025-02-12 | reference only |
| HOR | Monthly Fee - Current Eligibility & Function | 1579679978 | 2025-02-12 | reference only |
| HOR | Collection Fees Business Rules | 1579679961 | 2025-02-12 | reference only |
| HOR | Product Fees Business Rules | 1579679903 | 2025-02-12 | reference only |
| HOR | Product Fee Summary | 1579679888 | 2025-02-12 | reference only |
| HOR | CRC - Transfer Process | 419594541 | 2025-01-09 | reference only |
| HOR | Emails - Customer Level | 1384415316 | 2024-12-20 | reference only |
| HOR | DNC | 1384218882 | 2024-12-20 | reference only |
| HOR | Authorised Party | 1384218828 | 2024-12-20 | reference only |
| HOR | External Agency Partner | 1384251557 | 2024-12-20 | reference only |
| HOR | Business Details | 1384218818 | 2024-12-20 | reference only |
| HOR | Preference Centre | 1384251547 | 2024-12-20 | reference only |
| HOR | NEW Section: Authorised Party Details | 1177551087 | 2024-12-18 | reference only |
| HOR | Customer Level Management Solution | 1060864241 | 2024-12-12 | reference only |
| HOR | NEW Section: Preference Centre | 1267171395 | 2024-12-10 | reference only |
| HOR | NEW Section: External Agency Partner | 1224736774 | 2024-11-28 | reference only |
| HOR | Address Details - Edit Changes | 1159233811 | 2024-11-28 | reference only |
| HOR | Stage Movement Page Update | 1159299351 | 2024-11-28 | reference only |
| HOR | NEW Section: Active Applications | 1159725329 | 2024-11-27 | reference only |
| HOR | NEW Section: Business Details | 1159233821 | 2024-11-27 | reference only |
| HOR | Bank Details - Edit Changes | 1158775072 | 2024-11-27 | reference only |
| HOR | Customer Level Emails | 1274937570 | 2024-11-21 | reference only |
| HOR | Contact Details - Edit Changes | 1159758093 | 2024-11-20 | reference only |
| HOR | Horizon Team | 1343691 | 2024-11-19 | summarise |
| HOR | CRC - Rates & Fees | 443645969 | 2024-11-14 | reference only |
| HOR | DNC Changes | 1247150125 | 2024-11-07 | reference only |
| HOR | SPL Requirements | 38666382 | 2024-10-09 | reference only |
| HOR | CRC - Billing Cycle Logic | 418218042 | 2024-08-28 | reference only |
| HOR | Fee Behaviour | 407011529 | 2024-08-16 | reference only |
| HOR | Bills Engine Requirements | 406978561 | 2024-08-16 | reference only |
| HOR | Cutover Plan (CCC > CRC) | 423264507 | 2024-08-16 | reference only |
| HOR | LOC & CRC Allocation Logic | 425263602 | 2024-08-16 | reference only |
| HOR | Transaction Summary and Transaction Behaviour | 406978756 | 2024-08-16 | reference only |
| HOR | Collections Comms - Work in Progress | 978354424 | 2024-08-02 | mirror |
| HOR | Compliance - Work in Progress | 974225672 | 2024-08-01 | reference only |
| HOR | Staff Pilot - Test Cases | 482345104 | 2024-07-22 | reference only |
| HOR | Bills Page - Horizon Requirements | 407011329 | 2024-06-25 | summarise |
| HOR | Sprint 88 - May 31 to June 14 2024 | 844824654 | 2024-06-05 | skip, recurring log / template / out of scope |
| HOR | Horizon Team Daily Update | 845021206 | 2024-06-05 | skip, recurring log / template / out of scope |
| HOR | Daily Tasks | 844922898 | 2024-06-05 | skip, recurring log / template / out of scope |
| HOR | Ricky Buenavista Documents | 845086735 | 2024-06-05 | reference only |
| HOR | Dual Disbursment Requirements | 30834719 | 2024-05-30 | reference only |
| HOR | Arrears migration scenarios | 710279174 | 2024-04-24 | mirror |
| HOR | ARL Progress Items | 368115755 | 2024-03-21 | reference only |
| HOR | For Release Items - Horizon Platform team | 672235818 | 2024-03-19 | summarise |
| HOR | CRC - DPD & Writeoff | 454164694 | 2024-03-12 | reference only |
| HOR | New Overdue Fee Structure | 59441190 | 2024-02-27 | reference only |
| HOR | Staff Pilot Phase 2 - DPD & Arrears | 546308097 | 2024-02-15 | mirror |
| HOR | CRC - Marked for Closure | 406880371 | 2024-02-15 | reference only |
| HOR | Freestyle Bills Engine - Ops Training | 438534189 | 2024-01-29 | reference only |
| HOR | APY Balloon System Handling - Part 1 | 456720549 | 2024-01-23 | mirror |
| HOR | Staff Pilot Phase 1 - Bills Engine Core | 470778034 | 2024-01-23 | reference only |
| HOR | CRC Releases | 470581448 | 2024-01-23 | reference only |
| HOR | Phase 3 Customer Release | 539132245 | 2024-01-19 | reference only |
| HOR | Collection Comms Revamp Release Plan | 450166974 | 2024-01-08 | mirror |
| HOR | CRC - Horizon UI | 437944614 | 2023-11-16 | summarise |
| HOR | How to use the FredBot tool (Batch tool) | 143491288 | 2023-11-14 | reference only |
| HOR | APR Increases Nov/Dec 2023 - Action Plan | 445907063 | 2023-11-13 | mirror |
| HOR | ARL - External Collections Agency | 453181926 | 2023-11-10 | reference only |
| HOR | Interest Process - Review and Recovery | 425820163 | 2023-11-08 | reference only |
| HOR | CRC - MoneyMe Credit Card Requirements | 406880268 | 2023-11-06 | reference only |
| HOR | Scenario J | 447938591 | 2023-11-06 | skip, recurring log / template / out of scope |
| HOR | Scenario I | 447971470 | 2023-11-06 | skip, recurring log / template / out of scope |
| HOR | Scenario H | 424574977 | 2023-11-02 | skip, recurring log / template / out of scope |
| HOR | Scenario G | 406980114 | 2023-11-01 | skip, recurring log / template / out of scope |
| HOR | Scenario F | 406979819 | 2023-11-01 | skip, recurring log / template / out of scope |
| HOR | Scenario E | 406979654 | 2023-11-01 | skip, recurring log / template / out of scope |
| HOR | DPD V2 RHI changes - June 2023 | 334626903 | 2023-10-24 | reference only |
| HOR | ARL Catch Up | 435355816 | 2023-10-19 | reference only |
| HOR | Manager Approvals: Minimum Requirements | 387645594 | 2023-10-12 | reference only |
| HOR | Scenario C | 406979259 | 2023-10-03 | skip, recurring log / template / out of scope |
| HOR | Scenario B | 406979054 | 2023-10-03 | skip, recurring log / template / out of scope |
| HOR | Scenario A | 406978944 | 2023-10-03 | skip, recurring log / template / out of scope |
| HOR | Scenario D | 406979489 | 2023-10-03 | skip, recurring log / template / out of scope |
| HOR | New AFCA Stages | 409075824 | 2023-09-28 | reference only |
| HOR | New Stage Requests | 409108564 | 2023-09-24 | reference only |
| HOR | Scenarios: MoneyMe Credit Card Post Funding | 406978882 | 2023-09-21 | reference only |
| HOR | CCR Business Rule Changes | 64323587 | 2023-05-11 | reference only |
| HOR | APY RHI - BAU changes March 2023 | 260735010 | 2023-04-05 | mirror |
| HOR | Indebted Charging Process | 222363706 | 2023-03-15 | reference only |
| HOR | NEW Refund Process | 231965096 | 2023-03-09 | mirror |
| HOR | Hardship Reporting | 73334785 | 2023-03-08 | reference only |
| HOR | BAU changes - Jan 2023 | 185303063 | 2023-02-13 | reference only |
| HOR | NEW Stage Check Window | 200081891 | 2023-02-08 | reference only |
| HOR | New Overdue fee review | 132513879 | 2022-11-17 | reference only |
| HOR | MME Experian Credit Score | 63438863 | 2022-09-26 | reference only |
| HOR | Society One SPL UPL | 68714499 | 2022-09-06 | reference only |
| HOR | Existing Hardship Workflow Rules | 56983565 | 2022-09-06 | reference only |
| HOR | SPL/UPL Post-Funding Workflow Requirements | 53772307 | 2022-09-06 | reference only |
| HOR | SPL/UPL Direct Debit Transaction Rules | 55410928 | 2022-09-05 | reference only |
| HOR | SPL/UPL Basic Post-Funding Workflows | 55541763 | 2022-09-05 | reference only |
| HOR | SPL/UPL Overdue Phases Workflow | 53740147 | 2022-08-31 | reference only |
| HOR | SPL and UPL Write Off and Interest Hold Triggers | 57180165 | 2022-08-30 | reference only |
| HOR | SPL/UPL Dishonour or Overdue Account Fee Workflow | 57081861 | 2022-08-30 | reference only |
| HOR | Serviceability Calculation | 42467463 | 2022-08-08 | reference only |

### Space `TS` (25 pages returned)

| Space | Title | Page id | Last updated | Verdict |
| --- | --- | --- | --- | --- |
| TS | IT Onboarding | 1376551109 | 2025-09-08 | skip, recurring log / template / out of scope |
| TS | How to login in Jira | 1378975784 | 2024-12-18 | skip, recurring log / template / out of scope |
| TS | How to set up Microsoft Authenticator account. | 1376649326 | 2024-12-18 | skip, recurring log / template / out of scope |
| TS | How-to articles | 1376780441 | 2024-12-18 | reference only |
| TS | How to Change Authentication Phone Number for MFA in Azure AD on Windows 11: A Simple Step-by-Step Guide | 1376321888 | 2024-12-18 | reference only |
| TS | How to Change Password on Windows 11: A Simple Step-by-Step Guide | 1376092182 | 2024-12-18 | skip, recurring log / template / out of scope |
| TS | How to Change PIN on Windows 11: A Step-by-Step Guide | 1375731793 | 2024-12-17 | skip, recurring log / template / out of scope |
| TS | Slack for Andriod | 914817441 | 2024-07-04 | skip, recurring log / template / out of scope |
| TS | Mac/iOS Kandji/Mosyle Migration | 703954979 | 2024-04-16 | summarise |
| TS | Standard Process of Setting Up Machines for Onboarding | 683835848 | 2024-03-25 | skip, recurring log / template / out of scope |
| TS | How to fix MS Teams share screen on macOS | 641171837 | 2024-03-07 | reference only |
| TS | How to add a power user in AAD using command prompt | 573702401 | 2024-02-02 | reference only |
| TS | How to Add or Delete Members to an Outlook Distribution List | 573833444 | 2024-02-02 | reference only |
| TS | How to add IP/domain in the hostfile - macos | 475955620 | 2024-02-02 | reference only |
| TS | How to fix Azure VPN Client not working on MAC book M series | 476021009 | 2024-02-02 | summarise |
| TS | Horizon error code for SSO | 479363741 | 2024-02-02 | summarise |
| TS | How to pull out all Discovered Apps for all users | 573735031 | 2024-02-02 | reference only |
| TS | Hardware Standardisation and Replacement | 1572865 | 2023-12-19 | reference only |
| TS | Slack Webhooks | 470583365 | 2023-11-27 | reference only |
| TS | Kandji - MacOS Migration | 444596616 | 2023-11-08 | summarise |
| TS | Technical Support | 444924098 | 2023-10-31 | reference only |
| TS | Template - Troubleshooting article | 444924124 | 2023-10-31 | skip, recurring log / template / out of scope |
| TS | Template - How-to guide | 444924110 | 2023-10-31 | skip, recurring log / template / out of scope |
| TS | Sophos VPN - Adding a device to the MAC Address Filter | 331153427 | 2023-06-23 | summarise |
| TS | Kandji - MS365 - Azure AD Authentication for Mac | 64848235 | 2023-05-11 | summarise |

### Space `TO` (250 pages returned)

*145 further TO pages are omitted from this table: daily "Defender Alerts/Incidents" and "Email Submissions" logs, weekly security notes, KPI and progress trackers, and IT onboarding how-tos. All verdict: skip, security operations logs with no App Support value.*

| Space | Title | Page id | Last updated | Verdict |
| --- | --- | --- | --- | --- |
| TO | September Progress Tracker 2025 | 2088730625 | 2026-09-15 | summarise |
| TO | May Progress Tracker 2026 | 2832859246 | 2026-05-20 | summarise |
| TO | April Progress Tracker 2026 | 2726264833 | 2026-04-29 | mirror |
| TO | March Progress Tracker 2026 - App Support | 2628714601 | 2026-03-31 | summarise |
| TO | March Progress Tracker 2026 | 2623832073 | 2026-03-30 | summarise |
| TO | BAU Task - App Support / Infra | 2628714587 | 2026-03-05 | reference only |
| TO | Monthly Tracker - App Support | 2628714594 | 2026-03-05 | summarise |
| TO | App Support | 2628223114 | 2026-03-05 | reference only |
| TO | February Progress Tracker 2026 | 2506850410 | 2026-03-04 | summarise |
| TO | CRD Logs | 2566258793 | 2026-02-16 | reference only |
| TO | Security Patch - Prod | 1134100548 | 2026-02-12 | summarise |
| TO | Tech Ops | 470583197 | 2026-02-01 | reference only |
| TO | BAU Task Handover - Tech Support Officer | 2378465296 | 2026-01-30 | reference only |
| TO | Monthly Tracker | 2515140660 | 2026-01-30 | summarise |
| TO | ASV Scanning Procedure | 2404745223 | 2025-12-15 | reference only |
| TO | Technical Support | 2378629153 | 2025-12-07 | reference only |
| TO | System Health Check | 2162688004 | 2025-10-21 | reference only |
| TO | October Progress Tracker 2025 | 2194243586 | 2025-10-20 | summarise |
| TO | Monthly Team Task | 2088468508 | 2025-09-10 | reference only |
| TO | How to grant permission in AWS | 2018050096 | 2025-08-21 | summarise |
| TO | Secure Software Development Lifecycle (SSDLC) | 2035056678 | 2025-08-14 | reference only |
| TO | Threat Modelling Implementation Plan for SSDLC Integration | 2034958346 | 2025-08-14 | reference only |
| TO | August Progress Tracker 2025 | 2015657986 | 2025-08-04 | summarise |
| TO | July Progress Tracker | 1970602032 | 2025-08-01 | summarise |
| TO | MoneyMe API's | 1968440076 | 2025-07-04 | mirror |
| TO | Arrears Balance Issue | 1968505668 | 2025-07-04 | mirror |
| TO | Interest Adjuster Manual | 1968505575 | 2025-07-04 | mirror |
| TO | Misplaced Amortization | 1968505525 | 2025-07-04 | mirror |
| TO | App Support Daily Alerts | 1968505511 | 2025-07-04 | mirror |
| TO | Bulk Arrears Balance Calculation | 1968505496 | 2025-07-04 | mirror |
| TO | Download Files in Emails | 1968505430 | 2025-07-04 | mirror |
| TO | Remove Files in Emails | 1968505364 | 2025-07-04 | mirror |
| TO | APR Decrease | 1968505326 | 2025-07-04 | mirror |
| TO | APY APR Adjustment Recovery Part 2 | 1968505311 | 2025-07-04 | mirror |
| TO | APY APR Adjustment Recovery Part 1 | 1968505280 | 2025-07-04 | mirror |
| TO | APY Update Loan Contract (with APR adjustment) | 1968505188 | 2025-07-04 | mirror |
| TO | Access to Archived Email/SMS/File | 1968505160 | 2025-07-04 | mirror |
| TO | Kill Stuck Actualization Background Process | 1968505125 | 2025-07-04 | mirror |
| TO | LOC - SOA request with target date only | 1968505073 | 2025-07-04 | mirror |
| TO | How to generate SOA for old accounts with lots of transactions | 1968505025 | 2025-07-04 | mirror |
| TO | Incorrect URL ID Fix | 1968505004 | 2025-07-04 | mirror |
| TO | APY / SPL vehicles updates SQL DF Scripts | 1968504990 | 2025-07-04 | mirror |
| TO | Common Login SQL Data Fix Scripts | 1968504976 | 2025-07-04 | mirror |
| TO | SQL Data Fix scripts | 1968504962 | 2025-07-04 | mirror |
| TO | APY Support - Data Fix (Manual) | 1968504891 | 2025-07-04 | mirror |
| TO | App Support - Data Fix Manual | 1968504850 | 2025-07-04 | mirror |
| TO | Data Fix Guide | 1968504833 | 2025-07-04 | mirror |
| TO | Salesforce - Fields and Timings | 1968407960 | 2025-07-04 | summarise |
| TO | Salesforce - Add BSB number manually. | 1968407892 | 2025-07-04 | summarise |
| TO | Salesforce - Generate Loan Contract | 1968407805 | 2025-07-04 | summarise |
| TO | SSL Certificate Expired in Salesforce | 1968407785 | 2025-07-04 | summarise |
| TO | Salesforce - Grant SocietyOne Access | 1968407759 | 2025-07-04 | summarise |
| TO | Salesforce - UAT Account Refresh Issue | 1968407729 | 2025-07-04 | summarise |
| TO | Salesforce - Update Company Branch | 1968407694 | 2025-07-04 | summarise |
| TO | Banking Jobs (PM) Manual | 1968407526 | 2025-07-04 | mirror |
| TO | Banking Jobs (AM) Manual | 1968407186 | 2025-07-04 | mirror |
| TO | Salesforce Banking Jobs | 1968407173 | 2025-07-04 | mirror |
| TO | Salesforce Guide | 1968407156 | 2025-07-04 | summarise |
| TO | Uptime: Site Monitoring | 1968440060 | 2025-07-04 | mirror |
| TO | Sentry Monitoring | 1968440047 | 2025-07-04 | mirror |
| TO | Download and Upload BPAY Files | 1968440024 | 2025-07-04 | mirror |
| TO | DataFix Guide | 1968439995 | 2025-07-04 | mirror |
| TO | Sendgrid | 1968439959 | 2025-07-04 | mirror |
| TO | Reset Password for Azure Non-Prod VM access | 1968439894 | 2025-07-04 | summarise |
| TO | [Comms API] Support | 1968439833 | 2025-07-04 | mirror |
| TO | [Comms] Known Issue and Resolution | 1968439811 | 2025-07-04 | mirror |
| TO | [Twilio] Known Issue and Resolution | 1968439780 | 2025-07-04 | mirror |
| TO | Guide on Assessing a Support Ticket | 1968439729 | 2025-07-04 | mirror |
| TO | ARL SFTP | 1968439673 | 2025-07-04 | summarise |
| TO | Azure Non-Prod - Add Account Access on VM | 1968439578 | 2025-07-04 | summarise |
| TO | Server Patch - Azure Non-Prod | 1968439476 | 2025-07-04 | summarise |
| TO | Common issues in App Support | 1968439453 | 2025-07-04 | mirror |
| TO | 🏢 Tech & Product Team Directory | 1968439436 | 2025-07-04 | mirror |
| TO | Application Support Process Flow | 1968439415 | 2025-07-04 | mirror |
| TO | Ticket Handling (Manual) | 1968439317 | 2025-07-04 | mirror |
| TO | Application Support Process | 1968439297 | 2025-07-04 | mirror |
| TO | Conditional Policy Exemption | 1968407129 | 2025-07-04 | summarise |
| TO | Sophos - OpenVPN - Add Mac Address | 1968407071 | 2025-07-04 | summarise |
| TO | Sentry Access | 1968407032 | 2025-07-04 | mirror |
| TO | Sophos - OpenVPN - Reset password | 1968406943 | 2025-07-04 | summarise |
| TO | HID Portal and Skytunnel - Door Access | 1968406831 | 2025-07-04 | summarise |
| TO | Add a Permission for a Group in Horizon | 1968406816 | 2025-07-04 | summarise |
| TO | Add a user in Horizon | 1968406794 | 2025-07-04 | summarise |
| TO | Update an App in Kandji | 1968406779 | 2025-07-04 | summarise |
| TO | Reset a User’s Password in Microsoft Intune | 1968406760 | 2025-07-04 | summarise |
| TO | Add a New User in Microsoft Intune & Assign Permissions | 1968406741 | 2025-07-04 | summarise |
| TO | Add Users to a Group in Microsoft Intune | 1968406726 | 2025-07-04 | summarise |
| TO | Manually Update Apps in Microsoft Intune Using TeamViewer | 1968406711 | 2025-07-04 | summarise |
| TO | Microsoft Intune Application Updates | 1968406696 | 2025-07-04 | summarise |
| TO | Sophos - OpenVPN Access | 1968406649 | 2025-07-04 | summarise |
| TO | Laptop Setup | 1968406636 | 2025-07-04 | summarise |
| TO | Kandji - MacOS Migration | 1968406559 | 2025-07-04 | summarise |
| TO | Workstation Patch Management | 1968406534 | 2025-07-04 | summarise |
| TO | Platform and Support | 1039401209 | 2025-07-04 | reference only |
| TO | Transition Ron -> Louie | 1940194324 | 2025-06-18 | reference only |
| TO | RF Network Topology | 1925218369 | 2025-06-09 | reference only |
| TO | RFTAGS | 1925218343 | 2025-06-09 | reference only |
| TO | RFResource Group | 1925218318 | 2025-06-09 | reference only |
| TO | RFApp Service | 1925218600 | 2025-06-09 | reference only |
| TO | RFVPN | 1925218442 | 2025-06-09 | summarise |
| TO | RFApplication Gateway | 1925218424 | 2025-06-09 | reference only |
| TO | RFInfrastructure - Architecture Proposal | 1925218305 | 2025-06-09 | reference only |
| TO | April 2025 RM (MoM) | 1887600642 | 2025-06-05 | mirror |
| TO | Weekly Platform Team Task | 1913160212 | 2025-06-02 | reference only |
| TO | May 2025 InfoSec (MoM) | 1888026636 | 2025-05-19 | reference only |

---

## 4. Pages found outside the App Support space via CQL

Searches run: `text ~ "runbook"`, `text ~ "datafix"`, and a combined title search over
escalation, SOA, SendGrid, Twilio, Zepto, Sentry, G3APIBot, unblock, direct debit, incident,
environment and Horizon 3.0. Results below exclude the AS space and exclude the daily security
logs.

### Operations and process

| Space | Title | Page id | Updated | One line | Verdict |
| --- | --- | --- | --- | --- | --- |
| OP | Reoccurring DataFix process | 2524381287 | 2026-02-09 | Ops-facing monthly umbrella datafix ticket process | mirror |
| OP | Zepto/Split Account Task Handling Guide | 2286321665 | 2026-08-24 | Split account error codes and the two Horizon tasks | mirror |
| OP | Account Escalations in Slack | 264175641 | 2026-07-03 | Ops escalation matrix plus Slack compliance rules | mirror |
| OP | Zepto | 44597391 | not read | Referenced for "Rejected Payment Codes" and "Creating a Split Account" | mirror, not read in this pass, flagged in gaps |
| MHD | Urgency | 398622726 | 2023-09-27 | Urgency definitions and SLAs | mirror |
| IR | Incident Report Process | 601653285 | 2026-03-31 | Incident raising, documenting and comms | mirror |
| IR | Template | 594411943 | not read | The incident report template | reference only |
| TPM | Helpdesk Ticket Process | 889978981 | not read | MHD ticket creation guidelines referenced by the release process | mirror, not read in this pass |
| TPM | Story Point - Performance Metrics Framework | 2903146513 | 2026-06-09 | Sprint velocity and performance framework | skip |
| TPM | MoneyMe Technology Strategy, PM/SM Support Plan FY2028 | 2918547480 | 2026-06-05 | PM/SM support plan | skip |

### Horizon, systems and integration

| Space | Title | Page id | Updated | One line | Verdict |
| --- | --- | --- | --- | --- | --- |
| HOR | Stage & Status Logs | 1293647889 | 2026-02-18 | Active status and stage registers with per-stage behaviour | mirror |
| HOR | Payment Channels | 1772126209 | 2025-04-03 | Payment initiators, channels and how to identify them | mirror |
| HOR | Account Details / Bank Details / Address Details / Contact Details | 1383071929 / 1383399589 / 1383399579 / 1383628887 | 2025-03 | Horizon customer-level UI section specs | summarise |
| HOR | Customer Level Management Solution | 1060864241 | 2024-12-12 | The customer-level data model change | summarise |
| HOR | Duplicate Active Phone Number Issue | 1677426700 | 2025-04-09 | The defect behind the merge-tag multiple-active-number error | mirror |
| HOR | Suspension and Usage Controls | 425263360 | 2025-06-18 | Account suspension rules | summarise |
| HOR | Login Email Templates | 2663547077 | 2026-03-13 | Login-related email templates | reference only |
| HOR | Stage Movement Page Update / Application Level - Stage Movement Update | 1159299351 / 1384382551 | 2024-11 / 2025-03 | Stage movement UI changes | reference only |
| HOR | How to use the FredBot tool (Batch tool) | 143491288 | 2023-11-14 | Batch tool usage | summarise |
| HOR | Secured PPSR Updates Workflow | 1060864230 | 2025-06-13 | PPSR workflow | summarise |
| HOR | Equifax Alerts - Commercial / Consumer Individual Monitoring | 1615265823 / 1672904715 | 2025-04-17 | Equifax alert handling | reference only |
| HOR | CRC - Billing Cycle Logic / Rates & Fees / DPD & Writeoff / Marked for Closure / Transfer Process | 418218042 / 443645969 / 454164694 / 406880371 / 419594541 | 2024–2025 | Credit card business rules | reference only |
| HOR | Product Fees Business Rules / Collection Fees Business Rules / Product Fee Summary / Monthly Fee - Current Eligibility / Fee Revamp docs | 1579679903 / 1579679961 / 1579679888 / 1579679978 / 1579679995 / 1579680103 | 2025-02-12 | The fee model | summarise, App Support gets fee tickets |
| HOR | SPL/UPL workflow rule pages *(8 pages, 2022)* | 53740147, 53772307, 55410928, 55541763, 57081861, 57180165, 56983565, 68714499 | 2022 | SocietyOne SPL/UPL post-funding, direct debit, overdue, write-off and hardship rules | reference only, old but still the only written source |
| TECHNOLOGY | How to investigate missing contract | 942047312 | 2025-01-29 | Contract-not-sent runbook | mirror |
| TECHNOLOGY | How to add new workflow | 479363489 | not read | Referenced by the missing-contract runbook for editing workflow CriteriaSql | mirror, not read in this pass |
| TECHNOLOGY | Horizon - Replace Sentry by Uptrace | 3071442984 | 2026-09-03 | Sentry retirement register, Uptrace projects 8391/8392 | mirror |
| TECHNOLOGY | Horizon - White Label Comms Suppression (CommsMuteTemplate) | 3159327598 | 2026-09-07 | New comms suppression table and mute rule | mirror, extends the CommsMuteRule logic |
| TECHNOLOGY | MoneyMe.ContractGenerator.AzureFunc - Technical Documents | 3006136420 | 2026-07-09 | Canonical reference for the contract generation function | summarise |
| TECHNOLOGY | MoneyMe.Communication.BrazeScheduler - Technical Documents | 3022258468 | 2026-07-16 | Braze to Horizon Comms Tab sync | summarise |
| TECHNOLOGY | MoneyMe.Communication.BrazeScheduler, Lessons Learned | 3022618790 | 2026-07-16 | Braze scheduler gotchas | summarise |
| TECHNOLOGY | API BOT Knowledge Vault | 2869952559 | 2026-05-20 | Index of an append-only shared knowledge base | reference only |
| TECHNOLOGY | Vault, Schema | 2868675170 | 2026-07-14 | Non-obvious table, column and FK notes | mirror, directly useful for datafix work |
| TECHNOLOGY | Vault, Runbooks & Recipes | 2870149155 | 2026-08-10 | Reusable SQL query patterns and multi-step procedures | mirror |
| TECHNOLOGY | Vault, APIs & Endpoints | 2868805787 | 2026-07-07 | Endpoint quirks, auth requirements, undocumented behaviour | mirror |
| TECHNOLOGY | G3APIBot, How to Teach the Bot New Facts | 2994733113 | 2026-07-05 | Teaching and correcting the unblock bot | mirror |
| TECHNOLOGY | Building a Production Slack Bot on Claude Code (G3APIBot case study) | 2892169232 | 2026-05-27 | Engineering playbook | reference only |
| TECHNOLOGY | Get Credit Card Statement of Account (SOA) | 2436694044 | 2026-08-13 | CRD SOA endpoint | summarise |
| TECHNOLOGY | Block and Unblock Virtual Card | 2433876044 | 2026-08-13 | Virtual card block/unblock endpoints | summarise |
| TECHNOLOGY | Direct Debit Payment Request Event, Integration Guide | 2729836644 | 2026-04-01 | Payment V3 NServiceBus event contracts, Zepto Split migration | summarise |
| TECHNOLOGY | SOA Revamp Templates / SOA REVAMP Template Testing / QA evidence / QA test runner handover | 3166732380 / 443875383 / 3198648432 / 3199238332 | 2026-09 | The in-flight SOA revamp | reference only, moving target |
| TECHNOLOGY | MoneyMe Tech Team | 6981963 | not read | The team-routing page linked from Ticket Handling | reference only, the AS Team Directory is fresher |
| TECHNOLOGY | Twilio Documentation | 2761163168 | 2026-04-16 | The Twilio/VoIP platform overview, repo Twilio2 | mirror |
| TECHNOLOGY | Twilio App Support | 2731868161 | 2026-04-16 | Twilio SID prefixes and basic app support | mirror |
| TECHNOLOGY | Twilio Tech Support | 2725150760 | 2026-04-01 | Common Twilio issues and the steps when Ops reports one | mirror |
| TECHNOLOGY | Twilio Active Live Numbers and Merge Tags | 2384658887 | 2026-07-29 | The live brand numbers and their merge tags | mirror |
| TECHNOLOGY | [G4-Twilio] Known Issue and Resolution | 441417732 | 2026-03-31 | The G4 original of the AS Twilio page | reference only, AS copy is the one App Support uses |
| TECHNOLOGY | [G4-Comms] Known Issue and Resolution | 453509121 | not read | G4 original of the AS Comms page | reference only |
| TECHNOLOGY | [G4-Comms API] Support | 989069465 | not read | G4 original of the AS Comms API page | reference only |
| TECHNOLOGY | Twilio Setup to run in local / Twilio Test Instructions / Investigation Results - Twilio / Twilio Documentation - Claude Generated | 2769846319 / 2834530379 / 2806054937 / 2774859843 | 2026 | Dev and test material | reference only |
| TECHNOLOGY | Incident: spv-api-qa 503 (2026-06-11) | 2933817370 | 2026-06-16 | Worked incident write-up | reference only |
| TECHNOLOGY | Zepto DirectDebit QA Testing Guide | 2729541640 | 2026-05-28 | Zepto mock notes, sync validation, sandbox | summarise |
| TECHNOLOGY | How an Application Becomes Eligible to Fund | 2785771528 | not read | Funding 2.0 pipeline, referenced by the APY environments page | mirror, not read in this pass |
| TECHNOLOGY | MoneyMe.Core.Opentelemetry | 2529755256 | not read | Telemetry library documentation referenced by the Uptrace register | reference only |

### Product and QA spaces

| Space | Title | Page id | Updated | One line | Verdict |
| --- | --- | --- | --- | --- | --- |
| AUT | APY Environments and Credentials | 426082342 | 2026-08-26 | APY and Horizon environments, test fixtures, wagtest naming | mirror, credentials stripped |
| AUT | APY Dealer & Broker – Forced Valuation Flow for Underwriters | 2835677494 | 2026-06-11 | When AutoGrab cannot value a vehicle, and when a Datafix request form is needed | summarise |
| AUT | AutoGrab inc LVR Matrix | 2768863261 | 2026-05-15 | AutoGrab integration and data mapping | reference only |
| AUT | 0. Authentication (APY Broker API) | 2906489025 | 2026-06-02 | OAuth 2.0 client credentials via Azure AD | reference only |
| AUT | Underwriting Backlog, Effort/Impact Prioritisation | 3117154323 | 2026-08-21 | Backlog scoring | skip |
| APL | Statement of Account (SOA) | 332070951 | 2026-08-27 | CRD statement fields and sample | summarise |
| APL | Google Pay, Unified Push Provisioning Upgrade | 3160080745 | 2026-09-18 | Google Wallet provisioning change, due end Dec 2026 | reference only |
| APL | Sardine Tokenisation Data Push, Technical Reference | 2881224707 | 2026-05-23 | Sardine endpoint and field mappings | reference only |
| APL | MME Cashback Rewards Card Features Checklist | 2499084527 | 2026-05-25 | Feature readiness checklist | skip |
| PL | [PL Release] SEON Fraud Integration to DE | 3094052891 | 2026-09-15 | Release page | reference only |
| PL | [PL Release] OneDebt $0 RequestedAmount fix (MHD-35621) | 3134882048 | 2026-08-27 | Release page tied to an MHD ticket | reference only |
| PE | Horizon 3.0 updates | 3012460577 | 2026-07-13 | Proposed Horizon platform enhancements | reference only |
| PE | Unblocking customers | 2840461314 | 2026-05-07 | Proposal to let agents unblock from the Horizon reset feature | reference only, relevant to the G3APIBot unblock workload |
| RCT | Zepto notification of suspicious activity | 2760769540 | 2026-04-12 | How to respond when Zepto flags funding or repayments | mirror |
| QSI2 | Maestro Setup Guide | 2858614947 | 2026-09-08 | Mobile test automation | skip |
| TS | Horizon error code for SSO | 479363741 | 2024-02-02 | SSO error codes for Horizon | mirror |
| Cybersecur / TO | SSDLC, Threat Modelling | 2706669580 / 2035056678 / 2034958346 | 2025–2026 | Secure development lifecycle | reference only |

### Personal spaces containing work-relevant material

These live in individual users' personal spaces and are at risk of being lost when someone
leaves. Flagged in [07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md).

| Space | Title | Page id | Note |
| --- | --- | --- | --- |
| `~62fc53240268bddf1c91811f` (Maria Krizza Rosales) | Database Restore Procedure | 2335015225 | Azure Automation Runbook DB restore. **Operationally critical and in a personal space.** |
| `~7120208a3e3091cec1406ea6c612d12bfc680c` (Lea Nicolas) | Stage movement - environment variables | 3187867656 | Environment variables for the stage-movement hold pack |
| `~7120204210c2acc8164b0a869a025ff29102d8` (marlon.pamisa) | Venus Environment, Architecture Wiring Map, Go Modules assessments, s1-application-api rebuild | 2927591440, 2533523480, 2518810781 | SocietyOne infrastructure documentation |
| `~62e9fb5548e310e672958a3c` (David Orr) | PayTo GTM | 3135176715 | End-to-end PayTo operational reference |
| `~628352d9bd640f0068acfb9b` (Ulysses Consador) | PL Release MHD-34051 / MHD-34052 review | 2958885157 | Release review artefacts |
| `~63e1fe52c2b1cb6b347381c0` (Kristofer Tan) | Various CRD/API testing documentation | 3160179111, 2761818148 | QA evidence with application IDs |

---

## 5. Access notes

- `getPagesInConfluenceSpace` on the `TECHNOLOGY` space timed out, so that space was inventoried
  by CQL sampling rather than exhaustively. The TECHNOLOGY space is large and almost certainly
  contains further App Support relevant pages not listed here.
- The `TO` space listing returned 250 pages with a further page of results; only the first page
  was retrieved. The omitted tail is almost entirely daily Defender and email submission logs.
- Pages marked "not read" above were identified by reference or search result but not opened in
  full during this pass, to stay inside the 25 to 50 full read budget.
- No archived space was inventoried. `MTO`, `MOBILE`, `TEC`, `STT`, `AD`, `MK`, `DM1` and `MIH`
  are archived and may hold superseded App Support material.
