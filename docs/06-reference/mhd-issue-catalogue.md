# MHD recurring issue catalogue

The recurring themes in MHD with symptoms, confirmation steps, root causes, fixes and precedents. The runbooks in 02-runbooks are built from this.

Last reviewed: 23 September 2026
Sources: Jira MHD, 2025-09-01 to 2026-09-23

Mined from MHD (and linked HOR, CL, AMZ, CRD, MMM, G1 tickets) for the period 2025-09-01 to 2026-09-23.

Customer names, email addresses, phone numbers and addresses have been removed. Horizon application, loan, customer and transaction IDs are retained deliberately, as worked examples. Internal MoneyMe staff names are retained.

A note on one name that recurs: **"Rusty" is Josh Allen.** Tickets escalated "to Rusty" come back with a comment from Josh Allen. He is the standing authority on amortisation, schedules and Freestyle behaviour, and his position on a defect is usually the final word on whether it will be fixed.

---

## 1. Statement of Account (SOA) generation

**Volume:** 193 Problems in the window. Consistently 3 to 6 a week.

### Symptoms as reporters describe them

- "Unable to generate SOA <app id>"
- "SOA won't load"
- "SOA request <app id>" (often with no detail at all)
- "Fix SOA generation loading issue for Application <id>"
- "SOA is being sent to an incorrect email"
- "Manually generate SOA for LOC <id> due to high transaction volume"

### How to confirm it in Horizon

Open the application and attempt the SOA from the Issue Doc path. The failure presents as an indefinite spinner, not an error. Check the account's transaction volume first: long-running Freestyle and LOC accounts with hundreds of rows are the ones that hang.

For the wrong-recipient variant, compare the address on the Customer contact record against what Issue Doc actually resolves. The two can differ, see theme 4.

### Root causes seen

1. **Transaction volume.** High-transaction accounts, particularly Freestyle and LOC, time out during generation. MHD-35957 states this explicitly.
2. **File size.** The generated SOA exceeded Horizon's 10 MB upload ceiling. HOR-8167 was raised proactively for this: *"The Statement of Account (SOA) file size is expected to increase significantly due to the implementation of CRD and higher transaction volumes. This was previously an issue in the Freestyle project."*
3. **Stale or brand-mismatched contact record** sending the SOA to a superseded address.

### The fix

For the generation failures the standing resolution is **App Support generates the SOA manually and attaches it to the ticket**, with the instruction "please check the file before sending to the customer". This is a workaround performed dozens of times a month, not a fix. Typical turnaround is under two hours (MHD-35789 raised 10:01, delivered 11:51; MHD-35850 raised 09:15, delivered 09:41).

For the recipient variant it is a contact data fix, executed under the monthly umbrella ticket.

### Structural work in flight

**HOR-8167 / MHD-34644 / MHD-36453** raise the Horizon upload limit from 10 MB to 30 MB.
- Config-driven `appSetting FileUploadSizeLimitInMB = 30`, plus `web.config maxAllowedContentLength` at 35 MB because 30 MB exceeds the roughly 28.6 MB IIS default.
- Client-side pre-check rejects oversized files at selection instead of hanging. Rejection message is exactly `File size is exceeding to its limit 30 mb`.
- **The IIS limit was raised site-wide**, so it affects Visa, Bank Recon and Campaign Dialer upload screens too. Sanity-check those after any related release.
- QA passed 2026-08-06 (Jeric Mislang). Ron passed UAT on Integration 2026-09-09: 25 MB uploaded, 30.2 MB uploaded, 31 MB correctly rejected. Prod test passed 2026-09-10 on app 10003089519.
- **Out of scope and still open:** the system-generated SOA *email* ceiling. SendGrid caps attachments at roughly 30 MB, so a 30 MB SOA will still fail to email. Flagged by John Mark Gabriel on HOR-8167 and never given a ticket.
- Related: HOR-8183, the shared uploader shows no error and hangs on failed uploads, still in QA Ready.

### Precedents

MHD-35789, MHD-35850, MHD-35742, MHD-35718, MHD-35499, MHD-35511, MHD-35449, MHD-35957, MHD-35315, MHD-35333, MHD-36398, MHD-36803, MHD-36047, MHD-36152, MHD-36157, MHD-36074, MHD-35953, MHD-35894, MHD-35899, MHD-35700, MHD-35326, MHD-36710, MHD-36635. Wrong recipient: MHD-35314. Upload limit chain: HOR-8167, HOR-8170, HOR-8183, MHD-34644, MHD-36453, QAAUTO-1845, QAAUTO-1992.

---

## 2. Email delivery and communications

**Volume:** 602 Problems matching `SendGrid OR bounced OR email`, the single largest theme.

### Symptoms

- "Investigate in Sendgrid - <app id>" (a near-weekly standing request)
- "550 No Such User - <app id>"
- "Email keeps failing <app id>"
- "Not receiving email"
- "Email reverting to old email address" / "Old Email Still Pop Up after updating with new one"
- "Email Bounced Multiple times yesterday"
- "Investigate delayed settlement confirmation emails"

### How to confirm it in Horizon

Open **Communication / Application Comms** for the application. The list view **caps at 21 rows**; you must click Load More to see the full history. On MHD-36668 the full history was 33 rows and the missing rows were the point of the ticket. Check send status per message (Open, Delivered, Failed) and the template ID.

Then check SendGrid's suppression lists directly. App Support cannot see suppression status from Horizon at all today.

### Root causes seen

