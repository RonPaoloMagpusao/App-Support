# SQL library

The safety contract for production scripts on Horizon2, the stored procedures App Support owns, the legacy raw script catalogue, and read-only diagnostics.

Last reviewed: 23 September 2026
Sources: Confluence AS 3117842457 (Datafix catalogue), AS 2485059655 (Store Procedures), AS 519602304 (SQL Data Fix scripts), AS 1398210569 (Common Login SQL); MHD-35969 corrected script; `#datascript-requests`

Target: MS SQL Server, database `Horizon2`, schema `dbo`, T-SQL. Scripts are executed by the data team via `#datascript-requests`, not by App Support directly. See [../03-procedures/datafix-request.md](../03-procedures/datafix-request.md).

## Decision rule: procedure first, raw script second

1. **Is it a datafix at all?** Check [datafix-routing.md](datafix-routing.md) Part 1 ("Not a datafix") and [../05-knowledge/working-as-designed.md](../05-knowledge/working-as-designed.md). Many requests are config, a Horizon UI action, or a defect that needs a dev fix rather than a data patch.
2. **Does a stored procedure cover it?** Use the routing table in [datafix-routing.md](datafix-routing.md) Part 2 and the bodies in [stored-procedures.md](stored-procedures.md). Read the row warnings first: row 6 (`AppSupport_UpdateCustomerAccount`) silently resets credentials if you guess `@Password`.
3. **Only then a raw script.** Start from [script-template.sql](script-template.sql). The legacy catalogue in [sql-datafix-catalogue.md](sql-datafix-catalogue.md) is archive material: roughly six of ~97 items use a transaction, and several are known broken (see below).
4. **Run Pass A lookups first.** Resolve every ID with [diagnostics/pass-a-lookups.sql](diagnostics/pass-a-lookups.sql) before writing the fix.

## The safety contract

Every script handed to `#datascript-requests` must meet all of these.

| # | Rule | Why |
| --- | --- | --- |
| 1 | `USE Horizon2;` at the top | Scripts have been run against the wrong database |
| 2 | `BEGIN TRAN;` then the work, with `-- COMMIT;` commented and `ROLLBACK;` live on first hand-over | The runner checks the verify block before committing. Legacy item 15 shipped with `COMMIT;` live against its own comment (Confluence 3117842457) |
| 3 | Backup tables named `<Table>_MHD<number>`, no hyphen | `AppSupport_DeleteFundingRecords` concatenates `@MHDTicket` into dynamic DDL; `MHD-35866` is an invalid identifier and fails the batch (Confluence 3117842457) |
| 4 | Create backup tables **only if missing**, never drop at the start | A re-run of the original MHD-35969 script would have destroyed the first run's backup |
| 5 | Guard every backup insert with `NOT EXISTS` on the key | Re-runs otherwise duplicate backup rows |
| 6 | Reset loop variables at the top of every iteration | Original MHD-35969: `@AmortizationId` carried over from the previous application and deleted the wrong row |
| 7 | Back up **everything** you delete, including `Amortization` and `AmortizationHistory` | Original MHD-35969 deleted both with no backup |
| 8 | Do not back up an IDENTITY table with `SELECT INTO` and then `INSERT` into it without a column list | `SELECT INTO` copies the IDENTITY property; the insert fails with "An explicit value for the identity column ... can only be specified when a column list is used and IDENTITY_INSERT is ON". Either take the whole backup in one `SELECT INTO`, or use `SET IDENTITY_INSERT ... ON` with an explicit column list |
| 9 | Scope every `WHERE` with parentheses around `OR` | Legacy item 82: `AND IsDischarged = 0 OR IsDischarged IS NULL` scooped rows from other applications |
| 10 | `CustomerAccount` updates must filter on `CustomerAccountId`, not only `CustomerId` | Legacy items 5, 35 and login item 5 rewrote every brand row for the customer |
| 11 | Call `EXEC dbo.UpdateAmounts @ApplicationId, 1;` after changing transactions | Neither the procedures nor raw deletes recalculate balances. `UpdateAmounts` is **recalculated, not restored**: an undo means re-running it |
| 12 | End with a verify block: count assertions scoped to the rows actually changed | The runner needs something to check before committing |
| 13 | `WITH (NOLOCK)` on reads only | Never on a statement that feeds a write decision inside the transaction unless you accept dirty reads |
| 14 | Quote string literals against varchar columns | Vehicles item 3 compares an unquoted numeric literal to `VIN` |
| 15 | No credentials, password hashes or plaintext in the script or its comments | Several Confluence pages do this today. See [../07-open-items/security-findings.md](../07-open-items/security-findings.md) |

