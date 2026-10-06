---
name: mhd-issue-intake
description: 'Triage a new App Support issue from #app-support (or a portal ticket) and turn it into a well-formed MHD Problem. Use when Ron pastes a Slack thread or link, says "pick this up", "triage this", "create a ticket for this", or asks whether something is a bug.'
---

# MHD issue intake and triage

Sources of truth: `docs/03-procedures/issue-intake-and-triage.md`, the symptom router `docs/02-runbooks/README.md`, precedent `docs/06-reference/mhd-precedent-index.md`, rulings `docs/05-knowledge/working-as-designed.md` and `docs/05-knowledge/rusty-rulings.md`, Jira shape `docs/03-procedures/jira-conventions.md` sections 9 and 10.

## 1. Read the report

- Slack: `slack_read_thread` on the `#app-support` message (`GG7HL6CTE`). Pull out the reporter, the Horizon deep link and the application ID, any deadline, and whether they said it is urgent or affects multiple users.
- Note: the bot acknowledgement is not a pickup. Pickup is Ron replying or the `#app-support-issue-alerts` post.

## 2. Is information missing?

If there is no application ID, no screenshot, or no description of expected versus actual, draft the Ticket Handling Manual request (section 3 of the procedure) for Ron to post. Do not guess IDs.

## 3. Filter before investigating

Answer the four triage questions: known incident already handled, hotfix or deployment side effect, expected behaviour, misrouted. Check `working-as-designed.md` and the precedent index for the same symptom. Check `#solutions_memorandum` standing instructions where relevant (CRD refunds, SOA generation).

## 4. Route

Match the symptom in `docs/02-runbooks/README.md` and open that runbook. Follow its triage order. Where a datafix is the fix, hand to the `mhd-datafix-request` skill. Where it is a funding or refund queue item, the `funding-checks-triage` or `refund-support-triage` agent can do the read-heavy part.

## 5. Set urgency (not Priority)

Use the reporter's declaration. Always urgent: direct debit issues; anything that can move money to the wrong place (dealer lead source updates, bank details). SLAs: Critical 4h/6h, High 6h/8h, Medium 40h/48h, Low 240h.

## 6. Draft the MHD Problem

Show Ron the draft before creating anything:

- Summary with the product prefix (`APY`, `PL`, `CRD`, `SPL`, ...) and the app ID; the summary is the only field that separates a one-customer issue from a mass event, so make it specific.
- Description: what was reported, the Horizon link, the Slack permalink.
- Urgency per step 5. Leave Priority alone.

On approval, `createJiraIssue` (project MHD, issue type Problem `10130`), assign to Ron, move to WORK IN PROGRESS.

## 7. Investigation note

When there is a finding, write it in the house structure (`jira-conventions.md` section 10): verdict first line, account facts, timeline table, root cause with arithmetic, customer impact, ruled out, precedent, recommended action. Post it **internal** (`commentVisibility` role `Service Desk Team`) and remind Ron to eyeball it in the UI because the API reports `jsdPublic: true` regardless. Add "Investigated by Claude agent". A separate plain-language public comment goes to the reporter.

## 8. Out of scope

Escalate per the destinations table in the procedure (section 7). Raise or link the ticket in the owning project and set Pending or Selected for Development. When the reporter confirms a fix, close with `mhd-ticket-closure`.
