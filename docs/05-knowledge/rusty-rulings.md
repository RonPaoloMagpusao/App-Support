# Rusty's rulings

Product rulings and explanations from Joshua (Rusty) Allen, Product Owner for Prod Support, COL, AMZ and CRD: what is a defect, what is working as designed, and why.

Last reviewed: 23 September 2026
Sources: Slack `#app-support`, `#solutions_memorandum`, `#autopay_feedback` and related channels, 2025-09 to 2026-09; Jira MHD tickets citing his decisions

Harvested from Slack for the App Support internal knowledge repo. Private repo.
Customer names, customer emails, phone numbers and addresses have been stripped.
Horizon application, transaction and task IDs are kept as worked examples.

Harvest date: 2026-09-23. Window searched: 2025-09-01 to 2026-09-23.

---

## 1. Who Rusty is

| Field | Value |
| --- | --- |
| Display name in Slack | **Rusty** |
| Real name | **Joshua Allen** |
| Slack user ID | `UT2FPML2E` (username `jallen`) |
| Title | **Product Owner, Prod Support, COL, AMZ, CRD** |
| Email | joshua.allen@moneyme.com.au |
| Timezone | Australia/Canberra |
| Org | MoneyMe Financial Group |

**What that means in practice.** Rusty is the Product Owner over Production
Support, Collections (COL), Autopay (AMZ) and the Credit Card product (CRD).
He is the person who decides whether a reported behaviour is a defect or
working as designed, and his calls get quoted straight into MHD and CL
tickets. He posts the authoritative operational announcements to
`#solutions_memorandum` (the Ops announcement channel), and he is active in
`#app-support`, `#app-support-crd`, `#crd_firefighters`,
`#horizon-collections-team` and `#collections-payments-daily-support-team`.

He is not the Horizon backend owner and does not claim to be. He repeatedly
routes deep Horizon/transaction questions to Christopher "Tops" Enriquez,
Harvey Dacutanan, Albert Rick Martires and the CRD team, and card-network
questions to Murdo. See the ownership map in [05-knowledge/tribal-knowledge.md](tribal-knowledge.md).

Two of his own working principles, quoted:

> "Our first step should always just be 'Does this make sense?' And then apply
> a payment setting."
> 2026-05-06, `#app-support`,
> https://moneymefinance.slack.com/archives/GG7HL6CTE/p1778025076901269

> "I prefer to check thoroughly before involving them, especially since so many
> of those are agent error or expected behaviour."
> 2026-08-04, DM with Ron. On when to escalate to Tops.

---

## 2. Payments: cancellation of scheduled payments when a customer pays early

### 2.1 CRD does NOT follow the normal custom/partial payment rules

**Rule.** On CRD (credit card), the standard custom/partial payment
cancellation rules do not apply. Instead: when the bill is satisfied, the
scheduled MMP (minimum monthly payment) direct debit should be cancelled
automatically. If it is not cancelled, that is a defect.

- Date: **2026-05-28**
- Channel: `#app-support`
- Quote:
  > "The normal custom/partial rules don't apply to CRD.
  >
  > When the bill is satisfied, the scheduled MMP should be cancelled.
  > Will raise this to the CRD team."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1779953350581449
