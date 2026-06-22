import { useCallback, useEffect, useState } from "react";
import { useMsal } from "@azure/msal-react";
import type { AccountInfo } from "@azure/msal-browser";
import {
  fetchProfile,
  fetchInboxFolder,
  fetchRecentMessages,
  fetchUpcomingEvents,
  type GraphEvent,
} from "../lib/graph";
import { buildDashboardData, type DashboardData } from "../lib/snapshot";
import { DashboardView } from "./DashboardView";

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
        data: buildDashboardData({ profile, inbox, messages, events }),
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

  return (
    <DashboardView
      data={state.data}
      onRefresh={refresh}
      refreshing={refreshing}
      onExit={signOut}
      exitLabel="Sign out"
      sourceNote="Live read-only view via Microsoft Graph"
    />
  );
}
