# Login, passcode and account access

Customers who cannot log in or reset their passcode, blocked accounts, and staff who cannot reach a Horizon tab.

Last reviewed: 23 September 2026
Sources: Confluence 3131015188 section 11, Confluence 3117842457 Pattern A and B, Confluence 1398210569, Confluence 2485059655, Confluence 546701313, MHD issue catalogue theme 3, team procedures (Slack) section 3

"Unable to login" is the single most common summary line in the whole MHD project
(MHD issue catalogue theme 3). Counted with OTP cases it is about 39 tickets a year, a top-five
item, and most login work never becomes a ticket because unblocks run through G3APIBot
(Confluence 3131015188). SMS delivery problems are in [sms-otp-and-voice.md](sms-otp-and-voice.md).

## Symptoms

- "Unable to login" / "Cannot login" / "Log in"
- "We have a customer unable to login to the app. No duplicate mobile/email found."
- "Unable to reset the passcode | <brand> | <app id>"
- "Unable to login or reset password" / "Forgot Password Request - Unsuccessful"
- "There is an issue with this account" on entering email and mobile
- "Multiple active account found" / "Multiple Inactive account found"
- "invalid code" after entering the 4-digit code
- "Customer is blocked after too many passcode attempts"
- "Customer can log in on web but not on the iOS app"
- "Customer without a credit card is being asked about a credit card on login"
- "Can't log in with their email" (and the account is OzMoney, MOM or Autopay)
- "Account details on the Customer tab show N/A"
- Staff: "can't see the tab", "access denied", "no partnership portal access", "locked out of Horizon"

## Triage, in order

1. **If the customer is simply locked out from too many passcode attempts, use G3APIBot.** Post one
   line in `#unblock-account-request`: `reset {customer email address}`. Lowercase `reset`, then
   the email, nothing else. The bot replies "Picking this up" then "Reset complete", typically
   within 2 to 4 seconds. No ticket needed (team procedures (Slack) 3). But see step 6 before firing it
   repeatedly.
2. **Run the login diagnostic before deciding anything.** Common Login SQL Data Fix Scripts item 1
   (Confluence 1398210569) takes one ApplicationId and returns Application and Brand, every
   `CustomerAccount` row (`BrandId`, `Username`, `IsActive`, `LastLoginDate`,
   `LastLoginAttemptDate`, `IsMobileVerified`, `IsPINChanged`), every `CustomerContactNo` and
   `CustomerEmail` row, plus a fuzzy username join that surfaces sibling customers sharing the
   email. No stored procedure does this. It is the single most useful diagnostic in the tree
   (Confluence 3117842457). Template in [../04-sql/diagnostics/](../04-sql/diagnostics/).
3. **Work the Cover Runbook checklist, in this order** (Confluence 3131015188 section 11):
   1. Duplicate customer account, duplicate mobile or email. The most common real cause.
   2. Mismatch between the mobile number and email on the account.
   3. Empty or NULL password.
   4. Last login attempt in the DB and whether it succeeded. Login history is only visible
      **within 7 days**.
   5. FullStory session replay, which shows where the customer actually stopped.
4. **Check the brand.** MME, OzMoney and Autopay logins are separate, and `CustomerAccount` is
   keyed on (Username, BrandId). "Can't log in with their email" on an OzMoney, MOM or Autopay
   account is usually brand confusion (MHD-35866). For a migrated customer, check whether an MME
   account row exists at all (MHD-35589).
5. **Check the BrandId 1 account is active.** If the MME account has `IsActive = 0`, that is the
   fault (Confluence 546701313, MHD-14985).
6. **For a passcode reset loop, read Application Comms.** The normal flow is: the customer requests
   a reset and **email template 970** goes out; the customer taps the CTA and **SMS template 969**
   delivers the 4-digit code; the customer enters it. If 969 never sent, the customer never reached
   the button, which is usually rendering or trimming at their end, not a send failure
   (MHD-36075).
7. **If the ticket mentions an email change at all, treat `CustomerAccount` as in scope.**
   `CustomerEmail` can be correct while `CustomerAccount.Username` still holds the old address, so
   login and passcode reset still fail. That is why "email updated" tickets come back
   (Confluence 3117842457 Pattern A, MHD-35641).
8. **Check the merge history.** A prior duplicate ID datafix can leave the login path pointing at
   the wrong record (MHD-34426).

**Two things that mislead people constantly** (Confluence 3131015188 section 11):

