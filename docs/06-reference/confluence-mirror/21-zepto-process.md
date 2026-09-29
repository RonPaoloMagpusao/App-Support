# Zepto Process

Mirror of the Confluence page "Zepto Process".

Last reviewed: 23 September 2026
Sources: Confluence AS page 580845583, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 580845583 · Last updated: 6 Feb 2024 · Author: Julius Serrano
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/580845583/Zepto+Process

MoneyMe connects to **Zepto** to send Funds and to run Direct Debit for customers.

## Funding and direct debit process

- We create a profile/account for the customer in Zepto so we can send funds and direct debit.
- When we fund the customer we send the details and the funds, then pass the ID, since the
  customer should have an account in Zepto for us to fund them.
- We have a webhook set up in their portal to drive the process.

## What we send to Zepto

- A profile/account for the customer, so we can fund and direct debit.
- Customer personal information: name, email, bank sort code and account number.

## How we send customer information to Zepto

- Before we can send a request there is an OAuth2 authorisation process implemented to connect
  to their service/API.
- Zepto's API is protected by OAuth2; we need credentials from them, set up on their portal.
- The OAuth account is set up in their portal; we hold an admin account there to do this setup.

## Security implementation

- We use **IP whitelisting** for our API that Zepto connects to; their static IP is whitelisted.
- Zepto connects to us via **webhook**. We provide the endpoint in their portal, and an **HMAC**
  hashing algorithm verifies payload integrity.
- The endpoint is publicly available but protected by IP whitelisting plus HMAC.
- Other endpoints in the API are not accessible to Zepto because of the OAuth2 authorisation
  process; they would need credentials.

---