1. **SendGrid suppression.** The address is on the Bounced, Blocked or Spam Reports list. Every future send to it fails silently until someone removes it by hand in SendGrid. MHD-29993 is the clean worked example: a broker address was on the Bounces list with a 550 error, Michael Dela Torre removed it manually and warned it would likely re-bounce.
2. **Per-brand contact records out of sync.** See theme 4. The update is applied to one brand's contact row and not the others, so comms keep resolving the old address.
3. **Recipient-side mail client behaviour, not a defect.** MHD-36075 is the definitive write-up: four identical passcode reset emails within 25 minutes were threaded by Gmail and the repeated body collapsed behind a "…" *show trimmed content* control. The customer read that as an empty email. All four emails were intact and Delivered. Triggering more G3APIBot resets makes it worse, because each identical resend deepens the trimming.
4. **A blocking task on the application.** MHD-32267: a broker's loan agreement (template 2146) never sent after funding. The cause was an uncleared **Review - Contract Sending Failed** task. Michael Dela Torre's standing guidance: *"we should make sure that it's cleared first. There will be additional info in Notes, if the error message is about mobile or email, we should let the agent fix it first."*
5. **Comms engine re-firing.** MHD-36668: settlement emails for application 10003015808 sent correctly at 17/07/2026 11:01, three minutes after Fund Sent, then the identical pair sent again 61 days later at 16/09/2026 04:05 with no stage change in between. 04:05 sits inside the nightly comms window for that account.

### The fix

- Suppression: manual removal in SendGrid, then retry. Expect a repeat if the address is genuinely dead.
- Contact sync: data fix under the monthly umbrella.
- Gmail trimming: coach the reporter, do not trigger more resets. Tell the customer to open the **first** email in the thread or tap the "…".
- Blocked task: clear the Review task, fix the underlying contact error first if the task names one.

### Known defects raised and not yet fixed

- **MHD-35799** (Pending, Medium): add a Horizon button to view and clear a SendGrid suppression across all three lists, permission-gated, writing an audit note. Ron wrote the full acceptance criteria. It cites roughly 25 similar tickets and examples MHD-35666 and MHD-35539. Not built.
- **G1-7161** found that Bounced and Spam Reporting entries are standing do-not-send instructions and the send path **keeps retrying them anyway, around 50,000 futile sends**, and lists "Missing blocked/deferred event handling" as an untracked follow-up.
- **Template 970** ("Forgot Passcode Email To Generate Verification Code") renders **"Reference number 0"** instead of the application ID. Cosmetic but wrong. Found on MHD-36075, never given its own ticket.
- Reset emails are byte-identical on repeat sends, which is what triggers Gmail trimming. Adding a timestamp or reference to the body would prevent it. Not raised.
- **MHD-34298** "Fix incorrect email generation in ApplicationComms", Selected for Development since 01/07/2026.
- **MHD-26581** "Horizon - Email Deliverability", Selected for Development since 02/09/2025. Over a year old.

### Precedents

MHD-29993, MHD-29956, MHD-29963, MHD-29996, MHD-29997, MHD-30009, MHD-30036, MHD-30067, MHD-29744, MHD-29730, MHD-29734, MHD-29883, MHD-30309, MHD-30425, MHD-30808, MHD-31353, MHD-32398, MHD-32679, MHD-33633, MHD-33954, MHD-34093, MHD-34117, MHD-34838, MHD-34981, MHD-35539, MHD-35666, MHD-36007, MHD-36527, MHD-36407. Template and workflow: MHD-32267, MHD-36668, MHD-33771, MHD-35193, MHD-33293, MHD-35658. Tooling: MHD-35799, MHD-34298, MHD-26581, G1-6834, G1-7161.

---

## 3. Login, passcode reset, OTP and SMS

**Volume:** 286 Problems on `login OR passcode`, 149 on `OTP OR SMS OR Twilio`. Overlapping sets.

### Symptoms

- "Unable to login" (the single most common summary line in the whole project)
- "Unable to reset the passcode | <brand> | <app id>"
- "There is an issue with this account" on entering email and mobile
- "invalid code" after entering the 4-digit code
- "Not receiving OTP when submitting an application"
- "Code being sent to incorrect mobile num"
- "Cannot receive SMS code"

### How to confirm it in Horizon

Check Application Comms for the reset sequence. The normal flow is:
1. Customer requests reset, **email template 970** goes out.
2. Customer taps the CTA, **SMS template 969** delivers the 4-digit verification code.
3. Customer enters the code.

Check whether 969 ever sent. If it did not, the customer never reached the button, which is usually a rendering or trimming problem at their end, not a send failure. Check `#forgot-pin-spam-alert` in Slack for rate-limit hits on the customer.

For migrated customers, check whether an **MME account record exists at all**.

### Root causes seen

1. **Missing MME account row on a migrated customer.** MHD-35589: an OzMoney CRD customer migrated across, hit "There is an issue with this account" on every login attempt. Michael Dela Torre's finding was one line: *"Initial Investigation: No MME account. Resolution: Insert MME account."* This is a recurring migration gap.
2. **Mail client trimming, not a defect.** MHD-36075, see theme 2.
3. **Carrier-side SMS delivery.** MHD-31787: the customer's carrier (Optus) claimed the messages never reached their network while internal logs showed successful delivery. Raised directly with Twilio, who confirmed working as expected. Closed as no defect.
4. **Mobile number mismatch or duplication.** "Mobile number/Email does not match on our system", MHD-36210. Duplicate mobile associated to two customers, MHD-32624.

### The fix

