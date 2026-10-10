"use client";

import React from "react";
import dynamic from "next/dynamic";
import { ActivityList } from "./activity-list";
// import { Button } from "@/components/ui/button";

const ActivityChart = dynamic(() => import("./activity-chart"), { ssr: false });

type Props = {
  counts: number[] | null;
  labels?: string[] | null;
  isLoading: boolean;
  recentActivities?: Activity[] | null;
  showRecentList?: boolean;
  onRefresh?: () => void;
  onToggleRecent?: () => void;
};

export default function ActivitySection({ counts, labels, isLoading, recentActivities, showRecentList = false, onRefresh, onToggleRecent }: Props) {
  if (isLoading) return <div className="mt-3 h-48 animate-pulse rounded bg-muted/20" />;
  if (!counts || !labels) return <div className="text-sm text-muted-foreground">No activity data available.</div>;

  return (
    <div>
      <div className="w-full" >
        <React.Suspense fallback={<div className="h-48 w-full animate-pulse rounded bg-muted/20" /> }>
          <ActivityChart counts={counts} labels={labels} height={160} showDotsInterval={6} />
        </React.Suspense>
      </div>
      <div className="mt-3 grid grid-cols-3 gap-2 text-xs text-muted-foreground">
        <div>
          <div className="font-medium">Total</div>
          <div>{counts.reduce((a, b) => a + b, 0)}</div>
        </div>
        <div>
          <div className="font-medium">Period</div>
          <div>Last 30 days</div>
        </div>
        <div>
          <div className="font-medium">Peak</div>
          <div>{Math.max(...counts)}</div>
        </div>
      </div>

      {showRecentList && (
        <div className="mt-4">
          <div className="text-sm font-medium mb-2">Recent Activity</div>
          {recentActivities && recentActivities.length > 0 ? (
            <ActivityList activities={recentActivities.map((a) => ({ ...a, timestamp: a.timestamp }))} />
          ) : (
            <div className="text-sm text-muted-foreground">No recent activity.</div>
          )}
        </div>
      )}

      {/* Controls live in the page header to avoid duplication — keep callbacks for interaction only */}
    </div>
  );
}
