"use client";

// import React from "react";
import Link from "next/link";
import SafeImage from "@/components/ui/SafeImage";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  getInitials,
  generateAvatarGradientClass,
} from "@/components/ui/avatar-utils";

type Props = {
  username?: string | null;
  avatarUrl?: string | null;
  userId?: string | null;
  size?: "sm" | "md";
  className?: string;
  showProfileLink?: boolean;
};

// Use shared `getInitials` from avatar-utils for consistency

export default function UserBadge({
  username,
  avatarUrl,
  userId,
  size = "sm",
  className = "",
  showProfileLink = true,
}: Props) {
  const avatarClass = size === "sm" ? "h-8 w-8" : "h-10 w-10";
  // Only display the username in the forum UI. Show as @username.
  const name = username ? `@${username}` : "Anonymous";
  const initialsName = username ?? "Anonymous";
  // Compute avatar URL: prefer explicit `avatarUrl` only. We intentionally don't accept
  // storage paths here — callers should pass resolved `avatarUrl` values to keep UI logic simple.
  // Treat empty string/whitespace as `null` so browsers don't interpret `src=""` which may
  // cause a reload or warning in tests.
  const computedAvatar: string | null =
    avatarUrl && avatarUrl.trim() !== "" ? avatarUrl : null;
  const content = (
    <div className={`flex items-center gap-2 ${className}`}>
      {computedAvatar ? (
        <SafeImage
          src={computedAvatar}
          alt={username ? `@${username}` : "avatar"}
          className={`rounded-full object-cover ${avatarClass}`}
        />
      ) : (
        <Avatar className={avatarClass}>
          <AvatarFallback className={generateAvatarGradientClass(initialsName)}>
            <span className="text-sm" aria-hidden>
              {getInitials(initialsName)}
            </span>
          </AvatarFallback>
        </Avatar>
      )}

      <div className="min-w-0">
        <div className="text-sm font-medium leading-5 truncate">{name}</div>
      </div>
    </div>
  );

  if (showProfileLink && userId) {
    // Link to the dashboard profile page. We do not have per-user public
    // profile pages in this app, so link to the dashboard profile overview.
    return <Link href={`/dashboard/profile`}>{content}</Link>;
  }

  return content;
}
