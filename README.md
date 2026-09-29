# MoneyMe App Support knowledge base

Everything the App Support team knows about keeping Horizon, its payments and its customer comms running: runbooks, procedures, SQL, product rulings and open risks, in one searchable place.

**Private and internal.** Contains Horizon IDs, table names and internal URLs. No customer names, contact details or credentials. See [CONTRIBUTING.md](CONTRIBUTING.md).

Last reviewed: 23 September 2026. Maintainer: Ron Magpusao, App Support.

## Start here

| If you... | Go to |
| --- | --- |
| are new, or covering for someone | [docs/00-start-here](docs/00-start-here/README.md) |
| have a ticket in front of you | [docs/02-runbooks](docs/02-runbooks/README.md), the symptom router |
| need to write or request a datafix | [docs/04-sql](docs/04-sql/README.md) and [docs/03-procedures/datafix-request.md](docs/03-procedures/datafix-request.md) |
| want to know whether something is a bug | [docs/05-knowledge/working-as-designed.md](docs/05-knowledge/working-as-designed.md) and [docs/05-knowledge/rusty-rulings.md](docs/05-knowledge/rusty-rulings.md) |
| need precedent | [docs/06-reference/mhd-precedent-index.md](docs/06-reference/mhd-precedent-index.md) |
| want to know what is broken right now | [docs/07-open-items](docs/07-open-items/README.md) |

## Layout

```
docs/
  00-start-here/   onboarding, golden rules, investigation method
  01-systems/      Horizon, Horizon2 database, payment rails, comms, monitoring, brands, environments
  02-runbooks/     symptom-first runbooks, one per issue family, plus the symptom router
  03-procedures/   how the team works: intake, datafix requests, funding checks, unblock,
                   refunds, Sentry, Jira conventions, monitor ticket closure, monthly SFD email,
                   release and UAT
  04-sql/          safety contract, stored procedures, routing, legacy catalogue, template,
                   diagnostics, reference datafix
  05-knowledge/    Rusty's rulings, working-as-designed register, tribal knowledge, timings,
                   escalation map, incident log
  06-reference/    MHD precedent index, issue catalogue and stats, Confluence mirror and index,
                   Slack coverage, SOA format spec and template
  07-open-items/   open defects and risks, security findings, documentation gaps,
                   investigations in flight
```

## Where this came from

Sources captured 23 September 2026, published 29 September 2026:

- **Jira MHD**, 1 September 2025 to 23 September 2026: 10,218 issues, 579 cited.
- **Confluence**, the `AS` (Platform and Support) space and adjacent `HOR`, `TO`, `TS`, `OP` spaces: 36 pages mirrored, about 550 inventoried.
- **Slack**, `#app-support` and seven related channels plus `#solutions_memorandum`: about 750 messages, including roughly 45 dated rulings from Joshua (Rusty) Allen.
- **Ron's working notes**: SOA format spec, SOPs, investigation handover.

Coverage limits are stated in [docs/06-reference/README.md](docs/06-reference/README.md#coverage-and-limits). Anything marked `Unverified:` is exactly that.

## Conventions

- Every non-obvious fact carries its source inline: `(MHD-35706)`, `(Confluence 3117842457)`, `(#app-support, 2026-06-05)`.
- Where sources contradict, both readings are shown.
- Australian spelling in prose. System names keep their own spelling: the table is `Amortization`.
- No em dashes.

## Keeping it current

See [CONTRIBUTING.md](CONTRIBUTING.md). Run `python3 tools/check.py` before every commit.
