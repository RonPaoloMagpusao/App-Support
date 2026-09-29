# Runbooks: the symptom router

Start here. Find what the reporter actually said, open the runbook, do the first check.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue, MHD precedent index, MHD open threads, Confluence 3131015188, Confluence 3117842457, Confluence 2385150262, Confluence 546701313, team procedures (Slack), tribal knowledge (Slack), Rusty's rulings (Slack)

## How to use this

Reporters do not describe root causes, they describe what they saw. The left column is their
words, taken from real ticket summaries and Slack messages. The right column is the one check
that most often ends the investigation.

Three rules before you route anything.

1. **Check whether it is a datafix at all.** A meaningful share of tickets that sound like
   datafixes are not. Running an UPDATE on production when the real answer was "it is on the
   bounce list" is the worst outcome available (Confluence 3117842457, Part 1).
2. **Nothing runs in prod by your own hand.** Attach the script to the current monthly umbrella
   ticket, then request execution in `#datascript-requests` (Confluence 3131015188). See
   [../03-procedures/datafix-request.md](../03-procedures/datafix-request.md).
3. **Reproduce on a second example before declaring a rule broken.** Rusty has been caught by
   "2 invalid examples by coincidence on the same day" (Rusty, `#app-support`, 2026-08-13).

## Money and payments

| The reporter says | Runbook | First check |
| --- | --- | --- |
| "Application is stuck at the 'signed off' stage" | [application-stuck-at-stage.md](application-stuck-at-stage.md) | Work the funding runbook first. Most "stuck at Signed Off" tickets are a funding problem wearing a stage label (Confluence 3131015188, section 04) |
| "This one's stuck at signed off, need it fixed asap, broker has followed up" | [funding-and-disbursement.md](funding-and-disbursement.md) | Open the Tasks tab and name the blocking task before touching anything (`#pending-funding-checks`) |
| Task note: "Float account reached set limit of 400,000.00" | [funding-and-disbursement.md](funding-and-disbursement.md) | Safe to retry, no datafix. The payment never reached Zepto (Confluence 2385150262) |
| "Invalid Funding BSB" | [funding-and-disbursement.md](funding-and-disbursement.md) | Read the exact message. Leading-space format error is a datafix, AusPayNet rejection is not (MHD-35359) |
| "Reprocess application for funding" / "please run the data fix SP to delete the funding records" | [funding-and-disbursement.md](funding-and-disbursement.md) | Confirm in Zepto that the money has not already gone (Confluence 2385150262) |
| "PayAnyone transaction sits at Authorised, funding looks stuck" | [funding-and-disbursement.md](funding-and-disbursement.md) | Close the open funding failed task. Do not datafix (MHD-35999) |
| "Insert Equifax Score" | [funding-and-disbursement.md](funding-and-disbursement.md) | Routine datafix, insert the score (MHD-34765) |
| "Refund Funding Error 'No Bank Account'" | [refunds-and-reversals.md](refunds-and-reversals.md) | Check whether `applicationbankid` is NULL despite bank details being on screen (MHD-36658) |
| "Direct debits rejected with Add Payment Denied" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Pull the provider payload by `PaymentRef` = `<applicationId>-<transactionId>` (MHD-35514) |
| "Direct debit has been pending since 07/08", "still showing a 'proposed' status" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | A proposed payment not processed within 3 working days is rejected as "Payment not actioned" (MHD-36283) |
| "Payment came out twice" / "Zepto raised a DDR dispute claiming duplicates" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Confirm the duplicate is real against the payment arrangement timeline before writing anything. About one in seven needs no fix (MHD-35813) |
| "Customer paid early and the direct debit still came out" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Which product? PL cancels, Freestyle does not, CRD cancels on bill satisfaction (MHD-35019, MHD-33265) |
| "Payments are coming out earlier than expected" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Split Sched moved from after 17:30 to as early as 08:00 on 2026-08-26 (Rusty, `#solutions_memorandum`) |
| "Direct debit keeps on reversing even though it's well funded" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Look for a provider-side block on the nominated account, and check the DB for cancelled rows the grid hides (MHD-36618) |
| "Nothing debits at all on this account" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Missing Default Payment Mode, `AdditionalDataTypeId = 32` (MHD-35706) |
| "Error Split Create/Update Account task keeps appearing" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Close the task, which forces Horizon to re-attempt creation (Confluence 2286321665) |
| "DD rejected: incorrect_account_number" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | The account number on the bank statement is simply wrong. Not a defect (Rusty, `#app-support`, 2026-05-26) |
| "Zepto late dishonour file, please reverse" | [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md) | Does the file carry ApplicationId or TransactionId? If not, send it back (MHD-36494) |
| "Stuck refund for 30 mins" bot post | [refunds-and-reversals.md](refunds-and-reversals.md) | Run the pending refund sweep query (Confluence 2385150262) |
| "Perform datafix for reverse write-off" | [refunds-and-reversals.md](refunds-and-reversals.md) | Use SQL Data Fix scripts item 15, not item 14. Item 14 is broken (Confluence 3117842457) |
| "Refund for a closed CRD account" | [refunds-and-reversals.md](refunds-and-reversals.md) | CRD refunds are frozen as at 2026-09-23. Escalate, do not process (Rusty, `#solutions_memorandum`, 2026-09-17) |
| "Two refund transactions were created from one click" | [refunds-and-reversals.md](refunds-and-reversals.md) | Zepto rejects the second with `duplicate idempotency key`. Cancel the duplicate, then reopen the `System - Refund Loan` task (`#refund-supports`) |
| "Cancel the pending Pay Anyone transactions" | [refunds-and-reversals.md](refunds-and-reversals.md) | Stranded at the provider over 24 hours. `PATransactionDataFixUpdateTransaction` with status 67006, then `ComputeSlidingLimit` (MHD-34308) |

