import { SnapshotLoader } from "./SnapshotLoader";
import type { DashboardData } from "../lib/snapshot";

/**
 * Shown when no Azure client ID has been configured yet, so the app gives
 * clear next steps instead of a blank MSAL error.
 */
export function SetupNotice({
  onSnapshot,
}: {
  onSnapshot: (d: DashboardData) => void;
}) {
  return (
    <div className="centered">
      <div className="signin-card setup">
        <div className="signin-logo" aria-hidden>
          🔧
        </div>
        <h1>One quick setup step</h1>
        <p className="muted">
          This dashboard needs a free Azure app registration so Microsoft can
          recognize it. It takes about 5 minutes.
        </p>
        <ol className="setup-steps">
          <li>
            Go to{" "}
            <a
              href="https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade"
              target="_blank"
              rel="noreferrer"
            >
              Azure → App registrations
            </a>{" "}
            and click <strong>New registration</strong>.
          </li>
          <li>
            Under <strong>Redirect URI</strong>, pick{" "}
            <strong>Single-page application (SPA)</strong> and enter{" "}
            <code>http://localhost:5173</code>.
          </li>
          <li>
            Open <strong>API permissions</strong> → add Microsoft Graph{" "}
            <em>delegated</em> permissions: <code>User.Read</code>,{" "}
            <code>Mail.Read</code>, <code>MailboxSettings.Read</code>,{" "}
            <code>Calendars.Read</code>.
          </li>
          <li>
            Copy the <strong>Application (client) ID</strong> into a{" "}
            <code>.env.local</code> file:
            <pre>VITE_AAD_CLIENT_ID=your-client-id-here</pre>
          </li>
          <li>
            Restart the dev server (<code>npm run dev</code>) and refresh.
          </li>
        </ol>
        <div className="or-divider">
          <span>or skip setup for now</span>
        </div>
        <SnapshotLoader onLoaded={onSnapshot} />
        <p className="fineprint muted">
          Have Cowork export your inbox to a JSON file (see{" "}
          <code>COWORK_PROMPT.md</code>) and load it above to preview the
          dashboard instantly. Full setup is in{" "}
          <code>email-dashboard/README.md</code>.
        </p>
      </div>
    </div>
  );
}
