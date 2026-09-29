# Contributing

How to add to and maintain this knowledge base without leaking customer data or letting it rot.

## What must never be committed

| Never | Instead |
| --- | --- |
| Customer names, email addresses, phone numbers, residential addresses | "the customer", "the broker", `<EMAIL>`, `0400000000` |
| Credentials of any kind: passwords, hashes (even encrypted), API keys, tokens, connection strings, basic auth | `[CREDENTIAL REDACTED]`. Report the source to security |
| Real customer statements, SOAs, contracts, screenshots with personal data | Describe the finding; reference the application ID |
| Staff health or personal matters | Leave out |

Allowed: Horizon application, loan, customer and transaction IDs as worked examples; table, column and procedure names; internal URLs; MoneyMe staff names; Jira keys; Confluence page ids.

The repository must stay **private**.

## Before every commit

```bash
python3 tools/check.py
```

It fails on: broken relative links, em dashes, non-MoneyMe email addresses, Australian mobile numbers other than `0400000000`, and common credential patterns. Fix what it reports. If it flags something legitimate, adjust the allowlist in the script and say why in the commit message.

## Writing a new page

- H1, one line on what it covers, `Last reviewed: <date>`, `Sources: <where it came from>`.
- Source every non-obvious fact inline.
- Label anything inferred `Unverified:` and say what would confirm it.
- If sources disagree, show both.
- Concise. Assume the reader knows SQL, Jira and support work.
- No em dashes. Australian spelling in prose; system spellings exact.
- Blank line after every heading and before every list.

## Where things go

| New content | Folder |
| --- | --- |
| A new symptom or fix | `docs/02-runbooks/`, and add a row to the router in `docs/02-runbooks/README.md` |
| A ruling from a product owner | `docs/05-knowledge/rusty-rulings.md` or `working-as-designed.md`, dated, quoted, with a permalink |
| A datafix script worth reusing | `docs/04-sql/datafix-templates/<MHD-key>-<slug>.sql`, meeting the contract in `docs/04-sql/README.md` |
| A resolved ticket worth remembering | A row in `docs/06-reference/mhd-precedent-index.md` |
| An incident | `docs/05-knowledge/incident-log.md` |
| Something broken with no fix | `docs/07-open-items/open-defects-and-risks.md` |

## Refreshing from Confluence

The files in `docs/06-reference/confluence-mirror/` and the four Confluence-derived files in `docs/04-sql/` are snapshots dated 23 September 2026. Confluence remains the place those pages are edited. Do not set up an automated sync until the four pages publishing credentials are cleaned (see `docs/07-open-items/security-findings.md`): a sync would copy them in.

## Review cadence

Monthly, alongside the datafix umbrella ticket:

1. Move resolved items out of `docs/07-open-items/`.
2. Add the month's notable tickets to the precedent index.
3. Update `Last reviewed` on anything you touched.
