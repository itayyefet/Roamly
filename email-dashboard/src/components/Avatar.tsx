import { colorFor, initials } from "../lib/insights";

interface AvatarProps {
  name: string;
  size?: number;
}

export function Avatar({ name, size = 36 }: AvatarProps) {
  return (
    <span
      className="avatar"
      style={{
        width: size,
        height: size,
        background: colorFor(name),
        fontSize: size * 0.4,
      }}
      aria-hidden
    >
      {initials(name)}
    </span>
  );
}
