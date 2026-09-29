-- ============================================================================
-- Ticket:   MHD-<TICKET>
-- Purpose:  <one line: what this fixes and why>
-- Apps:     <APP_IDS>
-- Author:   <name>, App Support
-- Date:     <yyyy-mm-dd>
--
-- Re-run safe: yes. Backups are created only if missing and inserts are
-- guarded, so running twice neither destroys nor duplicates a backup.
--
-- Not covered by backups: anything recalculated by dbo.UpdateAmounts.
-- An undo restores the rows from the _MHD<TICKET> tables and then re-runs
-- UpdateAmounts.
--
-- Contract: docs/04-sql/README.md
-- ============================================================================

USE Horizon2;

BEGIN TRAN;

-- ---------------------------------------------------------------------------
-- 1. Target applications
-- ---------------------------------------------------------------------------
DECLARE @AffectedApps TABLE (ApplicationId BIGINT PRIMARY KEY, IsProcessed BIT NOT NULL DEFAULT 0);
DECLARE @CurrentAppId BIGINT;

INSERT INTO @AffectedApps (ApplicationId)
SELECT CAST([Value] AS BIGINT)
FROM dbo.fn_SplitString('<APP_IDS>', ',');

-- ---------------------------------------------------------------------------
-- 2. Backup tables: create only if missing, never drop.
--    Name: <Table>_MHD<TICKET> with no hyphen.
--    WHERE 1 = 0 copies the structure only. SELECT INTO copies the IDENTITY
--    property, so later inserts need SET IDENTITY_INSERT ON and a column list.
-- ---------------------------------------------------------------------------
IF OBJECT_ID('dbo.<Table>_MHD<TICKET>') IS NULL
BEGIN
    SELECT * INTO dbo.<Table>_MHD<TICKET> FROM dbo.<Table> WHERE 1 = 0;
    ALTER TABLE dbo.<Table>_MHD<TICKET> ADD BackupRunAt DATETIME NOT NULL DEFAULT GETDATE();
END

-- ---------------------------------------------------------------------------
-- 3. Process each application
-- ---------------------------------------------------------------------------
WHILE EXISTS (SELECT 1 FROM @AffectedApps WHERE IsProcessed = 0)
BEGIN
    SELECT TOP 1 @CurrentAppId = ApplicationId
    FROM @AffectedApps
    WHERE IsProcessed = 0;

    -- Reset every per-iteration variable here. A variable assigned by
    -- SELECT keeps its previous value when no row matches.
    -- SET @SomeId = NULL;

    -- === Backup, guarded ===
    SET IDENTITY_INSERT dbo.<Table>_MHD<TICKET> ON;
    INSERT INTO dbo.<Table>_MHD<TICKET> (<KeyColumn>, <col1>, <col2>)
    SELECT t.<KeyColumn>, t.<col1>, t.<col2>
    FROM dbo.<Table> t
    WHERE t.ApplicationId = @CurrentAppId
      AND (<condition>)
      AND NOT EXISTS (
            SELECT 1 FROM dbo.<Table>_MHD<TICKET> b
            WHERE b.<KeyColumn> = t.<KeyColumn>
          );
    SET IDENTITY_INSERT dbo.<Table>_MHD<TICKET> OFF;

    -- === Change ===
    -- Parenthesise every OR. Scope to the application.
    -- UPDATE dbo.<Table>
    -- SET <col> = <value>
    -- WHERE ApplicationId = @CurrentAppId
    --   AND (<condition>);

    -- === Recalculate derived balances if transactions changed ===
    -- EXEC dbo.UpdateAmounts @CurrentAppId, 1;

    UPDATE @AffectedApps SET IsProcessed = 1 WHERE ApplicationId = @CurrentAppId;
END

-- ---------------------------------------------------------------------------
-- 4. Verify: rows backed up, and the change landed only where intended
-- ---------------------------------------------------------------------------
SELECT '<Table>' AS TableName,
       (SELECT COUNT(*) FROM dbo.<Table>_MHD<TICKET> b
         WHERE b.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)) AS BackedUpRows,
       (SELECT COUNT(*) FROM dbo.<Table> t
         WHERE t.ApplicationId IN (SELECT ApplicationId FROM @AffectedApps)
           AND (<condition that should now be false>))                     AS ShouldNowBeZero;

-- Runner: check the verify output, then swap these two lines.
ROLLBACK;
-- COMMIT;