- Missing MME account: insert the account row via data fix.
- Reset loop: use G3APIBot in `#unblock-account-request`, but **do not fire repeated resets**. MHD-36075 shows each identical resend makes the customer's inbox worse, not better.
- Carrier issues: raise with Twilio, expect "working as expected", close as no defect and tell the customer to check their carrier.
- Contact mismatch: data fix.

### Open item

MHD-36075 closed with one thing unexplained and it was never chased: the SMS with the code was Delivered at 10:26, yet the customer's first attempt returned "invalid code". Expiry, mistype or a genuine validation defect was never determined. Ron asked the reporter to confirm and the ticket auto-closed after five days with no answer. Worth checking against MHD-29695 "Investigate Blank Temporary Code Issue" (16/01/2026), which was closed with a one-off data fix rather than a code change.

### Precedents

MHD-35589, MHD-36075, MHD-36186, MHD-35475, MHD-35418, MHD-35362, MHD-35364, MHD-35136, MHD-34985, MHD-34651, MHD-34441, MHD-34121, MHD-33905, MHD-33863, MHD-33818, MHD-33724, MHD-33524, MHD-33414, MHD-33257, MHD-32677, MHD-32518, MHD-32114, MHD-31779, MHD-31787, MHD-31736, MHD-31437, MHD-31174, MHD-30222, MHD-36641, MHD-36338, MHD-36268, MHD-36193, MHD-36210, MHD-36010, MHD-35955, MHD-35867, MHD-35853, MHD-35644, MHD-35643, MHD-35626, MHD-35664, MHD-35713, MHD-35513, MHD-29695.

---

## 4. Data and brand mismatches (contact records, VIN, lead source)

**Volume:** the largest single stream of data fixes. 61 project-wide hits on `brand id`.

### Symptoms

- "Old Email Still Pop Up after updating with new one"
- "Email reverting to old email address"
- "Unable to edit contact details on Customer tab for specific record"
- "Insert BrandId 5 contact and email to <app id>"
- "Updating the VIN on one application incorrectly updates the others"

### How to confirm it in Horizon

Contact records are held **per brand**. A customer who has held MoneyMe, OzMoney and SocietyOne products has separate contact rows for each. Updating the address on the Customer tab may only write to the brand you are looking at. Check every brand's contact row, not just the active one.

For VIN, query `AutopayVehicleDetail` by VIN and `AutopayApplication` by `AutopayVehicleDetailId`.

### Root causes seen

1. **Per-brand contact desync.** MHD-36009 is the clean example: correspondence kept going to the old address for application 10003012512 because *"the old address was still held on the customer's SocietyOne (SOC) brand contact record, the update was applied to the MoneyMe and OzMoney records but not SOC."*
2. **Missing brand contact row entirely.** MHD-35757 and MHD-35758, "Insert BrandId 5 contact and email".
3. **Shared foreign key across applications.** MHD-36240 is the best-documented data fix in the window. Three funded Autopay applications (10002846570, 10002847296, 10002846116) all pointed at the same `AutopayVehicleDetailId` 233752, so editing the VIN on one changed all of them. A fourth, 10002851749, was also attached. Correct IDs were 247005, 234651 and 234467 respectively, and there were two duplicate rows holding the same VIN. Traced back to data fixes performed during the **April 2026 Glass Guide outage**. PPSRs and loan agreements still held the correct individual VINs, which is how it was confirmed to be a Horizon-side data problem and not a contract problem.

### The fix

Data fix under the monthly `[App Support] Data Fix - YYYY-Mon` umbrella. For MHD-36240 the approach was to repoint each application to its correct `AutopayVehicleDetailId` and remove the duplicate row once no application referenced it.

### Precedents

MHD-36009, MHD-35754, MHD-35641, MHD-35757, MHD-35758, MHD-36037, MHD-35596, MHD-35692, MHD-36240, MHD-35305, MHD-36653, MHD-36686, MHD-35359, MHD-35970, MHD-30694, MHD-32267. Customer and application moves: MHD-35572, MHD-36049, MHD-36128, MHD-36200, MHD-35797.

---

## 5. Amortisation, shuffle and repayment schedules

**Volume:** 47 Problems on `shuffle`, 183 project-wide on `Amortization`.

This is the theme with the deepest precedent chain and the clearest unfixed defect.

### 5a. Repayment amount wrong after a frequency shuffle

**Symptoms:** "The repayment amount increased following a system adhoc shuffle", "Repayment amount remains unchanged", "The amount remains fixed at $300 after shuffling account from minimum payment $300 FN to Monthly", "Unable to Shuffle on the 15th of the month", "Unable to shuffle to the correct date".

**How to confirm:** compare the pre-shuffle contractual instalment and frequency against the post-shuffle rows in the Transaction tab. A correct conversion from monthly to fortnightly is roughly the monthly figure times 12/26. If the post-shuffle fortnightly figure is close to the old **monthly** figure, the frequency label changed but the amount did not convert.

**Root cause:** the adhoc shuffle changes the frequency label without recalculating the instalment. Ron's analysis on MHD-36071, account 10001184043 (Freestyle CCC, MME, limit $19,750, balance $20,382.53, APR 19.49%):
- 04/05/2026 contractual repayment $1,065.40 **monthly**
- 18/06 to 18/08/2026 hardship arrangement $295/mo, three payments, all cleared
- 21/08/2026 10:10 adhoc shuffle runs, creates two rows: Split Sched $1,097.598 on 09/09 and 23/09, labelled **fortnightly**
- Both figures are monthly instalments amortised over the same horizon. $1,065.40 against the May balance gives 22.5 months, $1,097.598 against the August balance gives 22.3 months. The 3 per cent difference is entirely balance growth.
- A correct fortnightly conversion would be roughly **$499.00** ($1,065.40 x 12/26 = $491.72).
- Customer impact: $12,784.80 a year became $28,537.55 a year, a **123 per cent increase**, applied three days after the customer exited hardship.

