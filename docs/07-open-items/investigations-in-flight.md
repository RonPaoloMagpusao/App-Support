# Investigations in flight

Tickets Ron worked between 27 August and 11 September 2026, with the open actions from each. Updated where Jira showed a later state on 23 September 2026.

Last reviewed: 23 September 2026
Sources: Investigation handover notes 11 September 2026; Jira MHD as at 23 September 2026

## Open actions, in priority order

1. **MHD-36446** batch query: find other accounts closed out or rescheduled by the same behaviour and debited without notice. Time sensitive.
2. **MHD-36446** confirm the $186.67 refund, respond to IDR 21134, and get the ticket re-rated from Low.
3. **MHD-36283** refund the $15.00 dishonour fee; confirm whether CRD auto-cancel scope should extend to APY.
4. **Email misrouting**: raise a ticket and get a privacy view. See [security-findings.md](security-findings.md#3-inbound-email-misrouting).
5. **MHD-36092**: Backend and Mobile to agree which of the two fixes they are taking.
6. **MHD-36075**: confirm the "invalid code" detail with the reporter; raise the two template defects.

## MHD-36446: customer debited a year after last payment

- SocietyOne account 2000019464.
- Customer paid $5,000 by card on 15/08/2025, leaving a $355 residual. Nothing happened for 13 months.
- 24/08/2026 03:00: the system wrote off the residual principal. Three minutes later it created a new schedule for the residual interest, which debited on 07/09 and cleared 09/09.
- No notice. Every earlier debit had an email and SMS reminder. The "loan is Repaid" email went out seven minutes after the money cleared.
- Customer threatened media escalation. IDR lodged, dispute 21134.

**Root cause, corrected.** The handover suggested an automated close-out after a trust migration, because both new entries carry Trust Id MoneyMe while the history is Spv12. The Jira harvest found the root cause recorded as **AMZ-7074** (amortisation schedules cancelled without replacement), and `text ~ "trust migration"` returns no MHD issues. Treat the trust angle as unverified. The systemic question stands either way: how many other accounts were left unscheduled and are waiting to be debited.

**State on 23/09:** Ron requested a re-rate on 16/09; it was not applied. The ticket auto-closed on 22/09 with acceptance criteria unmet. Priority looked wrong for the risk throughout. See [open-defects-and-risks.md](open-defects-and-risks.md) Tier 1.3.

## MHD-36283: ad hoc payment not cancelled

- App 10002445060.
- An officer raised an ad hoc Direct Credit. The customer paid by card two minutes later. The ad hoc was never cancelled and expired internally after three days.
- It attracted a **$15.00 dishonour fee** (txn 109324109) despite never being submitted to a bank: its Submitted column is blank, unlike the account's genuine dishonours.
- Auto-cancel on early payment was built for CRD under MHD-33404 and MHD-35241 but appears not to cover APY.
- Rusty's ruling on MHD-33265 (2026-05-28): "The normal custom/partial rules don't apply to CRD. When the bill is satisfied, the scheduled MMP should be cancelled." See [../05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md).

**State on 23/09:** closed as working as designed. Fresh instance MHD-36693 open. The $15 refund is not recorded.

## MHD-36092: app shows "3 years" for a 43-month loan

- App 10003066205. Horizon holds 43 months everywhere; contract end 27/03/2030. No datafix needed.
- Deliberately distinguished from MHD-35653, which looked the same but was genuine stale data, fixed by datafix under MHD-35277 (tracked as MHD-35509).
- Mobile team RCA (Paul LV Jain, Confluence, Mobile Engineering Team Documents): both apps work as designed. The server sends the string "3 years" already shortened. Ownership is Backend / API, whatever populates `DurationInYears`. iOS regressed to match Android via MMM-9350 in May 2025.
- **Unresolved:** the RCA also says the accurate "43 months" is already delivered to both apps and never displayed. That is two viable fixes. Backend and Mobile must agree before a fix ticket is raised. Linked MMM-16301 (To Do).
- A plain-language reply to the reporter was drafted and not sent.

## MHD-36075: "unable to login", reset emails appeared empty

- App 10002487161. Resolved, not a defect.
- The customer received four identical "Reset your passcode" emails in 25 minutes; Gmail collapsed the repeated body behind "show trimmed content". Repeated G3APIBot resets made it worse.
- Still open:
  - The original "invalid code" attempt was never explained. The SMS was delivered.
  - Two defects not raised: template 970 renders "Reference number 0" instead of the application ID; reset emails are byte-identical, which triggers the Gmail collapse.

## MHD-36071: repayment increased after adhoc shuffle

- Freestyle account, LID 10001184043. Closed.
- The 21/08 shuffle applied a monthly instalment to a fortnightly schedule: $1,065.40 monthly became $1,097.60 fortnightly, a 123 per cent annual increase, three days after the customer exited hardship. Correct fortnightly figure is about $499.00.
- Precedents: MHD-30258, MHD-31738, MHD-35875. See [../02-runbooks/amortisation-shuffle-and-schedules.md](../02-runbooks/amortisation-shuffle-and-schedules.md).
- Side finding: the Freestyle Amortization page errors for CCC accounts ("No Product Context associated with Product Name & Brand ID 'CCC-1'"), so App Support cannot verify Freestyle schedules through the UI. No ticket found.

## HOR-8167: UAT, Horizon upload limit raised to 30MB

- Integration, build 20260909.1 / Release-652. Passed on retest (first run looked like the build was not deployed).
- Gap: QA only confirmed the error at 31MB and above. The 30.0 to 31.0MB band has never been tested; a silent rejection would hide there.
- A UAT script exists with 11 test cases and PowerShell to generate test files.
- The parent MHD-34644 was never closed after the code shipped.

## Recurring theme

Several of these share one shape: **fixed for one product, never scoped to the others.**

- Auto-cancel on early payment exists for CRD but not APY.
- The term display regressed on iOS in May 2025 to match an Android bug and sat for sixteen months.
- Freestyle scheduling is knowingly unreliable, with a manual workaround.

Worth raising the pattern rather than only the instances.
