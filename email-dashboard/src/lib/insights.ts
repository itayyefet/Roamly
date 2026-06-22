import type { GraphMessage } from "./graph";

export interface SenderSummary {
  name: string;
  address: string;
  count: number;
  unread: number;
}

/** Aggregate the busiest senders from a batch of messages. */
export function topSenders(messages: GraphMessage[], limit = 6): SenderSummary[] {
  const byAddress = new Map<string, SenderSummary>();

  for (const msg of messages) {
    const email = msg.from?.emailAddress;
    const address = email?.address?.toLowerCase();
    if (!address) continue;

    const existing = byAddress.get(address);
    if (existing) {
      existing.count += 1;
      if (!msg.isRead) existing.unread += 1;
    } else {
      byAddress.set(address, {
        name: email?.name || address,
        address,
        count: 1,
        unread: msg.isRead ? 0 : 1,
      });
    }
  }

  return [...byAddress.values()]
    .sort((a, b) => b.count - a.count)
    .slice(0, limit);
}

export function countUnread(messages: GraphMessage[]): number {
  return messages.filter((m) => !m.isRead).length;
}

export function countFlagged(messages: GraphMessage[]): number {
  return messages.filter((m) => m.flag?.flagStatus === "flagged").length;
}

export function countImportant(messages: GraphMessage[]): number {
  return messages.filter((m) => m.importance === "high").length;
}

export function countWithAttachments(messages: GraphMessage[]): number {
  return messages.filter((m) => m.hasAttachments).length;
}

/** Messages received within the last 24 hours. */
export function countToday(messages: GraphMessage[]): number {
  const dayAgo = Date.now() - 24 * 60 * 60 * 1000;
  return messages.filter(
    (m) => new Date(m.receivedDateTime).getTime() >= dayAgo
  ).length;
}

const relativeFmt = new Intl.RelativeTimeFormat(undefined, { numeric: "auto" });

/** Human-friendly "3h ago" / "2d ago" style timestamp. */
export function relativeTime(iso: string): string {
  const diffMs = new Date(iso).getTime() - Date.now();
  const diffMin = Math.round(diffMs / 60000);
  const absMin = Math.abs(diffMin);

  if (absMin < 60) return relativeFmt.format(diffMin, "minute");
  const diffHour = Math.round(diffMin / 60);
  if (Math.abs(diffHour) < 24) return relativeFmt.format(diffHour, "hour");
  const diffDay = Math.round(diffHour / 24);
  if (Math.abs(diffDay) < 30) return relativeFmt.format(diffDay, "day");
  return new Date(iso).toLocaleDateString();
}

export function formatEventTime(iso: string, isAllDay: boolean): string {
  const date = new Date(iso + (iso.endsWith("Z") ? "" : "Z"));
  if (isAllDay) {
    return date.toLocaleDateString(undefined, {
      weekday: "short",
      month: "short",
      day: "numeric",
    });
  }
  return date.toLocaleString(undefined, {
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });
}

/** Deterministic avatar colour derived from a string. */
export function colorFor(seed: string): string {
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    hash = seed.charCodeAt(i) + ((hash << 5) - hash);
  }
  const hue = Math.abs(hash) % 360;
  return `hsl(${hue} 55% 45%)`;
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
