# Jira conventions (MHD)

How MHD is actually structured and used: issue types, statuses, resolutions, labels, comment visibility, linking, and JQL that works.

Last reviewed: 23 September 2026

Sources: `harvest/jira-raw-notes.md`; `harvest/confluence-systems-reference.md` section 10; `harvest/confluence-content.md` (Ticket Handling Manual 454590514, App Support Data Fix Manual 498401800, New Release Process 2036138487); `harvest/slack-procedures.md` section 10; repo owner brief, 23 September 2026 (the `jsdPublic` note in section 9).

Site: `moneyme1.atlassian.net`, cloudId `d9911a71-58c8-4d3c-a772-0f89702b5921`. MHD is "MME Help Desk", service desk portal 1.

- Portal: `https://moneyme1.atlassian.net/servicedesk/customer/portal/1/MHD-xxxxx`
- Browse: `https://moneyme1.atlassian.net/browse/MHD-xxxxx`

## 1. Issue types

Every MHD type carries the description string "MHDv2" in the API, which tells you nothing.

| ID | Name | What it is actually used for |
| --- | --- | --- |
| 10130 | **Problem** | App Support's investigation ticket. Almost always created from a Slack message. This is the App Support workload |
| 10125 | **- Service Request** | Generic intake plus automated feeds. Note the **leading hyphen and space** in the name, which matters for JQL |
| 10128 | **Change Request with Approvals** | Code and database releases: `[HOR - CODE Release]`, `[G1 - Database Release]`, `[PL - Database Release]`, `[CRD - Code Release]` |
| 10129 | **Change Request Data Fix/External with Multiple Approvals** | The monthly `[App Support] Data Fix - YYYY-Mon` umbrella, and other data fix changes |
| - | **- Service Request with Approval** / **with Multiple Approvals** | Approval-gated service requests |
| - | **Change Request with Multiple Approvals** | Higher-risk releases |
| - | **Threat Intelligence Review** | 437 in the harvest window, entirely auto-created by `defender-noreply@microsoft.com`. **Exclude from any support metric** |
| - | **Incident** | Only 16 in twelve months. Effectively unused, see [`issue-intake-and-triage.md`](issue-intake-and-triage.md) |
| 10053 | **Production Support** | Used in HOR, not MHD |
| - | Others | Task, Story, Risk Acceptance, Database Maintenance, Data Intelligence MHD, Data Intelligence General, Template Request, Feature Request, `Service request` |

**There are two service request types differing only in case:** `- Service Request` and `Service request`. Include both in any JQL.

## 2. Statuses and workflow

Three workflows are in play, which is why the status list is long.

**Service desk workflow (Problems and Service Requests):**

```
Waiting for Support (10001)
  -> WORK IN PROGRESS (10014)
  -> Waiting for Customer (10002) / Waiting for Confirmation (10324) / Pending (10003) / Escalated
  -> Closed (6) or Cancelled
```

Others seen: Completed (10011), Review, WAITING FOR REVIEW, Scheduled (10323), Selected for Development (10032), Ongoing Development (10327), For FE Ticket Creation. `Waiting for Customer` carries a **WFC Tracker** field ([03-procedures/README.md](README.md) section 10).

**Change and release workflow:**

```
Change Request Preparation (10209)
  -> Change Approval / CAB - Approval / Waiting for approval
  -> Awaiting implementation (10013)
  -> Implementing (10008)
  -> Post-Deployment Testing (10213)
  -> Post-Deployment Test Successful (10214)
  -> Deployment Completed (10212)
```

Also: Released (10265, on RB Release Tasks), Declined, Risk Accepted, and `Canceled` with one L, which is distinct from `Cancelled` (10122). **Grep for both spellings.** The rollback branch is in [`release-and-uat.md`](release-and-uat.md).

### Status category mapping that matters for reporting

| Status | Category |
| --- | --- |
| Closed | Done |
| Deployment Completed | Done |
| Cancelled (10122) | Done |
| Waiting for Support | In Progress |
| Waiting for Customer | In Progress |
| Waiting for Confirmation | In Progress |
| Pending | In Progress |
| Selected for Development | In Progress |
| Scheduled | In Progress |
| Change Request Preparation | To Do |

**`Deployment Completed` sits in the Done category but never sets `resolution`.** Any query filtering on `resolution = Done` silently drops every completed release and data fix. Use `statusCategory = Done`.

