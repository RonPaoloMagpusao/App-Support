# Brands, products and entities

The register of MoneyMe brands, products and legal or funding entities, with BrandId values where known and the payment rails each product uses.

Last reviewed: 23 September 2026

Sources: Confluence 3117842457 (Datafix catalogue), 2485059655 (Store Procedures), 2994733113 (G3APIBot How to Teach the Bot, source of the SocietyOne BrandId), 1293647889 (Stage and Status Logs), 3131015188 (Cover Runbook), 942047312 (missing contract), 1079312385 and 1079181314 (Comms, Twilio), 3159327598 (CommsMuteTemplate), 3016032467 (SPV reporting), 519602304 (SQL Data Fix scripts), 1772126209 (Payment Channels), 426082342 (APY Environments); [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 2, 3, 6, 7 and 9; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md); [07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.7.

## Read this first

No Confluence page lists brands, products, entities and their BrandIds together ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.7). This file is assembled from scattered script samples, Slack rulings and Jira prefixes. Every BrandId below says where it came from. Verify against the `Brand` table before relying on one:

```sql
SELECT BrandId, Code, [Description] FROM Horizon2.dbo.Brand WITH (NOLOCK) ORDER BY BrandId;
```

## Brand register

| Brand | Short forms | BrandId | Confidence and source |
| --- | --- | --- | --- |
| MoneyMe | MME | `1` | **Inferred.** Samples use `@BrandId = 1` throughout but never name it (Confluence 3117842457). Slack treats BrandId 1 as MME (Ron, 2026-09-10; [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 3.1). Twilio's custom brand `11` maps to brand 1, MME (Confluence 1079181314) |
| Autopay | APY | `5` | Stated (Confluence 3117842457, 2485059655). `AppSupport_InsertApyContactNEmail` inserts BrandId 5 rows |
| SocietyOne | SOC1, SOC, S1, soc 1 | `6` | Stated once, as the worked example on the G3APIBot teaching page: `@G3APIBot remember: soc1 apps are checked by application brand, brand table, BrandId 6` (Confluence 2994733113). No script sample confirms it |
| OzMoney | MOM | Unknown | Separate brand with separate logins (Confluence 3117842457). Unverified: BrandId. Confirm from the `Brand` table |
| All brands, in `CommsMuteRule` | | `-1` | Confluence 1079312385 |
| All number lines, in `Communication.SpecialSchedule` | | `0` | Confluence 1079181314 |

**Twilio's BrandId is different.** In the `Communication` database each number has a customised brand id whose first digit maps to the Horizon brand, for example `11` maps to brand 1 (Confluence 1079181314). Do not join Twilio brand ids straight to `Horizon2.dbo.Brand`.

### Contradiction: which BrandId does a SocietyOne application need for funding?

- [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 3.1 says BrandId **5** "is the one repeatedly inserted for APY/S1 apps" when funding fails on missing contact rows, and names "APY or S1" apps as the funding blocker case (Albert Rick, Jef Sumarago).
- SocietyOne's BrandId is **6** (Confluence 2994733113, a single example fact on the G3APIBot page).

Funding matches contact rows on the **application's** BrandId (Albert Rick, 2026-08-13). If that is right, an S1 application needs a BrandId 6 row, not 5. Unverified: whether "S1" in those threads means SocietyOne or is shorthand for something else, and whether SocietyOne-originated applications were re-branded to 5 at any point. Confirm by checking `Application.BrandId` on the worked examples (MHD-34560, application 10003052950) before inserting a row.

### Per-brand data you must remember

- Logins are per brand: `CustomerAccount` is keyed on (`Username`, `BrandId`). MME, OzMoney and Autopay logins are separate, so "cannot log in with their email" is often brand confusion (Confluence 3117842457, MHD-35866).
- Contact rows are per brand. A customer who has held MoneyMe, OzMoney and SocietyOne products has separate contact rows for each. MHD-36009: correspondence kept going to the old address for application 10003012512 because the old address was still on the SocietyOne brand contact record ([06-reference/mhd-issue-catalogue.md](../06-reference/mhd-issue-catalogue.md)).
- Convention: one active email row and one active mobile row **per brand** (Ron, 2026-09-10; Confluence 1079312385).

## Product register

| Product | What it is | Brand | Discriminator | Notes |
| --- | --- | --- | --- | --- |
| PL | Personal Loan | MME | `ProductTypeId` | Includes the PL Broker channel |
| PL Broker | Personal loan written through a broker | MME | `ApplicationTypeId = 87003` | Contract generation workflows 1258 / 1259, gated on `PartnershipApplication.StatusId IN (63006, 63007)` (Confluence 942047312) |
| SPL | Secured Personal Loan | MME, SOC1 | `ProductTypeId` | PPSR and vehicle asset tickets carry the `SPL` prefix. Includes SPL Broker and D2C private sale ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7) |
| UPL | Unsecured Personal Loan | SOC1 | `ProductTypeId` | SocietyOne product |
| SACC | Small Amount Credit Contract | MME | | Excluded from PL Broker contract generation (Confluence 942047312). Alternative Offer - SACC stage 64 is no longer in use |
| APY | Autopay secured car and asset finance | Autopay | BrandId 5 | Vehicle data in `AutopayApplication`, `AutopayVehicleDetail`. Partner portal `autopay.com.au` |
| CRD | MoneyMe Credit Card | MME, plus white label | **`ProductId = 111`**, NULL for all other products | Card platform is E6. Card network Mastercard. White label example: Luxury Escapes (template 201265). Use `ProductTypeId` for everything else (Rusty, 2026-09-22) |
| CCC / CRC | Earlier credit card products | MME | | The CCC to CRD migration carried `DisablePaymentSubmission` over and blocked submissions (MHD-34668). Stage register column heading is "CCC/CRC" |
| LOC | Line of credit | MME | | Legacy. "LOC unable to shuffle" and repayments creeping up are design limitations of the old product ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 4). LoC Shuffle Script ran January 2024 to March 2025, then stopped |
| Freestyle (FS) | Line of credit with a virtual card | MME | | See the Freestyle note below |

