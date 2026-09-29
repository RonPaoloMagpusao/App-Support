# Refunds and reversals

Refunds that will not send, write-offs that need reversing, and transactions that need cancelling or reversing.

Last reviewed: 23 September 2026
Sources: team procedures (Slack) section 5, Confluence 2385150262, Confluence 3131015188 section 03, Confluence 3117842457 Part 2 and 2b, MHD issue catalogue theme 10, Rusty's rulings (Slack) sections 7.3, 11.3, 11.6, tribal knowledge (Slack) sections 3.2, 3.5

Intake is `#refund-supports` and `#app-support`. Late dishonour batch reversals are in
[direct-debit-and-dishonour.md](direct-debit-and-dishonour.md).

## Symptoms

- Bot post in `#refund-supports`: "*Stuck refund for 30 mins:* {N}"
- "System - Refund Loan task has been open for ages and the overpayment task is still open"
- "Two refund transactions were created from one click"
- "Fix Review - Refund Funding Error 'No Bank Account'"
- "Refund was processed although a balance is still owing"
- "Can't reallocate a small amount from establishment fee to excess"
- "Customer has an excess balance after full repayment"
- "Refund caused the account to go into overdue"
- "Perform datafix for reverse write-off"
- "Reverse bankruptcy write-off transaction"
- "Reverse duplicate refund transaction"
- "Direct debit taken in error" / "payment needs reversing" / "double payment"
- "Cancel the pending Pay Anyone transactions"
- "Reverse payments and remove from SOA"
- CRD: "Customer wants a refund on their closed credit card account"

## Triage, in order

1. **Is it CRD? Stop.** Standing instruction as at 2026-09-23, Rusty, `#solutions_memorandum`,
   2026-09-17: *"Refunds for CRD have been released to Horizon overnight. Please do not process any
   refunds at this stage, and continue to escalate for now."* And since 2026-06-04, refunds cannot
   be processed for closed accounts; if a large refund is expected or the customer specifically
   asks, escalate and an exception can be made.
2. **Understand the chain before you fix a stuck refund.** James Wiles, 2026-02-19
   (team procedures (Slack) 5.3):
   1. The account has an excess balance.
   2. The agent reallocates credit to excess if needed, then processes the refund on the
      Transactions page.
   3. The excess moves to Extra Funds.
   4. A `System - Refund Loan` task raises (`TaskTypeId 219`) to send the funds out.
   5. The system processes that task to fund on Split or Zepto.
   6. If something stops it, a `Review - Refund Funding Error` task (`TaskTypeId 220`) should
      raise.
3. **Run the pending refund sweep query**, `Horizon2.dbo.Refund` joined to the open 219 task and
   the 220 error task, then `refundactivity` for the refund, then `payment.dbo.paymentaccountfunding`
   by payment reference (Confluence 2385150262). Establish whether it funded in Zepto.
4. **For "No Bank Account", check `applicationbankid`.** Bank details visible on screen, NULL
   reference underneath (MHD-36658).
