# Fees and charges

Overdue, dishonour, annual and establishment fees, interest rates, and waivers.

Last reviewed: 23 September 2026
Sources: Rusty's rulings (Slack) sections 7, 8.2, 13, MHD issue catalogue theme 7c, Confluence 3131015188 section 08, Confluence 1293647889, tribal knowledge (Slack) sections 4, 5

Most fee complaints are working as designed. Settle the stage and the allocation before you touch
anything. Rusty's rulings in full are in
[../05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md).

## Symptoms

- "Investigate incorrect $35 overdue fees" / "Repeated overdue fees despite payments"
- "Customer paid early and still got a $15 dishonour fee"
- "Customer was charged a dishonour fee on a retry" (CRD)
- "Overdue fee charged was $5.00 instead of $35.00"
- "Zero interest rate on ApplicationCharge for account <id>"
- "Update interest rate for account <id>" / "Approved at the wrong rate"
- "Incorrect payment amount after APR increase"
- "Sliding fee added to repayment"
- "Annual fee charged on the wrong day" (CRD)
- "Interest Free Expiry looks like a duplicate charge" (CRD)
- "Customer in hardship didn't get the monthly fee increase"
- "Broker commission / broker fee / establishment fee wrong"
- "We waived it and now the account looks wrong"
- "Can't waive fee interest via Cancel Money Out"

## Triage, in order

1. **For an overdue fee complaint, was the account in Overdue stage?** An OD fee is charged every
   14 days while an account is in Overdue stage, regardless of payments being made. A DH
   (dishonour) fee is separate and charged only when a payment rejects (Rusty, `#app-support`,
   2026-09-01; Overdue Fee Structures, Confluence 121831888). This ends most fee tickets.
2. **Check whether it was actually Overdue hold (65).** A payment for more than 80 per cent of the
   arrears balance moves an Overdue account to Overdue hold, which is not eligible for the Overdue
   Account Fee (Confluence 1293647889).
3. **For a dishonour fee after an early payment, work the allocation.** Payments go to the oldest
   outstanding amount first, so a customer in arrears who pays the current minimum still has the
   scheduled debit run and reject (MHD-35381).
4. **Is it CRD?** CRD does not add dishonour fees to retries or arrears; the retry amount should be
   the same as the original payment (Rusty, `#solutions_memorandum`, 2026-07-21). CRD interest only
   ever appears on statement issue day, and annual fees charge at the end of the first statement
   (Rusty, 2026-07-02). See [crd-credit-card.md](crd-credit-card.md).
5. **For a rate or charge problem, check `ApplicationCharge`** for a zero or missing rate
   (MHD-34728).
6. **For a hardship or DNC account missing the monthly fee increase, check the account's status as
   at February 2025.** Accounts in HS or DNC then were excluded (Rusty, `#app-support`, 2026-09-15).
7. **Before waiving, work out the remaining balance.** Waive that, not more (Rusty, `#app-support`,
   2026-07-02).

## Root causes seen

1. **Fees correctly charged in Overdue stage.** MHD-36206, application 10002399667: the account had
   been Overdue since February with arrears of $1,153.85.
2. **Early payment absorbed by arrears**, producing a $15 dishonour fee (MHD-35381, application
   10002937235).
3. **Rate failing to populate on the charge record.** A known recurring defect with an established
   workaround (MHD-34728, account 10002996207).
4. **Bad income data driving a risk-priced rate.** MHD-34449, account 10003003090, approved at
   19.35 per cent instead of 17.35 per cent because of an erroneous payslip load.
5. **Over-waiving.** Rusty, `#app-support`, 2026-07-02: *"Ahhh, you waived too much, right? Should
   have just waived the remaining balance. Those interest entries you've created to try and fix it
   aren't real. We can safely close the account, cancel the refund task, and walk away from this
   one."*
6. **Shuffling on the funding day.** Leaves the Dealer/Broker Fee out of the schedule, $990 in the
   worked example (Rusty, `#app-support`, 2026-09-14; AMZ-10685).

## The fix

