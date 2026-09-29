# Horizon: Stage and Status Logs

Mirror of the Confluence page "Horizon: Stage and Status Logs".

Last reviewed: 23 September 2026
Sources: Confluence HOR page 1293647889, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: HOR (Horizon) · Page id: 1293647889 · Last updated: 18 Feb 2026 · Author: Evangelia Liaros
- URL: https://moneyme1.atlassian.net/wiki/spaces/HOR/pages/1293647889/Stage+Status+Logs

The authoritative list of active Horizon statuses and stages. Only statuses and stages active
in the database are listed.

## Statuses

| Status ID | Status | Category |
| --- | --- | --- |
| 1 | Application | Pre-Funding |
| 2 | Underwriting | Pre-Funding |
| 3 | Pre-Approved | Pre-Funding |
| 5 | Declined | Pre-Funding |
| 6 | Cancelled | Pre-Funding |
| 7 | Funded | Post-Funding |
| 9 | Pay Plan | Post-Funding |
| 10 | Repaid | Post-Funding |
| 11 | Debt Sold | Post-Funding |
| 13 | Bad Debt | Post-Funding |
| 14 | Overdue | Post-Funding |

## Pre-Funding stages

Product columns are MME PL / SOC S-PL / CCC-CRC / APY.

| Stage ID | Stage | Status | MME PL | SOC S/PL | CCC/CRC | APY |
| --- | --- | --- | --- | --- | --- | --- |
| 59 | Alternate Offer | Application | no longer in use | | | |
| 64 | Alternative Offer - SACC | Application | no longer in use | | | |
| 99 | App Start | Application | N | Y | N | N |
| 100 | App Submit | Application | N | Y | N | N |
| 115 | App-esign | Application | N | Y | N | N |
| 7 | App-esign Sent | Application | Y | N | Y | Y |
| 8 | App-esign Shown | Application | Y | Y | Y | Y |
| 2 | Application Submitted | Application | | | | Y |
| 20 | Automated Bank Statement Aborted/Failed | Application | | | | N |
| 21 | Automated Bank Statement Completed | Application | | | | N |
| 19 | Automated Bank Statement Started | Application | | | | N |
| 22 | Bank Details | Application | Y | Y | Y | Y |
| 70 | Bank Income Cycle | Application | | | | N |
| 47 | Bank Statement | Application | Y | Y | Y | N |
| 87 | Borrower Details | Application | | | | Y |
| 82 | Business Details | Application | | | | Y |
| 68 | CCC Offer | Application | | | | N |
| 67 | CCC Withdrawal | Application | | | | N |
| 43 | Complaint received | Application | | | | Y |
| 92 | Debt Details | Application | | | | N |
| 44 | Employment Details | Application | Y | N | Y | Y |
| 46 | Expense Details | Application | | | | Y |
| 86 | Finance Calculator | Application | | | | Y |
| 89 | Financial Details | Application | | | | Y |
| 45 | Income Details | Application | | | | Y |
| 1 | Initial Stage | Application | | | | Y |
| 4 | Leadgen Arrived | Application | | | | N |
| 5 | Leadgen Purchased | Application | | | | N |
| 3 | Leadgen Received | Application | | | | N |
| 114 | Manual Bank Statement | Application | | | | N |
| 94 | Pre Approved | Application | | | | Y |
| 98 | Quote Given | Application | Y | Y | N | Y |
| 97 | Quote Start | Application | N | Y | N | Y |
| 112 | Referral Code | Application | | | | Y |
| 93 | Remove Debt | Application | | | | N |
| 91 | Review and Submit | Application | | | | Y |
| 23 | Submitted for Approval | Application | | | | N |
| 90 | Upload Documents | Application | | | | Y |
| 88 | Vehicle Details | Application | | | | Y |
| 78 | Verify Identity | Application | | | | Y |
| 80 | Verify Income | Application | | | | Y |
| 11 | App-esign Expired | Cancelled | | | | N |
| 6 | Application Expired | Cancelled | | | | Y |
| 18 | Cancelled | Cancelled | | | | Y |
| 12 | Client Cancelled | Cancelled | | | | Y |
| 103 | No Quote | Cancelled | | | | N |
| 17 | Underwriting Expired | Cancelled | | | | Y |
| 10 | App Declined | Declined | | | | N |
| 16 | App Declined Sold | Declined | | | | N |
| 15 | Declined | Declined | | | | Y |
| 116 | Quote Decline | Declined | | | | N |
| 104 | Referred to Partner | Declined | | | | N |
| 25 | HBA Review | Pre-Approved | | | | N |
| 9 | App-esign Accepted | Underwriting | | | | Y |
| 101 | Approved | Underwriting | | | | N |
| 85 | Awaiting Second Esign | Underwriting | | | | N |
| 58 | Manual Underwriting | Underwriting | | | | N |
| 102 | Offer Awaiting Confirmation | Underwriting | | | | N |
| 14 | Pending Sign off | Underwriting | | | | N |
| 84 | Pre Settlement | Underwriting | | | | Y |
| 118 | Second Review | Underwriting | Y | | Y | N |
| 39 | Signed Off | Underwriting | Y | | Y | Y |
| 79 | Signed-Off Pending ID | Underwriting | | | | Y |
| 83 | Tax Invoice | Underwriting | | | | Y |
| 13 | Underwriting | Underwriting | | | | Y |
| 111 | Verify Asset | Underwriting | | | | N |

