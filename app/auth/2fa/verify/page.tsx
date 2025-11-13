import Verify2faClient from "./Verify2faClient";

type Props = {
  searchParams?: { userId?: string };
};

export default function Verify2faPage({ searchParams }: Props) {
  const userId = searchParams?.userId || undefined;

  // Render a light wrapper server component and pass the userId to the
  // client component. This avoids using `useSearchParams` in a client
  // component during prerender which causes a Suspense-related build error.
  return (
    <div className="max-w-md mx-auto mt-24 p-6 bg-white rounded shadow">
      <Verify2faClient userId={userId} />
    </div>
  );
}
