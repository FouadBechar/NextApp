"use client";

export function getInitials(nameOrId: string | null): string {
  if (!nameOrId) return "?";
  const s = String(nameOrId).trim();
  if (s.includes(" ")) {
    const parts = s.split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? "";
    const second = parts[1]?.[0] ?? "";
    return (first + second).toUpperCase();
  }
  const letters = [...s].filter((c) => /[A-Za-z0-9]/.test(c));
  const first = letters[0] ?? (s[0] ?? "?");
  const second = letters[1] ?? "";
  return (first + second).toUpperCase();
}

export function generateAvatarGradientClass(seed: string) {
  const paletteClasses = [
    "bg-gradient-to-br from-indigo-500 to-violet-500",
    "bg-gradient-to-br from-cyan-400 to-teal-400",
    "bg-gradient-to-br from-orange-500 to-rose-500",
    "bg-gradient-to-br from-green-500 to-cyan-500",
    "bg-gradient-to-br from-red-500 to-orange-400",
    "bg-gradient-to-br from-blue-500 to-cyan-500",
    "bg-gradient-to-br from-amber-400 to-yellow-400",
  ];
  let h = 0;
  for (let i = 0; i < seed.length; i++) {
    h = (h * 31 + seed.charCodeAt(i)) % 1000000007;
  }
  const idx = Math.abs(h) % paletteClasses.length;
  return paletteClasses[idx];
}
