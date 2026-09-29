# [Comms] Known Issue and Resolution

Mirror of the Confluence page "[Comms] Known Issue and Resolution".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1079312385, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1079312385 · Last updated: 11 Sep 2024 · Author: Ron Paolo Miguel Magpusao
- Contributors: Hazelrey Cate Erasmo · Team assigned: G4 - Communications
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1079312385/Comms+Known+Issue+and+Resolution

**Overview.** Comms is an API used to send messages, process received messages, send mobile
notifications, update message status, and other CRUD transactions related to communication.

## Message not sent / delayed messages

### Message was muted by the `CommsMuteRule` table (Email and SMS)

For every email or SMS the API receives with an Application, Application2 or Customer object
type, it checks whether the request is muted per `CommsMuteRule`. The checking logic lives in
the Horizon2 stored procedure `usp_CanCustomerBeContacted`.

Values passed in: Application ID, Customer ID, Brand ID (-1 = all brands by default),
CommsTypeId, Template ID, From, To, Body, ObjectType, IsGenerate (1 = generate API request,
0 = send/queue API request).

Returns: `CanContact` BIT. `1` = can contact, `0` = cannot contact / muted.

Process: get the applicable `CommsMuteRule` rows. **The lower the `Priority` number, the higher
the priority.**

```sql
USE Horizon2;
SELECT CriteriaSql, AllowedTemplateSettingsId, [Priority]
FROM CommsMuteRule WITH (NOLOCK)
WHERE (BrandId = @BrandId OR BrandId = -1) AND IsActive = 1
ORDER BY [Priority] DESC;
```

Loop through the results. Each rule has a `CriteriaSql` column into which the passed values are
injected; it returns a BIT (`1` = cannot contact / muted). Each rule also has
`AllowedTemplateSettingsId` listing template IDs exempt from that rule. If `CriteriaSql`
returns 1 and the request's template ID is in `AllowedTemplateSettingsId`, sending is allowed
and the loop stops; otherwise sending is blocked and the loop stops. If no rules exist or all
rules pass, sending is allowed.

### Twilio down or SMS specific issue

Check https://status.twilio.com/ for an unresolved **SMS** incident, region **APAC**. Notify
the Twilio product owner or the G4 PM.

### Customer has unsubscribed or opted out of SMS

There is currently no way for us to check the list of opted out numbers ourselves; Twilio
support can generate the list. Otherwise determine it from the message status response
(https://www.twilio.com/docs/messaging/api/message-resource#message-status-values):

```sql
USE Communication;
SELECT * FROM HorizonSmsStatusLog WITH (NOLOCK) WHERE MessageId = <messageid_from_message_table>;
```

### Email address on a SendGrid suppression list

Log in to SendGrid and go to **Suppressions**:
- **Global Unsubscribes / Group Unsubscribes**: results mean the customer unsubscribed; the
  `Time` column shows when.
- **Bounces / Spam Reports / Blocks** (most common): Bounces and Blocks have a reason field;
  all three have a `Date` column.
- **Invalid**: emails that are invalid or do not exist; reason usually just "Invalid address."

**Removal from a suppression list needs customised access we do not have. For these requests we
ask the CTO to remove it for us.** The remove control sits on the row in the search results.

### Too many messages in the queue

Slack monitoring notifies us when bulk messages occur, in `#comms-daily-check`. The issue
occurs when one or more messages hit an error or time out. Most often the cause is the SOA
template, with errors such as:
- Too many records, getting all transactions from start to date
- Attachment not found, the Comms API tries to fetch the file and throws
- Error in merge tag query
- Invalid application data (merge tag cannot complete the request)

To identify the ApplicationId / TemplateId, open one of the queued messages, copy the `Body`
and base64 decode it.

Alternative workaround: manually move random messages from the `messagingqueue` to
`messagingqueue2` (from **mme-communications-live** to **api-communication2-prod**), moving
messages until the queue starts to reduce. Relay to Lary Rosario if SOA is causing the issue;
they may stop or fix the sending in the workflow.

### Logs

```sql
USE Horizon2;
SELECT TOP 100 * FROM dbo.[Message] WITH (NOLOCK) WHERE ApplicationId = <ApplicationId>;
```

In the Azure portal, find **mme-communications-live** → **App Service Editor (Preview)** →
**Log** folder, and open the file for the current date:
`<year>-<month>-<day>_Service.log` or `<year>-<month>-<day>_Exception.log`.

## Merge tag error, merge tag with mobile number

The error shows when the customer has multiple active mobile numbers. Per the Horizon team
there should be **only one active mobile number per brand**. Resolve by generating a script to
deactivate the extras:

```sql
USE Horizon2;
UPDATE dbo.CustomerContactNo SET IsActive = 0
WHERE customerid = <customerId> AND CustomerContactNoId = <CustomerContactNoId>;
```

## Bounce email

Sending an email to the customer shows as **Failed** in Horizon. Log in to SendGrid, check
**Suppressions** → Bounces, Spam Reports, Blocks. Send the removal request to the CTO, whose
account can remove entries from the Suppressions menu.

## Multiple sending

The customer received multiple messages, or the Horizon Message tab shows multiples. Check the
file logs to see whether the client or workflow sent multiple messages. Occurs when the timeout
(60 seconds) or queue time (70 seconds) is reached. Mostly happens on SOA templates with
attachments where the attachment is not found.

---
