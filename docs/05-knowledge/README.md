# Knowledge

Product rulings, tribal knowledge, timings, ownership and incidents: the things that are written down nowhere else.

Last reviewed: 23 September 2026
Sources: Slack `#app-support`, `#solutions_memorandum`, `#datascript-requests`, `#pending-funding-checks`, `#refund-supports`, `#autopay_feedback`; Jira MHD; Confluence

## Files

| File | What it covers |
| --- | --- |
| [rusty-rulings.md](rusty-rulings.md) | Joshua (Rusty) Allen's rulings on defect versus design for payments, fees, CRD, LOC/Freestyle and shuffling, with dated quotes and permalinks |
| [working-as-designed.md](working-as-designed.md) | Flat register of behaviours confirmed as intended. Check before raising a Problem |
| [tribal-knowledge.md](tribal-knowledge.md) | Check-first rules, fix recipes, known issues, vocabulary, seasonal effects, non-obvious behaviours |
| [batch-jobs-and-timings.md](batch-jobs-and-timings.md) | Batch jobs, processing windows, clearing times, end-of-month effects |
| [escalation-map.md](escalation-map.md) | Who decides, who owns which system, who to tag where |
| [incident-log.md](incident-log.md) | Incidents in the window: impact, cause, what App Support had to do |

## Who Rusty is

Joshua (Josh) Allen, Slack `UT2FPML2E`, Product Owner for Prod Support, COL, AMZ and CRD. He is the decision authority on defect versus working as designed for Collections, Autopay and the credit card product, and posts the authoritative Ops announcements to `#solutions_memorandum`. He is **not** the Horizon backend owner: he routes deep transaction questions to Tops, Harvey and Albert Rick, and card-network questions to Murdo.

## Ten rules to memorise

1. **Evidence before conclusions.** Pull the ticket, check Horizon for hard evidence, search [MHD precedents](../06-reference/mhd-precedent-index.md), verify money arithmetic independently, and state plainly what could not be verified. See [../00-start-here/investigation-method.md](../00-start-here/investigation-method.md).
2. **Direct debit issues are always urgent.** Rusty's words. See [rusty-rulings.md](rusty-rulings.md), section 11.
3. **In MHD, Urgency is the real field. Priority is unused**, everything sits at Low. Flag it on the ticket when the risk says otherwise. See [../03-procedures/issue-intake-and-triage.md](../03-procedures/issue-intake-and-triage.md).
4. **CRD does not follow the normal custom/partial payment rules.** When the bill is satisfied, the scheduled MMP should be cancelled (MHD-33265, 2026-05-28). See [rusty-rulings.md](rusty-rulings.md), section 2.
5. **Automatic payments only work if they match the default payment method.** Check the default before calling a missed scheduled payment a defect. See [rusty-rulings.md](rusty-rulings.md), section 3.
6. **E6 is the source of truth for CRD. Horizon cannot fix E6 data**, and a credit card account is never moved to Repaid by hand. See [rusty-rulings.md](rusty-rulings.md), section 8.
7. **Overdue and dishonour fees are different things.** The overdue fee is charged every 14 days while in overdue stage regardless of payments; the dishonour fee applies only on rejection. CRD retries do not attract dishonour fees. See [working-as-designed.md](working-as-designed.md) and [../02-runbooks/fees-and-charges.md](../02-runbooks/fees-and-charges.md).
8. **Shuffle carefully.** Twice in quick succession duplicates loaded transactions; on funding day it misses the Dealer/Broker Fee; a frequency change does not recalculate the instalment. See [rusty-rulings.md](rusty-rulings.md), section 10, and [../02-runbooks/amortisation-shuffle-and-schedules.md](../02-runbooks/amortisation-shuffle-and-schedules.md).
9. **Split Sched takes two business days to clear**, and bill satisfaction has to allow for it. See [batch-jobs-and-timings.md](batch-jobs-and-timings.md).
10. **Stored procedure before raw script, and `UpdateAmounts` after any transaction change.** Neither the procedures nor raw deletes recalculate balances. See [../04-sql/README.md](../04-sql/README.md).