**The fix, such as it is:** apply a **continuous payment setting** at the correct amount. Josh Allen's position on MHD-30258 was explicit: *"Unfortunately your workaround is the only option we have in this case."* On MHD-36071 the team's position was that Freestyle is being discontinued and hardship apps migrated, so no fix is expected; agents should manually schedule payments or use Payment upload for bulk scheduling.

**Precedent chain, all unfixed:**
- **MHD-30258** (06/02/2026), Freestyle adhoc shuffle, $299.48 to $507.81 fortnightly. Reporter had already applied a continuous setting of $299.48 as a workaround. Josh Allen confirmed the workaround was the only option. Closed same day.
- **MHD-31738** (08/04/2026), $300 fortnightly to $397.20 monthly, should have been roughly $650. Escalated to Collections, never root-caused, auto-closed after 39 days. Note the reporter's point: *"We do not process manual adjustments for Freestyle account. The update should be automatically generated once the shuffling process in Horizon has been completed."*
- **MHD-35875** (20/08/2026), fortnightly to monthly, amount did not change at all. Auto-closed after six days with no investigation recorded.
- **MHD-36071** (27/08/2026), monthly to fortnightly, amount not converted. Full analysis, workaround applied, auto-closed.

Do not conflate this with the fix released 14/05/2026 referenced on MHD-31974. That addressed shuffles **overriding existing arrangements**, a different failure mode. The frequency-conversion defect is separate and still live.

**Also found on MHD-36071:** the Amortization page for Freestyle account 10001184043 returns *"Something is wrong with the input request. (Inner Exception: No Product Context associated with Product Name & Brand ID 'CCC-1')"* on both horizon and horizon4. App Support cannot verify Freestyle schedules through the UI at all. Raised in the comment, never given a ticket.

### 5b. Loan term shown wrong in the mobile app

**Symptom:** "It's showing that loan term is 3 years when it should be displayed as 3 years and 7 months or 43 months."

**How to confirm:** check Horizon Application Overview, Application details, Amortisation (Payment Count) and the Transaction tab. If all four agree with the credit contract, the fault is in the app or API, not the data, and **no data fix is required**.

**Root cause (MHD-36092, application 10003066205):** the server sends two fields in the same response. `DurationInYears` carries "3 years", rounded down, and is what both iOS and Android wire to the Term row. A separate months field carries the accurate "43 months" and is delivered but never displayed. Both arrive as plain text rather than numbers, so neither app can convert. Neither app performs any calculation.

History, from the RCA by Paul LV Jain:
- Android has always shown whole years.
- Before May 2025 iOS read the accurate months field and correctly showed "43 months".
- May 2025, a "Platform disparity" review flagged the disagreement, ranked it low priority, marked **Android as correct** citing a Figma design that no longer exists.
- 21/05/2025, **MMM-9350** changed iOS to match Android, one line swapping the accurate months field for the rounded years one.
- It passed QA, UAT and production checks because every test account happened to have a whole-year term.
- 01/09/2026 a customer reports it.

Code refs examined: iOS `moneyme_ios` master @ `0a3877ab2` (19/08/2026), Android `moneyme_android` origin/master @ `7d08e1eaa` (30/08/2026).

**Status:** MHD-36092 is Selected for Development, linked to **MMM-16301** (To Do). Two viable fixes are on the table and nobody has picked one: correct what `DurationInYears` returns server-side, or point the apps at the months field they already receive. The RCA lands on the first without reconciling the second.

**Scope:** any loan whose term is not a whole number of years. On PL that is common, 42 and 43 month terms in two consecutive tickets. This is a **disclosure mismatch against the credit contract**, not a cosmetic issue.

**Distinguish from MHD-35653.** There the Transaction tab genuinely held a stale 36-month term against an actual 42-month amortisation, showing a last repayment date of 17/01/2030. That **was** a data fix, executed under MHD-35277 and tracked as MHD-35509. If Horizon and the contract disagree it is MHD-35653; if only the app disagrees it is MHD-36092.

### 5c. Dormant schedule and delayed debit

**Symptom (MHD-36446):** SocietyOne account 2000019464, IDR dispute 21134 lodged, customer threatened media escalation. A payment of $186.672 was taken on 07/09/2026, more than a year after the last activity.

**Timeline:**
- Funded 10/03/2021, contract end 24/02/2026.
- Last normal fortnightly debit 12/08/2025.
- 15/08/2025 the customer paid $5,000 by card to close the account, leaving a residual of $355.36 ($168.70 principal plus $186.66 interest).
- Then **374 days of nothing**. No debits, no comms, no collection activity.
- 24/08/2026 03:00, the system wrote off the remaining principal of $168.70.
- 24/08/2026 03:03, three minutes later, it created a new Split Sched for $186.672 dated 07/09/2026.
- That cleared 09/09 09:38. The "Your SocietyOne loan is Repaid!" email went out at 09:45, seven minutes after the money had gone.

**Root cause:** **AMZ-7074** "Cancel and Create Schedule instead of updating" (Done, AmortizationV2). The old behaviour: when a customer near the end of their loan made an ad hoc card payment, amortisation schedules already picked up by the Transaction Loader were cancelled **but not replaced** with new Proposed schedules. The residual was left with nothing scheduled against it, which is why there was nothing to collect and nothing to send comms about.

