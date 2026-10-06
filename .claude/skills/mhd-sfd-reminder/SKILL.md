---
name: mhd-sfd-reminder
description: 'Draft the monthly "MHD - Selected for Development Tickets" reminder email for High and Critical urgency tickets in Jira filter 10859. Use when Ron asks for the SfD reminder, the monthly dev/product chaser, or when the scheduled reminder task fires.'
---

# Monthly MHD Selected for Development reminder

Source of truth: `docs/03-procedures/monthly-sfd-reminder-email.md` (recipients, format rules, Outlook quirks, previous run notes). Read it every run; the recipient list and team labels live there.

A scheduled task already drafts this on the target day (trigger `trig_011C93cEWjLeQ8nAvZ2nPxvB`). Do not create a second schedule.

## 1. Date gate (scheduled runs only)

Target is the 29th, or the last weekday before it; in a month with no 29th, the last weekday on or before the month's last day. If today is not the target day, stop quietly.

## 2. Pull the tickets

`searchJiraIssuesUsingJql`: `filter = 10859 AND Urgency in (High, Critical)`, fields summary, created, status, urgency, description. Also a count of the whole filter (`filter = 10859`, `searchResultMode: "count"` or page through). **Never use Priority**: every ticket in this filter is Priority Low.

## 3. Compare with last month

Find the previous reminder's ticket list (the procedure's run notes, or Ron's sent email). Mark repeats. Note anything that dropped out and ask Ron to confirm it was delivered rather than re-statused.

## 4. Draft

- Subject: `MHD - Selected for Development Tickets - <Month> <Year>`
- "Hi Team," then the standing intro about Product Owners and Scrum Masters.
- One sentence naming the repeats, asking for an update or target sprint (omit if no prior email).
- Bold "Tickets Marked as HIGH URGENCY" (and a Critical heading if any).
- Per ticket: Team (carried forward from last month; flag new ones), Raised (date and age in months), two to four plain bullets, bold full browse URL.
- "Here" link to filter 10859 plus the total count.
- "Please let us know if you have any questions. Thank you!" / "Kind Regards, App Support Team".

Rules: no deadlines or reply-by dates (a vendor's published cut-off is a fact and may be stated); no em dashes; plain language, no template IDs or code.

## 5. Put it in Outlook as a draft, never send

Via Claude in Chrome into Outlook Web, following the five quirks in the procedure (Cc via the field, retype To so names resolve, confirm `aria-label` before typing, insert body with `execCommand('insertHTML')` plus an `input` event). If the browser is not available, give Ron the subject, To, Cc and body ready to paste. Ron adds his signature and sends.

## 6. Record

Offer to append this month's run notes (counts, tickets, repeats, drop-outs) to the procedure doc via a PR.
