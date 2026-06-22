# Inbox Dashboard 📬

A standalone web dashboard for your **Outlook / Microsoft 365** inbox. Sign in
with your Microsoft account and get an at-a-glance overview: unread counts, your
most recent messages, your busiest senders, flagged & high-importance mail,
attachments, and upcoming calendar events.

> This is a **separate web app** and is independent of the Roamly iOS app in the
> rest of this repository.

## How it works (and why it's safe)

- **Client-side single-page app** — there is **no backend** and **no client
  secret**. The app runs entirely in your browser.
- **Microsoft Graph + MSAL.js** using the **authorization code flow with PKCE**
  (the current Microsoft-recommended flow for SPAs; the old implicit grant is
  deprecated).
- **Read-only, delegated permissions** — `User.Read`, `Mail.Read`,
  `MailboxSettings.Read`, `Calendars.Read`. The app **cannot** send, delete, or
  modify anything.
- Your credentials are entered on Microsoft's own login page; this app only ever
  receives a short-lived access token, cached in `sessionStorage` and cleared
  when you close the tab.

## Setup (≈5 minutes)

### 1. Register a free Azure app

1. Go to [Azure → App registrations](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
   → **New registration**.
2. Name it anything (e.g. "Inbox Dashboard").
3. **Supported account types**: pick *"Accounts in any organizational directory
   and personal Microsoft accounts"* if you use a personal `outlook.com`/`live`
   account.
4. **Redirect URI**: choose platform **Single-page application (SPA)** and enter
   `http://localhost:5173`.
5. Click **Register**.

### 2. Add Graph permissions

1. Open **API permissions** → **Add a permission** → **Microsoft Graph** →
   **Delegated permissions**.
2. Add: `User.Read`, `Mail.Read`, `MailboxSettings.Read`, `Calendars.Read`.
3. (Optional) Click **Grant admin consent** if you're on a work account that
   requires it.

### 3. Configure the app

```bash
cd email-dashboard
cp .env.example .env.local
```

Open `.env.local` and paste your **Application (client) ID** from the app
registration's Overview page:

```
VITE_AAD_CLIENT_ID=11111111-2222-3333-4444-555555555555
```

Personal Microsoft accounts? Leave `VITE_AAD_AUTHORITY` as `common` (the
default) — it works for both work and personal accounts.

### 4. Run it

```bash
npm install
npm run dev
```

Open <http://localhost:5173>, click **Sign in with Microsoft**, and you're in.

## Available scripts

| Command           | What it does                              |
| ----------------- | ----------------------------------------- |
| `npm run dev`     | Start the Vite dev server on port 5173    |
| `npm run build`   | Type-check and build for production        |
| `npm run preview` | Preview the production build locally       |

## Deploying

Because it's a static SPA, `npm run build` produces a `dist/` folder you can
host anywhere (Azure Static Web Apps, Netlify, Vercel, GitHub Pages, etc.). When
you do, add your production URL (e.g. `https://yourname.example.com`) as an
**additional SPA Redirect URI** on the Azure app registration, and set
`VITE_REDIRECT_URI` accordingly at build time.

## Tech stack

- [Vite](https://vitejs.dev/) + React 18 + TypeScript
- [`@azure/msal-browser`](https://www.npmjs.com/package/@azure/msal-browser) /
  [`@azure/msal-react`](https://www.npmjs.com/package/@azure/msal-react)
- [Microsoft Graph REST API](https://learn.microsoft.com/en-us/graph/api/overview)

## Project layout

```
email-dashboard/
├── src/
│   ├── authConfig.ts        # MSAL config + requested Graph scopes
│   ├── main.tsx             # App bootstrap + MSAL provider
│   ├── App.tsx              # Auth gate (sign-in vs dashboard vs setup)
│   ├── lib/
│   │   ├── graph.ts         # Microsoft Graph client + typed endpoints
│   │   └── insights.ts      # Client-side aggregation (top senders, counts)
│   └── components/          # Dashboard UI (cards, lists, panels)
└── README.md
```