AMZ-7074 was raised 20/08/2025, five days after the card payment, and sanity-tested on production 22-23/10/2025 as part of Fee Revamp Phase 1. The fix only acts during actualisation when a payment amount changes. This account stayed dormant a further 306 days, so nothing triggered it. The write-off on 24/08/2026 was the first amount change, and the corrected system then created the schedule that should have existed since August 2025.

**The three decimal places are diagnostic.** $186.672 rather than $186.67 means a recreated amortisation holding a computed value rather than a transaction amount rounded to cents. If you see three decimals on a Split Sched, suspect a recreated schedule.

**Related precedent:** AMZ-7074 carries a `covers` link to **MHD-27965** "Payment schedule stopped for 6months", closed at Low. Same family of long-dormancy schedule anomaly.

**Acceptance criteria Ron set and which were not met before auto-close:** refund the $186.67, give the customer a plain-language explanation, respond to IDR dispute 21134. A priority re-rate was requested and never applied.

### Precedents for theme 5

MHD-36071, MHD-30258, MHD-31738, MHD-35875, MHD-31974, MHD-36092, MHD-35653, MHD-35277, MHD-35509, MMM-9350, MMM-16301, MHD-36446, AMZ-7074, MHD-27965, MHD-36006, MHD-36011, MHD-34725, MHD-34602, MHD-34449, MHD-34321, MHD-34131, MHD-33009, MHD-33162, MHD-32598, MHD-31364, MHD-31109, MHD-31110, MHD-28152, MHD-35208, MHD-33786, MHD-34522, MHD-32466, MHD-30381, MHD-35504, MHD-36564.

---

## 6. Direct debit, dishonour and payment scheduling

**Volume:** 71 Problems on `direct debit`, 36 project-wide on `dishonour`.

### 6a. "Add Payment Denied"

**Symptom:** scheduled direct debits rejected on the day with the note "Add Payment Denied", sometimes for months, while the customer keeps paying by card or transfer.

**How to confirm:** pull the provider failure payload using `PaymentRef` in the form `<applicationId>-<transactionId>`. Check whether the failures are recent or long-standing. Note that **cancelled transactions do not display in the Horizon transaction grid**, so a payment that appears to have vanished may be a cancelled row you can only see in the database.

**Root cause:** the customer's nominated account is not debitable. Worked example from MHD-35514, application 10002269829, transaction 108364618:

```
"FailureReason": "Authoriser contact (...) bank account (...) is blocked and not eligible (Non-debitable account type).",
"PaymentRef": "10002269829-108364618",
"PaymentAmount": 1079.17,
"PaymentStatusId": 27007,
"Provider": { "Name": "Split", "AccountId": 446967 }
```

**The fix:** the customer nominates a different, debitable account. Any further attempt on the existing direct debit fails identically. Take the immediate payment by card or bank transfer.

**Worked recurrence, MHD-36618, application 10002220007:** debited successfully seven months in a row from 12/07/2024 to 13/01/2025, then every scheduled Split payment denied from 12/02/2025 onward, twelve in a row with no successes. Bank details in Horizon were correct (NAB, Split Account Active and set as Default). Re-adding the direct debit on 22/06/2026 did not help, which confirms the block is provider-side. A cancelled August row was found only in the database: `108348993 | $834.47 | 2026-08-04 | CANCELLED DUE TO PAYMENT UPLOAD TOOL | TranId: 108528370`.

Related: MHD-36607 and MHD-36629 are separate reports against the same account in the same week. MHD-36629 was closed as Duplicate.

### 6b. Scheduled debit not cancelled after an early payment

**Symptom:** customer pays early, the scheduled direct debit runs anyway, rejects, and triggers a missed-payment notification and sometimes a dishonour fee.

**Root cause varies by product, and this is the important part:**

- **Personal Loan:** an early payment covering the next repayment **does** cancel the upcoming direct debit. Working as designed.
- **Freestyle:** the Custom Amount option is a one-off payment against the balance and does not touch the scheduled debit. Next Repayment is not available for Freestyle in the app, so the customer cannot adjust the schedule themselves. MHD-35019 documents this in full. Josh Allen's and Product's position is that Freestyle is being discontinued, so this will not be fixed; handle manually.
- **Credit Card (CRD):** the ad hoc payment rules do not apply. **Rusty's (Josh Allen's) recorded position on MHD-33265:** *"the ad hoc payment rules do not apply to CRD. When the payment is settled in advance, it should cancel the scheduled DD."* That is, CRD should behave like PL. The interim workaround recorded on MHD-33265 was "cancel by agent". The permanent fix shipped as **CRD-2459**, bundled in the release **MHD-33404** (which also carried CRD-2308 cashback clawback, CRD-2074 configurable Apple credit, CRD-2269 limit-change history, CRD-1783 minimum limit). CRD-2459 was raised off application 10002813976, the same application as MHD-33265. Release task RB-1558, Released. A further related release is **MHD-35241**.
- **Overdue accounts are a special case.** MHD-36283, application 10002445060: an officer created a $1,000 ad hoc payment (transaction 109268769) on 12/08/2026, the customer then paid by Debit Card Live (transaction 109268780) roughly two minutes later, and the ad hoc was marked **Rejected** rather than cancelled. Michael Dela Torre's answer after checking with the dev team: *"the debit card live was supposed to cancel the direct credit transaction because it can cover the direct credit. The only problem is the stage of the app before it happens. Since the app's on the overdue stage, we have special rules around it and we can only cancel retry transactions. Instead, the transaction continued as proposed and was rejected after 3 working days, because of our business rule that is 'Payment not actioned'."*