5. **For a stuck `System - Refund Loan` task, check for a duplicate task first.** Duplicates are
   safe to close. Missing Refund-table data needs a datafix (Ron's triage note, 2026-02-19).
6. **For any reversal, confirm the thing is really a duplicate.** Roughly one in seven duplicate
   claims needs no fix at all (MHD-35813). Check the payment arrangement timeline.
7. **For a write-off reversal, check whether a stage needs removing too.** "Remove stage" normally
   accompanies a reverse write-off, because an incorrect stage movement caused the write-off
   (Confluence 546701313, MHD-12322).

## Root causes seen

1. **Race on the transaction page creating two refunds.** Horizon creates a duplicate row in the
   Refund table but Zepto rejects the second with `duplicate idempotency key`
   (team procedures (Slack) 5.4).
2. **Duplicate `System - Refund Loan` task, or missing data in the Refund table.** Ron's triage on
   2026-02-19: applications 10002591964, 10001401011, 10002669590 safe to close; 10000936497
   reopen the old refund loan task, cancel the new one, covered by datafix; 10002508336 missing
   data in the Refund table.
3. **NULL `applicationbankid`** (MHD-36658, application 10002815000).
4. **Refund processed in error while a balance is owing.** There is usually a funding error message.
   James Wiles, 2025-12-15: a refund processed in error **without** a funding error would go
   unnoticed.
5. **Batch of `Review - Refund Funding Error` tasks pending after the CRD auto-refund release.**
   Configuration issue, sorted centrally (Albert Rick, 2026-08-27).
6. **New product without a `FloatBankAccountId` mapping.** CRD-R refunds could not work at all
   until the mapping was seeded (MHD-36616, Albert Rick, 2026-09-16).
7. **Refund driving a CRD account into overdue.** Two payments of $458.13 on 28 and 29 June, one
   refunded, account went into arrears (MHD-35159, CRD 10002918836).
8. **Incorrect CRD excess balance from the 01/06/2026 E6 reward credit.** All CRD customers received
   an incorrect reward credit, so a customer who closes may show an incorrect excess balance
   (Rusty, `#solutions_memorandum`, 2026-06-04).
9. **Pay Anyone SMS transactions stranded at the provider**, pending over 24 hours and not appearing
   in Zepto, so they can neither complete nor be retried by the customer (MHD-34308, account
   10002957600).
10. **Card payment raced the direct debit.** See [direct-debit-and-dishonour.md](direct-debit-and-dishonour.md).

## The fix

| Root cause | Action |
| --- | --- |
| CRD refund | **Escalate.** Do not process (Rusty, 2026-09-17) |
| Two refunds from one click | **Datafix**, cancel out the duplicate refund transaction, then reopen the `System - Refund Loan` task so the queued refund funds. Albert Rick with Ron or Michael |
| Duplicate System - Refund Loan task | **No action beyond closing the duplicate** |
| Missing Refund-table data | **Datafix** |
| Funded in Zepto, PaymentAccountFunding exists, Refund table not updated | **Datafix**, `RefundDataFixUpdateIsProcessed @AppId, @RefundId, 1` then `RefundDataFixUpdatePaymentSubmissionStatus @AppId, @RefundId, 91005, <date completed>, <payment account funding id>, @Notes` (Confluence 2385150262) |
| Not funded in Zepto, Payment API error | **Datafix**, `RefundDataFixUpdatePaymentSubmissionStatus @AppId, @RefundId, 91001, NULL, NULL, @Notes` to reset and retry |
| Funded in Zepto, no PaymentAccountFunding data | **Datafix**, follow the MHD-28180 attachments `DataFix-MHD-28180-*.sql` |
| NULL `applicationbankid` | **Datafix**, populate the reference. MHD-36658 ran under MHD-36184 |
| Refund processed in error | **Datafix**, cancel the refund out, and raise it so the gap is recorded |
| Cannot reallocate from establishment fee | **Escalate.** Recurring Horizon error, James Wiles, 2026-01-15, application 10001844210 |
| Batch of Refund Funding Error tasks | **Escalate** to Albert Rick Martires. He posts bulk lists headed "Review - Refund Funding Error (safe to close)" |
| No `FloatBankAccountId` mapping | **Escalate** to Albert Rick Martires (MHD-36616) |
| Refund drove a CRD account overdue | **Escalate.** MHD-35159 was fixed by a code release on 12/08/2026, not a datafix |
| Reverse write-off | **Datafix**, SQL Data Fix scripts **item 15, "Reverse Writeoff V2"**, never item 14. Re-comment its `COMMIT;` before handing it over. Consecutive examples MHD-35969 and MHD-36077, both under MHD-35277 |
| Pay Anyone stranded | **Datafix**, `EXEC [dbo].[PATransactionDataFixUpdateTransaction] <ApplicationId>, <TransactionId>, 67006, 1, NULL, NULL;` then `EXEC Horizon2.[dbo].[ComputeSlidingLimit] <ApplicationId>, 1, 1;` (MHD-34308) |
| Cancel a transaction record | **Datafix**, `AppSupport_CancelTransaction @TransactionId, @ApplicationId, @Notes`, then `EXEC dbo.UpdateAmounts @ApplicationId, 1`. **It moves no money.** It only sets `TransactionStatusId = 1005` and writes `@Notes`. If the requester wants money returned, route to payments or collections |
| Payment reversal, double payment, DD in error | **Datafix**, raw script territory, parent page items 13, 38, 63, 68. Late dishonour and reverse DDAC go to Michael Dela Torre |
| Doubled-up payment | Rusty, `#app-support`, 2026-09-01: *"refund one of the payments if they both clear, otherwise disable DH fees, retry, stage movement etc."* |

**Every reversal on `[Transaction]` needs a matching amortisation record**, or the amortisation
schedule silently diverges (Tops, 2026-02-11). Templates in
[../04-sql/datafix-templates/](../04-sql/datafix-templates/).

**Item 14 is broken.** "Reverse Write Off" deletes across five tables in a `WHILE` loop with no
transaction and references an undeclared variable, so the batch fails **after** the deletes have
committed. Item 15 is the corrected rewrite, but it ships with `COMMIT;` uncommented against its
own comment (Confluence 3117842457 Part 2b).

**`[Transaction]` has `Notes` (plural); `Task` has `Note` (singular).** A common failure when
writing the cancellation note by hand (Confluence 3117842457).

**CRD transaction removal is different.** Changing a transaction's trantype to refund is equivalent
to cancelling both the original and the refund pair: *"changing the trantype of 110246491 to refund
is the same as cancelling both 110200251 & 110246491. Same outcome either way"* (Rusty,
2026-09-22). And a Horizon-side deletion of a CRD transaction does not fix it, because the record
still exists in E6. See [crd-credit-card.md](crd-credit-card.md).

