# Open items

What is unresolved: defects without fixes, risks nobody has sized, documentation that is wrong or missing, and security findings.

Last reviewed: 23 September 2026
Sources: Jira MHD open threads, Confluence gaps review, investigation handover notes 27 August to 11 September 2026

## Files

| File | What it covers |
| --- | --- |
| [open-defects-and-risks.md](open-defects-and-risks.md) | Tiered list: customer money and regulatory exposure, recurring cost with an unbuilt fix, long-running tickets with no owner, defects never ticketed, process risks |
| [security-findings.md](security-findings.md) | Credentials in Confluence, backup tables of customer data, email misrouting, Slack handling rules |
| [documentation-gaps.md](documentation-gaps.md) | Contradictions, stale pages, undocumented necessities, structural problems in Confluence |
| [investigations-in-flight.md](investigations-in-flight.md) | Tickets worked 27 August to 11 September 2026 with their open actions, updated with what Jira showed on 23 September |

## Top ten, ranked

Ranked by customer harm and regulatory exposure first, then by how many customers could be affected, then by cost of doing nothing.

| # | Item | Why it ranks here | Next action | Detail |
| --- | --- | --- | --- | --- |
| 1 | Plain-text credentials on four Confluence pages (AUT 426082342, AS 519602304, AS 1398210569, AS 2485059655) | Includes production portal passwords and third-party credentials, readable by anyone with Confluence access | Rotate, move to the password manager, replace samples with placeholders | [security-findings.md](security-findings.md#1-credentials-published-in-confluence) |
| 2 | Dormant loans debited without notice (MHD-36446, root cause AMZ-7074) | Unknown number of accounts still unscheduled from pre-fix behaviour; each will debit with no reminder on its next amount change. IDR 21134 open, media threat, ticket sat at **Low** and auto-closed 22/09 | Batch query for accounts with no active schedule and a residual balance; confirm the $186.67 refund; raise the missing pre-debit comms as its own defect | [open-defects-and-risks.md](open-defects-and-risks.md) Tier 1.3 |
| 3 | Adhoc shuffle does not convert the instalment when frequency changes (MHD-36071, MHD-30258, MHD-31738, MHD-35875) | Four reports in seven months, up to a 123 per cent annual increase, no detection. Nobody has sized the population | Query all shuffled accounts where frequency changed and compare instalment to the recalculated figure | Tier 1.1 |
| 4 | Inbound email routed on subject reference alone | One mistyped digit put a customer's financial details on a stranger's file. No ticket raised | Move the email, raise the routing gap, notify whoever handles privacy incidents | [security-findings.md](security-findings.md#3-inbound-email-misrouting) |
| 5 | Mobile app shows "3 years" for a 43-month loan (MHD-36092) | Disclosure mismatch against the credit contract, affects every non-whole-year term | Backend and Mobile to choose between the two fixes | Tier 1.2 |
| 6 | Covered ad hoc payments not cancelled on overdue accounts; a $15 dishonour fee on a payment never submitted (MHD-36283, MHD-36693) | Customers see rejections and fees for payments they made. Closed as working as designed, fresh instance open | Refund the $15; decide whether the design should change; interim officer guidance | Tier 1.4 |
| 7 | `_MHD` backup tables of customer data with no retention | About 70 fixes a month, each leaving a permanent copy including encrypted bank details | Agree an owner and retention rule | [../04-sql/backup-table-hygiene.md](../04-sql/backup-table-hygiene.md) |
| 8 | No way to clear a SendGrid suppression from Horizon (MHD-35799); the send path retries suppressed addresses | Roughly 50,000 futile sends, and every suppressed customer needs a manual request | Get MHD-35799 scheduled | Tier 2.1, 2.2 |
| 9 | Funded applications arriving without an Equifax score | About 20 tickets, every one closed by inserting the score; nobody has asked why | Raise a Problem for the root cause | Tier 4 |
| 10 | Five business day auto-close resolves tickets with unmet acceptance criteria; Priority is unused | Hides open risk (item 2 closed this way) and makes resolution statistics meaningless | Exempt tickets with open acceptance criteria; use Urgency or fix Priority | Tier 5 |

When a ticket's priority looks wrong for its risk, say so on the ticket. Item 2 is the clearest example in the window.
