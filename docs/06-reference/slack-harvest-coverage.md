# Slack harvest coverage

Which Slack channels, dates and searches this repo's Slack-derived content came from, and what could not be reached.

Last reviewed: 23 September 2026
Sources: Slack, 2025-09 to 2026-09

What was searched, what was retrieved, what was not.

- Harvest run: **2026-09-23**
- Requested window: **2025-09-01 to 2026-09-23**
- Slack account used: Ron Paolo Miguel Magpusao (`U061GPUSFH6`)
- Mode: **read only**. No message was sent, drafted, scheduled or reacted to.

---

## 1. Subject identified

| Field | Value |
| --- | --- |
| Slack display name | **Rusty** |
| Real name | **Joshua Allen** |
| User ID | `UT2FPML2E` (username `jallen`) |
| Title | Product Owner, Prod Support, COL, AMZ, CRD |
| Email | joshua.allen@moneyme.com.au |
| Timezone | Australia/Canberra |

Only one Slack user matches "Rusty" in the workspace, so the identification is
unambiguous. Confirmed via `slack_search_users` and `slack_read_user_profile`.

---

## 2. Channels covered

### 2.1 The eight channels named in the brief

| Channel | ID | Type | Accessed | Notes |
| --- | --- | --- | --- | --- |
| `#app-support` | `GG7HL6CTE` | private | Yes, via search | Main intake. Created 2019-02-15 by Jonathan Wu. Topic "App Support Issues". |
| `#app-support-issue-alerts` | `C05S9EFD738` | public | Yes, channel read + search | ~25 most recent messages read in full |
| `#app-support-sentry-error-logs` | `C05PPSLUJ1K` | public | Yes, channel read + search | ~25 most recent alerts read in full |
| `#datascript-requests` | `C02HB99AXDX` | private | Yes, channel read + search | ~60 most recent messages read in full, plus 40 search hits across the window |
| `#pending-funding-checks` | `C05J8HEVC81` | private | Yes, channel read + search | ~40 most recent messages read, plus 20 search hits |
| `#refund-supports` | `C051WET9T1A` | private | Yes, channel read + search | ~45 most recent messages read, plus 20 search hits |
| `#unblock-account-request` | `C0B289B6DCL` | public | Yes, channel read + search | ~40 most recent messages read. Channel created 2026-05-07, so it only covers 2026-05 onwards. |
| `#autopay_feedback` | `C03DYRHJ1C6` | public | Yes, channel read | ~30 most recent messages read |

### 2.2 Additional channels surfaced by search and used as sources

These were not in the brief but carry the most valuable Rusty material.

| Channel | ID | Why it matters |
| --- | --- | --- |
| `#solutions_memorandum` | `CFY7LHEJW` | **The single richest source.** Operations announcement channel. Rusty's formal rulings and incident notices live here. |
| `#crd_firefighters` | `C0AFPUZPCEP` | CRD incident channel; Rusty's live diagnosis |
| `#app-support-crd` | `C0ANUL7JYR3` | CRD support; Rusty's behaviour rulings |
| `#horizon-collections-team` | `C03K89BMFAL` | Rusty's written behaviour specs (DisablePaymentSubmission, custom/partial rules) |
| `#collections-payments-daily-support-team` | `C0AP47CGLTY` | Daily payments support |
| `#app-support-twilio-comms` | `C06SG46KVNK` | Comms failure triage |
| `#twilio-team` | (surfaced by search) | Twilio agent-facing issues |
| `#twilio-tech-app-support` | `C0AQJ9MQT33` | Tech Support to App Support handover for Twilio |
| `#app-support-mobile-team` | `C07CSTF1LD8` | Mobile defects |
| `#collection-application-support` | `C05MP53UX0C` | Collections-side requests |
| `#amortization-app-support` | `C06FKJU5D8X` | Amortisation |
| `#funding-dev-qa-supports` | `C08PB3PRM33` | BrandId funding gotcha documented here |
| `#comms-fixing` | (surfaced by search) | Template incidents |
| `#unsaved-card-payments` | (surfaced by search) | Card-versus-DD race explanation |
| `#api-to-fe` | (surfaced by search) | G3APIBot behaviour when down |
| `#tech-cab-approval-followups` | (surfaced by search) | CAB approval convention |
| `#platform-unassigned-mhd-alerts` | (surfaced by search) | Unassigned MHD alerts |
| `#g3-announcements` | (surfaced by search) | Sentry to Uptrace migration |
| `#net-devs-only` | (surfaced by search) | SPV overnight job timing |
| DM: Rusty and Ron | `D069K9EBEDA` | NPP/EFT bounce explanation, arrears fields, access notes |
| Group DM: Rusty, Michael, Ron | `C0ANW0W3VF0` | ProductId 111, transaction cleanup SQL |

---

## 3. Message volume seen

Approximate, counting only what was actually returned into context:

