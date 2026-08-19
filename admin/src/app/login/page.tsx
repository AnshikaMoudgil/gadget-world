"use client";

import { useState, useEffect, Suspense } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useSearchParams } from "next/navigation";

function LoginForm() {
  const [error, setError] = useState("");
  const [googleLoading, setGoogleLoading] = useState(false);
  const searchParams = useSearchParams();
  const supabase = createBrowserSupabaseClient();

  useEffect(() => {
    const urlError = searchParams.get("error");
    if (urlError) {
      setError(urlError);
    }
  }, [searchParams]);

  const handleGoogleLogin = async () => {
    setError("");
    setGoogleLoading(true);
    try {
      const { error: authError } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      });

      if (authError) {
        setError(authError.message);
        setGoogleLoading(false);
      }
    } catch (err: any) {
      setError(err?.message || "Failed to initiate Google Sign-In.");
      setGoogleLoading(false);
    }
  };

  return (
    <div className="bg-white border border-slate-200 rounded-2xl px-8 py-12 shadow-xl animate-slide-up">
      {/* Brand */}
      <div className="text-center mb-8">
        <div className="w-14 h-14 flex items-center justify-center bg-slate-900 rounded-xl mx-auto mb-4 text-white shadow-md">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5z" />
            <path d="M2 17l10 5 10-5" />
            <path d="M2 12l10 5 10-5" />
          </svg>
        </div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          GadgetWorld
        </h1>
        <p className="text-sm text-slate-500 mt-1 font-medium tracking-widest uppercase">
          Admin Console
        </p>
      </div>

      {error && (
        <div className="mb-6 flex items-center gap-2 px-3.5 py-2.5 bg-red-50 border border-red-200 rounded-lg text-red-600 text-[0.8125rem] font-medium animate-slide-up">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10" />
            <line x1="15" y1="9" x2="9" y2="15" />
            <line x1="9" y1="9" x2="15" y2="15" />
          </svg>
          {error}
        </div>
      )}

      {/* Google Sign In Button */}
      <button
        type="button"
        onClick={handleGoogleLogin}
        disabled={googleLoading}
        className="w-full flex items-center justify-center gap-3 py-3.5 px-4 bg-slate-900 text-white hover:bg-slate-800 active:bg-slate-950 rounded-xl font-semibold text-sm transition-all duration-200 shadow-md disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
      >
        {googleLoading ? (
          <>
            <span className="spinner border-white/20 border-t-white" />
            Connecting to Google...
          </>
        ) : (
          <>
            <svg width="18" height="18" viewBox="0 0 24 24">
              <path
                fill="#4285F4"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              />
              <path
                fill="#34A853"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              />
              <path
                fill="#FBBC05"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
              />
              <path
                fill="#EA4335"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
              />
            </svg>
            Sign in with Google
          </>
        )}
      </button>

      <p className="text-center text-xs text-slate-400 mt-8 tracking-wider">
        Protected area · Admin access only
      </p>
    </div>
  );
}

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-slate-50">
      {/* Animated background blobs */}
      <div className="absolute w-[500px] h-[500px] rounded-full blur-[100px] opacity-[0.04] bg-white -top-50 -right-25 animate-float" />
      <div className="absolute w-[400px] h-[400px] rounded-full blur-[100px] opacity-[0.03] bg-white -bottom-[150px] -left-25 animate-float" style={{ animationDelay: "-5s" }} />
      <div className="absolute w-[300px] h-[300px] rounded-full blur-[100px] opacity-[0.02] bg-white top-1/2 left-1/2 animate-float" style={{ animationDelay: "-10s" }} />

      <div className="relative z-10 w-full max-w-[420px] px-4">
        <Suspense fallback={<div className="text-center text-white/50 text-sm">Loading login...</div>}>
          <LoginForm />
        </Suspense>
      </div>
    </div>
  );
}
