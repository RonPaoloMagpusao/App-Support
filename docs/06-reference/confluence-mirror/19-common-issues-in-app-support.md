# Common issues in App Support

Mirror of the Confluence page "Common issues in App Support".

Last reviewed: 23 September 2026
Sources: Confluence AS page 546701313, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 546701313 · Last updated: 1 Dec 2025 · Author: Michael Dela Torre
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/546701313/Common+issues+in+App+Support

The older symptom to action triage table. Superseded in part by the Cover Runbook, but still
the quickest lookup for these seven symptoms.

| Ticket will say | Details / fix | Example |
| --- | --- | --- |
| "Unable to shuffle LOC" | Run the background shuffle script. If no frequency (Fortnightly/Monthly) is given, confirm with the requester | MHD-12686 |
| "Repayments too high" | Normally relates to fundamental LOC issues that cannot or will not be fixed. Assign to Josh Allen | MHD-12786 |
| "LOC arrears" | Can generally be filed and safely ignored, *except* if the arrears is very large, such as equal to the current balance, which may indicate a larger issue | |
| "Reverse WO / Write off" | | MHD-12322 |
| "Remove stage" | Normally accompanies a "Reverse WO" request, due to incorrect stage movement causing the write off and preventing future account access | MHD-12322 |
| Cannot / unable to login, OTP generation failed | 1. Check in the database whether the account has an MME account (BrandId 1), and whether the mobile number and email/username are correct. 2. Check whether the MME (BrandId 1) account has `IsActive = 0`; update to `IsActive = 1`. 3. Ask the reporter whether this solves the issue | MHD-14985 |
| Twilio issues | Initially ask the reporter for a network test before raising to the Comms Team (Jap / Aina / Slack channel) | |
| Error sending email | Check DNC if checked/enabled | MHD-18891 |
| Late Dishonour | Run the reversal script (SQL Data Fix scripts, "Reverse DDAC and Reverse Payment") | MHD-17600 |

---
