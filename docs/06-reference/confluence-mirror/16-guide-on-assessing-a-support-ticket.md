# Guide on Assessing a Support Ticket

Mirror of the Confluence page "Guide on Assessing a Support Ticket".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1002766337, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1002766337 · Last updated: 11 Sep 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1002766337/Guide+on+Assessing+a+Support+Ticket

Instructions for assessing App Support tickets for Twilio and Comms.

## Information to collect

**Twilio**
1. Name of the agent or agents experiencing the issue
2. Date and time the issue occurred
3. Location of the agent
4. Number called by the customer if it is an incoming call, or the name of the number the agent
   is calling if outbound

**Comms**
1. ApplicationID
2. Date and time
3. TemplateId
4. Optionally CustomerId

Then: get screenshots if applicable; ask how many are affected and whether a workaround exists
(and if so, how hard it is); update the priority based on the assessment; investigate and place
the findings in the ticket.

## Twilio triage

1. Check the network at https://networktest.twilio.com/ if one to three agents are affected,
   especially if they are in one location (for example the Ortigas office or the Newcastle
   office). If it is a network issue ask Marco for help. If working from home, ask for a speed
   test.
2. Check https://status.twilio.com/ if the majority of calls are affected and there was no
   prior release. If there is an ongoing Twilio issue, inform the Ops team and give the
   estimated time of resolution if the site shows one.
3. Check for slowness or issues on: Horizon; the databases (Horizon2 and Communication); a
   spike in resources (check CPU usage, check the log for continuous errors, reach out to
   Julius).
4. Check Sentry logs if you have access:
   - Twilio Web: `https://societyone.sentry.io/projects/twilio-web/?project=6704642`
   - Azure Table: `livemoneymestorage` > `TwilioLogException`
   - Log the first instance of the error and flag the Comms Team, but it can be ignored.
   - Monitoring tool: Azure App Service. (Page notes a TODO to push this into Sentry, owner
     Julius.)
   - If the error occurs five times, the Comms Team needs to step in.

Cross reference: `[G4-Twilio] Known Issue and Resolution`, TECHNOLOGY space page 441417732.

## Comms triage

Check:
- Sentry: `https://societyone.sentry.io/projects/comms-api/?project=6704643`
- SendGrid: `https://app.sendgrid.com/`
- Twilio Console: `https://console.twilio.com/`

Cross reference: `[G4-Comms] Known Issue and Resolution` (TECHNOLOGY page 453509121) and
`[G4-Comms API] Support` (TECHNOLOGY page 989069465).

The page closes by asking requesters to provide this information in the ticket before assigning
it to App Support, and to set the priority based on App Support's assessment.

---
