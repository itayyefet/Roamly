import { useState } from "react";
import type { GraphMessage } from "../lib/graph";
import { relativeTime } from "../lib/insights";
import { Avatar } from "./Avatar";

type Filter = "all" | "unread" | "flagged" | "attachments";

interface MessageListProps {
  messages: GraphMessage[];
}

function matches(msg: GraphMessage, filter: Filter): boolean {
  switch (filter) {
    case "unread":
      return !msg.isRead;
    case "flagged":
      return msg.flag?.flagStatus === "flagged";
    case "attachments":
      return msg.hasAttachments;
    default:
      return true;
  }
}

export function MessageList({ messages }: MessageListProps) {
  const [filter, setFilter] = useState<Filter>("all");
  const visible = messages.filter((m) => matches(m, filter));

  const tabs: { key: Filter; label: string }[] = [
    { key: "all", label: "All" },
    { key: "unread", label: "Unread" },
    { key: "flagged", label: "Flagged" },
    { key: "attachments", label: "Attachments" },
  ];

  return (
    <section className="panel">
      <div className="panel-head">
        <h2 className="panel-title">Recent messages</h2>
        <div className="tabs">
          {tabs.map((t) => (
            <button
              key={t.key}
              className={`tab ${filter === t.key ? "tab-active" : ""}`}
              onClick={() => setFilter(t.key)}
            >
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {visible.length === 0 ? (
        <p className="empty muted">Nothing here 🎉</p>
      ) : (
        <ul className="msg-list">
          {visible.map((msg) => {
            const sender =
              msg.from?.emailAddress?.name ||
              msg.from?.emailAddress?.address ||
              "Unknown sender";
            return (
              <li key={msg.id} className={`msg ${msg.isRead ? "" : "msg-unread"}`}>
                <Avatar name={sender} />
                <a
                  className="msg-body"
                  href={msg.webLink}
                  target="_blank"
                  rel="noreferrer"
                >
                  <div className="msg-row">
                    <span className="msg-sender">{sender}</span>
                    <span className="msg-time muted">
                      {relativeTime(msg.receivedDateTime)}
                    </span>
                  </div>
                  <div className="msg-subject">
                    {msg.importance === "high" && (
                      <span title="High importance">❗ </span>
                    )}
                    {msg.flag?.flagStatus === "flagged" && (
                      <span title="Flagged">🚩 </span>
                    )}
                    {msg.subject || "(no subject)"}
                    {msg.hasAttachments && (
                      <span title="Has attachments"> 📎</span>
                    )}
                  </div>
                  <div className="msg-preview muted">{msg.bodyPreview}</div>
                </a>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}
