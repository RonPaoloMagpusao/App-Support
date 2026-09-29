# Datafix request

How App Support gets SQL run in production: the `#datascript-requests` contract, the monthly umbrella ticket, and the two competing "current" processes.

Last reviewed: 23 September 2026

Sources: `harvest/slack-procedures.md` section 2; `harvest/jira-raw-notes.md` (monthly datafix process, linking); `harvest/confluence-systems-reference.md` section 12; `harvest/confluence-content.md` (Cover Runbook 3131015188, DataFix Guide 1409351766, App Support Data Fix Manual 498401800, Reoccurring DataFix process 2524381287); `harvest/slack-tribal-knowledge.md` section 2.

## 0. The one rule above all others

**Nothing runs in production by App Support's own hand** (Confluence 3131015188). You write the script, attach it to a ticket, and request execution in `#datascript-requests`. The SQL dev runs it.

## 1. Two competing "current" processes

The sources do not agree on what the datafix process is. Both are described as current by their own page. Read both and pick by risk.

### Reading A: the monthly umbrella workflow (App Support's live practice)

Documented in the Cover Runbook (Confluence 3131015188, last updated 26 Aug 2026, author Ron Magpusao), and corroborated by every observed request in `#datascript-requests` and by the Jira link graph on MHD-35277 and MHD-36184.

1. Write the script and attach it to the current monthly umbrella ticket, `[App Support] Data Fix - YYYY-Mon`.
2. Number it sequentially within that ticket ("Data fix # 1", "# 2", ...). DB Portal auto-reviews and posts a verdict.
3. Post in `#datascript-requests` tagging Victor Alvarez and Krizza Rosales, asking them to run Data fix # N in prod and **not** to close the ticket.
4. Comment back on the originating ticket ("Done implementing the fix for this request. Thanks!") and close it. Leave the umbrella ticket open.

No named per-fix approver. Approval is carried by the monthly umbrella, which is a Change Request Data Fix/External with Multiple Approvals.

### Reading B: the ten-step approval-heavy process (the older DataFix Guide)

Documented in the DataFix Guide (Confluence 1409351766, last updated 31 Dec 2024, author Ron Magpusao) and echoed by the App Support Data Fix Manual (Confluence 498401800, 12 Jan 2024, author Michael Dela Torre).

1. Create a DataFix ticket in Jira with the description, steps to reproduce, the fix approach or script outline, and supporting context.
2. Review that all required information is present and the approvers **Jeffrey Lu** and **Jon Wu** are listed.
3. Obtain approval from Jeffrey Lu and Jon Wu, Slack channel `C056NTCCX96`.
4. Update the ticket status to Approved and record both approvals.
5. Hand over to the DB team, Slack channel `C02HB99AXDX` (this is `#datascript-requests`).
6. DB team review and preparation: verify against a test environment where possible, review production impact, confirm backups.
7. DB team runs the script.
8. Post-fix validation: check the impacted data points, query to confirm no unintended changes, test for regressions.
9. Ticket closure with outcome, logs and screenshots.
10. Communication and documentation.

The Cover Runbook itself flags the conflict: *"Note this is the older, approval heavy variant; the Cover Runbook (page 3131015188) documents the current monthly umbrella ticket workflow, which differs."*

### How to reconcile them

- **Default to Reading A** for the routine mix: login and passcode fixes, contact and email updates, file removals, duplicate transaction cleanup, PPSR removals, account merges. These are what the monthly umbrella exists to pre-approve (Confluence 2524381287 lists the covered categories).
- **Fall back to Reading B** where a named approval gate applies, where the change is structural (stored procedure alteration, schema touching), or where the blast radius is beyond one application.
- **One gate survives in both readings:** the **Incorrect URL ID Fix** requires **Jeffrey Lu and Jon Wu** plus the DB team, regardless of how low-risk it looks (Confluence 3131015188 and 498401800).

## 2. Channel contract

`#datascript-requests`, channel ID `C02HB99AXDX`, private, created 2021-10-07 by Amanda Davenport. Purpose, verbatim:

> Channel for requesting SQL Dev to run datascripts. Pls share with other team members, if they need this channel. SQL Dev will look at new requests each work day (Mon-Fri) between 12-1pm & also 4-5pm (Sydney time). If URGENT tag @meghashree

**Window arithmetic matters.** Requests landing after roughly 16:00 Philippine time on the previous day have slipped a day in practice (Ron, 2026-09-17). If a funding or payment fix has to land today, it needs to be in the channel before the afternoon Sydney window.

## 3. Who runs the scripts

| Person | Slack ID | Role |
| --- | --- | --- |
| **Victor Anthony Alvarez** | `U04D4F52Y7J` | SQL dev, primary executor |
| **Maria Krizza Rosales** | `U03SM7YL3K7` | SQL dev, primary executor |
| **meghashree (Megha)** | `U01GN5N1DQF` | SQL developer, Decision Intelligence. Tag for URGENT per the channel purpose |