## Not a defect

- **CRD auto refund running once per 24 hours while the task raises more than once.** James Wiles,
  2026-08-27: *"I believe it raises every time, just only auto refunds once."*
- **Duplicate direct debits that were both valid.** MHD-35813: the customer entered a Betterway
  arrangement after the debits processed, and we stop direct debits as soon as Betterway notifies
  us. No fix required.
- **The hourly "Stuck refund for 30 mins" count.** Observed range 3 to 5 in September 2026. The
  count alone is not actionable; run the sweep query.

## Precedents

- MHD-35969, MHD-36077: reverse write-off, under MHD-35277. MHD-35969 turned around in under two
  days.
- MHD-32859: reverse bankruptcy write-off, account 10002429438.
- MHD-32161: reverse write-off, 10001515721.
- MHD-33294: reverse duplicate refund transaction, account 10001320825.
- MHD-35159: refund drove CRD 10002918836 into overdue, fixed by code release.
- MHD-36658: "No Bank Account" on refund funding, NULL `applicationbankid`.
- MHD-36616: seeded `FloatBankAccountId` for CRD-R.
- MHD-28340: excess of $1,074.49 after full repayment, account 10001336079.
- MHD-34021: missing excess balance, transaction 10002640675.
- MHD-28907: batch-processed Zepto refunds.
- MHD-28180: funded in Zepto, no `PaymentAccountFunding` record.
- MHD-30586: unprocessed System - Refund Loan tasks.
- MHD-34308: cancelled pending Pay Anyone transactions, account 10002957600.
- MHD-12322: reverse write-off with a stage removal.
- MHD-36280, MHD-34822, MHD-35966, MHD-36617, MHD-35353, MHD-32196: further reversal tickets.

## Open defects

- **CRD refunds are frozen.** Released to Horizon 2026-09-17, but agents must escalate while the
  backlog is cleaned up so excess balances are accurate. No end date given.
- **Refunds processed in error without a funding error go unnoticed.** James Wiles raised it,
  2025-12-15. No ticket recorded.
- **Establishment fee to excess reallocation error**, recurring. No ticket recorded.
- **MHD-35966**, CRD payment reversal request for 10002926516, Waiting for Customer.
- **MHD-34306**, "Admin Fee Reallocation Error on the App, 10002922420", Pending, 84 days as at
  harvest.
