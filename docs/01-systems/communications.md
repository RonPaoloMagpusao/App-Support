# Communications

The Comms API, template handling, the mute and suppression logic, SendGrid, Twilio, Braze, and how to trace one message end to end.

Last reviewed: 23 September 2026

Sources: Confluence 1079312385 (Comms Known Issue and Resolution), 1078689857 (Comms API Support), 1060864395 (Sendgrid), 1079181314 (Twilio Known Issue and Resolution), 3131015188 (App Support Cover Runbook), 3022258468 (Braze Scheduler), 3159327598 (CommsMuteTemplate), 2761163168 (Twilio2 repo), 1293647889 (stage comms behaviour), 2286321665 (Split Account Task Handling); [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 1, 5, 6 and 9; [03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md).

## Comms API

`Comms` is the API that sends messages, processes received messages, sends mobile notifications, updates message status and handles the related CRUD (Confluence 1079312385).

| Item | Value |
| --- | --- |
| Azure app service | `mme-communications-live` |
| Subscription | `d2c61912-1986-42ce-ae47-24f987ce73aa` |
| Resource group | `MicroserviceLive2` |
| Log path | App Service Editor (Preview) > **Log** folder > `<year>-<month>-<day>_Service.log` and `<year>-<month>-<day>_Exception.log` |
| Queues | `messagingqueue` on `mme-communications-live`; `messagingqueue2` on `api-communication2-prod` |
| Sentry project | `https://societyone.sentry.io/projects/comms-api/?project=6704643` |
| Slack monitoring | `#comms-daily-check` for bulk message backlogs |
| Jira | G1 project. G1-6834 and G1-7161 hold the SendGrid suppression findings ([03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md)) |

**Inbound email is not the Comms team's.** Inbound is handled by "Email Downloader", which runs in the background and is maintained by the **Horizon team** (Confluence 1078689857).

### Log keywords that prove the API received a message

Search the service log for the date, then for the TemplateId plus ApplicationId or CustomerId:

- `Email QueueV2 received message for data`
- `Email QueueV2 sending to handler for data`
- `Email sent for data`
- The same three with `Sms QueueV2` and `Sms sent for data`

If none of them are present, the caller (Horizon, Workflow, MME Web and so on) never triggered the Comms API, and the investigation belongs to that caller's team.

### Queue backlog

A backlog happens when one or more messages hit an error or time out. The usual culprit is the SOA template, with errors such as:

- Too many records, getting all transactions from start to date
- Attachment not found, the Comms API tries to fetch the file and throws
- Error in merge tag query
- Invalid application data, the merge tag cannot complete the request

To identify the ApplicationId and TemplateId, open one of the queued messages, copy the `Body` and base64 decode it.

Documented workaround: manually move random messages from `messagingqueue` to `messagingqueue2`, that is from `mme-communications-live` to `api-communication2-prod`, until the queue starts to reduce. Relay to Lary Rosario if SOA is the cause; they may stop or fix the sending in the workflow (Confluence 1079312385).

### Duplicate sends

Timeout is **60 seconds** and queue time **70 seconds**. Exceeding either causes duplicate sends. It happens most often on SOA templates with attachments where the attachment is not found (Confluence 1079312385).

Related non-obvious behaviour: settlement confirmation emails can re-fire months later as pure duplicates with no account change behind them. Worked example: loan settled 17 July 2026, repaid 14 August, settlement emails re-sent in the early hours of 16 September. Verify before treating it as a new event ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 9).

Long-standing `comms-api` Sentry alerts (`NotRegistered`, `APNs device token is disabled`, first seen 2022-11-15, 1 user affected) are noise ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 4).

## Template handling

Templates are identified by numeric TemplateId and are referenced by id everywhere: in `CommsMuteRule.AllowedTemplateSettingsId`, in the Comms API logs, and in Ops requests.

