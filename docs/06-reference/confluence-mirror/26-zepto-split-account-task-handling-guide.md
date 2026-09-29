# Zepto / Split Account Task Handling Guide

Mirror of the Confluence page "Zepto / Split Account Task Handling Guide".

Last reviewed: 23 September 2026
Sources: Confluence OP page 2286321665, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: OP (Operations) · Page id: 2286321665 · Last updated: 24 Aug 2026 · Author: Simon Stefanovski
- URL: https://moneyme1.atlassian.net/wiki/spaces/OP/pages/2286321665/Zepto+Split+Account+Task+Handling+Guide

Covers two Horizon operational tasks: **Action – Check Split Account** and
**Error Split Create/Update Account**.

## 1. Action – Check Split Account

Generated when a payment fails with a **terminal Split error code**. Common codes:

| Code | Meaning |
| --- | --- |
| `incorrect_bsb` | Invalid BSB entered |
| `payment_stopped` | Customer or bank has stopped or blocked the debit |
| `account_closed` | Account no longer active, if surfaced by Split |

**Step 1.** Open the task, identify the error code, and read the customer notes for previous
contact attempts or historic bank account changes.

**Step 2, by error type.**

- `incorrect_bsb`: review supporting documents (bank statements, customer uploaded docs); if
  unclear, contact the customer for updated bank details; update in
  **Application → Bank Details**; confirm the details also updated in the **Debit Accounts**
  tab and that the Split account shows **Active**.
- `payment_stopped`: outbound call to the customer explaining the stop; ask them to remove the
  stop at their bank or provide new bank details; update **Application → Bank Details**;
  validate in the **Debit Accounts** tab.
- `account_closed`: contact the customer for a replacement account; update Bank Details and
  validate in the Debit Accounts tab.

**Step 3.** Confirm the Split account is active and the next scheduled debit aligns with the
updated details. Add a note covering the error code, actions taken, customer contact attempts
and updated details.

## 2. Error Split Create/Update Account

Appears when Horizon attempts to create or update a Split account and the creation fails at the
Split provider. Usually immediately after loan funding, when the first direct debit account is
being created, before any repayment schedule or transactions exist.

**Step 1. Close the task.** Closing it **forces Horizon to re-attempt** the Split account
creation. This is expected behaviour.

**Step 2.** Check the **Debit Accounts** tab; confirm an **Active** Split account now appears.
If it still has not populated after the retry, leave a note and escalate to Product Support or
Tech.

**Step 3.** Check the **Transactions** tab; ensure the repayment schedule has populated. If
not, re-check the Split account status, and escalate if it is still inactive or missing.

**Step 4.** Add notes covering: that the task was closed to trigger a reattempt; whether the
Split account is now active; whether the schedule has loaded; any follow up required.

## Accounts currently receiving manual repayments (DC/CC)

1. Some accounts look up to date because the customer is paying manually.
2. If an account has been making manual payments for **2 to 3 months**, update the payment
   method to match how they have been paying (DC or CC).
3. Send **Email Template 2017 - Switch to Manual Payments (Good Standing Order)**, replacing
   the default wording with: "We have tried to contact you and have been unable to get through.
   The bank account number we have on file is incorrect, and we are unable to process direct
   debit repayments. We have been receiving manual payments, therefore your default payment
   method has been changed to manual payments."
4. Clear the task and record notes, for example: "Attempts made to update bank details. Payment
   method changed to DC/CC. Email sent to customer."

If unsure why a payment failed or how to proceed, reach out to Simon Stefanovski or
jason.mcguire. Related reference: the OP space Zepto page (id 44597391), sections
"Rejected Payment Codes" and "Creating a Split Account".

---
