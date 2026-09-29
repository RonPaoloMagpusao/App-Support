# Email delivery

Emails that fail, bounce, go to the wrong address, arrive empty, arrive twice, or never arrive.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 2, team procedures (Slack) section 7.1, tribal knowledge (Slack) sections 1, 5, 9, Confluence 3131015188 section 06, Confluence 3117842457 Part 1, Confluence 1060864395, Confluence 1079312385

602 Problems matching `SendGrid OR bounced OR email`, the single largest theme (MHD issue catalogue
theme 2). The SendGrid suppression recipe is the single most repeated fix in `#app-support`.

## Symptoms

- "Investigate in Sendgrid - <app id>" (a near-weekly standing request)
- "550 No Such User - <app id>"
- "Email keeps failing <app id>"
- "Email status shows 'Failed' despite correct email on file"
- "Not receiving email"
- "Email Bounced Multiple times yesterday"
- "Email reverting to old email address" / "Old Email Still Pop Up after updating with new one"
- "The passcode reset email is empty"
- "Investigate delayed settlement confirmation emails"
- "Customer and dealer got the settlement emails twice"
- "Customer received the same message multiple times"
- "The email shows boxed question marks"
- "Wrong template, wrong merge tag, wrong wording in the email"

## Triage, in order

1. **Is the recipient on DNC in Horizon?** If yes, that is the answer (Michael Dela Torre,
   `#app-support`, repeatedly; Confluence 546701313, MHD-18891).
2. **Open Communication / Application Comms**, `/Communication/ApplicationComms/<appId>`. **The list
   view caps at 21 rows; click Load More.** On MHD-36668 the full history was 33 rows and the
   missing rows were the point of the ticket. Check send status per message (Open, Delivered,
   Failed) and the template ID.
3. **Look the address up in SendGrid.** Activity tab to see every send to the address, then
   **Suppressions**, especially **Bounces** (Confluence 1060864395). App Support cannot see
   suppression status from Horizon at all today. The lists that matter are Bounced, Blocked and
   Spam Reports. Global and Group Unsubscribes mean the customer unsubscribed. Invalid means the
   address is invalid or does not exist (Confluence 1079312385).
4. **Read the bounce reason.** The two seen repeatedly are `550 no such user here` and
   `user unknown`, meaning the mailbox does not exist. Removing the suppression will not make a
   non-existent mailbox work (team procedures (Slack) 7.1).
5. **If the ticket says the address was already updated, stop and switch runbooks.** Contact
   records are held per brand, in three tables that nothing keeps in sync. Go to
   [customer-and-company-data.md](customer-and-company-data.md) and run the Pass A lookups for all
   three (MHD-36009, Confluence 3117842457 Pattern A).
6. **Check for a blocking task.** An uncleared **Review - Contract Sending Failed** task stops the
   loan agreement sending (MHD-32267).
7. **Check whether the send was muted.** Every email or SMS with an Application, Application2 or
   Customer object type is checked against `CommsMuteRule` by the Horizon2 stored procedure
   `usp_CanCustomerBeContacted`. The lower the `Priority` number, the higher the priority. Each
   rule's `AllowedTemplateSettingsId` lists templates exempt from it (Confluence 1079312385).
8. **Check the stage.** At Arrears Referred to External (117), or the older stage 37, we can no
   longer contact the customer directly (Confluence 1293647889).
9. **For duplicates, compare send timestamps against stage changes.** Identical sends with no stage
   change between them point to a comms engine re-fire, not a new event (MHD-36668).

## Root causes seen

1. **SendGrid suppression.** Once an address lands on Bounced, Blocked or Spam Reports, every future
   email to it fails silently and the send path keeps retrying it (MHD-35539). MHD-29993 is the
   clean worked example: a broker address on the Bounces list with a 550 error, removed manually by
   Michael Dela Torre, who warned it would likely re-bounce.
2. **Per-brand contact records out of sync.** The update lands on one brand's contact row and not
   the others, so comms keep resolving the old address. On MHD-36009, application 10003012512,
   *"the old address was still held on the customer's SocietyOne (SOC) brand contact record, the
   update was applied to the MoneyMe and OzMoney records but not SOC."*
