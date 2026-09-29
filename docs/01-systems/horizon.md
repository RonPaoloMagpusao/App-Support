# Horizon

The internal loan and application management system, its modules, stage and status registers, URL patterns and permissions model.

Last reviewed: 23 September 2026

Sources: Confluence 3071442984 (Replace Sentry by Uptrace), 1293647889 (Stage and Status Logs), 3117842457 (Datafix catalogue), 2485059655 (Store Procedures for App Support), 3131015188 (App Support Cover Runbook), 426082342 (APY Environments and Credentials), 1772126209 (Payment Channels), 942047312 (missing contract investigation); [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 7 and 9.

## What Horizon is

Horizon is the loan and application management system of record for MoneyMe. Operations, Collections, Underwriting, Partnerships and App Support all work in it. The application is `MoneyMe.Horizon`; the database is `Horizon2` (see `horizon-database.md`).

Everything App Support can see lives in Horizon. Rusty's standing rule: if it is not in Horizon, we probably cannot see it, and that is not by itself a Horizon defect ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 4). The main exception is CRD card data, which lives in E6 (see `brands-products-entities.md`).

## Age and platform, and why it matters

`MoneyMe.Horizon` is still on **.NET Framework 4.6.1** as at 3 September 2026 (Confluence 3071442984). Consequences App Support feels:

- Horizon and `MoneyMe.BankStatement` are the last two services still reporting to Sentry. Sentry cannot be switched off until they move, so Horizon errors are still looked up in Sentry and not Uptrace. See `monitoring.md`.
- The Sentry removal and OpenTelemetry wiring ride inside each host's isolated model / .NET 10 upgrade. Horizon is the largest single piece of work remaining and has not started (Confluence 3071442984).
- Long-running UI complaint: Horizon tabs not populating and needing several refreshes, worse on CRD. Raised May 2026, followed up 14 and 18 May, 3 and 20 July, escalated again 2026-08-05 by Raina. Suspected E6 data not loading or a timeout set too short ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 5).

## Modules App Support touches

| Module / tab | What it holds | Notes for support |
| --- | --- | --- |
| Application | The central record: amounts, product, stage, status, dates, flags | `/Application/Application/<id>` |
| Notes | Free text notes against an application | Moved between applications by raw UPDATE on `Note` |
| Tasks | Work items raised by workflows and agents | Closing a task is often the whole fix. See `payments-and-rails.md` |
| Communication / Comms tab | Outbound and inbound messages, including Braze campaign sends synced back in | See `communications.md` |
| Transactions | MoneyIn, MoneyOut, schedules, reversals | Ties to `[Transaction]`, `Amortization` |
| Debit Accounts | Split (Zepto) debit account status | Must show **Active** after a Split account fix (Confluence 2286321665) |
| Bank Details (Application) | Customer bank account used for debits | Where `incorrect_bsb` and `account_closed` fixes are applied |
| Credit Card tab (CRD) | Card balances and card transactions | **Data is E6, not Horizon.** A Horizon data fix will not change it (Rusty, 2026-07-02) |
| Customer tab | Customer identity, contact, login account | Three separate stores, not kept in sync. See `horizon-database.md` |
| Payment File Upload | Direct Credit and other payment file uploads | `/PaymentFileUpload/PaymentFileUploads` |
| Admin, Roles and Tabs | Permissions | See the permissions model below |

## URL paths that identify a record type

Source: Confluence 3117842457.

| Path | Identifier it carries |
| --- | --- |
| `/Application/Application/<id>` | ApplicationId |
| `/Note/ApplicationNotes/<id>` | ApplicationId |
| `/Task/ApplicationTasks/<id>` | ApplicationId |
| `/Communication/ApplicationComms/<id>` | ApplicationId |
| `/Customer/CustomerDetails/<id>` | **Ambiguous.** The value is 11 digits, the same shape as an ApplicationId, while sample CustomerIds are 6 to 7 digits. Test it with a `SELECT` before using it as `@CustomerId` |
| `/PaymentFileUpload/PaymentFileUploads` | Payment file upload list, used to identify Direct Credit uploads |

Worked example of the task path: close a funding follow up task at `horizon.moneyme.com.au/Task/ApplicationTasks/<id>` (Confluence 3131015188, sample MHD-35999).

## Status register

Source: Confluence 1293647889. Only statuses active in the database are listed on that page.

