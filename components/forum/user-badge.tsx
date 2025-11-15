"use client";

import React from 'react';
import Link from 'next/link';

type Props = {
  displayName?: string | null;
  username?: string | null;
  avatarUrl?: string | null;
  userId?: string | null;
  size?: 'sm' | 'md';
  className?: string;
  showProfileLink?: boolean;
};

function initials(name?: string | null) {
  if (!name) return '';
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

export default function UserBadge({
  displayName,
  username,
  avatarUrl,
  userId,
  size = 'sm',
  className = '',
  showProfileLink = true,
}: Props) {
  const avatarClass = size === 'sm' ? 'h-8 w-8' : 'h-10 w-10';
  const name = displayName ?? username ?? 'Anonymous';

  const content = (
    <div className={`flex items-center gap-2 ${className}`}>
      {avatarUrl ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={avatarUrl} alt={name} className={`rounded-full object-cover ${avatarClass}`} />
      ) : (
        <div
          aria-hidden
          className={`rounded-full bg-gray-200 text-gray-700 flex items-center justify-center font-medium ${avatarClass}`}
        >
          <span className="text-sm">{initials(name)}</span>
        </div>
      )}

      <div className="min-w-0">
        <div className="text-sm font-medium leading-5 truncate">{name}</div>
        {username && (
          <div className="text-xs text-muted-foreground truncate">@{username}</div>
        )}
      </div>
    </div>
  );

  if (showProfileLink && userId) {
    return <Link href={`/dashboard/profile/${encodeURIComponent(userId)}`}>{content}</Link>;
  }

  return content;
}
