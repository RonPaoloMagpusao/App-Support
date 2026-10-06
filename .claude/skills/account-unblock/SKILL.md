---
name: account-unblock
description: 'Handle customer account unblock and passcode reset questions for #unblock-account-request and G3APIBot. Use when Ron asks about an unblock or reset, a customer is locked out after passcode attempts, or G3APIBot looks down.'
---

# Account unblock and passcode reset

Source of truth: `docs/03-procedures/account-unblock-and-reset.md`. Login fixes beyond the bot: `docs/02-runbooks/login-passcode-and-account-access.md`, `docs/04-sql/login-datafix-scripts.md`.

App Support monitors this channel; it does not work it. G3APIBot does the reset.

## Check a reset

1. `slack_read_channel` on `#unblock-account-request` (`C0B289B6DCL`), or search for the email.
2. A healthy reset is two bot posts with the same 4-hex job ref, 2 to 4 seconds apart: "Picking this up" then "Reset complete for `{email}`".
3. Report: requested by, job ref, completed or not, and whether the same email was reset repeatedly (repeats within minutes are normal and need no ticket).

## The command, if Ron wants one posted

`reset {customer email}`, nothing else. Draft it; Ron or the requester posts it.

## Bot looks down

Signs: a `reset` line with no "Picking this up" after a minute, or several in a row. **Do not retry the command.** Draft an escalation to the G3 team (Albert Rick Martires, Daryll Felipe) for Ron to send. If the customer is genuinely blocked meanwhile, the fallback is a login datafix: hand to `mhd-datafix-request`.

## Customer still cannot log in after "Reset complete"

That is not a bot problem. Triage with `mhd-issue-intake` and the login runbook (FullStory replay shows where they stopped).