| Source | Messages |
| --- | --- |
| Channel reads (full text) | ~265 |
| Search result sets (concise, 1 to 2 line excerpts) | ~430 across 22 searches |
| Search result sets (detailed, full text) | ~55 across 10 searches |
| **Total distinct messages inspected** | **~700 to 750** |

This is a targeted harvest, not an exhaustive one. `#app-support` alone carries
far more traffic than this across the window.

---

## 4. Date range actually retrieved

| Channel | Earliest seen | Latest seen |
| --- | --- | --- |
| `#app-support` | 2025-09-18 | 2026-09-22 |
| `#solutions_memorandum` | 2025-09-22 | 2026-09-17 |
| `#datascript-requests` | 2025-11-07 | 2026-09-22 |
| `#pending-funding-checks` | 2026-06-12 | 2026-09-23 |
| `#refund-supports` | 2025-11-18 | 2026-09-23 |
| `#unblock-account-request` | 2026-09-03 | 2026-09-22 |
| `#app-support-issue-alerts` | 2026-09-18 | 2026-09-22 |
| `#app-support-sentry-error-logs` | 2026-09-17 | 2026-09-22 |
| `#autopay_feedback` | 2026-08-26 | 2026-09-22 |
| `#crd_firefighters` | 2026-04-22 | 2026-09-16 |
| `#horizon-collections-team` | 2025-11-27 | 2026-09-21 |
| DM with Rusty | 2025-09-17 (referenced) | 2026-09-22 |

Coverage is **dense for 2026-05 to 2026-09** and **sparse for 2025-09 to
2026-04**. Relevance-ranked search reached back into late 2025 for specific
topics (SendGrid, late dishonours, comms templates, Split Sched date rejection)
but the older months were not swept systematically.

---

## 5. Search queries run

Against `slack_search_public_and_private` unless noted.

**User and channel discovery**
1. users: `Rusty`
2. channels: `app-support`; `datascript`; `funding`; `refund`; `unblock`;
   `solutions memorandum`

**Rusty, broad**
3. `from:@Rusty after:2025-09-01` (timestamp sort)
4. `from:@Rusty in:#app-support after:2025-09-01` (pages 1 and 2)
5. `from:@Rusty in:#solutions_memorandum after:2025-09-01`
6. `from:@Rusty in:#solutions_memorandum after:2026-08-20` (detailed)
7. `from:@Rusty in:DM-with-Ron after:2025-09-01`

**Rusty, by topic**
8. `designed from:@Rusty`
9. `direct debit from:@Rusty`
10. `refund from:@Rusty`
11. `arrears from:@Rusty`
12. `escalate from:@Rusty`
13. `E6 from:@Rusty`
14. `Split Zepto from:@Rusty`
15. `"Horizon outage" from:@Rusty`
16. `retry "Debit Card Sched" from:@Rusty`
17. `"Interest Free Expiry" from:@Rusty`
18. `LOC payments from:@Rusty in:#app-support`
19. `migrating payments internal from:@Rusty`
20. `"Custom/partial rules" from:@Rusty`
21. `advance from:@Rusty before:2026-01-01`
22. `"always urgent" from:@Rusty`
23. `cashback "grace period" from:@Rusty`
24. `"bill satisfaction" from:@Rusty`
25. `"first thing we check"`
26. `"always been the case" from:@Rusty`
27. `"processed overnight" from:@Rusty`
28. `allocations from:@Rusty`
29. `bounce business from:@Rusty after:2026-08-01`
30. `Intention Problem from:@Rusty in:#horizon-collections-team`
31. `"Disable Payment Submission" from:@Rusty` (returned nothing; found via
    query 30 instead)

**Procedures and patterns**
32. `datafix in:#datascript-requests after:2025-09-01`
33. `funding in:#pending-funding-checks after:2025-09-01`
34. `refund in:#refund-supports after:2025-09-01`
35. `G3APIBot after:2025-09-01`
36. `"Thanks for reporting this issue" in:#app-support` (bots included)
37. `urgent in:#app-support after:2025-09-01`
38. `cancel scheduled after:2025-09-01`
39. `MHD-33265`

**Cross-cutting**
40. `dishonour after:2025-09-01`
41. `Twilio after:2025-09-01`
42. `SendGrid after:2025-09-01`
43. `SOA after:2025-09-01`
44. `overnight after:2025-09-01`
45. `"known issue" after:2025-09-01`
46. `brand after:2025-09-01`
47. `CustomerEmail BrandId after:2025-09-01`
48. `Sentry after:2025-09-01`

**Channel reads (`slack_read_channel`)**
- `#datascript-requests` (60)
- `#unblock-account-request` (40, plus an empty historical-window read)
- `#pending-funding-checks` (40)
- `#refund-supports` (45)
- `#app-support-issue-alerts` (25)
- `#app-support-sentry-error-logs` (25)
- `#autopay_feedback` (30)

