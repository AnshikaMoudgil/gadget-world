"use client";

import { useEffect, useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { DashboardStats } from "@/lib/types";

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const supabase = createBrowserSupabaseClient();

  useEffect(() => {
    async function loadStats() {
      try {
        const [productsRes, categoriesRes, brandsRes, usersRes, activeProductsRes] =
          await Promise.all([
            supabase.from("products").select("*", { count: "exact", head: true }),
            supabase.from("categories").select("*", { count: "exact", head: true }),
            supabase.from("brands").select("*", { count: "exact", head: true }),
            supabase.from("profiles").select("*", { count: "exact", head: true }),
            supabase
              .from("products")
              .select("*", { count: "exact", head: true })
              .eq("is_active", true),
          ]);

        setStats({
          totalProducts: productsRes.count ?? 0,
          totalCategories: categoriesRes.count ?? 0,
          totalBrands: brandsRes.count ?? 0,
          totalUsers: usersRes.count ?? 0,
          totalOrders: 0,
          activeProducts: activeProductsRes.count ?? 0,
        });
      } catch (err) {
        console.error("Failed to load stats:", err);
      } finally {
        setLoading(false);
      }
    }
    loadStats();
  }, []);

  const statCards = [
    { label: "Total Products", value: stats?.totalProducts ?? 0, icon: "📦", color: "bg-white/10", textColor: "text-white" },
    { label: "Active Products", value: stats?.activeProducts ?? 0, icon: "✅", color: "bg-white/5", textColor: "text-text-secondary" },
    { label: "Categories", value: stats?.totalCategories ?? 0, icon: "📂", color: "bg-white/5", textColor: "text-text-secondary" },
    { label: "Brands", value: stats?.totalBrands ?? 0, icon: "🏷️", color: "bg-white/5", textColor: "text-text-secondary" },
    { label: "Users", value: stats?.totalUsers ?? 0, icon: "👥", color: "bg-white/5", textColor: "text-text-secondary" },
    { label: "Orders", value: stats?.totalOrders ?? 0, icon: "🛒", color: "bg-white/5", textColor: "text-text-secondary" },
  ];

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
          <p className="text-text-secondary text-sm mt-1">Welcome back to GadgetWorld Admin</p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-[repeat(auto-fill,minmax(220px,1fr))] gap-4">
        {statCards.map((card, i) => (
          <div
            key={card.label}
            className="glass-card p-6 flex flex-col gap-2 animate-slide-up"
            style={{ animationDelay: `${i * 50}ms`, animationFillMode: "backwards" }}
          >
            {loading ? (
              <>
                <div className="w-[42px] h-[42px] rounded-lg bg-gradient-to-r from-bg-tertiary via-bg-elevated to-bg-tertiary bg-[length:200%_100%] animate-shimmer" />
                <div className="w-15 h-7 mt-2 rounded bg-gradient-to-r from-bg-tertiary via-bg-elevated to-bg-tertiary bg-[length:200%_100%] animate-shimmer" />
                <div className="w-25 h-4 rounded bg-gradient-to-r from-bg-tertiary via-bg-elevated to-bg-tertiary bg-[length:200%_100%] animate-shimmer" />
              </>
            ) : (
              <>
                <div className={`w-[42px] h-[42px] flex items-center justify-center rounded-lg text-xl mb-1 ${card.color} ${card.textColor}`}>
                  {card.icon}
                </div>
                <span className="text-3xl font-bold tracking-tight">{card.value.toLocaleString()}</span>
                <span className="text-[0.8125rem] text-text-secondary font-medium">{card.label}</span>
              </>
            )}
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className="mt-8">
        <h2 className="text-lg font-semibold mb-4 tracking-tight">Quick Actions</h2>
        <div className="grid grid-cols-[repeat(auto-fill,minmax(180px,1fr))] gap-4">
          {[
            { href: "/admin/products?action=new", icon: "➕", label: "Add Product" },
            { href: "/admin/categories", icon: "📂", label: "Manage Categories" },
            { href: "/admin/brands", icon: "🏷️", label: "Manage Brands" },
            { href: "/admin/users", icon: "👥", label: "Manage Users" },
          ].map((action) => (
            <a
              key={action.href}
              href={action.href}
              className="glass-card flex flex-col items-center gap-2 p-6 hover:-translate-y-0.5 hover:shadow-[0_0_24px_var(--color-accent-glow)] transition-all duration-150 group"
            >
              <span className="text-2xl">{action.icon}</span>
              <span className="text-[0.8125rem] font-medium text-text-secondary group-hover:text-text-primary transition-colors">
                {action.label}
              </span>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}
