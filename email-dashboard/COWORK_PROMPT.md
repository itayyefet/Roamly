# Cowork prompt → inbox snapshot

Paste the prompt below into **Cowork** (which has access to your Outlook
mailbox). It will produce a single `inbox-snapshot.json` file. Then either:

- **Load it in the dashboard:** open the app and click
  **"Load a snapshot from Cowork"**, or
- **Auto-load it:** save the file as
  `email-dashboard/public/inbox-snapshot.json` and the dashboard will pick it
  up automatically on launch.

A filled-in example lives at `public/inbox-snapshot.example.json`.

---

## The prompt

> You have access to my Outlook mailbox. Export an overview of my inbox as a
> **single JSON file** named `inbox-snapshot.json`. Do **not** include full
> message bodies — only the fields listed below. Output **only** the JSON
> (no commentary, no markdown fences).
>
> Use exactly this schema:
>
> ```json
> {
>   "generatedAt": "<current UTC time, ISO 8601>",
>   "profile": {
>     "displayName": "<my name>",
>     "email": "<my primary email>",
>     "jobTitle": "<my job title or null>"
>   },
>   "inbox": {
>     "totalItemCount": <total messages in Inbox>,
>     "unreadItemCount": <unread messages in Inbox>
>   },
>   "messages": [
>     {
>       "id": "<message id>",
>       "subject": "<subject>",
>       "bodyPreview": "<first ~150 chars of the body>",
>       "receivedDateTime": "<ISO 8601 UTC, e.g. 2026-06-22T08:42:00Z>",
>       "isRead": <true|false>,
>       "hasAttachments": <true|false>,
>       "importance": "<low|normal|high>",
>       "from": { "name": "<sender name>", "address": "<sender email>" },
>       "flagged": <true|false>,
>       "webLink": "<deep link to open the message in Outlook, or null>"
>     }
>   ],
>   "events": [
>     {
>       "id": "<event id>",
>       "subject": "<title>",
>       "start": "<ISO 8601 UTC>",
>       "end": "<ISO 8601 UTC>",
>       "location": "<location or null>",
>       "isAllDay": <true|false>,
>       "webLink": "<deep link to the event, or null>"
>     }
>   ]
> }
> ```
>
> Rules:
> - Include the **50 most recent Inbox messages**, newest first.
> - Include my **next 5 upcoming calendar events** (those that haven't ended
>   yet), soonest first. If I have no upcoming events, use an empty array.
> - All timestamps must be ISO 8601 in **UTC** (end with `Z`).
> - `importance` must be one of `low`, `normal`, or `high`.
> - If a field is unknown, use `null` (or `false` for the boolean flags).
> - Return valid JSON only.

---

## Notes

- The dashboard's stats (flagged, high-importance, attachments, "arrived
  today", top senders) are all computed from the `messages` array, so the more
  messages you include the richer those panels are.
- `totalItemCount` / `unreadItemCount` should reflect the **whole** Inbox, even
  though only the 50 most recent messages are listed.
- Nothing in this file is secret beyond what's in your inbox — but treat it like
  you would any email export and don't commit a real one to a public repo
  (`inbox-snapshot.json` is git-ignored for that reason).