## Schedules, arrears and fees

| The reporter says | Runbook | First check |
| --- | --- | --- |
| "The repayment amount increased following a system adhoc shuffle" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | Compare the post-shuffle instalment against monthly x 12/26. If it matches the old monthly figure, the frequency label changed and the amount did not convert (MHD-36071) |
| "Repayment amount remains unchanged after shuffling" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | Same defect, other direction (MHD-35875) |
| "Unable to shuffle on the 15th" / "unable to shuffle to the correct date" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | Freestyle or LOC? Shuffling an LOC does nothing for the amount (Rusty, `#app-support`, 2026-05-06) |
| "Loan term shows 3 years when it should be 43 months" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | If Horizon and the contract agree and only the app disagrees, it is MHD-36092 and no datafix is required |
| "App shows repayments as DD but Horizon has DC" | [mobile-app-display.md](mobile-app-display.md) | Known open display issue MHD-35324. Link to it |
| "Payment reminder notification shows 01/01/1900" | [mobile-app-display.md](mobile-app-display.md) | Null date leaking into the push. Confirm the DD was correctly cancelled |
| "Customer can't see their loan in the app" | [mobile-app-display.md](mobile-app-display.md) | Does Horizon agree with the contract? If yes, it is a display issue for the mobile team |
| "Last repayment date shows 2030" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | If the Transaction tab term disagrees with the amortisation, it is a datafix (MHD-35653) |
| "A payment came out a year after the account went quiet" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | Three decimal places on a Split Sched amount means a recreated amortisation (MHD-36446) |
| "Duplicate transactions after a shuffle" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | Two shuffles in quick succession both triggered the transaction load (Rusty, `#app-support`, 2026-09-01) |
| "Repayments too high" | [amortisation-shuffle-and-schedules.md](amortisation-shuffle-and-schedules.md) | LOC design limitation. Assign to Josh Allen and apply a payment setting (Confluence 546701313) |
| "Reset Arrears to $0 for Write off account" | [arrears-overdue-and-stage-transitions.md](arrears-overdue-and-stage-transitions.md) | Routine. Apply a contract variation (MHD-36602) |
| "Did not auto move to FS" / "stuck in Overdue despite $0.00 arrears" | [arrears-overdue-and-stage-transitions.md](arrears-overdue-and-stage-transitions.md) | Check arrears on the Scheduled and Due summary, not the amortisation screen (MHD-36790) |
| "Overdue still showing after a contract variation" | [arrears-overdue-and-stage-transitions.md](arrears-overdue-and-stage-transitions.md) | Overdue plus a rejected payment equals no stage move (MHD-32117) |
| "Customer is being charged overdue fees while they are paying" | [fees-and-charges.md](fees-and-charges.md) | Was the account in Overdue stage? The OD fee is every 14 days regardless of payments (MHD-36206) |
| "Customer paid early and still got a $15 dishonour fee" | [fees-and-charges.md](fees-and-charges.md) | Payments allocate to the oldest outstanding amount first (MHD-35381) |
| "Zero interest rate on ApplicationCharge" | [fees-and-charges.md](fees-and-charges.md) | Apply the existing fix script, then rerun the Funding Event (MHD-34728) |
| "Interest rate is wrong on the loan" | [fees-and-charges.md](fees-and-charges.md) | Not a plain UPDATE. The loan has to be shuffled against the new APR (MHD-34449) |
| "Broker commission or establishment fee is wrong" | [fees-and-charges.md](fees-and-charges.md) | Raw script territory, SQL Data Fix scripts items 10, 23, 93, 96 (Confluence 3117842457) |
| "Unable to implement hardship arrangement" | [hardship-and-arrangements.md](hardship-and-arrangements.md) | Is the approved amount inclusive of the monthly fee? (MHD-30961) |
| "System debiting the wrong hardship amount" | [hardship-and-arrangements.md](hardship-and-arrangements.md) | Same check. The gap is usually the monthly fee (MHD-30961) |
| "Unable to set up the arrangement in the Amort tab", LOC | [hardship-and-arrangements.md](hardship-and-arrangements.md) | Manually add the first expected payment, then the schedule displays correctly (MHD-36270) |
| "Hold interest for the hardship period" | [hardship-and-arrangements.md](hardship-and-arrangements.md) | Raw script territory, SQL Data Fix scripts item 40. No stored procedure (Confluence 3117842457) |
| "Unable to submit the Hardship form" | [hardship-and-arrangements.md](hardship-and-arrangements.md) | One instance only, MHD-35690, root cause unverified. Escalate with the application ID |
| "Overdue fee was $5.00 instead of $35.00" / "Sliding fee added to repayment" | [fees-and-charges.md](fees-and-charges.md) | Known open defects MHD-33684 and MHD-32268. Link the ticket rather than datafixing |
| "Customer in hardship didn't get the monthly fee increase" | [fees-and-charges.md](fees-and-charges.md) | Accounts in HS or DNC as at February 2025 were deliberately excluded (Rusty, `#app-support`, 2026-09-15) |

