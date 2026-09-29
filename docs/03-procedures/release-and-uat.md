# Release and UAT

How a change gets from a tested ticket to production through MHD, and how App Support records UAT and post-deployment test results.

Last reviewed: 23 September 2026

Sources: `harvest/confluence-content.md` (New Release Process 2036138487, earlier Release Process 995033259, App Support Data Fix Manual 498401800); `harvest/confluence-systems-reference.md` sections 1, 6, 11 and 13; `harvest/slack-procedures.md` sections 2.6 and 10; `harvest/jira-issue-catalogue.md` and `harvest/jira-precedent-index.md` (HOR-8167); repo owner brief, 23 September 2026 (house test result format).

**Current source:** New Release Process, Confluence 2036138487 (1 Sep 2025, author Anna Paulene Pascual). It supersedes Release Process, Confluence 995033259, and is to be followed "until the release process is automated".

## 1. Release types

| Release type | Definition | Urgency | Change Type | Extra |
| --- | --- | --- | --- | --- |
| **Scheduled Release** | Planned, regular, follows the fortnightly timeline | Low to Medium | Standard | |
| **Out-of-Schedule Release** | Planned release outside the normal cycle for a specific need | High to Critical | Standard | Add the `Out-of-Schedule_Release` label. **Once a week maximum** since Sep 2025 |
| **Hotfix Release** | Urgent, unplanned, fixes critical issues or production bugs | High to Critical | Emergency | |

Cadence (Confluence 2036138487):

- Scheduled releases are **fortnightly, on a Tuesday**.
- **The MHD ticket cutoff is the Wednesday before** the release.
- Out-of-Schedule releases are capped at once a week so the Release team can prepare. They are planned in a **weekly PM/SM and Release team meeting**; major releases in the same week are agreed there.

Note that Urgency, not Priority, is the field the release type maps to. This is consistent with how MHD uses Urgency elsewhere (see [`jira-conventions.md`](jira-conventions.md) section 3).

## 2. Release preparation

Before raising the MHD ticket:

- All tickets tested and **ready for release**. User Stories, Production Support and Bug tickets must be **QA Passed with test evidence or test suites clearly commented on the ticket**.
- Dependencies ready for release, already released, or confirmed no impact.
- Azure release notes filled in. Required fields: Description, Change Request link (the MHD ticket), Development Ticket (the User Story), Project Pull Request (PR link), Implementation Plan, Rollback Plan.
- **The pull request must be reviewed by two devs other than its owner.** Otherwise the release can be delayed.

## 3. Creating the MHD ticket

1. Go to `https://moneyme1.atlassian.net/servicedesk/customer/portal/1`, then **Change Requests > Code Release**.
2. Use the description template from Helpdesk Ticket Process (TPM space, Confluence 889978981).
3. Attach the Release Notes link in the **Azure Devops - Release Notes** field.
4. Put a screenshot of the **completed and approved PR** in the description, one per PR.
5. After submitting through the portal, open the created Jira ticket and add a **Post Deployment Tester**.
6. Set the **planned end date on or before the release date**.
7. Link the User Stories, Production Support or Bug tickets that carry the test evidence comments, so approvers can check them.
8. The ticket must be approved and moved to **Awaiting Implementation** before it can be released.

**Never reuse an MHD ticket.** A new item or feature means a new MHD ticket (Confluence 2036138487).

Issue types in use for releases are **Change Request with Approvals** (10128) and, for higher risk, **Change Request with Multiple Approvals** ([03-procedures/jira-conventions.md](jira-conventions.md)). Summary prefixes follow the platform convention: `[HOR - CODE Release]`, `[G1 - Database Release]`, `[PL - Database Release]`, `[CRD - Code Release]`, `[SPV - Horizon2 DB]` and so on. The full list is in [`datafix-request.md`](datafix-request.md) section 6.

### CAB approval

Approvals are chased in `#tech-cab-approval-followups`, tagging the approver ([03-procedures/README.md](README.md) section 10). Two readings of who the approvers are:

