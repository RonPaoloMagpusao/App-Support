# Account unblock and passcode reset

The `#unblock-account-request` channel and G3APIBot: what to type, what the bot does, and when App Support actually has to act.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` section 3; `harvest/slack-inventory.md` (channel metadata); `#api-to-fe` precedent 2026-09-01.

> **No founding SOP was recoverable for this channel.** Nothing in the Confluence harvest documents `#unblock-account-request` or G3APIBot's `reset` command. Everything below is reconstructed from observed usage in the channel between 2026-05-07 and 2026-09-22. Treat the command syntax and bot behaviour as verified by observation, and the operational notes as convention rather than policy.

## 1. The channel

`#unblock-account-request`, ID `C0B289B6DCL`, **public**, created 2026-05-07 by Stefan Hemady. Purpose, verbatim:

> This channel is for requests in unblocking customer accounts that have been blocked due to multiple attempts to reset their passcode

Because it was created in May 2026, there is no history before then. Earlier unblock requests were handled elsewhere and are not recoverable from this channel.

## 2. The command

One line, nothing else:

```
reset {customer email address}
```

- Lowercase `reset`, then the email address.
- No mention of the bot, no ticket reference, no justification.
- Case in the email does not matter. An all-lowercase address and the same address with a capitalised first letter have both worked.

There is no other syntax in use. Nothing else in the message is parsed.

## 3. What G3APIBot actually does

The bot picks the message up within seconds and posts **two** messages, each stamped with a 4-hex job reference:

```
:robot_face: *G3APIBot* `#E88A`: Picking this up -- running reset for `{email}`
:robot_face: *G3APIBot* `#E88A`: Reset complete for `{email}`
```

Typical elapsed time between the two messages: **2 to 4 seconds**.

The job reference ties the two messages together and is the handle to quote if a reset needs chasing.

**Unverified:** exactly what the reset clears server-side. Observationally it unblocks an account locked by repeated failed passcode reset attempts, which is what the channel purpose describes. The bot posts no detail beyond "Reset complete", and no API documentation for it surfaced in the harvest.

## 4. Operational notes

- **Volume** is roughly **2 to 6 resets per working day**.
- **Requesters** are Ops and Collections agents (observed: Kri, Jackie, Yanna, Reyan, Jane, Ella, Jha, Ace, Joy, Dars).
- **App Support does not need to action these.** The bot does the work. This channel is monitored, not worked.
- **Repeats are normal and harmless.** The same email being reset twice within 10 minutes is common, because the customer is still failing the passcode. **Do not raise a ticket for a repeat.**
- **Most login work never becomes a ticket at all** precisely because unblocks run through this bot. Login is understated in the ticket counts for that reason: counted with the OTP and SMS cases filed under Comms it is about 39 tickets in the last twelve months, which would place it around 6th by volume rather than 11th (Confluence 3131015188).

## 5. When G3APIBot is down

**There is no fallback command.** Do not retry the `reset` line hoping it catches.

Precedent from `#api-to-fe`, 2026-09-01: a human posted on the bot's behalf (*"G3APIBot is down right now, so posting on its behalf"*). The correct response is to escalate to the G3 team rather than retry:

- **Albert Rick Martires**
- **Daryll Felipe**

If a customer is genuinely blocked and the bot is down, the underlying fix is a login datafix. See the login script set in [`../04-sql/datafix-templates/`](../04-sql/datafix-templates/) and route the request per [`datafix-request.md`](datafix-request.md).

## 6. Where else G3APIBot appears

G3APIBot also serves the G3 and API teams in `#api-to-fe` for QA test accounts and API behaviour questions. The `reset` command is the App Support facing part of it. Anything else the bot does in `#api-to-fe` is outside this procedure.

## 7. Related

- Login and passcode datafix recipes: [`../02-runbooks/`](../02-runbooks/), [`../04-sql/datafix-templates/`](../04-sql/datafix-templates/).
- The wider "customer cannot log in" investigation, including FullStory session replay to see where the customer actually stopped: [`../05-knowledge/`](../05-knowledge/).