**Profile reads**
- `UT2FPML2E` (Rusty), `U01GN5N1DQF` (Megha), `U03B04FUGDS` (Albert Rick)

---

## 6. What could NOT be accessed or completed

1. **Historical read of `#unblock-account-request` by timestamp range failed.**
   A `slack_read_channel` call with `oldest`/`latest` set to May-June 2026
   returned zero messages. Only the recent page (2026-09-03 onward) was
   retrievable by paging from newest. The channel's founding instructions, if
   any were posted, were not recovered. The `reset {email}` syntax is documented
   from observed usage plus the channel purpose, not from a posted SOP.
2. **`slack_read_thread` on `#crd_firefighters` failed** with `thread_not_found`
   for one attempted thread timestamp. Thread contents were obtained instead via
   search with `include_context`.
3. **Very large search results were truncated by the tool.** The first broad
   `from:@Rusty` search returned 97,682 characters and had to be spilled to a
   file and re-read. Subsequent searches used `response_format: concise` and
   `include_context: false`, which means **most quotes captured in concise mode
   are truncated at roughly 500 characters**. Where a full quote mattered it was
   re-fetched in detailed mode; a handful of memos in the knowledge file are
   therefore marked with an ellipsis where the tail was not recovered.
4. **Pagination was not exhausted.** Nearly every search reported "For the next
   page of results use cursor ...". Only the first page (20 results) was taken in
   most cases. There is more material available, particularly in `#app-support`,
   `#solutions_memorandum` and `#crd_firefighters`.
5. **No systematic sweep of 2025-09 to 2026-04.** Relevance ranking surfaced
   older items only when the query matched them. A calendar-ordered sweep of the
   earlier months was not performed.
6. **Attachments and files were not opened.** Several key memos link to SharePoint
   spreadsheets (e.g. *Collection June 19 Payment Errors.xlsx*, *Payment Event
   Driven Migration List.xlsx*) and Confluence pages. None were fetched; only
   their titles and URLs are recorded.
7. **Confluence pages referenced but not read.** These are cited in the knowledge
   files by URL only:
   - *Partial and Custom Payment Rules* (`.../pages/44630030/`)
   - *Overdue Fee Structures* (`.../pages/121831888/`)
   - *Debit Card Repayments Automatic Retires* (`.../pages/3033497726/`)
   - *APR Increase FAQ's August 2026* (`.../pages/358220138/`)
   - *APR Increase - Lodging Complaints* (`.../pages/455770125/`)
   - *Ad hoc payment - Web ECA Payment Portal* (`.../pages/1742962798/`)
   - *IDKit Troubleshooting* (`.../pages/1640923151/`)
   - *Twilio Tech Support* (`.../pages/2725150760/`)
   - *[G4-Twilio] Known Issue and Resolution* (`.../pages/441417732/`)
   These are the obvious next harvest target.
8. **Jira was not queried.** MHD/CL/COL/CRD ticket bodies were not read; ticket
   keys and titles come only from what people pasted into Slack.
9. **`#app-support-collab`, `#app-support-daily-alerts`, `#app-support-pl-team`,
   `#app-support-team-ph`, `#app-support-apy`, `#app-support-funding`** exist but
   were not read. They may hold further procedure detail.
10. **Bot-posted alert bodies in `#pending-funding-checks` and `#refund-supports`
    carry no author name and no detail**, only a count. The underlying stuck
    items are not listed in Slack, so the actual queue cannot be reconstructed
    from these channels.
11. **One Rusty quote could not be anchored to a subject.** A 2026-03-31 DM
    reading "Yep, it's working exactly as designed and intended" was returned
    without enough surrounding context to know what behaviour it referred to. It
    is flagged in [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) section 14 and deliberately not
    attributed to any specific behaviour.

---

## 7. Redaction applied

- Customer names, customer email addresses, phone numbers and postal addresses
  were **removed** and replaced with "the customer" / "the broker" / `{email}`
  placeholders. The `#unblock-account-request` traffic is entirely customer email
  addresses, so **no individual reset request is reproduced**; only the command
  shape and the bot's reply shape are.
- Internal MoneyMe staff names, Slack handles and user IDs are **kept**, as
  instructed.
- Horizon application, transaction, task, bill, customer and user IDs are
  **kept** as worked examples, as instructed.
- **No credentials, tokens, API keys, passwords or connection strings were
  encountered** in the material harvested. Nothing needed a
  `[CREDENTIAL REDACTED]` marker.
- One DM exchange touching on a colleague's health was seen and **deliberately
  excluded** from all output files.

---

## 8. Output files

| File | Lines |
| --- | --- |
| [05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md) | 745 |
| [03-procedures/README.md](../03-procedures/README.md) | 697 |
| [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) | 373 |
| [06-reference/slack-harvest-coverage.md](slack-harvest-coverage.md) | this file |
