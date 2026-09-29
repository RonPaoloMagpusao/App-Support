# Security findings

Security and privacy problems found while building this repo. Page ids and titles only: no credential value appears anywhere in this repository.

Last reviewed: 23 September 2026
Sources: Confluence gaps review (section 1), Datafix catalogue 3117842457, investigation handover notes 27 August to 11 September 2026

## 1. Credentials published in Confluence

| Page | Title | What is exposed (type only) |
| --- | --- | --- |
| AUT 426082342 | APY Environments and Credentials | QA **and production** portal usernames with passwords in clear text (Broker Portal, Dealer Portal, AutoScan admin and state user accounts, DOF, Caravan); third-party credentials for EDX/PPSR (ESIS UAT), MoneyMe ID Kit and Illion; HTTP basic auth for the Amortization and Glass's Guide Swagger endpoints |
| AS 519602304 | SQL Data Fix scripts | An encrypted Horizon staff password with the plaintext in a comment beside it; a temp passcode hash; a hash passed to `DecryptTextNoPWD`; a PartnerUser insert with encrypted password and plaintext in a comment |
| AS 1398210569 | Common Login SQL Data Fix Scripts | A real encrypted customer password in the "create an account directly into the DB" sample |
| AS 2485059655 | Store Procedures for App Support | Real encrypted password values in the `AppSupport_UpdateCustomerAccount` and `AppSupport_InsertCustomerAccount` execute samples |

The Datafix catalogue (3117842457) already says "Never copy a password or hash out of the wiki... flag it as a hygiene problem instead." It was flagged and not fixed.

**Actions**

1. Rotate anything still live, starting with production portal accounts and third-party credentials.
2. Move credentials to the password manager.
3. Replace the samples with placeholders such as `'<ENCRYPTED_PASSWORD>'`.
4. The mirrors in this repo are redacted. A future automated Confluence sync would not be, so do not add one until the pages are cleaned.

## 2. Datafix backup tables hold customer data indefinitely

Every datafix leaves a `<Table>_MHD<number>` table in production with full customer rows, including encrypted bank account numbers. No owner, no retention rule, roughly 70 new fixes a month. Detail and an inventory query: [../04-sql/backup-table-hygiene.md](../04-sql/backup-table-hygiene.md).

**Action:** agree an owner and a retention rule with the data team and privacy.

## 3. Inbound email misrouting

Horizon routes inbound customer email to an application using the reference number in the subject line alone. It does not check that the sender has any relationship to that application.

Worked example (no ticket raised): a customer mistyped one digit of her reference. Her email landed on an unrelated customer's APY application. Consequences: her answer never reached her assessor, and her personal financial details are stored on a stranger's file. It was verified that MoneyMe never sent the wrong reference, so this is not a template fault.

**Actions**

1. Move the email to the correct application and remove it from the wrong one.
2. Raise the routing gap as a Problem: at minimum, compare the sender address to the application's customer emails and hold mismatches for review.
3. Check with whoever handles privacy incidents whether this is notifiable.

## 4. No Slack handling rules for App Support

Operations has rules for what may be posted about a customer in Slack (OP 264175641). App Support has none, yet routinely posts application IDs, customer IDs and script bodies, sometimes containing customer email addresses, into `#datascript-requests` and `#app-support`.

**Action:** adapt the Operations rules for App Support. Minimum: IDs are fine, customer names, emails, phone numbers and addresses are not, and scripts reference IDs rather than personal data.

## 5. Decrypt capability in the script catalogue

The legacy catalogue includes an item that decrypts a stored password "for investigation only" (AS 519602304, item 91, noted in [../04-sql/datafix-routing.md](../04-sql/datafix-routing.md)). Unverified: who can run it and whether its use is logged.

**Action:** confirm access controls and logging, or remove it from the catalogue.

## Rules for this repository

- It must stay **private**.
- Horizon application, loan, customer and transaction IDs may appear as worked examples.
- Customer names, email addresses, phone numbers and residential addresses must not. Use "the customer".
- No credential, hash, token, connection string or password, even encrypted, even in a comment. Use `[CREDENTIAL REDACTED]`.
- See [../../CONTRIBUTING.md](../../CONTRIBUTING.md) for the pre-commit check.
