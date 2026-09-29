# Documentation gaps

What is missing, stale, contradictory or unsafe in the App Support Confluence.

Last reviewed: 23 September 2026
Sources: Confluence harvest, 23 September 2026

Compiled 23 September 2026 alongside [06-reference/confluence-index.md](../06-reference/confluence-index.md) and [06-reference/confluence-mirror/README.md](../06-reference/confluence-mirror/README.md).
Written for the person who has to rely on this documentation at 2am, not for a documentation
audit. Everything below is something a support engineer would actually hit.

---

## 1. Security and handling problems that should be fixed before anything is mirrored

### 1.1 Live credentials are published in plain text on at least three pages

| Page | What is exposed |
| --- | --- |
| **AUT 426082342, APY Environments and Credentials** | Dozens of QA **and production** portal usernames with passwords in clear text: Broker Portal, Dealer Portal, AutoScan admin and user accounts for every state, DOF, Caravan. Also third party credentials: **EDX/PPSR (ESIS UAT)** under two named staff accounts, **MoneyMe ID Kit** under a named staff account, **Illion** self-serve bank statements, and HTTP basic auth for the Amortization and Glass's Guide Swagger endpoints. |
| **AS 519602304, SQL Data Fix scripts** | At least four embedded secrets: an encrypted Horizon staff password with the **plaintext written next to it in a comment**, a temp passcode hash, a hash passed to `DecryptTextNoPWD`, and a PartnerUser insert carrying both an encrypted password and the **plaintext in a comment**. |
| **AS 1398210569, Common Login SQL Data Fix Scripts** | A real encrypted customer password value in the "create an account directly into the DB" sample. |
| **AS 2485059655, Store Procedures** | Real encrypted password values in the `AppSupport_UpdateCustomerAccount` and `AppSupport_InsertCustomerAccount` execute samples. |

The Datafix catalogue page (3117842457) already flags this: *"Never copy a password or hash out
of the wiki... flag it as a hygiene problem instead."* It has been flagged and not fixed.

**What is needed:** rotate anything still live, move credentials to the password manager, and
replace the samples with placeholders. Until that is done, the repo must not mirror those
pages verbatim; this harvest redacted them, but a future automated sync would not.

### 1.2 Nobody owns cleanup of datafix backup tables

Every fix creates a permanent table in production: `CustomerEmail_MHD35866`,
`fundingactivity_MHD35277`, `Application_MHD12195`, and so on. These contain full customer rows
including encrypted bank account numbers. No page describes when, or whether, they are ever
dropped. Over three years of monthly datafix tickets that is a significant and growing shadow
copy of customer data in the production database.

### 1.3 Slack compliance rules exist for Operations but not for App Support

OP 264175641 sets out exactly what may and may not be posted about a customer in Slack. There
is no equivalent on any App Support page, even though App Support routinely posts application
IDs, customer IDs and script bodies into `#datascript-requests` and `#app-support`. The Ops
rules are a reasonable starting point but were written for call escalations, not for pasting
SQL containing customer email addresses.

---

## 2. Contradictions a support engineer will actually trip over

### 2.1 Two different datafix processes are both "current"

| Source | Process |
| --- | --- |
| **AS 1409351766, DataFix Guide** (Dec 2024) and **AS 498401800, App Support Data Fix Manual** (Jan 2024) | Create a Change Request ticket per fix, get approval from Jeffrey Lu and Jon Wu in `#tech-cab-approval-followups`, then hand to the DB team |
| **AS 3131015188, Cover Runbook** (Aug 2026) and **OP 2524381287, Reoccurring DataFix process** (Feb 2026) | Attach the script to the current **monthly umbrella ticket**, number it, let DB Portal auto-review, then ask Victor Alvarez and Krizza Rosales in `#datascript-requests` to run it |

Both pages are live and neither says the other is superseded. A new starter reading the AS page
tree top-down will find the older process first, because it is higher in the hierarchy.

