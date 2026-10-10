"use client";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { login } from "@/lib/utils/auth-helpers";
import { loginSchema } from "@/lib/utils/validation";
import { createClient } from "@/utils/supabase/client";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion } from "framer-motion";
import PasswordInput from '@/components/ui/password-input';
import { executeRecaptchaSafe } from "@/lib/utils/recaptcha";
import { extractMessageFromObject } from '@/utils/extract-message';
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { useState } from "react";
import { z } from "zod";

type FormData = z.infer<typeof loginSchema>;

export function LoginForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const router = useRouter();


  const form = useForm<FormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  async function checkLoginAttempt(email: string, phase: "preflight" | "failed") {
    const response = await fetch('/api/auth/login-attempt', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, phase }),
    });

    if (!response.ok) {
      const result = await response.json().catch(() => null);
      throw new Error(extractMessageFromObject(result) || 'Too many login attempts');
    }
  }

  async function onSubmit(data: FormData) {
    setIsLoading(true);
    setError(null);

    try {
      // If reCAPTCHA is configured, verify token server-side before sign-in
      const siteKey = process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY;
      if (siteKey) {
        try {
          const res = await executeRecaptchaSafe(siteKey, "login");
          if (!res.ok) {
            // Block login: show error and return
            setError(res.error || "reCAPTCHA unavailable");
            setIsLoading(false);
            return;
          } else {
            const token = res.token;
            // Verify token server-side, but be defensive about the response shape
            let verifyJson: Record<string, unknown> | null = null;
            try {
              const verifyRes = await fetch("/api/recaptcha", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ token, action: 'login' }),
              });

              // If server didn't return JSON (e.g., 405 or empty body), handle gracefully
              const contentType = verifyRes.headers.get("content-type") || "";
              if (!verifyRes.ok) {
                let json: Record<string, unknown> | null = null;
                if (contentType.includes("application/json")) json = await verifyRes.json();
                // Block login if server rejects verification
                setError(extractMessageFromObject(json) || `reCAPTCHA verify failed (${verifyRes.status})`);
                setIsLoading(false);
                return;
              }

              if (contentType.includes("application/json")) {
                verifyJson = await verifyRes.json();
              } else {
                throw new Error("reCAPTCHA verify returned non-JSON response");
              }

              if (!verifyJson?.success) {
                setError(extractMessageFromObject(verifyJson) || "reCAPTCHA verification failed");
                setIsLoading(false);
                return;
              }
            } catch (verifyErr) {
              setError((verifyErr as Error).message || String(verifyErr));
              setIsLoading(false);
              return;
            }
          }
        } catch (recErr) {
          setError((recErr as Error).message || String(recErr));
          setIsLoading(false);
          return;
        }
      }

      // Before attempting sign-in, call the server-side rate limiter to
      // refuse excessive attempts. This prevents brute force even though
      // the actual sign-in still happens with Supabase client-side.
      try {
        await checkLoginAttempt(data.email, "preflight");
      } catch (rlErr) {
        // Surface rate-limit message to the user
        setError(rlErr instanceof Error ? rlErr.message : String(rlErr));
        setIsLoading(false);
        return;
      }

      let res;
      try {
        res = await login(data.email, data.password);
      } catch (signInError) {
        try {
          await checkLoginAttempt(data.email, "failed");
        } catch (rateLimitError) {
          throw rateLimitError;
        }

        throw signInError;
      }

      // After password sign-in, check whether the user has 2FA enabled and
      // whether this device is trusted. If 2FA is enabled and device is not
      // trusted, redirect to a verification page before allowing access.
      try {
        const userId = res?.user?.id;
        const token = res?.session?.access_token;
        if (!userId || !token) {
          throw new Error("Unable to verify account security settings");
        }

        const profileRes = await fetch(`/api/dashboard/profile?userId=${encodeURIComponent(userId)}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!profileRes.ok) {
          throw new Error("Unable to verify account security settings");
        }

        const json = await profileRes.json();
        const totp = json?.profile?.totp;
        const trustedDevice = !!json?.profile?.trustedDevice;
        const totpEnabled =
          typeof totp === "object" &&
          totp !== null &&
          "enabled" in totp &&
          Boolean((totp as { enabled?: unknown }).enabled);
        if (totpEnabled && !trustedDevice) {
          // require 2FA verification — show a clear message and redirect to verification UI
          setInfo('Two-Factor Authentication is required for this account. Redirecting to verification...');
          router.replace(`/auth/2fa/verify?userId=${encodeURIComponent(userId)}`);
          return;
        }
      } catch (e) {
        console.warn('2FA profile check error', e);
        try {
          await createClient().auth.signOut();
        } catch (signOutError) {
          console.warn('Failed to clear session after 2FA check error', signOutError);
        }
        setError('Unable to verify account security settings. Please try signing in again.');
        return;
      }

      // If we reached here, proceed to the dashboard
      router.push("/dashboard");
    } catch (error) {
      setError(
        error instanceof Error ? error.message : "Invalid email or password"
      );
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="space-y-6">
      {error && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        </motion.div>
      )}

      {info && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          <Alert>
            <AlertDescription>{info}</AlertDescription>
          </Alert>
        </motion.div>
      )}

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input placeholder="you@example.com" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => {
              const { ref, ...rest } = field as unknown as { ref?: React.LegacyRef<HTMLInputElement> } & Record<string, unknown>;
              return (
                <FormItem>
                  <FormLabel>Password</FormLabel>
                  <FormControl>
                    <PasswordInput inputRef={ref} placeholder="••••••••" {...rest} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              );
            }}
          />

          <div className="text-right">
            <Link
              href="/auth/reset-password"
              className="text-sm text-blue-600 hover:underline"
            >
              Forgot password?
            </Link>
          </div>

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? "Signing in..." : "Sign in"}
          </Button>
        </form>
      </Form>

      <div className="text-center text-sm">
        Don&apos;t have an account?{" "}
        <Link href="/auth/signup" className="text-blue-600 hover:underline">
          Sign up
        </Link>
      </div>
    </div>
  );
}