| StatusId | Status | Category |
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

Note statuses 4, 8 and 12 are absent from the register. Unverified: whether they are retired or simply not active. Confirm with `SELECT * FROM Status` (or the equivalent lookup) in `Horizon2`.

## Stage register, pre-funding

Source: Confluence 1293647889. Product columns are MME PL / SOC S-PL / CCC-CRC / APY as published on that page; blank means the page left the cell blank.

| StageId | Stage | Status | MME PL | SOC S/PL | CCC/CRC | APY |
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
| 39 | **Signed Off** | Underwriting | Y | | Y | Y |
| 79 | Signed-Off Pending ID | Underwriting | | | | Y |
| 83 | Tax Invoice | Underwriting | | | | Y |
| 13 | Underwriting | Underwriting | | | | Y |
| 111 | Verify Asset | Underwriting | | | | N |

## Stage register, post-funding

Source: Confluence 1293647889. WO = moving into the stage triggers a write off transaction.

| StageId | Stage | Status | Trigger | WO | Pauses interest | Cancels payments |
| --- | --- | --- | --- | --- | --- | --- |
| 41 | Bankruptcy | Bad Debt | Manual | Yes | Yes | Yes |
| 123 | Deceased Estate | Bad Debt | Manual | Yes | Yes | Yes |
| 42 | Fraud and WriteOff | Bad Debt | Manual | Yes | Yes | Yes |
| 48 | Written Off | Bad Debt | Manual | Yes | Yes | Yes |
| 30 | Debt Sold | Debt Sold | Manual | No | Yes | Yes |
| 121 | AFCA Arrangement | Funded | Manual | No | No | Yes |
| 122 | AFCA Arrangement Broken | Funded | Auto | No | No | No |
| 120 | AFCA In Progress | Funded | Manual | No | No | Yes |
| 38 | **Fund Sent** | Funded | Auto | No | No | No |
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

## What the stages mean operationally

The stages App Support actually has to reason about, from Confluence 1293647889 unless otherwise cited.

**39 Signed Off.** The stage in the recurring "stuck at Signed Off" tickets. Almost always a funding problem wearing a stage label: work the funding checks in `payments-and-rails.md` before touching the stage (Confluence 3131015188).

**38 Fund Sent.** The initial active stage after approval and funding: the account is active, in good standing, no arrears balance. The system also moves accounts back into Fund Sent when their arrears balance is repaid, may reset Collection Action Taken details if not previously default listed, and re-allows access to available credit if nothing else restricts it. Stage 38 is also the `ToStageId` the contract generation workflow keys on (Confluence 942047312).

**56 Overdue.** Entered on a missed payment with arrears greater than $0. Holds the collection comms workflow. Eligible for overdue account fees, escalating as arrears grow. The overdue fee is charged every 14 days while the account is in this stage, regardless of whether the customer is paying (Rusty, 2026-09-01). Do not waive on that basis.

**65 Overdue hold.** Auto: entered when the account is in Overdue and a payment for more than 80% of the arrears balance clears. Overdue comms and notices do not send, and the stage is not eligible for the Overdue Account Fee.

**120 AFCA In Progress, 121 AFCA Arrangement, 122 AFCA Arrangement Broken.** Interest must **not** be paused in AFCA stages. A pop up modal offers DNC, Suppress CCR, Disable Annual Fee, Disable Account Keeping Fee; those checkboxes are de-selected on moving out if they were not already selected pre-AFCA. Stage 122 is entered automatically when a proposed payment moves to Rejected while the account is in AFCA Arrangement. Eligible payment types for that auto move: Split Sched, Split Live, Ezi Sched, Ezi Live, Credit Card, Direct Credit, Split Auto Retry, Direct Debit Auto Retry. There is no auto movement out of 122. Visibility of 121 and 122 is controlled by `Tab` ids 295 and 296 (Confluence 2485059655).

**117 Arrears Referred to External, 119 Arrears Referred Payment Plan.** Payment schedule and interest stay active; DD retry and arrears capture are disabled; DD reminders continue but other auto comms are paused; notices are issued by the third party, not by us; fees remain active. Stage 117 carries an external party identifier and an SFTP integration. **For comms tickets: an application at 117, or at the older stage 37, means we can no longer contact the customer directly.**