- Jira: **MHD-33265** (Rusty raised it onward the same day in
  `#crd_firefighters`:
  https://moneymefinance.slack.com/archives/C0AFPUZPCEP/p1779953462083359)
- Worked example in that thread: transaction page 10002813976.
- Follow-on ruling in the same thread: when the DD is due next day and the bill
  is already satisfied, agents may cancel it manually. Rusty:
  > "Yeah mate, please cancel!"

**Companion note (non-CRD).** Michael Dela Torre's standing check in the same
thread: for non-CRD the cancellation is real but not instant, and the reference
is the Confluence page *Ad hoc payment - Web ECA Payment Portal*
(`.../wiki/spaces/FS/pages/1742962798/`):
> "Because usually it cancels but not instantly after the customer pays."

### 2.2 The non-CRD custom/partial rule, stated

**Rule.** Under the existing/old rules an adhoc self-service payment should
cancel an "upcoming" Direct Credit dated in the future, dated today, **or up to
3 business days in the past**.

- Date: **2026-08-13**
- Channel: `#horizon-collections-team`
- Quote:
  > "Under the existing/old rules an adhoc self service payment should cancel
  > and 'upcoming' Direct credit on a future date, today's date, or up to 3
  > business days in the past."
- Permalink: https://moneymefinance.slack.com/archives/C03K89BMFAL/p1786582835741969
- Worked example: transaction page 10001272416, txn 109265264 (Split Live,
  created 12/08/2026 08:39) should have cancelled txn 108410996 (Direct Credit).
- **Important epilogue (2026-08-13, same thread):** Rusty verified the rule was
  in fact working in the vast majority of cases and that the two Ops reports
  that day were invalid examples:
  > "Actually Ops raised 2 invalid examples by coincidence on the same day I
  > thought there might be an issue"
  Verified-good examples he listed: 10003031354, 10002965976, 10002895294,
  10002750980, 10002749746, 10002810327, 10002813134.
  Do not treat 2.2 as a live defect without reproducing it.

### 2.3 The rules are documented, do not relitigate them

- Date: **2026-09-09**
- Channel: `#app-support`
- Quote:
  > "this has always been the case, and the rules are well documented here:
  > https://moneyme1.atlassian.net/wiki/spaces/OP/pages/44630030/Partial+and+Custom+Payment+Rules"
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1788915074206799

### 2.4 Card payment racing the direct debit

**Explanation.** If a customer pays by card at the same moment Horizon submits
the DD to Split, the card payment cancels the DD locally but the DD has already
gone to Split, so it never updates to pending then cleared. The fix is a data
fix on the cancelled DD to "cleared".

- Date: **2026-02-25**
- Channel: `#unsaved-card-payments`
- Quote:
  > "The customer paid by card at 5:28am, the exact time we submitted the direct
  > debit to Split. The card payment cancelled the DD, but we had also already
  > sent the DD to Split, so it never updated to pending, then cleared. I will
  > arrange for the cancelled DD to be data fixed to cleared."

---

## 3. Payments: which payment methods can be scheduled

### 3.1 Automatic payments only work if they match the default payment method

**Rule.** You cannot schedule a Split Sched DD on a customer whose default
payment method is Debit Card Sched (and vice versa). If you need to schedule the
other method, you must also change the default to match.

- Date: **2026-08-12** (original), restated **2026-08-21**
- Channel: `#solutions_memorandum`
- Quote (2026-08-12):
  > "Automatic payments only work if they match the default payment method.
  > So for example we can't schedule a Split Sched DD if the customer normally
  > pays by Debit Card Sched. We will be making updates to this, but currently
  > there is no ETA."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1786485720659689
- Restatement (2026-08-21):
  > "As per this post, we need to also change the default to match. If they are
  > on Debit Card as the default, we aren't able to just schedule Split payments."
  https://moneymefinance.slack.com/archives/CFY7LHEJW/p1787279238976839
- Live example he called out (2026-08-21): transaction page 10002828260,
  > "This customer is on Debit card payments and you have setup Split, which
  > won't work. Also, why didn't you use the PP option?"
  https://moneymefinance.slack.com/archives/CFY7LHEJW/p1787277611955779

### 3.2 Auto Stripe / Debit Card Sched is not CRD-only

**Ruling.** Debit Card Sched as a default payment method works outside CRD and
should be supported across all products.

- Date: **2026-08-26**
- Channel: `#horizon-collections-team`
- Quote:
  > "We do have one non-CRD app with Debit Card Sched as the default payment
  > method (And it works) Tran Id's 109171848 109194954 ...
  > Although auto Stripe was built for CRD, it can and should work across all
  > products."
- Worked example: transaction page 10000648562.

### 3.3 Horizon will not submit a DD when the balance is $0

**Rule.** When a CRD customer has a $0 balance and a payout figure is generated
to capture unbilled interest, Horizon will **not** submit a DD to Split/Zepto.
The customer must pay that amount manually. Tell them up front.

- Date: **2026-09-08**
- Channel: `#solutions_memorandum`
- Quote:
  > "If a CRD customer has a $0 balance, and we generate a payout figure to
  > capture unbilled interest and close their account, the customer must pay
  > this amount manually.
  >
  > Horizon will not submit a DD to Split/Zepto when the balance is $0.
  >
  > Please ensure you advise customers of this to prevent unnecessary delays in
  > closing their account."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1788837232238049

---

## 4. Payments: timings and clearing

### 4.1 Split Sched takes 2 business days, and bill satisfaction must allow for it

- Date: **2026-07-22**
- Channel: `#app-support-crd`
- Quote:
  > "Yes, the system only gets the cleared date, and if that was a direct debit
  > (Split Sched) it should still count.
  >
  > Those take 2 business days, sp we need to account for that in our bill
  > satisfaction logic."
- Permalink: https://moneymefinance.slack.com/archives/C0ANUL7JYR3/p1784712035908539

### 4.2 CRD cashback grace period (internal only, do not tell customers)

- Date: **2026-05-28**
- Channel: `#solutions_memorandum`
- Quote:
  > "Small CRD FYI, please do not advise customers of this
  >
  > If a customer misses their minimum payment on CRD, but clears it soon after,
  > we may still apply their cashback credit.
  > This is due to the grace period we allow for Direct Debit payments to clear.
  >
  > In particular, this is likely to be the case for customers using an instant
  > payment method such as Debit Card Sched that clear their catch up payment
  > within 2 business days after the MMP due date."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1779939101738209
- Related: over Easter 2026 the grace period was temporarily extended to 7 days
  (2026-04-22, `#crd_firefighters`), which caused forgiven interest and cashback
  not to be applied to some customers and needed a data fix.

### 4.3 Split Sched processing window moved from after 5:30pm to 8am

- Date: **2026-08-26**
- Channel: `#solutions_memorandum`
- Quote:
  > "We have updated a setting that was previously delaying Split Sched and
  > forcing them to process quite late in the day, after 5:30pm.
  > We have now updated this so they will process as early as 8am."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1787714314326749

### 4.4 Zepto response timing

- Date: **2026-08-14**, `#app-support`
- Quote:
  > "Zepto is showing a delay for some reason. The next response is showing 3:30
  > this morning, where it is normally 5:30pm on the due date. So I would expect
  > it should just come out today, and is something outside of our control."
- Take-away: the **normal** Zepto next-response time is 5:30pm on the due date.

### 4.5 CRD payment allocations run overnight off an E6 daily report

- Date: **2026-05-22**
- Channel: `#app-support`
- Quote:
  > "Payment allocations are processed overnight for CRD.
  >
  > We get the allocation data in a daily report from E6."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1779421100378119

---

## 5. Payments: funds sent to a non-existent bank account (NPP / EFT fallback)

This is the single best mechanism explanation Rusty has given, and he
explicitly invited it to be documented.

- Date: **2026-08-24**
- Channel: DM with Ron
- Quote (verbatim, lightly trimmed):
  > "OK, are you ready for this explanation?
  > Please feel free to have your AI document this, and cross check previous
  > examples.
  >
  > In this case, it is likely that the funds will bounce back.
  > It takes up to 3-5 business days to occur.
  >
  > The reason it would bounce is because the bank details don't exist.
  > Horizon does have a process to automatically credit this amount back to the
  > account, but I'm not sure if that is active for CRD. It definitely worked
  > for Freestyle (Though, it might have just raised a task for an agent to
  > manually fix)
  >
  > The reason I know it is likely to bounce back:
  > We send funds via NPP, which is received virtually instantly.
  > NPP works via API, and it only works if the account exists, of course.
  > IF there is some issue with the NPP transfer, we have set Zepto to fall back
  > to old school EFT, which takes up to 2 business days to be received.
  > The reason for this is to cover us in the case of some NPP system outage.
  > But, since we still send the money, we need to wait the 1-2 business days for
  > funds to be received by the other bank, then 1-2 business days for them to
  > return it to us if the bank account doesn't exist.
  >
  > IF the bank details did exist, then it would be received instantly into
  > someone else's account. If that did happen, we could only ask the recipient
  > nicely to send the funds back, and hope we could get it back for the
  > customer. We couldn't force them to return the finds in this case."
- Permalink (DM): https://moneymefinance.slack.com/archives/D069K9EBEDA/p1787543128508539

---

## 6. "Disable Payment Submission" after a rejected payment

This is Rusty's own written spec of intended versus actual behaviour. He called
it his best explanation of the issue.

- Date: **2026-03-17**
- Channel: `#horizon-collections-team`
- Quote (verbatim):
  > "Intention:
  > We submit a payment to Zepto, and get a response with one of the listed
  > reasons, account closed being the main scenario.
  > We then prevent future submission, and instead immediately reject the
  > transaction.
  > To reset and allow future submission, we must change bank account, which
  > creates a 'Split Create/Update account' task and sets 'Disable Payment
  > Submission' to false (or equivalent.
  >
  > Problem:
  >
  > Customer contacts us soon after submission, before we get the response from
  > Zepto. They advise us of the new account, because they know the payment will
  > be rejected due to the closed account. Split Create/Update Account task is
  > raised. Later, the payment is rejected, and the NEW account is set to
  > 'Disable Payment Submission'
  >
  > We need to cater to this scenario, as it causes a lot of confusion for agents
  > and customers.
  >
  > WHEN a payment is rejected for a relevant reason, IF the Split account was
  > already updated, THEN do not disable submission on the new account."
- Permalink: https://moneymefinance.slack.com/archives/C03K89BMFAL/p1773740710282299
- Related (2026-09-15, `#collections-payments-daily-support-team`): Rusty asked
  for a list of all CRD with `DisablePaymentSubmission = true` because
  > "these payments should be rejecting (But are not rejecting automatically)".

---

## 7. Fees: working as designed versus defect

### 7.1 Overdue fee versus dishonour fee

**Ruling.** These are two different fees with two different triggers. If an
account is in overdue stage it gets the overdue fee, full stop.

- Date: **2026-09-01**
- Channel: `#app-support`
- Quote:
  > "It's because they have been in overdue stage since Feb with Arrears
  > Balance: 1,153.85
  >
  > Documentation is here, but the summary is: if they're overdue, they get the
  > overdue fee.
  > https://moneyme1.atlassian.net/wiki/spaces/OP/pages/121831888/Overdue+Fee+Structures
  >
  > DH fee is charged when a payment rejects.
  > OD fee is charged every 14 days when an account is in overdue stage,
  > regardless of whether they are clearing payments."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1788241027264449
- And immediately after, on whether to waive:
  > "No, I wouldn't waive them.
  >
  > It's working exactly as expected/intended."
  https://moneymefinance.slack.com/archives/GG7HL6CTE/p1788241327235919 (thread)

### 7.2 CRD retries do not attract dishonour fees

- Date: **2026-07-21**
- Channel: `#solutions_memorandum`
- Quote:
  > "We now have retry for Debit Card Sched!
  >
  > A few things to note:
  > - We do not add dishonour fees to retries or arrears for CRD. The retry
  >   amount should be the same as the original payment.
  > - Retries are on a different cycle for 'instant' payment methods. I have
  >   attached an outline of the current timings, including examples."
- Reference doc: Confluence *Debit Card Repayments Automatic Retires*,
  https://moneyme1.atlassian.net/wiki/spaces/OP/pages/3033497726/
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1784621163279889

### 7.3 Doubled-up payments

- Date: **2026-09-01**, `#app-support`
- Quote:
  > "Yes, and obviously refund one of the payments if they both clear, otherwise
  > disable DH fees, retry, stage movement etc."

### 7.4 Waiving: waive the remaining balance, not more

- Date: **2026-07-02**, `#app-support`
- Quote:
  > "Ahhh, you waived too much, right?
  > Should have just waived the remaining balance.
  > Those interest entries you've created to try and fix it aren't real.
  > We can safely close the account, cancel the refund task, and walk away from
  > this one."
- Also (2026-09-15, `#app-support`): "You can just waive the $20 directly from
  interest."

---

## 8. CRD product behaviour

### 8.1 Do not manually move a credit card account to Repaid

Posted with `@channel`.

- Date: **2026-09-04**
- Channel: `#solutions_memorandum`
- Quote:
  > "important reminder for anyone working on credit card accounts:
  >
  > Do not manually move the stage to Repaid.
  > If the account is not closed using the payout process, it is not actually
  > closed."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1788491520348599

### 8.2 Annual fees and "Interest Free Expiry"

- Date: **2026-07-02**
- Channel: `#solutions_memorandum`
- Quote:
  > "Annual fees now charge at the end of the first statement for newly funded
  > accounts, not the day the account is funded.
  >
  > 'Interest Free Expiry' is us moving the old Freestyle purchases FROM an
  > interest free 'bucket' TO an interest bearing bucket.
  > The actual interest will show up in MoneyOut on the day we issue a statement.
  > This is the only day interest will ever show on CRD.
  > Think of it like a reallocation, it is not a duplicate charge."
- Permalink: https://moneymefinance.slack.com/archives/CFY7LHEJW/p1782966361852179
- Restated 2026-07-07 in `#crd_firefighters`: "Yeah, it's the equivalent of a
  reallocation."

### 8.3 E6 is the source of truth, and Horizon cannot "fix" E6 data

- Date: **2026-07-02**, DM with Ron
- Quote:
  > "FYI if you remove this, it will still exist in E6, so it won't actually be
  > fixed. CRD is different because of the external integration.
  > Those transactions from before were different because we created them in
  > Horizon, and never synced with E6.
  > Everything in the Credit Card tab exists in E6 so can't just be fixed on our
  > side."
- Date: **2026-08-24**, DM with Ron
- Quote:
  > "The other real question is, why is Horizon using it's own calculation when
  > we decided E6 is the 'Source of truth'"
- **Rule of thumb for App Support:** anything shown on the Credit Card tab lives
  in E6. A Horizon-side data fix will not fix it. Escalate to the CRD team.

### 8.4 Clear-arrears payment plans on CRD

- Date: **2026-06-10**
- Channel: `#crd_firefighters`
- Quote:
  > "Customer paid the first payment as part of their clear arrears PP, and the
  > stage has immediately moved to Fund Sent.
  > This stage movement should only occur once the arrears = 0
  >
  > If a customer pays the overdue bill, it's not cancelling the payment plan.
  > Once the arrears = 0, the clear arrears PP should be cancelled automatically."
- Worked examples: bill 10002954179.
- Both statements are **specifications of intended behaviour**, so a deviation
  is a defect.

### 8.5 Arrears reset on CRD is a hardship mechanism

- Date: **2026-06-09**
- Channel: `#app-support-crd`
- Quote:
  > "The Hardship process includes a function that marks all previous bills as
  > inactive to reset the arrears. Is it possible to create a manual trigger for
  > this bill deactivation process, please?"
  and
  > "Any workaround or new process should simply replicate the hardship process
  > of resetting arrears. ... Ideally, we could trigger the same action without
  > moving the stage through Hardship."
- Related pointer (2026-07-08, DM with Ron) on which fields an arrears reset
  touches:
  > "I believe it's updating:
  > `application.ArrearsLevelId`
  > `application.ArrearsStandingId`"
  and "I think ArrearsStandingId will be 4, and should be set to 0".
  He flagged this as not certain: "You may need to ask Gil or Harvey or someone
  senior like that."

---

## 9. LOC / Freestyle: repayments design

**Ruling.** LOC repayment amounts drifting upward is a known design limitation,
not a per-account defect. Shuffling does not change the amount. Apply a payment
setting instead.

- Date: **2026-05-06**
- Channel: `#app-support`
- Quote:
  > "We (Gelo) know that LOC payments are cooked. This is a huge part of why we
  > built a new product.
  >
  > If we need repayments to stay the same, we just need to use a payment
  > setting.
  >
  > They can increase massively if a customer has fallen behind by a lot, or even
  > if they just use the account a lot over a long period.
  >
  > The design just was not effective over a long period of time.
  >
  > Our first step should always just be 'Does this make sense?' And then apply a
  > payment setting.
  >
  > Shuffling an LOC does nothing for the amount."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1778025076901269

---

## 10. Shuffling and schedules

### 10.1 Shuffling twice in quick succession duplicates loaded transactions

- Date: **2026-09-01**, `#app-support`
- Quote:
  > "It's caused by shuffling twice in quick succession, so both shuffles have
  > triggered the transactions to load. Just very unlucky timing. Either
  > shuffling faster or slower would avoid this.
  >
  > It's very rare, so the fix is low priority for now."

### 10.2 Shuffling on the same day as funding misses the Dealer/Broker Fee

- Date: **2026-09-14**, `#app-support`
- Quote:
  > "Actually I figured it out. It was shuffled the same day it was funded,
  > before the Dealer/Broker Fee was charged, so that $990.00 was not included in
  > the schedule."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1789343840057809
- Follow-up: 84 apps in the same state, bulk shuffle ticket **AMZ-10685**
  (2026-09-15).

---

## 11. Escalation and priority, in Rusty's words

### 11.1 Direct debit issues are always urgent

- Date: **2026-07-01**
- Channel: `#app-support`
- Quote:
  > "There are 412 not submitted yesterday.
  >
  > Ron Have you escalated?
  > Direct debit issues are always urgent. (Though Tops is out, and Harvey is on
  > EOM cashflow reports)"
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1782869919552699

### 11.2 Check the obvious thing before raising an issue

- Date: **2026-05-26**
- Channel: `#app-support`
- Quote:
  > "The DD outcome we have gotten both times we have tried is
  > `incorrect_account_number`. This is the response Zepto/Split is getting from
  > the customers bank and passing to us.
  >
  > When I check the MB, the account number is just wrong.
  > This should be the first thing we check before raising this as an issue."
- Permalink: https://moneymefinance.slack.com/archives/GG7HL6CTE/p1779763272992589
  ("MB" = bank statement / MoneyBrain statement data for the application.)

### 11.3 Template changes must follow the process

- Date: **2025-10-29**
- Channel: `#comms-fixing`
- Quote:
  > "I have just now updated template 341 (MME 1014 - Confirmation of Change of
  > Direct Debit Details) in prod.
  >
  > An entirely different MOM template had been put in it's place, leading to
  > multiple Ops tickets being raised.
  >
  > I have raised a ticket here so we can 'Follow the process' and also please
  > investigate internally how/why this occurred, and try to avoid this happening
  > in future. https://moneyme1.atlassian.net/browse/FE-5360"

