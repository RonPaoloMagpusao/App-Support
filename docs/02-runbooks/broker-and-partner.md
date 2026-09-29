# Broker and partner

Broker and dealer issues: agreements and settlement emails that do not reach them, portal problems, logins, documents, lead source and commission.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 11, team procedures (Slack) section 9, Confluence 3131015188 section 10, Confluence 3117842457 Part 2b, Confluence 942047312

110 Problems in the window (MHD issue catalogue theme 11). Broker and Autopay operations intake
is `#autopay_feedback`, channel ID `C03DYRHJ1C6`. `#apy-partner-feedback` exists for non-urgent
partner product feedback and explicitly redirects urgent items to `#autopay_feedback` or
`#app-support` (team procedures (Slack) 9).

## Symptoms

- "Loan agreement not sent to the broker"
- "Investigate missing settlement emails for application <id>"
- "The dealer got the settlement emails twice"
- "Investigate Contract Sending Failed - <app id>"
- "Broker portal stuck on 'calculating your finance details'"
- "Move broker applications from inactive to active login"
- "[APY] [UP TO <date>] Broker uploaded incorrect documents on customers file"
- "Transfer applications <id> and <id> to another broker"
- "Update dealership lead source - <app id>"
- "Can I please request a data fix on the {field} field on this application to show '{value}' instead of N/A"
- "Find root cause so this doesn't happen again" plus "instructions on how to fix this application"
- "Broker commission paid to the wrong bank" / "broker fee wrong"
- "Invalid Funding BSB Format" on a dealer or broker commission bank
- "Manually add a broker user in S1"
- "Blacklist this car dealership"
- "Broker not receiving the password reset OTP"

## Triage, in order

1. **For anything that did not reach the broker, check the Tasks tab for Review - Contract Sending
   Failed.** Clear it first. Michael Dela Torre: *"There will be additional info in Notes, if the
   error message is about mobile or email, we should let the agent fix it first"* (MHD-32267).
2. **Then check SendGrid for the broker's address.** Broker addresses land on the Bounces list like
   anyone else's (MHD-29993). See [email-delivery.md](email-delivery.md).
3. **For a contract that never generated on PL Broker**, check `ApplicationTypeId = 87003`,
   `PartnershipApplication.StatusId IN (63006, 63007)`, and whether `WorkflowId` 1258 or 1259 has a
   row in `ApplicationWorkFlow` (Confluence 942047312). See
   [application-stuck-at-stage.md](application-stuck-at-stage.md).
4. **For duplicate settlement emails, compare the send timestamps against Fund Sent.** On MHD-36668
   the originals fired three minutes after Fund Sent and the duplicates 61 days later with no stage
   change.
5. **For the portal hanging on "calculating your finance details", check `IsEditedVehicleDetails`**
   on the application. It should not be 1 on a pre-approval application (MHD-35818).
6. **For an Autopay field correction request, ask for the root cause as well as the fix.** Bec's
   standard two-part ask (2026-09-04) is "find root cause so this doesn't happen again" and
   "instructions on how to fix this application". Answer both.
7. **For a commission funding failure, read the BSB message.** A leading space in
   `CommissionBank.SortCode` is a datafix; an AusPayNet rejection is not (MHD-35359). See
   [funding-and-disbursement.md](funding-and-disbursement.md).

## Root causes seen

1. **Uncleared Review - Contract Sending Failed task.** MHD-32267, application 10002867333, MME PL
   Broker, email template 2146, funded 24/04/2026 16:57. The agreement should have gone the same
   day.
2. **Comms engine re-fire of settlement emails.** MHD-36668, application 10003015808, customer and
   external dealer both received the identical pair again at 16/09/2026 04:05, inside the nightly
   comms window. Mechanism unconfirmed.
3. **`IsEditedVehicleDetails` incorrectly set to 1** on a pre-approval application (MHD-35818,
   application 10003059392).
4. **Applications attached to an inactive broker login** (MHD-36263).
5. **Broker uploading the wrong documents** to a customer file. Recurring enough to be raised as a
   scheduled clean-up (MHD-36154, MHD-35691, MHD-35112).
6. **SortCode saved with a leading space** on the commission bank, `LeadSourceId` 8187
   (MHD-35359).

## The fix

