import "server-only";

import { createClient } from "@supabase/supabase-js";

/** Service-role client for Server Components, Server Actions and handlers only. */
export function createAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SECRET_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}
