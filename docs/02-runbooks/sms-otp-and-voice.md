# SMS, OTP and voice

SMS and OTP codes that do not arrive or go to the wrong number, and Twilio voice problems for agents.

Last reviewed: 23 September 2026
Sources: MHD issue catalogue theme 3, team procedures (Slack) sections 7.2 to 7.5, Rusty's rulings (Slack) section 13, Confluence 3131015188 sections 06 and 11, Confluence 1079181314, Confluence 1079312385

149 Problems on `OTP OR SMS OR Twilio` in the window, overlapping with login (MHD issue catalogue
theme 3). Login and passcode failures that are not a delivery problem are in
[login-passcode-and-account-access.md](login-passcode-and-account-access.md).

## Symptoms

- "Not receiving OTP when submitting an application"
- "Cannot receive SMS code" / "Unable to receive SMS verification code"
- "OTP sending failed" / "OTP Failed - getting a quote"
- "SMS status showing undelivered"
- "Code being sent to incorrect mobile num"
- "SMS verification code is being sent to MOB ending in 000"
- "Received an OTP without attempting to log in" / "Unauthorised OTP"
- "Agent gets disconnected when receiving an inbound call"
- "No inbound calls received"
- "When we answer, the wrong customer's account opens"
- "The card payment screen sits on 'processing' after the call has ended"
- "Twilio call recording issue"
- "Outbound campaign shows no application ID"

## Triage, in order

### SMS and OTP

1. **Confirm in Twilio that the SMS was sent without errors, and check delivery status.** If it
   was, it is almost never us. Rusty, `#app-support`, 2026-09-03: *"This (Like most 'SMS not
   received' issues) was not an issue on our side."* Ron, 2026-08-26: *"Also confirmed in Twilio
   that the SMS were sent without errors. It's possible that the SMS is in the spam?"*
2. **Check `HorizonSmsStatusLog`** for the message status response:
   `SELECT * FROM Communication.dbo.HorizonSmsStatusLog WHERE MessageId = <messageid_from_message_table>`
   (Confluence 1079312385).
3. **Check status.twilio.com** for an unresolved SMS incident in APAC (Confluence 1079312385).
4. **Check which number the code went to.** Pull every `CustomerContactNo` row for the customer,
   all brands, and look for more than one active row or a row on the wrong brand
   (Confluence 3117842457 Part 3). Unverified: for "sent to MOB ending in 000", check whether the
   active row is the `0400000000` placeholder used to neutralise wrong numbers (MHD-35960). The
   root cause of MHD-35025 was not read during harvest, so opening that ticket would confirm or
   rule this out.
5. **Check whether the send was muted** by `CommsMuteRule` via `usp_CanCustomerBeContacted`
   (Confluence 1079312385).
6. **Check `#forgot-pin-spam-alert`** in Slack for rate-limit hits on the customer
   (MHD issue catalogue theme 3).
7. **Use FullStory session replay** to see where the customer actually stopped. In one case it
   showed the SMS was triggered and the customer never entered the code
   (Confluence 3131015188 section 11).

### Voice

1. **Check https://status.twilio.com** for a live Voice incident, APAC if region-specific. Real
   precedent: incident `57141rz6lhv2`, Voice Call Failures, Post Dial Delay, Silent and One-Way
   Audio, August 2026 (team procedures (Slack) 7.5).
2. **Have the agent run https://networktest.twilio.com/** and pass both the NTS and Voice tests.
   The output pastes straight into the channel. Also confirm the Twilio site has microphone
   permission; a blocked microphone ends the call automatically (Confluence 1079181314). The Cover
   Runbook's standing instruction is to ask the reporter for a network test **before** raising to
   the Comms team (Confluence 3131015188).
3. **Find the call in Twilio > Call Log** (Haze, team procedures (Slack) 7.5).
4. **Query `Communication.dbo.EventLog`**, which doubles as the error log for all Twilio responses,
   filtered on `CreatedbyUser` and date (Confluence 1079181314). Keywords: `ConnectionError`,
   `TransportError`, `AccessTokenInvalid` (connection or token), `HangupWhenCustomerNotAround`
   (the customer had already dropped), `Agent *** disconnected on twilio ***` (unstable agent
   internet, or VPN connect or disconnect mid-call).
5. **For no inbound calls**, check in this order: the agent's inbound grouping (Admin > User >
   Search User), whether the number was switched off
   (`Communication.dbo.[Configuration] WHERE SettingId = 1002 AND IsActive = 1`, `Value = False`
   means off), then `SpecialSchedule` and `OperatingHours` for the day (Confluence 1079181314).
6. **For the wrong customer opening**, look for the same phone number on two customer records.

## Root causes seen

1. **Customer-side spam filtering or blocking.** The largest single bucket. Delivery logs show every
   OTP delivered; the messages were spam-filed or blocked customer-side (MHD-35362, application
   10002405188). Customers with poor repayment history often block us deliberately, which is why
   delivery shows successful on our side and they still see nothing (Confluence 3131015188
   section 11).
2. **Carrier-side delivery.** MHD-31787, application 10002223282: the carrier (Optus) claimed the
   messages never reached their network while internal logs showed successful delivery. Raised
   directly with Twilio, who confirmed working as expected.
3. **Customer opted out of SMS.** There is no way for us to check the opted-out list ourselves;
   Twilio support can generate it (Confluence 1079312385).
4. **Mobile number mismatch or duplication.** "Mobile number/Email does not match on our system"
   (MHD-36210). Duplicate mobile associated to two customers (MHD-32624). Code going to a
   different mobile (MHD-33863, MHD-33724).
5. **Twilio voice routing collision.** Twilio routes calls by the phone number registered to an
   application. Ron's diagnosis, 2026-07-13: *"app 10001591341 was the original account using the
   number ..., and 10002927069 was later updated to the same number, causing the conflict."*
