# New Release Process

Mirror of the Confluence page "New Release Process".

Last reviewed: 23 September 2026
Sources: Confluence AS page 2036138487, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 2036138487 · Last updated: 1 Sep 2025 · Author: Anna Paulene Pascual
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/2036138487/New+Release+Process

Supersedes "Release Process" (page 995033259). Followed until the release process is automated.

**Change in out of schedule releases.** Out of Schedule Releases will only be once a week, so
the Release team can prepare properly. Weekly meetings take place between the PM/SM and Release
team to plan them. If there are Major Releases in the same week, the approach is agreed in that
meeting.

Process flow diagram: Lucidchart `4a45dea5-c69f-4859-99f0-3acc6ffcc796`.

## Release preparation

Prepare all needed information for the MHD ticket:

- All tickets tested and **ready for release**. User stories, Production Support or Bug tickets
  must be QA Passed with test evidence/test suites clearly commented on the ticket.
- Dependencies must be ready for release, already released, or have no impact.
- Azure release notes filled in. Required fields: Description, Change Request link (MHD ticket),
  Development Ticket (User Story ticket), Project Pull Request (PR link), Implementation Plan,
  Rollback Plan.
- **The pull request must be reviewed by two devs other than its owner.** If this is not done,
  the release can be delayed.

## Create the MHD ticket

- Go to https://moneyme1.atlassian.net/servicedesk/customer/portal/1
- **Change Requests > Code Release**
- Description template: Helpdesk Ticket Process, TPM space page 889978981.

Release types, urgency and change type:

| Release type | Definition | Urgency | Change Type | Extra |
| --- | --- | --- | --- | --- |
| **Scheduled Release** | Planned, regular, follows the fortnightly timeline | Low to Medium | Standard | |
| **Out-of-Schedule Release** | Planned release outside the normal cycle for a specific need | High to Critical | Standard | Add the `Out-of-Schedule_Release` label |
| **Hotfix Release** | Urgent, unplanned, fixes critical issues or production bugs | High to Critical | Emergency | |

- Attach the Release Notes link in the **Azure Devops - Release Notes** field.
- A screenshot of the **completed and approved PR** must be in the description, one per PR.
- After sending the ticket through the MHD portal, open the created Jira ticket and add a
  **Post Deployment Tester**.
- The **planned end date must be on or before the release date**.
- Link the User Stories / Production Support / Bug tickets with test evidence comments so the
  approvers can check them.
- A ticket must be approved and moved to `Awaiting Implementation` before it can be released.
- **The cutoff for MHD tickets is the Wednesday before the release** (release is the Tuesday of
  the following week).
- **DO NOT reuse MHD tickets.** New item or feature means a new MHD ticket.

## Pre-release

**Release board.** Once the MHD ticket is in `Awaiting Implementation`, the automated RB ticket
can be lined up in the corresponding Release Sprint on the RB board
(`moneyme1.atlassian.net/jira/software/c/projects/RB/boards/81/backlog`).

For Out of Schedule or Hotfix releases the PM/SM must give the Release team: target release
date; major or minor release; reason; and the release planning meeting/channel or documentation
link.

**Weekly meeting** between PM/SM and Release teams. For projects or major releases with multiple
release dates, discussion in the weekly meeting is mandatory, and tickets for the next release
must be discussed and scheduled first.

**Pre-release email.** On the cutoff day the release team sends a Slack reminder of the
deadline. After cutoff they check each ticket for completeness and approval; incomplete tickets
are **removed from the list** and the PM/SM is told. If everything is complete a Pre-Release
email goes to the tech, product, ops and marketing teams.

## Release

The release manager releases the tickets on the pre-release list. Hotfixes and Out of Schedule
releases can go out even if not on the list. With many items, expect the release to carry over
across days.

## Post-release

**Post-deployment testing.** The release manager or SM moves the MHD ticket to
`Post-Deployment Testing`. QA then tests:

- Success → QA moves it to `Post-Deployment Testing Successful`.
- Failure → QA moves it to `Post-Deployment Testing Failed`, and a rollback or redeployment must
  be done.
  - Rollback: move the MHD to `Rollback In Progress`; once done QA does rollback testing.
    Success → `Rollback Done`. Failure → the team assesses whether a fix or redeployment is
    needed.
  - Redeployment: if the fix can be done the same day, move the MHD to `Implementing`, retest on
    redeployment, then continue to `Deployment Completed`. If not same day, move the MHD to
    `Implementing` and clone the ticket, **adding [Redeployment] to the title**. The new MHD
    ticket gets an automated RB ticket which must be lined up for release again.

Once QA is done, the SM or PM moves the MHD ticket to `Deployment Completed`. **Before** doing
so, the SM/PM must comment whether a PIR document is needed; if so it must be attached.

**Post-release email.** After a release cycle the release team emails the list of everything
released, to notify the business.

## Links

- Release board: https://moneyme1.atlassian.net/jira/software/c/projects/RB/boards/81/backlog
- RB release notes: https://moneyme1.atlassian.net/projects/RB (Releases page)
- MHD ticket creation guidelines: Helpdesk Ticket Process, TPM space page 889978981
- Lucid board tracking Out of Schedule and Hotfix releases: Lucidspark
  `ded4931b-5944-431d-83ca-aaf366f956c5`

## Earlier version, Release Process (page 995033259, 30 Jul 2025)

Same shape with fewer controls. Differences worth noting: it has no weekly PM/SM meeting, no
once a week cap on out of schedule releases, no PR screenshot requirement, and no explicit
rollback status path (`Rollback In Progress` / `Rollback Done`). Out-of-Schedule tickets needed
target release date, major/minor, reason and the planning link; Hotfix tickets needed target
release date and reason. Use the New Release Process page as the current source.

---
