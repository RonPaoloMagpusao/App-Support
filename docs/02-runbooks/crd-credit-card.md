# CRD credit card

The credit card product: what lives in E6, how its payments and arrears differ from PL, migrations, cards, and the standing instructions currently in force.

Last reviewed: 23 September 2026
Sources: Rusty's rulings (Slack) sections 2.1, 3.3, 4, 8, 11, tribal knowledge (Slack) sections 1 to 5, 9, team procedures (Slack) sections 5.2, 8.1, Confluence 3131015188 sections 01, 05, 10, MHD issue catalogue themes 6, 10

**Read this first.** Anything shown on the Credit Card tab lives in **E6**, the card issuing
platform, not Horizon. Rusty, DM with Ron, 2026-07-02: *"FYI if you remove this, it will still
exist in E6, so it won't actually be fixed. CRD is different because of the external integration.
... Everything in the Credit Card tab exists in E6 so can't just be fixed on our side."* A Horizon
datafix will not fix it. `ProductId = 111` is CRD and is NULL for everything else; use
`ProductTypeId` for other products (Rusty, 2026-09-22).

## Symptoms

- "Something on the Credit Card tab is wrong"
- "Interest appeared out of nowhere" / "Interest Free Expiry looks like a duplicate charge"
- "Annual fee charged on the wrong day"
- "The scheduled MMP was not cancelled after the customer paid the bill"
- "The stage moved to Fund Sent after the first clear-arrears payment"
- "Reset arrears on CRD" / "reset arrears by marking overdue bill as inactive"
- "Customer wants their account closed" / "Moved to Repaid but still open"
- "Payout figure generated but no direct debit went out"
- "Cashback not applied" / "reward credit wrong"
- "Customer wants a refund on their CRD account"
- "Android Virtual Card provisioning failure"
- "An error occurred retrieving card details"
- "No option to apply CRD" / "Credit Limit Increase option not visible"
- "Customer without a credit card is being prompted about one on login"
- "Split Create/Update Account tasks keep regenerating on CRD accounts"
- "Freestyle customer's migration to CRD was skipped"
- "Horizon CRD tab needs several refreshes to populate"
- "Statement has not been sent yet"

## Triage, in order

1. **Is it E6 data?** If it is on the Credit Card tab, escalate to the CRD team; do not datafix it
   in Horizon. A Horizon-side deletion of a CRD transaction does not fix it, because the record still
   exists in E6 (Rusty, 2026-07-02).
2. **Check the standing instructions in force as at 2026-09-23:**
   - **Refunds: do not process, escalate.** Released to Horizon 2026-09-17, frozen while the backlog
     is cleaned up (Rusty, `#solutions_memorandum`, 2026-09-17). Refunds cannot be processed for
     closed accounts at all (Rusty, 2026-06-04).
   - **SOA: do not use SOA generation.** Use only the monthly statements attached to files (Raina
     Schmidt, `#solutions_memorandum`, 2026-08-13).
   - **Do not manually move the stage to Repaid.** *"If the account is not closed using the payout
     process, it is not actually closed"* (Rusty, `#solutions_memorandum`, 2026-09-04, posted with
     `@channel`).
3. **Check the date against the statement cycle.** CRD statements issue monthly and interest only
   ever appears in MoneyOut on the day a statement is issued (Rusty, 2026-07-02). Payment
   allocations process overnight, off a daily report from E6 (Rusty, 2026-05-22). A report made the
   morning after a payment may simply be before the allocation ran.
4. **Check for a known E6 incident.** 10 to 11 September 2026: statements issued showing no rewards
   and payment allocations not processed overnight, "only delays, and display issues" (Rusty,
   2026-09-11). 1 June 2026: all CRD customers received an incorrect reward credit (Rusty,
   2026-06-04).
5. **For a scheduled MMP not cancelled, apply the CRD rule, not the custom and partial rules.** When
   the bill is satisfied, the scheduled MMP should be cancelled. If it is not, that is a defect
   (Rusty, `#app-support`, 2026-05-28). Split Sched takes 2 business days to clear and bill
   satisfaction must allow for it (Rusty, `#app-support-crd`, 2026-07-22).
6. **For a migrated customer who cannot log in**, check whether an MME account row exists
   (MHD-35589). See [login-passcode-and-account-access.md](login-passcode-and-account-access.md).
7. **For a migrated account that will not debit**, check `DisablePaymentSubmission` carried over
   from the original CCC application (MHD-34668).

## Root causes seen

1. **Scheduled MMP not cancelled on bill satisfaction.** MHD-33265, application 10002813976. CRD did
   not apply the rule. Permanent fix CRD-2459, shipped in release MHD-33404 (which also carried
   CRD-2308 cashback clawback, CRD-2074 configurable Apple credit, CRD-2269 limit-change history,
   CRD-1783 minimum limit), release task RB-1558. Further related release MHD-35241. A recurrence of
   a previously fixed CRD issue was re-raised by Rusty on 2026-09-16 as MHD-36573, prior fix
   CRD-2422 (tribal knowledge (Slack) section 5).
