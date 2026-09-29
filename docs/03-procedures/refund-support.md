# Refund support

Working `#refund-supports`: the hourly signal, the CRD freeze, how a refund is supposed to work, and the failure modes that actually turn up.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` section 5; `harvest/slack-tribal-knowledge.md` section 2; `harvest/confluence-content.md` (Pending Funding and Refund support 2385150262); `#solutions_memorandum` 2026-08-13 and 2026-09-17.

Channel: `#refund-supports`, ID `C051WET9T1A`, private, created 2023-04-05 by Raina Schmidt.

## 1. The automated signal

Hourly bot post, on the hour, same shape as funding:

```
*Stuck refund for 30 mins:*  {N}
```

Observed range in September 2026: 3 to 5. As with funding, the count is a count and not a list; it is a health indicator, not a work queue. Work the human requests.

## 2. Standing instruction as at 23 September 2026: CRD refunds are frozen

Rusty, 2026-09-17, `#solutions_memorandum`:

> "Refunds for CRD have been released to Horizon overnight. **Please do not process any refunds at this stage, and continue to escalate for now.**"

This is current. Do not process a CRD refund. Escalate it.

Also standing, from 2026-06-04: **refunds cannot be processed for closed accounts.** Where a large refund is expected, or the customer specifically asks, escalate and an exception can be made.

Check `#solutions_memorandum` before processing anything, because these instructions change without a ticket.

## 3. The normal, non-CRD refund mechanism

As laid out by **James Wiles** (`UG189BF6K`), the main refunds requester, 2026-02-19:

1. The account has an **excess balance**.
2. The agent reallocates credit to excess if needed (from principal, interest or establishment fee), then processes the refund on the Transactions page.
3. The excess moves to **Extra Funds**, *"as is ordinarily the case when a refund is processed"*.
4. A **`System - Refund Loan`** task raises, to send the funds out.
5. The system processes that task to fund on **Split/Zepto**.
6. If something stops it, a **`Review - Refund Funding Error`** task should raise.

His own note on the failure mode: *"If there's anything stopping this from being processed, the Review - Refund Funding Error would usually raise, but it didn't."* The absence of an error task does not mean the refund succeeded.

Timing: the auto refund runs **at most once per 24 hours** per account, although the task can raise more than once. James, 2026-08-27: *"I believe it raises every time, just only auto refunds once."*

Task type IDs: `TaskTypeId 219` = refund task, `TaskTypeId 220` = review refund error task (Confluence 2385150262).

## 4. Known failure modes and their fixes

| Symptom | Cause | Fix and owner |
| --- | --- | --- |
| Two refund transactions created from one click | Race on the transaction page. Horizon creates a duplicate row in the Refund table but Zepto rejects the second with `duplicate idempotency key` | Cancel out the duplicate refund transaction, then reopen the `System - Refund Loan` task so the queued refund funds. Albert Rick plus Ron or Michael |
| `System - Refund Loan` open for a long time, overpayment task still open | Duplicate task created by the system, **or** missing data in the Refund table | Duplicates are safe to close. Missing Refund-table data needs a datafix. Ron's triage note, 2026-02-19, covered apps 10002591964, 10001401011 and 10002669590 (safe to close), 10000936497 (reopen the old refund loan task, cancel the new one, covered by datafix) and 10002508336 (missing data in the Refund table) |
| Refund processed although a balance is still owing | Horizon processed it in error; there is usually a funding error message | Cancel the refund out. **Raise it**, because a refund processed in error *without* a funding error would go unnoticed. James, 2025-12-15 |
| Cannot reallocate a small amount from establishment fee to excess | Horizon error on reallocation | Recurring. Raise with App Support. James, 2026-01-15, app 10001844210 |
| Batch of `Review - Refund Funding Error` tasks all pending | Configuration issue after a CRD auto-refund release | Sorted centrally; the tasks then complete. Albert Rick, 2026-08-27 |
| `Review - Refund Funding Error` tasks that are safe to close | Assessed in bulk by Albert Rick | He posts a list headed "Review - Refund Funding Error (safe to close)" |

### The datafix shapes

Three patterns cover most refund datafixes (Confluence 2385150262). Full scripts in [`../04-sql/datafix-templates/`](../04-sql/datafix-templates/).

