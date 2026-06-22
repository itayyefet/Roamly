import type { Configuration, PopupRequest } from "@azure/msal-browser";
import { LogLevel } from "@azure/msal-browser";

const clientId = import.meta.env.VITE_AAD_CLIENT_ID;
const authority =
  import.meta.env.VITE_AAD_AUTHORITY ??
  "https://login.microsoftonline.com/common";
const redirectUri =
  import.meta.env.VITE_REDIRECT_URI ?? window.location.origin;

/**
 * True only when a real client ID has been configured. The app shows a
 * friendly setup screen instead of crashing when this is missing.
 */
export const isConfigured =
  !!clientId &&
  clientId !== "00000000-0000-0000-0000-000000000000" &&
  clientId.trim().length > 0;

/**
 * MSAL configuration. We use the authorization code flow with PKCE (the
 * default and recommended flow for SPAs — implicit grant is deprecated),
 * so no client secret is ever needed or stored.
 */
export const msalConfig: Configuration = {
  auth: {
    clientId: clientId ?? "",
    authority,
    redirectUri,
    postLogoutRedirectUri: redirectUri,
  },
  cache: {
    // sessionStorage keeps tokens scoped to the tab and clears on close,
    // which is a safer default for a dashboard than localStorage.
    cacheLocation: "sessionStorage",
    storeAuthStateInCookie: false,
  },
  system: {
    loggerOptions: {
      logLevel: LogLevel.Warning,
      loggerCallback: (level, message, containsPii) => {
        if (containsPii) return;
        if (level === LogLevel.Error) console.error(message);
      },
    },
  },
};

/**
 * Delegated Microsoft Graph scopes the dashboard requests. These are
 * read-only — the app can never send, delete, or modify your mail.
 */
export const loginRequest: PopupRequest = {
  scopes: ["User.Read", "Mail.Read", "MailboxSettings.Read", "Calendars.Read"],
};

export const graphConfig = {
  graphBaseEndpoint: "https://graph.microsoft.com/v1.0",
};
