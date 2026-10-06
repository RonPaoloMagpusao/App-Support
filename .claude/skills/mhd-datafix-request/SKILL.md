---
name: mhd-datafix-request
description: 'End-to-end App Support datafix for Horizon2. Use whenever Ron asks for a SQL data-fix script, wants a fix run in prod, or asks to request a datafix in #datascript-requests. Writes the script, runs the Jira steps (request ticket comment, monthly umbrella comment, Blocks link, Scheduled), drafts the #datascript-requests post, and closes the request once the fix has run.'
---

# MHD datafix request

Sources of truth, read the relevant one when in doubt:

- Process and channel contract: `docs/03-procedures/datafix-request.md`
- Script safety contract and template: `docs/04-sql/README.md`, `docs/04-sql/script-template.sql`
- Prefer the `dbo.AppSupport_*` procedures: `docs/04-sql/stored-procedures.md`
- Routing and precedent scripts: `docs/04-sql/datafix-routing.md`, `docs/04-sql/datafix-templates/`

This skill supersedes the claude.ai `moneyme-datafix-sop` skill: same Steps 1 to 5, plus the Slack request and the close-out.

**Nothing runs in production by App Support's own hand.** You write the script; the SQL devs run it.

## Step 0: inputs

- The **request ticket** (MHD-XXXXX). Ask if not given; it drives the filename and backup table names.
- The **monthly umbrella** `[App Support] Data Fix - YYYY-Mon`. Find it: `project = MHD AND summary ~ "App Support Data Fix" ORDER BY created DESC`, or from the last request's links.
- Check the gates in `datafix-request.md` section 1: an **Incorrect URL ID Fix**, a stored procedure or schema change, or anything beyond one application needs the approval-heavy route (Jeffrey Lu and Jon Wu). Say so and stop.

## Step 1: write the script, `<TICKET>.sql`

Shape: backup, change, verify, inside a transaction on `Horizon2`. The SQL is different every time.

```sql
-- Ticket: MHD-XXXXX
-- <one-line description of the change>
USE Horizon2
BEGIN TRAN;

SELECT *, GETDATE() AS BackedUpAt
INTO dbo.<TableName>_MHDXXXXX FROM <TableName> WHERE <predicate>;   -- 1. Backup

-- 2. Update / Delete / Insert, whatever the fix requires

SELECT ... ;                                                          -- 3. Verify

COMMIT;
-- ROLLBACK;
```

- Backup table per written table: `<TableName>_<TicketNoHyphens>`.
- `COMMIT;` live, `-- ROLLBACK;` commented.
- Batches: load IDs into `#AppIds` and JOIN.
- Verify only the changed rows (join to the backup), with count assertions.
- UPDATE-only logic skips missing rows: add `INSERT ... WHERE NOT EXISTS` where the row may not exist.
- Flag any mismatch between the SELECT filter and the UPDATE/DELETE filter.
- DELETE hitting an FK: repoint the referencing column first; ask which record becomes the target.
- Landmine: `AppSupport_UpdateCustomerAccount` has no defaults and overwrites Username, Password, BrandId and IsActive together.
- Reversals need an amortisation counterpart (`datafix-request.md` section 8).
- Offer a read-only pre-check query for large or ambiguous changes, and a soft-execution variant for anything mutating many rows.

Save the `.sql` in the working directory or scratchpad, never in this repo (it carries customer IDs in context).

## Step 2: comment the script on the request ticket

Embed the file **in an internal note**, not the Attachments panel. The Claude in Chrome paste method (open "Add internal note", paste text, Enter, paste the file as a `File` in a `DataTransfer`, wait for `mediaInline`, Save) is the one that works; see the claude.ai `moneyme-datafix-sop` skill for the full mechanics. If the browser is not available, give Ron the file and say which step he needs to do by hand.

## Step 3: comment on the monthly umbrella

Text `Datafix # N`, file on the line below (`hardBreak` before the `mediaInline`). N = Ron's own last `Datafix # X` on that ticket + 1; ignore other people's comments.

## Step 4: link

`createIssueLink`, type `Blocks`, inwardIssue = umbrella, outwardIssue = request ("request is blocked by umbrella").

## Step 5: request ticket to Scheduled

Look the transition up (`171` on Problems, `201` seen on other types).

## Step 6: draft the #datascript-requests post

Channel `C02HB99AXDX`. Draft with `slack_send_message_draft` or show the text; **Ron sends it**. Template:

```
Hi @Victor Alvarez and @Krizza Rosales need your help running Data fix # {N}
in prod please. Please do not close the ticket. Thank you!
https://moneyme1.atlassian.net/browse/{umbrella key}
```

Variants (urgent, soft execution, long running, scheduled, backup-first) are in `datafix-request.md` section 4. Mark funding, payment, direct debit and dealer lead source fixes **Urgent**. Remind Ron of the SQL dev windows: Mon to Fri 12:00 to 13:00 and 16:00 to 17:00 Sydney time; after about 16:00 PH it slips a day.

## Step 7: after it has run

When Ron confirms the SQL dev has run it (or the dev confirms in channel), close the request ticket with the `mhd-ticket-closure` skill: update the reporter with what changed, Completed, then Closed. **Never close the umbrella.** If the dev reports an error, fix the script and re-request "Data fix # N again".

## Verify at the end

Re-read the request ticket's status, both comments (file embedded, number right) and the link.
