import { AuthForm } from "@/components/auth/auth-form";
import Verify2faClient from "./Verify2faClient";

type Props = {
  searchParams?: Promise<{ userId?: string }> | { userId?: string };
};

export default async function Verify2faPage({ searchParams }: Props) {
  const resolvedSearchParams = await searchParams;
  const userId = resolvedSearchParams?.userId || undefined;

  return (
    <AuthForm
      title="Two-Factor Verification"
      description="Enter the code from your authenticator app to continue"
    >
      <Verify2faClient userId={userId} />
    </AuthForm>
  );
}
