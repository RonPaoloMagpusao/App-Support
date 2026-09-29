# Batch jobs and timings

Every batch job, processing window, clearing time and calendar effect known to App Support. Times are Sydney time unless stated; Manila is 2 to 3 hours behind depending on daylight saving.

Last reviewed: 23 September 2026
Sources: Slack tribal knowledge, Confluence systems pages (see inline)

## From Slack

| Thing | Timing | Source |
| --- | --- | --- |
| **SQL dev datascript window** | Mon-Fri, **12:00-13:00** and **16:00-17:00 Sydney time**. Requests landing after ~16:00 PH on the previous day have slipped by a day in practice. | `#datascript-requests` channel purpose; Ron 2026-09-17 |
| **Split Sched processing** | Was after **17:30**; since 2026-08-26 processes from as early as **08:00** | Rusty, 2026-08-26 |
| **Zepto next response** | Normally **17:30 on the due date**. A 03:30 response means Zepto is running late; usually resolves itself. | Rusty, 2026-08-14 |
| **Split Sched clearing** | **2 business days**. Bill satisfaction logic must allow for this. | Rusty, 2026-07-22 |
| **CRD payment allocations** | Processed **overnight**, off a **daily report from E6** | Rusty, 2026-05-22 |
| **CRD statements** | Issued monthly; interest only ever appears in MoneyOut **on the day a statement is issued** | Rusty, 2026-07-02 |
| **CRD annual fee** | Charged at the **end of the first statement**, not on the funding day (changed ~2026-07-02) | Rusty, 2026-07-02 |
| **CRD cashback grace period** | ~**2 business days** after the MMP due date for instant methods. Temporarily **7 days** over Easter 2026. | Rusty, 2026-05-28 / 2026-04-22 |
| **NPP funds transfer** | Virtually instant. Fallback to EFT takes **up to 2 business days** out and another **1-2 business days** to bounce back, so **3-5 business days** total for a bad account. | Rusty, 2026-08-24 |
| **`Stuck in funding for 20 mins` bot** | Hourly, on the hour, 24/7, `#pending-funding-checks` | observed |
| **`Stuck refund for 30 mins` bot** | Hourly, on the hour, 24/7, `#refund-supports` | observed |
| **CRD auto refund** | Runs at most **once per 24 hours** per account, although the task may raise more than once | James Wiles, 2026-08-27 |
| **Freestyle/LOC to CRD migration batch** | Weekly, **Tuesdays** (from mid-2026); migration emails sent ahead, 21-day opt-out or opt-in on request | Rusty, 2026-06-17 |
| **SPV overnight job** | Reads MoneyOut; effects land **the day after**. Newly funded loans will not move warehouse if fees/balances were mis-captured. | Limuel Bacay, 2025-11-10, `#net-devs-only` |

### End-of-month

- Harvey Dacutanan is on **EOM cashflow reports** at month end and is
  effectively unavailable for payments escalations then (Rusty, 2026-07-01).
- Plan payments/DD escalations around this.

---

## From Confluence

| Job / cadence | Detail | Source |
| --- | --- | --- |
| `#app-support-daily-alerts` `[AP]` checks | Daily. Six alert types: apps funded without Equifax score, pending DD over 2 days, funded but not in Funded status, APY/PL overfunding, commission overfunding, funded apps with no MoneyOut | 899317845 |
| "No MoneyOut" false positives | Appear when transactions are made before **7:04 AM Philippine time** | 899317845 |
| Jira queue check | Daily at **8am** | 454590514 |
| Banking Jobs (AM) and (PM) | Salesforce banking job manuals, run morning and afternoon | AS 457375748, 457441396 |
| BPAY file download and upload | Recurring | AS 1409417316 |
| Direct Credit allocation | Daily CommBiz download, batch upload file created by Raina, remainder allocated manually by Ops | 1772126209 |
| Funding sweep | Albert Rick Martires sweeps for unmapped TransactionIds and sends batches of 8 to 29, roughly weekly | 3131015188 |
| Monthly datafix umbrella ticket | A new MHD parent ticket each month | 3131015188, 2524381287 |
| Scheduled release | Fortnightly, releasing on a Tuesday, with MHD ticket cutoff the **Wednesday before** | 2036138487 |
| Out-of-Schedule releases | Capped at **once a week** since Sep 2025 | 2036138487 |
| LoC Shuffle Script | Ran on a standing schedule Jan 2024 to Mar 2025, then stopped entirely | 3131015188 |
| External - LOA Received / Pending DAP | Auto move out after **60 days** | 1293647889 |
| External - 14 Day Hold | Auto move to Overdue after **14 days** | 1293647889 |
| Hardship Requested | Awaiting Hardship Docs due +21 days; moves to Overdue after 35 days | 1293647889 |
| Hardship Approved - Missed Payment | Moves on after **28 days** | 1293647889 |
| Hardship Declined | 14 day protection period before returning to Overdue | 1293647889 |

---