| Root cause | Action |
| --- | --- |
| Contract Sending Failed task | **Config change**, clear the task after the agent fixes any contact error it names |
| Settlement emails re-fired | **Escalate** to the Comms team with timestamps. Reopen MHD-36668 rather than raising a new ticket, as Ron asked on closure |
| Missing settlement emails | **Escalate** after checking tasks and SendGrid (MHD-35193, MHD-33293) |
| `IsEditedVehicleDetails` stuck at 1 | **Datafix**, reset the flag under the monthly umbrella (MHD-35818) |
| Inactive broker login | **Datafix**, move the applications to the active login (MHD-36263) |
| Wrong documents uploaded | **Datafix**, `AppSupport_DeleteFileUpload @ApplicationId, @FileUploadId`. **Irreversible.** `SELECT * FROM FileUpload WHERE ApplicationId = <ApplicationId>` first, identify the wrong file positively, and keep the full output: it is the only record of what was there (Confluence 3117842457) |
| Transfer between brokers, wrong broker | **Datafix**, raw script territory, parent page item 39 (MHD-35200) |
| Lead source, referrer, risk band or product type wrong on an APY application | **Datafix**, raw script territory, parent page items 49, 71, 80 (MHD-35305, MHD-36653, MHD-36686) |
| Commission, broker fee or establishment fee wrong, commission to the wrong bank | **Datafix**, raw script territory, parent page items 10, 23, 93, 96. Item 96 declares the same backup table name twice, so the second throws and the write proceeds unbacked; its verification comments also disagree with the values the code sets. Fix the backup before using it |
| Remove dealership bank details | **Datafix**, parent page items 3, 85, 98. Item 85 is interim pending a dev fix; check whether the release has landed |
| Commission SortCode with a space | **Datafix**, strip the space in `Horizon2.dbo.CommissionBank`, then ask Ops to complete the task. Jeff Lu loads this data |
| Blacklist a dealership | **Datafix**, parent page item 78 |

Owners in `#autopay_feedback`: **Rebecca Sampson (Bec)**, **Jef Sumarago**, **Hayley Smith**,
**Denmark (Den) Gadia**, **Ulysses Consador**, **EJ**, **Dominic Uy** (team procedures (Slack) 9). Parent
page is SQL Data Fix scripts, Confluence 519602304. Templates in
[../04-sql/datafix-templates/](../04-sql/datafix-templates/).

## Not a defect

- **Delays on public holidays in the Philippines.** The AU side posts a heads-up when the PH team is
  out, "There is a PH in the Phillipines today, so there may be delays" (team procedures (Slack) 9).
- **A broker address bouncing after its suppression was removed.** If the mailbox is genuinely dead
  it will re-bounce. Michael Dela Torre warned exactly that on MHD-29993.

## Precedents

- MHD-32267: loan agreement template 2146 never sent to the broker, application 10002867333.
- MHD-35658: Contract Sending Failed, application 10003050872.
- MHD-35193, MHD-33293: missing settlement emails to broker and customer.
- MHD-36668: duplicate settlement emails to an external dealer, application 10003015808.
- MHD-36263: broker applications moved from an inactive to the active login.
- MHD-36154, MHD-35691, MHD-35112: scheduled clean-up of incorrect broker uploads.
- MHD-35200: applications 10002890830 and 10002861918 transferred to another broker.
- MHD-35305, MHD-36653, MHD-36686: lead source and dealership updates.
- MHD-35818: broker portal stuck on "calculating your finance details", application 10003059392.
- MHD-35359: commission bank SortCode with a leading space.
- MHD-29993: broker address on the SendGrid Bounces list.
- MHD-31255, MHD-36467, MHD-36442: broker OTP reset, manual broker user in S1, dealer bank account
  deletion. Root cause not verified.

## Open defects

- **MHD-27683**, "Lead source syncing for new broker accreditations", WORK IN PROGRESS since
  24/10/2025, nearly a year.
- **The `IsEditedVehicleDetails` flag keeps being set incorrectly.** MHD-35818 asked for a permanent
  fix to how the flag is set; a datafix closed it and the permanent fix was never delivered. Expect
  it to recur (Confluence 3131015188 section 10).
- **MHD-36668** closed without identifying the job that re-sent settlement emails, or whether other
  applications and dealers were affected.
- **Incorrect broker uploads keep recurring.** They are cleaned up as a periodic batch (cut-offs of
  27/07, 14/08 and 27/08/2026 in the window); no ticket addresses why brokers can upload to the
  wrong customer file.
