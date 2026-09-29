# Sendgrid

Mirror of the Confluence page "Sendgrid".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1060864395, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1060864395 · Last updated: 4 Sep 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1060864395/Sendgrid

1. Log in to SendGrid to check the email in question. SendGrid sends an OTP to your phone
   number as second factor.
2. On the homepage, click the **Activity** tab on the left side of the page.
3. On the Activity tab, enter the email address you want to investigate in the search area.
   You will see all emails sent to that customer with the email information and details. To
   remove the blockage, follow the suggested steps on the event history.

Supplement from the Cover Runbook (page 3131015188), section 06: the suppression lists that
matter are **Bounced**, **Blocked** and **Spam Reports**. Once an address lands on one, every
future email to it fails silently and the send path keeps retrying. Remove it from the list and
ask the requester to retry. There is no self serve button in Horizon; MHD-35799 requests one and
is still Pending.

---
