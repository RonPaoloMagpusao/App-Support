# MHD precedent index

Greppable index of MHD tickets with symptom, root cause, resolution and related keys. Search here before concluding on any investigation.

Last reviewed: 23 September 2026
Sources: Jira MHD, 2025-09-01 to 2026-09-23

Flat, greppable. One row per ticket. Grep for a symptom word, a system name or a ticket key.

**Section A** holds tickets whose description and comment thread were read in full during this harvest. Root cause and resolution columns are verified.

**Section B** is an index of every other ticket collected, grouped by theme, with summary line only. Root cause is **not** verified for Section B rows. Use it to find candidates, then open the ticket.

Window: 2025-09-01 to 2026-09-23. Project MHD unless the key says otherwise.

---

## Section A: verified precedents

| Key | Date | Symptom (one line) | Root cause | Resolution | Linked / precedent keys |
| --- | --- | --- | --- | --- | --- |
| MHD-36071 | 2026-08-27 | Freestyle repayment rose from $1,065.40 monthly to $1,097.60 fortnightly after adhoc shuffle, account 10001184043 | Adhoc shuffle changed frequency label without converting the instalment amount; both figures are monthly amounts | Continuous payment setting at roughly $499 fortnightly. No fix planned, Freestyle being discontinued. Auto-closed | MHD-30258, MHD-31738, MHD-35875, MHD-31974 |
| MHD-30258 | 2026-02-06 | Freestyle fortnightly repayment rose $299.48 to $507.81 after adhoc shuffle, loan 10001620977 | Same shuffle frequency-conversion defect | Josh Allen: continuous payment setting is "the only option we have in this case". Closed same day | MHD-36071, MHD-31738, MHD-35875 |
| MHD-31738 | 2026-04-08 | $300 fortnightly became $397.20 monthly after shuffle (should be roughly $650), loan 10001749537 | Not root-caused | Escalated to Collections, auto-closed after 39 days without resolution | MHD-30258, MHD-36071 |
| MHD-35875 | 2026-08-20 | Shuffled fortnightly to monthly, repayment amount did not change at all, loan 10001306925 | Not investigated | Auto-closed after 6 days, no analysis recorded | MHD-30258, MHD-31738, MHD-36071 |
| MHD-36092 | 2026-08-27 | Mobile app shows "3 years" for a 43-month loan, application 10003066205 | API `DurationInYears` field returns a rounded-down string; the accurate months field is sent but never displayed. iOS regressed via MMM-9350 in May 2025 | Open. Selected for Development, linked to MMM-16301 (To Do). No data fix required | MMM-9350, MMM-16301, MHD-35653, MHD-35277 |
| MHD-35653 | 2026-08-14 | App showed last repayment date 17/01/2030 for a "36 month" loan, application 10003041310 | Transaction tab held a stale 36-month term; actual amortisation was 42 months | Data fix to correct the loan term on the Transaction tab, tracked as MHD-35509 under MHD-35277 | MHD-35277, MHD-35509, MHD-36092 |
| MHD-36446 | 2026-09-09 | SocietyOne 2000019464 debited $186.672 on 07/09/2026, 374 days after last activity; IDR dispute 21134, media threat | AMZ-7074: an ad hoc card payment cancelled amortisation schedules without replacing them, leaving a $355.36 residual unscheduled from 15/08/2025. The 24/08/2026 write-off of $168.70 triggered the corrected code to create the missing schedule three minutes later | Root cause identified and explained. Refund, customer explanation and IDR response set as acceptance criteria; ticket auto-closed before they were confirmed. Priority re-rate requested, not applied | AMZ-7074, MHD-27965 |
| MHD-35969 | 2026-08-24 | Reverse write-off data fix requested from Slack | Request, not a defect | Data fix executed, closed in under two days | MHD-35277 (blocks), MHD-36077 |
| MHD-36077 | 2026-08-27 | Reverse write-off data fix | Request | Data fix executed | MHD-35277 |
| MHD-36075 | 2026-08-27 | Passcode reset emails appeared empty, application 10002487161 | Not a defect. Four identical template 970 emails in 25 minutes were threaded by Gmail and the repeated body hidden behind a "…" trimmed-content control | Advised to open the first email in the thread. Two side defects logged in the comment only: template 970 renders "Reference number 0", and identical resends cause the trimming | MHD-29695 |
| MHD-36283 | 2026-09-03 | Ad hoc payment 109268769 of $1,000 marked Rejected instead of cancelled after the customer paid by Debit Card Live (109268780), LID 10002445060 | Working as designed. Debit Card Live should have cancelled the direct credit, but on an overdue-stage account only retry transactions can be cancelled. The transaction stayed Proposed and was rejected after 3 working days under the "Payment not actioned" rule | Explained to the reporter, no change. Auto-closed | MHD-33265, MHD-33404, MHD-35241, CRD-2459 |
| MHD-33265 | 2026-05-28 | CRD scheduled DD not cancelled after an advance payment, application 10002813976 | CRD did not apply the ad hoc payment rules. Josh Allen ("Rusty"): when the payment is settled in advance it **should** cancel the scheduled DD | Interim: cancel by agent. Permanent fix shipped as CRD-2459 in release MHD-33404 | MHD-33404, CRD-2459, RB-1558 |
| MHD-33404 | 2026-06-02 | Release bundling five CRD fixes including scheduled DD cancellation on early payment | n/a, release | Deployment Completed | CRD-2459, CRD-2308, CRD-2074, CRD-2269, CRD-1783, RB-1558 |
| MHD-35019 | 2026-07-24 | Early Custom Amount payment cancelled the PL scheduled repayment but not the Freestyle one due 21/07 | Product difference. PL cancels the upcoming DD on an early payment; Freestyle Custom Amount is a one-off against balance and does not touch the schedule. Next Repayment is unavailable for Freestyle in the app | Known Freestyle limitation, no fix planned. Manual schedule edit as workaround. Customer not double charged | MHD-36071, MHD-36270 |
| MHD-35514 | 2026-08-10 | DD rejected same day with "Add Payment Denied", application 10002269829, transaction 108364618 | Provider payload: "Authoriser contact bank account is blocked and not eligible (Non-debitable account type)". Provider Split | Customer must nominate a different debitable account | MHD-36618 |
| MHD-36618 | 2026-09-15 | Every scheduled Split payment denied since 12/02/2025, 12 consecutive, application 10002220007 | Non-debitable nominated account, provider-side block. Horizon bank details were correct; re-adding the DD on 22/06/2026 did not help | Nominate a different debitable account; take the immediate payment by card or transfer. Cancelled row 108348993 found only in the DB | MHD-35514, MHD-36607, MHD-36629 |
| MHD-36629 | 2026-09-16 | "Direct debit keeps on reversing even though its well-funded", 10002220007 | Duplicate of MHD-36618 | Closed as Duplicate | MHD-36618, MHD-36607 |
| MHD-34293 | 2026-07-01 | Six accounts with DD payments stuck in Proposed past the scheduled date | Not recorded | Fixed by Tops and Harvey within a day. No root cause captured | MHD-34732 |
| MHD-30926 | 2026-03-05 | Zepto bulk late dishonour reversals, CBA 19 and 29 Jan Bendigo outage, part 2 | Batch operation | Collections script first, then Soft Execution Script, Amort verify, Actual Execution Script, Amort actualise | MHD-30048, MHD-36494 |
| MHD-36494 | 2026-09-10 | Zepto bulk late dishonour recovery, 185 rows totalling $78,611.86 | Batch operation. Blocker: the supplied CSV had Amount and Zepto PR Ref only, no ApplicationId or TransactionId | Mapping file supplied by Josh Allen, then the standard four-step execution plan. Backup `Transaction_MHD36494` | MHD-14377, MHD-30926 |
| MHD-32117 | 2026-04-21 | LID 10002525753 stuck in Overdue despite $0.00 arrears | Workflow rule: **Overdue + Rejected payment = no stage move** | Manual stage move. Josh Allen said stage-transition workflows were being reworked, expected end of year | MHD-34734, MHD-36790 |
| MHD-34734 | 2026-07-16 | Account 10002120225 failed to move to FS after arrears cleared, resurfacing in outbound campaigns, twice | Same rule as MHD-32117. Rejected DC transaction 107630018 sat alongside the ad hoc payment 108582314 that cleared arrears | Manual stage move by Jonathan Flack. Flagged as a live recurrence of the unfixed MHD-32117 gap | MHD-32117, MHD-36790 |
| MHD-36790 | 2026-09-22 | APY 10002108249 did not auto move to FS after a cleared DD retry | Hypothesis, unconfirmed: the Overdue to Fund Sent check requires the last successful payment to be dated today and may be reading the transaction date rather than the clearing date. DDs on this account settle 2 to 4 days later | Stage moved manually by the reporter. Raised with the Horizon workflow team. **Open**, a second example requested | MHD-32117, MHD-34734 |
| MHD-36602 | 2026-09-15 | Reset arrears to $0 on a written-off SocietyOne PL Broker account, 10002127727 | Routine request | Contract variation applied, same day | MHD-36819, MHD-33703, MHD-35578 |
| MHD-36206 | 2026-09-01 | Repeated $35 overdue fees despite payments, application 10002399667 | Working as designed. An OD fee is charged every 14 days while an account is in Overdue stage, regardless of payments. Account had been Overdue since February, arrears $1,153.85 | Fees waived by Jason McGuire's approval, because a Courtesy Variation had forced a Financial-Support customer ahead of schedule | MHD-35381 |
| MHD-35381 | 2026-08-05 | Payment plan stayed active after a $630 early payment was allocated to arrears, LID 10002937235 | Working as designed. Payments allocate to the oldest outstanding amount first; the PP covers arrears only and runs alongside monthly minimums. The 04/08 DD still ran, rejected, and triggered a $15 dishonour fee | Explained. $15 fee waived because the customer had been given incorrect advice on 07/07. Josh Allen confirmed the arithmetic and said the behaviour is being changed to align with other products | MHD-36206 |
| MHD-30961 | 2026-03-06 | System debiting $145 against an approved $150 hardship arrangement, account 10000796502 | Not a defect. The $5 gap is the monthly fee; the amount had been set with the include-fee flag false | Set the amount to $150 explicitly | MHD-36270 |
| MHD-36270 | 2026-09-03 | Could not pause fortnightly payments; next due kept showing $40.74, application 10001806432 | Horizon shows the full schedule when an LOC has nothing scheduled | Josh Allen: manually add the first expected payment. The ongoing-amount tag not sticking is a display issue only; payments process at the set amount. Not to be fixed, Freestyle is being phased out | MHD-30961 |
| MHD-29993 | 2026-01-28 | Emails failing to send, application 10002742595, "550 No Such User" | The broker address was on the SendGrid Bounces suppression list | Removed manually from SendGrid. Warned it would likely re-bounce | MHD-29956, MHD-29963, MHD-35666, MHD-35539 |
| MHD-35799 | 2026-08-19 | No way to clear a SendGrid suppression from Horizon; each case needs direct SendGrid access | Tooling gap | **Open, Pending, Medium.** Full acceptance criteria written: view suppression status, one-action removal across Bounced/Blocked/Spam, audit note, permission gate | MHD-35666, MHD-35539, G1-6834, G1-7161 |
| MHD-31787 | 2026-04-10 | Customer not receiving verification codes despite successful internal delivery logs, application 10002223282 | Carrier-side (Optus). Raised directly with Twilio | Closed as "working as expected". No defect | MHD-31779, MHD-31736 |
| MHD-35589 | 2026-08-12 | Migrated OzMoney CRD customer got "There is an issue with this account" on login, LID 10002954051, customer 664818 | No MME account record existed for the migrated customer | Insert MME account | MHD-36010, MHD-35478 |
| MHD-36009 | 2026-08-25 | Correspondence still going to the old email after the address was updated, application 10003012512 | The old address was still held on the SocietyOne (SOC) brand contact record; the update was applied to MoneyMe and OzMoney but not SOC | Data fix to correct the SOC contact row | MHD-35754, MHD-35641, MHD-35277 |
| MHD-35314 | 2026-08-04 | SOA issued via Issue Doc went to a different address than the one on file, PL 10001616803 | Stale contact record | Contact updated, same day | MHD-35277 |
| MHD-35789 | 2026-08-19 | SOA failing to load for application 10000620227 | Generation failure, cause not captured | SOA generated manually and attached, 1h50m turnaround | MHD-35850, HOR-8167 |
| MHD-35850 | 2026-08-20 | "SOA won't load", application 10000700299 | Generation failure | SOA generated manually and attached, 26 minutes | MHD-35789, HOR-8167 |
| HOR-8167 | 2026-07-14 | Horizon file upload limit of 10 MB too low for CRD-era SOA files | Config limit plus IIS default of roughly 28.6 MB | Raised to 30 MB, config-driven, with a 35 MB `maxAllowedContentLength` and a client-side pre-check. QA passed 06/08, UAT passed 09/09, prod passed 10/09. **Email attachment ceiling still out of scope** | MHD-34644, HOR-8170, HOR-8183, MHD-36453, QAAUTO-1845, QAAUTO-1992 |
| MHD-36658 | 2026-09-16 | "No Bank Account" error on refund funding despite visible bank details, application 10002815000 | `applicationbankid` was NULL in the application bank table | Data fix to populate the reference, run under MHD-36184 | MHD-36184 |
| MHD-36609 | 2026-09-15 | Application 10003084267 stuck at Signed Off | Orphan funding records | Data fix stored procedure to delete the funding records | MHD-35863 |
| MHD-34765 | 2026-07-17 | Application 10003014669 funded without an Equifax score | Not investigated | Score inserted by data fix. Closed in 2 minutes | MHD-36129, MHD-36041, MHD-35896 and roughly 20 others |
| MHD-35818 | 2026-08-19 | Broker portal stuck on "calculating your finance details", application 10003059392 | `IsEditedVehicleDetails` incorrectly set to 1 on a pre-approval application | Data fix. The requested permanent fix to how the flag is set was never delivered | MHD-35277 |
| MHD-36240 | 2026-09-02 | Editing the VIN on one funded Autopay application changed two others (10002846570, 10002847296, 10002846116) | Four applications shared `AutopayVehicleDetailId` 233752, plus two duplicate rows on the same VIN. Traced to data fixes during the April 2026 Glass Guide outage | Data fix repointing each application to its correct ID (247005, 234651, 234467) and removing the duplicate once unreferenced | MHD-36184 |
| MHD-32267 | 2026-04-27 | Loan agreement (template 2146) never sent to the broker after funding, application 10002867333 | An uncleared **Review - Contract Sending Failed** task blocked the send | Task cleared. Standing guidance: always clear that task first, and if the error names a mobile or email problem have the agent fix it before retrying | MHD-35658, MHD-36527 |
| MHD-36668 | 2026-09-16 | Settlement confirmation emails re-sent to customer and dealer 61 days after settlement, application 10003015808 | Duplicate re-send, not a delayed first send. Originals fired 17/07/2026 11:01, three minutes after Fund Sent; identical subjects fired again 16/09/2026 04:05 with no stage change. 04:05 is inside the nightly comms window. Two candidate mechanisms: a Workflow2 `Reset Days` value allowing re-processing, or a missing "templates not yet sent" guard | **Not resolved.** Auto-closed. Which job ran at 04:05, and whether other applications were affected, are both unknown. Email contents were never compared between the two sends | MHD-33771 |
| MHD-35062 | 2026-07-27 | "Split Create/Update Account" tasks keep regenerating for CRD accounts on non-Split Sched repayment | Not identified | **Open**, Selected for Development since July. Raised to Funding | none recorded |
| MHD-35324 | 2026-08-04 | App shows upcoming repayments as DD when Horizon has DC, LID 10001905418 | Not identified. Mobile team still confirming whether it is a display issue or expected | **Open**, Waiting for Confirmation since August. Reporter has chased four times | none recorded |
| MHD-35277 | 2026-08-01 | `[App Support] Data Fix - 2026-Aug` umbrella change ticket | n/a | Deployment Completed. **69 linked child tickets** | MHD-36184, MHD-34282, MHD-33350, MHD-32416, MHD-31576, MHD-30801, MHD-30099 |