**Also unresolved:** the Cover Runbook says "Incorrect URL ID Fix" still carries a named
approval gate, which implies the old CR route survives for some fixes but not others. There is
no list of which fixes need which route.

### 2.2 Who can remove an address from a SendGrid suppression list

- AS 1079312385 and AS 1078689857: *"we ask CTO to remove it for us, since we don't have access
  to it"*, and *"CTO is the only account that can remove it"*.
- AS 3131015188 (Aug 2026): *"Find the address in SendGrid, remove it from whichever list it is
  on, then tell the requester to retry."*

Either App Support gained the access and the older pages were not updated, or the newer runbook
is describing something the author can do that the reader cannot. This is a daily-frequency
task, so the ambiguity matters.

### 2.3 Horizon's production URL

App Support pages and the Ops escalation page use `horizon.moneyme.com.au`. The APY
environments page uses `horizon4.moneyme.com.au`. Both look current. No page explains whether
these are the same host, a migration in progress, or brand-specific.

### 2.4 Who to contact about Twilio

- AS 1079181314 and AS 1079312385 name **Khea Harder** as the Twilio product owner. Her
  Confluence account is marked **(Unlicensed)**, which normally means she has left.
- AS 546701313 says to raise Twilio issues to "the Comms Team (Jap/Aina)".
- AS 456556548 (the current Team Directory) names **Jeffrey Acosta** as Communications Tech
  Lead with Twilio as his specialty, and Hazelrey Cate Erasmo and Miela Jovienne Lacanilao as
  the Twilio developers.

Three different answers across three pages that are all presented as current.

### 2.5 SQL Data Fix scripts item numbering does not resolve

The Datafix catalogue routes by item number ("items 4, 67, 68, 73", "item 53", "item 91",
"item 96", "item 98") and describes the parent page as holding ~97 items. The parent page as
rendered has two numbered sequences: 1 to 28, then a restart at 1 running to 71. Item 53 on the
catalogue maps to something near, but not exactly, item 26 of the second sequence. **Every
cross reference in the catalogue is therefore approximate.** Anyone following a routing
instruction has to confirm by symptom text, and the catalogue does not say so.

---

## 3. Documented-as-broken scripts that are still published

The Datafix catalogue itself lists these, which is to its credit, but nothing has been done
about them on the source page:

| Item | Defect |
| --- | --- |
| 14 "Reverse Write Off" | Deletes across five tables in a `WHILE` loop with no transaction, references an undeclared variable, so **the batch fails after the deletes have committed**. Use item 15 instead |
| 15 "Reverse Writeoff V2" | Ships with `COMMIT;` uncommented against its own comment |
| 82 | `AND IsDischarged = 0 OR IsDischarged IS NULL` unparenthesised, so the backup SELECT scoops rows from other applications |
| 5, 35, login page item 5 | `UPDATE CustomerAccount ... WHERE CustomerId = x` with no `CustomerAccountId`, rewriting every brand row |
| 96 | Declares the same `SELECT * INTO` backup name twice, so the second throws and **the write proceeds unbacked**. Verification comments also disagree with what the code sets |
| 66 | Nulls `ApplicationId` on `InboundEmail` rows with **no backup at all** |
| 17 | Not valid T-SQL as published |
| 95 | Mutates a second database (`Payment.dbo.SplitAccount`) without saying so in its heading |
| 85 | Explicitly interim, "while dev fix is not yet released". Nobody has checked whether that release landed |
| Vehicles page item 3 | Compares an unquoted numeric literal to the varchar `VIN` column |

Roughly six of about 97 items use an explicit transaction. The rest are `SELECT * INTO` then a
bare `UPDATE`/`DELETE`, so a mis-scoped `WHERE` is permanent the moment it runs.

**A repo is a better home for these than a wiki page**, precisely because a broken script can be
fixed once, reviewed, and version controlled.

---

## 4. Things a support engineer needs that are simply not documented anywhere

### 4.1 How to actually do an account unblock or reset with G3APIBot