2. **Clear-arrears payment plan behaving wrongly.** Rusty's specification, `#crd_firefighters`,
   2026-06-10: *"Customer paid the first payment as part of their clear arrears PP, and the stage has
   immediately moved to Fund Sent. This stage movement should only occur once the arrears = 0. If a
   customer pays the overdue bill, it's not cancelling the payment plan. Once the arrears = 0, the
   clear arrears PP should be cancelled automatically."* Worked example bill 10002954179. Both
   statements are specifications of intended behaviour, so a deviation is a defect.
3. **No E6 account created for a repeat customer**, so Android Virtual Card provisioning fails
   (MHD-35954).
4. **CCC to CRD migration carrying `DisablePaymentSubmission`.** A pre-migration "payment denied"
   event then blocks all future submissions (MHD-34668).
5. **Pending direct debit blocking the Freestyle or LOC to CRD migration.** On 2026-06-18, 22 of 50
   were skipped for a pending DD (Rusty, `#solutions_memorandum`). The batch runs weekly on Tuesdays,
   with migration emails sent ahead and a 21-day opt-out or opt-in on request.
6. **Refund driving the account into overdue.** Two payments of $458.13 on 28 and 29 June, one
   refunded (MHD-35159, CRD 10002918836). Fixed by a code release on 12/08/2026.
7. **PayAnyone stuck at Authorized** because a stale funding failed task is still open (MHD-35999).
   See [funding-and-disbursement.md](funding-and-disbursement.md).
8. **Migrated OzMoney CRD customer with no MME account** (MHD-35589, customer 664818).

## The fix

| Root cause | Action |
| --- | --- |
| Anything on the Credit Card tab | **Escalate** to the CRD team, `#crd_firefighters` or `#app-support-crd`. Card-network questions go to Murdo |
| MMP not cancelled, bill satisfied, DD due | **Config change**, the agent cancels it. Rusty: *"Yeah mate, please cancel!"* Then **escalate** the recurrence to the CRD team |
| Clear-arrears PP deviating from spec | **Escalate** to the CRD team as a defect |
| Arrears reset on CRD | **Escalate.** It is a hardship mechanism: *"The Hardship process includes a function that marks all previous bills as inactive to reset the arrears"* (Rusty, `#app-support-crd`, 2026-06-09). Rusty named `application.ArrearsLevelId` and `application.ArrearsStandingId` as the fields touched, hedged: *"I think ArrearsStandingId will be 4, and should be set to 0"* and *"You may need to ask Gil or Harvey or someone senior like that"*. Confirm with Tops or Harvey Dacutanan before any datafix |
| Customer wants to close | **No action** outside the payout process. Never move to Repaid manually |
| $0 balance payout figure | **No action.** Horizon will not submit a DD to Split or Zepto when the balance is $0. The customer must pay the amount manually. Tell them up front (Rusty, `#solutions_memorandum`, 2026-09-08) |
| Refund | **Escalate.** Frozen |
| Virtual Card provisioning | **Datafix plus a new application.** *"Update the customer number in E6 (append with X) and create a new application from scratch, which creates a new E6 account"* (MHD-35954) |
| `DisablePaymentSubmission` carried over | **Datafix**, set it to NULL and switch the default payment mode from Split Sched to Direct Credit (MHD-34668) |
| Migration skipped for a pending DD | **No action** beyond advising. Rusty: *"Please let these customers know they should not make any further direct debits, and please cancel/disable any retry or other DD that might be scheduled to prevent further delays."* |
| Migration reversed | **Datafix**, remove the `AdditionalData` rows with `AdditionalDataTypeId = 125`, the migration marker (Rusty, 2026-07-02) |
| Login prompt for a customer with no CRD | **Escalate** to `#app-support-mobile-team`, cc Aus, Paul, Stefan (MHD-34604, MMM-15339) |
| Missing Equifax score on migrated CRDs | **Datafix**, insert the score (MHD-33355) |

**Bulk Direct Credit upload noise.** When Rusty bulk-uploads Direct Credit transactions
(`TranType 1`), Horizon spawns interest and allocation transactions that must be removed:
`TransactionTypeId IN (18, 28, 32)`, the Daily Interest, Unallocated Interest and Allocated Interest
rows. Do not touch the Direct Credit row. **The source is internally inconsistent here.** The
recipe is headed "CRD junk transactions", but Rusty's own selector filters `app.ProductId <> 111`
and he says *"CRD just doesn't have the same interest adjustment and reallocation processes, so
should be none"* (tribal knowledge (Slack) 3.5, 2026-09-22). Unverified which accounts the noise
lands on; confirm scope with Rusty before running the selector. The selector as recorded also joins
to an alias it never defines, so it will not run as written.

