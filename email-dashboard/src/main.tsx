import React from "react";
import ReactDOM from "react-dom/client";
import { PublicClientApplication, EventType } from "@azure/msal-browser";
import { MsalProvider } from "@azure/msal-react";
import { msalConfig, isConfigured } from "./authConfig";
import App from "./App";
import "./styles.css";

const msalInstance = new PublicClientApplication(msalConfig);

async function bootstrap() {
  if (isConfigured) {
    await msalInstance.initialize();

    // Default to the first signed-in account if one exists.
    const accounts = msalInstance.getAllAccounts();
    if (accounts.length > 0) {
      msalInstance.setActiveAccount(accounts[0]);
    }

    // Keep the active account in sync after each successful login.
    msalInstance.addEventCallback((event) => {
      if (
        event.eventType === EventType.LOGIN_SUCCESS &&
        event.payload &&
        "account" in event.payload &&
        event.payload.account
      ) {
        msalInstance.setActiveAccount(event.payload.account);
      }
    });
  }

  ReactDOM.createRoot(document.getElementById("root")!).render(
    <React.StrictMode>
      <MsalProvider instance={msalInstance}>
        <App />
      </MsalProvider>
    </React.StrictMode>
  );
}

bootstrap();