| Template | What happened | Source |
| --- | --- | --- |
| `341` (MME 1014, Confirmation of Change of Direct Debit Details) | Overwritten in production with an unrelated MOM template. Fixed in prod by Rusty 2025-10-29; a process investigation was requested | FE-5360 |
| `201122` | Rendered `&nbsp;` as boxed question marks, U+FFFD replacement characters baked into the message body. Fixed 2026-09-16 by replacing 11 `&nbsp;` instances with plain spaces or `white-space:nowrap` spans | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 5 |
| `201185` versus `201265` | Luxury Escapes CRD funded email used the generic template 201185 instead of the branded 201265. Raised 2026-08-19 | [05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 5 |
| `2017` Switch to Manual Payments (Good Standing Order) | Sent when a customer's default payment method is switched to DC or CC after repeated manual payments. Default wording is replaced with the text on the source page | Confluence 2286321665 |
| SOA templates | The main source of queue backlogs and duplicate sends | Confluence 1079312385 |

**Rule: avoid `&nbsp;` in Horizon email templates.** It can end up as U+FFFD replacement characters rendering as boxed question marks in Outlook.

Related open item: SOA file upload is blocked by a 10MB limit, HOR-8167, raised 2026-07-14 with a request to increase it to 20MB.

Unverified: how templates are edited and promoted to production, and who owns that process. FE-5360 asked for exactly this investigation; no answer appears in the sources.

## Mute and suppression logic

`usp_CanCustomerBeContacted` in `Horizon2` decides whether a send is allowed. The Comms API calls it for every email or SMS it receives with an Application, Application2 or Customer object type (Confluence 1079312385).

Inputs: Application ID, Customer ID, Brand ID (`-1` = all brands by default), CommsTypeId, Template ID, From, To, Body, ObjectType, IsGenerate (`1` = generate API request, `0` = send/queue API request).

Output: `CanContact` BIT. `1` = can contact, `0` = muted.

Evaluation:

1. Select the applicable `CommsMuteRule` rows for the brand (`BrandId = @BrandId OR BrandId = -1`) where `IsActive = 1`. **The lower the `Priority` number, the higher the priority.**
2. For each rule, run its `CriteriaSql` with the passed values injected. It returns a BIT, where `1` means muted.
3. If `CriteriaSql` returns 1 and the request's template id is in that rule's `AllowedTemplateSettingsId`, sending is allowed and the loop stops. Otherwise sending is blocked and the loop stops.
4. If no rules exist or all rules pass, sending is allowed.

Source inconsistency: the page states lower number means higher priority, but its published query orders by `[Priority] DESC`, which would evaluate the lowest priority rule first (Confluence 1079312385). Unverified: which order the procedure actually uses. Confirm by reading the body of `usp_CanCustomerBeContacted`.

`CommsMuteTemplate` is a newer table added for white label credit card comms suppression under HOR-8583 / HOR-8694, released via MHD-36342 (Confluence 3159327598).

### Other things that stop a send

| Check | Where |
| --- | --- |
| Customer is DNC | `Customer.IsDonotContact` |
| Marketing Opt Out Internal | `AdditionalData.AdditionalDataTypeId = 8` |
| Marketing Opt Out External | `AdditionalData.AdditionalDataTypeId = 16` |
| Application at stage 117 Arrears Referred to External, or the older stage 37 | We can no longer contact the customer directly; the third party issues notices (Confluence 1293647889) |
| Application at stage 127 External - LOA Received | DNC is selected on entry (Confluence 1293647889) |
| Application at stage 65 Overdue hold | Overdue comms and notices do not send (Confluence 1293647889) |

## SendGrid

Console: `https://app.sendgrid.com/`. Login sends an OTP to your phone. No credential is recorded here.

### Delivery logs

**Activity** tab, search the address. You get every email sent to that address with its event history, which is what tells you whether the message was delivered, bounced, blocked or dropped (Confluence 1060864395).

Horizon side: `SELECT TOP 100 * FROM Horizon2.dbo.[Message] WITH (NOLOCK) WHERE ApplicationId = <id>`. A send that shows **Failed** in Horizon is the signal to go to SendGrid Suppressions (Confluence 1079312385).

### Suppression lists

Under the **Suppressions** menu. Once an address lands on one, every future email to it fails silently and the send path keeps retrying (Confluence 3131015188).

| List | What it means | Fields |
| --- | --- | --- |
| Global Unsubscribes | The customer unsubscribed globally | `Time` column shows when |
| Group Unsubscribes | Unsubscribed from a group | `Time` column |
| **Bounces** | Most common, with Blocks and Spam Reports | Reason, for example `550 no such user here`, `user unknown`. `Date` column |
| **Blocks** | Receiving server blocked us | Reason. `Date` column |
| **Spam Reports** | Recipient marked us as spam | `Date` column |
| Invalid | Address does not exist | Reason usually just "Invalid address." |

### Who may clear a suppression: the sources contradict each other

- **Confluence 1079312385 and 1078689857 (both September 2024)**: "Removal from a suppression list needs customised access we do not have. For these requests we ask the **CTO** to remove it for us." Page 1078689857 adds: raise an MHD, the CTO is the only account that can remove it.
- **Confluence 3131015188, the Cover Runbook (August 2026)**: describes removing the address from the list and asking the requester to retry, with no mention of a CTO gate.

Both readings are live and neither page says it supersedes the other. The Cover Runbook is two years newer, which suggests access changed. Unverified: whether App Support SendGrid accounts can now remove suppressions. Confirm by checking whether the remove control appears on a suppression row when logged in as App Support. Until confirmed: attempt the removal, and if the control is not there, raise an MHD for the CTO.

There is no self serve removal button in Horizon. **MHD-35799** requests one and is Pending.

### Triage order for "email not delivered"

Michael Dela Torre's repeated practice ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 1):

1. DNC flag in Horizon.
2. SendGrid **Bounces** suppression list.
3. The bounce reason itself.

Known defect on the delivery side: Horizon transactional email quarantined as spam through MAIL FROM and DKIM misalignment, MHD-26581, raised 2025-09-19.

## Twilio

Twilio is the SMS provider and the product Ops uses to receive and trigger customer calls (Confluence 1079181314).

| Resource | Where |
| --- | --- |
| Status page | `https://status.twilio.com/`. Check for **voice** or **SMS** incidents and whether they are **APAC** specific |
| Agent network test | `https://networktest.twilio.com/`. The agent must pass both the NTS and Voice tests |
| Console | `https://console.twilio.com/` > Monitor > Messaging, filter on the number under **To** |
| Error dictionary | `https://www.twilio.com/docs/api/errors` |
| Sentry project | `https://societyone.sentry.io/projects/twilio-web/?project=6704642` |
| Azure Table | `livemoneymestorage` > `TwilioLogException` |
| Repository | **Twilio2** in Azure DevOps, app `MoneyMe.Voip.WebApi` (Confluence 2761163168) |

### The Twilio error log

`Communication.dbo.EventLog` doubles as the error log for all Twilio responses.

```sql
USE Communication;
SELECT * FROM EventLog l WITH (NOLOCK)
WHERE l.CreatedbyUser = '<agent_username>' AND CAST(l.CreatedDate AS DATE) = '<yyyy-mm-dd>';
```

- `LogDetails`: general error or log messages.
- `AdditionalInfo`: mostly parsed JSON responses and error detail from Twilio. `OriginalError` is usually less helpful but occasionally clearer than the newer detail.

| Keyword | Meaning |
| --- | --- |
| `ConnectionError`, `TransportError`, `AccessTokenInvalid` | Error connecting to, validating with, or exchanging data with Twilio |
| `HangupWhenCustomerNotAround` | We accepted a call but the customer had already dropped; the call is then dropped on our end too |
| `Agent *** disconnected on twilio ***` | Unstable agent internet, or the agent connected to or disconnected from the VPN while on a call |

### Voice: agent disconnected on an inbound call

Urgency HIGH. Impact LOW if one to two agents, HIGH if widespread. Check in order: a Twilio voice incident (APAC); microphone permission, since a blocked microphone ends the call automatically; connection quality via the network test; then `EventLog`.

### Voice: no inbound calls received

| Cause | Check |
| --- | --- |
| Inbound grouping changed | Admin > User > Search User > click the user. Groups appear on the right under `<first name>'s Group's`. Usually checked by the agent's supervisor or the Twilio product owner |
| The number was turned off | `SELECT * FROM [Configuration] WITH (NOLOCK) WHERE SettingId = 1002 AND IsActive = 1`. `Value` is `True` or `False`; `False` means someone turned it off. Turn it back on by script, or ask the product owner to do it in the Twilio app |
| Who turned it off | `SELECT TOP 10 * FROM EventLog WITH (NOLOCK) WHERE LogDetails LIKE 'Updated Inbound Config to%' ORDER BY 1 DESC`. Text reads `Updated Inbound Config to <True/False> for <brand name>`; `CreatedByUser` is the username |
| Outside operating hours | `OperatingHours` for the `DayOfWeek` (1 to 7, Monday = 1) where `IsActive = 1`. `From` and `To` are 24 hour `hh:mm` |
| Special schedule applied | `SpecialSchedule` where `IsActive = 1` for the date. `BrandId 0` means all number lines |

Find a number's brand with `SELECT * FROM [Configuration] WITH (NOLOCK) WHERE [Value] = '<number in international format>'`. **Twilio's BrandId is customised**: each number is assigned a number and the first digit maps to the usual brand, for example `11` maps to brand 1 (MME).

`ConfigurationSettingId` line types: `1001` Brand line, `1005` Customer line, `1006` Partner line.

### Campaigns

`CampaignHeader.CampaignStatusId`: `0` live; `1` open, which will complete soon because there is no pending list in `CampaignDialer` (numbers and customers are fetched in real time); `2` cancelled; `3` completed; `4` closed. To activate, confirm `CampaignHeader.LiveCampaignId` exists in `LiveCampaign` and that the stored procedure named in `LiveCampaign.Query` exists in the `Communication` database, then set `CampaignStatusId = 0`. To deactivate, set `3`.

"Outbound Campaign - No Application Id": the agent cannot see the application id. Check whether the agents are on V2. The source page is incomplete here (Confluence 1079181314).

### SMS

- Message status is logged in `Communication.dbo.HorizonSmsStatusLog`, joined by `MessageId` from the Horizon `[Message]` table. Status values are Twilio's: `https://www.twilio.com/docs/messaging/api/message-resource#message-status-values`.
- **SMS opt-out lists are held by Twilio.** We cannot query them ourselves; Twilio support has to generate the list.
- If Twilio shows the message sent without errors, it is almost never us. Check the customer's spam folder ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) sections 1 and 4).
- A merge tag error with a mobile number means the customer has multiple active mobile numbers. There should be only one active mobile per brand. Deactivate the extras with `UPDATE dbo.CustomerContactNo SET IsActive = 0 WHERE CustomerId = <id> AND CustomerContactNoId = <id>`.

### OTP and verification

- The customer verification code is **always SMS, never email** (Confluence 3131015188).
- A "successful login" in our data means the password was accepted and the customer reached the OTP step. It does **not** mean they got in.
- Login history is only visible within 7 days.
- MHD-35362 (application 10002405188) is the sample SMS login failure ticket on the Cover Runbook.

### Escalation and ownership

The Twilio product owner or the G4 PM talk to Twilio support (Confluence 1079181314). Comms contacts named on the App Support pages are Jap and Aina. The Team Directory names Jeffrey Acosta as Communications Tech Lead, with Hazelrey Cate Erasmo and Miela Jovienne Lacanilao as the Twilio developers. In Slack the working contacts are Hazelrey Cate Erasmo (Haze) and Dave, in `#twilio-team`, `#app-support-twilio-comms`, `#twilio-tech-app-support`, `#twilio-tech-ops-workgroup` and `#comms-fixing` ([05-knowledge/tribal-knowledge.md](../05-knowledge/tribal-knowledge.md) section 6).

The Twilio and Comms Confluence pages date from September to October 2024 and name a departed product owner; the Comms platform has had a revamp and a Braze integration since ([07-open-items/documentation-gaps.md](../07-open-items/documentation-gaps.md) section 5). Treat their escalation names as stale.

## Braze

`MoneyMe.Communication.BrazeScheduler` (V2) is a .NET 9 Azure Functions app that syncs Braze campaign communications (email, SMS, push) **inbound into the Horizon Comms Tab**, so agents can see what a customer was sent (Confluence 3022258468).

Consequence: a message visible on the Comms tab may have been sent by Braze marketing, not by Horizon. If it is on the tab but absent from the Comms API logs, check whether it was a Braze campaign before treating it as a Horizon send. Unverified: whether Braze-synced items are written to `Horizon2.dbo.[Message]` or to a separate store. Confirm with the Comms team.

## Tracing one message end to end

1. **Identify the message.** Horizon Comms tab (`/Communication/ApplicationComms/<ApplicationId>`), or `SELECT TOP 100 * FROM Horizon2.dbo.[Message] WITH (NOLOCK) WHERE ApplicationId = <id>`. Note the TemplateId, the MessageId and the send timestamp.
2. **Was it allowed to send?** `Customer.IsDonotContact`, `AdditionalData` types 8 and 16, the application's stage (117, 37, 127 and 65 all suppress something), then the `CommsMuteRule` evaluation above.
3. **Did the Comms API receive it?** Azure portal > subscription `d2c61912-1986-42ce-ae47-24f987ce73aa` > resource group `MicroserviceLive2` > `mme-communications-live` > Development Tools > App Service Editor > Log folder > the file for that date. Search the TemplateId and ApplicationId or CustomerId for the `QueueV2 received` / `sending to handler` / `sent for data` keywords. Nothing there means the caller never triggered the API.
4. **Is it stuck in a queue?** `messagingqueue` on `mme-communications-live`. Base64 decode a queued message `Body` to identify it. Check `#comms-daily-check`.
5. **Did the provider accept it?**
   - Email: SendGrid **Activity**, search the address, read the event history. Then **Suppressions**: Bounces, Blocks, Spam Reports, Invalid, and the Unsubscribe lists.
   - SMS: `Communication.dbo.HorizonSmsStatusLog` by `MessageId`, then Twilio Console > Monitor > Messaging filtered on the number.
6. **Was it delivered?** Email: the SendGrid event history is the answer. SMS: the Twilio message status. If Twilio says sent with no errors, stop looking on our side.
7. **Duplicates?** Look for multiple Comms API requests with the same TemplateId and ApplicationId in the Azure logs, then the 60 second timeout and 70 second queue time behaviour.

In write-ups use "the customer" and keep application and message ids as the handles. Do not paste addresses or numbers into tickets or this repo.
