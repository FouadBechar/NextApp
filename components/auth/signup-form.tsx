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
import { signupSchema } from "@/lib/utils/validation";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion } from "framer-motion";
import EyeIcon from "@/components/icons/eye";
import EyeOffIcon from "@/components/icons/eye-off";
import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";

type FormData = z.infer<typeof signupSchema>;

export function SignupForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const form = useForm<FormData>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      username: "",
      email: "",
      password: "",
      confirmPassword: "",
    },
  });

  const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(
    null
  );
  const [checkingUsername, setCheckingUsername] = useState(false);

  // Debounced username availability check
  let usernameTimer: number | undefined;
  function checkUsername(value: string) {
    window.clearTimeout(usernameTimer);
    if (!value || value.length < 3) {
      setUsernameAvailable(null);
      return;
    }
    setCheckingUsername(true);
    usernameTimer = window.setTimeout(async () => {
      try {
        const res = await fetch(
          `/api/auth/username-availability?username=${encodeURIComponent(value)}`
        );
        const json = await res.json();
        setUsernameAvailable(!!json.available);
      } catch (e) {
        setUsernameAvailable(null);
      } finally {
        setCheckingUsername(false);
      }
    }, 500);
  }

  async function onSubmit(data: FormData) {
    setIsLoading(true);
    setError(null);

    try {
      sessionStorage.setItem("verificationEmail", data.email);
      // persist chosen username across verification step
      if ((data as any).username) {
        sessionStorage.setItem("verificationUsername", (data as any).username);
      }

      await fetch("/api/resend", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          type: "verification",
          email: data.email,
          password: data.password,
          username: (data as any).username,
        }),
      });

      router.push("/auth/verify");
    } catch (error) {
      setError(
        error instanceof Error
          ? error.message
          : "An error occurred during signup"
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
            name="username"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Username</FormLabel>
                <FormControl>
                  <Input
                    placeholder="yourusername"
                    {...field}
                    onChange={(e) => {
                      field.onChange(e);
                      checkUsername(e.target.value);
                    }}
                  />
                </FormControl>
                <FormMessage />
                <div className="text-sm mt-1">
                  {checkingUsername ? (
                    <span className="text-muted-foreground">Checking...</span>
                  ) : usernameAvailable === null ? null : usernameAvailable ? (
                    <span className="text-success">Username available</span>
                  ) : (
                    <span className="text-destructive">Username taken</span>
                  )}
                </div>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl>
                  <div className="relative">
                    <Input
                      type={showPassword ? "text" : "password"}
                      placeholder="••••••••"
                      {...field}
                    />
                    <button
                      type="button"
                      aria-label={
                        showPassword ? "Hide password" : "Show password"
                      }
                      onClick={() => setShowPassword((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showPassword ? (
                        <EyeOffIcon className="h-5 w-5" />
                      ) : (
                        <EyeIcon className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="confirmPassword"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Confirm Password</FormLabel>
                <FormControl>
                  <div className="relative">
                    <Input
                      type={showConfirm ? "text" : "password"}
                      placeholder="••••••••"
                      {...field}
                    />
                    <button
                      type="button"
                      aria-label={
                        showConfirm
                          ? "Hide confirm password"
                          : "Show confirm password"
                      }
                      onClick={() => setShowConfirm((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showConfirm ? (
                        <EyeOffIcon className="h-5 w-5" />
                      ) : (
                        <EyeIcon className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? "Creating account..." : "Create account"}
          </Button>
        </form>
      </Form>

      <div className="text-center text-sm">
        Already have an account?{" "}
        <Link href="/auth/login" className="text-blue-600 hover:underline">
          Sign in
        </Link>
      </div>
    </div>
  );
}
