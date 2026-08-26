import { NextResponse } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/admin";

  if (code) {
    const cookieStore = await cookies();

    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
      {
        cookies: {
          getAll() {
            return cookieStore.getAll();
          },
          setAll(cookiesToSet) {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          },
        },
      }
    );

    const { data: authData, error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error && authData.user) {
      // Check admin role
      const { data: profile } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", authData.user.id)
        .single();

      if (profile && (profile.role === "admin" || profile.role === "superadmin")) {
        return NextResponse.redirect(`${origin}/admin`);
      } else {
        // Not an admin, sign out and redirect to login with error
        await supabase.auth.signOut();
        const roleMsg = profile?.role ? ` (Your role: ${profile.role})` : "";
        return NextResponse.redirect(
          `${origin}/login?error=${encodeURIComponent("Access denied. Admin privileges required." + roleMsg)}`
        );
      }
    }
  }

  // Return the user to login with error if auth failed
  return NextResponse.redirect(`${origin}/login?error=${encodeURIComponent("Authentication failed.")}`);
}
