# Frequently raised tickets for manual processing

Mirror of the Confluence page "Frequently raised tickets for manual processing".

Last reviewed: 23 September 2026
Sources: Confluence AS page 882868262, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 882868262 · Last updated: 20 Jun 2024 · Author: Anna Paulene Pascual
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/882868262/Frequently+raised+tickets+for+manual+processing

Tracks tickets raised to Application Support for manual action, to identify which processes
should be automated. The page is two saved Jira JQL links rather than content:

**Shuffle**

```jql
(text ~ "Shuffle*" OR summary ~ "Shuffle*")
AND assignee IN (712020:f074c2f2-eb08-4745-8fcf-b20cf87dabe5, 63f31e3dce6f37e5ed92c59b)
AND project IN (MHD) AND type IN (Problem)
ORDER BY created DESC
```

**Change account login details**

```jql
(text ~ "pin*" OR summary ~ "pin*" AND text ~ "OTP*" OR summary ~ "OTP*"
 AND text ~ "login*" OR summary ~ "login*" AND text ~ "email*" OR summary ~ "email*"
 AND text ~ "invalid*" OR summary ~ "invalid*" AND text ~ "number*" OR summary ~ "number*")
AND project IN (MHD)
AND type IN (Problem, "Change Request Data Fix/External with Multiple Approvals")
AND assignee IN (63f31e3dce6f37e5ed92c59b, 712020:f074c2f2-eb08-4745-8fcf-b20cf87dabe5)
ORDER BY created DESC
```

The two account IDs are Michael Dela Torre (`63f31e3dce6f37e5ed92c59b`) and Ron Paolo Miguel
Magpusao (`712020:f074c2f2-eb08-4745-8fcf-b20cf87dabe5`).

---
