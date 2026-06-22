interface StatCardProps {
  label: string;
  value: number;
  icon: string;
  accent: "blue" | "green" | "amber" | "red" | "purple" | "slate";
  hint?: string;
}

export function StatCard({ label, value, icon, accent, hint }: StatCardProps) {
  return (
    <div className={`stat-card accent-${accent}`}>
      <div className="stat-icon" aria-hidden>
        {icon}
      </div>
      <div className="stat-body">
        <div className="stat-value">{value.toLocaleString()}</div>
        <div className="stat-label">{label}</div>
        {hint && <div className="stat-hint muted">{hint}</div>}
      </div>
    </div>
  );
}