## 3. Priority and Urgency

**Priority is not a triage signal on Problems.** The scheme has Highest (1), High (2), Medium (3), Low (4), Lowest (5), with Critical alongside. Every Problem read in the harvest was `Low`. High and Highest appear almost exclusively on Change Requests and releases. Critical (267 in the window) is concentrated in the security and Threat Intelligence feed.

**Urgency is the real field.** The SLA table keys off it and the Selected for Development filter queries it. See [`issue-intake-and-triage.md`](issue-intake-and-triage.md) for the SLA table and how urgency is set, and [`monthly-sfd-reminder-email.md`](monthly-sfd-reminder-email.md) for the standing instruction never to sort by Priority in this project.

## 4. Resolutions

Only five values exist and three are nearly unused: **Done (10000)**, Duplicate (10002), Won't Do, Cannot Reproduce, and empty.

**There is no "Works as Designed" resolution, which is a real gap.** A significant share of Problems close with a clear "this is correct behaviour" answer (MHD-36075, MHD-35381, MHD-36206, MHD-36283, MHD-31787, MHD-30961) and every one is recorded as `Done`, indistinguishable from an actual fix. Until a value exists, say so in the closing comment so the text carries what the field cannot.

## 5. Labels

Used on roughly **2 per cent** of issues and almost entirely on releases:

`Out-of-Schedule_Release`, `code-release`, `db-release`, `Autopay`, `AmortizationV2`, `G1`, `FE`, `Platform-Support-BAU`, `Collections`, plus a small security cluster: `Vulnerability-Management`, `PAN`, `PCI-DSS`, `cardholder-data`, `data-leakage`, `security-incident`, `infrastructure`.

Do not rely on labels for reporting. The one label with process weight is `Out-of-Schedule_Release`, which the release process requires (Confluence 2036138487).

## 6. Components

**Unpopulated across the entire project.** Product is encoded in the summary prefix instead, so any product-level reporting has to parse the summary.

| Prefix | Meaning |
| --- | --- |
| `APY` | Autopay (car and asset finance) |
| `CRD` | Credit Card |
| `MME` | MoneyMe |
| `PL` / `PL Broker` | Personal Loan, broker channel |
| `Freestyle` | Freestyle line of credit, being discontinued |
| `SOC1` / `SocietyOne` | SocietyOne |
| `SPL` | Secured Personal Loan; PPSR and vehicle asset tickets |
| `LOC` | Line of credit |
| `[HOR - CODE Release]` | Horizon code release |
| `[G1 - Database Release]`, `[PL - Database Release]`, `[SPV - Horizon2 DB]` | Database releases by platform |
| `[CRD - Code Release]`, `[G1/G3/FE - Code Releases]` | Code releases by platform |
| `[App Support] Data Fix - YYYY-Mon` | The monthly data fix umbrella |
| `[APY] [UP TO DD/MM/YY]` | Recurring scheduled clean-up batches |

Because components are empty, the "Team" label used in the monthly Selected for Development reminder is not in Jira at all and has to be carried forward by hand. See [`monthly-sfd-reminder-email.md`](monthly-sfd-reminder-email.md).

## 7. How a ticket is born

Most Problems are created from Slack. The description ends with a line in this form:

