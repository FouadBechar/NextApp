import type { NextConfig } from "next";

// Dev-only helper: Allow developer machines to add trusted origins
// for the dev server. Set the `ALLOWED_DEV_ORIGINS` environment
// variable as a comma-separated list of origins and the dev server
// will allow those origins when serving /_next/* resources.
// Example: ALLOWED_DEV_ORIGINS=http://localhost:3000,http://192.168.0.5:3000
const allowed = typeof process.env.ALLOWED_DEV_ORIGINS === "string"
  ? process.env.ALLOWED_DEV_ORIGINS.split(",").map((s) => s.trim()).filter(Boolean)
  : undefined;

const nextConfig: NextConfig = {
  // This will be used only in dev to silence cross-origin dev warnings
  // when you open the site via the network IP (e.g. http://192.168.x.y:3000).
  // Only set the dev-only config when in development.
  allowedDevOrigins: process.env.NODE_ENV === 'development' ? allowed : undefined,
  reactStrictMode: true,
  experimental: {
    // This app uses proxy.ts, so multipart form uploads pass through Next's proxy
    // body buffering. The default limit is 10MB, which is too small for the
    // 18MB attachment limit exposed by the contact form.
    proxyClientMaxBodySize: '20mb',
  },
  turbopack: {
    root: __dirname,
  },
};

export default nextConfig;
