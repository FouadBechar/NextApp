"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";

export default function Verify2faClient({ userId }: { userId?: string }) {
  const router = useRouter();

  const [code, setCode] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    try {
      if (!userId) throw new Error("Missing userId");
      const res = await fetch("/api/auth/2fa/verify-login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId, token: code }),
      });

      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        throw new Error(json?.error || `Verification failed (${res.status})`);
      }

      // On success the server sets the trusted_device cookie. Finalize flow.
      router.push("/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div>
      <h2 className="text-lg font-medium mb-4">Two-factor verification</h2>
      <p className="text-sm text-muted-foreground mb-4">Enter the 6-digit code from your authenticator app.</p>

      {error && (
        <div className="mb-4">
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        </div>
      )}

      <form onSubmit={onSubmit} className="space-y-4">
        <div>
          <Label>Code</Label>
          <Input
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="123456"
            autoFocus
          />
        </div>

        <Button type="submit" className="w-full" disabled={isLoading}>
          {isLoading ? "Verifying..." : "Verify"}
        </Button>
      </form>
    </div>
  );
}
