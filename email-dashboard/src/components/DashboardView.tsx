import type { DashboardData } from "../lib/snapshot";
import {
  countFlagged,
  countImportant,
  countWithAttachments,
  countToday,
} from "../lib/insights";
import { StatCard } from "./StatCard";
import { MessageList } from "./MessageList";
import { SenderList } from "./SenderList";
import { EventList } from "./EventList";
import { Avatar } from "./Avatar";

interface DashboardViewProps {
  data: DashboardData;
  /** Optional refresh handler (live source only). */
  onRefresh?: () => void;
  refreshing?: boolean;
  /** Action button on the right of the top bar (sign out / exit). */
  onExit: () => void;
  exitLabel: string;
  /** Small note shown in the footer about where the data came from. */
  sourceNote: string;
}

export function DashboardView({
  data,
  onRefresh,
  refreshing,
  onExit,
  exitLabel,
  sourceNote,
}: DashboardViewProps) {
  const { profile, inbox, messages, events, senders } = data;
  const displayName = profile.displayName || "there";
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
          {onRefresh && (
            <button
              className="btn btn-ghost"
              onClick={onRefresh}
              disabled={refreshing}
            >
              {refreshing ? "Refreshing…" : "↻ Refresh"}
            </button>
          )}
          <button className="btn btn-ghost" onClick={onExit}>
            {exitLabel}
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
        {sourceNote} · stats reflect the {messages.length} most recent inbox
        messages
      </footer>
    </div>
  );
}
