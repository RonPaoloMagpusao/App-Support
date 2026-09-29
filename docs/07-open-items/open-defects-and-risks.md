# Open defects and risks

Unresolved systemic risks and known defects, tiered by customer money and regulatory exposure.

Last reviewed: 23 September 2026
Sources: Jira MHD, Slack, investigation notes

Everything below is either an open ticket, a defect found during investigation that was never given a ticket, or a fix that is agreed but not built. Sorted by how much harm it can do.

Counts as at 2026-09-23. There are **42 Problem tickets** in the window that are not in a Done status category and not sitting in "Waiting for Support". Several have been open for close to a year.

---

## Tier 1: customer money or regulatory exposure

### 1.1 Adhoc shuffle does not convert the repayment amount when frequency changes

**Tickets:** MHD-36071, MHD-30258, MHD-31738, MHD-35875. All closed, none fixed.

Four reports in seven months. Changing frequency relabels the schedule without recalculating the instalment, so the customer is scheduled to be debited a monthly amount at fortnightly frequency, or the reverse.

On MHD-36071 that would have taken $12,784.80 a year to $28,537.55 a year, a **123 per cent increase**, on a customer who had exited hardship three days earlier. It was caught only because the reporter escalated. There is no detection for this; it surfaces when someone notices.

**Why it is not fixed:** the accepted position is that Freestyle is being discontinued and hardship applications will be migrated, so no fix is expected. The workaround, a continuous payment setting at the correct amount, was confirmed by Josh Allen on MHD-30258 as "the only option we have in this case".

**The risk that position does not cover:** the workaround depends on somebody noticing. Between MHD-30258 in February and MHD-36071 in August, no detection was added. Any shuffled account where nobody looked was debited the wrong amount. **Nobody has run a query across shuffled accounts to find out how many.** That is the single highest-value piece of work suggested by this harvest.

**Do not confuse this with** the fix released 14/05/2026 referenced on MHD-31974, which addressed shuffles overriding existing arrangements. Different failure mode.

### 1.2 Mobile app understates the contracted loan term

**Ticket:** MHD-36092, Selected for Development. Linked MMM-16301, To Do. No fix date.

The app shows "3 years" for a 43-month loan. The credit contract and the customer's email both say 43 months. This is a **disclosure mismatch against a legal document**, not a cosmetic bug, and it affects every loan whose term is not a whole number of years. PL terms of 42 and 43 months appeared in two consecutive tickets, so the population is not small.

**Blocking decision:** two viable fixes exist and nobody has picked one.
1. Correct what the API's `DurationInYears` field returns (the RCA's stated ownership, Backend).
2. Point the apps at the accurate months field they already receive (the RCA notes this needs no server change).

The RCA lands on option 1 without reconciling option 2. Backend and Mobile need to agree before a fix ticket can be raised. As at 2026-09-02, **no ticket exists on the Mobile side** beyond MMM-16301.

**Unverified:** the mobile team could not confirm from the apps alone that the server genuinely sends both values in the same response. Verifying needs a test account with a non-whole-year term. They recommend capturing that if a backend ticket is raised.

**Also unmeasured:** how many customers are affected. Nobody has counted loans with non-whole-year terms.

### 1.3 Dormant loans can be silently debited a year later

**Ticket:** MHD-36446, closed by auto-close with acceptance criteria unmet.

Root cause is AMZ-7074, which is Done. But this account shows the **long tail after the fix**: an account left unscheduled in August 2025 sat dormant for 374 days, and when any amount changed, the corrected code created the schedule that should have existed and debited it with no prior notice.

**The open question nobody has answered:** how many other accounts were left unscheduled by the pre-AMZ-7074 behaviour and are still dormant, waiting for their next amount change to trigger a surprise debit? AMZ-7074 links to MHD-27965 "Payment schedule stopped for 6months" (closed at Low), so this is at least the second instance.

**Specific to MHD-36446 and still outstanding:**
- The $186.67 refund was set as an acceptance criterion and never confirmed.
- IDR dispute 21134 has no recorded response.
- The customer threatened media escalation and the ticket sat at **Low** priority for its whole life. Ron requested a re-rate on 16/09. It was never applied and the ticket auto-closed on 22/09.
- The customer received no pre-debit notice. Every other debit in the life of that loan had an Upcoming Payment DD email and an SMS reminder. **The comms gap on recreated schedules is itself a defect and has no ticket.**

### 1.4 Overdue accounts cannot cancel an ad hoc payment that has already been covered

**Tickets:** MHD-36283 (closed as working as designed), MHD-33265, MHD-36693 (open).