**The rule to remember:** a proposed payment that is not processed within **3 working days** is rejected as "Payment not actioned". On overdue-stage accounts, only **retry** transactions can be auto-cancelled.

### 6c. Payments stuck in Proposed

**Symptom:** "Direct Debit payments for several accounts are still in 'Proposed' status despite the scheduled payment date having passed."

MHD-34293 (01/07/2026) covered six accounts at once: 10002249595, 10002270641, 10002970835, 2000186241, 10002967754, 10002852548. Escalated to Tops and fixed by Tops and Harvey within a day. No root cause recorded in the ticket, which is a gap. Also MHD-34732, "Investigate direct debit stuck in proposed status for transaction 10002058837".

### 6d. Zepto bulk late dishonour recoveries

A recurring batch operation, not a defect. Zepto returns a file of late dishonours and App Support runs bulk reversals.

**The standing execution plan, recorded by Jess Leal on both MHD-30926 and MHD-36494:**
1. Run the Soft Execution Script **after** running the Collections team's script.
2. Amortisation team verifies the results.
3. Run the Actual Execution Script.
4. Amortisation team actualises the affected applications.

Christopher Enriquez's instruction on both: *"Please run this before the amortization scripts."*

**The standing blocker, and the thing to check first:** the file Collections supplies usually carries only Amount and Zepto PR Ref, with **no ApplicationId or TransactionId**, so the payments cannot be located in Horizon. On MHD-36494 the file had 185 rows totalling $78,611.86 and had to be sent back for the account mapping. The precedent for supplying the mapping is **MHD-14377**.

**Two questions Michael Dela Torre raised on MHD-36494 that should be asked on every batch**, because the customers are not at fault:
- Should dishonour fees be suppressed on the reversals?
- Should stage movement and arrears capture be disabled, so that 185 accounts do not move into collections at once?

Backups are taken as `Transaction_MHD<ticket number>`.

**Precedents:** MHD-36494, MHD-30926, MHD-30048, MHD-30342, MHD-30348, MHD-28907, MHD-35813, MHD-14377.

### Precedents for theme 6

MHD-35514, MHD-36618, MHD-36607, MHD-36629, MHD-33265, MHD-33404, MHD-35241, CRD-2459, RB-1558, MHD-36283, MHD-35019, MHD-34293, MHD-34732, MHD-35707, MHD-35890, MHD-36766, MHD-36623, MHD-36693, MHD-35631, MHD-34447, MHD-34761, MHD-32507, MHD-31613, MHD-32196, MHD-35062.

---

## 7. Arrears, overdue balance and stage transitions

**Volume:** 300 Problems on `arrears`, the second largest theme.

### 7a. Reset arrears on a written-off account

This is a routine request, not a defect. Volume is a few a week.

**Symptom:** "Reset Arrears to $0 for Write off account", "Applied Variation for WO account", "Removed arrears to write-off account".

**The fix:** apply a **contract variation** to reset arrears to $0.00. The reporter normally shuffles the scheduled payment first. Example, MHD-36602, SocietyOne PL Broker 10002127727, raised 10:17 and done by 16:16 the same day.

**Precedents:** MHD-36602, MHD-36819, MHD-33703, MHD-35578, MHD-31716, MHD-31732, MHD-31457, MHD-31354, MHD-30830, MHD-35710, MHD-35501, MHD-35367, MHD-35206, MHD-34601, MHD-33862, MHD-33638, MHD-36573, MHD-35594.

### 7b. Account stuck in Overdue with $0.00 arrears

**Symptom:** "did not auto move to FS", "Investigate account status transition to FS when arrears are paid in full", "LID stuck in Overdue stage despite $0.00 arrears". The practical harm is that the account keeps appearing in outbound collections campaigns.

**How to confirm:** verify arrears on the **Scheduled and Due summary**, not the amortisation screen. Michael Dela Torre notes on MHD-36790 that the amortisation screen *"is where this sort of thing has been misread before"*. Then check the stage history for whether the move was made by System User or by a person.

**Root cause, recorded as a rule on MHD-32117:** *"the stage did not automatically move to FS due to the rejected payment. The workflow logic is: **Overdue + Rejected payment = no stage move**."*

MHD-34734 confirmed the pattern on account 10002120225 and showed it recurring:
- 09/07/2026, auto-moved to Overdue because a scheduled Direct Credit (transaction 107630018) sat unprocessed and was marked **Rejected, "Not processed in last 3 days"**.
- 10/07/2026, a separate ad hoc payment (transaction 108582314) cleared and brought arrears to $0.00.
- The stage stayed on Overdue until Jonathan Flack moved it manually on 15/07/2026 (Overdue to Payment Plan to Fund Sent). The same manual move had been needed on 11/05/2026.
- Earlier transitions on the same account (31/12/2025, 26/09/2025, 14/11/2025) moved automatically via System User, so the automation does work in the normal case.

On MHD-32117 Josh Allen said the team was reworking stage-transition workflows to be more reliable, expected "by end of this year". As of MHD-34734 (16/07/2026) it had not landed.

