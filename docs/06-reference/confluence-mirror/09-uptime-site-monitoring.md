# Uptime: Site Monitoring

Mirror of the Confluence page "Uptime: Site Monitoring".

Last reviewed: 23 September 2026
Sources: Confluence AS page 1409351830, mirrored 23 September 2026. Edits here do not flow back to Confluence.

- Space: AS · Page id: 1409351830 · Last updated: 31 Dec 2024 · Author: Ron Paolo Miguel Magpusao
- URL: https://moneyme1.atlassian.net/wiki/spaces/AS/pages/1409351830/Uptime+Site+Monitoring

Tool: Uptime Robot, dashboard at https://dashboard.uptimerobot.com/login

Twelve step procedure. The operationally relevant points:

- Log in to the Uptime Robot dashboard to see every monitored site and its up/down status.
- Add a new monitor with "Add New Monitor": choose HTTP(s), enter the URL or IP, set the
  monitoring interval (usually 5 minutes) and a monitor name.
- Green = up, red = down. Uptime statistics and logs show how often a site goes down.
- Slack notifications: My Settings → Notifications → Add Notification → Slack. Create a Slack
  Incoming Webhook against the target channel (the page uses `#uptime-alerts` as the example),
  copy the webhook URL, paste it into the Uptime Robot notification settings, save, then send a
  test notification.
- Alert messages carry the site URL, the status change and the timestamp.
- On a down alert, click through to the monitor logs in Uptime Robot for downtime history and
  outage duration, then investigate server status and network connectivity.

The page contains no list of which MoneyMe sites are actually monitored, and no credentials.

---