ProductTypeId values seen in published scripts, meanings not stated: `2190`, `2191`, `3891` (the last set on an APY application in MHD-25045) (Confluence 519602304). Unverified. Confirm from `Horizon2.dbo.ProductType`.

### Freestyle: the sources describe it differently

- [01-systems/README.md](README.md): "Virtual card / EML product" (Confluence 519602304, 456556548). EML holds Freestyle card balances (SQL catalogue item 54: "Freestyle / EML card transaction status wrong", "money missing from Freestyle balance").
- [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7: "The legacy line-of-credit product being migrated to CRD".
- [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md): "Freestyle line of credit (being discontinued)".

These are compatible readings of one product: a line of credit drawn through a virtual card whose balances sit at EML, now being migrated to CRD. There is a second tension: the Cover Runbook names **E6** as "the card issuing platform behind Virtual Cards" (Confluence 3131015188), while the SQL catalogue ties Freestyle card balances to **EML**. Unverified: whether Freestyle virtual cards are on EML, E6, or moved from one to the other. Confirm with the CRD team (`#app-support-crd`).

Freestyle / LOC to CRD migration: weekly batches on **Tuesdays** from mid-2026. Migration emails are sent ahead, with a 21-day opt-out, or opt-in on request (Rusty, 2026-06-17). `AdditionalDataTypeId = 125` is the migration marker; rows are removed when a migration is reversed (Rusty, 2026-07-02). Customers can still see a migrated Freestyle payment schedule showing the wrong amount; Rusty's view is that it should be hidden (2026-05-26).

## Which product uses which rail

See `payments-and-rails.md` for the behaviour of each rail.

| Product | Money out (funding, refunds) | Money in (repayments) | Other platforms |
| --- | --- | --- | --- |
| PL, PL Broker | Zepto via the Payment API | Split Sched, Split Live, Split Auto Retry; card via ECA / app / phone (Eway); Direct Credit | Equifax, Decision Engine |
| SPL | Zepto | As PL | PPSR via EDX / ESIS |
| APY | Zepto. Float cap **$400,000 per 5 minutes** | As PL | PPSR via EDX / ESIS; AutoGrab replacing Glass's Guide |
| SOC1 (SPL, UPL) | Zepto | As PL; stray **BPAY** into the SocietyOne payment account is reconciled but not supported | Salesforce (legacy CRM, `sf_*` columns) |
| CRD | Zepto (refunds); **PayAnyone** for customer transfers | Split Sched; **Debit Card Sched** / Auto Stripe (built for CRD); Direct Credit (default after the CCC migration fix) | **E6** is source of truth for balances and card transactions; Mastercard; allocations overnight off the daily E6 report |
| LOC, Freestyle | Zepto (NPP with EFT fallback; auto credit-back on bounce worked for Freestyle) | Split, Direct Credit | EML card balances; Freestyle Bills Engine |
| Legacy accounts | | Ezidebit (`Ezi Sched`, `Ezi Live`), Direct Debit Auto Retry | |

Debit Card Sched is not CRD-only: Rusty confirmed a non-CRD application running on it and said auto Stripe "can and should work across all products" (`#horizon-collections-team`, 2026-08-26).

## Jira projects that map to products

Summary prefixes carry the product because MHD components are unpopulated ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).