The Cover Runbook says most login work "never becomes a ticket at all because account unblocks
run through G3APIBot in `#unblock-account-request`". The only G3APIBot page found
(TECHNOLOGY 2994733113) explains how to **teach the bot facts**. **There is no page anywhere
that documents the unblock or reset command itself**, what it does to the database, who is
authorised to run it, or what to do when it fails. This is one of the highest-frequency tasks
App Support performs and it is entirely undocumented.

### 4.2 Production API base URLs

AS 550961514 lists QA base URLs for sixteen internal APIs, with eight of them blank. **No page
in the harvest records a single production API URL.** The page has not been touched since
January 2024.

### 4.3 Which sites Uptime Robot actually monitors

AS 1409351830 is twelve steps of generic Uptime Robot instructions, including how to create a
Slack webhook. It does not name a single MoneyMe site, does not say which Slack channel the
alerts land in for real (the example is `#uptime-alerts`), and does not say who owns the
account.

### 4.4 An App Support runbook for Uptrace

TECHNOLOGY 3071442984 documents the Sentry retirement thoroughly from an engineering angle.
Nothing tells App Support how to use Uptrace: how to get access, which project to open, how to
find an error for a given application, or what to do with the `deployment_environment_name`
filter. Meanwhile the App Support Sentry page (1409548294) is generic enough that it does not
name a single MoneyMe Sentry project, alert rule or DSN, and is being overtaken anyway.

### 4.5 On-call, out-of-hours and roster

There is no page describing an on-call rotation, an out-of-hours escalation path, or what
happens to a Critical ticket raised outside Manila business hours. The MHD urgency page sets a
4 hour response SLA for Critical without saying who is on the hook for it overnight.

### 4.6 A single "start here" page for a new App Support engineer

The Cover Runbook is the closest thing that exists, and it is framed as leave cover for one
person rather than as onboarding. A new starter would have to assemble the picture from at
least eight pages spread across four spaces, and would hit the superseded datafix process
first.

### 4.7 A brand and entity register

BrandId values are scattered across sample scripts: 1 is MoneyMe (inferred, never stated), 5 is
Autopay, 6 is SocietyOne, -1 and 0 mean "all" in two different tables. **No page lists them
together.** The task brief asked specifically about `Spv12`; SPV appears in the harvest only as
cashflow reporting (SPV 3 specification, SPV Tool Revamp G1-5776) and no page connects SPV
entities to BrandIds or to anything App Support touches. If `Spv12` is a trust entity, it is
not documented in Confluence.

### 4.8 What "DB Portal" is

The Cover Runbook says "DB Portal auto-reviews and posts a verdict" on every datafix script.
This is a gate every script passes through, and nothing in the harvest explains what DB Portal
is, who runs it, what it checks, or what to do when it rejects a script.

### 4.9 Refund process

The `#refund-supports` channel is part of the App Support remit. The only refund content found
is the datafix half on AS 2385150262 (sweep queries and the three fix shapes). There is no page
describing the refund process itself: who approves, what the customer-facing steps are, or how
a refund differs from the "cancel transaction" procedure, which the catalogue warns explicitly
**moves no money**.

### 4.10 Backout plans for the stored procedures

Fifteen of the sixteen `AppSupport_*` procedures take no backup. Three of them
(`AppSupport_DeleteCustomerContactNumber`, `AppSupport_DeleteCustomerEmail`,
`AppSupport_DeleteFileUpload`) are irreversible deletes with no inverse procedure, and there is
**no insert procedure for a BrandId 1 `CustomerEmail` or `CustomerContactNo` row**, so there is
no restore path at all. The catalogue page says to capture the row with `SELECT *` first, which
is the right advice, but it lives on a different page from the procedures themselves.

---

## 5. Staleness

