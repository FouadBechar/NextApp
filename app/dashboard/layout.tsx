import "../globals2.css";
import ThemeWrapper from "@/components/ThemeWrapper";
import { DashboardLayout as DashboardShell } from "@/components/dashboard/dashboard-layout";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <ThemeWrapper>
      <DashboardShell>{children}</DashboardShell>
    </ThemeWrapper>
  );
}