Practically every request tags **both** Victor and Krizza.

## 4. The request templates people actually use

App Support's monthly-datafix form:

```
Hi @Victor Alvarez and @Krizza Rosales need your help running Data fix # {N}
in prod please. Please do not close the ticket. Thank you!
https://moneyme1.atlassian.net/browse/MHD-{monthly ticket}
```

Per-script variant, used when the script has its own file name (Michael Dela Torre):

```
Hi @Victor Alvarez @Krizza Rosales requesting for your implementation of
`MHD-36811.sql` in Prod. Please do not close the ticket after. Thanks!
https://moneyme1.atlassian.net/browse/MHD-36184  [App Support] Data Fix - 2026-Sep
```

Urgent variant:

```
Hi @Victor Alvarez and @Krizza Rosales need your help running Data fix # 10 in
prod please. Marking this as Urgent :rotating_light: as per team.
Please do not close the ticket. Thank you!
```

Soft-execution-first variant, when you want the result set before committing:

```
Please help with the soft execution for this ticket: {MHD link}
We will need the results and the messages. Thanks
```

Long-running variant:

```
... requesting for your implementation of `MHD-36602-Soft.sql` in Prod.
_Note that this is a long running script_. Kindly send the results back here.
Please do not close the ticket after.
```

Scheduled variant:

```
please help us run this script *4PM PH Time* today
kindly *implement this today after business hours*
Hello ... kindly help us execute this later 5pm today
```

Backup-first variant, for stored procedure changes:

```
before you execute, requesting to back up and send here this SP
`dbo.GetApplicationSearchItems` then wait for my go signal
```

## 5. The rules that matter

1. **Always link the Jira ticket. Never paste raw SQL as the request.** Every observed request links an `MHD-xxxxx`, or an `AMZ-`, `PER-`, `G1-`, `HOR-`, `CL-` or `APY-` release ticket that itself carries the script.
2. **Name the exact file.** Where a ticket holds several scripts, name the `.sql` file, and if order matters say so ("in order of their prefixes").
3. **Say "Please do not close the ticket."** This is the single most repeated sentence in the channel. The monthly umbrella stays open all month and takes numbered datafixes 1 to N.
4. **Ask for the results back in the channel** when you need them.
5. **Soft execute before commit** for anything that mutates rows. Soft execute, review the result set, then request the commit script.
6. **Back up stored procedures before altering them.** Post the backup in channel and wait for the requester's go signal.
7. **Flag urgency explicitly** with the rotating light emoji and the words "Marking this as Urgent as per team".
8. **cc the owning team lead**, for example `cc: @Aly`, `cc: @Ulysses`, `cc: @Marvin`, `cc: @Jef @Josah`.
9. **Follow-ups are normal.** "gentle follow up on this one, please."
10. **If it errors**, the SQL dev replies in channel naming the datafix number ("Hi @Ron, error occurred for Datafix #12"). Fix the script and re-request: "updated the script. Need your help running datafix # 1 again please."

### Backup convention

```sql
SELECT * INTO <Table>_MHD<ticket> FROM <Table> WHERE <key> = <value>;
```

with the hyphen stripped from the ticket number, for example `Application_MHD12195` (Confluence 3131015188, 498401800). Where the backup table already exists, the Data Fix Manual gives a `SET IDENTITY_INSERT ... ON` / `INSERT INTO ... SELECT` / `SET IDENTITY_INSERT ... OFF` pattern before the UPDATEs.

### Two landmines

- `AppSupport_UpdateCustomerAccount` has **no parameter defaults**. It overwrites `Username`, `Password`, `BrandId` and `IsActive` together, so a wrong `@Password` resets the customer's login (Confluence 3131015188).
- **Incorrect URL ID Fix** carries the named Jeffrey Lu and Jon Wu approval gate regardless of risk rating.

### Prefer the parameterised procedures

Sixteen `dbo.AppSupport_*` stored procedures cover the most common fixes (Confluence 2485059655). Use them before writing raw SQL. Search the historical catalogue (Confluence 519602304) before writing anything new, and take the **shape** of a script, never the literal IDs, emails or plate numbers. See [`../04-sql/`](../04-sql/).

## 6. Ticket naming conventions in the channel

```
[App Support] Data Fix - {Month}
[PL - Data Fix] {PER-xxxx} ...
[PL - Database Release] ...
[HOR - DB Release] - ...
[G1 - Database Release] ...
[G3 - Database Release] ...
[AMZ - Database Release] ...
[APY - Database Release] ...
[CL - Database Release] ...
[DI - DB Release] ...
[SPV - TrustFund & Horizon2 DB] ...
[MoneyMe.Funding2.0] ...
```