On an overdue-stage account, only **retry** transactions can be auto-cancelled. An ad hoc payment set up by an officer, then covered by a customer payment minutes later, continues as Proposed and is rejected after three working days as "Payment not actioned". The customer sees a rejection on their record for a payment they in fact made.

This was explained and closed. It has not been raised as something that should change. MHD-36693 "BRAND (MME /PL) | 10003003669 | ISSUE DD was no cancelled" is a fresh instance still open at 17/09/2026.

---

## Tier 2: recurring operational cost with an agreed but unbuilt fix

### 2.1 No way to clear a SendGrid suppression from Horizon

**Ticket:** MHD-35799, **Pending**, Medium, raised 19/08/2026, no movement since the day it was written.

Every suppressed address has to be cleared by hand by whoever happens to have SendGrid access. Ron counted roughly 25 similar tickets on a quick search. Full acceptance criteria are written and ready to build:

- Suppression status visible in Horizon without logging into SendGrid
- One action removes the address from Bounced, Blocked and Spam Reports
- Success writes an application note with agent, timestamp and lists affected
- Failure surfaces a clear error and writes no success note
- Permission-gated, because removing a suppression overrides a deliverability safeguard

Candidate SendGrid endpoints, to be confirmed against the current integration: `/v3/suppression/bounces/{email}`, `/v3/suppression/blocks/{email}`, `/v3/suppression/spam_reports/{email}`.

### 2.2 The send path retries suppressed addresses, roughly 50,000 futile sends

**Source:** G1-7161, referenced from MHD-35799. Not an MHD ticket.

G1-7161 confirmed that Bounced and Spam Reporting entries are standing instructions not to send, and that the send path keeps retrying them anyway. It lists **"Missing blocked/deferred event handling" as a follow-up that is not yet tracked anywhere**. MHD-35799 explicitly does not fix this.

### 2.3 SOA email attachment ceiling

**Source:** HOR-8167 comment by John Mark Gabriel, 14/07/2026. Never given a ticket.

The Horizon **upload** limit has been raised to 30 MB and is in production. The **email** path was explicitly excluded. SendGrid caps attachments at roughly 30 MB, so a 30 MB SOA generated for a high-volume CRD or Freestyle account will still fail to reach the customer. The problem the upload change was meant to solve is therefore only half solved.

Related and still open: **HOR-8183**, "shared uploader shows no error/warning notification and hangs ('keeps loading') on failed uploads", QA Ready.

### 2.4 Stage does not move to Fund Sent when arrears clear

**Tickets:** MHD-32117 (closed), MHD-34734 (closed), MHD-36790 (**open**, Waiting for Customer), MHD-31967 (Selected for Development since 16/04/2026), MHD-36600, MHD-33036, MHD-31915.

The consequence is that cleared accounts keep appearing in outbound collections campaigns. On MHD-34734 the same account hit it twice and was manually moved both times.

**Two competing explanations, neither confirmed:**
1. The documented rule from MHD-32117: **Overdue + Rejected payment = no stage move**.
2. Michael Dela Torre's newer hypothesis on MHD-36790: the transition requires the last successful payment to be dated today, and that check may read the **transaction date rather than the clearing date**. Direct debits on the affected account settle two to four days after their transaction date, so the condition could never be met.

If (2) is right, every account whose DD settles late will need a manual stage move, indefinitely. It is with the Horizon workflow team. **They asked for a second example to pin it down, and as at 22/09/2026 nobody has supplied one.** That is a cheap, high-value action.

Josh Allen said on MHD-32117 (April 2026) that stage-transition workflows were being reworked, expected "by end of this year". Not landed.

### 2.5 Split Create/Update Account tasks regenerate on CRD accounts that should not have them

**Ticket:** MHD-35062, **Selected for Development** since 27/07/2026. Raised to Funding, no further movement recorded.

Error Split Create/Update Account and Split Create/Update Account tasks keep being raised for CRD accounts on non-Split Sched (direct debit) repayment, even though the repayment method was never changed. The reporter's concern is the right one: task build-up increases the risk that CRD accounts which **genuinely** need action for Split Sched get missed in the noise.

Nine sample applications are listed on the ticket.

---

## Tier 3: long-running open tickets with no visible owner

These are Problem tickets still not in a Done status category. Age is to 2026-09-23.