**A second hypothesis, newer and not yet confirmed.** On MHD-36790 (22/09/2026, APY account 10002108249) Michael Dela Torre recorded that the Overdue to Fund Sent move requires four conditions, one of which is that **the last successful payment is dated today**. He suspects that check reads the **transaction date rather than the clearing date**. On that account direct debits consistently take two to four days to settle, so the condition could never be met on the day the money lands. Note the correction he made to the reporter's timeline: the retry's clearing date was 11/09, not 09/09, which was its transaction date. Raised with the Horizon workflow team, still open. He asked for a second example to pin it down.

**The fix:** move the stage manually. There is no automated remedy today.

**Precedents:** MHD-32117, MHD-34734, MHD-36790, MHD-36600, MHD-33036, MHD-31915, MHD-30935, MHD-35433, MHD-31967.

### 7c. Arrears and fees that are correct but look wrong

Two patterns that are **working as designed** and should be closed as such, with the reasoning given to the reporter.

**Overdue fee charged despite payments (MHD-36206, application 10002399667).** Per the Overdue Fee Structure, an OD fee is charged **every 14 days while an account is in Overdue stage, regardless of payments being made**. A DH (dishonour) fee is separate and charged only when a payment rejects. On this ticket the account had been Overdue since February with arrears of $1,153.85. The fees were correct, but the customer had been Financial-Support at the time and would not have shown as overdue had a Courtesy Variation not forced them ahead of schedule, so Jason McGuire approved waiving them.

**Early payment absorbed by arrears (MHD-35381, application 10002937235).** Payments always go to the **oldest outstanding amount first**. A customer a month behind who pays the current month's minimum has it absorbed by the previous statement, so the scheduled direct debit still runs, rejects, and triggers a $15 dishonour fee. The payment plan correctly stays active because it covers arrears only and runs alongside normal monthly minimums; it is cancelled only when arrears clear.

Josh Allen's arithmetic on that ticket is the clearest statement of the rule and worth keeping verbatim:

> Arrears = 602.89 − 50.25 − 50.25 **+ 629.51 August bill due** **− 629.51 August payment made** = 502.39 arrears
>
> "Even though the July bill is now 'satisfied' and the $502.39 is against the August bill, the total arrears amount is the same. We certainly don't need to cancel the PP every month and create it again."

He added that the team is working on this so the behaviour will change and align with other products.

**The service lesson from MHD-35381:** the customer had been told on 07/07 that paying after the statement is issued stops the direct debit. That is true when the account is up to date and false when there are arrears. Ron recommended waiving the $15 fee on that basis and it was waived. **Tell customers with arrears that they must cover arrears plus the current month's minimum, or call to have the debit cancelled.**

---

## 8. Hardship and payment arrangements

**Volume:** 18 Problems on `hardship`.

**Symptoms:** "Unable to implement hardship arrangement", "System Debiting Incorrect Hardship Arrangement Amount", "Unable to set up the arrangement in Amort Tab", "Unable to submit the Hardship form".

**Root causes and fixes seen:**

1. **Amount short by the monthly fee.** MHD-30961, account 10000796502: approved arrangement was $150/month, the system captured $145. The $5 gap was the monthly fee. Not a defect: the amount had been set with the include-fee flag false. Set the amount to $150 explicitly if you want $150 debited.
2. **LOC with nothing scheduled shows the full schedule.** MHD-36270, application 10001806432. Josh Allen's workaround, quoted: *"please manually add the first expected payment, then it will display correctly. Horizon gets confused when an LOC has nothing scheduled, so it shows the full schedule. Adding in the first payment manually shows it where to start, and removes the confusion."*
3. **Ongoing payment amount cannot be tagged after the manual first payment.** The reporter on MHD-36270 could set the next due date but not tag $80 as ongoing, and the schedule kept showing $40.74. Josh Allen confirmed: *"as long as the payment setting stays in place, the repayments will actually process for $80. This is just a display issue, and due to Freestyle being phased out, it is not likely to be fixed."*

**Precedents:** MHD-30961, MHD-36270, MHD-30381, MHD-35690, MHD-33537, MHD-31062, MHD-30000, MHD-36071 (hardship exit interacting with shuffle).

---

## 9. Funding, settlement and application stage

**Volume:** 197 Problems on `funding`.

### Symptoms

- "Investigate and resolve application stuck at 'Signed Off' status"
- "Investigate application stuck in 'app-esign accepted' stage"
- "Investigate application stuck in pre-settlement status"
- "Reprocess application for funding"
- "Refund Funding Error 'No Bank Account'"
- "Insert Equifax Score" (the highest-frequency single request in this theme)

### How to confirm in Horizon

Open the application's Tasks tab. Stuck applications usually have an unresolved or failed task. For "No Bank Account" errors, check whether `applicationbankid` in the application bank table is NULL despite bank details being visible on screen.

### Root causes and fixes seen

1. **Orphan funding records hold the application at Signed Off.** MHD-36609, application 10003084267. Fix: run the data fix stored procedure to delete the funding records. Same class as MHD-35863.
2. **NULL application bank reference.** MHD-36658, application 10002815000: bank details were listed on screen but `applicationbankid` was NULL, producing a "No Bank Account" error on refund funding. Fix: populate the missing reference. Run under MHD-36184 (September data fix).
3. **Missing Equifax score on a funded application.** MHD-34765, application 10003014669. The standing fix is to insert the score by data fix. This recurs constantly: MHD-36712, MHD-36559, MHD-36129, MHD-36041, MHD-35896, MHD-35709, MHD-35571, MHD-35497, MHD-35187, MHD-35155, MHD-35077, MHD-34362, MHD-34324, MHD-34285, MHD-34204, MHD-34091, MHD-33837, MHD-33781, MHD-33355. Nobody has raised a ticket asking **why** funded applications keep landing without a score.
4. **Broker portal stuck on "calculating your finance details".** MHD-35818, application 10003059392. `IsEditedVehicleDetails` was incorrectly set to 1 on a pre-approval application. Fixed by data fix. The ticket asked for a permanent fix to how the flag gets set and that was never delivered; the data fix closed it.
5. **Contract sending failed.** Clear the **Review - Contract Sending Failed** task and fix any contact error it names, see theme 2 and MHD-32267, MHD-35658.