## Comms and access

| The reporter says | Runbook | First check |
| --- | --- | --- |
| "Investigate in Sendgrid - <app id>" | [email-delivery.md](email-delivery.md) | DNC in Horizon, then the SendGrid Bounces suppression list (`#app-support`, repeatedly) |
| "550 No Such User" / "user unknown" | [email-delivery.md](email-delivery.md) | The mailbox does not exist. Removing the suppression will not make it work (MHD-29993) |
| "Customer is not receiving emails" | [email-delivery.md](email-delivery.md) | Open Application Comms and click Load More. The list caps at 21 rows (MHD-36668) |
| "Old email still pops up after updating with the new one" | [customer-and-company-data.md](customer-and-company-data.md) | Contact records are per brand and nothing keeps the three tables in sync (MHD-36009, MHD-35810) |
| "Customer says the passcode reset email is empty" | [email-delivery.md](email-delivery.md) | Gmail trimmed the repeated body. Do not fire more resets (MHD-36075) |
| "Loan agreement never went to the broker" | [broker-and-partner.md](broker-and-partner.md) | Look for an uncleared Review - Contract Sending Failed task (MHD-32267) |
| "Settlement emails arrived twice, months apart" | [email-delivery.md](email-delivery.md) | Compare send timestamps against stage changes. 04:05 sits in the nightly comms window (MHD-36668) |
| "Contract missing" / "contract not sent" | [application-stuck-at-stage.md](application-stuck-at-stage.md) | Review - Contract Sending Failed task first, then the Azure contract generator (Confluence 942047312) |
| "Emails are showing boxed question marks" | [email-delivery.md](email-delivery.md) | `&nbsp;` in the template rendering as U+FFFD. Replace with plain spaces (`#app-support`, 2026-09-16) |
| "Customer received the same message multiple times" | [email-delivery.md](email-delivery.md) | 60-second timeout or 70-second queue time, mostly SOA templates with a missing attachment (Confluence 1079312385) |
| "Not receiving OTP when submitting an application" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | Confirm in Twilio the SMS sent without errors, then suggest spam (Rusty, `#app-support`, 2026-09-03) |
| "Code being sent to incorrect mobile number" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | Duplicate or stale `CustomerContactNo` row, per brand (MHD-33863) |
| "Agent gets disconnected on inbound calls" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | status.twilio.com, then the Twilio network test, then `Communication.dbo.EventLog` (Confluence 1079181314) |
| "No inbound calls are coming through" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | Inbound grouping, then whether the number was switched off in `Configuration` SettingId 1002 (Confluence 1079181314) |
| "The wrong customer's account opens when we answer" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | Two customer records share one phone number (`#app-support`, 2026-07-13) |
| "Twilio call recording issue" | [sms-otp-and-voice.md](sms-otp-and-voice.md) | No verified root cause in the sources. Start with status.twilio.com and Twilio > Call Log (MHD-35238) |
| "Customer can't log in" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Duplicate customer account on mobile or email. The most common real cause (Confluence 3131015188, section 11) |
| "There is an issue with this account" on entering email and mobile | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Migrated customer with no MME account row (MHD-35589) |
| "Unable to reset the passcode" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Run the login diagnostic, Confluence 1398210569 item 1, before deciding anything |
| "Multiple active account found" / "Multiple Inactive account found" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | More than one `CustomerAccount` row on the same (Username, BrandId) (Confluence 3117842457, Pattern B) |
| "Customer is blocked after too many passcode attempts" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Post `reset <email>` in `#unblock-account-request`. G3APIBot handles it, no ticket needed |
| "Invalid code after entering the 4-digit code" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Check whether SMS template 969 ever sent (MHD-36075) |
| "Can log in on web but not on the iOS app" | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | Mobile team, `#app-support-mobile-team` (MHD-35643) |
| Staff: "can't see the tab", "access denied" in Horizon | [login-passcode-and-account-access.md](login-passcode-and-account-access.md) | `AppSupport_InsertRoleAccess`. TabId 295 and 296 are the AFCA arrangement tabs (Confluence 3117842457) |