---

## Section B: theme index, summary line only

Root cause and resolution are **not** verified for these rows. Problem-type tickets only.

### SOA generation

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36803 | 2026-09-22 | 2026-09-22 | Closed | Generate Statement of Account (SOA) for Application 10001404007 |
| MHD-36710 | 2026-09-18 | 2026-09-18 | Closed | Freestyle / 10000764579 / SOA request |
| MHD-36635 | 2026-09-16 | 2026-09-18 | Closed | Not received SOA |
| MHD-36398 | 2026-09-07 | 2026-09-07 | Closed | SOA generation 10000970018 |
| MHD-36345 | 2026-09-04 | 2026-09-07 | Closed | the current statement has not send yet which supposedly is 5 and due date will be on 17/09/2026 - 10003039272 |
| MHD-36280 | 2026-09-03 | 2026-09-07 | Closed | Reverse payments and remove from SOA |
| MHD-36152 | 2026-08-31 | 2026-09-01 | Closed | SOA request 10001037413 |
| MHD-36157 | 2026-08-31 | 2026-09-01 | Closed | Freestyle / 10001133359 / SOA request |
| MHD-36074 | 2026-08-27 | 2026-08-27 | Closed | SOA request 10001167979 |
| MHD-36047 | 2026-08-26 | 2026-09-01 | Closed | SOA for 10001167510 |
| MHD-35953 | 2026-08-24 | 2026-08-27 | Closed | SOA request 10001459594 |
| MHD-35957 | 2026-08-24 | 2026-08-27 | Closed | Manually generate SOA for LOC 10000627167 due to high transaction volume |
| MHD-35899 | 2026-08-21 | 2026-08-21 | Closed | Freestyle / 10001332267 / SOA request |
| MHD-35894 | 2026-08-21 | 2026-08-21 | Closed | Generate and provide Statement of Account (SOA) |
| MHD-35850 | 2026-08-20 | 2026-08-20 | Closed | Unable to generate SOA 10000700299 |
| MHD-35789 | 2026-08-19 | 2026-08-19 | Closed | Fix SOA generation loading issue for Application 10000620227 |
| MHD-35742 | 2026-08-18 | 2026-08-18 | Closed | Unable to generate the SOA - 10000621944 |
| MHD-35700 | 2026-08-17 | 2026-08-17 | Closed | Soa for 10000841498 |
| MHD-35718 | 2026-08-17 | 2026-08-18 | Closed | Unable to generate the SOA - 10000655975 |
| MHD-35511 | 2026-08-10 | 2026-08-10 | Closed | Unable to generate the SOA - 10000993633 |
| MHD-35499 | 2026-08-10 | 2026-08-10 | Closed | Unable to generate SOA 10000897045 |
| MHD-35449 | 2026-08-07 | 2026-08-07 | Closed | Unable to generate SOA 10000874843 |
| MHD-35353 | 2026-08-05 | 2026-08-06 | Closed | Incorrect display showing on reversal |
| MHD-35314 | 2026-08-04 | 2026-08-04 | Closed | SOA is being sent to an incorrect email / [PL / 10001616803 |
| MHD-35327 | 2026-08-04 | 2026-08-10 | Closed | MME / 10002918019 / transaction history for their credit card account from December to August |
| MHD-35326 | 2026-08-04 | 2026-08-04 | Closed | Freestyle / 10001531138 / Request for Full History SOA |
| MHD-35333 | 2026-08-04 | 2026-08-04 | Closed | Investigate failure to generate updated SOA for account 10000845933 |
| MHD-35315 | 2026-08-04 | 2026-08-04 | Closed | Investigate and resolve issue generating updated statement for account 10000724481 |
| MHD-35340 | 2026-08-04 | 2026-08-05 | Closed | Freestyle / 10001304138 / SOA request |
| MHD-35151 | 2026-07-29 | 2026-07-29 | Closed | MME- 10000605196 / Unable to Send SOA |
| MHD-35080 | 2026-07-27 | 2026-07-27 | Closed | Unable to Generate SOA on Freestyle Account |
| MHD-35017 | 2026-07-24 | 2026-07-24 | Closed | MME / 10001222048 / I need help on sending to the customer for the Full SOA |
| MHD-35020 | 2026-07-24 | 2026-07-24 | Closed | Freestyle / 10001063997 / SOA request Full History |
| MHD-34848 | 2026-07-20 | 2026-07-28 | Closed | MME PL / 10001808258 / Broker Fee enquiry |
| MHD-34781 | 2026-07-17 | 2026-07-17 | Closed | Investigate SOA generation failure for account 10000784619 |
| MHD-34695 | 2026-07-15 | 2026-07-15 | Closed | SOA Request from 01/07/2025 to 30/06/2026 / 10001278605 |
| MHD-34653 | 2026-07-14 | 2026-07-14 | Closed | Full History SOA Request / 10001278605 |
| MHD-34644 | 2026-07-14 | - | Selected for Development | Increase file size upload limit in Horizon to 30mb |
| MHD-34619 | 2026-07-13 | 2026-07-14 | Closed | Investigate SOA generation error for account 10001219374 |
| MHD-34448 | 2026-07-07 | 2026-07-07 | Closed | Freestyle / Loan ID: 10000855141 / SOA |
| MHD-34415 | 2026-07-06 | 2026-07-06 | Closed | Unable to generate SOA 10000700299 |
| MHD-34423 | 2026-07-06 | 2026-07-06 | Closed | Generate statement of account for account 10001167510 |
| MHD-34424 | 2026-07-06 | 2026-07-07 | Closed | Unable to generate SOA 10001150926 |
| MHD-34372 | 2026-07-03 | 2026-07-08 | Closed | MME- 10002839455 / Incorrect Outstanding Balance |
| MHD-34286 | 2026-07-01 | 2026-07-01 | Closed | 10001167510 - Generate SOA |
| MHD-34306 | 2026-07-01 | - | Pending | MME - 10002922420 / Admin Fee Reallocation Error on the App |
| MHD-34284 | 2026-07-01 | 2026-07-01 | Closed | SOA req |
| MHD-34263 | 2026-06-30 | 2026-06-30 | Closed | LID: 10000637944 / Issue: Cant generate full SOA in PDF |
| MHD-34259 | 2026-06-30 | 2026-07-01 | Closed | Need to remove transaction - 10002113722 |
| MHD-34252 | 2026-06-30 | 2026-06-30 | Closed | Unable to generate SOA 10000832047 10001172561 |
| MHD-34248 | 2026-06-30 | 2026-06-30 | Closed | Unable to generate SOA 10001514007 10000700299 |
| MHD-34208 | 2026-06-29 | 2026-06-30 | Closed | Unable to generate SOA 10000832047 10001172561 |
| MHD-34035 | 2026-06-22 | 2026-06-22 | Closed | SOA for 10002811754, 15/05/2026-14/06/2026 |
| MHD-33973 | 2026-06-19 | 2026-06-22 | Closed | SOA request 10001946919 and 2000086425 |
| MHD-33965 | 2026-06-19 | 2026-06-22 | Closed | customer has not receive monthly statement yet which current statement day 22 and due date on 06/07 - 10002936347 |
| MHD-33885 | 2026-06-18 | 2026-06-24 | Closed | 10002921887 - incorrect balance on the account |
| MHD-33848 | 2026-06-17 | 2026-06-17 | Closed | 10000620227 unable to generate the full Statement of Account (SOA) history in HZ. |
| MHD-33833 | 2026-06-17 | 2026-06-17 | Closed | Unable to generate the SOA - 10000897045 |
| MHD-33834 | 2026-06-17 | 2026-06-17 | Closed | Generate Statement of Advice (SOA) for account 10001114014 |
| MHD-33838 | 2026-06-17 | 2026-06-23 | Closed | Address Inquiry |
| MHD-33763 | 2026-06-15 | 2026-06-15 | Closed | Unable to generate SOA 10000859961 |
| MHD-33770 | 2026-06-15 | 2026-06-15 | Closed | Unable to generate SOA 10000874843 10000978663 10000899629 10000897045 |
| MHD-33737 | 2026-06-12 | 2026-06-18 | Closed | 10002683885 |
| MHD-33735 | 2026-06-12 | 2026-06-12 | Closed | Statement of Account request |
| MHD-33633 | 2026-06-10 | 2026-06-10 | Closed | status Failed emails - 10002363334 |
| MHD-33505 | 2026-06-04 | 2026-06-08 | Closed | 6 mos SOA request / 10001791121 / Freestyle |
| MHD-33490 | 2026-06-04 | 2026-06-04 | Closed | SOA req |
| MHD-33403 | 2026-06-02 | 2026-06-02 | Closed | Unable to generate SOA 10000695628 |
| MHD-33399 | 2026-06-02 | 2026-06-02 | Closed | SOA req |
| MHD-33402 | 2026-06-02 | 2026-06-02 | Closed | Unable to generate SOA 10000859961 |
| MHD-33412 | 2026-06-02 | 2026-06-02 | Closed | Unable to generate the SOA - 10000706060 |
| MHD-33421 | 2026-06-02 | - | Closed | payment reminder/notification was received the same day at 12AM when the payment was due |
| MHD-33397 | 2026-06-02 | 2026-06-02 | Closed | SOA wont load 10000770478 |
| MHD-33262 | 2026-05-28 | 2026-05-28 | Closed | Cannot generate SOA 10001190186 |
| MHD-33266 | 2026-05-28 | 2026-05-29 | Closed | Cannot generate SOA 10000854764 |
| MHD-33214 | 2026-05-27 | 2026-05-28 | Closed | SOA req |
| MHD-33212 | 2026-05-27 | 2026-05-28 | Closed | SOA |
| MHD-33164 | 2026-05-26 | 2026-05-26 | Closed | Freestyle SOA in pdf |
| MHD-33172 | 2026-05-26 | 2026-05-26 | Closed | FULL HISTORY SOA Request / 10000622739 |
| MHD-33082 | 2026-05-22 | 2026-05-22 | Closed | SOA req |
| MHD-33032 | 2026-05-21 | 2026-05-21 | Closed | Generate SOA for the following apps |

### Email delivery / SendGrid

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36007 | 2026-08-25 | 2026-08-26 | Closed | Investigate in sendgrid - 10003064185 |
| MHD-35799 | 2026-08-19 | - | Pending | Horizon: add a button to remove an email address from the SendGrid suppression lists (Bounced / Blocked / Spam) |
| MHD-35666 | 2026-08-14 | 2026-08-17 | Closed | Investigate in sendgrid - 10003051293 |
| MHD-35539 | 2026-08-11 | 2026-08-11 | Closed | Investigate in sendgrid - 10003045718 |
| MHD-34981 | 2026-07-23 | 2026-07-23 | Closed | Investigate email in Sendgrid - 10003024955 |
| MHD-34838 | 2026-07-20 | 2026-07-21 | Closed | Not receiving email |
| MHD-34117 | 2026-06-25 | 2026-06-25 | Closed | Investigate in Sendgrid - 10002974975 |
| MHD-34093 | 2026-06-24 | 2026-06-24 | Closed | Investigate in Sendgrid - 10002953661 |
| MHD-33954 | 2026-06-19 | 2026-06-24 | Closed | Email issue |
| MHD-33633 | 2026-06-10 | 2026-06-10 | Closed | status Failed emails - 10002363334 |
| MHD-32679 | 2026-05-11 | 2026-05-12 | Closed | Investigate in Sendgrid - 10001663301 |
| MHD-31353 | 2026-03-23 | 2026-03-23 | Closed | Investigate email - 10002795582 |
| MHD-30808 | 2026-03-02 | 2026-03-02 | Closed | Check email - 10002144603 |
| MHD-30425 | 2026-02-13 | 2026-02-22 | Closed | Check app - 10002761739 |
| MHD-30309 | 2026-02-10 | 2026-02-10 | Closed | Investigate Email - 2000054339 |
| MHD-30067 | 2026-01-30 | 2026-01-30 | Closed | 10002741480 - Investigate in Sendgrid |
| MHD-30036 | 2026-01-29 | 2026-01-29 | Closed | 10002748385 - investigate in sendgrid |
| MHD-29996 | 2026-01-28 | 2026-01-28 | Closed | Fix Customer email |
| MHD-29993 | 2026-01-28 | 2026-01-28 | Closed | 10002742595 - 550 No Such User |
| MHD-29997 | 2026-01-28 | 2026-01-28 | Closed | Email keeps failing 10002738887 |
| MHD-30009 | 2026-01-28 | 2026-01-28 | Closed | 10002740443 - Investigate in Sendgrid |
| MHD-29992 | 2026-01-28 | 2026-01-28 | Closed | 10002742595 - Investigate in Sendgrid |
| MHD-29956 | 2026-01-27 | 2026-01-27 | Closed | 550 No Such User - 10002744903 |
| MHD-29963 | 2026-01-27 | 2026-01-27 | Closed | 550 No Such User - 10002744370 |
| MHD-29883 | 2026-01-23 | 2026-01-23 | Closed | 10002744855 - Investigate email in sendgrid |
| MHD-29744 | 2026-01-20 | 2026-01-20 | Closed | 10001268838 - Investigate in Sendgrid |
| MHD-29730 | 2026-01-19 | 2026-01-19 | Closed | 10002740148 - investigate in Sendgrid |
| MHD-29734 | 2026-01-19 | 2026-01-19 | Closed | 10002394511 - Investigate in Sendgrid |
| MHD-29582 | 2026-01-15 | 2026-01-15 | Closed | Investigate in Sendgrid - 10001654731 |
| MHD-29479 | 2026-01-09 | 2026-01-20 | Closed | 10002404506 – Email status shows “Failed” despite correct email on file |
| MHD-29441 | 2026-01-07 | 2026-01-08 | Closed | Investigate in sendgrid - 10002227839 |
| MHD-29303 | 2025-12-30 | 2025-12-30 | Closed | Investigate in sendgrid - 10002714444 |
| MHD-29162 | 2025-12-18 | 2025-12-23 | Closed | Investigate in sendgrid - 10002193204 |
| MHD-28397 | 2025-11-20 | 2025-11-20 | Closed | Investigate Sendgrid - 10002105690 |
| MHD-28369 | 2025-11-19 | 2025-11-19 | Closed | Investigate - Declined email 10002675630 |
| MHD-27706 | 2025-10-27 | 2025-11-27 | Closed | Investigate in Sendgrid - 10002634657 |
| MHD-27624 | 2025-10-22 | 2025-10-23 | Closed | Eway / Login/access issue / Not receiving verification codes on email |
| MHD-27609 | 2025-10-21 | 2025-11-27 | Closed | Investigate in Sendgrid - 10002630711 |
| MHD-26581 | 2025-09-02 | - | Selected for Development | Horizon - Email Deliverability |

### SMS, OTP, Twilio

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36397 | 2026-09-07 | 2026-09-08 | Closed | Add <internal test address redacted> to SpecialUser bypass table |
| MHD-36186 | 2026-09-01 | 2026-09-07 | Closed | Unable to reset the passcode/ 10003075272 / PL |
| MHD-35486 | 2026-08-08 | 2026-08-16 | Closed | Not Receiving SMS |
| MHD-35475 | 2026-08-07 | 2026-08-16 | Closed | Unable to reset the passcode / CRD / 10002922217 |
| MHD-35418 | 2026-08-06 | 2026-08-12 | Closed | Unable to login |
| MHD-35364 | 2026-08-05 | 2026-08-11 | Closed | OTP Failed - getting a quote |
| MHD-35362 | 2026-08-05 | 2026-08-05 | Closed | Investigate SMS login failure for customer application 10002405188 |
| MHD-35238 | 2026-07-31 | 2026-08-06 | Closed | MME / 10001902852 / Twilio Call Recording Check |
| MHD-35136 | 2026-07-28 | 2026-08-03 | Closed | Unable to reset passcode / APY / 10002887928 |
| MHD-35073 | 2026-07-27 | 2026-08-02 | Closed | APY / 10002436750 / Twilio - Call Recording Issue |
| MHD-35072 | 2026-07-27 | - | Cancelled | MME / Sample LID: 10002436750 / Twilio Call Recording Issue |
| MHD-35030 | 2026-07-24 | 2026-07-30 | Closed | Cannot receive SMS code - 10002967365 |
| MHD-34985 | 2026-07-23 | 2026-07-30 | Closed | Unauthorised OTP / 10002948860 / CRD |
| MHD-34806 | 2026-07-18 | 2026-07-25 | Closed | SMS Payment notification |
| MHD-34651 | 2026-07-14 | 2026-07-14 | Closed | Investigate 'error: timed out' on iPhone after 4-digit code entry |
| MHD-34524 | 2026-07-09 | 2026-07-25 | Closed | Investigate app - 10002229579 |
| MHD-34517 | 2026-07-09 | 2026-07-09 | Closed | Add Kristofer.Tan to Twilio Live for testing purposes |
| MHD-34441 | 2026-07-07 | 2026-07-07 | Closed | Not receiving the OTP / APY / 10002406209 |
| MHD-34453 | 2026-07-07 | 2026-07-30 | Closed | Investigate Comms - 10002439742 |
| MHD-34331 | 2026-07-02 | 2026-07-07 | Closed | Investigate - 10002113054 |
| MHD-34257 | 2026-06-30 | 2026-07-02 | Closed | Twlio Issue / Captured Recording Issue |
| MHD-34121 | 2026-06-25 | 2026-07-01 | Closed | OTP sending failed error - |
| MHD-34105 | 2026-06-24 | 2026-06-30 | Closed | Freestyle 10001093600 - SMS status showing undelivered |
| MHD-33905 | 2026-06-18 | 2026-06-24 | Closed | OTP sending failed - 10001081735 |
| MHD-33863 | 2026-06-17 | 2026-06-23 | Closed | Code being sent to incorrect mobile num /10002966840/ PL |
| MHD-33798 | 2026-06-16 | 2026-06-16 | Closed | Customer ID 727589 |
| MHD-33818 | 2026-06-16 | 2026-06-22 | Closed | Not receiving OTP when submitting an application / PL / 10001173129 |
| MHD-33724 | 2026-06-12 | 2026-06-12 | Closed | OTP being sent to different mobile / 10002667381 / APY |
| MHD-33638 | 2026-06-10 | 2026-08-20 | Closed | Request to reset Arrears 10002953898 |
| MHD-33524 | 2026-06-05 | 2026-06-10 | Closed | Cust not receivign SMS code |
| MHD-33536 | 2026-06-05 | 2026-06-14 | Closed | 10001224169 / Customer reported unauthorized chat activity on the account and provided a screenshot as supporting eviden |
| MHD-33477 | 2026-06-04 | 2026-06-10 | Closed | 10002954043 - Payout balance |
| MHD-33414 | 2026-06-02 | 2026-06-08 | Closed | Forgot Password Request - Unsuccessful |
| MHD-33257 | 2026-05-28 | 2026-05-28 | Closed | Unable to log in |
| MHD-32677 | 2026-05-11 | 2026-05-12 | Closed | Reset passcode notification / 10000967164/ Freestyle |
| MHD-32624 | 2026-05-08 | 2026-05-08 | Closed | Investigate and resolve duplicate mobile number association for two customers |
| MHD-32518 | 2026-05-05 | 2026-05-06 | Closed | Cannot Reset Passcode |
| MHD-32398 | 2026-04-30 | 2026-05-04 | Closed | Investigate persistent email bounces for account 10002283333 with Twilio |
| MHD-32266 | 2026-04-27 | 2026-05-03 | Closed | Investigate Twilio Calls - two named users |
| MHD-32114 | 2026-04-21 | 2026-04-24 | Closed | Unable to login |
| MHD-31785 | 2026-04-10 | 2026-04-20 | Closed | MME- 10002308576 / Customer is Not Receiving SMS |
| MHD-31779 | 2026-04-10 | 2026-04-15 | Closed | Unable to received SMS with Code |
| MHD-31787 | 2026-04-10 | 2026-04-13 | Closed | Investigate SMS delivery failure for customer verification codes via Twilio |
| MHD-31736 | 2026-04-08 | 2026-04-16 | Closed | SMS code not being sent |
| MHD-31437 | 2026-03-26 | 2026-04-01 | Closed | Check app 1323696 not receiving verification code |
| MHD-31255 | 2026-03-19 | 2026-03-19 | Closed | Investigate OTP delivery issue for broker password reset |
| MHD-31174 | 2026-03-17 | 2026-03-23 | Closed | Verification code issue |
| MHD-30759 | 2026-02-26 | 2026-07-02 | Closed | Twilio Inbound Queue Issue |
| MHD-30728 | 2026-02-25 | 2026-03-04 | Closed | Reset passcode comms |
| MHD-30577 | 2026-02-19 | 2026-02-19 | Closed | 10001649654 - MOM Login otp |
| MHD-30587 | 2026-02-19 | 2026-02-19 | Closed | MME / 10000720469 / Please reset the arrears balance |
| MHD-30418 | 2026-02-13 | 2026-02-13 | Closed | Investigate mobile number - 1011833 |
| MHD-30222 | 2026-02-05 | 2026-02-06 | Closed | Investigate OTP delivery issue for APY portal and Twilio call failure |
| MHD-30049 | 2026-01-30 | 2026-02-04 | Closed | 10001172781 - not receiving otp in app |
| MHD-29746 | 2026-01-20 | 2026-01-23 | Closed | Received an OTP without attempting to log in - 10002209267 |
| MHD-29756 | 2026-01-20 | 2026-01-21 | Closed | MME / Freestyle / 10001488953 / Reset of Arrears |
| MHD-29578 | 2026-01-15 | 2026-01-27 | Closed | LID: 10001456140 / Issue: Not receiving OTP |
| MHD-29565 | 2026-01-15 | 2026-02-04 | Closed | LID: 10002116511 & 10002451004 / Issue: Receiving OTP |
| MHD-29505 | 2026-01-12 | 2026-02-04 | Closed | Login otp - 10002409886 |
| MHD-29446 | 2026-01-08 | 2026-01-09 | Closed | requesting to reset the arrears balance please. I have spoken with customer yesterday and processed the full arrears bal |
| MHD-29069 | 2025-12-15 | 2025-12-15 | Closed | Investigate OTP delivery issue related to application ID 0 |
| MHD-28993 | 2025-12-10 | 2026-01-07 | Closed | Unable to receive SMS code for MME log in |
| MHD-28686 | 2025-12-03 | 2026-07-08 | Closed | Unauthorised Reset Passcode |
| MHD-28363 | 2025-11-19 | 2026-01-07 | Closed | LID: 10002676743 / Issue: Receiving OTP but number is not on file |
| MHD-28146 | 2025-11-07 | 2025-11-13 | Closed | PAYMENT / 10002583102 |
| MHD-28117 | 2025-11-06 | 2025-11-11 | Closed | System taking a long time to process payment / load; not able to process payment - 10001761030 |
| MHD-28069 | 2025-11-04 | - | Closed | Investigate Pending Payment Issue After OTP Processing |
| MHD-27706 | 2025-10-27 | 2025-11-27 | Closed | Investigate in Sendgrid - 10002634657 |
| MHD-27609 | 2025-10-21 | 2025-11-27 | Closed | Investigate in Sendgrid - 10002630711 |
| MHD-27588 | 2025-10-20 | 2025-10-29 | Closed | card payment did not clear/update the arrears 10001050645 |
| MHD-27277 | 2025-10-03 | 2025-10-13 | Closed | Investigate issue with outbound queue showing incomplete |
| MHD-27263 | 2025-10-02 | 2025-10-15 | Closed | Twillio call issue |
| MHD-27082 | 2025-09-22 | 2025-09-22 | Closed | [URGENT] S1 - 2000176817 (mobile number issue) |
| MHD-27006 | 2025-09-16 | 2025-09-17 | Closed | Next payment auto cancelled 10002273217 |
| MHD-26652 | 2025-09-05 | 2025-09-05 | Closed | PL (mobile app issue) - 10001500116 - card payment issue |
| MHD-26592 | 2025-09-03 | 2025-09-11 | Closed | Twilio Outbound Campaigns Issue |

### Login and passcode

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36714 | 2026-09-18 | 2026-09-18 | Closed | Email update |
| MHD-36680 | 2026-09-17 | 2026-09-17 | Closed | Email update |
| MHD-36641 | 2026-09-16 | 2026-09-16 | Closed | Unable to receive SMS verification code |
| MHD-36622 | 2026-09-15 | - | Pending | [SPV - Horizon2 DB] Release for G1-2762 - Fix Treasury team SPV Admin permission grouping (SpvAdmin grant) |
| MHD-36338 | 2026-09-04 | 2026-09-10 | Closed | Unable to login |
| MHD-36268 | 2026-09-03 | 2026-09-09 | Closed | Unable to login |
| MHD-36276 | 2026-09-03 | 2026-09-03 | Closed | For data fix |
| MHD-36263 | 2026-09-03 | 2026-09-03 | Closed | Move broker applications from inactive to active login for <broker email redacted> |
| MHD-36210 | 2026-09-01 | 2026-09-07 | Closed | Mobile number/Email does not match on our system |
| MHD-36186 | 2026-09-01 | 2026-09-07 | Closed | Unable to reset the passcode/ 10003075272 / PL |
| MHD-36193 | 2026-09-01 | 2026-09-07 | Closed | Unable to login - 10003070082 |
| MHD-36075 | 2026-08-27 | 2026-09-02 | Closed | Unable to login |
| MHD-36010 | 2026-08-25 | 2026-08-25 | Closed | Cant login 2000160645 |
| MHD-35955 | 2026-08-24 | 2026-08-30 | Closed | Unable to login or reset password |
| MHD-35889 | 2026-08-21 | 2026-08-26 | Closed | Log in |
| MHD-35853 | 2026-08-20 | 2026-08-26 | Closed | Not receiving SMS to login - 100029541490 |
| MHD-35867 | 2026-08-20 | 2026-08-20 | Closed | Unable to login |
| MHD-35866 | 2026-08-20 | 2026-08-26 | Closed | email update |
| MHD-35644 | 2026-08-14 | 2026-08-20 | Closed | Unable to login - 10002866545 |
| MHD-35643 | 2026-08-14 | 2026-08-17 | Closed | Cannot login on the app - 10002062136 |
| MHD-35589 | 2026-08-12 | 2026-08-19 | Closed | Login Issue (Migrated OzMoney CRD) - 10002954051 |
| MHD-35582 | 2026-08-12 | - | Selected for Development | Credit Limit Increase option is not visible on their account - 10002859953 |
| MHD-35475 | 2026-08-07 | 2026-08-16 | Closed | Unable to reset the passcode / CRD / 10002922217 |
| MHD-35478 | 2026-08-07 | 2026-08-10 | Closed | Unable to login |
| MHD-35418 | 2026-08-06 | 2026-08-12 | Closed | Unable to login |
| MHD-35362 | 2026-08-05 | 2026-08-05 | Closed | Investigate SMS login failure for customer application 10002405188 |
| MHD-35307 | 2026-08-03 | 2026-08-04 | Closed | Unable to login |
| MHD-35278 | 2026-08-01 | 2026-08-03 | Closed | APY / 10002457865 / Can't log in thru the app |
| MHD-35263 | 2026-07-31 | 2026-08-06 | Closed | Unable to login |
| MHD-35163 | 2026-07-29 | 2026-08-03 | Closed | Online Access |
| MHD-35120 | 2026-07-28 | 2026-08-03 | Closed | Login issue - 10002587374 |
| MHD-35116 | 2026-07-28 | 2026-07-28 | Closed | Unable to login |
| MHD-35074 | 2026-07-27 | 2026-07-27 | Closed | Unable to login |
| MHD-35039 | 2026-07-24 | 2026-07-27 | Closed | For data fix |
| MHD-35025 | 2026-07-24 | 2026-07-30 | Closed | SMS verification code is being sent to MOB ending in 000 / 10002666089 |
| MHD-34985 | 2026-07-23 | 2026-07-30 | Closed | Unauthorised OTP / 10002948860 / CRD |
| MHD-34956 | 2026-07-23 | 2026-07-29 | Closed | Unable to login |
| MHD-34959 | 2026-07-23 | 2026-07-23 | Closed | Cannot log in 10001987444 |
| MHD-34962 | 2026-07-23 | 2026-07-23 | Closed | Investigate reported delay or failure in mobile verification code delivery |
| MHD-34687 | 2026-07-15 | 2026-07-20 | Closed | Unable to login - 10003014103 |
| MHD-34655 | 2026-07-14 | 2026-07-15 | Closed | Cannot Login |
| MHD-34652 | 2026-07-14 | 2026-07-14 | Closed | Data Fix |
| MHD-34654 | 2026-07-14 | 2026-07-15 | Closed | Unable to login |
| MHD-34604 | 2026-07-13 | 2026-08-17 | Closed | Investigate incorrect login prompt for customer without active CRD account |
| MHD-34561 | 2026-07-10 | 2026-07-14 | Closed | LOG IN |
| MHD-34530 | 2026-07-09 | 2026-07-13 | Closed | Unable to login or reset password |
| MHD-34515 | 2026-07-09 | 2026-07-09 | Closed | Log in issue - 10002005535 |

### Arrears and overdue

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36808 | 2026-09-22 | - | Waiting for Customer | 10002955931- please reset the arrears showing on customer app amounting to $142.75. which according to customer on his e |
| MHD-36790 | 2026-09-22 | - | Waiting for Customer | did not auto move to FS / 10002108249 |
| MHD-36819 | 2026-09-22 | - | Waiting for Support | Autopay 10001453346 - Reset Arrears to $0 for Write off Account |
| MHD-36693 | 2026-09-17 | - | Waiting for Customer | BRAND (MME /PL) / 10003003669/ ISSUE DD was no cancelled |
| MHD-36602 | 2026-09-15 | 2026-09-15 | Closed | SocietyOne PL Broker , 10002127727 - Reset Arrears to $0 for Write off account |
| MHD-36600 | 2026-09-15 | 2026-09-16 | Closed | Investigate application stage transition failure to FS for LID 10002258706 |
| MHD-36618 | 2026-09-15 | 2026-09-17 | Closed | APY / 10002220007 / Add payment denied |
| MHD-36573 | 2026-09-14 | 2026-09-22 | Closed | CRD l LIDs 10002930479 & 10002931351 l Reset Arrears |
| MHD-36524 | 2026-09-11 | 2026-09-19 | Closed | 10001270587 - Check for the repayment |
| MHD-36494 | 2026-09-10 | 2026-09-14 | Closed | Zepto - Bulk Late Dishonour Recovery-Moneyme- CRU02Sep26-Processing Issue |
| MHD-36206 | 2026-09-01 | 2026-09-01 | Closed | Investigate incorrect $35 overdue fees for application 10002399667 |
| MHD-36071 | 2026-08-27 | 2026-09-02 | Closed | The repayment amount increased following a system adhoc shuffle. |
| MHD-36006 | 2026-08-25 | 2026-08-31 | Closed | incorrect payment amount after APR increase LID 10001520037 |
| MHD-35710 | 2026-08-17 | 2026-08-17 | Closed | Freestyle / Loan ID 10001030884 / Reset Arrears |
| MHD-35594 | 2026-08-12 | 2026-08-13 | Closed | REQUEST TO RESET OVERDUE BALANCE FOR 10000643023 |
| MHD-35578 | 2026-08-12 | 2026-08-12 | Closed | Applied Variation for WO account APY |
| MHD-35501 | 2026-08-10 | 2026-08-10 | Closed | MME- 10001536005 / Arrears Reset |
| MHD-35487 | 2026-08-08 | 2026-08-16 | Closed | Mobile App Issue - not showing overdue balance |
| MHD-35433 | 2026-08-06 | 2026-08-11 | Closed | Account Showing Arrears / 10002938447 |
| MHD-35381 | 2026-08-05 | 2026-08-23 | Closed | PP remains active after early payment allocated to arrears |
| MHD-35367 | 2026-08-05 | 2026-08-05 | Closed | MME / 10001303454 / Please reset the arrears balance |
| MHD-35206 | 2026-07-30 | 2026-07-30 | Closed | Reset arrears balance |
| MHD-35159 | 2026-07-29 | 2026-08-20 | Closed | CRD / 10002918836 / Refund caused the account to go in overdue |
| MHD-35161 | 2026-07-29 | 2026-08-06 | Closed | CRD 10002953884 Kindly confirm the reason a $10 payment was scheduled for 06/07/2026. |
| MHD-34761 | 2026-07-17 | 2026-07-23 | Closed | customer would like to understand why there are 2 reattempt payments processed on 03/07/2026 and 09/07/2026 which he alr |
| MHD-34738 | 2026-07-16 | 2026-07-16 | Closed | REQUEST TO RESET OVERDUE BALANCE FOR 10002381946 |
| MHD-34734 | 2026-07-16 | 2026-07-16 | Closed | Investigate account status transition to FS when arrears are paid in full |
| MHD-34635 | 2026-07-14 | 2026-07-14 | Closed | Reset arrears balance - MOM LOC account |
| MHD-34637 | 2026-07-14 | 2026-07-15 | Closed | CRD / 10002954126 / Card was accessible even though account has Arrears |
| MHD-34629 | 2026-07-14 | 2026-07-14 | Closed | REQUEST TO RESET OVERDUE BALANCE FOR 10001393282 |
| MHD-34602 | 2026-07-13 | 2026-08-20 | Closed | Investigate DPD repayment amount discrepancies following recent rate changes |
| MHD-34601 | 2026-07-13 | 2026-07-14 | Closed | Reset arrears balance - CRD account |
| MHD-34565 | 2026-07-10 | 2026-07-14 | Closed | PL / 10001219128 / Update Arrears Level |
| MHD-34516 | 2026-07-09 | 2026-07-14 | Closed | Applied Variation for WO account |
| MHD-34457 | 2026-07-07 | - | Closed | Freestyle / 10001220242 / Updating Arrears Risk |
| MHD-34064 | 2026-06-23 | 2026-06-23 | Closed | 10001185680 - reset incorrect arrears balance on the account |
| MHD-34000 | 2026-06-20 | 2026-06-28 | Closed | Rectified arrears 10000658440 |
| MHD-33839 | 2026-06-17 | 2026-06-17 | Closed | RESET ARREARS 10001136433 |
| MHD-33862 | 2026-06-17 | 2026-06-18 | Closed | Reset Arrears 10002469450 |
| MHD-33744 | 2026-06-12 | 2026-06-12 | Closed | 10001552674 - reset invalid arrears |
| MHD-33703 | 2026-06-11 | 2026-06-15 | Closed | APY 10001690721 - Apply contract vary for Write off account |
| MHD-33640 | 2026-06-10 | 2026-08-20 | Closed | LID: 10002954088 / Issue: reset arrears on account by marking overdue bill as inactive |
| MHD-33641 | 2026-06-10 | 2026-08-16 | Closed | Reset arrears/overdue on CRD |
| MHD-33653 | 2026-06-10 | 2026-06-10 | Closed | Reset arrears balance - LOC account |
| MHD-33638 | 2026-06-10 | 2026-08-20 | Closed | Request to reset Arrears 10002953898 |
| MHD-33603 | 2026-06-09 | 2026-08-17 | Closed | CRD / 10002954057 / Payment Plan Migration Issue |
| MHD-33537 | 2026-06-05 | 2026-06-16 | Closed | MME / 10002954117 / Disputing the arrears balance |

### Direct debit and dishonour

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36808 | 2026-09-22 | - | Waiting for Customer | 10002955931- please reset the arrears showing on customer app amounting to $142.75. which according to customer on his e |
| MHD-36790 | 2026-09-22 | - | Waiting for Customer | did not auto move to FS / 10002108249 |
| MHD-36766 | 2026-09-21 | - | Waiting for Customer | Direct debit error - 10002975361 |
| MHD-36693 | 2026-09-17 | - | Waiting for Customer | BRAND (MME /PL) / 10003003669/ ISSUE DD was no cancelled |
| MHD-36629 | 2026-09-16 | 2026-09-16 | Closed | Direct debit keeps on reversing even though its well-funded - 10002220007 |
| MHD-36623 | 2026-09-15 | 2026-09-16 | Closed | Investigate failure of direct debit account update for account ending 4909 |
| MHD-36618 | 2026-09-15 | 2026-09-17 | Closed | APY / 10002220007 / Add payment denied |
| MHD-36607 | 2026-09-15 | 2026-09-21 | Closed | PL / 10002964124 / Payments are being rejected "Add payment denied" |
| MHD-36494 | 2026-09-10 | 2026-09-14 | Closed | Zepto - Bulk Late Dishonour Recovery-Moneyme- CRU02Sep26-Processing Issue |
| MHD-36283 | 2026-09-03 | 2026-09-13 | Closed | Payment not cancelled_10002445060 |
| MHD-36011 | 2026-08-25 | 2026-09-01 | Closed | incorrect payment amount after APR increase LID 10001658530 |
| MHD-35890 | 2026-08-21 | 2026-08-25 | Closed | Direct debit not processed - 10002999471 |
| MHD-35813 | 2026-08-19 | 2026-08-19 | Closed | Investigate potential duplicate direct debit transactions for Zepto DDR Dispute |
| MHD-35707 | 2026-08-17 | 2026-08-18 | Closed | Investigate pending direct debit status for transaction 10003024147 |
| MHD-35631 | 2026-08-13 | 2026-09-07 | Closed | MME- 10002276534 / Add Payment Denied |
| MHD-35433 | 2026-08-06 | 2026-08-11 | Closed | Account Showing Arrears / 10002938447 |
| MHD-35381 | 2026-08-05 | 2026-08-23 | Closed | PP remains active after early payment allocated to arrears |
| MHD-35324 | 2026-08-04 | - | Waiting for Confirmation | App still showing upcoming repayments on DD instead of DC - 10001905418 |
| MHD-35160 | 2026-07-29 | 2026-08-10 | Closed | Direct Debit Investigation |
| MHD-35161 | 2026-07-29 | 2026-08-06 | Closed | CRD 10002953884 Kindly confirm the reason a $10 payment was scheduled for 06/07/2026. |
| MHD-35062 | 2026-07-27 | - | Selected for Development | Recurring Split Create/Update Account Tasks for CRD Accounts with Non-Split Sched Repayment |
| MHD-35019 | 2026-07-24 | 2026-07-30 | Closed | Freestyle Scheduled Repayment Not Cancelled After Early Custom Payment |
| MHD-34761 | 2026-07-17 | 2026-07-23 | Closed | customer would like to understand why there are 2 reattempt payments processed on 03/07/2026 and 09/07/2026 which he alr |
| MHD-34732 | 2026-07-16 | 2026-07-17 | Closed | Investigate direct debit stuck in proposed status for transaction 10002058837 |
| MHD-34447 | 2026-07-07 | 2026-07-13 | Closed | 10001276111 - MME+ account, why DD was processed on 06/07/2026, but it was not supposed to be debited until 30/07/2026. |
| MHD-34386 | 2026-07-03 | 2026-07-15 | Closed | Complaint Summary – System Investigation Request |
| MHD-34293 | 2026-07-01 | 2026-07-02 | Closed | Investigate Direct Debit payments stuck in 'Proposed' status |
| MHD-34168 | 2026-06-26 | 2026-07-02 | Closed | Default Payment Mode Change |
| MHD-34159 | 2026-06-26 | 2026-06-30 | Closed | MME / CRD / 10002905868 / Debit Card Sched Issue |
| MHD-34054 | 2026-06-23 | 2026-06-24 | Closed | Investigate pending direct debit status for transaction 10001429592 |
| MHD-34049 | 2026-06-23 | 2026-07-03 | Closed | 10002730231 |
| MHD-34034 | 2026-06-22 | 2026-06-30 | Closed | Direct Debit Payment |
| MHD-34010 | 2026-06-22 | 2026-06-24 | Closed | Request to investigate failed direct debit and payment processing issue |
| MHD-34014 | 2026-06-22 | 2026-06-29 | Closed | 10002954711 - Direct debit did not processed |
| MHD-33858 | 2026-06-17 | 2026-06-24 | Closed | 10002825335 - Discrepancy in Credit Limit |
| MHD-33775 | 2026-06-15 | 2026-06-22 | Closed | 10002126932 - Direct Debit Cancellation After Manual Payments |
| MHD-33210 | 2026-05-27 | 2026-06-03 | Closed | 10002867775 - App issue |
| MHD-33219 | 2026-05-27 | 2026-05-28 | Closed | Investigate pending direct debit status for transaction 10002398855 |
| MHD-33146 | 2026-05-25 | 2026-05-26 | Closed | 10002920823 - Check of Direct debit |
| MHD-32851 | 2026-05-15 | 2026-05-21 | Closed | MME- 10002757167 / Rejected Payments |
| MHD-32507 | 2026-05-05 | 2026-05-12 | Closed | MME / 10002115675 / Investigation request: No direct debit retry for 14.04 schedule |
| MHD-32466 | 2026-05-04 | 2026-05-06 | Closed | Amortization Tab is not updated |
| MHD-32065 | 2026-04-20 | 2026-04-20 | Closed | Investigate missing Zepto payment allocation for account 10002390611 |
| MHD-32080 | 2026-04-20 | 2026-04-21 | Closed | Perform data fix to update Zepto payment status to cleared for account 10002390611 |
| MHD-31973 | 2026-04-16 | 2026-04-17 | Closed | Investigate duplicate direct debit scheduling for account 10001715678 |
| MHD-31831 | 2026-04-13 | 2026-04-22 | Closed | unable to pay by debit card via app, online link and over the phone |
| MHD-31725 | 2026-04-08 | 2026-05-06 | Closed | No Direct Debit Charges |
| MHD-31613 | 2026-04-02 | 2026-06-19 | Closed | System Issue – Direct Debit Matter |
| MHD-31624 | 2026-04-02 | 2026-06-19 | Closed | 10002510425 - SMS reminder issue |
| MHD-31628 | 2026-04-02 | 2026-06-19 | Closed | System Issue – Direct Debit Matter |
| MHD-31625 | 2026-04-02 | 2026-04-07 | Closed | request to check dishonor fee applied to 10002756143 |
| MHD-31619 | 2026-04-02 | 2026-04-21 | Closed | Direct Debit keeps on failing |
| MHD-31460 | 2026-03-26 | 2026-03-26 | Closed | Reprocess funds to updated account for client |
| MHD-31424 | 2026-03-25 | 2026-03-27 | Closed | na |
| MHD-31221 | 2026-03-18 | 2026-03-18 | Closed | Investigate missing direct debit option for custom payments |
| MHD-31139 | 2026-03-16 | 2026-05-28 | Closed | Remove Dealer Bank Details from Customer Loan Agreement |
| MHD-31083 | 2026-03-12 | 2026-03-30 | Closed | Unable to add card in device |
| MHD-30962 | 2026-03-06 | 2026-03-09 | Closed | Autopay 10002254599 - Incorrect overdue amount on default notice |
| MHD-30926 | 2026-03-05 | 2026-03-05 | Closed | Zepto Late Dishonour- Bulk CBA 19 Jan and 29 Jan Bendigo Outage part 2 |
| MHD-30809 | 2026-03-02 | 2026-03-02 | Closed | APY / 10002282448 / Help to Review remaining other charge amount |
| MHD-30342 | 2026-02-11 | 2026-02-12 | Closed | Reverse cleared payments for Zepto late dishonour notifications |
| MHD-30348 | 2026-02-11 | 2026-02-11 | Closed | Zepto Late Return Recoveries 11.2.26 (31.12.25) |
| MHD-30110 | 2026-02-02 | - | Ongoing Development | DC upload tool issue |
| MHD-30048 | 2026-01-30 | 2026-03-03 | Closed | Zepto Late Dishonour- Bulk CBA 19 Jan and 29 Jan Bendigo Outage |

### Shuffle and amortisation

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36602 | 2026-09-15 | 2026-09-15 | Closed | SocietyOne PL Broker , 10002127727 - Reset Arrears to $0 for Write off account |
| MHD-36564 | 2026-09-14 | 2026-09-14 | Closed | Next repayment not showing and cust not getting debited - 10002065874 |
| MHD-36538 | 2026-09-11 | - | Waiting for Customer | Cancelled Repayment for 5 months |
| MHD-36494 | 2026-09-10 | 2026-09-14 | Closed | Zepto - Bulk Late Dishonour Recovery-Moneyme- CRU02Sep26-Processing Issue |
| MHD-36446 | 2026-09-09 | 2026-09-22 | Closed | SOC1 2000019464 Customer is asking why the payment was taken a year after her last payment - Split Sched 186.672 on 07/0 |
| MHD-36071 | 2026-08-27 | 2026-09-02 | Closed | The repayment amount increased following a system adhoc shuffle. |
| MHD-36006 | 2026-08-25 | 2026-08-31 | Closed | incorrect payment amount after APR increase LID 10001520037 |
| MHD-36011 | 2026-08-25 | 2026-09-01 | Closed | incorrect payment amount after APR increase LID 10001658530 |
| MHD-35875 | 2026-08-20 | 2026-08-26 | Closed | Repayment amount remains unchanged. |
| MHD-35653 | 2026-08-14 | 2026-08-19 | Closed | Incorrect final repayment date showing on the app_10003041310 |
| MHD-35504 | 2026-08-10 | 2026-08-12 | Closed | MME / 10003021630 / No Upcoming Repayment Showing in Transaction Tab |
| MHD-35363 | 2026-08-05 | 2026-08-05 | Closed | Investigate app - 10003026842 |
| MHD-35208 | 2026-07-30 | 2026-07-30 | Closed | Investigate missing amortization schedule for Transaction 10003028181 |
| MHD-34848 | 2026-07-20 | 2026-07-28 | Closed | MME PL / 10001808258 / Broker Fee enquiry |
| MHD-34725 | 2026-07-16 | 2026-07-17 | Closed | Process contract variation on accounts impacted by balloon payment APR increase issue |
| MHD-34677 | 2026-07-15 | 2026-07-15 | Closed | No loan agreement and repayments generated - 10002977847 |
| MHD-34602 | 2026-07-13 | 2026-08-20 | Closed | Investigate DPD repayment amount discrepancies following recent rate changes |
| MHD-34522 | 2026-07-09 | 2026-07-14 | Closed | Activate amortization - 10002460191 |
| MHD-34449 | 2026-07-07 | 2026-07-07 | Closed | Update interest rate for account 10003003090 |
| MHD-34389 | 2026-07-03 | 2026-07-13 | Closed | Investigation Request - Payment Debited During Approved Payment Pause |
| MHD-34386 | 2026-07-03 | 2026-07-15 | Closed | Complaint Summary – System Investigation Request |
| MHD-34321 | 2026-07-02 | 2026-07-25 | Closed | Unable to Shuffle on the 15th of the month |
| MHD-34131 | 2026-06-25 | 2026-06-26 | Closed | Unable to shuffle to the correct date |
| MHD-34036 | 2026-06-22 | 2026-06-22 | Closed | Update Interest Rate and Amort - 10002975232 |
| MHD-33862 | 2026-06-17 | 2026-06-18 | Closed | Reset Arrears 10002469450 |
| MHD-33786 | 2026-06-15 | 2026-06-16 | Closed | Investigate missing data in Amortization and Transactions tabs for account 10002957101 |
| MHD-33771 | 2026-06-15 | 2026-06-16 | Closed | Payment changes not reflecting in 2000 series email templates |
| MHD-33703 | 2026-06-11 | 2026-06-15 | Closed | APY 10001690721 - Apply contract vary for Write off account |
| MHD-33650 | 2026-06-10 | 2026-06-20 | Closed | Unable to reset passcode |
| MHD-33479 | 2026-06-04 | 2026-06-17 | Cancelled | MME / 10002952332 / Contract Variation Inquiry |
| MHD-33162 | 2026-05-26 | 2026-06-01 | Closed | Incorrect Scheduled Payment Amount – Request for Investigation |
| MHD-33133 | 2026-05-25 | 2026-05-26 | Closed | Investigate missing loan agreement and repayment schedules for application 10002922287 |
| MHD-33125 | 2026-05-25 | 2026-05-26 | Closed | Not in Funded Status - 10002903111 |
| MHD-33036 | 2026-05-21 | 2026-05-26 | Closed | Still showing account is overdue even though the status is Fund Sent |
| MHD-33009 | 2026-05-20 | 2026-05-21 | Closed | Cancel duplicated transactions and shuffle amortization for application 10002675969 |
| MHD-32852 | 2026-05-15 | 2026-05-15 | Closed | Cancel repayments of repaid app - 10002297006 |
| MHD-32848 | 2026-05-15 | 2026-06-15 | Closed | MME / 2000169330 / PL Broker / April 15,2026 Still on Pending on DPD Header |
| MHD-32731 | 2026-05-12 | 2026-05-19 | Closed | Waive establishment fees for requested accounts |
| MHD-32598 | 2026-05-07 | 2026-05-13 | Closed | Shuffle issue - 10002114878 |
| MHD-32507 | 2026-05-05 | 2026-05-12 | Closed | MME / 10002115675 / Investigation request: No direct debit retry for 14.04 schedule |
| MHD-32466 | 2026-05-04 | 2026-05-06 | Closed | Amortization Tab is not updated |
| MHD-32392 | 2026-04-30 | 2026-04-30 | Closed | Edit type in Amortization tab |
| MHD-32210 | 2026-04-23 | 2026-04-24 | Closed | 2000123163 - Payment Allocation Request - Please allocate payment $3,534.54 from account 2000123163 to LID 10001685679.  |
| MHD-32196 | 2026-04-23 | 2026-05-04 | Closed | System Issue – Duplicate Payment Debited |
| MHD-32134 | 2026-04-21 | 2026-04-29 | Closed | incomplete repayment plan LID 10001505640 Freestyle credit card account |
| MHD-32021 | 2026-04-17 | 2026-04-20 | Closed | Repayments showing incorrectly on app |
| MHD-31974 | 2026-04-16 | 2026-06-19 | Closed | Repayments increased - 10001234363 |
| MHD-31915 | 2026-04-15 | - | Selected for Development | Overdue still showing after contract variation - 10001661291 |
| MHD-31732 | 2026-04-08 | 2026-04-09 | Closed | 10002578776 Reset of arrears |
| MHD-31716 | 2026-04-08 | 2026-04-09 | Closed | 10001586457 Reset of arrears for 299.69 |
| MHD-31738 | 2026-04-08 | 2026-05-17 | Closed | 10001749537 - The amount remains fixed at $300 after shuffling account from minimum payment $300 FN to Monthly. |
| MHD-31624 | 2026-04-02 | 2026-06-19 | Closed | 10002510425 - SMS reminder issue |
| MHD-31364 | 2026-03-23 | 2026-03-30 | Closed | Discrepancy on next scheduled repayments |
| MHD-31109 | 2026-03-13 | 2026-03-18 | Closed | Unable to shuffle payment |
| MHD-31110 | 2026-03-13 | 2026-03-18 | Closed | Unable to shuffle payment |
| MHD-31062 | 2026-03-12 | 2026-03-18 | Closed | MME / PL/ 10001862560 / Total Arrears Review |
| MHD-31024 | 2026-03-10 | 2026-05-28 | Closed | Visual bug on conditional offer |
| MHD-30996 | 2026-03-09 | 2026-03-16 | Closed | SYSTEM RECALCULATION / 10002667651 |
| MHD-30926 | 2026-03-05 | 2026-03-05 | Closed | Zepto Late Dishonour- Bulk CBA 19 Jan and 29 Jan Bendigo Outage part 2 |
| MHD-30830 | 2026-03-02 | 2026-03-03 | Closed | Reset Arrears for PL Account - Loan ID 10001336412 |
| MHD-30536 | 2026-02-18 | 2026-02-18 | Closed | Investigate missing funding email notification to broker |
| MHD-30379 | 2026-02-12 | - | Cancelled | Unable to set up reduced payment arrangement and shuffle schedule |
| MHD-30381 | 2026-02-12 | 2026-02-13 | Closed | Unable to set up the arrangement in Amort Tab |
| MHD-30370 | 2026-02-12 | 2026-02-13 | Closed | unable to shuffle 10001485548 |
| MHD-30404 | 2026-02-12 | 2026-03-23 | Closed | Account shuffle issue - 1000110436 |
| MHD-30258 | 2026-02-06 | 2026-02-06 | Closed | Repayment on Freestyle has increased after Adhoc Shuffle - 10001620977 |
| MHD-30246 | 2026-02-06 | 2026-02-06 | Closed | 10002756061 - Investigate task: review - contract sending failed |
| MHD-30262 | 2026-02-06 | 2026-02-10 | Closed | arrears reset 10001816254 |
| MHD-30256 | 2026-02-06 | 2026-02-06 | Closed | Autopay 10001376181 - Update Payment Method to Direct Credit |
| MHD-30000 | 2026-01-28 | 2026-01-30 | Closed | MME / PL / 10002345022 / DPD Repayment Amount Inquiry |
| MHD-29542 | 2026-01-14 | 2026-01-14 | Closed | Next payment amount is being doubled - 10002126138 |
| MHD-29405 | 2026-01-06 | 2026-07-08 | Closed | SHUFFLE PAYMENT SCHEDULE FOR ACCOUNT 10001171653 |
| MHD-29296 | 2025-12-29 | 2025-12-30 | Closed | 10002459136 / Shuffle issue |
| MHD-28401 | 2025-11-20 | 2025-12-01 | Closed | Unable to shuffle 250 FN from 03/12/2025 |
| MHD-28331 | 2025-11-18 | 2025-11-20 | Closed | Unable to shuffle - 10001580382 |
| MHD-28244 | 2025-11-12 | 2026-02-15 | Closed | Investigate 10001187195 - scheduled repayment cancelled by redraw shuffle |
| MHD-28152 | 2025-11-07 | 2025-11-18 | Closed | Shuffle issue |
| MHD-27965 | 2025-10-30 | 2026-01-07 | Closed | Payment schedule stopped for 6months |
| MHD-27416 | 2025-10-11 | 2025-10-13 | Closed | Change Payment schedule |
| MHD-27043 | 2025-09-18 | 2025-09-18 | Closed | Payments in Transaction tab did not reflect after shuffle - 10002547581 |
| MHD-26895 | 2025-09-09 | 2025-09-09 | Closed | Incorrect fortnight amounts on the System - Adhoc Shuffle request |

### Funding and settlement

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36808 | 2026-09-22 | - | Waiting for Customer | 10002955931- please reset the arrears showing on customer app amounting to $142.75. which according to customer on his e |
| MHD-36790 | 2026-09-22 | - | Waiting for Customer | did not auto move to FS / 10002108249 |
| MHD-36797 | 2026-09-22 | 2026-09-22 | Closed | Data Fix: Update missing Transaction IDs for funding records |
| MHD-36712 | 2026-09-18 | 2026-09-18 | Closed | Insert Equifax Score |
| MHD-36686 | 2026-09-17 | 2026-09-17 | Closed | URGENT: Caravan lead source change and bank detail confirmation for application 10003078375 |
| MHD-36693 | 2026-09-17 | - | Waiting for Customer | BRAND (MME /PL) / 10003003669/ ISSUE DD was no cancelled |
| MHD-36658 | 2026-09-16 | 2026-09-17 | Closed | Fix Review - Refund Funding Error 'No Bank Account' for Application 10002815000 |
| MHD-36635 | 2026-09-16 | 2026-09-18 | Closed | Not received SOA |
| MHD-36653 | 2026-09-16 | 2026-09-17 | Closed | Update Lead Source and Bank Details for Application 10003094246 |
| MHD-36629 | 2026-09-16 | 2026-09-16 | Closed | Direct debit keeps on reversing even though its well-funded - 10002220007 |
| MHD-36668 | 2026-09-16 | 2026-09-18 | Closed | Investigate delayed settlement confirmation emails for repaid loan 10003015808 |
| MHD-36609 | 2026-09-15 | 2026-09-15 | Closed | Investigate and resolve application stuck at 'Signed Off' status |
| MHD-36600 | 2026-09-15 | 2026-09-16 | Closed | Investigate application stage transition failure to FS for LID 10002258706 |
| MHD-36559 | 2026-09-14 | 2026-09-14 | Closed | Insert equifax score for the following apps |
| MHD-36446 | 2026-09-09 | 2026-09-22 | Closed | SOC1 2000019464 Customer is asking why the payment was taken a year after her last payment - Split Sched 186.672 on 07/0 |
| MHD-36412 | 2026-09-08 | 2026-09-08 | Closed | Reprocess application 10003083568 for funding |
| MHD-36393 | 2026-09-07 | 2026-09-07 | Closed | Check funding status and cancel funding record for Application 10002983715 and 10003068489 |
| MHD-36265 | 2026-09-03 | 2026-09-09 | Closed | MME CRD / 10002929090 / Debit Card was not accepting as mode of payment |
| MHD-36240 | 2026-09-02 | 2026-09-08 | Closed | Investigate VIN synchronization issue across multiple Funded applications in Horizon |
| MHD-36238 | 2026-09-02 | 2026-09-03 | Closed | Repaid date fix |
| MHD-36243 | 2026-09-02 | - | Pending | 10002927664 |
| MHD-36129 | 2026-08-28 | 2026-09-01 | Closed | Insert Equifax Score - 10003068611 |
| MHD-36075 | 2026-08-27 | 2026-09-02 | Closed | Unable to login |
| MHD-36041 | 2026-08-26 | 2026-08-26 | Closed | Insert Equifax Score - 10003065687 |
| MHD-35966 | 2026-08-24 | - | Waiting for Customer | CRD / Loan ID 10002926516 / Payment Reversal Request |
| MHD-35899 | 2026-08-21 | 2026-08-21 | Closed | Freestyle / 10001332267 / SOA request |
| MHD-35896 | 2026-08-21 | 2026-08-21 | Closed | Insert Equifax Score - 10003059315 |
| MHD-35921 | 2026-08-21 | 2026-08-21 | Closed | Run stored procedure for deletion of funding records for application 10003056301 |
| MHD-35904 | 2026-08-21 | 2026-08-21 | Closed | Run FundingDataFixUpdateTransactionId script for missing TransactionIds |
| MHD-35863 | 2026-08-20 | 2026-08-20 | Closed | Data fix for Application 10003038152 stuck in Signed Off status |
| MHD-35793 | 2026-08-19 | 2026-09-01 | Closed | Luxury escapes card is getting the incorrect Funded CRD template - 10003058217 |
| MHD-35748 | 2026-08-18 | 2026-08-19 | Closed | MME PL / 10002412862 / Reason of Payment Stopped |
| MHD-35709 | 2026-08-17 | 2026-08-17 | Closed | Insert Equifax Score - 10003045475 |
| MHD-35694 | 2026-08-17 | 2026-08-17 | Closed | Data fix for disbursement mismatch on Application 10003048093 |
| MHD-35722 | 2026-08-17 | 2026-08-24 | Closed | PayAnyone Transaction |
| MHD-35658 | 2026-08-14 | 2026-08-17 | Closed | Investigate Contract Sending Failed - 10003050872 |
| MHD-35633 | 2026-08-13 | 2026-08-14 | Closed | Funding follow up task - 10003047361 |
| MHD-35571 | 2026-08-12 | 2026-08-12 | Closed | Insert Equifax Score - 10003044093 |
| MHD-35537 | 2026-08-11 | 2026-08-11 | Closed | Investigate Contract Sending Failed - 10003041204 |
| MHD-35497 | 2026-08-10 | 2026-08-10 | Closed | Insert equifax score - 10003033377 10003039821 |
| MHD-35433 | 2026-08-06 | 2026-08-11 | Closed | Account Showing Arrears / 10002938447 |
| MHD-35363 | 2026-08-05 | 2026-08-05 | Closed | Investigate app - 10003026842 |
| MHD-35379 | 2026-08-05 | 2026-08-05 | Closed | Investigate 'refer_to_split' rejection for customer transaction 10001898419 |
| MHD-35193 | 2026-07-30 | 2026-07-30 | Closed | Investigate missing settlement emails for application 10003026626 |
| MHD-34489 | 2026-07-08 | 2026-07-10 | Closed | Perform datafix for application funding due to incorrect disbursement details |
| MHD-34018 | 2026-06-22 | 2026-06-23 | Closed | Investigate delay in 2nd retry payment attempt for transaction 10002278919 |
| MHD-33741 | 2026-06-12 | 2026-06-12 | Closed | Investigate application stuck in 'app-esign accepted' stage - App ID 10002952353 |
| MHD-33742 | 2026-06-12 | 2026-06-16 | Closed | Investigate application stuck in pre-settlement status - 10002965566 |
| MHD-33293 | 2026-05-29 | 2026-06-01 | Closed | Investigate missing settlement emails for broker and customer |
| MHD-32156 | 2026-04-22 | 2026-04-22 | Closed | Fix Transaction - 10001515721 |
| MHD-31677 | 2026-04-07 | 2026-04-07 | Closed | Stuck in app esign accepted - 10002841788 |
| MHD-30935 | 2026-03-05 | 2026-03-05 | Closed | Investigate and resolve issue with account stage rollback |
| MHD-30830 | 2026-03-02 | 2026-03-03 | Closed | Reset Arrears for PL Account - Loan ID 10001336412 |
| MHD-30741 | 2026-02-26 | 2026-03-04 | Closed | Discrepancy in Outstanding balance and remaining scheduled repayments |
| MHD-30425 | 2026-02-13 | 2026-02-22 | Closed | Check app - 10002761739 |
| MHD-28069 | 2025-11-04 | - | Closed | Investigate Pending Payment Issue After OTP Processing |
| MHD-28030 | 2025-11-03 | 2025-12-22 | Closed | Discrepancy Between App Balance and Horizon Balance 10002203681 |

### Refund and reversal

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36808 | 2026-09-22 | - | Waiting for Customer | 10002955931- please reset the arrears showing on customer app amounting to $142.75. which according to customer on his e |
| MHD-36693 | 2026-09-17 | - | Waiting for Customer | BRAND (MME /PL) / 10003003669/ ISSUE DD was no cancelled |
| MHD-36658 | 2026-09-16 | 2026-09-17 | Closed | Fix Review - Refund Funding Error 'No Bank Account' for Application 10002815000 |
| MHD-36629 | 2026-09-16 | 2026-09-16 | Closed | Direct debit keeps on reversing even though its well-funded - 10002220007 |
| MHD-36617 | 2026-09-15 | 2026-09-15 | Closed | Update transaction - 10002478022 |
| MHD-36573 | 2026-09-14 | 2026-09-22 | Closed | CRD l LIDs 10002930479 & 10002931351 l Reset Arrears |
| MHD-36494 | 2026-09-10 | 2026-09-14 | Closed | Zepto - Bulk Late Dishonour Recovery-Moneyme- CRU02Sep26-Processing Issue |
| MHD-36446 | 2026-09-09 | 2026-09-22 | Closed | SOC1 2000019464 Customer is asking why the payment was taken a year after her last payment - Split Sched 186.672 on 07/0 |
| MHD-36280 | 2026-09-03 | 2026-09-07 | Closed | Reverse payments and remove from SOA |
| MHD-36243 | 2026-09-02 | - | Pending | 10002927664 |
| MHD-36077 | 2026-08-27 | 2026-08-27 | Closed | Perform datafix for reverse write-off |
| MHD-35969 | 2026-08-24 | 2026-08-26 | Closed | Perform datafix for reverse write-off |
| MHD-35966 | 2026-08-24 | - | Waiting for Customer | CRD / Loan ID 10002926516 / Payment Reversal Request |
| MHD-35425 | 2026-08-06 | 2026-08-12 | Closed | 107634742 |
| MHD-35381 | 2026-08-05 | 2026-08-23 | Closed | PP remains active after early payment allocated to arrears |
| MHD-35353 | 2026-08-05 | 2026-08-06 | Closed | Incorrect display showing on reversal |
| MHD-35159 | 2026-07-29 | 2026-08-20 | Closed | CRD / 10002918836 / Refund caused the account to go in overdue |
| MHD-34822 | 2026-07-20 | 2026-07-20 | Closed | 10002829245 - Reversal & Correct Fix |
| MHD-34374 | 2026-07-03 | 2026-08-07 | Closed | Horizon - Need to refresh CRD tab sometimes to get the fields populated |
| MHD-34386 | 2026-07-03 | 2026-07-15 | Closed | Complaint Summary – System Investigation Request |
| MHD-34021 | 2026-06-22 | 2026-06-22 | Closed | Investigate missing excess balance for transaction 10002640675 |
| MHD-33294 | 2026-05-29 | 2026-05-29 | Closed | Reverse duplicate refund transaction for account 10001320825 |
| MHD-32196 | 2026-04-23 | 2026-05-04 | Closed | System Issue – Duplicate Payment Debited |
| MHD-31613 | 2026-04-02 | 2026-06-19 | Closed | System Issue – Direct Debit Matter |
| MHD-30586 | 2026-02-19 | 2026-02-19 | Closed | Investigate and resolve unprocessed System - Refund Loan tasks |
| MHD-28907 | 2025-12-08 | 2025-12-08 | Closed | Batch process Zepto refunds |
| MHD-28340 | 2025-11-18 | 2025-11-19 | Closed | 10001336079 - loan has been fully repaid and the account is closed. The system shows an Excess amount of $1,074.49 and a |

### Broker and partner

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36635 | 2026-09-16 | 2026-09-18 | Closed | Not received SOA |
| MHD-36668 | 2026-09-16 | 2026-09-18 | Closed | Investigate delayed settlement confirmation emails for repaid loan 10003015808 |
| MHD-36602 | 2026-09-15 | 2026-09-15 | Closed | SocietyOne PL Broker , 10002127727 - Reset Arrears to $0 for Write off account |
| MHD-36527 | 2026-09-11 | 2026-09-11 | Closed | Investigate email - 10003084677 |
| MHD-36467 | 2026-09-09 | 2026-09-10 | Closed | Manually add a broker user in S1 |
| MHD-36442 | 2026-09-09 | 2026-09-09 | Closed | Delete bank account 06867 - 10003069999 |
| MHD-36407 | 2026-09-08 | - | Waiting for Confirmation | Investigate email - 10003052183 |
| MHD-36263 | 2026-09-03 | 2026-09-03 | Closed | Move broker applications from inactive to active login for <broker email redacted> |
| MHD-36154 | 2026-08-31 | 2026-09-01 | Closed | [APY] [UP TO 27/08/26] Broker uploaded incorrect documents on customers file |
| MHD-36009 | 2026-08-25 | 2026-08-25 | Closed | MME PL Broker / 10003012512 / Old Email Still Pop Up after updating with new one |
| MHD-36007 | 2026-08-25 | 2026-08-26 | Closed | Investigate in sendgrid - 10003064185 |
| MHD-35799 | 2026-08-19 | - | Pending | Horizon: add a button to remove an email address from the SendGrid suppression lists (Bounced / Blocked / Spam) |
| MHD-35818 | 2026-08-19 | 2026-08-20 | Closed | Investigate and fix infinite loading on 'calculating your finance details' section |
| MHD-35691 | 2026-08-17 | 2026-08-17 | Closed | [APY] [UP TO 14/08/26] Broker uploaded incorrect documents on customers file |
| MHD-35658 | 2026-08-14 | 2026-08-17 | Closed | Investigate Contract Sending Failed - 10003050872 |
| MHD-35666 | 2026-08-14 | 2026-08-17 | Closed | Investigate in sendgrid - 10003051293 |
| MHD-35305 | 2026-08-03 | 2026-08-04 | Closed | Update dealership lead source - 10003037855 |
| MHD-35193 | 2026-07-30 | 2026-07-30 | Closed | Investigate missing settlement emails for application 10003026626 |
| MHD-35200 | 2026-07-30 | 2026-07-30 | Closed | Transfer applications 10002890830 and 10002861918 to another broker |
| MHD-35112 | 2026-07-28 | 2026-07-28 | Closed | [APY] [UP TO 27/07/26] Broker uploaded incorrect documents on customers file |
| MHD-34981 | 2026-07-23 | 2026-07-23 | Closed | Investigate email in Sendgrid - 10003024955 |

### Write-off

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36819 | 2026-09-22 | - | Waiting for Support | Autopay 10001453346 - Reset Arrears to $0 for Write off Account |
| MHD-36602 | 2026-09-15 | 2026-09-15 | Closed | SocietyOne PL Broker , 10002127727 - Reset Arrears to $0 for Write off account |
| MHD-36446 | 2026-09-09 | 2026-09-22 | Closed | SOC1 2000019464 Customer is asking why the payment was taken a year after her last payment - Split Sched 186.672 on 07/0 |
| MHD-36077 | 2026-08-27 | 2026-08-27 | Closed | Perform datafix for reverse write-off |
| MHD-35969 | 2026-08-24 | 2026-08-26 | Closed | Perform datafix for reverse write-off |
| MHD-35799 | 2026-08-19 | - | Pending | Horizon: add a button to remove an email address from the SendGrid suppression lists (Bounced / Blocked / Spam) |
| MHD-33703 | 2026-06-11 | 2026-06-15 | Closed | APY 10001690721 - Apply contract vary for Write off account |
| MHD-32859 | 2026-05-15 | 2026-05-19 | Closed | Reverse bankruptcy write-off transaction for account 10002429438 |
| MHD-32161 | 2026-04-22 | 2026-04-22 | Closed | REverse writeoff - 10001515721 |
| MHD-31716 | 2026-04-08 | 2026-04-09 | Closed | 10001586457 Reset of arrears for 299.69 |
| MHD-31732 | 2026-04-08 | 2026-04-09 | Closed | 10002578776 Reset of arrears |
| MHD-31457 | 2026-03-26 | 2026-03-26 | Closed | Freestyle 10001261923 - Removed arrears to write-off account |
| MHD-31354 | 2026-03-23 | 2026-03-24 | Closed | PL Broker 10001637753 - Reset arrears to Zero (Write-off) |
| MHD-30935 | 2026-03-05 | 2026-03-05 | Closed | Investigate and resolve issue with account stage rollback |

### Equifax / credit score

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36712 | 2026-09-18 | 2026-09-18 | Closed | Insert Equifax Score |
| MHD-36713 | 2026-09-18 | 2026-09-18 | Closed | Removal of IDM re run file in applications 10002893477 and 10002965230 |
| MHD-36559 | 2026-09-14 | 2026-09-14 | Closed | Insert equifax score for the following apps |
| MHD-36129 | 2026-08-28 | 2026-09-01 | Closed | Insert Equifax Score - 10003068611 |
| MHD-36041 | 2026-08-26 | 2026-08-26 | Closed | Insert Equifax Score - 10003065687 |
| MHD-35896 | 2026-08-21 | 2026-08-21 | Closed | Insert Equifax Score - 10003059315 |
| MHD-35814 | 2026-08-19 | 2026-08-25 | Closed | Credit score |
| MHD-35709 | 2026-08-17 | 2026-08-17 | Closed | Insert Equifax Score - 10003045475 |
| MHD-35708 | 2026-08-17 | 2026-08-24 | Closed | Data Fix |
| MHD-35571 | 2026-08-12 | 2026-08-12 | Closed | Insert Equifax Score - 10003044093 |
| MHD-35497 | 2026-08-10 | 2026-08-10 | Closed | Insert equifax score - 10003033377 10003039821 |
| MHD-35372 | 2026-08-05 | 2026-09-17 | Closed | Removal of credit file and IDMatrix reports |
| MHD-35187 | 2026-07-30 | 2026-07-30 | Closed | Insert Equifax - 10003030118 |
| MHD-35155 | 2026-07-29 | 2026-07-29 | Closed | Insert Equifax Score |
| MHD-35077 | 2026-07-27 | 2026-07-27 | Closed | Insert Equifax Score - 10003023845 |
| MHD-34765 | 2026-07-17 | 2026-07-17 | Closed | Investigate funded application 10003014669 missing Equifax score |
| MHD-34362 | 2026-07-03 | 2026-07-03 | Closed | Insert Equifax Score - 2 |
| MHD-34324 | 2026-07-02 | 2026-08-07 | Closed | Insert Equifax Score - 10002993629 |
| MHD-34285 | 2026-07-01 | 2026-07-01 | Closed | Insert Equifax Score - 10002992742 |
| MHD-34204 | 2026-06-29 | 2026-06-29 | Closed | Insert Equifax Scores - 2 |
| MHD-34091 | 2026-06-24 | 2026-06-24 | Closed | Insert Equifax Score - 10002974966 |
| MHD-34011 | 2026-06-22 | 2026-07-02 | Closed | MONEYME Credit Score |
| MHD-33837 | 2026-06-17 | 2026-06-17 | Closed | Insert Equifax Score - 10002963488 |
| MHD-33781 | 2026-06-15 | 2026-06-15 | Closed | Insert Equifax Score |
| MHD-33738 | 2026-06-12 | 2026-06-21 | Closed | MONEYME Credit Score |
| MHD-33355 | 2026-06-01 | 2026-06-01 | Closed | Insert Equifax Score for migrated CRDs |
| MHD-33124 | 2026-05-25 | 2026-05-28 | Closed | Get and insert Equifax score |
| MHD-33029 | 2026-05-21 | 2026-05-21 | Closed | Insert equifax score to apps |
| MHD-32897 | 2026-05-18 | 2026-05-20 | Closed | Add Equifax score to list of apps |
| MHD-32187 | 2026-04-23 | 2026-04-23 | Closed | Insert Equifax Scores for the ff apps |
| MHD-32159 | 2026-04-22 | 2026-09-08 | Closed | Credit Score not updated in the app |
| MHD-32106 | 2026-04-21 | 2026-04-21 | Closed | Insert Equifax score - 10002855484 |
| MHD-31816 | 2026-04-13 | 2026-04-13 | Closed | Insert Equifax scores for Apps: 10002845932 , 10002847420 |
| MHD-31778 | 2026-04-10 | 2026-04-10 | Closed | Insert Equifax scores for Apps: 10002843531, 10002845051 |
| MHD-31687 | 2026-04-07 | 2026-04-07 | Closed | File Removal Request 10002834084 |
| MHD-31346 | 2026-03-23 | 2026-03-23 | Closed | Insert Equifax score to apps |
| MHD-30988 | 2026-03-09 | 2026-03-09 | Closed | Investigate funded apps without Equifax score |
| MHD-30862 | 2026-03-03 | 2026-03-11 | Closed | Investigate customer's loan amount discrepancy |
| MHD-30810 | 2026-03-02 | 2026-03-02 | Closed | Insert Equifax Score - 10002788999 |
| MHD-30739 | 2026-02-26 | 2026-02-26 | Closed | Update Equifax Score - 10002790629 |
| MHD-30500 | 2026-02-17 | 2026-02-17 | Closed | Add Equifax Score - 10002769011 |
| MHD-30372 | 2026-02-12 | 2026-02-12 | Closed | Insert Equifax Score - 10002763787 |
| MHD-29829 | 2026-01-22 | 2026-01-22 | Closed | 10002741718 - Insert Equifax Score ver 3 |

### Hardship

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36270 | 2026-09-03 | 2026-09-08 | Closed | Unable to implement hardship arrangement |
| MHD-36071 | 2026-08-27 | 2026-09-02 | Closed | The repayment amount increased following a system adhoc shuffle. |
| MHD-35690 | 2026-08-17 | 2026-08-23 | Closed | 10002755169 - Unable to submit the Hardship form |
| MHD-34761 | 2026-07-17 | 2026-07-23 | Closed | customer would like to understand why there are 2 reattempt payments processed on 03/07/2026 and 09/07/2026 which he alr |
| MHD-34601 | 2026-07-13 | 2026-07-14 | Closed | Reset arrears balance - CRD account |
| MHD-34321 | 2026-07-02 | 2026-07-25 | Closed | Unable to Shuffle on the 15th of the month |
| MHD-33537 | 2026-06-05 | 2026-06-16 | Closed | MME / 10002954117 / Disputing the arrears balance |
| MHD-33488 | 2026-06-04 | 2026-06-10 | Closed | Email Bounced Multiple times yesterday |
| MHD-33246 | 2026-05-28 | 2026-06-03 | Closed | Investigate stage progression error for CRD account 10002918145 |
| MHD-32466 | 2026-05-04 | 2026-05-06 | Closed | Amortization Tab is not updated |
| MHD-31774 | 2026-04-10 | 2026-04-16 | Closed | 10002260756 stage movement review |
| MHD-31062 | 2026-03-12 | 2026-03-18 | Closed | MME / PL/ 10001862560 / Total Arrears Review |
| MHD-30961 | 2026-03-06 | 2026-03-15 | Closed | System Debiting Incorrect Hardship Arrangement Amount 10000796502 |
| MHD-30381 | 2026-02-12 | 2026-02-13 | Closed | Unable to set up the arrangement in Amort Tab |
| MHD-30000 | 2026-01-28 | 2026-01-30 | Closed | MME / PL / 10002345022 / DPD Repayment Amount Inquiry |

### Autopay

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36819 | 2026-09-22 | - | Waiting for Support | Autopay 10001453346 - Reset Arrears to $0 for Write off Account |
| MHD-36668 | 2026-09-16 | 2026-09-18 | Closed | Investigate delayed settlement confirmation emails for repaid loan 10003015808 |
| MHD-36276 | 2026-09-03 | 2026-09-03 | Closed | For data fix |
| MHD-35959 | 2026-08-24 | 2026-08-30 | Closed | Unable to Forward Email |
| MHD-33407 | 2026-06-02 | 2026-06-08 | Closed | Unable to reset Password |
| MHD-32689 | 2026-05-11 | 2026-08-20 | Closed | Special Handling - APY enable account manager |
| MHD-31877 | 2026-04-14 | 2026-04-14 | Closed | Cannot see car loan on the app - 10002815976 / 10002453373 |

### Brand / contact data

| Key | Created | Resolved | Status | Summary |
| --- | --- | --- | --- | --- |
| MHD-36071 | 2026-08-27 | 2026-09-02 | Closed | The repayment amount increased following a system adhoc shuffle. |
| MHD-35970 | 2026-08-24 | 2026-08-24 | Closed | Investigate application stage regression from Signed Off to E-Sign |
| MHD-35757 | 2026-08-18 | 2026-08-18 | Closed | Insert BrandId 5 contact and email to 10003052056 |
| MHD-32267 | 2026-04-27 | 2026-04-28 | Closed | Loan agreement not sent to the broker - 10002867333 |
| MHD-30694 | 2026-02-24 | 2026-03-03 | Closed | Check email - 2000124974 |
