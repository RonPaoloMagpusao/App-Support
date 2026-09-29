# G3APIBot: How to Teach the Bot New Facts

Mirror of the Confluence page "G3APIBot: How to Teach the Bot New Facts".

Last reviewed: 23 September 2026
Sources: Confluence TECHNOLOGY page 2994733113, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: TECHNOLOGY · Page id: 2994733113 · Last updated: 5 Jul 2026 · Author: Daryll Felipe
- URL: https://moneyme1.atlassian.net/wiki/spaces/TECHNOLOGY/pages/2994733113/G3APIBot+How+to+Teach+the+Bot+New+Facts

G3APIBot is the Slack bot App Support uses for account unblocks and resets in
`#unblock-account-request`. It also answers data questions, and it learns permanently: a fact
taught once is answered forever, for everyone.

## 1. `remember:`, plain language

@mention the bot, start with `remember:`, and state the fact:

> `@G3APIBot remember: soc1 apps are checked by application brand, brand table, BrandId 6`

The bot dissects the sentence into facts and replies with exactly what it learned, one line per
fact. If an extraction came out wrong, retract with `forget: <term>` and re-teach.

**Power user shapes (instant, no AI parsing):**
- `remember: <term> = <value>`, e.g. `remember: funded = StatusId 7`
- `remember: <entity> is deprecated <reason>`
- `forget: <entity>`

Tips for facts that retrieve well:
- Pack aliases in: `soc1 / soc 1 / SocietyOne`. The bot matches the names people actually type.
- Include concrete IDs and tables (`BrandId 6`, `dbo.Application`, `StatusId 7`). The bot
  verifies values against live lookups before asserting them.
- A runnable `SELECT` is gold: the bot can execute it deterministically on future asks.
- **Trusted authors** (the net-devs core devs) teach instantly; everyone else's facts stay
  pending until a second source corroborates.

## 2. Teach by answering

When the bot asks for help, an escalation ("I've held this back...") or a question in a thread
it is active in, your reply teaches it. Trusted authors' answers are dissected and stored
automatically, whether or not you @mention the bot, as long as the reply carries real substance
(a table, an ID, a query, not just "thanks"). In a thread where the bot has **escalated**, a
plain no-@mention reply is the surest teach. In other threads, include the @mention.

## 3. Auto-learning

Every successfully answered question (tools ran, answer posted) is mined for new facts
automatically, filtered through provenance, PII and schema gates.

## Correcting a wrong fact

- Overwrite: `remember: <same term> = <corrected value>`. A trusted author's fact supersedes.
- Retract: `forget: <entity>`.
- The confirmation echo after every teach shows exactly what landed; check it.

---
