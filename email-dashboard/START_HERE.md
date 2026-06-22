# 📬 Inbox Dashboard — Start Here

This zip contains a small **web app** that shows an at-a-glance overview of your
Outlook / Microsoft 365 inbox: unread counts, recent messages, top senders,
flagged & important mail, attachments, and upcoming calendar events.

You can get it running in **two ways**. The fastest one uses **Cowork**.

---

## Option A — Fastest: use Cowork to fill it with your data (no sign-in)

**Step 1. Get your data from Cowork.**
Open Cowork (it has access to your Outlook) and paste the prompt from
[`COWORK_PROMPT.md`](./COWORK_PROMPT.md). It will produce a single file called
`inbox-snapshot.json`. Save that file.

**Step 2. Run the app.**
You need [Node.js](https://nodejs.org) (LTS) installed. Then in a terminal:

```bash
cd email-dashboard
npm install
npm run dev
```

Open the printed URL (usually <http://localhost:5173>).

**Step 3. Load your data.**
On the start screen click **"📂 Load a snapshot from Cowork"** and choose the
`inbox-snapshot.json` Cowork gave you. Done — your dashboard appears.

> Want it to load automatically? Save the file as
> `email-dashboard/public/inbox-snapshot.json` instead, and it loads on launch.

**Just want to see what it looks like first?** Load the included
`public/inbox-snapshot.example.json` in step 3 — it's sample data.

---

## Option B — Live connection to Outlook (real-time, ~5 min setup)

This signs you in with Microsoft and reads your inbox live. It needs a free
Azure "app registration" (a client ID). Full walkthrough is in
[`README.md`](./README.md) under **"Setup — live connection"**.

---

## What's safe to know

- The app is **read-only** — it can never send, delete, or change your mail.
- In live mode you log in on Microsoft's own page; the app only gets a
  short-lived token. There is **no server and no password stored**.
- The snapshot file is just an export of your inbox overview. It's git-ignored
  so you won't accidentally commit a real one.

---

## What's in this zip

| Path                                   | What it is                                  |
| -------------------------------------- | ------------------------------------------- |
| `START_HERE.md`                        | This file                                   |
| `COWORK_PROMPT.md`                     | The prompt to paste into Cowork             |
| `README.md`                            | Full docs incl. live-connection setup       |
| `public/inbox-snapshot.example.json`   | Sample data you can load to preview the UI  |
| `src/`                                 | The app source code                         |
