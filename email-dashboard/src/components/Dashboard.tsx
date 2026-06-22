import { useCallback, useEffect, useState } from "react";
import { useMsal } from "@azure/msal-react";
import type { AccountInfo } from "@azure/msal-browser";
import {
  fetchProfile,
  fetchInboxFolder,
  fetchRecentMessages,
  fetchUpcomingEvents,
  type GraphUser,
  type GraphMessage,
  type MailFolder,
  type GraphEvent,
} from "../lib/graph";
import {
  topSenders,
  countFlagged,
  countImportant,
  countWithAttachments,
  countToday,
  type SenderSummary,
} from "../lib/insights";
import { StatCard } from "./StatCard";
import { MessageList } from "./MessageList";
import { SenderList } from "./SenderList";
import { EventList } from "./EventList";
import { Avatar } from "./Avatar";

interface DashboardData {
  profile: GraphUser;
  inbox: MailFolder;
  messages: GraphMessage[];
  events: GraphEvent[];
  senders: SenderSummary[];
}

type LoadState =
  | { status: "loading" }
  | { status: "error"; message: string }
  | { status: "ready"; data: DashboardData };

export function Dashboard() {
  const { instance } = useMsal();
  const account = instance.getActiveAccount() as AccountInfo | null;
  const [state, setState] = useState<LoadState>({ status: "loading" });
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    if (!account) return;
    try {
      // Calendar can fail independently (e.g. consent not granted) without
      // breaking the whole dashboard, so it gets its own catch.
      const [profile, inbox, messages, events] = await Promise.all([
        fetchProfile(instance, account),
        fetchInboxFolder(instance, account),
        fetchRecentMessages(instance, account, 50),
        fetchUpcomingEvents(instance, account, 5).catch(() => [] as GraphEvent[]),
      ]);

      setState({
        status: "ready",
        data: {
          profile,
          inbox,
          messages,
          events,
          senders: topSenders(messages),
        },
      });
    } catch (err) {
      setState({
        status: "error",
        message: err instanceof Error ? err.message : "Unknown error",
      });
    }
  }, [instance, account]);

  useEffect(() => {
    load();
  }, [load]);

  const refresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

  const signOut = () => {
    instance.logoutPopup({ account: account ?? undefined }).catch(console.error);
  };

  if (state.status === "loading") {
    return (
      <div className="centered">
        <div className="spinner" aria-label="Loading" />
        <p className="muted">Reading your inbox…</p>
      </div>
    );
  }

  if (state.status === "error") {
    return (
      <div className="centered">
        <div className="signin-card">
          <div className="signin-logo" aria-hidden>
            ⚠️
          </div>
          <h1>Couldn’t load your inbox</h1>
          <p className="muted">{state.message}</p>
          <button className="btn btn-primary" onClick={refresh}>
            Try again
          </button>
          <button className="btn btn-ghost" onClick={signOut}>
            Sign out
          </button>
        </div>
      </div>
    );
  }

  const { profile, inbox, messages, events, senders } = state.data;
  const displayName = profile.displayName || account?.name || "there";
  const email = profile.mail || profile.userPrincipalName;

  return (
    <div className="app">
      <header className="topbar">
        <div className="topbar-id">
          <Avatar name={displayName} size={44} />
          <div>
            <h1 className="topbar-title">Hi, {displayName.split(" ")[0]} 👋</h1>
            <p className="muted topbar-sub">{email}</p>
          </div>
        </div>
        <div className="topbar-actions">
          <button
            className="btn btn-ghost"
            onClick={refresh}
            disabled={refreshing}
          >
            {refreshing ? "Refreshing…" : "↻ Refresh"}
          </button>
          <button className="btn btn-ghost" onClick={signOut}>
            Sign out
          </button>
        </div>
      </header>

      <section className="stats-grid">
        <StatCard
          label="Unread in inbox"
          value={inbox.unreadItemCount}
          accent="blue"
          icon="📬"
        />
        <StatCard
          label="Total in inbox"
          value={inbox.totalItemCount}
          accent="slate"
          icon="🗂️"
        />
        <StatCard
          label="Arrived today"
          value={countToday(messages)}
          accent="green"
          icon="🕒"
          hint="last 24h"
        />
        <StatCard
          label="Flagged"
          value={countFlagged(messages)}
          accent="amber"
          icon="🚩"
          hint="recent"
        />
        <StatCard
          label="High importance"
          value={countImportant(messages)}
          accent="red"
          icon="❗"
          hint="recent"
        />
        <StatCard
          label="With attachments"
          value={countWithAttachments(messages)}
          accent="purple"
          icon="📎"
          hint="recent"
        />
      </section>

      <div className="columns">
        <main className="col-main">
          <MessageList messages={messages} />
        </main>
        <aside className="col-side">
          <SenderList senders={senders} />
          <EventList events={events} />
        </aside>
      </div>

      <footer className="footer muted">
        Read-only view via Microsoft Graph · stats reflect the {messages.length}{" "}
        most recent inbox messages
      </footer>
    </div>
  );
}
