# [Comms API] Support

Mirror of the Confluence page "[Comms API] Support".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1078689857, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1078689857 · Last updated: 11 Sep 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1078689857/Comms+API+Support

## 1. The customer is not able to send

**1.1** Check whether the customer is DNC, or whether Marketing Opt Out Internal/External is
tagged true in the workflow. Either stops the send.

```sql
-- Is the customer DNC?
SELECT TOP 100 FirstName, LastName, IsTest, IsDonotContact FROM Customer WHERE CustomerId = <<CustomerId>>

-- Is the customer Marketing Opt Out?
-- 8: Marketing Opt Out Internal
-- 16: Marketing Opt Out External
SELECT TOP 100 * FROM AdditionalData WHERE AdditionalDataTypeId IN (8,16) AND CustomerId = <<CustomerId>>
```

**1.2 to 1.4** Check the Azure logging to see whether the request reached the Comms API.

Azure resource path for the Comms app service:
`portal.azure.com` → subscription `d2c61912-1986-42ce-ae47-24f987ce73aa` → resource group
`MicroserviceLive2` → `Microsoft.Web/sites/mme-communications-live` → **Development Tools** →
**App Service Editor** → **Open Editor**.

Search the service log file for the date, then search the TemplateId and
ApplicationId/CustomerId for these keywords, which indicate the message was received:
- "Email QueueV2 received message for data", "Email QueueV2 sending to handler for data",
  "Email sent for data"
- "Sms QueueV2 received message for data", "Sms QueueV2 sending to handler for data",
  "Sms sent for data"

If not found, the caller (Horizon, Workflow, MME Web and so on) did not trigger the Comms API
and they should investigate on their side.

**1.5** Check the provider. For email, log in to SendGrid → Suppressions → Bounces, Spam
Reports, Blocks, Invalid. If found, raise an MHD: the CTO is the only account that can remove it.

## 2. Not able to receive an email from an external sender

The Comms team handles the outbound engine. Inbound is handled by "Email Downloader", which
runs in the background and is maintained by the **Horizon team**. This is not supported by the
Comms team.

## 3. SMS multiple sending

Check Azure logging for multiple requests to the Comms API (steps 1.2 to 1.4). If multiple
records show the same TemplateId and ApplicationId/CustomerId, Horizon, Workflow or the Web
application may be triggering multiple requests.

Then log in to the Twilio Console (https://console.twilio.com/) → **Monitor** → **Messaging** →
put the mobile number under **To** and filter. If multiple sends show, report it to the Twilio
provider.

## 4. Email multiple sending

Same as 3: check Azure logging for multiple client requests to the Comms API.

---
