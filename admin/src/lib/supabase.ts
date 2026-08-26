import { createBrowserClient } from "@supabase/ssr";

/**
 * Browser-side Supabase client (uses anon key, respects RLS).
 * Safe to use in Client Components.
 */
export function createBrowserSupabaseClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!
  );
}