- **Slack, as practised:** Jon, Julius, Fred, Jeffrey Lu.
- **Confluence 498401800 (Jan 2024):** Jeffrey Lu and Jonathan Wu.

These are compatible if "Jon" is Jonathan Wu, which the Slack ID `UFZHH7CD6` suggests but the sources do not confirm. **Unverified:** whether Julius and Fred are formal CAB approvers or simply people who can unblock an approval.

## 4. Pre-release

- **Release board.** Once the MHD ticket is in Awaiting Implementation, the automated RB ticket can be lined up in the matching Release Sprint on board 81: `https://moneyme1.atlassian.net/jira/software/c/projects/RB/boards/81/backlog`.
- **Out-of-Schedule and Hotfix requests** need, from the PM/SM: target release date; major or minor release; reason; and the release planning meeting, channel or documentation link.
- **Cutoff reminder.** On cutoff day the Release team sends a Slack reminder. After cutoff they check each ticket for completeness and approval; **incomplete tickets are removed from the list** and the PM/SM is told.
- **Pre-Release email** goes to the tech, product, ops and marketing teams once the list is complete.

## 5. Release

The release manager releases the tickets on the pre-release list. Hotfixes and Out-of-Schedule releases can go out even if not on the list. With many items, expect the release to carry over across days.

## 6. Post-release status path

```
Awaiting Implementation
  -> (released)
  -> Post-Deployment Testing
       -> Post-Deployment Testing Successful  -> Deployment Completed
       -> Post-Deployment Testing Failed
            -> Rollback In Progress -> (rollback testing)
                 -> Rollback Done
                 -> or: team assesses fix or redeployment
            -> Implementing -> (redeploy, retest) -> Deployment Completed
```

- The release manager or SM moves the ticket to **Post-Deployment Testing**. QA then tests and moves it to Successful or Failed.
- **Redeployment the same day:** move to Implementing, retest, continue to Deployment Completed.
- **Redeployment not the same day:** move to Implementing and **clone the ticket with `[Redeployment]` in the title**. The clone gets its own automated RB ticket, which must be lined up for release again.
- **Before Deployment Completed**, the SM or PM must comment whether a **PIR** document is needed, and attach it if so.
- A **Post-release email** lists everything released, to notify the business.

**Reporting gotcha:** `Deployment Completed` is in the Done status category but never sets `resolution`. Query releases with `statusCategory = Done`, never `resolution = Done` ([03-procedures/jira-conventions.md](jira-conventions.md)).

The earlier process (Confluence 995033259, 30 Jul 2025) had no weekly PM/SM meeting, no once-a-week cap, no PR screenshot requirement and no explicit rollback statuses. Treat it as superseded.

## 7. UAT conventions

### Environments

| Environment | Horizon URL | Used for |
| --- | --- | --- |
| QA | `https://qa-horizon.moneyme.net/` | QA team testing |
| Integration | `https://integration-horizon.moneyme.net/` | UAT, as App Support practises it |
| Production | `https://horizon.moneyme.com.au` | Post-deployment testing on a real application |

Source: Confluence 426082342 via [01-systems/README.md](../01-systems/README.md) section 6. Note the alternate production host `https://horizon4.moneyme.com.au/` recorded on the APY page; both appear current.

### The observed sequence

HOR-8167 (Horizon upload limit, 10 MB to 30 MB) is the cleanest recent example of the full chain ([06-reference/mhd-issue-catalogue.md](../06-reference/mhd-issue-catalogue.md), [06-reference/mhd-precedent-index.md](../06-reference/mhd-precedent-index.md)):

1. **QA passed** 2026-08-06, Jeric Mislang.
2. **UAT passed on Integration** 2026-09-09, Ron: 25 MB uploaded, 30.2 MB uploaded, 31 MB correctly rejected.
3. **Production test passed** 2026-09-10 on app 10003089519.

Linked QA automation tasks: QAAUTO-1845, QAAUTO-1992 (via the `tests` link type).

Two lessons carried from the precedent index:

- **Test the edges, not just the happy path.** HOR-8167 was tested at, above and below the limit. By contrast, the `DurationInYears` loan term regression (MMM-9350) *"passed QA, UAT and production checks because every test account happened to have a whole-year term"* ([06-reference/mhd-issue-catalogue.md](../06-reference/mhd-issue-catalogue.md)). Pick test data that exercises the boundary the change touches.
- **Check side effects on shared components.** The HOR-8167 IIS limit was raised site-wide, so it also affects the Visa, Bank Recon and Campaign Dialer upload screens. Sanity-check those after any related release.

QA contacts: Jeric Mislang, Ricky, Dominic Austin Sicat, Reynard Prudente ([03-procedures/jira-conventions.md](jira-conventions.md)).

### House test result format

App Support records UAT and post-deployment results as a ticket comment with these six fields, in this order (repo owner brief, 23 September 2026; the format itself is not captured in the harvest notes):

```
Test Result:
AUT:
Browser Used:
Test Environment:
Test Evidences:
Notes:
```

| Field | What goes in it |
| --- | --- |
| **Test Result** | `Passed` or `Failed`. One word, first line, so the verdict is readable at a glance |
| **AUT** | The application under test, plus the ticket being tested. Not to be confused with the Confluence Autopay space key `AUT` |
| **Browser Used** | Browser and version |
| **Test Environment** | `QA`, `Integration` or `Production`, with the host URL |
| **Test Evidences** | Screenshots or recordings attached to the ticket, plus the concrete cases run and their outcomes. For production, the application ID tested |
| **Notes** | Side effects, out-of-scope findings, anything that needs its own ticket |

Unverified: the expansion of AUT as "application under test" is the standard QA meaning and is assumed here; no source defines it.

Worked example, **reconstructed** from the HOR-8167 facts above to show the shape. It is not a copy of the comment on the ticket, and the browser was not recorded in the harvest:

```
Test Result: Passed
AUT: Horizon file upload (HOR-8167, raise upload limit to 30 MB)
Browser Used: {browser and version}
Test Environment: Integration, https://integration-horizon.moneyme.net/
Test Evidences:
  - 25 MB file uploaded successfully (screenshot attached)
  - 30.2 MB file uploaded successfully (screenshot attached)
  - 31 MB file rejected at selection with "File size is exceeding to its limit 30 mb" (screenshot attached)
Notes:
  - IIS maxAllowedContentLength raised site-wide; Visa, Bank Recon and Campaign Dialer upload screens should be sanity-checked.
  - Out of scope: SOA email attachment ceiling (SendGrid caps attachments at roughly 30 MB). Not ticketed.
```

## 8. Where App Support fits

- **Post Deployment Tester.** App Support is often the named tester on releases that fix App Support-raised Problems, as on HOR-8167.
- **Database releases carry scripts.** `#datascript-requests` requests frequently reference a release ticket (`AMZ-`, `PER-`, `G1-`, `HOR-`, `CL-`, `APY-`) that itself carries the script, rather than an MHD Problem ([03-procedures/README.md](README.md) section 2.4). The same channel rules apply: name the file, give the order, ask for results back.
- **Hotfix triage.** Before raising a Problem, check whether the symptom is a hotfix or deployment side effect that engineering already owns (App Support Ticket Triage, Confluence 2910191688). See [`issue-intake-and-triage.md`](issue-intake-and-triage.md).

## 9. Links

- Release board: `https://moneyme1.atlassian.net/jira/software/c/projects/RB/boards/81/backlog`
- RB release notes: `https://moneyme1.atlassian.net/projects/RB` (Releases page)
- MHD ticket creation guidelines: Helpdesk Ticket Process, TPM space, Confluence 889978981
- Process flow diagram: Lucidchart `4a45dea5-c69f-4859-99f0-3acc6ffcc796`
- Out-of-Schedule and Hotfix tracking board: Lucidspark `ded4931b-5944-431d-83ca-aaf366f956c5`
- Related: [`jira-conventions.md`](jira-conventions.md), [`datafix-request.md`](datafix-request.md), [`../05-knowledge/`](../05-knowledge/)
