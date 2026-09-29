# SOA generation

Statements of Account that will not generate, will not upload, go to the wrong address, or show wrong figures.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 1, team procedures (Slack) section 8, tribal knowledge (Slack) section 5, MHD open threads 2.3, Confluence 1079312385

193 Problems in the window, consistently 3 to 6 a week (MHD issue catalogue theme 1).

## Symptoms

- "Unable to generate SOA <app id>"
- "SOA won't load"
- "SOA request <app id>" (often with no detail at all)
- "Fix SOA generation loading issue for Application <id>"
- "Manually generate SOA for LOC <id> due to high transaction volume"
- "Generate Statement of Account (SOA) for Application <id>"
- "SOA is being sent to an incorrect email"
- "Not received SOA"
- "Negative 'Outstanding charges' on the SOA"
- "The SOA file will not upload" / "the uploader keeps loading"
- CRD: "The current statement has not been sent yet"

## Triage, in order

1. **Is it CRD?** Then do not use SOA generation at all. Raina Schmidt, `#solutions_memorandum`,
   2026-08-13: *"Please DO NOT use SOA generation (document and email template). The only
   statements that should be used are the ones that are generated monthly and attached to files."*
   Point the reporter at the monthly statement on the Files tab. See
   [crd-credit-card.md](crd-credit-card.md).
2. **Check the account's transaction volume.** Open the application and attempt the SOA from the
   Issue Doc path. The failure presents as an **indefinite spinner, not an error**. Long-running
   Freestyle and LOC accounts with hundreds of rows are the ones that hang (MHD-35957). Angelo Misa,
   2026-07-14: *"dati na issue yan sa Freestyle"*, and CRD will make it worse.
3. **For the wrong-recipient variant, compare the address on the Customer contact record against
   what Issue Doc actually resolves.** The two can differ because contact records are per brand
   (MHD-35314). Go to [customer-and-company-data.md](customer-and-company-data.md).
4. **For an upload that fails, check the file size.** The limit is now 30 MB. Oversized files are
   rejected at selection with exactly `File size is exceeding to its limit 30 mb` (HOR-8167). If the
   uploader just hangs with no message, that is HOR-8183.
5. **For negative "Outstanding charges", check `PaidChargeAmount` against `TotalChargeAmount`** on
   the account's charges. Where paid exceeds total, it is CL-628 (team procedures (Slack) 8.4).
6. **If comms are backing up generally**, check `#comms-daily-check`. The SOA template is the most
   common cause of a stuck messaging queue: too many records, attachment not found, merge tag query
   errors (Confluence 1079312385). See [email-delivery.md](email-delivery.md).

## Root causes seen

1. **Transaction volume.** High-transaction accounts, particularly Freestyle and LOC, time out
   during generation. MHD-35957 states this explicitly.
2. **File size.** The generated SOA exceeded Horizon's old 10 MB upload ceiling. HOR-8167 was raised
   proactively: *"The Statement of Account (SOA) file size is expected to increase significantly due
   to the implementation of CRD and higher transaction volumes. This was previously an issue in the
   Freestyle project."*
3. **Stale or brand-mismatched contact record** sending the SOA to a superseded address (MHD-35314,
   PL 10001616803).
4. **Charges where `PaidChargeAmount` exceeds `TotalChargeAmount`**, producing a negative
   outstanding charges line (CL-628).
5. **Multiple sends of the SOA email.** The 60-second timeout or 70-second queue time is reached,
   mostly on SOA templates with attachments where the attachment is not found
   (Confluence 1079312385).

## The fix

| Root cause | Action |
| --- | --- |
| Transaction volume, generation hangs | **No fix, workaround.** App Support generates the SOA manually with a script outside Horizon and attaches it to the Jira ticket or the Horizon Files tab. Performed dozens of times a month. Typical turnaround under two hours: MHD-35789 raised 10:01, delivered 11:51; MHD-35850 raised 09:15, delivered 09:41 |
| File too large to upload | **No action** if under 30 MB, it now uploads. Over 30 MB, **escalate** to the Horizon team |
| Wrong recipient | **Datafix** to the contact record under the monthly umbrella ticket (MHD-35314, closed same day) |
| Negative outstanding charges | **Escalate** to Rusty (Josh Allen). Individual accounts are being fixed manually. Lary Rosario, 2026-09-18: *"yung account na yan inayos na ni Rusty kahapon"* |
| SOA clogging the comms queue | **Escalate** to Lary Rosario, who may stop or fix the sending in the workflow (Confluence 1079312385) |