6. **Card payment window timeouts.** When the payment window times out, Twilio can still be waiting
   on a delayed callback in the background, so the screen sits on "processing" until after the call
   has ended, and sometimes the payment clears after the fact. Error categories in the logs were all
   input or entry issues: `timeout`, `invalid card number`, `wrong expiry date`, `caller
   interrupted the call` (Ron, `#twilio-team`, 2026-08-27).
7. **Inbound number switched off.** Find who changed it:
   `SELECT TOP 10 * FROM Communication.dbo.EventLog WHERE LogDetails LIKE 'Updated Inbound Config to%' ORDER BY 1 DESC`.
   `CreatedByUser` is the username (Confluence 1079181314). Twilio's `BrandId` is custom: `11` maps
   to brand 1 (MME).
8. **Outside operating hours or a special schedule applied.** `BrandId 0` in `SpecialSchedule`
   applies to all lines (Confluence 1079181314).

## The fix

| Root cause | Action |
| --- | --- |
| Spam or blocked | **No action.** Tell Ops: ask the customer to search their SMS app for messages from **"MONEYME"**; on Android, Google Messages > profile icon > **Spam & Blocked**. Paste the delivery log and last login timestamp into the ticket as evidence and close. Do not write a datafix (Confluence 3131015188 section 11) |
| Carrier-side | **Escalate** to Twilio, expect "working as expected", close as no defect and tell the customer to check with their carrier (MHD-31787) |
| Opted out | **Escalate** to Twilio support for the opted-out list |
| Wrong, duplicate or extra active mobile | **Datafix**, `AppSupport_UpdateCustomerContactNumber` (or set `@IsActive = 0` on the extra row). See [customer-and-company-data.md](customer-and-company-data.md) |
| Voice routing collision | **Datafix**, remove or change the duplicate number on one record |
| Card payment timeout | **No action.** Input or entry issues. Check whether the payment cleared late before advising a retry |
| Number switched off | **Config change**, turn it back on by DB script or ask the Twilio product owner to do it in the Twilio app |
| Agent grouping wrong | **Config change**, the agent's supervisor or the Twilio product owner updates the group |
| Twilio incident | **Escalate**, tell Twilio's product owner or the G4 PM. Nothing can be done locally until it clears |
| Nothing above fits | **Escalate.** Raise a Twilio Support ticket at help.twilio.com and post the link in `#twilio-team` |

Escalation path for Twilio (team procedures (Slack) 7.5): `#twilio-team` (agent-facing), then
`#twilio-tech-app-support` or `#app-support-twilio-comms` (created 2026-04-01 by Haze for handover
between Tech Support and App Support), then Haze (Hazelrey Cate Erasmo), then
`#twilio-tech-ops-workgroup`. The Cover Runbook names the Comms team as Jap and Aina
(Confluence 3131015188). Reference pages: Twilio Tech Support (Confluence 2725150760) and
[G4-Twilio] Known Issue and Resolution (Confluence 441417732). New Twilio users are onboarded via an
MHD ticket titled `[Twilio] New User - {name}`.

Before endorsing a voice issue, collect: names of the agents affected, estimated date and time, and
the caller or receiver number (Confluence 1079181314).

## Not a defect

- **"SMS not received."** *"Like most 'SMS not received' issues, this was not an issue on our
  side"* (Rusty, `#app-support`, 2026-09-03). In that case the customer was somewhere very remote,
  and the application funded.
- **Carrier-side non-delivery with successful internal logs.** Twilio confirmed working as expected
  (MHD-31787).
- **Card payment "processing" after the call ends.** Delayed callback, not a Twilio or system fault
  (Ron, `#twilio-team`, 2026-08-27).
- **The verification code arriving by SMS rather than email.** It is always SMS, never email
  (Confluence 3131015188 section 11).

## Precedents

- MHD-35362: SMS login failure, application 10002405188, delivered, customer-side filtering.
- MHD-31787: carrier-side (Optus), raised with Twilio, no defect. Related MHD-31779, MHD-31736.
- MHD-32624: duplicate mobile number associated with two customers.
- MHD-33863, MHD-33724, MHD-35025: code sent to an incorrect mobile, root cause not verified.
- MHD-36210: mobile number or email does not match.
- MHD-30222: OTP delivery issue on the APY portal plus a Twilio call failure.
- MHD-34651: "error: timed out" on iPhone after 4-digit code entry.
- MHD-35238, MHD-35073, MHD-34257: Twilio call recording issues, root cause not verified.
- MHD-34985, MHD-29746, MHD-28686: unauthorised or unsolicited OTP and reset reports, root cause not
  verified.
- MHD-30759, MHD-27277, MHD-26592, MHD-27263, MHD-32266: Twilio inbound queue, outbound queue and
  call issues.
- MHD-35486, MHD-35030, MHD-34441, MHD-34121, MHD-33905, MHD-33818, MHD-33524, MHD-34105,
  MHD-31785, MHD-31437, MHD-31255, MHD-31174, MHD-30049, MHD-29578, MHD-29505, MHD-28993,
  MHD-36641: further SMS and OTP tickets.

## Open defects

- **Outbound Campaign, no Application Id.** Agents cannot see the customer's application ID. The
  only recorded check is whether the agents are using V2; the source page is incomplete and no
  ticket is recorded (Confluence 1079181314).
- **Twilio2 logging has moved from Sentry to Uptrace** (G1-6164, MHD-34768), as has
  MoneyMe.Communications (G1-6177, MHD-34989). If an expected Twilio alert is missing, check Uptrace
  before assuming there was no error.
- No other open Twilio or SMS defect was found in the sources.