| Page | Last updated | Why it matters |
| --- | --- | --- |
| AS 550961514 MoneyMe API's | Jan 2024 | QA only, half the rows blank, over two and a half years old |
| AS 580845583 Zepto Process | Feb 2024 | Predates the Split migration, PayTo and the Payment V3 event contracts |
| AS 498401800 App Support - Data Fix Manual | Jan 2024 | Documents the superseded CR route as the process |
| AS 1409351766 DataFix Guide | Dec 2024 | Same |
| AS 1409548294 Sentry Monitoring | Dec 2024 | Generic, and the platform is being retired |
| AS 1409351830 Uptime: Site Monitoring | Dec 2024 | Generic |
| AS 1398210569 Common Login SQL Data Fix Scripts | Mar 2025 | The catalogue itself calls this "stale but uniquely useful", it holds the best diagnostic in the tree |
| AS 1397882974 APY / SPL vehicles updates | Mar 2025 | The catalogue calls it stale; still the only source for vehicle field corrections |
| AS 1079181314 / 1079312385 / 1078689857 Twilio and Comms | Sep–Oct 2024 | Name a departed product owner; the Comms platform has had a revamp and a Braze integration since |
| AS 502890827 Salesforce Guide and children | 2023–2024 | Salesforce is legacy for SocietyOne; unclear how much still applies |
| AS 546701313 Common issues in App Support | Dec 2025 | Still references the LoC Shuffle script, which stopped running in Mar 2025 |
| MHD 398622726 Urgency | Sep 2023 | Three years old, and the SLAs are quoted in the current process |

---

## 6. Structural problems with the Confluence itself

### 6.1 The App Support pages exist twice

On **4 July 2025** the entire AS page tree was copied into the **TO (Tech Ops)** space under a
page called "Platform and Support" (TO 1039401209). Roughly 50 pages now exist in both places
with different page ids. `SQL Data Fix scripts` is AS 519602304 and TO 1968504962;
`App Support Daily Alerts` is AS 899317845 and TO 1968505511; and so on.

The AS copies have continued to be edited (SQL Data Fix scripts to Aug 2026) while the TO copies
are frozen at their 2025-07-04 copy date. **Anyone who lands on a TO copy from search is reading
a fourteen month old snapshot with no warning.** The duplicates should be deleted or replaced
with redirects.

### 6.2 The space is named for a team that no longer has that name

The space key is `AS`, the display name is "Platform and Support", and the homepage is still
titled "App Support". Search results show "Platform and Support", which is not what anyone calls
it. Worth noting in the repo's README so people can find the source.

### 6.3 Load-bearing pages are owned by departed staff

Authors marked "(Unlicensed)" in Confluence, which normally indicates a deactivated account,
include **Anna Paulene Pascual** (Ticket Handling, Release Process, New Release Process,
Incident Report Process, Team Directory), **Evangelia Liaros** (Stage & Status Logs, Payment
Channels, the two most valuable Horizon pages), **Melissa Pabillano** (APY Environments),
**Khea Harder** (named as Twilio PO), and **Louie Christopher de Guzman** (SSDLC). Nobody has
picked up ownership.

### 6.4 Operational documentation lives in personal spaces

Most seriously, **"Database Restore Procedure"** (page 2335015225) sits in Maria Krizza
Rosales' personal space. It documents restoring a database via Azure Automation Runbooks. That
is a disaster-recovery procedure in a space that disappears when its owner leaves. Others:
"Stage movement - environment variables" (Lea Nicolas), "Venus Environment, Architecture
Wiring Map" and the SocietyOne API rebuild assessments (marlon.pamisa), "PayTo GTM"
(David Orr).

### 6.5 Key process pages are images, not text

**AS 502825229 "Application Support Process"** is the top of the App Support hierarchy. Its
entire body is a heading, one sentence, an embedded diagram and two links. The process flow is
in the image, so it is not searchable, not diffable, and not extractable. The same is true of
**AS 1224704086 "Application Support Process Flow"**.

### 6.6 SQL pasted as screenshots

The Cover Runbook records this explicitly: in seven of seventeen tickets sampled across merges,
rates, assets and platform bugs, the SQL was pasted into the ticket as a screenshot rather than
text, so it cannot be searched or reused. That is roughly 40% of the historical fix record lost
to image capture.

---

## 7. Known defects being data-fixed rather than fixed

Recorded on AS 3131015188 as recurring work that should not exist:

