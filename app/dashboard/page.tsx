import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import DiscussionForum from '@/components/forum/DiscussionForum';

export default function DashboardPage() {
  return (
    <DashboardLayout>
      <div className="py-4">
        <DiscussionForum />
      </div>
    </DashboardLayout>
  );
}