System spellings to watch: the table is `Amortization`; the `[Transaction]` column is `WrittenOfRemainingPrincipalBalance` (sic) alongside `WrittenOffRemainingPrincipalBalance`; `[Transaction]` has `Notes` (plural) while `Task` has `Note` (singular).

## Files in this folder

| File | What it is |
| --- | --- |
| [datafix-routing.md](datafix-routing.md) | Symptom to fix routing: not-a-datafix list, composite patterns A to E, procedure routing table with warnings, raw script clusters, landmines, Pass A lookups, reference values |
| [stored-procedures.md](stored-procedures.md) | The sixteen `dbo.AppSupport_*` procedures: execute samples and full bodies |
| [sql-datafix-catalogue.md](sql-datafix-catalogue.md) | Legacy raw script catalogue (~100 items). Archive, read the landmines first |
| [login-datafix-scripts.md](login-datafix-scripts.md) | Login and account investigation scripts; item 1 is the single most useful diagnostic |
| [script-template.sql](script-template.sql) | Blank re-run-safe template that meets the contract above |
| [backup-table-hygiene.md](backup-table-hygiene.md) | The `_MHD` backup table problem and a proposed retention rule |
| [diagnostics/pass-a-lookups.sql](diagnostics/pass-a-lookups.sql) | Read-only lookups to resolve IDs before a fix |
| [datafix-templates/MHD-35969-reverse-writeoff.sql](datafix-templates/MHD-35969-reverse-writeoff.sql) | Reference implementation of the contract: reverse write-off, corrected and re-run safe |

## Known unsafe scripts

Do not hand these over as published. Source: Confluence 3117842457.

| Item | Page | Problem | Use instead |
| --- | --- | --- | --- |
| 14 "Reverse Write Off" | 519602304 | Deletes across five tables in a `WHILE` loop with no transaction and an undeclared variable; the batch fails **after** the deletes commit | Item 15, re-commented, or [MHD-35969-reverse-writeoff.sql](datafix-templates/MHD-35969-reverse-writeoff.sql) |
| 15 "Reverse Writeoff V2" | 519602304 | Ships with `COMMIT;` uncommented | Re-comment before hand-over |
| 82 | 519602304 | Unparenthesised `OR` in the backup `SELECT` | `AppSupport_PLRemovePPSR` / `AppSupport_APYRemovePPSR` |
| 5, 35 | 519602304 | `UPDATE CustomerAccount ... WHERE CustomerId = x` with no `CustomerAccountId` | `AppSupport_UpdateCustomerAccount` (read its warning) |
| Login item 5 | 1398210569 | Same `CustomerAccount` scoping bug | As above |
| 96 | 519602304 | Declares the same backup name twice; the second throws and the write proceeds unbacked | Rewrite from the template |
| 66 | 519602304 | Nulls `ApplicationId` on `InboundEmail` with no backup | Add a backup first |
| 17 | 519602304 | Not valid T-SQL as published | Rewrite |
| 95 | 519602304 | Mutates a second database (`Payment.dbo.SplitAccount`) | Confirm with the payments team first |
| 85 | 519602304 | Explicitly interim "while dev fix is not yet released" | Check whether the release has landed |
| `AppSupport_UpdatePPSR` | 2485059655 | Bare `INSERT` into `EdxRegistration` with no existence check; re-running duplicates | Check for the row first |

## The reference script

[MHD-35969-reverse-writeoff.sql](datafix-templates/MHD-35969-reverse-writeoff.sql) is reproduced exactly as corrected on 14 September 2026, which means it ends with `COMMIT;` live and `-- ROLLBACK;` commented, as it was run. When reusing it as a pattern, swap those two lines per rule 2.
