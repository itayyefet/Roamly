import { useEffect, useState } from "react";
import {
  AuthenticatedTemplate,
  UnauthenticatedTemplate,
  useMsal,
} from "@azure/msal-react";
import { isConfigured, loginRequest } from "./authConfig";
import { Dashboard } from "./components/Dashboard";
import { DashboardView } from "./components/DashboardView";
import { SetupNotice } from "./components/SetupNotice";
import { SnapshotLoader } from "./components/SnapshotLoader";
import { tryLoadHostedSnapshot, type DashboardData } from "./lib/snapshot";

function SignIn({ onSnapshot }: { onSnapshot: (d: DashboardData) => void }) {
  const { instance } = useMsal();

  return (
    <div className="centered">
      <div className="signin-card">
        <div className="signin-logo" aria-hidden>
          ✉️
        </div>
        <h1>Inbox Dashboard</h1>
        <p className="muted">
          Connect your Outlook / Microsoft 365 account to see an at-a-glance
          overview of your inbox. Read-only — your credentials never touch this
          app.
        </p>
        <button
          className="btn btn-primary"
          onClick={() => instance.loginPopup(loginRequest).catch(console.error)}
        >
          Sign in with Microsoft
        </button>
        <div className="or-divider">
          <span>or</span>
        </div>
        <SnapshotLoader onLoaded={onSnapshot} />
        <p className="fineprint muted">
          Requests: profile, read mail, read calendar. Nothing is sent, deleted,
          or modified.
        </p>
      </div>
    </div>
  );
}

export default function App() {
  const [snapshot, setSnapshot] = useState<DashboardData | null>(null);

  // If a snapshot file was dropped into public/ (inbox-snapshot.json), load
  // it automatically so the dashboard "just works" with no sign-in.
  useEffect(() => {
    tryLoadHostedSnapshot().then((data) => {
      if (data) setSnapshot(data);
    });
  }, []);

  if (snapshot) {
    return (
      <DashboardView
        data={snapshot}
        onExit={() => setSnapshot(null)}
        exitLabel="Close snapshot"
        sourceNote="Snapshot view (exported data, not live)"
      />
    );
  }

  if (!isConfigured) {
    return <SetupNotice onSnapshot={setSnapshot} />;
  }

  return (
    <>
      <AuthenticatedTemplate>
        <Dashboard />
      </AuthenticatedTemplate>
      <UnauthenticatedTemplate>
        <SignIn onSnapshot={setSnapshot} />
      </UnauthenticatedTemplate>
    </>
  );
}