## Not a defect

- **"Interest Free Expiry".** A reallocation from an interest-free bucket to an interest-bearing one,
  not a duplicate charge (Rusty, `#solutions_memorandum`, 2026-07-02).
- **Interest appearing only on statement day.** The only day interest will ever show on CRD.
- **Annual fee at the end of the first statement**, not the funding day, for newly funded accounts
  (changed around 2026-07-02).
- **No dishonour fee on retries or arrears.** The retry amount should equal the original payment
  (Rusty, 2026-07-21).
- **Cashback applied although the MMP was missed.** A grace period applies for DD clearing,
  roughly 2 business days after the MMP due date for instant methods such as Debit Card Sched,
  temporarily 7 days over Easter 2026. **Internal only, do not tell customers** (Rusty,
  `#solutions_memorandum`, 2026-05-28).
- **CRD scheduled MMP not cancelling under the custom and partial rules.** Those rules do not apply
  to CRD at all (Rusty, 2026-05-28). Failure to cancel **after bill satisfaction** is still a defect.
- **Debit Card Sched working on a non-CRD account.** Auto Stripe was built for CRD but *"can and
  should work across all products"* (Rusty, 2026-08-26).
- **The CRD auto refund running once per 24 hours** while its task raises more than once (James
  Wiles, 2026-08-27).

## Precedents

- MHD-33265, CRD-2459, MHD-33404, RB-1558, MHD-35241: MMP not cancelled after an advance payment.
- MHD-36573, CRD-2422: recurrence of a previously fixed CRD issue, LIDs 10002930479 and 10002931351.
- MHD-35954: Android Virtual Card provisioning failure.
- MHD-34668: CCC to CRD migration with `DisablePaymentSubmission` carried over.
- MHD-35159: refund drove CRD 10002918836 into overdue.
- MHD-35999: CRD PayAnyone stuck at Authorized.
- MHD-35589: migrated OzMoney CRD customer with no MME account.
- MHD-34604, MMM-15339: CRD login prompt on a PL-only customer.
- MHD-36616: seeded `FloatBankAccountId` for CRD-R so refunds could work.
- MHD-33355: Equifax scores for migrated CRDs.
- MHD-34601, MHD-33640, MHD-33641: CRD arrears resets.
- MHD-33603, MHD-33246, MHD-35161, MHD-34637, MHD-34374: payment plan migration, stage progression,
  scheduled payment query, card accessible in arrears, tab not populating. Root cause not verified.

## Open defects

- **MHD-35062**, Split Create/Update Account and Error Split Create/Update Account tasks keep being
  raised for CRD accounts on non-Split Sched repayment, although the method was never changed.
  Selected for Development since 27/07/2026, raised to Funding, no further movement. The risk is
  that accounts genuinely needing Split action get lost in the noise. Nine sample applications are
  on the ticket.
- **CRD with `DisablePaymentSubmission = true` not rejecting automatically.** Rusty requested a list
  on 2026-09-15 to quantify balance, arrears and stage impact. No ticket recorded.
- **API-6134**, remove the condition blocking CRD Pay Anyone funding events.
- **MHD-29029**, "An error occurred retrieving card details" despite troubleshooting, 10000755997,
  Selected for Development, 286 days.
- **MHD-30782**, "No option to apply CRD, 10002708306", Selected for Development, 208 days.
- **MHD-35582**, Credit Limit Increase option not visible, 10002859953, Selected for Development.
- **CL-215**, a CRD bug queued for backlog, "in ~3 months it will be a bigger priority", raised
  2026-06-24.
- **Horizon tabs not populating on CRD, needing several refreshes.** Raised May, followed up
  14 and 18 May, 3 and 20 July, escalated again by Raina on 2026-08-05. Suspected E6 data not loading
  or a timeout too short. Long-running, no ticket key beyond the closed MHD-34374.
- **No manual trigger for the CRD arrears reset** outside the Hardship stage (Rusty, 2026-06-09).
- **Luxury Escapes CRD funded email using generic template 201185 instead of branded 201265.**
  Raised 2026-08-19, no ticket key recorded.
- **Horizon using its own calculation although E6 is the source of truth.** Rusty, DM with Ron,
  2026-08-24: *"why is Horizon using it's own calculation when we decided E6 is the 'Source of
  truth'"*. No ticket recorded.
- **Refunds for closed accounts** cannot be processed, and the 01/06/2026 reward credit left some
  closed accounts with an incorrect excess balance. The reversal should have been capped at 1 per
  cent of the credit limit; some reversals were wrong and needed further fixing (Rusty,
  `#app-support-crd`, 2026-06-29).
