# Monthly MHD Selected for Development reminder email

SOP for the monthly email that chases dev and product on High and Critical urgency tickets sitting in MHD Selected for Development.

Last reviewed: 23 September 2026

Sources: App Support SOP, owner Ron Magpusao (project doc `claude/mhd-selected-for-development-email-sop.md`), reproduced verbatim with light editing for repo fit; Jira filter 10859; September 2026 run notes.

Owner: Ron Magpusao, App Support. Automated by the scheduled task "MHD Selected for Development monthly reminder draft" (trigger id `trig_011C93cEWjLeQ8nAvZ2nPxvB`).

## Purpose

Monthly email to the dev and product teams summarising the High and Critical urgency tickets sitting in MHD Selected for Development, so Product Owners and Scrum Masters either action them or plan the fix.

## Schedule

- Runs on the 29th of the month at 8:00 AM Manila time.
- If the 29th is a weekend, it runs on the last weekday before it.
- If the month has no 29th (February), it targets the last day of the month, then walks back to the last weekday.
- Underlying schedule fires on the 26th, 27th, 28th and 29th; a date gate in the task prompt lets only the correct day through.
- September 2026 was deliberately skipped. First live run: Thu 29 Oct 2026.

Upcoming target days: 29 Oct 2026, 27 Nov 2026, 29 Dec 2026, 29 Jan 2027, 26 Feb 2027, 29 Mar 2027.

## Source of truth

Jira filter 10859, "[BAU] Selected for Development": https://moneyme1.atlassian.net/issues/?filter=10859

Query for the email content: `filter = 10859 AND Urgency in (High, Critical)`

Use the custom Urgency field, never Jira Priority. Every ticket in this filter carries Priority = Low regardless of real urgency, so sorting or filtering by Priority is meaningless here. This is a field hygiene problem worth fixing in the MHD scheme: anyone outside App Support who sorts by Priority sees the whole list as bottom of the backlog.

Repo note: the same pattern holds across MHD Problems generally, not just this filter. See [`jira-conventions.md`](jira-conventions.md) section 3 and [`issue-intake-and-triage.md`](issue-intake-and-triage.md) section 4.

## Recipients

To (13): aina.dilao, dominic.sicat, alyssa.ventura, jossalyn.capule, ann.cordero, cto, jonathan, product-team, ricky, christopher.enriquez, lary, albert.martires, rogelio (all @moneyme.com.au)

Cc (2): michael.delatorre@moneyme.com.au, julius@moneyme.com.au

## Email format

Subject: `MHD - Selected for Development Tickets - <Month> <Year>` (dating the subject stops Outlook threading every month's reminder together)

Body:

1. "Hi Team," then the standing intro paragraph about Product Owners and Scrum Masters being aware of the items.
2. A sentence naming which items are repeats from the previous reminder, and asking for an update or target sprint. Omit if there is no prior email to compare against.
3. Bold heading "Tickets Marked as HIGH URGENCY".
4. Numbered entry per ticket, each with: Team, Raised (date plus age in months), Description as two to four plain bullets, and the full browse URL as a bold link.
5. Link to the full filter as "Here", plus the total count in Selected for Development.
6. "Please let us know if you have any questions. Thank you!" then "Kind Regards, App Support Team".

Rules:

- No deadlines or reply-by dates. Ask for an update, a target sprint or a confirmed schedule with no date attached. A vendor's own published cut-off (for example Microsoft ending Azure Functions in-process support on 10 November 2026) is a fact and may be stated.
- No em dashes.
- Plain language, no template IDs, no API or code detail.
- Team labels are not in Jira; components are empty on these tickets. Carry the label forward from the previous reminder, and flag any newly assigned label for correction.

## Drafting in Outlook Web, known quirks

The task drafts via Claude in Chrome into Outlook Web and never sends. Ron reviews and sends.

1. The `deeplink/compose` URL does not populate Cc. Click into the Cc field, confirm `document.activeElement` has `aria-label="Cc"`, then type the addresses separated by semicolons.
2. Addresses passed in the deeplink arrive as unresolved raw text, which collapses the To field and makes recipients look missing. Clear the To field with repeated Backspace and retype all 13 with semicolons so Outlook resolves them to display names.
3. Always confirm `document.activeElement` has `aria-label="Subject"` before typing the subject. Without the check the text lands in the message body.
4. Insert the body by focusing the `aria-label="Message body"` div, selecting its contents with a Range, then `document.execCommand('insertHTML', ...)` and dispatching an `input` event. Setting innerHTML alone does not register with the editor.
5. Ron's signature is not included, because the body is inserted directly. Add it by hand before sending.

## September 2026 run notes

- 3 High urgency tickets, 0 Critical, out of 40 in Selected for Development.
- MHD-30782, No option to apply CRD (API), raised 27 Feb 2026.
- MHD-25824, Slow processing in workflow queue (Horizon), raised 29 Jul 2025.
- MHD-14444, Azure Functions isolated worker migration (DevOps), raised 26 Mar 2024. Logged as a Feature Request, which will lose triage against defects despite the hard Microsoft cut-off. Worth changing the issue type and urgency.
- All three also appeared in the June 2026 reminder. MHD-26341, Cash Flow Report for SPV15, dropped out of the filter since June; confirm it was delivered rather than just re-statused.

## Related

- MHD statuses including Selected for Development (10032): [`jira-conventions.md`](jira-conventions.md)
- Urgency SLAs: [`issue-intake-and-triage.md`](issue-intake-and-triage.md)
- Open follow-ups from the run notes (MHD-14444 issue type, MHD-26341 delivery check): [`../07-open-items/`](../07-open-items/)
