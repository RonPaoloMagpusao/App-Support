# [Twilio] Known Issue and Resolution

Mirror of the Confluence page "[Twilio] Known Issue and Resolution".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1079181314, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1079181314 · Last updated: 23 Oct 2024 · Author: Ron Paolo Miguel Magpusao
- Contributors: Hazelrey Cate Erasmo · Team assigned: G4 - Communications
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1079181314/Twilio+Known+Issue+and+Resolution

**Overview.** Twilio is the product the Ops team uses to receive and trigger calls from and to
customers.

## Agent gets disconnected when receiving an inbound call

Urgency HIGH · Impact LOW if one to two agents affected, HIGH if widespread.

Possible causes and checks:

**Twilio (third party) down or voice specific issue.** Check https://status.twilio.com/.
Unresolved incidents appear at the top. Check for an incident related to **voice**, and if it
is region specific check for **APAC**. If active, tell Twilio's product owner or the G4 PM;
they talk to Twilio support for status and time frame. Our Twilio cannot accept or trigger a
call until then.

**Unstable internet connection or no microphone permission.** The Twilio site must have
microphone permission; a blocked microphone ends the call automatically. Ask the agent to run
the Twilio Network Test at https://networktest.twilio.com/ and pass both the NTS and Voice
tests.

**Check `Communication.dbo.EventLog`**, which doubles as an error log for all Twilio responses:

```sql
USE Communication;
SELECT * FROM EventLog l WITH (NOLOCK)
WHERE l.CreatedbyUser = '<agent_username>' AND CAST(l.CreatedDate AS DATE) = '<yyyy-mm-dd>';
```

Column values:
- `LogDetails`: general error or log messages.
- `AdditionalInfo`: mostly parsed JSON responses and error detail from Twilio. The
  `OriginalError` value is usually less helpful, but occasionally clearer than the newer detail.
  Error codes can be looked up in Twilio's error and warning dictionary at
  https://www.twilio.com/docs/api/errors.

Keywords that indicate an error:
- `ConnectionError`, `TransportError`, `AccessTokenInvalid`: error connecting, validating, or
  sending/receiving data to or from Twilio.
- `HangupWhenCustomerNotAround`: we accepted a call but the customer had already dropped; the
  call is then dropped on our end too.
- `Agent *** disconnected on twilio ***`: unstable agent internet, or the agent connected or
  disconnected from the VPN while on a call.

## No inbound calls received

Urgency HIGH · Impact LOW if one to two agents affected, HIGH if widespread.

**Agent's inbound grouping may have changed.** Inbound grouping is how Twilio knows which call
goes to whom. Check via **Admin > User > Search User > Click User**; groups are listed on the
right under the label `<first name>'s Group's`. Edit to update. Usually checked by the agent's
supervisor/manager or the Twilio product owner.

**Number was turned off.** An authorised user can turn inbound calls on or off for specific
brand numbers.

```sql
USE Communication;
SELECT * FROM [Configuration] WITH (NOLOCK) WHERE SettingId = 1002 AND IsActive = 1;
```

To find a number's BrandId:

```sql
USE Communication;
SELECT * FROM [Configuration] WITH (NOLOCK) WHERE [Value] = '<number in international format, e.g. +61...>';
```

Twilio's `BrandId` is customised: each number is assigned a number. The custom brand ID is
distinguished by its first digit, for example `11` maps to brand ID 1 (MME) in our usual brand
names. `Value` is `True` or `False`; `False` means someone turned it off. Turn it back on by a
DB script, or ask the product owner to do it in the Twilio app.

Who turned it off:

```sql
USE Communication;
SELECT TOP 10 * FROM EventLog WITH (NOLOCK)
WHERE LogDetails LIKE 'Updated Inbound Config to%' ORDER BY 1 DESC;
```

Text reads `Updated Inbound Config to <True/False> for <brand name>`. `CreatedByUser` is the
username who changed it.

**Outside operating hours, or a special schedule applied.**

```sql
USE Communication;
SELECT TOP 10 * FROM SpecialSchedule WITH (NOLOCK)
WHERE IsActive = 1 AND CAST(Date AS DATE) = 'yyyy-mm-dd'
ORDER BY 1 DESC;
```

`BrandId 0` means it applies to all number lines. If a row returns, check whether the current
Australian time is outside `OperatingStart` and `OperatingEnd`.

```sql
USE Communication;
SELECT * FROM OperatingHours WITH (NOLOCK) WHERE DayOfWeek = <dayofweek> AND IsActive = 1;
```

- `BrandId`: the number's brand ID from the Configuration table.
- `ConfigurationSettingId`: line type. `1006` = Partner line, `1005` = Customer line,
  `1001` = Brand line.
- `DayOfWeek`: 1 to 7, Monday = 1, Sunday = 7.
- `From` and `To`: 24 hour format (hh:mm).

Most numbers now use the `OperatingHours` table, so the deployed config file rarely needs
checking.

## Activate / deactivate a live campaign

Urgency HIGH · Impact MEDIUM.

```sql
USE Communication;
SELECT * FROM CampaignHeader WITH (NOLOCK) WHERE LiveCampaignId > 0 AND [Name] = '<campaign name>';
```

`CampaignStatusId` should be `0` for a live campaign. Other values:
- `1` = Open, but will be marked completed soon because there is no pending list in
  `CampaignDialer`; numbers and customers are fetched in real time.
- `2` = Cancelled, `3` = Completed, `4` = Closed.

To activate: confirm `CampaignHeader.LiveCampaignId` exists in the `LiveCampaign` table, and
that the stored procedure named in `LiveCampaign.Query` exists in the `Communication` database
(Twilio runs it to get the call list). Then:

```sql
USE Communication;
UPDATE CampaignHeader SET CampaignStatusId = 0 WHERE CampaignHeaderId = <campaign_header_id>;
```

To deactivate:

```sql
USE Communication;
UPDATE CampaignHeader SET CampaignStatusId = 3 WHERE CampaignHeaderId = <campaign_header_id>;
```

## Outbound Campaign - No Application Id

Urgency MEDIUM · Impact MEDIUM. Agent cannot see the customer's application id. Check whether
the agents are using V2. (The source page is incomplete here: no related ticket recorded.)

## Questions to ask before endorsing

- Names of the agents affected
- Estimated date and time the issue was encountered
- Number of the caller / receiver

## Urgency and impact guide (used across the Comms runbooks)

- **Urgency:** HIGH = the affected user can no longer perform primary work functions.
  MEDIUM = work functions impaired but a workaround exists. LOW = an inconvenience.
- **Impact:** HIGH = system wide problem (business unit, department, area/location).
  MEDIUM = multiple users. LOW = single user.

---