3. **Recipient-side mail client behaviour.** MHD-36075 is the definitive write-up. Four identical
   passcode reset emails within 25 minutes were threaded by Gmail and the repeated body collapsed
   behind a "…" show-trimmed-content control. The customer read that as an empty email. All four
   were intact and Delivered. Triggering more G3APIBot resets makes it worse, because each
   identical resend deepens the trimming.
4. **A blocking task.** MHD-32267: a broker's loan agreement, template 2146, never sent after
   funding because of an uncleared Review - Contract Sending Failed task.
5. **Comms engine re-firing.** MHD-36668: settlement emails for application 10003015808 sent
   correctly at 17/07/2026 11:01, three minutes after Fund Sent, then the identical pair sent again
   61 days later at 16/09/2026 04:05 with no stage change in between. 04:05 sits inside the nightly
   comms window. Two candidate mechanisms, neither confirmed: a Workflow2 `Reset Days` value
   allowing re-processing, or a missing "templates not yet sent" guard.
6. **Timeout or queue limits causing multiple sends.** Occurs when the 60-second timeout or the
   70-second queue time is reached. Mostly on SOA templates with attachments where the attachment
   is not found (Confluence 1079312385).
7. **A queue backed up behind a failing SOA template.** `#comms-daily-check` notifies on bulk
   messages. Causes seen: too many records, attachment not found, merge tag query error, invalid
   application data. Base64-decode the `Body` of a queued message to find the ApplicationId and
   TemplateId (Confluence 1079312385).
8. **Merge tag error on a mobile number merge tag.** The customer has multiple active mobile
   numbers. There should be only one active mobile number per brand (Confluence 1079312385).
9. **`&nbsp;` in the template.** It can end up as U+FFFD replacement characters rendering as boxed
   question marks in Outlook. Template 201122 was fixed on 2026-09-16 by replacing 11 `&nbsp;`
   instances with plain spaces or `white-space:nowrap` spans (tribal knowledge (Slack) section 5).
10. **A template overwritten in production.** Template 341, MME 1014 Confirmation of Change of
    Direct Debit Details, had an entirely different MOM template put in its place, leading to
    multiple Ops tickets. Rusty fixed it in prod on 2025-10-29 and raised FE-5360 so the process
    would be followed (`#comms-fixing`).
11. **Deliverability.** Suped, the deliverability partner, flagged Horizon transactional email as
    quarantined or spam due to misaligned MAIL FROM (`sendgrid.net`) and DKIM (MHD-26581).

## The fix

| Root cause | Action |
| --- | --- |
| On DNC | **No action.** That is the answer |
| SendGrid suppression | **Config change**, remove the address from whichever list it is on, then ask the requester to retry. Expect a repeat if the address is genuinely dead. Reply template below |
| Not on any suppression list, not on DNC | **Escalate.** Raise an MHD and post to `#app-support-twilio-comms` cc Haze (Hazelrey Cate Erasmo). Worked example MHD-34838, failing since 10 July 2026, not on DNC, not suppressed |
| Per-brand contact desync | **Datafix** under the monthly umbrella. See [customer-and-company-data.md](customer-and-company-data.md) |
| Gmail trimming | **No action.** Coach the reporter. Tell the customer to open the **first** email in the thread or tap the "…". Do not trigger more resets |
| Blocked by a task | **Config change**, clear the Review task. If the note names a mobile or email error, have the agent fix it first (Michael Dela Torre, MHD-32267) |
| Comms engine re-fire | **Escalate** to the Comms team. Record the send timestamps and the absence of a stage change on the ticket |
| Queue backed up behind SOA | **Escalate** to Lary Rosario, who may stop or fix the sending in the workflow. Workaround on Confluence 1079312385: move messages from `messagingqueue` (mme-communications-live) to `messagingqueue2` (api-communication2-prod) until the queue reduces |
| Multiple active mobile numbers | **Datafix**, deactivate the extras with `AppSupport_UpdateCustomerContactNumber @IsActive = 0` rather than the raw UPDATE on the Comms page |
| Template defect, `&nbsp;`, wrong template | **Escalate.** Raise or link a G1, AMZ or FE ticket. Needs a release, not SQL (Confluence 3117842457 Part 1). Template changes must follow the process (Rusty, FE-5360) |

**Removal reply template**, Michael Dela Torre's wording, used verbatim many times:

> Hi @{reporter} upon checking, the email {address} was under the Bounces list in our suppression
> list in Sendgrid. I have removed it from the list for you to be able to try sending again but it
> might fail again due to the reason/error 550. Thank you.

