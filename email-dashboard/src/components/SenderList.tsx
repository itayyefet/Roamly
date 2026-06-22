import type { SenderSummary } from "../lib/insights";
import { Avatar } from "./Avatar";

interface SenderListProps {
  senders: SenderSummary[];
}

export function SenderList({ senders }: SenderListProps) {
  const max = senders[0]?.count ?? 1;

  return (
    <section className="panel">
      <div className="panel-head">
        <h2 className="panel-title">Top senders</h2>
      </div>
      {senders.length === 0 ? (
        <p className="empty muted">No senders yet</p>
      ) : (
        <ul className="sender-list">
          {senders.map((s) => (
            <li key={s.address} className="sender">
              <Avatar name={s.name} size={32} />
              <div className="sender-body">
                <div className="sender-row">
                  <span className="sender-name" title={s.address}>
                    {s.name}
                  </span>
                  <span className="sender-count muted">
                    {s.count}
                    {s.unread > 0 && (
                      <span className="badge"> {s.unread} new</span>
                    )}
                  </span>
                </div>
                <div className="bar">
                  <div
                    className="bar-fill"
                    style={{ width: `${(s.count / max) * 100}%` }}
                  />
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