**Precedents:** MHD-36609, MHD-36658, MHD-36412, MHD-36393, MHD-35863, MHD-34489, MHD-33741, MHD-33742, MHD-31677, MHD-34765, MHD-35818, MHD-36600, MHD-35970, MHD-30935, MHD-36797.

---

## 10. Refunds and reversals

**Volume:** 18 Problems, 74 project-wide. Mostly executed as data fixes.

### Symptoms and fixes

- **"Perform datafix for reverse write-off"** is a standing request type, raised from Slack and executed directly. MHD-35969 and MHD-36077 are consecutive examples, both under MHD-35277. Turnaround on MHD-35969 was under two days.
- **Refund drove the account into overdue.** MHD-35159, CRD account 10002918836: two payments of $458.13 on 28 and 29 June, one refunded, account went into arrears. The fix was a code release on 12/08/2026 rather than a data fix.
- **Duplicate refund transaction.** MHD-33294, account 10001320825, reversed.
- **Bankruptcy write-off reversal.** MHD-32859, account 10002429438.
- **Excess balance after full repayment.** MHD-28340, account 10001336079, and MHD-34021, transaction 10002640675.
- **Zepto batch refunds.** MHD-28907.

**Precedents:** MHD-35969, MHD-36077, MHD-32161, MHD-32859, MHD-35159, MHD-33294, MHD-32196, MHD-28340, MHD-34021, MHD-28907, MHD-36280, MHD-34822, MHD-35966, MHD-36617.

---

## 11. Broker and partner

**Volume:** 110 Problems.

### Symptoms and fixes

- **Loan agreement not sent to the broker.** MHD-32267, application 10002867333, MME PL Broker, email template 2146, funded 24/04/2026 16:57 and the agreement should have gone the same day. Root cause was an uncleared **Review - Contract Sending Failed** task.
- **Missing settlement emails to broker and customer.** MHD-35193, MHD-33293.
- **Duplicate settlement emails to an external dealer.** MHD-36668, see theme 2 and open threads.
- **Broker applications on an inactive login.** MHD-36263, resolved by moving the applications to the active login.
- **Broker uploaded incorrect documents to a customer file.** A recurring scheduled clean-up, raised as `[APY] [UP TO <date>] Broker uploaded incorrect documents on customers file`: MHD-36154, MHD-35691, MHD-35112.
- **Application transfer between brokers.** MHD-35200.
- **Lead source and dealership updates.** MHD-35305, MHD-36653, MHD-36686.
- **Lead source syncing for new broker accreditations.** MHD-27683, WORK IN PROGRESS since 24/10/2025, nearly a year.

---

## 12. Trust and SPV migration

**Nothing usable was found under this heading.** `text ~ "trust migration"` returns zero MHD issues in the window, and the MoneyMe versus Spv12 distinction referenced in the harvest brief does not appear in the text of MHD-36446, which is the ticket it was associated with. MHD-36446's actual root cause is the AMZ-7074 amortisation defect documented at theme 5c, not a trust migration.

The only SPV-adjacent ticket found is **MHD-36622**, `[SPV - Horizon2 DB] Release for G1-2762 - Fix Treasury team SPV Admin permission grouping (SpvAdmin grant)`, High, Pending since 15/09/2026. That is a permissions change, not a migration.

If a trust or SPV migration workstream exists it is not discoverable from MHD text search and would need to be located by another route.

---

## 13. Cross-cutting rules worth memorising

These came up repeatedly across themes and are the kind of thing that saves an hour of investigation.

| Rule | Source |
| --- | --- |
| A proposed payment not processed within **3 working days** is rejected as "Payment not actioned". | MHD-36283, MHD-34734 |
| On an **overdue-stage** account only **retry** transactions can be auto-cancelled. Ad hoc payments cannot. | MHD-36283 |
| Payments always allocate to the **oldest outstanding amount first**. | MHD-35381 |
| An **OD fee is charged every 14 days** while an account sits in Overdue, regardless of payments. A **DH fee** is charged only when a payment rejects. | MHD-36206 |
| **Overdue + Rejected payment = no stage move** to Fund Sent. | MHD-32117, MHD-34734 |
| Check arrears on the **Scheduled and Due summary**, not the amortisation screen. | MHD-36790 |
| The Application Comms list view **caps at 21 rows**. Click Load More. | MHD-36668 |
| **Cancelled transactions do not display** in the Horizon transaction grid. | MHD-36618 |
| Contact records are **per brand**. Update all of them. | MHD-36009 |
| Three decimal places on a Split Sched amount means a **recreated amortisation**. | MHD-36446 |
| `PaymentRef` format is `<applicationId>-<transactionId>`. | MHD-35514, MHD-36618 |
| Freestyle is being discontinued. Freestyle-only defects will generally **not** be fixed; use manual scheduling or Payment upload. | MHD-35019, MHD-36071, MHD-36270 |
| Search `Amortization`, not `amortisation`. The system uses US spelling. | This harvest |