| Key | Name | Product link |
| --- | --- | --- |
| MHD | MME Help Desk | App Support intake. Prefixes `APY`, `CRD`, `MME`, `PL`, `PL Broker`, `Freestyle`, `SOC1` / `SocietyOne`, `SPL`, `LOC` |
| CRD | Credit Card (MME) | CRD defects, for example CRD-2459, CRD-2422 |
| AMZ | Amortization | Schedules and amortisation, for example AMZ-7074, AMZ-10685 |
| APY | Autopay | |
| COL | Collections | For example COL-3475 (Split Sched rejecting on date), COL-4101 (late dishonours) |
| CL | Collection | For example CL-628 (negative outstanding charges on SOA), CL-215 (CRD), CL-516 (fee interest waiver), CL-523 |
| PER | Personal Loan | |
| HOR | Horizon | |
| G1 | Greenfield 1 | Comms API, funding, SPV admin (G1-2762) |
| MMM | MME Mobile | |

### Contradiction: what AMZ means

- [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) and [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7: **AMZ = Amortization** (Amortisation).
- [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 6.1 lists Rusty's areas as "Prod Support, Collections (COL), **Autopay (AMZ)**, Credit Card (CRD)".

AMZ is the Amortization project; the tickets under it (AMZ-7074 amortisation defect, AMZ-10685 bulk shuffle for missing Dealer/Broker Fee) are schedule work. The section 6.1 label reads as a slip, but it may reflect that Rusty owns Autopay schedule issues through AMZ. The Autopay project key is **APY**.

Also note two collections keys exist, **CL** (Collection) and **COL** (Collections). CL did not surface in any MHD link chain in the harvest ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)).

## Legal, funding and trust entities

This is the least documented part of the estate.

| Entity | What the sources say | Source |
| --- | --- | --- |
| SPV (special purpose vehicle) | "SPV 3" cashflow reporting specification and the SPV Tool Revamp (G1-5776) | Confluence 3016032467, TECHNOLOGY sprint pages |
| SPV overnight job | Reads MoneyOut; effects land **the day after**. Newly funded loans will not move warehouse if fees or balances were mis-captured | Limuel Bacay, `#net-devs-only`, 2025-11-10 |
| SPV API | `spv-api-qa.azurewebsites.net` (QA) | [01-systems/README.md](README.md) section 6 |
| SPV database releases | MHD summary prefixes `[SPV - Horizon2 DB]` and `[SPV - TrustFund & Horizon2 DB]` | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md); [03-procedures/README.md](../03-procedures/README.md) |
| Treasury SPV admin permissions | MHD-36622, `[SPV - Horizon2 DB] Release for G1-2762 - Fix Treasury team SPV Admin permission grouping (SpvAdmin grant)`, High, Pending since 2026-09-15 | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| Trust on a transaction | `[Transaction].TrustName` column exists | Confluence 519602304, column list in the MHD-26144 script |
| Spv12 | **Not found.** Does not appear in any Confluence page, Jira text or Slack message read in the harvest | [07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) 4.7; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md) |
| MoneyMe trust | **Not found** as a named entity. `text ~ "trust migration"` returns zero MHD issues. MHD-36446, the ticket once associated with a MoneyMe versus Spv12 distinction, is in fact the AMZ-7074 amortisation defect | [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md), [06-reference/mhd-issue-catalogue.md](../06-reference/mhd-issue-catalogue.md) section 12 |
| MMMFG Autopay Trans | The QA and PROD dealership / customer bank fixture account name (BSB 062104) | Confluence 426082342 |
| MONEYME (BSB 062104) | MoneyMe's own account for customer Direct Credit | Confluence 1772126209 |

Warehouse movement (which funding vehicle a loan sits in) is evidently driven off MoneyOut by the SPV overnight job, and `[Transaction].TrustName` is the only schema hook found. Unverified: the list of trusts or SPVs, how an application is assigned to one, and whether any BrandId or ProductTypeId encodes it. Confirm with Treasury or the SPV Tool owners (G1-5776) and by profiling `SELECT DISTINCT TrustName FROM [Transaction]`.

## Other brand-adjacent terms

| Term | Meaning | Source |
| --- | --- | --- |
| ECA | Self service web payment portal | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7 |
| E6 | External card platform partner. Source of truth for CRD | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7 |
| MMP | Minimum Monthly Payment (CRD) | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 7 |
| ListReady, Lead Sell Platform | Separate product spaces in Confluence (`LST`, `LSP`), low App Support relevance | [06-reference/confluence-index.md](../06-reference/confluence-index.md) |
| Partnerships | Partner and broker channel, `partnership.moneyme.com.au` | [01-systems/README.md](README.md) section 6 |
| White label credit card | CRD issued under a partner brand. Comms suppression handled by `CommsMuteTemplate` (HOR-8583 / HOR-8694, MHD-36342) | Confluence 3159327598 |
