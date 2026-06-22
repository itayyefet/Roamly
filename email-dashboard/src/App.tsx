import {
  AuthenticatedTemplate,
  UnauthenticatedTemplate,
  useMsal,
} from "@azure/msal-react";
import { isConfigured, loginRequest } from "./authConfig";
import { Dashboard } from "./components/Dashboard";
import { SetupNotice } from "./components/SetupNotice";

function SignIn() {
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
        <p className="fineprint muted">
          Requests: profile, read mail, read calendar. Nothing is sent, deleted,
          or modified.
        </p>
      </div>
    </div>
  );
}

export default function App() {
  if (!isConfigured) {
    return <SetupNotice />;
  }

  return (
    <>
      <AuthenticatedTemplate>
        <Dashboard />
      </AuthenticatedTemplate>
      <UnauthenticatedTemplate>
        <SignIn />
      </UnauthenticatedTemplate>
    </>
  );
}
