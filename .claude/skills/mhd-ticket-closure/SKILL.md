---
name: mhd-ticket-closure
description: 'Close MHD Jira tickets the App Support way. Use whenever Ron asks to close, complete, resolve or wrap up one or more MHD tickets (e.g. "close MHD-37037 and MHD-37031"). Updates the reporter first, moves to Completed, then always on to Closed.'
---

# MHD ticket closure

Source of truth: `docs/03-procedures/jira-monitor-ticket-closure.md`, section "Closing rule for every MHD ticket". Read it if anything below is unclear. Transition IDs, resolution IDs and comment-visibility rules: `docs/03-procedures/jira-conventions.md`.

Cloud ID: `moneyme1.atlassian.net`. Ron's accountId: `712020:f074c2f2-eb08-4745-8fcf-b20cf87dabe5`.

Ron naming the tickets is the go-ahead. Do not ask again per ticket, but stop and ask if a ticket looks wrong to close (see Stop conditions).

## For each ticket

1. **Read it.** `getJiraIssue` with `fields: ["summary","status","reporter","assignee","comment","resolution","issuetype"]`, `responseContentFormat: "markdown"`. Work out from the description and comments what was actually done.
2. **Post the update.**
   - **Reporter is not Ron:** public comment, ADF, opening with a `mention` node for the reporter (`attrs.id` = reporter accountId, `attrs.text` = `@<displayName>`). Say specifically what was done: the fix, the values changed, the account or application ID. Then "We'll be closing this ticket now." and "Please let us know if you need anything else. Thanks!" Use `addCommentToJiraIssue` with no `commentVisibility`.
   - **Reporter is Ron:** a one-line closing note on the outcome.
   - **Monitor up/down tickets:** use the standard comment from the SOP instead, folded into the Completed transition. For more than about six, use the `monitor-ticket-closer` agent.
   - Never claim something was done that the ticket does not show was done. If the fix is not evidenced (for example a datafix not yet confirmed as run), stop and ask.
3. **Move to Completed.** `getTransitionsForJiraIssue`, pick the transition whose target is Completed (`10011`). Seen: `191` from Scheduled on Problems, `41` on monitor tickets. Never hardcode.
4. **Move to Closed** (`71`) as a separate call. Never stop at Completed.
5. **Verify** with a fresh `getJiraIssue` on `status`.

## Stop conditions, ask Ron first

- The ticket is not assigned to Ron and is not obviously his to close.
- The latest comment is an open question from the reporter or someone else.
- The fix is not evidenced on the ticket.
- No transition to Completed or Closed is offered (report the transitions that are).
- It is the monthly `[App Support] Data Fix - YYYY-Mon` umbrella. That one is never closed by this skill.

## Report back

A table: ticket, summary, reporter, update posted (one line), final status. Mention anything skipped and why. If a resolution matters for reporting, note that the Completed transition was done without screen fields (resolution may be empty).
