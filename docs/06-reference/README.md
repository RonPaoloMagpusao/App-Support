# Reference

Look-up material: MHD precedents and statistics, Confluence mirrors and index, the SOA format, and the limits of what this repo was built from.

Last reviewed: 23 September 2026
Sources: Jira MHD 2025-09-01 to 2026-09-23; Confluence moneyme1.atlassian.net; Slack; Claude project notes

## Files

| File | What it is | Use it when |
| --- | --- | --- |
| [mhd-precedent-index.md](mhd-precedent-index.md) | Greppable index of MHD tickets: symptom, root cause, resolution, related keys | Before concluding on any investigation. `grep -i "<symptom>"` it |
| [mhd-issue-catalogue.md](mhd-issue-catalogue.md) | The recurring themes with symptoms, confirmation, root causes, fixes and precedents | You want the full picture behind a runbook |
| [mhd-volume-stats.md](mhd-volume-stats.md) | Volumes by month, type, priority, theme, with counting caveats | Reporting, or arguing for a fix. Read the caveats first |
| [confluence-mirror/](confluence-mirror/README.md) | Markdown mirrors of 36 Confluence pages | Searching Confluence content offline or alongside the rest of the repo |
| [confluence-index.md](confluence-index.md) | Every relevant Confluence page, by space, with a verdict | Finding the live page |
| [slack-harvest-coverage.md](slack-harvest-coverage.md) | Which Slack channels, dates and searches the Slack-derived content came from | Judging how complete a Slack-derived section is |
| [soa/soa-format-spec.md](soa/soa-format-spec.md) | Layout spec for rebuilding a Horizon Statement of Account | An SOA will not generate and one has to be produced by hand |
| [soa/soa-template.html](soa/soa-template.html) | Print-ready HTML template matching the spec | As above |

## Coverage and limits

Read this before treating anything here as complete.

- **Jira:** 10,218 MHD issues in the window; 3,785 pulled and aggregated; about 45 read in full. Monthly, type and priority counts are exact; status, label and component breakdowns are sampled. `text ~` searches are stemmed and over-match.
- **Confluence:** 56 spaces listed. The App Support space is key `AS`, display name "Platform and Support". 36 pages mirrored in full. The `TECHNOLOGY` space enumeration timed out and was sampled by search only. Attachments, page comments and image-only pages were not harvested.
- **Slack:** eight App Support channels plus about 20 more surfaced by search, notably `#solutions_memorandum`. Around 750 messages inspected. Coverage is dense from May 2026 and sparse before; searches were not paginated beyond the first 20 results.
- **Claude project notes:** SOA format spec and template, datafix SOP, monitor ticket closure SOP, monthly Selected for Development email SOP, investigation handover.

Anything not in these sources is not in this repo. Where a section says `Unverified:`, it means exactly that.
