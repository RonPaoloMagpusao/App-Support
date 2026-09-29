# Sentry Monitoring

Mirror of the Confluence page "Sentry Monitoring".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1409548294, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1409548294 · Last updated: 31 Dec 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1409548294/Sentry+Monitoring

Eleven step procedure, summarised (the source is written at a generic level and contains no
MoneyMe specific Sentry project names, DSNs or alert rules).

1. Open Slack and go to channel `#C05PPSLUJ1K`, the channel where Sentry logs and error
   reports are posted. (Note: the page records the channel by Slack ID, not by name. The
   human readable channel is `#app-support-sentry-error-logs`.)
2. Search the channel for "Sentry", "error" or "log" mentions.
3. Click through the Sentry issue link shared in the message.
4. Log in to Sentry with organisation credentials or SSO.
5. Review the error message, stack trace, events, timestamp and affected environment
   (production, staging, development).
6. Check occurrence count, user impact, and tags or custom metadata (version, release,
   environment).
7. Assign or acknowledge the issue.
8. Communicate status back to the Slack channel.
9. Track the resolution and watch for regressions.
10. Mark the issue Resolved in Sentry and document what was done in the issue comments.
11. Monitor the Slack channel regularly for new mentions.

---
