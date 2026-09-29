# Backup table hygiene

Every datafix leaves a permanent `<Table>_MHD<number>` table in production. Nobody owns cleaning them up.

Last reviewed: 23 September 2026
Sources: Confluence gaps review (section 1.2, 4.10), Datafix catalogue 3117842457, MHD-35277

## The problem

- Each fix creates tables such as `CustomerEmail_MHD35866`, `fundingactivity_MHD35277`, `Application_MHD12195`.
- They hold full customer rows, including encrypted bank account numbers.
- No Confluence page says when, or whether, they are dropped.
- App Support runs roughly 70 datafixes a month (MHD-35277 has 69 children), so the shadow copy of customer data grows every month.
- Fifteen of the sixteen `AppSupport_*` procedures take no backup at all. `AppSupport_DeleteCustomerContactNumber`, `AppSupport_DeleteCustomerEmail` and `AppSupport_DeleteFileUpload` are irreversible and have no inverse procedure. Capture the row with `SELECT *` before running any of them.

## Inventory query (read only)

```sql
USE Horizon2;

SELECT  s.name                         AS SchemaName,
        t.name                         AS BackupTable,
        TRY_CAST(SUBSTRING(t.name, CHARINDEX('_MHD', t.name) + 4, 10) AS INT) AS TicketNumber,
        t.create_date,
        DATEDIFF(DAY, t.create_date, GETDATE()) AS AgeDays,
        SUM(p.rows)                    AS [RowCount]
FROM sys.tables t
JOIN sys.schemas s     ON s.schema_id = t.schema_id
JOIN sys.partitions p  ON p.object_id = t.object_id AND p.index_id IN (0, 1)
WHERE t.name LIKE '%[_]MHD[0-9]%'
GROUP BY s.name, t.name, t.create_date
ORDER BY t.create_date;
```

Unverified: whether App Support accounts have `VIEW DEFINITION` on `sys.tables` in production. If not, ask the data team to run it.

## Proposed retention rule

**Proposal only. Not agreed with anyone.**

1. Keep a backup table for 90 days after the ticket's datafix is confirmed, or until the next monthly datafix umbrella ticket closes, whichever is later.
2. Before dropping, confirm the originating MHD ticket is Closed and the reporter has not reopened it.
3. Drop in a monthly batch owned by one named person, logged as a child of that month's datafix umbrella ticket.
4. Never drop a backup table referenced by an open IDR, AFCA or complaint ticket.

Raise this with the data team and whoever owns privacy before acting on it. It is also listed in [../07-open-items/security-findings.md](../07-open-items/security-findings.md).
