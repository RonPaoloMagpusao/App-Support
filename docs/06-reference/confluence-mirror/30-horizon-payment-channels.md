# Horizon: Payment Channels

Mirror of the Confluence page "Horizon: Payment Channels".

Last reviewed: 23 September 2026
Sources: Confluence HOR page 1772126209, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: HOR · Page id: 1772126209 · Last updated: 3 Apr 2025 · Author: Evangelia Liaros
- URL: https://moneyme1.atlassian.net/wiki/spaces/HOR/pages/1772126209/Payment+Channels

| Initiator | Payment type | Details |
| --- | --- | --- |
| Customer | **Payment Portal** | The payment portal URL is used in all comms: reminder SMS/email, collection comms, default notices (email versions), and comms manually sent by agents. The link is shortened for SMS/email and redirects to the payment portal. No login required, but each URL is unique to the application ID. |
| Customer | **ECA (Web) - Card Payment** | Login required. Choose debit card or direct debit. Payment types: Partial ("Pay my next payment"), Custom ("Pay a custom amount"), Full ("Pay full balance"). |
| Customer | **ECA (Web) - Direct Debit** | Same options. ECA still allows a customer to pay via DD for their next payment; this is intentionally disabled in the mobile app because of cancellation and pending time problems when customers pay early close to the submission time of their next payment. |
| Customer | **Direct Credit (bank transfer)** | Customer transfers to MoneyMe's account. Name: MONEYME, BSB 062104, Account 10233152. Process: daily downloads of CommBiz transaction data; a batch upload file is created by Raina and remaining unallocated payments are shared with Ops for manual allocation. |
| Customer | **App - Card Payment** | Login required. Partial, Custom, Full. |
| Customer | **App - Direct Debit** | Login required. Custom and Full only. |
| Agent | **Over the phone - Card Payment** | The agent uses a built in payment page in the Twilio window while on the phone. This arrives in Horizon as an "ECA User" payment with a **blank** Payment Type. Source can be identified in the back end by the dev team. |
| Agent | **Over the phone or email / LC request - Direct Debit** | The agent creates a direct debit on Horizon's transaction page following a customer request. |

Direct Credit caveat recorded on the page: this channel is harder to pin down because other
direct credit upload types come into Horizon the same way:
- **Dividends from external arrangements.** External hardships, external debt collectors or
  debt agreement facilitators pay periodic amounts to MoneyMe and these are uploaded via this
  channel.
- **BPAY payments.** SocietyOne used to offer BPAY; MoneyMe does not support it, but we
  reconcile stray BPAY payments that land in the SocietyOne payment account from open accounts
  and allocate them.

## Identifying the channel

**Direct Credit:** look for payment type "Direct Credit" added by the payment upload tool with
status Cleared. Narrow further by file upload title "DC Upload", or by upload agent (Raina) at
`https://horizon.moneyme.com.au/PaymentFileUpload/PaymentFileUploads`. Also look for payment
type "Direct Credit" added by agents directly with status Cleared.

**Self service payments (ECA):** identify the selection from the Payment Type captured on the
transaction receipt/note. A note is posted to the account after each payment, in addition to
the transaction records (MoneyIn entry, Eway log).

- Card, Payment Type **Payment Portal**: they used the payment portal link.
- Card, Payment Type **Partial**: they selected "pay my next payment".
- DD, Payment Type **Custom**: they nominated a custom amount.
- DD, Payment Type **Full**: they nominated to pay a full payment.

Payments made via the mobile app or via the Twilio integration channel appear with a **blank**
Payment Type; back end tables distinguish the source.

---
