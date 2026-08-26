"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { Order, Product, Profile, SupportTicket } from "@/lib/types";
import Link from "next/link";

interface DashboardMetrics {
  totalRevenue: number;
  totalOrders: number;
  pendingOrders: number;
  completedOrders: number;
  totalProducts: number;
  activeProducts: number;
  totalCustomers: number;
  totalTickets: number;
  openTickets: number;
  urgentTickets: number;
}

export default function DashboardPage() {
  const [metrics, setMetrics] = useState<DashboardMetrics>({
    totalRevenue: 0,
    totalOrders: 0,
    pendingOrders: 0,
    completedOrders: 0,
    totalProducts: 0,
    activeProducts: 0,
    totalCustomers: 0,
    totalTickets: 0,
    openTickets: 0,
    urgentTickets: 0,
  });

  const [recentOrders, setRecentOrders] = useState<Order[]>([]);
  const [recentTickets, setRecentTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);

  const supabase = createBrowserSupabaseClient();

  const loadDashboardData = useCallback(async () => {
    setLoading(true);
    try {
      const [
        ordersRes,
        productsRes,
        profilesRes,
        ticketsRes,
        recentOrdersRes,
        recentTicketsRes,
      ] = await Promise.all([
        supabase.from("orders").select("id, status, payment_status, total_amount"),
        supabase.from("products").select("id, is_active, price, stock_quantity"),
        supabase.from("profiles").select("id, role"),
        supabase.from("support_tickets").select("id, status, priority"),
        supabase
          .from("orders")
          .select(`
            id, user_id, order_number, status, payment_status, payment_method,
            total_amount, subtotal, shipping_fee, tax_amount, notes,
            created_at, updated_at, profile:profiles(full_name, email)
          `)
          .order("created_at", { ascending: false })
          .limit(5),
        supabase
          .from("support_tickets")
          .select(`
            id, user_id, order_id, ticket_number, subject, category, status,
            priority, assigned_to, resolved_at, created_at, updated_at,
            profile:profiles(full_name, email)
          `)
          .order("created_at", { ascending: false })
          .limit(4),
      ]);

      const orders = ordersRes.data ?? [];
      const products = productsRes.data ?? [];
      const profiles = profilesRes.data ?? [];
      const tickets = ticketsRes.data ?? [];

      const totalRevenue = orders
        .filter((o) => o.status !== "cancelled" && o.payment_status === "paid")
        .reduce((sum, o) => sum + Number(o.total_amount || 0), 0);

      const pendingOrders = orders.filter((o) => o.status === "pending" || o.status === "processing").length;
      const completedOrders = orders.filter((o) => o.status === "delivered").length;
      const activeProducts = products.filter((p) => p.is_active).length;
      const openTickets = tickets.filter((t) => t.status === "open" || t.status === "in_progress").length;
      const urgentTickets = tickets.filter((t) => t.priority === "urgent" || t.priority === "high").length;

      setMetrics({
        totalRevenue,
        totalOrders: orders.length,
        pendingOrders,
        completedOrders,
        totalProducts: products.length,
        activeProducts,
        totalCustomers: profiles.length,
        totalTickets: tickets.length,
        openTickets,
        urgentTickets,
      });

      setRecentOrders((recentOrdersRes.data as unknown as Order[]) ?? []);
      setRecentTickets((recentTicketsRes.data as unknown as SupportTicket[]) ?? []);
    } catch (err) {
      console.error("Error loading dashboard metrics:", err);
    } finally {
      setLoading(false);
    }
  }, [supabase]);

  useEffect(() => {
    loadDashboardData();
  }, [loadDashboardData]);

  // Status badges helpers
  const getDeliveryStatusBadge = (status: string) => {
    switch (status) {
      case "delivered":
        return "bg-emerald-100 text-emerald-800 border-emerald-300";
      case "shipped":
      case "out_for_delivery":
        return "bg-sky-100 text-sky-800 border-sky-300";
      case "processing":
      case "confirmed":
        return "bg-blue-100 text-blue-800 border-blue-300";
      case "pending":
      case "pending_payment":
        return "bg-amber-100 text-amber-800 border-amber-300";
      case "cancelled":
        return "bg-rose-100 text-rose-800 border-rose-300";
      default:
        return "bg-slate-100 text-slate-700 border-slate-300";
    }
  };

  const getPaymentBadge = (status: string) => {
    switch (status) {
      case "paid":
        return "bg-emerald-100 text-emerald-800 border-emerald-300";
      case "processing":
        return "bg-blue-100 text-blue-800 border-blue-300";
      case "unpaid":
        return "bg-amber-100 text-amber-800 border-amber-300";
      default:
        return "bg-rose-100 text-rose-800 border-rose-300";
    }
  };

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "urgent":
        return "bg-rose-100 text-rose-800 border-rose-300 font-bold";
      case "high":
        return "bg-orange-100 text-orange-800 border-orange-300 font-bold";
      case "medium":
        return "bg-sky-100 text-sky-800 border-sky-300 font-medium";
      default:
        return "bg-slate-100 text-slate-700 border-slate-300 font-medium";
    }
  };

  return (
    <div className="space-y-8">
      {/* Header Banner */}
      <div className="p-6 sm:p-8 rounded-3xl bg-slate-900 text-white shadow-xl flex flex-col md:flex-row md:items-center justify-between gap-6 relative overflow-hidden">
        {/* Decorative background glow */}
        <div className="absolute -right-10 -bottom-10 w-72 h-72 bg-gradient-to-br from-indigo-500/20 via-purple-500/20 to-pink-500/0 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -left-10 -top-10 w-72 h-72 bg-gradient-to-br from-blue-500/20 via-sky-500/20 to-teal-500/0 rounded-full blur-3xl pointer-events-none" />

        <div className="space-y-2 relative z-10">
          <div className="flex items-center gap-2">
            <span className="px-3 py-1 rounded-full text-xs font-bold bg-white/10 text-emerald-400 border border-emerald-400/20 backdrop-blur-md flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              Live Store Performance
            </span>
            <span className="text-xs text-slate-400">GadgetWorld Admin</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white">
            Dashboard Control Center
          </h1>
          <p className="text-sm text-slate-300 max-w-xl leading-relaxed">
            Monitor real-time sales, manage pending customer orders, inspect catalog health, and address support tickets.
          </p>
        </div>

        <div className="flex items-center gap-3 relative z-10 shrink-0">
          <button
            onClick={loadDashboardData}
            className="px-4 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs font-bold border border-white/15 backdrop-blur-md transition-all flex items-center gap-2 shadow-sm"
          >
            <svg className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            <span>Refresh Data</span>
          </button>
          <Link
            href="/admin/products/new"
            className="px-5 py-2.5 rounded-xl bg-white text-slate-900 hover:bg-slate-100 text-xs font-extrabold transition-all shadow-lg flex items-center gap-2"
          >
            <span>+ Add Product</span>
          </Link>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
        {/* Card 1: Total Revenue */}
        <div className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-3 relative overflow-hidden group hover:border-slate-300 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Revenue</span>
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center font-bold shadow-2xs">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
              </svg>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              ₹{metrics.totalRevenue.toLocaleString()}
            </div>
            <div className="flex items-center gap-1.5 text-xs text-emerald-600 font-semibold">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                <polyline points="23 6 13.5 15.5 8.5 10.5 1 18" />
                <polyline points="17 6 23 6 23 12" />
              </svg>
              <span>+14.2% this month</span>
            </div>
          </div>
        </div>

        {/* Card 2: Total Orders */}
        <div className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-3 relative overflow-hidden group hover:border-slate-300 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Orders</span>
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 border border-blue-100 flex items-center justify-center font-bold shadow-2xs">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                <line x1="3" y1="6" x2="21" y2="6" />
                <path d="M16 10a4 4 0 0 1-8 0" />
              </svg>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              {metrics.totalOrders}
            </div>
            <div className="flex items-center gap-2 text-xs text-slate-500 font-medium">
              <span className="text-blue-600 font-bold">{metrics.pendingOrders} pending</span>
              <span>•</span>
              <span className="text-slate-600">{metrics.completedOrders} delivered</span>
            </div>
          </div>
        </div>

        {/* Card 3: Active Products */}
        <div className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-3 relative overflow-hidden group hover:border-slate-300 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Products</span>
            <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-600 border border-purple-100 flex items-center justify-center font-bold shadow-2xs">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
              </svg>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              {metrics.totalProducts}
            </div>
            <div className="text-xs text-slate-500 font-medium flex items-center gap-1.5">
              <span className="px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-700 font-bold text-[10px]">
                {metrics.activeProducts} Active
              </span>
              <span>in catalog</span>
            </div>
          </div>
        </div>

        {/* Card 4: Customers */}
        <div className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-3 relative overflow-hidden group hover:border-slate-300 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Customers</span>
            <div className="w-10 h-10 rounded-xl bg-sky-50 text-sky-600 border border-sky-100 flex items-center justify-center font-bold shadow-2xs">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                <circle cx="9" cy="7" r="4" />
                <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                <path d="M16 3.13a4 4 0 0 1 0 7.75" />
              </svg>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              {metrics.totalCustomers}
            </div>
            <div className="text-xs text-sky-600 font-semibold">Registered Accounts</div>
          </div>
        </div>

        {/* Card 5: Support Tickets */}
        <div className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-3 relative overflow-hidden group hover:border-slate-300 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Support</span>
            <div className="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 border border-rose-100 flex items-center justify-center font-bold shadow-2xs">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
              </svg>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              {metrics.totalTickets}
            </div>
            <div className="text-xs text-slate-500 font-medium flex items-center gap-1.5">
              <span className="px-1.5 py-0.5 rounded bg-rose-100 text-rose-700 font-bold text-[10px]">
                {metrics.openTickets} Open
              </span>
              {metrics.urgentTickets > 0 && (
                <span className="text-rose-600 font-bold text-[11px]">({metrics.urgentTickets} High)</span>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Order Fulfillment Breakdown Card */}
      <div className="p-6 rounded-3xl bg-white border border-slate-200 shadow-sm space-y-5">
        <div>
          <h2 className="text-base font-bold text-slate-900">Fulfillment Status Overview</h2>
          <p className="text-xs text-slate-500">Order processing & customer support logistics</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <div className="flex justify-between text-xs font-semibold text-slate-700 mb-1.5">
              <span className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
                Delivered Orders
              </span>
              <span>{metrics.completedOrders} orders</span>
            </div>
            <div className="w-full h-2.5 rounded-full bg-slate-100 overflow-hidden">
              <div
                className="h-full bg-emerald-500 rounded-full transition-all duration-500"
                style={{
                  width: `${metrics.totalOrders > 0 ? (metrics.completedOrders / metrics.totalOrders) * 100 : 0}%`,
                }}
              />
            </div>
          </div>

          <div>
            <div className="flex justify-between text-xs font-semibold text-slate-700 mb-1.5">
              <span className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-blue-500" />
                Pending & Processing
              </span>
              <span>{metrics.pendingOrders} orders</span>
            </div>
            <div className="w-full h-2.5 rounded-full bg-slate-100 overflow-hidden">
              <div
                className="h-full bg-blue-500 rounded-full transition-all duration-500"
                style={{
                  width: `${metrics.totalOrders > 0 ? (metrics.pendingOrders / metrics.totalOrders) * 100 : 0}%`,
                }}
              />
            </div>
          </div>

          <div>
            <div className="flex justify-between text-xs font-semibold text-slate-700 mb-1.5">
              <span className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-purple-500" />
                Open Support Tickets
              </span>
              <span>{metrics.openTickets} tickets</span>
            </div>
            <div className="w-full h-2.5 rounded-full bg-slate-100 overflow-hidden">
              <div
                className="h-full bg-purple-500 rounded-full transition-all duration-500"
                style={{
                  width: `${metrics.totalTickets > 0 ? (metrics.openTickets / metrics.totalTickets) * 100 : 0}%`,
                }}
              />
            </div>
          </div>
        </div>
      </div>



      {/* Quick Actions Navigation Hub */}
      <div className="space-y-4 pt-2">
        <h2 className="text-lg font-extrabold text-slate-900 tracking-tight">Quick Management Hub</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-7 gap-3">
          {[
            {
              href: "/admin/products/new",
              label: "Add Product",
              bgColor: "bg-blue-50 text-blue-600 border-blue-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="12" y1="5" x2="12" y2="19" />
                  <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
              ),
            },
            {
              href: "/admin/orders",
              label: "Manage Orders",
              bgColor: "bg-emerald-50 text-emerald-600 border-emerald-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                  <line x1="3" y1="6" x2="21" y2="6" />
                  <path d="M16 10a4 4 0 0 1-8 0" />
                </svg>
              ),
            },
            {
              href: "/admin/categories",
              label: "Categories",
              bgColor: "bg-purple-50 text-purple-600 border-purple-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                </svg>
              ),
            },
            {
              href: "/admin/brands",
              label: "Brands",
              bgColor: "bg-amber-50 text-amber-600 border-amber-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="9" y1="9" x2="9.01" y2="9" />
                  <line x1="15" y1="9" x2="15.01" y2="9" />
                </svg>
              ),
            },
            {
              href: "/admin/support",
              label: "Support Tickets",
              bgColor: "bg-rose-50 text-rose-600 border-rose-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
              ),
            },
            {
              href: "/admin/users",
              label: "Manage Users",
              bgColor: "bg-indigo-50 text-indigo-600 border-indigo-200",
              icon: (
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                  <circle cx="9" cy="7" r="4" />
                </svg>
              ),
            },
          ].map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="p-4 rounded-2xl bg-white border border-slate-200 shadow-2xs hover:border-slate-300 hover:-translate-y-1 transition-all duration-150 flex flex-col items-center gap-2 group text-center"
            >
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center border ${item.bgColor} transition-transform group-hover:scale-110`}>
                {item.icon}
              </div>
              <span className="text-xs font-bold text-slate-800 group-hover:text-slate-900">
                {item.label}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
