-- ============================================================================
-- Pass A lookup queries: resolve the IDs a datafix needs before writing it.
-- SELECT only. Safe to run against production (Horizon2).
-- Source: Confluence AS page 3117842457 (Datafix catalogue, Part 3),
--         mirrored in docs/04-sql/datafix-routing.md.
-- Last reviewed: 23 September 2026
-- Replace every <placeholder> before running.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Resolve the identifier in the ticket
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT ApplicationId, CustomerId
FROM [Application]
WHERE ApplicationId = <ApplicationId from ticket>;

USE Horizon2;
-- Is it an ApplicationId?
SELECT ApplicationId, CustomerId FROM [Application] WHERE ApplicationId = <id from URL>;
-- Or is it genuinely a CustomerId?
SELECT CustomerId FROM CustomerEmail WHERE CustomerId = <id from URL>;

-- ----------------------------------------------------------------------------
-- Email rows, procedures 3, 4
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT CustomerEmailId, CustomerId, BrandId, EmailTypeId, EmailAddress, IsActive, DateCreated
FROM CustomerEmail
WHERE CustomerId = <CustomerId>
ORDER BY BrandId, IsActive DESC, DateCreated DESC;

-- ----------------------------------------------------------------------------
-- Contact number rows, procedures 1, 2
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT CustomerContactNoId, CustomerId, BrandId, ContactNoTypeId, Number, IsActive, DateCreated
FROM CustomerContactNo
WHERE CustomerId = <CustomerId>
ORDER BY BrandId, IsActive DESC, DateCreated DESC;

-- ----------------------------------------------------------------------------
-- Login account rows, procedures 6, 8
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT CustomerAccountId, CustomerId, BrandId, Username, IsActive, DateCreated
FROM CustomerAccount
WHERE CustomerId = <CustomerId>;

-- Is the username contested across the brand? This is what breaks forgot-password.
SELECT CustomerAccountId, CustomerId, BrandId, Username, IsActive
FROM CustomerAccount
WHERE Username = '<username/email>';

-- ----------------------------------------------------------------------------
-- APY BrandId 5 gap, procedure 16
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT CustomerEmailId, BrandId, EmailTypeId, EmailAddress, IsActive, DateCreated
FROM CustomerEmail      WHERE CustomerId = <CustomerId>;
SELECT CustomerContactNoId, BrandId, ContactNoTypeId, Number, IsActive, DateCreated
FROM CustomerContactNo  WHERE CustomerId = <CustomerId>;

-- ----------------------------------------------------------------------------
-- Uploaded file, procedure 7
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT * FROM FileUpload WHERE ApplicationId = <ApplicationId>;

-- ----------------------------------------------------------------------------
-- Transaction, procedure 14
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT TransactionId, ApplicationId, TransactionStatusId, TranAmount, TranDate, Notes
FROM [Transaction]
WHERE ApplicationId = <ApplicationId>
ORDER BY TranDate DESC;

-- ----------------------------------------------------------------------------
-- Open task and PPSR state, procedures 9, 10
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT TaskId, ApplicationId, TaskTypeId, [Status], IsActive
FROM Task
WHERE ApplicationId = <ApplicationId> AND [Status] = 'Open' AND TaskTypeId = 178;

SELECT ApplicationId, IsDischarged, DateDischarged FROM EdxRegistration WHERE ApplicationId = <ApplicationId>;
-- PL/SPL:
SELECT VehicleAssetStatusTypeId, VehicleStatusDate FROM vehicleAsset       WHERE ApplicationId = <ApplicationId>;
-- APY:
SELECT VehicleAssetStatusTypeId, VehicleStatusDate FROM AutopayApplication WHERE ApplicationId = <ApplicationId>;

-- ----------------------------------------------------------------------------
-- Funding records, procedure 15
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT * FROM funding            WHERE applicationid = <ApplicationId>;
SELECT * FROM fundingscheduling  WHERE applicationid = <ApplicationId>;
SELECT * FROM fundingactivity    WHERE applicationid = <ApplicationId>;
SELECT TaskId, TaskTypeId, [Status], IsActive FROM dbo.Task
WHERE ApplicationId = <ApplicationId> AND TaskTypeId IN (65, 77) AND IsActive = 1;

-- ----------------------------------------------------------------------------
-- Roles, tabs, permissions, procedure 13
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT * FROM webpages_Roles ORDER BY RoleId;
SELECT * FROM Tab WHERE TabId IN (<TabIds>);
SELECT * FROM RoleAccess WHERE RoleId IN (<RoleIds>);

-- ----------------------------------------------------------------------------
-- Payment method, procedure 12
-- ----------------------------------------------------------------------------
USE Horizon2;
SELECT ApplicationId, AdditionalDataTypeId, Value
FROM [AdditionalData]
WHERE ApplicationId = <ApplicationId> AND AdditionalDataTypeId = 32;