- The verification code is **always SMS, never email**.
- A "successful login" in our data only means the **password was accepted and they reached the OTP
  step**. It does not mean they got in. Quoting a successful login timestamp at Ops without that
  caveat causes arguments.

## Root causes seen

1. **Duplicate `CustomerAccount` rows on the same (Username, BrandId).** Both
   `ChangeCustomerPasscodeAsync` and Web2 forgot-password abort on a `Count() != 1` check, which is
   what produces "Multiple active account found" or "Multiple Inactive account found". Login reads
   are non-deterministic while duplicates exist, so the customer can even be authenticated against
   the wrong row (Confluence 3117842457 Pattern B). Three sub-cases:
   - **B1, genuine duplicate for the same customer.** Parent page item 28: if the duplicate has a
     Credit Score only (from March 2024 backwards), rename its username so Mobile cannot pick it
     up as the validated credentials.
   - **B2, Username not equal to email.** Parent page item 77: "Multiple Inactive account found;
     the error shows when the username and the email address are different. Update the Username."
   - **B3, `wagtest*` or other test customers squatting the username in production.** The
     MHD-35810 / PER-8863 shape. It needed a Change Request.
2. **Two customer records for one person.** Separate CIDs, one carrying the mobile number and one
   without, and the API pulls the record missing the phone number. Horizon creates a new customer
   record instead of matching the existing one at application time (MHD-34750).
3. **Missing MME account row on a migrated customer.** MHD-35589: an OzMoney CRD customer migrated
   across hit "There is an issue with this account" on every login attempt. Michael Dela Torre:
   *"Initial Investigation: No MME account. Resolution: Insert MME account."* A recurring migration
   gap.
4. **MME account inactive**, `IsActive = 0` on the BrandId 1 row (MHD-14985).
5. **Login username left behind after an email change** (MHD-35641).
6. **Mobile app defects.** A PL-only customer served a CRD prompt on login (MHD-34604,
   MMM-15339). A customer who can log in on web but not on the iOS app (MHD-35643).
7. **Mail client trimming, not a defect.** Identical template 970 emails threaded and collapsed by
   Gmail (MHD-36075). See [email-delivery.md](email-delivery.md).
8. **Customer-side SMS blocking.** The OTP was delivered and the customer has MoneyMe blocked or
   spam-filed. The most common outcome overall (Confluence 3131015188 section 11).

## The fix

| Root cause | Action |
| --- | --- |
| Locked out after passcode attempts | **No action beyond G3APIBot**, `reset {email}` in `#unblock-account-request` |
| B1 genuine duplicate | **Datafix**, rename the losing row's username, for example `x@y.com_duplicate`, via `AppSupport_UpdateCustomerAccount` keyed on both `@CustomerId` and `@CustomerAccountId`. Not the raw UPDATE on the page, which omits the `CustomerAccountId` predicate and rewrites every brand row |
| B2 username not equal to email | **Datafix**, same procedure, set the username to the real email |
| B3 test customer squatting | **Escalate** for a Change Request. Not a routine datafix |
| Two customer records | **Datafix**, `AppSupport_MoveAppToCustomer @ApplicationId, @CustomerId`, then `EXEC dbo.UpdateAmounts @ApplicationId, 1`. The procedure raises an error on zero rows, which is your safety net against a wrong ID |
| No MME account | **Datafix**, `AppSupport_InsertCustomerAccount` (procedure 8). Password value is `[CREDENTIAL REDACTED]` and must be supplied by the operator in their own session |
| MME account inactive | **Datafix**, `AppSupport_UpdateCustomerAccount` with `@IsActive = 1`. Read the warning below first |
| Login username left behind | **Datafix**, `AppSupport_UpdateCustomerAccount`. Read the warning below first |
| Brand confusion | **No action.** Tell the requester which portal to use. If they changed their email it must also be changed on an MME application to sync (MHD-35866) |
| Mobile app prompt or platform defect | **Escalate** to `#app-support-mobile-team` with the application note link and the MHD ticket, cc Aus, Paul, Stefan |
| SMS blocked or spam-filed | **No action.** Tell Ops to have the customer search for "MONEYME" and check Spam & Blocked. Paste the delivery log and last login timestamp as evidence and close |
| G3APIBot down | **Escalate** to the G3 team, Albert Rick Martires and Daryll Felipe. There is no fallback command. Precedent `#api-to-fe`, 2026-09-01, where a human posted on the bot's behalf |

