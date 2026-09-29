# Escalation map

Who owns what, who decides, and who to tag where.

Last reviewed: 23 September 2026
Sources: Slack tribal knowledge section 6, Jira MHD people notes, Confluence Tech and Product Team Directory (3 sources, merged)

## Ownership seen in Slack

### Product and decision authority

| Area | Owner |
| --- | --- |
| Prod Support, Collections (COL), Autopay (AMZ), Credit Card (CRD), product decisions, "is this a defect" | **Rusty (Joshua Allen)**, `UT2FPML2E`, Product Owner |
| Ops announcements | `#solutions_memorandum`: Rusty, **Raina Schmidt**, **Rebecca Sampson (Bec)**, **Ethan Campbell**, **Joanne Nguyen**, **Alexis Beaini** |
| Complaints / IDR escalation | **Raina Schmidt**; APR-increase complaints have their own Confluence path |
| Customer retention escalation | `#customer-retention` |

### Technical ownership

| Area | People / channels |
| --- | --- |
| **Horizon core, transactions, payments backend** | **Christopher "Tops" Enriquez** (`U03EBB5EZ6W`), **Harvey Dacutanan** (`UFZ9WDNCS`). Rusty routes the hardest Horizon calculation questions to Tops. |
| **Funding** | **Albert Rick Martires** (`U03B04FUGDS`, Senior .Net Dev, Team Lead, G3 Engineering). Channels `#pending-funding-checks`, `#app-support-funding`, `#funding-dev-qa-supports`, `#funding-issues`, `#horizon-funding-team` |
| **Horizon task closure / funding ops** | **Gabriel Pavlovic** (`UKWGXS8HW`), **Jamie Nguyen** (`UFZ93UAQ3`) |
| **Refunds (Ops side)** | **James Wiles (Jim)** (`UG189BF6K`), **Raina Schmidt** |
| **CRD / card platform** | `#app-support-crd`, `#crd_firefighters`. **Mhars Pabalan**, **JD**, **Marydel (Madel) Gutierrez**, **Ken** |
| **Card network / Mastercard / E6 transaction forensics** | **Murdo** (`U0A82563ZLG`). Rusty: *"He is the final boss of CRD transactions."* Mastercard admin access is held by **Julius Serrano**. |
| **Comms, Twilio, SendGrid** | **Hazelrey Cate Erasmo (Haze)** (`U03P4GSSZEX`), **Dave** (`U03DLN91T0A`). Channels `#twilio-team`, `#app-support-twilio-comms`, `#twilio-tech-app-support`, `#twilio-tech-ops-workgroup`, `#comms-fixing` |
| **Mobile app** | `#app-support-mobile-team`, **Aus** (`U03N4MVJRMM`) |
| **Amortisation** | **Jess Leal**, `#amortization-app-support` |
| **SQL / datascript execution** | **Victor Anthony Alvarez** (`U04D4F52Y7J`), **Maria Krizza Rosales** (`U03SM7YL3K7`); urgent escalation **meghashree (Megha)** (`U01GN5N1DQF`, Decision Intelligence) |
| **Decision Engine / credit policy (PL)** | **Ethan Campbell**, **Joanne Nguyen**, **Ulysses Consador**, **Alyssa (Aly) Ventura**, **Marvin Martin** |
| **Autopay / car loans product** | **Rebecca Sampson (Bec)**, **Jef Sumarago**, **Hayley Smith**, **Denmark (Den) Gadia**, **EJ** |
| **Platform / G1 / G3 / API** | **Julius Serrano** (`UG0BMPC87`), **Daryll Felipe**, **Ricky Buenavista**, **John Mark Gabriel (JM)**, **Limuel Bacay (Awel)** |
| **App Support (this team)** | **Ron Paolo Miguel Magpusao** (`U061GPUSFH6`), **Michael Dela Torre** (`U04PC31NNLS`), **Lary Rosario**, **Aina Kristina Dilao** |
| **CAB approvals for releases** | `#tech-cab-approval-followups`: **Jon** (`UFZHH7CD6`), **Julius**, **Fred**, **Jeffrey Lu** |
| **Database permissions (unmask etc.)** | **Jeffrey Lu** (`UFZLL4G1F`) approves; Victor grants |
| **Sentry team admin** | Ron and Michael hold Team Admin at `societyone.sentry.io/settings/teams/mme/members/` |

### Access notes

- **E6 and Mastercard logins**: App Support does not have them. Rusty,
  2026-09-22: *"We could get you logins to E6 and Mastercard, but I don't think
  it's beneficial, yet."* Mastercard admin is Julius. For E6 updates, ask
  **Mhars** how he does it.
- If it is not in Horizon, App Support cannot see it. Ask Murdo to check
  Mastercard.

---

## People seen in MHD tickets

Internal MoneyMe staff, from ticket threads. Customer and broker names have been removed.

| Name | Role as it appears in the tickets |
| --- | --- |
| **Josh Allen**, referred to as **"Rusty"** | The standing authority on amortisation, schedules, Freestyle and payment allocation. Tickets escalated "to Rusty" come back with a comment from Josh Allen. His word is generally final on whether a defect will be fixed. Quotes worth keeping: "your workaround is the only option we have in this case" (MHD-30258), the arrears arithmetic on MHD-35381, the LOC first-payment workaround on MHD-36270 |
| **Ron Paolo Miguel Magpusao** | App Support. Writes the long-form investigations |
| **Michael Dela Torre** | App Support. Handles the largest share of day-to-day Problem triage |
| **Jess Leal** | Amortisation. Owns the four-step Zepto execution plan |
| **Christopher Enriquez** | Collections scripts. "Please run this before the amortization scripts" |
| **John Mark Gabriel** | Horizon development. Owned the HOR-8167 upload limit change |
| **Jeric Mislang**, **Ricky**, **Dominic Austin Sicat**, **Reynard Prudente** | QA |
| **Paul LV Jain** | Mobile engineering. Authored the `DurationInYears` RCA |
| **Jonathan Flack** | Collections. Reports stage-transition failures and moves stages manually |
| **Jason McGuire** | Approves fee waivers |
| **Simon Stefanovski** | Collections. Raises the Zepto bulk dishonour batches |
| **Tops** and **Harvey** | Fixed the stuck-Proposed payments on MHD-34293 |
| **John Garcia** | Assignee on the Defender threat intelligence feed |

Reporters who appear frequently, mostly collections and operations: Ma. Shiela Unay, Julieve Gata, Daralyn Ramos, Gracely Lubrido, Jerric Elefanio, Sarah Jane Suriaga, Jocelyn Alfonso, Deidra Alfred, Charmaine Bardaje Olaguer, hedrina macapagal, Ma. Mercedes Alvarez, Mark Anthony Mallari, Villa Angao, Maria Kriselle Catacutan, Archie Abarra, Joy Origenes, Ireen Monel, Michael Ronel Adano, Panayiotis Skrepetos, juan.bernardo, alreyanne.bolneo, cipriano.infante, Jennyfer Reyes, ishmaiah.

---

## Directories

- Full Tech and Product Team Directory: [../06-reference/confluence-mirror/](../06-reference/confluence-mirror/README.md) (page 32).
- Rusty's scope and what he does not own: [rusty-rulings.md](rusty-rulings.md).
