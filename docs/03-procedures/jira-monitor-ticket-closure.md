# Closing MHD monitor up/down tickets

SOP for bulk-closing the UptimeRobot "Monitor is UP / DOWN" tickets that land in MHD, via the Jira MCP connector.

Last reviewed: 23 September 2026

Sources: App Support SOP, owner Ron Magpusao (project doc `claude/jira-monitor-ticket-closure-sop.md`), reproduced verbatim with light editing for repo fit; batch history from the 11 and 22 September 2026 runs.

Applies to the MHD project ("MME Help Desk" service desk) via the Jira MCP connector.

## Reference IDs

| Item | Value |
|---|---|
| Cloud ID | `moneyme1.atlassian.net` |
| Saved filter for the queue | `10591` (JQL: `filter = 10591`) |
| Assignee accountId (Ron) | `712020:f074c2f2-eb08-4745-8fcf-b20cf87dabe5` |
| Transition: Completed | `41` |
| Transition: Closed | `71` |
| Resolution | `{"id": "10000"}` |
| Request Type field | `customfield_10010` |
| Request Type: "I need help with something else..." | `81` (allows Completed) |
| Request Type: "Emailed Request" | `106` (blocks Completed) |
| Status: Waiting for Support | `10001` |
| Status: Completed | `10011` |
| Status: Closed | `6` |

Repo note: the connector accepts the site hostname as the Cloud ID. The underlying site cloudId is `d9911a71-58c8-4d3c-a772-0f89702b5921` (`harvest/jira-raw-notes.md`), should a tool insist on the GUID.

## Standard monitor tickets

Summary matches "Monitor is UP: Web - X" or "Monitor is DOWN: Web - X".

1. Transition to Completed (`41`) with the comment folded into the same call via `update.comment`, plus `fields.assignee.accountId` and `fields.resolution.id "10000"`. Comment text, exactly once: "We can now close this ticket since the website is already up and running."
2. Transition to Closed (`71`) as a separate call. No fields or update needed.

Never post the comment via a separate `addCommentToJiraIssue` call as well as the transition. It must appear exactly once.

### Comment body must be ADF

`transitionJiraIssue` rejects a plain string in `update.comment` with "Operation value must be an Atlassian Document". Nothing is written when it fails, so it is safe to retry. Use this shape:

```json
{
  "update": {
    "comment": [
      { "add": { "body": {
        "type": "doc",
        "version": 1,
        "content": [
          { "type": "paragraph", "content": [
            { "type": "text", "text": "We can now close this ticket since the website is already up and running." }
          ]}
        ]
      }}}
    ]
  }
}
```

`addCommentToJiraIssue` accepts markdown, but `transitionJiraIssue` does not.

### Before applying the standard comment

Confirm every DOWN ticket in the batch has a matching UP for the same monitor. The comment asserts the site is back up, so it is only accurate if the recovery alert exists.

### Batch execution note

Each transition call returns the whole issue, including the very large UptimeRobot email body in `description`. For batches above about six tickets, delegate the transitions to a subagent so that output stays out of the main context, then verify independently by re-querying the filter with `fields: ["status"]`.

## Blocked transitions

If Completed is rejected because Request Type is "Emailed Request" (`106`), fix it first, then retry:

```json
{
  "cloudId": "moneyme1.atlassian.net",
  "issueIdOrKey": "MHD-XXXXX",
  "fields": { "customfield_10010": "81" }
}
```

`customfield_10010` takes a plain string, not an object.

## Non-standard tickets

SSL certificate expiry warnings, domain expiry notices, anything that is not the generic "website is up" pattern: do not apply the generic comment. Check the comments, creation date and the real status of the underlying issue, write a tailored and factually accurate closing comment, and ask before closing.

## History

- 11 Sep 2026: 75 tickets closed across six batches. Left open at Ron's request: MHD-35599 and MHD-35385 (SSL certs, created 12 Aug and 6 Aug 2026).
- 22 Sep 2026: 18 tickets closed from filter 10591 (MHD-36875, 36874, 36871, 36870, 36866, 36865, 36864, 36863, 36862, 36861, 36831, 36830, 36829, 36828, 36826, 36825, 36821, 36820). Running total: 93.

## Related

- Where these alerts come from (Uptime Robot, Confluence 1409351830): [`sentry-and-error-triage.md`](sentry-and-error-triage.md)
- MHD statuses, resolutions and the automation cycle: [`jira-conventions.md`](jira-conventions.md)
