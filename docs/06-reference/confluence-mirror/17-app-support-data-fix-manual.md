# App Support - Data Fix Manual

Mirror of the Confluence page "App Support - Data Fix Manual".

Last reviewed: 23 September 2026
Sources: Confluence AS page 498401800, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 498401800 · Last updated: 12 Jan 2024 · Author: Michael Dela Torre
- Contributors: Michael Dela Torre, Anna Paulene Pascual, Ron Paolo Miguel Magpusao
- Reviewer: Julius Serrano · Team: Application Support
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/498401800/App+Support+-+Data+Fix+Manual

## [App Support] Update a field from Horizon Web

Update field requests arrive via Jira ticket. Read and analyse the description. Worked example:
"offer" in a ticket means `OfferedAmount` in the Horizon2 database.

```sql
USE Horizon2
SELECT * FROM [Application] WHERE ApplicationId = <ApplicationId>
```

Check whether the application funds have been sent. If not, proceed. Find the `OfferedAmount`
column and confirm the amount still needs updating.

```sql
USE Horizon2
SELECT * INTO Application_MHD12195 FROM [Application] WHERE ApplicationId = <ApplicationId>
UPDATE [Application] SET OfferedAmount = '<amount>' WHERE ApplicationId = <ApplicationId>
```

If the backup table already exists, the page gives a long `SET IDENTITY_INSERT ... ON` /
`INSERT INTO Application_MHD12195 (<full column list>) SELECT <full column list> FROM ...` /
`SET IDENTITY_INSERT ... OFF` pattern before the UPDATEs. The full `Application` column list as
published on this page is a useful schema reference in its own right:

```
ApplicationId, BrandId, CustomerId, LeadSourceId, ApplicationAddressId, ApplicationBankId,
EmploymentId, ApplicationReferenceId, RequestedAmount, OfferedAmount, FundedAmount, FullAmount,
MonthlyFee, EstablishmentFee, TotalInterestAmount, TotalChargeAmount, CurrentBalance,
ProductTypeId, PaymentCount, Duration, StatusId, EngineResultTypeId, DeclineReasonId, Reason,
ReasonDetailed, FundedDate, ArrearsLevelId, ArrearsStandingId, OutstandingBalance, HistoricAB,
CurrentAB, ArrearsBalance, DishonourFee, ContractStartDate, ContractEndDate, CampaignId,
VerificationCode, LoanType, ApplicationDate, EzidebitAccountId, SplitAccountId, DateCreated,
CreatedByUserId, RepaidDate, PaidInterestAmount, PaidPrincipalAmount, PaidChargeAmount,
FeeReversal, BrokerCode, IsMigrated, SettlementAmount, TotalExtraFunds, PaidExtraFunds, Excess,
PaidEstablishmentFee, PaymentABDPerc, DebitCardAccountId, PaymentStartDate,
TotalAccountKeepingFee, PaidAccountKeepingFee, TotalEstablishmentFee, TotalOtherFee,
PaidOtherFee, TotalAnnualFeeAmount, PaidAnnualFeeAmount, TotalWithrawalAmount,
MigratedAndProcessed, PropertyAddressId, HasVirtualCard, CanRedraw, IsPostPay, WithCustomer,
AidenResultId, CardActivationRequestDate, TotalGstFee, PaidGstFee, CommencementDate,
IsPdfStatement, PdfStatementSubmissionReasonId, IsPropertySold, ExpectedSettlementDate,
IsPropertyWithdrawn, PropertyWithdrawnDate, DisableAccountKeepingFee, DisableAnnualFee,
IsRefinance, RefinanceId, ExpectedMonthlyRental, MerchantFeeAmount, PaidMerchantFeeAmount,
TotalAdminFee, PaidAdminFee, WriteOffTypeId, DisableArrearsCapture, PaidBrokerFee,
DisablePaymentSubmission, ApplicationTypeId, TotalBrokerFee, EwayAccountId,
ContractVariationDate, InterestRate, BrokerFee, RequestedDuration, RequestedProduct,
VehicleAssetId, OriginTypeId, OverdueStartDateTime, PartnerUserId, Commission, ApplicationGUID,
IsMmeStaff, CRN, ArrearsBalanceV2, HasVerifierConsent, OriginallySPL, ArrearsBalanceV1,
CloseOnRepaid, SecondReviewerId, ProductProfileId, IsFirstTimeBorrower, IsLearnerDriver,
ProductId, sf_loanid, sf_customerid, sf_applicationaddressId, sf_ApplicationBankId,
sf_EmploymentId, sf_userid, sf_applicationid
```

Backup table naming is situational: name it after the Jira ticket for easier tracking. As best
practice send the SQL script to Julius first for approval before updating the Jira ticket. Once
approved on Slack, save and name it `Update <ApplicationId>`.

## Change Request ticket fields

| Field | Value |
| --- | --- |
| Project | MME Help Desk (MHD) |
| Issue type | Change Request Data Fix/External with... |
| Summary | Data Fix for `<Requestor>` |
| Urgency | Medium |
| Data fix reason | Lack of Feature |
| Additional information | Can't edit `<field>` |
| Database Affected | Horizon2 |
| Priority | Medium |
| Approvers | Jeffrey Lu, Jonathan Wu |
| Impact | Minor/Localized |

After submitting, screenshot the important fields in Horizon Web before implementing the change.

**Implementation plan:** the approved SQL script, commented on the ticket as an Internal Note.

**Test plan:** e.g.

```
Check the <updated field> of the application in Horizon Web and the database
(select <updated field>, * from Application where ApplicationId = <id>)
```

**Rollback plan:** e.g.

```
Please run the sql script:
use Horizon2
select <updated field>, * from Application_MHD<id>
---
Check and copy the value of <updated field>, see attachment "Before implementation <AppId>.png"
---
Run sql script:
use Horizon2
update Application set <updated field> = '<value>' where ApplicationId = <id>
```

Set the ticket status to **Change Approval** and ask for approval in the Slack channel
**#tech-cab-approval-followups**, tagging **Jeffrey Lu** and **Jonathan Wu**.

If the ticket came from Julius, ask for approval directly in **#datascript-requests**, tagging
**Victor Alvarez** and/or **Krizza Rosales**. They reply when the script has been executed.

---