**The sources disagree on who can remove a suppression.** The Cover Runbook (Confluence 3131015188,
August 2026) and current Slack practice have App Support removing entries directly in SendGrid.
The older Comms Known Issue page (Confluence 1079312385, September 2024) says removal *"needs
customised access we do not have. For these requests we ask the CTO to remove it for us."* Current
practice is direct removal by whoever holds SendGrid access. If your login cannot see the remove
control, escalate to Michael Dela Torre, then the CTO.

Logs: `SELECT TOP 100 * FROM Horizon2.dbo.[Message] WHERE ApplicationId = <ApplicationId>`, and the
mme-communications-live App Service log folder, `<year>-<month>-<day>_Service.log` or
`_Exception.log` (Confluence 1079312385). Comms stack detail is in
[../01-systems/communications.md](../01-systems/communications.md).

## Not a defect

- **"Emails are failing" when the address on file is already correct.** Usually the bounce list.
  Remove it, no SQL (Confluence 3117842457 Part 1, MHD-35847).
- **Empty-looking passcode reset emails.** Gmail threading and trimming (MHD-36075).
- **Settlement emails re-firing months later.** Pure duplicates with no account change behind them.
  Verify before treating as a new event (tribal knowledge (Slack) section 9). Unexplained, but not a
  new event.
- **Comms not reaching a customer at stage 117 or 37.** A third party handles contact
  (Confluence 1293647889).

## Precedents

- MHD-29993: broker address on the Bounces list, 550 No Such User, removed manually.
- MHD-35539, MHD-35666, MHD-36007: "Investigate in sendgrid", suppression removal.
- MHD-35847: correct address on file, bounce list was the cause.
- MHD-34838: not on DNC, not suppressed, genuinely failing. Escalated.
- MHD-36009: SOC brand contact record left holding the old address.
- MHD-36075: empty-looking passcode reset emails, Gmail trimming.
- MHD-32267: template 2146 blocked by Review - Contract Sending Failed.
- MHD-36668: settlement emails re-sent 61 days later.
- MHD-18891: error sending email, DNC was enabled.
- FE-5360: template 341 overwritten with a MOM template.
- MHD-29956, MHD-29963, MHD-29996, MHD-29997, MHD-30009, MHD-30036, MHD-30067, MHD-29744,
  MHD-29730, MHD-29734, MHD-29883, MHD-29479, MHD-30309, MHD-30425, MHD-30808, MHD-31353,
  MHD-32398, MHD-32679, MHD-33488, MHD-33633, MHD-33954, MHD-34093, MHD-34117, MHD-34981,
  MHD-36527, MHD-36407: further SendGrid and email tickets.
- MHD-33771, MHD-35193, MHD-33293, MHD-35658: template and workflow send failures.

## Open defects

- **MHD-35799**, Pending, Medium: add a Horizon button to view and clear a SendGrid suppression
  across all three lists, permission-gated, writing an audit note. Ron wrote the full acceptance
  criteria. It cites roughly 25 similar tickets. Not built, no movement since 19/08/2026.
- **G1-7161** found that Bounced and Spam Reporting entries are standing do-not-send instructions
  and the send path keeps retrying them anyway, around 50,000 futile sends. It lists "Missing
  blocked/deferred event handling" as a follow-up that is not tracked anywhere.
- **Template 970** ("Forgot Passcode Email To Generate Verification Code") renders "Reference number
  0" instead of the application ID. Found on MHD-36075. No ticket.
- **Reset emails are byte-identical on repeat sends**, which is what triggers Gmail trimming.
  Adding a timestamp or reference to the body would prevent it. Not raised.
- **MHD-36668** auto-closed unresolved. Which job ran at 04:05, whether other applications were in
  the same run, and whether the September bodies differ from July were never established. If the
  bodies were re-rendered against current data, the figures may differ, which would be materially
  worse than a duplicate. Ron asked that any recurrence reopen this ticket rather than raise a new
  one.
- **MHD-34298**, "Fix incorrect email generation in ApplicationComms", Selected for Development
  since 01/07/2026.
- **MHD-26581**, "Horizon - Email Deliverability", Selected for Development since 02/09/2025. Over a
  year old.
- **Luxury Escapes CRD funded email using generic template 201185 instead of branded 201265.**
  Raised 2026-08-19, no ticket key recorded.
