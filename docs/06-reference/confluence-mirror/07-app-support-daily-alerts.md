# App Support Daily Alerts

Mirror of the Confluence page "App Support Daily Alerts".

Last reviewed: 23 September 2026
Sources: Confluence AS page 899317845, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 899317845 · Last updated: 22 Jan 2026 · Author: Michael Dela Torre
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/899317845/App+Support+Daily+Alerts

Covers checking the `#app-support-daily-alerts` Slack channel. Alerts are prefixed `[AP]`.

## 1. [AP] App(s) Funded - without Equifax Score

```sql
USE Horizon2

-- For easier copy paste
SELECT ApplicationId, CustomerId, CreatedByUserId FROM [Application] WHERE ApplicationId IN (
10002222557, 10002229256, 10002232970
)
-- Check if no record
SELECT ApplicationId, CustomerId, Score, VersionId, CreatedByUserId FROM [VedaScore] WHERE ApplicationId IN (
10002222557, 10002229256, 10002232970
)

EXEC AppSupport_InsertVedaScore 10002682950, 3, 441
EXEC AppSupport_InsertVedaScore 10002714248, 3, 806
EXEC AppSupport_InsertVedaScore 10002714576, 3, 760
```

Arguments are `ApplicationId, VersionId, Score`. Veda Score = Comprehensive Score = Version 3.

Find the score: Horizon Web → Application → Files tab, look for "VEDA for Applicant" notes;
otherwise use Equifax Hard Check from the Notes tab.

## 2. [AP] Pending DD (2 days transaction)

Expected value is `0`. Flag to the team if it is not 0.

## 3. [AP] Funded - NOT in Funded Status

Check the application in Horizon Web. Can pass to the Ops team.

## 4 and 5. [AP] APY/PL - Overfunding and [AP] Commission - Overfunding

Check the application in Horizon Web → Transactions tab, look for duplicate amounts. If
Commission, it is usually the "Dealer/broker fee". If APY/PL, it is the "Funded" amount that
is duplicated. Create a Jira ticket.

```sql
USE Horizon2
SELECT * FROM Funding WHERE ApplicationId IN (10002279430)
SELECT * FROM FundingAppIssue WHERE ApplicationId IN (10002279430)

INSERT INTO FundingAppIssue (ApplicationId, Amount, ErrorNotes, DateCreated)
VALUES (10002216546, 19700, 'Double Fund', GETDATE())

INSERT INTO FundingAppIssue (ApplicationId, Amount, ErrorNotes, DateCreated)
VALUES (10002219161, 1490, 'Commission Double Fund', GETDATE())
```

## 6. [AP] APY/PL Funded Apps - No MoneyOut

Check Horizon Web → Transactions tab for Transactions Out dated today, or:

```sql
USE Horizon2
SELECT ApplicationId, FundingId, TransactionId, Amount, AccountName, IsCompleted, IsSuccessful, DateCompleted
FROM Funding WHERE ApplicationId = 10002352667
```

This alert usually appears when the transactions are made before 7:04 AM Philippine time.

---