## Documents, data and partners

| The reporter says | Runbook | First check |
| --- | --- | --- |
| "Unable to generate SOA <app id>" / "SOA won't load" | [soa-generation.md](soa-generation.md) | Check transaction volume. Freestyle and LOC accounts with hundreds of rows are the ones that hang (MHD-35957) |
| "SOA is being sent to an incorrect email" | [soa-generation.md](soa-generation.md) | Compare the Customer contact record against what Issue Doc resolves (MHD-35314) |
| "Negative outstanding charges on the SOA" | [soa-generation.md](soa-generation.md) | `PaidChargeAmount` exceeds `TotalChargeAmount`, tracked as CL-628 |
| "Statement has not been sent yet" (CRD) | [soa-generation.md](soa-generation.md) | Do not use SOA generation on CRD. Use the monthly statements attached to the file (Raina Schmidt, `#solutions_memorandum`, 2026-08-13) |
| "Please update the ABN Active Since date" | [customer-and-company-data.md](customer-and-company-data.md) | Verify against the ABR record first. No stored procedure exists (MHD-34134) |
| "Remove this mobile number, it belongs to someone else" | [customer-and-company-data.md](customer-and-company-data.md) | Neutralise with a placeholder, do not delete (MHD-35960) |
| "Unable to edit contact details on the Customer tab" | [customer-and-company-data.md](customer-and-company-data.md) | Run the Pass A lookups for all three tables, not just the one the ticket names (Confluence 3117842457) |
| "Insert BrandId 5 contact and email to <app id>" | [customer-and-company-data.md](customer-and-company-data.md) | Confirm the BrandId 5 rows really are absent before inserting (MHD-35757, MHD-35758) |
| "Review Funding Follow up: Please check customer contact details" | [customer-and-company-data.md](customer-and-company-data.md) | Same as above. This is the APY BrandId 5 gap (Confluence 3117842457, Pattern C) |
| "Updating the VIN on one application changed the others" | [customer-and-company-data.md](customer-and-company-data.md) | Query `AutopayVehicleDetail` by VIN and `AutopayApplication` by `AutopayVehicleDetailId` (MHD-36240) |
| "Wrong rego plate, VIN, fuel type or seller on the loan" | [customer-and-company-data.md](customer-and-company-data.md) | Vehicle fields have no stored procedure. PPSR and vehicle fields are two separate halves (Confluence 3117842457, Pattern D) |
| "Merge these duplicate customer records" | [customer-and-company-data.md](customer-and-company-data.md) | `AppSupport_MoveAppToCustomer`, then `EXEC dbo.UpdateAmounts` (Confluence 2485059655) |
| "Resend the ID verification link, it's pointing at the wrong customer" | [customer-and-company-data.md](customer-and-company-data.md) | It blocks settlement, and has a named approval gate: Jeffrey Lu and Jon Wu plus the DB team (Confluence 1409351844) |
| "Discharge PPSR on these repaid loans, unable to do it via the UI" | [customer-and-company-data.md](customer-and-company-data.md) | PL/SPL and APY use different procedures. One EXEC block per application, never a loop (MHD-35624) |
| "This note or email is on the wrong account" | [customer-and-company-data.md](customer-and-company-data.md) | No procedure. Raw updates, SQL Data Fix scripts items 30 and 32 (MHD-35066) |
| "Broker's applications are on an inactive login" | [broker-and-partner.md](broker-and-partner.md) | Move the applications to the active login (MHD-36263) |
| "Broker uploaded incorrect documents to a customer file" | [broker-and-partner.md](broker-and-partner.md) | Scheduled clean-up, `AppSupport_DeleteFileUpload`. Irreversible, capture the row first (MHD-36154) |
| "Broker portal stuck on 'calculating your finance details'" | [broker-and-partner.md](broker-and-partner.md) | `IsEditedVehicleDetails` set to 1 on a pre-approval application (MHD-35818) |
| "Wrong lead source or dealership on the application" | [broker-and-partner.md](broker-and-partner.md) | Raw script territory, items 49, 71, 80 (Confluence 3117842457) |
| "Can you update this Autopay field to show a value instead of N/A" | [broker-and-partner.md](broker-and-partner.md) | Intake is `#autopay_feedback`. Ask for root cause as well as the fix (Bec, 2026-09-04) |