> *Issue created in Slack from a* [*message*](https://moneymefinance.slack.com/archives/<channel>/p<ts>)*.*

Channel IDs seen in ticket descriptions, useful for tracing back:

| Channel ID | Source |
| --- | --- |
| `GG7HL6CTE` | The main `#app-support` intake. By far the most common |
| `C07JY7GMEMT` | Datascript requests and escalations |
| `C03DYRHJ1C6` | Broker and Autopay (`#autopay_feedback`) |
| `C05J8HEVC81` | Funding and stage-stuck applications (`#pending-funding-checks`) |
| `C06LR1SJJ8Y` | Equifax and credit score |
| `C0C1ETVFW87` | Refund support |
| `C05MP53UX0C`, `C07CSTF1LD8`, `C05QV96RURW`, `D06AQL6ATU2` | Follow-up and escalation threads |

**Contradiction worth noting.** The Jira notes infer `C07JY7GMEMT` as datascript requests and `C0C1ETVFW87` as refund support, but the Slack harvest gives `#datascript-requests` as `C02HB99AXDX` and `#refund-supports` as `C051WET9T1A` ([03-procedures/README.md](README.md) sections 2 and 5). The Slack IDs are read from the channels directly and should be preferred; the two Jira-cited IDs are probably other channels (possibly successors or side channels). **Unverified** which.

## 8. The automation cycle

Every Problem goes through the same rhythm, posted by **Automation for Jira**:

1. **On creation:** *"Hi @reporter, Thanks for raising an issue. @assignee will check this."* This is how the ticket gets assigned. It usually lands within minutes to a few hours.
2. **The next morning at 10:00:** *"Just following up to see if you had a chance to review our last update. If we don't hear back within the next 5 business days, we will assume that the issue is resolved and will close the ticket."*
3. **After five business days with no reporter reply, at 18:00:** *"This ticket is being closed due to no response after 5 business days. Please create a new ticket if you still need assistance."* This sets `resolution = Done` and `resolutiondate`.

**Consequence for any metric:** a large share of `resolutiondate` values are set by step 3, not by anyone confirming a fix. Treat MHD resolution time as "time until the conversation stopped", not "time to fix".

## 9. Comment visibility

Investigation write-ups are frequently posted with:

```json
"visibility": { "type": "role", "value": "Service Desk Team" }
```

which restricts the comment to the **Service Desk Team** role and hides the internal detail from the reporter. The convention is two comments:

1. An **internal, role-restricted comment** with the full analysis: timeline table, root cause, precedents, recommended action.
2. A **separate public comment** in plain language addressed to the reporter, with "what you can tell the customer" bullets.

MHD-36075, MHD-36092 and MHD-36446 are the cleanest examples. It is a good convention and worth keeping.

**Gotcha.** The API returns `jsdPublic: true` on these comments anyway, even where the role restriction is set (repo owner brief, 23 September 2026; not recorded in the harvest notes). So:

- Do not trust `jsdPublic` to tell you whether a comment is internal.
- After posting an internal comment via the API, **open the ticket in the UI and check it**. If the service desk view shows it as shared with the customer, flip the toggle to internal there.
- Until you have eyeballed it, treat every API-posted comment as potentially reporter-visible. Keep customer-identifying detail and unconfirmed blame out of anything you have not checked.

## 10. Investigation comment structure

The strongest write-ups follow a consistent shape. Use it.

- **Investigation summary, App Support** as the heading
- **A verdict in the first line**: "Confirmed as a system defect", "Not a system defect"
- **Account facts**: ID, brand, product, limit, balance, APR, DPD
- **A markdown timeline table** with date and event columns
- **Root cause**, with the arithmetic shown
- **Customer impact**, quantified
- **Ruled out**, listing what was checked and eliminated
- **Precedent**, with ticket keys and what each one concluded
- **Recommended action**, as a numbered list
- **Separate finding** for anything discovered in passing that needs its own ticket
- **Acceptance criteria** on the more serious tickets

Where an AI agent did the work, the comment carries the line **"Investigated by Claude agent"** (MHD-36009, MHD-36790, MHD-36494).

## 11. Corrections

Where an earlier conclusion turns out to be wrong, **correct it in place and say so explicitly** rather than quietly editing.

- MHD-36092: *"My initial analysis attributed the fault to the app's term formatter. That was wrong on location."*
- MHD-36668: *"The earlier version of this note said the emails went out 61 days after settlement. That was wrong."*

This is what keeps the ticket history trustworthy.

## 12. Linking conventions

| Link type | Direction words | Used for |
| --- | --- | --- |
| **Cover** | covers / covered by | The dominant link on the monthly data fix umbrella. The umbrella `covers` the child. Also used from a release to the stories and bugs it carries |
| **Blocks** | blocks / is blocked by | Also used heavily on the data fix umbrella, apparently interchangeably with Cover. On MHD-35277's 69 children the split looks arbitrary |
| **Finish-to-Finish (Teamboard)** | cannot finish until / linked issue cannot finish until | MHD to MMM, MHD to HOR, MHD to RB cross-project dependency |
| **Testing** | tests / tested by | QAAUTO tasks against a HOR or MHD ticket |
| **Relates** | relates to | General |

**The Blocks-versus-Cover inconsistency means you must query both** to enumerate a month's data fixes.

### Downstream projects App Support links into

| Key | Name | Why it matters |
| --- | --- | --- |
| **AMZ** | Amortization | AMZ-7074 is the root cause of MHD-36446 |
| **HOR** | Horizon | HOR-8167, HOR-8170, HOR-8183 |
| **CRD** | Credit Card | CRD-2459 fixed the CRD advance-payment DD cancellation |
| **MMM** | MME Mobile | MMM-9350 caused the loan term regression; MMM-16301 is the open fix |
| **G1** | Greenfield 1 | Comms API. G1-6834 and G1-7161 hold the SendGrid suppression findings |
| **RB** | Release Board | Release Tasks paired with MHD Change Requests, for example RB-1558; board 81 |
| **QAAUTO** | QA Automation | Linked by `tests` |
| **PER** | Personal Loan | PER-8726, PER-8649 in PL database release titles |
| **API** | Payment API and funding | API-6134, the CRD PayAnyone funding fix |
| **APY**, **CL**, **COL**, **DC**, **CM**, **FE**, **DAT** | Autopay, Collection, Collections, DevCore, ClearMatch Migration, front end, data | Referenced in release titles and escalations |

**Open question.** CL (Collection) did not surface organically in any MHD link chain during the harvest, despite CL-series tickets being part of App Support's stated workload (for example CL-628 on negative SOA outstanding charges, [03-procedures/README.md](README.md) section 8.4). Either CL is linked by another convention or the relationship is tracked only in Slack. See [`../07-open-items/`](../07-open-items/).

## 13. Ticket fields for a data fix Change Request

From the App Support Data Fix Manual (Confluence 498401800, Jan 2024, so this reflects the older approval-heavy route):

| Field | Value |
| --- | --- |
| Project | MME Help Desk (MHD) |
| Issue type | Change Request Data Fix/External with Multiple Approvals |
| Summary | `Data Fix for <Requestor>` |
| Urgency | Medium |
| Data fix reason | Lack of Feature |
| Additional information | `Can't edit <field>` |
| Database Affected | Horizon2 |
| Priority | Medium |
| Approvers | Jeffrey Lu, Jonathan Wu |
| Impact | Minor/Localized |

The implementation plan is the approved SQL script, commented on the ticket as an **Internal Note**. The test plan and rollback plan are separate comments. Screenshot the affected fields in Horizon Web **before** implementing. See [`datafix-request.md`](datafix-request.md) for how this relates to the current monthly umbrella route.

## 14. JQL that works

```
project = MHD AND created >= "2025-09-01" AND created <= "2026-09-23"

project = MHD AND issuetype = Problem AND statusCategory != Done

project = MHD AND summary ~ "App Support Data Fix" ORDER BY created DESC

project = MHD AND issuetype in ("- Service Request", "- Service Request with Approval",
  "- Service Request with Multiple Approvals", "Service request")

project = MHD AND issuetype = "Change Request Data Fix/External with Multiple Approvals"

project = MHD AND statusCategory = Done          -- NOT resolution = Done
```

Saved filters in daily use:

```
filter = 10200                                   -- New and Pending Tickets (Confluence 454590514)
filter = 10591                                   -- Monitor up/down queue, see jira-monitor-ticket-closure.md
filter = 10859                                   -- [BAU] Selected for Development
filter = 10859 AND Urgency in (High, Critical)   -- monthly SfD reminder content
```

### Gotchas

- `text ~` is **stemmed and word-based, not phrase-based**. Multi-word terms over-match: `text ~ "statement of account"` returns 1,756, which is nonsense.
- `text ~` searches **comments** as well as summary and description.
- Search `Amortization`, not `amortisation`: 183 results versus 11.
- `text ~ "DDR"` returns only 5. It is not a usable handle for direct debit requests.
- `text ~ "trust migration"` returns 0.
- The `- Service Request` type name starts with a **hyphen and a space**. Quote it.
- The MCP search tool caps `maxResults` at **100**. Use `nextPageToken`, or partition by created-date range and page each partition in parallel.
- `searchResultMode: "count"` returns a cheap `totalCount` and is the right tool for any aggregate.
- Exclude **Threat Intelligence Review** from every support metric.
- Never filter or sort by Priority when the question is about urgency.

## 15. Related

- Intake, urgency and escalation: [`issue-intake-and-triage.md`](issue-intake-and-triage.md)
- Data fix umbrella and linking in practice: [`datafix-request.md`](datafix-request.md)
- Release statuses in full: [`release-and-uat.md`](release-and-uat.md)
- Precedent index by ticket key: [`../05-knowledge/`](../05-knowledge/)