| Root cause | Action |
| --- | --- |
| OD fee in Overdue stage | **No action.** Close with the reasoning. Rusty: *"No, I wouldn't waive them. It's working exactly as expected/intended."* |
| DH fee after early payment into arrears | **No action** as a rule. Waive only where the customer was given incorrect advice, as on MHD-35381 |
| Zero rate on `ApplicationCharge` | **Datafix**, apply the existing fix script, **then rerun the Funding Event**. The rerun is load-bearing; the datafix alone is not sufficient (Confluence 3131015188 section 08) |
| Wrong interest rate | **Escalate** to Rusty (Josh Allen). Not a plain UPDATE: the loan has to be shuffled in Horizon against the new APR so the schedule re-amortises |
| Over-waived | **No action** beyond closing the account and cancelling the refund task, per Rusty's ruling. To waive a small amount, *"You can just waive the $20 directly from interest"* (Rusty, 2026-09-15) |
| Dealer/Broker Fee missing after same-day shuffle | **Config change**, re-shuffle. Bulk case handled under AMZ-10685 |
| Broker commission, broker fee, establishment fee wrong | **Datafix**, raw script territory, parent page items 10, 23, 93, 96. See [broker-and-partner.md](broker-and-partner.md) for the item 96 backup bug |
| Doubled-up payments | Rusty, 2026-09-01: refund one if both clear, *"otherwise disable DH fees, retry, stage movement etc."* |

**The sources disagree on waiving OD fees, in one specific way.** Rusty's ruling is not to waive OD
fees correctly charged in Overdue stage (`#app-support`, 2026-09-01). On MHD-36206, the ticket that
prompted that ruling, **Jason McGuire approved waiving them anyway**, because the customer had been
Financial-Support at the time and would not have shown as overdue had a Courtesy Variation not
forced them ahead of schedule. Read it as: the fee is correct, and a waiver is a separate business
decision that needs Jason McGuire's approval, not App Support's.

## Not a defect

- **OD fees while the customer is clearing payments.** Every 14 days in Overdue stage, regardless
  (Rusty, 2026-09-01, MHD-36206).
- **A dishonour fee after an early payment on an account in arrears.** Allocation to the oldest
  amount first (MHD-35381). Tell customers with arrears they must cover arrears plus the current
  month's minimum, or call to have the debit cancelled.
- **No dishonour fee on a CRD retry.** By design (Rusty, 2026-07-21; Confluence 3033497726).
- **"Interest Free Expiry" on CRD.** Moving old Freestyle purchases from an interest-free bucket to an
  interest-bearing one. *"Think of it like a reallocation, it is not a duplicate charge"* (Rusty,
  `#solutions_memorandum`, 2026-07-02).
- **CRD annual fee at the end of the first statement**, not on the funding day, for newly funded
  accounts (Rusty, 2026-07-02).
- **Hardship or DNC accounts as at February 2025 not getting the monthly fee increase.** Deliberately
  excluded (Rusty, 2026-09-15).

## Precedents

- MHD-36206: repeated $35 OD fees on application 10002399667, correct, waived by Jason McGuire's
  approval.
- MHD-35381: $15 DH fee after an early payment was absorbed by arrears, waived for incorrect advice.
- MHD-34728: zero interest rate on `ApplicationCharge`, account 10002996207.
- MHD-34449: rate approved at 19.35 per cent instead of 17.35 per cent, account 10003003090.
- MHD-36006: incorrect payment amount after an APR increase, LID 10001520037. Root cause not verified.
- MHD-34602: DPD repayment amount discrepancies following rate changes. Root cause not verified.
- AMZ-10685: 84 applications shuffled on funding day, Dealer/Broker Fee missing.

## Open defects

- **MHD-33684**, overdue fee charged as $5.00 instead of $35.00. Raised 2026-06-17.
- **MHD-32268**, "Sliding fee added to repayment due 27/04, 10002526736", Selected for Development,
  149 days as at harvest.
- **MHD-30596**, "Discrepancy in charge cancellation options for PL versus Freestyle", Selected for
  Development, 215 days.
- **Fee interest cannot be waived via Cancel Money Out**, related to CL-516 (Rusty, 2026-09-21).
- **The zero-rate `ApplicationCharge` defect is datafixed each time rather than permanently fixed.**
  No ticket against the cause (Confluence 3131015188, known gaps).
- **CL-628**, negative "Outstanding charges" where `PaidChargeAmount` exceeds `TotalChargeAmount`.
  See [soa-generation.md](soa-generation.md).
- **Should dishonour fees be suppressed on Zepto late dishonour reversals?** Raised by Michael Dela
  Torre on MHD-36494, never answered. See
  [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md).