**Note for App Support:** stage `39` (Signed Off) is the stage in the recurring "stuck at
Signed Off" tickets, and stage `38` (Fund Sent) is the destination. Stage `38` is also the
`ToStageId` the contract generation workflow keys on.

## Post-Funding stages

Columns: Stage triggers write off (WO) / Stage pauses interest / Stage cancels payments.

| ID | Stage | Status | Trigger | WO | Pauses interest | Cancels payments |
| --- | --- | --- | --- | --- | --- | --- |
| 41 | Bankruptcy | Bad Debt | Manual | Yes | Yes | Yes |
| 123 | Deceased Estate | Bad Debt | Manual | Yes | Yes | Yes |
| 42 | Fraud and WriteOff | Bad Debt | Manual | Yes | Yes | Yes |
| 48 | Written Off | Bad Debt | Manual | Yes | Yes | Yes |
| 30 | Debt Sold | Debt Sold | Manual | No | Yes | Yes |
| 121 | AFCA Arrangement | Funded | Manual | No | No | Yes |
| 122 | AFCA Arrangement Broken | Funded | Auto | No | No | No |
| 120 | AFCA In Progress | Funded | Manual | No | No | Yes |
| 38 | Fund Sent | Funded | Auto | No | No | No |
| 26, 27, 28, 29 | Arrears M0 to M3 | Overdue | historic, not in use | | | |
| 119 | Arrears Referred Payment Plan | Overdue | Auto | No | No | Yes |
| 117 | Arrears Referred to External | Overdue | Manual | No | No | No |
| 55 | Debt Agreement Voting Period | Overdue | Manual | No | Yes | Yes |
| 125 | Debt Sale Eligible | Overdue | Manual | No | No | No |
| 124 | Debt Sale Ineligible | Overdue | not implemented | | | |
| 129 | External - 14 Day Hold | Overdue | Auto / Manual | No | No | No |
| 127 | External - LOA Received | Overdue | Manual | No | No | No |
| 128 | External - Pending DAP | Overdue | Manual | No | No | No |
| 110 | Litigation - Enforcement Action | Overdue | Manual | No | No | No |
| 108 | Litigation Claim Served | Overdue | Manual | No | No | No |
| 109 | Litigation Judgement Entered | Overdue | Manual | No | No | No |
| 63 | Litigation Preview | Overdue | Manual | No | No | No |
| 106 | Litigation Preview - Overdue | Overdue | Manual | No | No | No |
| 105 | Litigation Preview - Payment Plan | Overdue | Manual | No | No | No |
| 107 | Litigation Referred | Overdue | Manual | No | Yes | Yes |
| 126 | Locked For Debt Sale | Overdue | Manual | No | No | No |
| 56 | Overdue | Overdue | Auto | No | No | No |
| 65 | Overdue hold | Overdue | Auto / Manual | No | No | No |
| 62, 73, 72, 74 | Recall stages | Overdue | historic, not in use | | | |
| 37 | Referred to External Agency | Overdue | Manual | No | Yes | Yes |
| 57 | Review DAP Voting | Overdue | not in use | | | |
| 71 | Suspended | Overdue | Manual | No | Yes | Yes |
| 36 | Debt Assignment | Pay Plan | not in use | | | |
| 34 | Further Hardship Information Required | Pay Plan | Manual | No | No | No |
| 32 | Hardship Approved | Pay Plan | Manual | No | No | No |
| 81 | Hardship Approved - External | Pay Plan | Manual | No | No | No |
| 134 | Hardship Approved - External (Missed Payment) | Pay Plan | Auto | No | No | No |
| 113 | Hardship Approved - Missed Payment | Pay Plan | Auto | No | No | No |
| 33 | Hardship Declined | Pay Plan | Manual / Auto | No | No | No |
| 132 | Hardship External - Further Hardship Info Required | Pay Plan | Manual | No | No | No |
| 133 | Hardship External - Hardship Declined | Pay Plan | Auto / Manual | No | No | No |
| 130 | Hardship External - Hardship Requested | Pay Plan | Manual | No | No | No |
| 131 | Hardship External - Hardship Under Review | Pay Plan | Auto | No | No | No |
| 31 | Hardship Requested | Pay Plan | Auto / Manual | No | No | No |
| 75 | Hardship Under Review | Pay Plan | Auto | No | No | No |
| 40 | Payment Plan | Pay Plan | Manual | No | No | No |
| 35 | Under Debt Agreement | Pay Plan | Manual | No | Yes | Yes |
| 135 | Under Debt Agreement - Part X | Pay Plan | Manual | No | Yes | Yes |
| 24 | Repaid | Repaid | Auto | No | Yes | payments not cancelled but do not process |
| 66 | Settlement | Repaid | Manual | Yes | Yes | Yes |

