# Login datafix scripts

Raw SQL for customer login and account investigation and fixes.

Last reviewed: 23 September 2026
Sources: Confluence AS page 1398210569, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1398210569 · Last updated: 13 Mar 2025 · Author: Michael Dela Torre
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1398210569/Common+Login+SQL+Data+Fix+Scripts
- Contributors: Michael Dela Torre, Ron Paolo Miguel Magpusao · Reviewer: Julius Serrano · Team: Application Support

## 1. Check the application / account for common issues, the key diagnostic

The single most useful diagnostic in the tree. One ApplicationId in; Application and Brand,
every `CustomerAccount` row, every `CustomerContactNo` and `CustomerEmail` row, plus a fuzzy
username join that surfaces sibling customers sharing the email.

```sql
USE Horizon2
-- Check LID / Customer Account
DECLARE @CurrentCustomerId bigint, @TestApplicationId bigint, @CurrentBrandId int, @CurrentEmail varchar(255)
-- Insert ApplicationId on the line below
SELECT TOP 1 @TestApplicationId = ApplicationId FROM [Application] WHERE ApplicationId = <ApplicationId>
SELECT TOP 1 @CurrentBrandId = BrandId FROM [Application] WHERE ApplicationId = @TestApplicationId
SELECT a.CustomerId, a.ApplicationId, a.BrandId, b.Code, b.Description FROM [Application] a
JOIN [Brand] b ON a.BrandId = b.BrandId WHERE ApplicationId = @TestApplicationId
SELECT TOP 1 @CurrentCustomerId = CustomerId FROM [Application] WHERE ApplicationId = @TestApplicationId
SELECT TOP 1 @CurrentEmail = Username FROM [CustomerAccount] WHERE CustomerId = @CurrentCustomerId
SELECT CustomerAccountId, BrandId, CustomerId, Username, IsActive, DateCreated, CreatedByUserId,
       LastLoginDate, LastLoginIp, LastLoginAttemptDate, IsMobileVerified, IsPINChanged, *
FROM CustomerAccount WHERE CustomerId = @CurrentCustomerId
SELECT IsActive AS IsContactActive, CustomerContactNoId, CustomerId, BrandId AS ContactBrandId,
       Number, DateCreated AS ContactDateCreated, Invalid
FROM CustomerContactNo WHERE CustomerId = @CurrentCustomerId
SELECT IsActive AS IsEmailActive, CustomerEmailId, CustomerId, BrandId AS EmailBrandId,
       EmailAddress, DateCreated AS EmailDateCreated
FROM CustomerEmail WHERE CustomerId = @CurrentCustomerId
SELECT TOP 100
c.isActive, c.CustomerId, ce.EmailAddress, ce.BrandId,
ca.Username username, ca.BrandId AS accountBrand, ce.isActive AS emailIsActive,
ccn.Number, ccn.isActive AS ContactStatus, c.isTest, ccn.*
FROM Customer c
LEFT JOIN CustomerEmail ce ON c.CustomerId = ce.CustomerId
LEFT JOIN CustomerContactNo ccn ON c.CustomerId = ccn.CustomerId
LEFT JOIN CustomerAccount ca ON ca.CustomerId = c.CustomerId
WHERE username LIKE '%' + @CurrentEmail + '%';
```

## 2. MME mobile number is not updated

```sql
USE Horizon2
SELECT * INTO CustomerContactNo_MHD16174 FROM CustomerContactNo WHERE CustomerId = <CustomerId>
UPDATE CustomerContactNo SET Number = '04XXXXXXXX' WHERE CustomerContactNoId = <id> AND CustomerId = <CustomerId>
SELECT * FROM CustomerContactNo WHERE CustomerId = <CustomerId>
```

## 3. MME account is not active

```sql
USE Horizon2
SELECT * INTO CustomerAccount_MHD18513 FROM CustomerAccount WHERE CustomerId = <CustomerId>
UPDATE CustomerAccount SET IsActive = 1 WHERE CustomerId = <CustomerId> AND CustomerAccountId = <id>
SELECT * FROM CustomerAccount WHERE CustomerId = <CustomerId>
```

## 4. MME account has a duplicate

Determine the duplicate by checking both accounts and seeing which is the latest. Rename the
loser rather than deleting it.

```sql
USE Horizon2
SELECT * INTO CustomerAccount_MHD14526 FROM CustomerAccount WHERE CustomerId = <CustomerId>
UPDATE CustomerAccount SET Username = 'customer@example.com_duplicate'
WHERE CustomerAccountId = <id> AND CustomerId = <CustomerId>
```

## 5. No MME account active

Note: this item omits `CustomerAccountId` from the WHERE clause, so it rewrites every brand row
for that customer. Prefer `AppSupport_UpdateCustomerAccount`.

```sql
USE Horizon2
SELECT * INTO CustomerAccount_MHD16167 FROM CustomerAccount WHERE CustomerId = <CustomerId>
UPDATE CustomerAccount SET IsActive = 1 WHERE CustomerId = <CustomerId>
UPDATE CustomerAccount SET BrandId = 1 WHERE CustomerId = <CustomerId>
```

## 6. Account details in the Customer tab are N/A; create an account directly in the DB

```sql
USE Horizon2
INSERT INTO CustomerAccount (CustomerId, BrandId, Username, Password, IsActive, DateCreated, CreatedByUserId)
VALUES ('<CustomerId>', '1', 'customer@example.com',
        '[CREDENTIAL REDACTED - see Confluence page 1398210569]', 1, GETDATE(), 1);
```

## 7. MME email address is not updated

```sql
USE Horizon2
SELECT * INTO CustomerEmail_MHD18403 FROM CustomerEmail WHERE CustomerId = <CustomerId>
UPDATE CustomerEmail SET EmailAddress = 'customer@example.com'
WHERE CustomerEmailId IN (<ids>) AND CustomerId = <CustomerId>
SELECT * FROM CustomerEmail WHERE CustomerId = <CustomerId>
```

## 8. Merge account

```sql
USE Horizon2
-- Backup
SELECT * INTO Application_MHD20463 FROM [Application] WHERE ApplicationId = <ApplicationId>
-- Update
UPDATE [Application] SET CustomerId = '<CustomerId>' WHERE ApplicationId = <ApplicationId>
-- Testing
SELECT * FROM [Application] WHERE ApplicationId = <ApplicationId>
```

---
