import React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface QuickStatsProps {
  threadsCount: number;
  activeTitle?: string | null;
}

export default function QuickStats({ threadsCount, activeTitle }: QuickStatsProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Quick Stats</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <div className="text-sm text-muted-foreground">Discussions</div>
            <div className="font-medium">{threadsCount}</div>
          </div>
          <div className="flex items-center justify-between">
            <div className="text-sm text-muted-foreground">Active Thread</div>
            <div className="font-medium">{activeTitle ? activeTitle : "—"}</div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
