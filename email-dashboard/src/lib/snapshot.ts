import type {
  GraphUser,
  GraphMessage,
  MailFolder,
  GraphEvent,
} from "./graph";
import { topSenders, type SenderSummary } from "./insights";

/** The fully-resolved data the dashboard UI renders, from any source. */
export interface DashboardData {
  profile: GraphUser;
  inbox: MailFolder;
  messages: GraphMessage[];
  events: GraphEvent[];
  senders: SenderSummary[];
}

/* ------------------------- Snapshot file schema ------------------------ */
/* This is the simple, LLM-friendly shape that Cowork (or any tool with    */
/* mailbox access) exports. See COWORK_PROMPT.md and the example JSON.     */

export interface SnapshotMessage {
  id?: string;
  subject?: string | null;
  bodyPreview?: string | null;
  receivedDateTime: string;
  isRead?: boolean;
  hasAttachments?: boolean;
  importance?: "low" | "normal" | "high";
  from?: { name?: string; address?: string };
  flagged?: boolean;
  webLink?: string;
}

export interface SnapshotEvent {
  id?: string;
  subject?: string | null;
  start: string;
  end?: string;
  location?: string;
  isAllDay?: boolean;
  webLink?: string;
}

export interface Snapshot {
  generatedAt?: string;
  profile?: { displayName?: string; email?: string; jobTitle?: string | null };
  inbox?: { totalItemCount?: number; unreadItemCount?: number };
  messages?: SnapshotMessage[];
  events?: SnapshotEvent[];
}

/** Build the rendered data shape; shared by live + snapshot sources. */
export function buildDashboardData(parts: {
  profile: GraphUser;
  inbox: MailFolder;
  messages: GraphMessage[];
  events: GraphEvent[];
}): DashboardData {
  return { ...parts, senders: topSenders(parts.messages) };
}

/**
 * Convert a raw snapshot (parsed JSON) into DashboardData, tolerating
 * missing fields. Throws a readable error if the file is unusable.
 */
export function adaptSnapshot(raw: unknown): DashboardData {
  if (!raw || typeof raw !== "object") {
    throw new Error("Snapshot is not a JSON object.");
  }
  const snap = raw as Snapshot;

  if (!Array.isArray(snap.messages)) {
    throw new Error('Snapshot is missing a "messages" array.');
  }

  const messages: GraphMessage[] = snap.messages.map((m, i) => {
    if (!m || typeof m.receivedDateTime !== "string") {
      throw new Error(
        `messages[${i}] is missing a "receivedDateTime" timestamp.`
      );
    }
    return {
      id: m.id ?? `snap-${i}`,
      subject: m.subject ?? null,
      bodyPreview: m.bodyPreview ?? "",
      receivedDateTime: m.receivedDateTime,
      isRead: m.isRead ?? true,
      hasAttachments: m.hasAttachments ?? false,
      importance: m.importance ?? "normal",
      webLink: m.webLink ?? "#",
      from: { emailAddress: { name: m.from?.name, address: m.from?.address } },
      flag: { flagStatus: m.flagged ? "flagged" : "notFlagged" },
    };
  });

  const events: GraphEvent[] = (snap.events ?? []).map((e, i) => ({
    id: e.id ?? `snap-ev-${i}`,
    subject: e.subject ?? null,
    start: { dateTime: e.start, timeZone: "UTC" },
    end: { dateTime: e.end ?? e.start, timeZone: "UTC" },
    location: e.location ? { displayName: e.location } : undefined,
    isAllDay: e.isAllDay ?? false,
    webLink: e.webLink ?? "#",
  }));

  const displayName = snap.profile?.displayName ?? "there";
  const email = snap.profile?.email ?? "";

  const profile: GraphUser = {
    displayName,
    mail: email || null,
    userPrincipalName: email,
    jobTitle: snap.profile?.jobTitle ?? null,
  };

  const unreadFromMessages = messages.filter((m) => !m.isRead).length;
  const inbox: MailFolder = {
    totalItemCount: snap.inbox?.totalItemCount ?? messages.length,
    unreadItemCount: snap.inbox?.unreadItemCount ?? unreadFromMessages,
  };

  return buildDashboardData({ profile, inbox, messages, events });
}

/** Parse a File the user picked, returning DashboardData. */
export async function loadSnapshotFile(file: File): Promise<DashboardData> {
  const text = await file.text();
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new Error("That file isn't valid JSON.");
  }
  return adaptSnapshot(parsed);
}

/**
 * Try to auto-load a snapshot served at /inbox-snapshot.json (if you drop
 * one into the app's public/ folder). Returns null when absent.
 */
export async function tryLoadHostedSnapshot(): Promise<DashboardData | null> {
  try {
    const res = await fetch("/inbox-snapshot.json", {
      headers: { Accept: "application/json" },
    });
    if (!res.ok) return null;
    const ct = res.headers.get("content-type") ?? "";
    if (!ct.includes("json")) return null;
    return adaptSnapshot(await res.json());
  } catch {
    return null;
  }
}