**The manual generation workaround needs the unmask permission on the database.** Ron requested it
from Jeffrey Lu on 2026-08-21 so Victor Alvarez could grant it (team procedures (Slack) 8.2).

**Always attach the caveat when you send a manually generated SOA.** Ron's wording:

> "attached the SOA you requested in the ticket. Please review the file before sending since we used
> a different method because the current tool is broken. Please double check the data."

The ticket-level instruction is the same: "please check the file before sending to the customer"
(MHD issue catalogue theme 1).

### The upload limit change, for reference

HOR-8167, MHD-34644 and MHD-36453 raised the Horizon upload limit from 10 MB to 30 MB.

- Config-driven `appSetting FileUploadSizeLimitInMB = 30`, plus `web.config maxAllowedContentLength`
  at 35 MB, because 30 MB exceeds the roughly 28.6 MB IIS default.
- A client-side pre-check rejects oversized files at selection instead of hanging.
- **The IIS limit was raised site-wide**, so it affects the Visa, Bank Recon and Campaign Dialer
  upload screens too. Sanity-check those after any related release.
- QA passed 2026-08-06 (Jeric Mislang). Ron passed UAT on Integration 2026-09-09: 25 MB uploaded,
  30.2 MB uploaded, 31 MB correctly rejected. Prod test passed 2026-09-10 on application
  10003089519.

**The sources disagree on the requested size.** team procedures (Slack) 8.3 records the request, Ron on
2026-07-14 endorsed by the CTO, as "at least 20MB". The Jira chain shipped 30 MB. The delivered
value is 30 MB.

## Not a defect

- **CRD statements not produced by SOA generation.** By instruction, CRD uses only the monthly
  statements attached to files (Raina Schmidt, `#solutions_memorandum`, 2026-08-13).
- **An indefinite spinner with no error.** That is how the volume failure presents. It is the known
  defect, not a new one, so go straight to manual generation.

## Precedents

- MHD-35957: states the transaction-volume cause explicitly.
- MHD-35789: application 10000620227, generated manually, 1 hour 50 minutes.
- MHD-35850: application 10000700299, "SOA won't load", 26 minutes.
- MHD-35314: PL 10001616803, SOA via Issue Doc went to a different address than the one on file.
- MHD-36803, MHD-36710, MHD-36398, MHD-36635, MHD-35742, MHD-35718, MHD-35499, MHD-35511,
  MHD-35449, MHD-35315, MHD-35333, MHD-36047, MHD-36152, MHD-36157, MHD-36074, MHD-35953,
  MHD-35894, MHD-35899, MHD-35700, MHD-35326: further generation requests.
- MHD-36345: application 10003039272, current statement not yet sent. Root cause not verified.
- HOR-8167, HOR-8170, HOR-8183, MHD-34644, MHD-36453, QAAUTO-1845, QAAUTO-1992: the upload limit
  chain.
- CL-628: negative outstanding charges.

## Open defects

- **SOA generation itself is broken on high-volume accounts and has no fix ticket.** Every instance
  is worked around by hand. The upload change addressed storage, not generation.
- **The system-generated SOA email ceiling.** Out of scope for HOR-8167 and still open. SendGrid caps
  attachments at roughly 30 MB, so a 30 MB SOA will still fail to email. Flagged by John Mark
  Gabriel on HOR-8167 on 14/07/2026 and **never given a ticket**. The problem the upload change was
  meant to solve is only half solved.
- **HOR-8183**, the shared uploader shows no error and hangs ("keeps loading") on failed uploads.
  QA Ready.
- **MHD-34644**, the 30 MB parent, Selected for Development. The code shipped and the parent was
  never closed.
- **CL-628**, correct accounts where `PaidChargeAmount` exceeds `TotalChargeAmount`. Open,
  individual accounts fixed manually.
- **MHD-29121**, "File upload issue, 10002422996", Selected for Development, 280 days as at harvest.
