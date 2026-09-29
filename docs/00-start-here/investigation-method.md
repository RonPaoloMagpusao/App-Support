# Investigation method

How App Support investigates a ticket, from triage to closure, and how to write back to reporters, Slack and Jira.

Last reviewed: 23 September 2026
Sources: Ron Magpusao's working method (Claude project instructions, investigation handover notes 11 September 2026); Confluence 16 "Guide on Assessing a Support Ticket" and 20 "App Support Ticket Triage" (see [../06-reference/confluence-mirror/](../06-reference/confluence-mirror/README.md))

## The loop

Triage, then reproduce, investigate, fix or escalate, communicate. Define acceptance criteria before closing.

### 1. Triage (minutes, not hours)

Score quickly on four questions, loosely RICE:

| Question | Ask |
| --- | --- |
| Reach | One customer, one broker, one product, or everyone? Could a batch have hit others? |
| Impact | Is money moving wrongly, is a customer being charged, is there a complaint, IDR or AFCA? Is personal data exposed? |
| Confidence | Do you have hard evidence yet, or only the reporter's description? |
| Effort | Known runbook fix, datafix, or needs a developer? |

Anything that moves money wrongly, involves a direct debit, or has a complaint attached is urgent regardless of what the MHD Priority field says. Set Urgency accordingly and say on the ticket if Priority looks wrong for the risk.

### 2. Reproduce

- Find the application in Horizon and see the thing the reporter saw.
- Find a **second example** before declaring a rule broken. Rusty has been caught by two invalid examples on the same day.

### 3. Investigate

In this order:

1. **Pull the ticket** and every linked ticket.
2. **Check Horizon for hard evidence**: stage and status logs, transactions (including the Submitted column), amortisation, tasks, comms, notes. Screenshots or IDs, not impressions.
3. **Search MHD for precedent** before concluding: [../06-reference/mhd-precedent-index.md](../06-reference/mhd-precedent-index.md) and a Jira JQL search. Many "new" problems are the fourth instance of an old one.
4. **Check the rulings**: [../05-knowledge/working-as-designed.md](../05-knowledge/working-as-designed.md) and [../05-knowledge/rusty-rulings.md](../05-knowledge/rusty-rulings.md).
5. **Verify the arithmetic independently** wherever money is involved. Recalculate instalments, fees and balances yourself rather than trusting a screen.
6. **Write down what you could not verify.** State it plainly on the ticket rather than glossing over it.

Watch for the recurring shape: **fixed for one product, never scoped to the others.** CRD has auto-cancel on early payment, APY does not; the iOS term display was regressed to match an Android bug.

### 4. Fix or escalate

- Runbook fix: follow [../02-runbooks/](../02-runbooks/README.md).
- Datafix: [../03-procedures/datafix-request.md](../03-procedures/datafix-request.md) and [../04-sql/README.md](../04-sql/README.md).
- Defect: raise a Problem with evidence, precedent keys and a proposed owner from [../05-knowledge/escalation-map.md](../05-knowledge/escalation-map.md).
- Systemic risk: ask for the batch query that sizes the population. One customer calling usually means others have not called yet.

### 5. Communicate

- **Internal Jira comment** with the evidence, the root cause, the fix and what was not verified. Internal comments are restricted to the Service Desk Team role; the API sets the role but still returns `jsdPublic: true`, so check the internal toggle in the UI.
- **Reply to the reporter in plain language.** No template IDs, API names, table names, code or internal jargon. What happened, what was done, what the customer will see.
- **Draft first, post on approval** when posting to Jira or Slack on someone else's behalf.

### 6. Close

Define acceptance criteria **before** closing, and confirm each is met: refund processed, customer notified, datafix verified, defect raised. The five business day auto-close will close a ticket whose criteria are unmet; do not let it.

## House formats

### Test results

```
Test Result:
AUT:
Browser Used:
Test Environment:
Test Evidences:
Notes:
```

Worked example in [../03-procedures/release-and-uat.md](../03-procedures/release-and-uat.md).

### Slack updates

Short, checklist form, pass and fail markers:

```
MHD-XXXXX update
[PASS] Funding record reprocessed
[PASS] Stage moved to Fund Sent
[FAIL] Customer SMS not delivered, checking Twilio
```

### Investigation comment

Structure used on MHD tickets: see [../03-procedures/jira-conventions.md](../03-procedures/jira-conventions.md).