**Funded in Zepto, `PaymentAccountFunding` exists, but the Refund table was not updated:**

```sql
DECLARE @AppId BIGINT = 10001985427
DECLARE @RefundId BIGINT = 25362
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@AppId AS NVARCHAR(20)), ' - RefundFundTransferDone');
EXEC Horizon2.[dbo].[RefundDataFixUpdateIsProcessed] @AppId, @RefundId, 1
EXEC [Horizon2].[dbo].[RefundDataFixUpdatePaymentSubmissionStatus] @AppId, @RefundId, 91005, '2025-11-27 08:52:05.247', '340FD10D-C901-4865-B129-A61CA7E8923C', @Notes
```

**Not funded in Zepto, error in the Payment API, reset to retry:**

```sql
DECLARE @AppId BIGINT = 10002674557
DECLARE @RefundId BIGINT = 25389
DECLARE @Notes NVARCHAR(MAX) = CONCAT('Application: ', CAST(@AppId AS NVARCHAR(20)), ' - RefundFundTransferDone');
EXEC [Horizon2].[dbo].[RefundDataFixUpdatePaymentSubmissionStatus] @AppId, @RefundId, 91001, NULL, NULL, @Notes
```

**Funded in Zepto but no data in `PaymentAccountFunding`:** see the MHD-28180 attachments, `DataFix-MHD-28180-*.sql`.

The status IDs are the same ladder as funding: `91001` reset to retry, `91005` mark as funded.

### The sweep query

Applications with a pending refund, from Confluence 2385150262:

```sql
SELECT R.*
FROM Horizon2.dbo.Refund R WITH (NOLOCK)
INNER JOIN Horizon2.dbo.Task T WITH (NOLOCK) ON T.TaskId = R.RefundTaskId
INNER JOIN Horizon2.dbo.Application A WITH (NOLOCK) ON R.ApplicationId = A.ApplicationId
INNER JOIN Horizon2.dbo.Customer C WITH (NOLOCK) ON A.CustomerId = C.CustomerId
LEFT JOIN Horizon2.dbo.Task ET WITH (NOLOCK) ON R.ReviewRefundErrorTaskId = ET.TaskId AND ET.TaskTypeId = 220
LEFT JOIN Payment.dbo.PaymentAccountFunding PAF WITH (NOLOCK) ON R.PaymentFundingId = PAF.PaymentAccountFundingId
WHERE R.IsCompleted = 0 AND R.IsSuccessful = 0
AND R.DateCreated <= DATEADD(MINUTE, -30, GETDATE())
AND (C.FirstName NOT LIKE '%wagtest%')
AND T.TaskTypeId = 219
AND T.Status = 'Open'
ORDER BY R.DateCreated DESC
```

Follow-up lookups:

```sql
SELECT * FROM payment.dbo.paymentaccountfunding WHERE paymentreference = 'PB.19ctj7'
SELECT * FROM horizon2.dbo.refundactivity WHERE refundid = 25389 ORDER BY datecreated DESC
```

Copies live in [`../04-sql/diagnostics/`](../04-sql/diagnostics/).

## 5. Enabling refunds on a new product

A refund cannot work on a product until its **`FloatBankAccountId` mapping** is seeded. For CRD-R this was MHD-36616, *"Seed FloatBankAccountId mapping for CRD-R product to enable CRD app refunds"* (Albert Rick, 2026-09-16).

So when a new product launches and refunds fail from day one with no obvious error, check the float bank account mapping before investigating the refund path itself.

## 6. Who to tag

| Role | Person |
| --- | --- |
| Refunds, Ops side | **James Wiles (Jim)** (`UG189BF6K`), **Raina Schmidt** |
| Refund funding path, bulk assessments | **Albert Rick Martires** |
| Datafix execution | `#datascript-requests`, Victor and Krizza |
| CRD escalation while the freeze holds | `#app-support-crd`, `#crd_firefighters`, Rusty |

## 7. Related

- Funding shares the same Payment API and status IDs: [`funding-checks.md`](funding-checks.md).
- Requesting the datafix: [`datafix-request.md`](datafix-request.md).
- CRD product behaviour, E6 as source of truth: [`../05-knowledge/`](../05-knowledge/).