For a ticket raised by Ops through the portal, the required title format is `[APY] [Datafix] AppID - description`, with the App ID and both the current and intended data values in the description, Urgency High, Impact and Severity blank (Confluence 2524381287).

## 7. The monthly umbrella ticket

A ticket auto-creates on the 1st of each month at about 09:00: `[App Support] Data Fix - YYYY-Mon`, issue type **Change Request Data Fix/External with Multiple Approvals** ([03-procedures/jira-conventions.md](jira-conventions.md)).

Standing description:

> creating this ticket to support the approval and tracking of App Support data fixes for this month. This covers login fixes, email or mobile account updates, incorrect file removals, duplicate transactions, and other related fixes. This ticket will be reviewed at the end of the month for verification and record-keeping.

Individual requests are raised as Problems and linked to the umbrella by **Blocks** or **Cover**. The umbrella moves Implementing to Deployment Completed at month end.

| Ticket | Month |
| --- | --- |
| MHD-36184 | 2026-Sep |
| MHD-35277 | 2026-Aug (69 children) |
| MHD-34282 | 2026-Jul |
| MHD-33350 | 2026-Jun |
| MHD-32416 | 2026-May |
| MHD-31576 | 2026-Apr |
| MHD-30801 | 2026-Mar |
| MHD-30099 | 2026-Feb |

**Linking gotcha.** The Blocks-versus-Cover split on the umbrella's children looks arbitrary, so **query both link types** to enumerate a month's datafixes ([03-procedures/jira-conventions.md](jira-conventions.md)). See [`jira-conventions.md`](jira-conventions.md).

**Contradiction worth noting.** MHD-34282 is the July umbrella in the Jira link data, but in Slack Ron referred to it as *"Pre-approved ticket for datafixes"* for ad-hoc work (`#datascript-requests`, 2026-07-09). Read it as the same ticket used both ways, not as two tickets.

### What the umbrella actually covers

From MHD-35277's 69 children, a representative steady-state mix:

- login and passcode fixes, and inserting missing brand accounts
- email and mobile contact updates, including per-brand inserts (`Insert BrandId 5 contact and email`)
- Equifax score inserts
- PPSR removal and setting vehicle asset status to `removed` (SPL and APY)
- moving applications between customer IDs
- removing files uploaded in error
- deleting or correcting transactions created in error
- dealership and lead source updates, removing dealership bank details
- unsticking applications (Signed Off, stage regression, funding records)
- write-off reversals and contract variations
- Horizon permission grants
- loan term and repaid date corrections

The Operations-facing list (Confluence 2524381287, scope APY and PL) is narrower and worth quoting to Ops when they ask what qualifies: update or create customer account, remove duplicate customer, update contact number, update email address, remove duplicate email address, merge account, remove incorrect uploaded files, PL/SPL and APY PPSR removal with vehicle asset status set to Removed, update PPSR (EdxRegistration), change to Default (DC) payment method, remove obsolete disbursement from the Disbursement table.

## 8. Worked example: transaction reversal

Ron's reversal skeleton, used for Zepto late-dishonour reversals (MHD-30342 and MHD-30348, Feb 2026). Reproduced for shape; the values are the worked example.

```sql
DECLARE @TranId    BIGINT = 101948541
DECLARE @AppId     BIGINT = 10001492387
DECLARE @UserId    BIGINT = 148          -- the requesting agent's Horizon user id
DECLARE @TranAmount MONEY

DECLARE @notes VARCHAR(500) =
  'Reverse cleared payments for Zepto late dishonour notifications: 101948541 | MHD-30342'

SELECT @TranAmount = TranAmount
FROM [Transaction]
WHERE TransactionId = @TranId
  AND ApplicationId = @AppId

BEGIN TRAN
  -- Reversed Transaction
  INSERT INTO [Transaction] ...
```

**The gotcha, from Tops (2026-02-11):** a transaction reversal must have an **amortisation counterpart**, otherwise the amortisation record is out of step.

> "may same request si Michael about sa late dishonour, isabay mo na lang sya dun kasi need din magkaron ng record ang reversal sa amortization"

This is why September 2026 carried a script literally named `Soft Execution - MHD36494 - Create amort counterpart for Bulk Dishonour Fee Update - Sep2026.sql`.

### Amortisation cancellation recipe

From Jess Leal, 2026-06-05, to cancel proposed or scheduled amortisation entries by datafix:

1. Update the status of the affected amorts to **35005 (Cancelled)**.
2. Update Notes to add the note **"Cancel all proposed schedule"** for the affected amorts.

The special note is what stops Horizon regenerating new proposed schedules.

Script library: [`../04-sql/datafix-templates/`](../04-sql/datafix-templates/). Diagnostic queries: [`../04-sql/diagnostics/`](../04-sql/diagnostics/).
