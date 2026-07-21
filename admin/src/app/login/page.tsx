"use client";

import { useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const supabase = createBrowserSupabaseClient();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (authError) {
        setError(authError.message);
        setLoading(false);
        return;
      }

      // Verify admin role
      const { data: profile, error: profileError } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", data.user.id)
        .single();

      if (profileError || !profile) {
        setError("Unable to verify admin access.");
        await supabase.auth.signOut();
        setLoading(false);
        return;
      }

      if (profile.role !== "admin" && profile.role !== "superadmin") {
        setError("Access denied. Admin privileges required.");
        await supabase.auth.signOut();
        setLoading(false);
        return;
      }

      router.push("/");
      router.refresh();
    } catch {
      setError("An unexpected error occurred.");
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-bg-primary">
      {/* Animated background blobs */}
      <div className="absolute w-[500px] h-[500px] rounded-full blur-[100px] opacity-[0.04] bg-white -top-50 -right-25 animate-float" />
      <div className="absolute w-[400px] h-[400px] rounded-full blur-[100px] opacity-[0.03] bg-white -bottom-[150px] -left-25 animate-float" style={{ animationDelay: "-5s" }} />
      <div className="absolute w-[300px] h-[300px] rounded-full blur-[100px] opacity-[0.02] bg-white top-1/2 left-1/2 animate-float" style={{ animationDelay: "-10s" }} />

      <div className="relative z-10 w-full max-w-[420px] px-4">
        <div className="bg-[rgba(10,10,10,0.85)] backdrop-blur-3xl border border-white/8 rounded-2xl px-8 py-12 shadow-lg animate-slide-up">
          {/* Brand */}
          <div className="text-center mb-8">
            <div className="w-14 h-14 flex items-center justify-center bg-white rounded-xl mx-auto mb-4 text-black shadow-[0_0_24px_rgba(255,255,255,0.12)]">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 2L2 7l10 5 10-5-10-5z" />
                <path d="M2 17l10 5 10-5" />
                <path d="M2 12l10 5 10-5" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold tracking-tight bg-gradient-to-br from-text-primary to-text-secondary bg-clip-text text-transparent">
              GadgetWorld
            </h1>
            <p className="text-sm text-text-tertiary mt-1 font-medium tracking-widest uppercase">
              Admin Console
            </p>
          </div>

          {/* Login Form */}
          <form onSubmit={handleLogin} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="email" className="form-label">Email address</label>
              <input
                id="email"
                type="email"
                className="form-input"
                placeholder="admin@gadgetworld.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoFocus
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <label htmlFor="password" className="form-label">Password</label>
              <input
                id="password"
                type="password"
                className="form-input"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            {error && (
              <div className="flex items-center gap-2 px-3.5 py-2.5 bg-danger-bg border border-danger/20 rounded-lg text-danger text-[0.8125rem] font-medium animate-slide-up">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="15" y1="9" x2="9" y2="15" />
                  <line x1="9" y1="9" x2="15" y2="15" />
                </svg>
                {error}
              </div>
            )}

            <button
              type="submit"
              className="btn btn-primary w-full py-3 text-[0.9375rem] mt-2 disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none"
              disabled={loading}
            >
              {loading ? (
                <>
                  <span className="spinner" />
                  Signing in...
                </>
              ) : (
                "Sign in"
              )}
            </button>
          </form>

          <p className="text-center text-xs text-text-tertiary mt-6 tracking-wider">
            Protected area · Admin access only
          </p>
        </div>
      </div>
    </div>
  );
}