**`AppSupport_UpdateCustomerAccount` is the most damaging procedure in the catalogue to run
carelessly.** It is a flat `UPDATE CustomerAccount SET BrandId, Username, Password, IsActive` and no
parameter has a default. There is no "update just the username" mode. You must supply `@Password`;
omitting or guessing it silently resets the customer's web portal **and** mobile app credential.
`@BrandId` must be the row's real current brand, or the login moves to another brand. Never print,
log or comment a `Password` value. The operator reads the existing encrypted value in their own
session and fills it in (Confluence 3117842457, Confluence 2485059655).

**It does not fix passcodes.** There is no passcode column and no passcode procedure. "Customer
can't reset their passcode" is Pattern B above (Confluence 3117842457).

**Avoid Common Login item 5.** "No MME account active" omits `CustomerAccountId` from the WHERE
clause, so it rewrites every brand row for that customer (Confluence 1398210569). The same bug is in
parent page items 5 and 35.

### Staff access to Horizon

"Can't see tab", "access denied", "AFCA arrangement tab" is `AppSupport_InsertRoleAccess`
(procedure 13). Known values: `TabId 295` is Stages_AFCA_Arrangement, `296` is
Stages_AFCA_Arrangement_Broken, `AccessLevelId 1` is View. Look up `webpages_Roles`, `Tab` and
`RoleAccess` first (Confluence 3117842457). "Staff locked out of Horizon" and "no partnership
portal access" are raw script territory, parent page items 44, 72, 76, 94. **Items 44 and 94 embed
real hashes and plaintext staff passwords** (`[CREDENTIAL REDACTED - see Confluence page
519602304]`). Do not copy them. Flag it as a hygiene problem instead.

## Not a defect

- **Repeated `reset` commands for the same email in `#unblock-account-request`.** Normal and
  harmless to the account. The same email reset twice within 10 minutes is common, because the
  customer is still failing the passcode. Do not raise a ticket (team procedures (Slack) 3.3).
  **Tension with MHD-36075:** repeated resets do not harm the account, but each identical reset
  email deepens Gmail's trimming, which is what made the customer on MHD-36075 think the emails
  were empty. Both are true. If the customer reports empty emails, stop resetting and coach them to
  open the first email in the thread.
- **"SMS not received" with Twilio showing sent.** Almost never us (Rusty, `#app-support`,
  2026-09-03).
- **A logged "successful login" when the customer says they never got in.** It only means the
  password was accepted (Confluence 3131015188).

## Precedents

- MHD-35589: migrated OzMoney CRD customer 664818, LID 10002954051, no MME account, inserted.
- MHD-36075: application 10002487161, empty-looking reset emails, Gmail trimming.
- MHD-34750: duplicate production accounts, merged to resolve a Forgot Password error.
- MHD-34426: login failure after a duplicate ID fix.
- MHD-34604, MMM-15339: CRD prompt on a PL-only customer.
- MHD-35643: web works, iOS app does not, application 10002062136.
- MHD-35866: brand confusion on an email update.
- MHD-35641: login username left behind after the email was changed.
- MHD-35810, PER-8863: test customer squatting a production username.
- MHD-14985: MME account inactive.
- MHD-29695: "Investigate Blank Temporary Code Issue", closed with a one-off datafix rather than a
  code change.
- MHD-36186, MHD-35475, MHD-35418, MHD-35136, MHD-33414, MHD-33257, MHD-32677, MHD-32518,
  MHD-32114, MHD-36338, MHD-36268, MHD-36193, MHD-36010, MHD-35955, MHD-35867, MHD-35853,
  MHD-35644, MHD-35478, MHD-35307, MHD-35278, MHD-35263, MHD-35120, MHD-34687, MHD-34530:
  further login and passcode tickets, root cause not verified.

## Open defects

- **The "invalid code" on MHD-36075 was never explained.** The SMS with the code was Delivered at
  10:26, yet the customer's first attempt returned "invalid code". Expiry, mistype or a genuine
  validation defect was never determined. Ron asked the reporter to confirm and the ticket
  auto-closed after five days. Unverified whether it is the same mechanism as MHD-29695. A second
  instance with FullStory replay would settle it.
- **Template 970 renders "Reference number 0"** instead of the application ID. No ticket.
- **Migrated customers arriving without an MME account row** is a recurring migration gap with no
  ticket against the migration itself (MHD-35589).
- **Horizon creates a new customer record instead of matching the existing one** at application
  time, which is what produces the duplicates in root cause 2 (MHD-34750). No ticket found.
