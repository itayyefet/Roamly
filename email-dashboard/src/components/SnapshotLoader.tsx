import { useRef, useState } from "react";
import { loadSnapshotFile, type DashboardData } from "../lib/snapshot";

interface SnapshotLoaderProps {
  onLoaded: (data: DashboardData) => void;
}

/**
 * Lets the user open a JSON snapshot exported by Cowork (or any tool with
 * mailbox access) and view it in the dashboard without signing in.
 */
export function SnapshotLoader({ onLoaded }: SnapshotLoaderProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [error, setError] = useState<string | null>(null);

  const handleFile = async (file: File | undefined) => {
    if (!file) return;
    setError(null);
    try {
      onLoaded(await loadSnapshotFile(file));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Couldn't read that file.");
    }
  };

  return (
    <div className="snapshot-loader">
      <input
        ref={inputRef}
        type="file"
        accept="application/json,.json"
        hidden
        onChange={(e) => handleFile(e.target.files?.[0])}
      />
      <button
        className="btn btn-ghost"
        onClick={() => inputRef.current?.click()}
      >
        📂 Load a snapshot from Cowork
      </button>
      {error && <p className="snapshot-error">{error}</p>}
    </div>
  );
}