### Behaviour notes that matter in support

- **Fund Sent (38).** The initial active stage after approval and funding; indicates the
  account is active and in good standing with no arrears balance. The system moves accounts
  back into Fund Sent when their arrears balance is repaid. It may also reset Collection Action
  Taken details if not previously default listed, and re-allow access to available credit if
  nothing else restricts it.
- **Overdue (56).** Accounts move here on a missed payment with arrears greater than $0. Holds
  the collection comms workflow. Eligible for overdue account fees, escalating as arrears grow.
- **Overdue hold (65).** Automated trigger: if the current stage is Overdue and a payment for
  more than 80% of the arrears balance is made, the stage moves to Overdue Hold. Overdue comms
  and notices do not send, and the stage is not eligible for the Overdue Account Fee.
- **AFCA Arrangement (121) and AFCA In Progress (120).** Interest should **not** be paused. A
  pop up modal offers DNC, Suppress CCR, Disable Annual Fee, Disable Account Keeping Fee. Those
  checkboxes are de-selected on moving out, if they were not already selected pre-AFCA.
- **AFCA Arrangement Broken (122).** Auto: if a proposed payment moves to Rejected while the
  account is in AFCA Arrangement, the system moves it here. Eligible payment types: Split Sched,
  Split Live, Ezi Sched, Ezi Live, Credit Card, Direct Credit, Split Auto Retry, Direct Debit
  Auto Retry. Manually handled thereafter; there are no auto movements out.
- **Arrears Referred to External (117) and Arrears Referred Payment Plan (119).** Payment
  schedule and interest remain active; DD retry and arrears capture are disabled; DD reminders
  continue but other auto comms are paused; notices are not issued (the third party issues
  them); fees remain active. Stage 117 has an external party identifier and SFTP integration.
  **Relevant to comms tickets:** an application at stage 117 (or the older stage 37) means we
  can no longer contact the customer directly.
- **Debt Sold (30) and Locked For Debt Sale (126).** Only Solutions 4, Solutions 5 and Solutions
  Compliance can move a stage out of Debt Sold; moving into Debt Sold closes any active Virtual
  Cards. Stage 126 restricts view permissions to Solutions 5 and Solutions Compliance.
- **Hardship Requested (31).** Raises "Awaiting Hardship Docs" with due date +21 days. Moves to
  Overdue after 35 days in the stage, or +14 days from the Awaiting Hardship Docs due date.
- **Hardship Under Review (75).** Entered when the hardship form is returned or bank statements
  are received; completes "Awaiting Hardship Doc" and raises "Review - Hardship".
- **Hardship Declined (33).** Incomplete hardship applications move here on the due date of the
  Awaiting Hardship Doc task. The customer gets a declined email and stays here 14 days (which
  protects them from collection activity) before moving back to Overdue. If supporting
  documentation arrives while here, the system moves it back to Hardship Under Review and raises
  a task.
- **Hardship Approved - Missed Payment (113) / External (134).** If the account stays more than
  28 days, it moves to Overdue (113) or External - 14 Day Hold (134). If more than 80% of the
  last rejected payment (113) or expected monthly payment (134) clears, it returns to Hardship
  Approved.
- **External - 14 Day Hold (129).** Accounts stay 14 days then auto move to **Overdue**. On the
  way out: interest and fee settings are reinstated, DNC is de-selected, and a
  "Review - Shuffle Schedule" task is raised.
- **External - LOA Received (127).** DNC selected, payments set to Direct Credit, specific comms
  triggered. Auto moves to External - 14 Day Hold after 60 days.
- **External - Pending DAP (128).** Auto moves to External - 14 Day Hold after 60 days.
- **Repaid (24).** Automated workflows push accounts here when the current balance is below a
  threshold. Triggers: Action - Collection (Overpayment) task check (refund task); PPSR removal
  for secured loans; repaid email; default update task if applicable.
- **Settlement (66), Bankruptcy (41), Deceased Estate (123), Fraud and WriteOff (42),
  Written Off (48).** Moving into any of these triggers a write off transaction.

---
