# Start here

For anyone new to MoneyMe App Support, or covering while the usual engineer is away. Read this page, then keep the symptom router open.

Last reviewed: 23 September 2026
Sources: App Support Cover Runbook (Confluence AS 3131015188), BAU Task Handover (Confluence page 36 in the mirror), team procedures (Slack), MHD workflow notes

## What App Support does

Triage and resolve issues raised by internal staff (Operations, Collections, Underwriting, brokers and partners) about the Horizon loan platform, its payments and its customer comms. Most work arrives in `#app-support` and becomes an MHD ticket in Jira.

The recurring work, roughly by volume:

- Production datafixes via `#datascript-requests` (about 70 a month, under a monthly umbrella ticket).
- Funding and disbursement problems (`#pending-funding-checks`).
- Payment, direct debit and dishonour issues.
- Email (SendGrid) and SMS (Twilio) delivery failures.
- Customer login, passcode reset and account unblock (`#unblock-account-request`, G3APIBot).
- SOA generation failures.
- Refunds (`#refund-supports`).
- Monitor up/down and Sentry/Uptrace alerts.

## Your first day

1. Confirm access: Horizon (`https://horizon.moneyme.com.au`), Jira MHD, Confluence space `AS`, SendGrid, Twilio, Zepto portal, Sentry/Uptrace, the Slack channels below. See [../05-knowledge/escalation-map.md](../05-knowledge/escalation-map.md) for who grants what.
2. Join the channels: `#app-support`, `#app-support-issue-alerts`, `#app-support-sentry-error-logs`, `#datascript-requests`, `#pending-funding-checks`, `#refund-supports`, `#unblock-account-request`, `#autopay_feedback`, `#solutions_memorandum`.
3. Read, in this order:
   1. [investigation-method.md](investigation-method.md): how to investigate and how to write back.
   2. [../02-runbooks/README.md](../02-runbooks/README.md): the symptom router.
   3. [../05-knowledge/README.md](../05-knowledge/README.md): the ten rules to memorise.
   4. [../04-sql/README.md](../04-sql/README.md): the datafix safety contract.
   5. [../03-procedures/README.md](../03-procedures/README.md): the daily loop.

## Golden rules

1. **Nothing runs in production by your own hand.** Scripts go through `#datascript-requests`.
2. **Check it is a datafix at all** before writing one. Many requests are config, a UI action, or a defect that needs a dev fix.
3. **Stored procedure first, raw script second.** Read the procedure's warnings before running it.
4. **Search MHD precedent before concluding.** [../06-reference/mhd-precedent-index.md](../06-reference/mhd-precedent-index.md).
5. **Check [working-as-designed](../05-knowledge/working-as-designed.md)** before raising a Problem.
6. **Direct debit issues are always urgent.**
7. **Ask before posting to Jira or Slack on someone else's behalf.** Draft first.
8. **Replies to reporters are plain language.** No template IDs, API names, table names or code.
9. **Flag a ticket whose priority looks wrong for its risk.** Priority in MHD defaults to Low; say so on the ticket when a customer is out of pocket or a complaint is open.
10. **Never paste customer names, emails, phone numbers or addresses into Slack or this repo.** IDs are fine.

## Where things are in this repo

| Folder | Open it when |
| --- | --- |
| [01-systems](../01-systems/README.md) | You need to know how Horizon, the database, payment rails or comms actually work |
| [02-runbooks](../02-runbooks/README.md) | A ticket has landed |
| [03-procedures](../03-procedures/README.md) | You need to do a standard task: datafix request, funding check, unblock, refund, Jira hygiene, release/UAT |
| [04-sql](../04-sql/README.md) | You need a lookup, a stored procedure or a datafix script |
| [05-knowledge](../05-knowledge/README.md) | You need a ruling, a timing, an owner or an incident |
| [06-reference](../06-reference/README.md) | You need precedent, statistics, Confluence content or the SOA format |
| [07-open-items](../07-open-items/README.md) | You want to know what is broken and not yet fixed |
