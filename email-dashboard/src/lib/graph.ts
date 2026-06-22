import type { IPublicClientApplication, AccountInfo } from "@azure/msal-browser";
import { InteractionRequiredAuthError } from "@azure/msal-browser";
import { graphConfig, loginRequest } from "../authConfig";

/* ----------------------------- Graph types ----------------------------- */

export interface GraphUser {
  displayName: string;
  mail: string | null;
  userPrincipalName: string;
  jobTitle: string | null;
}

export interface EmailAddress {
  name?: string;
  address?: string;
}

export interface Recipient {
  emailAddress?: EmailAddress;
}

export interface GraphMessage {
  id: string;
  subject: string | null;
  bodyPreview: string | null;
  receivedDateTime: string;
  isRead: boolean;
  hasAttachments: boolean;
  importance: "low" | "normal" | "high";
  webLink: string;
  from?: Recipient;
  flag?: { flagStatus?: "notFlagged" | "flagged" | "complete" };
}

export interface MailFolder {
  totalItemCount: number;
  unreadItemCount: number;
}

export interface GraphEvent {
  id: string;
  subject: string | null;
  start: { dateTime: string; timeZone: string };
  end: { dateTime: string; timeZone: string };
  location?: { displayName?: string };
  isAllDay: boolean;
  webLink: string;
}

interface GraphCollection<T> {
  value: T[];
}

/* --------------------------- Token acquisition -------------------------- */

/**
 * Get a Graph access token for the signed-in account. Tries the silent
 * (cached) path first, then falls back to an interactive popup only when
 * Microsoft requires fresh consent or login.
 */
async function getToken(
  instance: IPublicClientApplication,
  account: AccountInfo
): Promise<string> {
  try {
    const result = await instance.acquireTokenSilent({
      ...loginRequest,
      account,
    });
    return result.accessToken;
  } catch (error) {
    if (error instanceof InteractionRequiredAuthError) {
      const result = await instance.acquireTokenPopup({
        ...loginRequest,
        account,
      });
      return result.accessToken;
    }
    throw error;
  }
}

async function graphGet<T>(
  instance: IPublicClientApplication,
  account: AccountInfo,
  path: string
): Promise<T> {
  const token = await getToken(instance, account);
  const response = await fetch(`${graphConfig.graphBaseEndpoint}${path}`, {
    headers: {
      Authorization: `Bearer ${token}`,
      Prefer: 'outlook.timezone="UTC"',
    },
  });

  if (!response.ok) {
    let detail = "";
    try {
      const body = await response.json();
      detail = body?.error?.message ?? "";
    } catch {
      /* ignore non-JSON error bodies */
    }
    throw new Error(
      `Graph request failed (${response.status} ${response.statusText})` +
        (detail ? `: ${detail}` : "")
    );
  }
  return (await response.json()) as T;
}

/* ------------------------------- Endpoints ------------------------------ */

export function fetchProfile(
  instance: IPublicClientApplication,
  account: AccountInfo
): Promise<GraphUser> {
  return graphGet<GraphUser>(
    instance,
    account,
    "/me?$select=displayName,mail,userPrincipalName,jobTitle"
  );
}

export function fetchInboxFolder(
  instance: IPublicClientApplication,
  account: AccountInfo
): Promise<MailFolder> {
  return graphGet<MailFolder>(
    instance,
    account,
    "/me/mailFolders/inbox?$select=totalItemCount,unreadItemCount"
  );
}

export async function fetchRecentMessages(
  instance: IPublicClientApplication,
  account: AccountInfo,
  top = 50
): Promise<GraphMessage[]> {
  const select =
    "id,subject,bodyPreview,receivedDateTime,isRead,hasAttachments,importance,webLink,from,flag";
  const data = await graphGet<GraphCollection<GraphMessage>>(
    instance,
    account,
    `/me/mailFolders/inbox/messages?$select=${select}&$top=${top}&$orderby=receivedDateTime desc`
  );
  return data.value;
}

export async function fetchUpcomingEvents(
  instance: IPublicClientApplication,
  account: AccountInfo,
  top = 5
): Promise<GraphEvent[]> {
  const now = new Date().toISOString();
  const select = "id,subject,start,end,location,isAllDay,webLink";
  const data = await graphGet<GraphCollection<GraphEvent>>(
    instance,
    account,
    `/me/events?$select=${select}&$filter=end/dateTime ge '${now}'` +
      `&$orderby=start/dateTime asc&$top=${top}`
  );
  return data.value;
}
