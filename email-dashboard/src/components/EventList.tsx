import type { GraphEvent } from "../lib/graph";
import { formatEventTime } from "../lib/insights";

interface EventListProps {
  events: GraphEvent[];
}

export function EventList({ events }: EventListProps) {
  return (
    <section className="panel">
      <div className="panel-head">
        <h2 className="panel-title">Upcoming events</h2>
      </div>
      {events.length === 0 ? (
        <p className="empty muted">Nothing on the calendar</p>
      ) : (
        <ul className="event-list">
          {events.map((ev) => (
            <li key={ev.id} className="event">
              <a href={ev.webLink} target="_blank" rel="noreferrer">
                <div className="event-subject">
                  {ev.subject || "(no title)"}
                </div>
                <div className="event-meta muted">
                  {formatEventTime(ev.start.dateTime, ev.isAllDay)}
                  {ev.location?.displayName && ` · ${ev.location.displayName}`}
                </div>
              </a>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
