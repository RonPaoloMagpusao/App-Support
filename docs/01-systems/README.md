# 01 Systems

Index of the systems reference: what each file in this folder covers and where to look for a given fact.

Last reviewed: 23 September 2026

Sources: this folder's own files, which were compiled from [01-systems/README.md](README.md), [06-reference/confluence-mirror/README.md](../06-reference/confluence-mirror/README.md), [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md), [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md), [03-procedures/README.md](../03-procedures/README.md) and [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) in the September 2026 harvest.

## Files

| File | Covers |
| --- | --- |
| [`horizon.md`](horizon.md) | What Horizon is, its age (.NET Framework 4.6.1), the modules App Support touches, URL paths that identify a record, the full status and stage registers, what each stage does operationally, the permissions model |
| [`horizon-database.md`](horizon-database.md) | `Horizon2`, `Payment` and `Communication` tables we touch, key columns, the reference value tables (transaction types and statuses, funding statuses, task types, workflow ids), UI id to DB id mapping, stored procedure families, spellings that trip people up |
| [`payments-and-rails.md`](payments-and-rails.md) | Zepto, Split, Split Sched, Ezidebit, Direct Credit, Direct Debit, Stripe / Debit Card Sched, PayAnyone, NPP and EFT, card channels, E6. Timings, failure modes, error strings, funding flow and retry semantics |
| [`communications.md`](communications.md) | Comms API, templates, `CommsMuteRule` and `usp_CanCustomerBeContacted`, SendGrid, Twilio (SMS, voice, OTP), Braze, tracing one message end to end |
| [`monitoring.md`](monitoring.md) | Sentry (being retired), Uptrace, Uptime Robot, Application Insights, FullStory, and the Slack bot feeds |
| [`brands-products-entities.md`](brands-products-entities.md) | BrandIds, products (PL, SPL, UPL, APY, CRD, LOC, Freestyle, SACC), which product uses which rail, Jira project keys, SPV and trust entities |
| [`environments-and-urls.md`](environments-and-urls.md) | Production, QA and integration URLs, internal API base URLs, Azure resources, third party consoles, Jira, Confluence and Slack coordinates |

## If you are looking for X, go to Y

| Looking for | Go to |
| --- | --- |
| What a StageId or StatusId means | `horizon.md`, stage and status registers |
| Why an app is "stuck at Signed Off" | `payments-and-rails.md`, funding flow; then `horizon.md`, stage 39 |
| Whether a stage pauses interest or cancels payments | `horizon.md`, post-funding register |
| Which tab id or role grants a permission | `horizon.md`, permissions model |
| A table's columns or purpose | `horizon-database.md`, tables are headings |
| What `TransactionTypeId 87` or `TransactionStatusId 1005` is | `horizon-database.md`, reference values |
| What funding status `91001`, `91004`, `91005` or `91007` does | `horizon-database.md` and `payments-and-rails.md` |
| Which id in a Horizon URL is which | `horizon-database.md`, UI to DB mapping |
| `Amortization`, `WrittenOfRemainingPrincipalBalance` and other odd spellings | `horizon-database.md`, spellings |
| A funding or Split error string | `payments-and-rails.md`, error strings and Split tasks |
| Split Sched timing, Zepto response time, NPP bounce-back | `payments-and-rails.md`, timing tables |
| Whether a payment behaviour is by design | `payments-and-rails.md`, working as designed |
| Why an email or SMS was not delivered | `communications.md`, end-to-end trace |
| Who may clear a SendGrid suppression | `communications.md`. The sources contradict each other |
| Twilio inbound, campaign or agent disconnect issues | `communications.md`, Twilio |
| What a Sentry alert means and who owns it | `monitoring.md`, Sentry routing table |
| Whether a service is on Sentry or Uptrace | `monitoring.md` |
| A BrandId, or which brand a product belongs to | `brands-products-entities.md` |
| Which rail a product uses | `brands-products-entities.md`, product to rail table |
| What AMZ, COL, CL or CRD mean as Jira keys | `brands-products-entities.md` |
| SPV, Spv12 or trust entities | `brands-products-entities.md`. Largely undocumented |
| Which Horizon host to use | `environments-and-urls.md`. The sources disagree |
| A QA URL or Azure resource | `environments-and-urls.md` |
| A Slack channel id or Jira queue | `environments-and-urls.md` |

## Conventions in this folder

- Every non-obvious fact carries its source inline: a Jira key, a Confluence page id, or a Slack channel and date.
- `Unverified:` marks anything inferred or not stated in a source, with what would confirm it.
- Contradictions between sources are shown with both readings. None has been silently resolved.
- No credential appears anywhere. Pages that publish them are named in `[CREDENTIAL REDACTED - Confluence page <id>]` markers.
- Customer names, emails, phone numbers and addresses are stripped. Application, customer and transaction ids are kept as worked examples.

## Open questions carried by this folder

| Question | File |
| --- | --- |
| Canonical production Horizon host: `horizon`, `horizon4` or `horizon-az` | `environments-and-urls.md` |
| Whether App Support can now remove SendGrid suppressions directly | `communications.md` |
| SocietyOne funding contact rows: BrandId 5 or 6 | `brands-products-entities.md` |
| Freestyle virtual cards: EML or E6 | `brands-products-entities.md` |
| Spv12 and the trust entity list | `brands-products-entities.md` |
| Which Sentry projects still receive events | `monitoring.md` |
| `TransactionStatusId 1003` label and the ids for Proposed, Pending, Authorised, Rejected | `horizon-database.md` |
| Special Handling StageId | `horizon.md` |
| `CommsMuteRule` evaluation order (page says ascending priority, query sorts descending) | `communications.md` |
| Production internal API base URLs | `environments-and-urls.md` |