| Defect | Status |
| --- | --- |
| Zero interest rate on `ApplicationCharge` | "Apply the existing fix script", then rerun the Funding Event. Recurring |
| `IsEditedVehicleDetails` incorrectly set to 1, causing infinite loading on "calculating your finance details" | Permanent fix requested and not delivered. Expect it to recur |
| `TinyUrl` | Data fixed each time |
| CRD PayAnyone blocked by an unnecessary funding condition | **API-6134** raised, not delivered. Albert hit it three times in one month |
| No self-serve removal from SendGrid suppression lists in Horizon | **MHD-35799** raised, still Pending |
| ABN Active Since date resets after a brief ABR cancellation | No self-service re-sync exists, so every correction is a manual data fix |
| Missing Default Payment Mode on direct debit | Cohort-based; `AppSupport_UpdateToDefaultPaymentMethod` has no INSERT path, so half the cases need a raw INSERT |
| CCC→CRD migration carries `DisablePaymentSubmission` across | Blocks all future submissions on migrated accounts |

---

## 8. What I could not access or did not cover

Stated plainly rather than papered over:

- **The TECHNOLOGY space could not be enumerated.** `getPagesInConfluenceSpace` timed out on
  it. It was sampled by CQL only, so this harvest almost certainly missed App Support relevant
  pages there. It is the largest space in the site and holds the Twilio platform docs, the API
  BOT Knowledge Vault, the contract generator and Braze technical references, and the sprint
  goal pages.
- **The TO space listing was truncated** at 250 results with more pages available. The omitted
  tail appears to be daily security logs, but that was not verified.
- **No archived space was inventoried**: `MTO`, `MOBILE`, `TEC`, `STT`, `AD`, `MK`, `DM1`,
  `MIH`. `MTO` ("MME Tech operations") and `MIH` ("MoneyMe Internal Helpdesk") in particular may
  hold superseded App Support material worth checking before anything is declared missing.
- **Pages identified but not read in full**, because of the read budget: OP 44597391 (Zepto -
  rejected payment codes and creating a Split account, referenced twice and clearly load
  bearing), TPM 889978981 (Helpdesk Ticket Process), TECHNOLOGY 479363489 (How to add new
  workflow), TECHNOLOGY 2785771528 (How an Application Becomes Eligible to Fund), the three
  Vault sub-pages (2868675170, 2870149155, 2868805787), and the Twilio platform pages
  (2761163168, 2731868161, 2725150760, 2384658887). All are marked in the inventory.
- **Page attachments were not harvested.** Several pages reference attached `.sql` files by name
  (for example `DataFix-MHD-28180-10002649556.sql`) and images carrying process diagrams and
  screenshots. Those attachments are not in this extract, and for the process diagrams they are
  the only copy of the content.
- **Comments were not read.** Confluence page comments can carry corrections that never made it
  into the body.
- **Jira was not harvested.** A great deal of the real fix record lives in MHD ticket comments
  rather than in Confluence; the Cover Runbook was itself built by pulling 801 Jira issues.

---

## 9. Suggested repo structure, given what is actually there

Not asked for, but it falls out of the inventory:

```
/runbooks/          cover-runbook, funding, login, comms, contract, split-account
/datafix/           procedures/ (the 16 AppSupport_*), catalogue/ (the ~100 raw items,
                    fixed and reviewed), lookups/ (the Pass A queries)
/reference/         horizon-stages.md, horizon-statuses.md, ids-and-codes.md,
                    tables.md, environments.md, integrations.md
/process/           datafix-workflow, ticket-handling, triage, release, incident,
                    escalation-matrix, slas
/people/            team-directory.md, escalation contacts
/gaps/              this file, kept live
```

The two things worth doing first, before any mirroring:

1. **Resolve the datafix process contradiction** (section 2.1) and delete or archive the
   superseded page. Everything else in the repo depends on which process is correct.
2. **Get the credentials off Confluence** (section 1.1). A private GitHub repo is not a safe
   destination for them either.