## Credit card (CRD)

| The reporter says | Runbook | First check |
| --- | --- | --- |
| "Something on the Credit Card tab is wrong" | [crd-credit-card.md](crd-credit-card.md) | It lives in E6, not Horizon. A Horizon datafix will not fix it (Rusty, 2026-07-02) |
| "Android Virtual Card provisioning failed" | [crd-credit-card.md](crd-credit-card.md) | No E6 account was created for the repeat customer (MHD-35954) |
| "Interest appeared out of nowhere" / "Interest Free Expiry looks like a duplicate charge" | [crd-credit-card.md](crd-credit-card.md) | Interest only ever shows on statement issue day. It is a reallocation (Rusty, 2026-07-02) |
| "The scheduled MMP was not cancelled after the customer paid the bill" | [crd-credit-card.md](crd-credit-card.md) | CRD cancels on bill satisfaction, not the custom/partial rules. Failing to cancel is a defect (MHD-33265) |
| "Split Create/Update Account tasks keep regenerating on a CRD account" | [crd-credit-card.md](crd-credit-card.md) | Known open defect, MHD-35062, Selected for Development |
| "Customer wants their credit card account closed" | [crd-credit-card.md](crd-credit-card.md) | Do not move the stage to Repaid manually. Only the payout process closes it (Rusty, `#solutions_memorandum`, 2026-09-04) |
| "Payout figure generated but no direct debit went out", $0 balance | [crd-credit-card.md](crd-credit-card.md) | Horizon will not submit a DD when the balance is $0. The customer pays manually (Rusty, 2026-09-08) |
| "Cashback or reward credit is wrong" | [crd-credit-card.md](crd-credit-card.md) | Check against the 01/06/2026 E6 incorrect reward credit and the grace period rules (Rusty, `#solutions_memorandum`) |
| "Freestyle customer's migration to CRD was skipped" | [crd-credit-card.md](crd-credit-card.md) | A pending DD blocks migration. Cancel scheduled DDs and retries before the next Tuesday batch (Rusty, `#solutions_memorandum`, 2026-06-18) |
| "An error occurred retrieving card details" / "No option to apply CRD" | [crd-credit-card.md](crd-credit-card.md) | Known open defects MHD-29029 and MHD-30782. Link, do not datafix |

## What is not in these runbooks

- **Trust and SPV migration.** Nothing usable was found. `text ~ "trust migration"` returns zero
  MHD issues in the window. The only SPV-adjacent ticket is MHD-36622, a permissions change.
- **Sentry triage.** Lives in [../03-procedures/sentry-and-error-triage.md](../03-procedures/sentry-and-error-triage.md),
  because it is an alert queue rather than a reported symptom.
- **Release tickets.** A ticket titled `[X - Code Release]` or `[X - Database Release]` is not an
  incident. Follow the release process (Confluence 3117842457, Part 1).
- **Anything not on this page.** Verdict is Unknown. Escalate rather than improvise
  (Confluence 3117842457). Escalation map is in
  [../05-knowledge/escalation-map.md](../05-knowledge/escalation-map.md).