| Ticket | Age | Status | Summary |
| --- | --- | --- | --- |
| MHD-26581 | 386 days | Selected for Development | Horizon - Email Deliverability |
| MHD-26582 | 386 days | Selected for Development | 10002579948 (no summary text) |
| MHD-27683 | 334 days | WORK IN PROGRESS | Lead source syncing for new broker accreditations |
| MHD-29029 | 286 days | Selected for Development | "An error occurred retrieving card details" despite troubleshooting, 10000755997 |
| MHD-29121 | 280 days | Selected for Development | File upload issue, 10002422996 |
| MHD-30110 | 233 days | Ongoing Development | DC upload tool issue |
| MHD-30596 | 215 days | Selected for Development | Discrepancy in charge cancellation options for PL versus Freestyle |
| MHD-30782 | 208 days | Selected for Development | No option to apply CRD, 10002708306 |
| MHD-31302 | 187 days | Selected for Development | Incorrect figures on app esign for loan offer |
| MHD-31915 | 161 days | Selected for Development | Overdue still showing after contract variation, 10001661291 |
| MHD-31962 | 160 days | Selected for Development | Fix the payment method back to DD, 10002045721 |
| MHD-31967 | 160 days | Selected for Development | Arrears not showing even though no payment was made |
| MHD-32268 | 149 days | Selected for Development | Sliding fee added to repayment due 27/04, 10002526736 |
| MHD-33167 | 120 days | Selected for Development | Allocate and split $112K payment |
| MHD-34298 | 84 days | Selected for Development | Fix incorrect email generation in ApplicationComms |
| MHD-34306 | 84 days | Pending | Admin Fee Reallocation Error on the App, 10002922420 |
| MHD-34329 | 83 days | Selected for Development | Decline on S1 app issue, 10002995580 |
| MHD-34644 | 71 days | Selected for Development | Increase file size upload limit in Horizon to 30mb (the code shipped; this parent was never closed) |
| MHD-34821 | 65 days | Pending | Confirm loan account closure status |
| MHD-34846 | 65 days | Pending | Request for repaid letter |
| MHD-35062 | 58 days | Selected for Development | Recurring Split Create/Update Account tasks on CRD |
| MHD-35068 | 58 days | Pending | SocietyOne - ClearMatch 461020 |
| MHD-35324 | 50 days | Waiting for Confirmation | App shows repayments on DD instead of DC, 10001905418 |
| MHD-35582 | 42 days | Selected for Development | Credit Limit Increase option not visible, 10002859953 |
| MHD-35621 | 41 days | Waiting for Confirmation | Investigate apps 10003039555, 10003039543 |
| MHD-35799 | 35 days | Pending | SendGrid suppression removal button |
| MHD-35952 | 30 days | Selected for Development | Incorrect date |
| MHD-35966 | 30 days | Waiting for Customer | CRD payment reversal request, 10002926516 |
| MHD-36092 | 27 days | Selected for Development | Loan term "3 years" for 43-month loan |
| MHD-36211 | 22 days | Pending | Document Request |
| MHD-36225 | 21 days | Pending | Request for Information for Clearmatch account |
| MHD-36243 | 21 days | Pending | 10002927664 (no summary text) |
| MHD-36407 | 15 days | Waiting for Confirmation | Investigate email, 10003052183 |
| MHD-36538 | 12 days | Waiting for Customer | Cancelled Repayment for 5 months |
| MHD-36613 | 8 days | Selected for Development | Remove specific prompt from S1 website |
| MHD-36622 | 8 days | Pending | SPV Admin permission grouping, G1-2762 |
| MHD-36693 | 6 days | Waiting for Customer | DD was not cancelled, 10003003669 |
| MHD-36716 | 5 days | Scheduled | Missing drop down for risk rating in application notes |
| MHD-36766 | 2 days | Waiting for Customer | Direct debit error, 10002975361 |
| MHD-36790 | 1 day | Waiting for Customer | Did not auto move to FS, 10002108249 |
| MHD-36808 | 1 day | Waiting for Customer | Reset arrears, 10002955931 |
| MHD-36811 | 1 day | Scheduled | Remove transactions dated today |

**MHD-35324 deserves a callout.** Raised 04/08/2026, the reporter has chased four times (07/08, 11/08, 04/09, 11/09) and the ticket is still stuck on "still confirming with our mobile team if this is a display issue or is expected". Fifty days to answer a yes-or-no question.

---

## Tier 4: defects found during investigation that were never given a ticket

These exist only inside comment threads. Each one will be lost the moment the ticket ages out of memory.