**30 Debt Sold, 126 Locked For Debt Sale.** Only Solutions 4, Solutions 5 and Solutions Compliance can move a stage out of Debt Sold. Moving into Debt Sold closes any active Virtual Cards. Stage 126 restricts view permissions to Solutions 5 and Solutions Compliance.

**31 Hardship Requested.** Raises "Awaiting Hardship Docs" with a due date of +21 days. Moves to Overdue after 35 days in the stage, or +14 days from the Awaiting Hardship Docs due date.

**75 Hardship Under Review.** Entered when the hardship form is returned or bank statements are received; completes "Awaiting Hardship Doc" and raises "Review - Hardship".

**33 Hardship Declined.** Incomplete hardship applications move here on the due date of the Awaiting Hardship Doc task. The customer gets a declined email and stays 14 days, which protects them from collection activity, before moving back to Overdue. Documentation arriving during that window moves the account back to Hardship Under Review and raises a task.

**113 Hardship Approved - Missed Payment, 134 External equivalent.** Staying more than 28 days moves the account to Overdue (113) or External - 14 Day Hold (134). Clearing more than 80% of the last rejected payment (113) or of the expected monthly payment (134) returns it to Hardship Approved.

**129 External - 14 Day Hold.** 14 days, then auto move to Overdue. On the way out: interest and fee settings reinstated, DNC de-selected, and a "Review - Shuffle Schedule" task raised.

**127 External - LOA Received.** DNC selected, payments set to Direct Credit, specific comms triggered. Auto moves to External - 14 Day Hold after 60 days. **128 External - Pending DAP** does the same after 60 days.

**24 Repaid.** Automated workflows push accounts here when the current balance is below a threshold. Triggers an Action - Collection (Overpayment) task check for a refund, PPSR removal on secured loans, the repaid email, and a default update task where applicable. Note: an account moved **manually** to Repaid is not actually closed. Only the payout process closes a credit card account ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 9).

**66 Settlement, 41 Bankruptcy, 123 Deceased Estate, 42 Fraud and WriteOff, 48 Written Off.** Moving into any of these triggers a write off transaction.

**71 Suspended, and its replacement "Special Handling".** Suspended pauses payments. Special Handling, which replaced it, is **designed to keep payments active**. That caught Collections out in June 2026: moving a batch of pre-sale accounts to Special Handling needed an urgent datafix to cancel active schedules before a separate fix went live that would have let those payments submit ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 7 and 9). Special Handling does not appear in the Confluence 1293647889 register, which was last updated 18 February 2026. Unverified: its StageId. Confirm with a `SELECT` on the stage lookup.

## Permissions model

Sources: Confluence 2485059655, 3117842457.

| Object | Key | What it is |
| --- | --- | --- |
| `webpages_Roles` | `RoleId` | The role list |
| `Tab` | `TabId` | The permission targets. Known: `295` = `Stages_AFCA_Arrangement`, `296` = `Stages_AFCA_Arrangement_Broken` |
| `RoleAccess` | `RoleId` + `TabId` + `AccessLevelId` | The join that grants access. `AccessLevelId = 1` is View |

Grant a permission with `dbo.AppSupport_InsertRoleAccess @RoleIds, @TabIds, @AccessLevelId`. Bulk grants are done as a `CROSS JOIN` insert with a `NOT EXISTS` guard (Confluence 519602304, item 45). The sample there grants TabIds 295 and 296 at AccessLevelId 1 to RoleIds 39, 40, 41, 47, 49, 50, 53, and 55 to 71; Solutions 1 to 5, Admin, Compliance, Marketing Basic and Marketing + LR were excluded because they had already been done manually.

Permission grants are ordinary monthly datafix work. August 2026 examples from the MHD-35277 umbrella include a `Stripe_Accounts` view permission grant for all roles ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).

Named role groups that carry stage restrictions: Solutions 4, Solutions 5, Solutions Compliance (Debt Sold and Locked For Debt Sale, Confluence 1293647889). Treasury SPV admin permission grouping is a separate grant, tracked as MHD-36622 / G1-2762 ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).

## Fronts onto the same system

`horizon.moneyme.com.au`, `horizon4.moneyme.com.au` and `horizon-az.moneyme.com.au` are all described as live front ends onto the same Horizon ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7). The App Support pages and the APY page disagree about which host is canonical. See `environments-and-urls.md`.