### 11.4 Unblocking a stuck Split task

- Date: **2025-09-18**
- Channel: `#app-support`
- Quote:
  > "This task [Error Split Create/Update Account] prevents transactions loading,
  > since we don't have a valid Split account to DD. I have cleared the task now.
  >
  > cc Simon please have your team start working this queue, or figure out who is
  > responsible for this. I'll also escalate this matter to Greg now."
- Worked example: task 10002547581.

---

## 12. Things Rusty explicitly called not a defect

Moved to [working-as-designed.md](working-as-designed.md#rulings-by-rusty). Incidents he declared are in [incident-log.md](incident-log.md).

## 13. Attribution caveats

- Everything in sections 2 to 13 above is attributed to Rusty (Joshua Allen)
  with a date and channel. Where the quote comes from a DM or group DM, that is
  marked.
- The 2026-03-31 "working exactly as designed and intended" quote is real but
  its subject was not recovered. **Do not** attach it to a specific behaviour.
- Section 2.2 is Rusty's statement of the rule, but he later verified the rule
  was working and that the reports that prompted it were invalid. Treat the rule
  as authoritative and the defect claim as withdrawn.
- The arrears field names in section 8.5 (`ArrearsLevelId`, `ArrearsStandingId`)
  were given by Rusty with an explicit hedge; confirm with Tops or Harvey before
  writing a data fix against them.