| Finding | Found on | Detail |
| --- | --- | --- |
| Template 970 renders "Reference number 0" instead of the application ID | MHD-36075 | Passcode reset email. Cosmetic but incorrect on a customer-facing comm |
| Reset emails are byte-identical on repeat sends | MHD-36075 | Which is what triggers Gmail's trimmed-content collapse. Adding a timestamp or reference to the body would prevent it |
| The "invalid code" on the first reset attempt was never explained | MHD-36075 | The SMS was Delivered at 10:26. Expiry, mistype or a real validation defect was never determined. Ron asked the reporter and the ticket auto-closed |
| Freestyle Amortization page is unusable for CCC accounts | MHD-36071 | Returns "Something is wrong with the input request. (Inner Exception: No Product Context associated with Product Name & Brand ID 'CCC-1')" on both horizon and horizon4. **App Support cannot verify Freestyle schedules through the UI at all.** Ron said he would raise it separately; no ticket found |
| Which job re-sent settlement emails at 04:05 on 16/09/2026 is unknown | MHD-36668 | And whether other applications were in the same run. Neither template appears in the Workflow Mapping export covering 446 active workflows and 347 templates, so these are either stage-entry comms or a workflow missing from the export |
| The email **contents** of the duplicate settlement sends were never compared | MHD-36668 | If the September bodies were re-rendered against current data, the figures or dates may differ from July, which would be a materially worse defect than a duplicate. Horizon access was lost before the check could be run |
| The reporter on MHD-36668 was never given a written answer | MHD-36668 | Ron noted this explicitly on closure and asked that any recurrence reopen the ticket rather than raise a new one |
| Funded applications keep arriving without an Equifax score | roughly 20 tickets | MHD-34765, MHD-36712, MHD-36559, MHD-36129, MHD-36041, MHD-35896, MHD-35709, MHD-35571, MHD-35497, MHD-35187, MHD-35155, MHD-35077, MHD-34362, MHD-34324, MHD-34285, MHD-34204, MHD-34091, MHD-33837, MHD-33781, MHD-33355. Every one closed by inserting the score. **Nobody has asked why it keeps happening** |
| `IsEditedVehicleDetails` gets incorrectly set to 1 on pre-approval applications | MHD-35818 | The ticket asked for a permanent fix to how the flag is set. A data fix closed it and the permanent fix was never delivered |
| MHD-34293 fixed six accounts stuck in Proposed with no root cause recorded | MHD-34293 | "Fixed by Tops and Harvey." If it recurs there is nothing to go on |
| Zepto batches: should dishonour fees be suppressed and stage movement disabled? | MHD-36494 | Michael Dela Torre raised both questions because the customers are not at fault. Neither was answered on the ticket. They should be standing policy, not a per-batch judgement |
| Collections supplies Zepto files with no ApplicationId or TransactionId | MHD-36494, MHD-14377 | Every batch stalls until the mapping is requested and re-supplied. A file format standard would remove this entirely |

---

## Tier 5: process risks visible in the data

### 5.1 The five business day auto-close is resolving unresolved tickets

MHD-36071, MHD-36075, MHD-36283, MHD-35875, MHD-31738, MHD-35381, MHD-35159, MHD-36446 and MHD-30961 were all closed by the automation, not by anyone confirming the outcome. On MHD-36446 that closed a ticket with an open IDR dispute and an unpaid refund. On MHD-36075 it closed an unexplained authentication failure. On MHD-31738 it closed an uninvestigated repayment miscalculation after 39 days.

The rule is reasonable for genuine no-response cases. It should not apply to tickets where App Support has recorded outstanding actions or acceptance criteria.

### 5.2 Priority is not used

Every Problem examined in this harvest carried **Low**, including the IDR and media-escalation ticket. Ron requested a re-rate on MHD-36446 and nothing happened. Until priority means something, it cannot be used for triage, reporting or SLA.

### 5.3 Data fixes are the largest workstream and are invisible in reporting

MHD-35277 (August 2026) carries 69 children. That is roughly 70 production data fixes a month executed by App Support. None of them are typed as data fixes, they are linked children of a monthly change ticket, so they do not appear in any Problem or Change Request count.

### 5.4 Components and labels are unused

No MHD issue carries a component. About 98 per cent carry no label. Product and system live in informal summary prefixes (`APY |`, `CRD |`, `PL |`, `Freestyle |`, `[HOR - CODE Release]`). Any attempt to report by product has to parse text.

### 5.5 Repeat reports against the same account are not being linked

Application 10002220007 generated MHD-36607, MHD-36618 and MHD-36629 within two days. Only one was recognised as a duplicate. Application 10002813976 generated both MHD-33265 and CRD-2459. There is no obvious mechanism for spotting that a new report is the same account as an open one.
