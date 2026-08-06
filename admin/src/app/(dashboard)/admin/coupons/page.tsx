"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import ConfirmModal from "@/components/ConfirmModal";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { Coupon } from "@/lib/types";
import Link from "next/link";
import CustomSelect from "@/components/CustomSelect";

export default function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const [deleteCouponTarget, setDeleteCouponTarget] = useState<Coupon | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);
  
  const supabase = createBrowserSupabaseClient();

  const loadCoupons = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("coupons")
      .select("*")
      .order("created_at", { ascending: false });

    if (search) query = query.ilike("code", `%${search}%`);
    if (statusFilter === "active") query = query.eq("is_active", true);
    if (statusFilter === "inactive") query = query.eq("is_active", false);

    const { data, error } = await query;
    if (!error) {
      setCoupons(data as Coupon[]);
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to load coupons"));
    }
    setLoading(false);
  }, [search, statusFilter]);

  useEffect(() => { loadCoupons(); }, [loadCoupons]);

  const toggleActive = async (coupon: Coupon) => {
    const { error } = await supabase.from("coupons").update({ is_active: !coupon.is_active }).eq("id", coupon.id);
    if (!error) {
      setCoupons((prev) => prev.map((c) => c.id === coupon.id ? { ...c, is_active: !c.is_active } : c));
      showToast("success", `Coupon ${!coupon.is_active ? "activated" : "deactivated"}`);
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to update coupon status"));
    }
  };

  const handleDeleteCoupon = async () => {
    if (!deleteCouponTarget) return;
    setIsDeleting(true);
    const { error } = await supabase.from("coupons").delete().eq("id", deleteCouponTarget.id);
    if (!error) {
      setCoupons((prev) => prev.filter((c) => c.id !== deleteCouponTarget.id));
      showToast("success", "Coupon deleted successfully");
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to delete coupon"));
    }
    setIsDeleting(false);
    setDeleteCouponTarget(null);
  };

  const showToast = (type: "success" | "error", message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 3000);
  };

  const statusOptions = [
    { value: "", label: "All Statuses" },
    { value: "active", label: "Active" },
    { value: "inactive", label: "Inactive" },
  ];

  return (
    <div className="flex flex-col gap-6 w-full max-w-7xl mx-auto p-4 sm:p-6 lg:p-8 animate-in fade-in duration-500">
      {/* Toast Notification */}
      {toast && (
        <div className={`fixed top-4 right-4 z-50 p-4 rounded-xl shadow-lg border flex items-center gap-3 animate-in slide-in-from-top-2 ${toast.type === "success" ? "bg-white border-emerald-100 text-emerald-800" : "bg-white border-rose-100 text-rose-800"}`}>
          <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 ${toast.type === "success" ? "bg-emerald-100 text-emerald-600" : "bg-rose-100 text-rose-600"}`}>
            {toast.type === "success" ? (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12" /></svg>
            ) : (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10" /><line x1="12" y1="8" x2="12" y2="12" /><line x1="12" y1="16" x2="12.01" y2="16" /></svg>
            )}
          </div>
          <p className="text-sm font-semibold pr-4">{toast.message}</p>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">Coupons</h1>
          <p className="text-sm text-slate-500 mt-1 font-medium">Manage discount codes and promotional offers.</p>
        </div>
        <Link
          href="/admin/coupons/new"
          className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-slate-900 text-white text-sm font-semibold rounded-xl hover:bg-slate-800 hover:shadow-md hover:-translate-y-0.5 transition-all focus:outline-none focus:ring-2 focus:ring-slate-900 focus:ring-offset-2 w-full sm:w-auto"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></svg>
          Add Coupon
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1 min-w-[200px] relative group">
            <svg className="absolute left-3.5 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-indigo-500 transition-colors" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" /></svg>
            <input
              type="text"
              placeholder="Search coupon code..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-11 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-medium placeholder:text-slate-400"
            />
          </div>
          <div className="w-full lg:w-48">
            <CustomSelect
              options={statusOptions}
              value={statusFilter}
              onChange={setStatusFilter}
              placeholder="Status"
            />
          </div>
        </div>
      </div>

      {/* Main Table */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden flex-1 flex flex-col relative min-h-[400px]">
        {loading ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-white/80 backdrop-blur-sm z-10">
            <div className="w-10 h-10 border-3 border-indigo-600/30 border-t-indigo-600 rounded-full animate-spin" />
            <p className="mt-4 text-sm font-semibold text-slate-600">Loading coupons...</p>
          </div>
        ) : coupons.length === 0 ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-6">
            <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 mb-4 border border-slate-100 shadow-sm">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21.21 15.89A10 10 0 1 1 8 2.83" /><path d="M22 12A10 10 0 0 0 12 2v10z" /></svg>
            </div>
            <h3 className="text-lg font-bold text-slate-900 mb-1">No coupons found</h3>
            <p className="text-slate-500 max-w-[250px] text-sm">
              {search || statusFilter ? "Try adjusting your search filters to find what you're looking for." : "Get started by creating your first promotional coupon."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                  <th className="px-6 py-4 rounded-tl-xl whitespace-nowrap">Coupon Code</th>
                  <th className="px-6 py-4 whitespace-nowrap">Discount Details</th>
                  <th className="px-6 py-4 whitespace-nowrap">Usage Limit</th>
                  <th className="px-6 py-4 whitespace-nowrap">Status</th>
                  <th className="px-6 py-4 text-right rounded-tr-xl whitespace-nowrap">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {coupons.map((coupon) => (
                  <tr key={coupon.id} className="group hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100/50 flex items-center justify-center text-indigo-600 shrink-0">
                          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21.21 15.89A10 10 0 1 1 8 2.83" /><path d="M22 12A10 10 0 0 0 12 2v10z" /></svg>
                        </div>
                        <div>
                          <div className="text-sm font-bold text-slate-900 tracking-tight">{coupon.code}</div>
                          <div className="text-xs text-slate-500 mt-0.5">Min. ₹{coupon.min_order_value}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm font-semibold text-slate-700">
                        {coupon.discount_type === 'percentage' && `${coupon.discount_value}% OFF`}
                        {coupon.discount_type === 'fixed_amount' && `₹${coupon.discount_value} OFF`}
                        {coupon.discount_type === 'free_shipping' && `FREE SHIPPING`}
                      </div>
                      {coupon.max_discount_amount && (
                        <div className="text-xs text-slate-500 mt-0.5">Up to ₹{coupon.max_discount_amount}</div>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-slate-700">
                        <span className="font-semibold text-slate-900">{coupon.times_used}</span>
                        {coupon.total_usage_limit ? ` / ${coupon.total_usage_limit}` : ' uses'}
                      </div>
                      {coupon.usage_limit_per_user && (
                        <div className="text-xs text-slate-500 mt-0.5">Max {coupon.usage_limit_per_user} per user</div>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => toggleActive(coupon)}
                        className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${coupon.is_active ? 'bg-emerald-500' : 'bg-slate-300'}`}
                      >
                        <span className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-sm transition-transform ${coupon.is_active ? 'translate-x-4' : 'translate-x-1'}`} />
                      </button>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => setDeleteCouponTarget(coupon)}
                        className="w-8 h-8 inline-flex items-center justify-center rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors focus:outline-none focus:ring-2 focus:ring-rose-500 focus:ring-offset-2"
                        title="Delete Coupon"
                      >
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" /></svg>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <ConfirmModal
        isOpen={!!deleteCouponTarget}
        title="Delete Coupon"
        message={`Are you sure you want to delete coupon "${deleteCouponTarget?.code}"? This action cannot be undone.`}
        confirmText={isDeleting ? "Deleting..." : "Delete"}
        cancelText="Cancel"
        onConfirm={handleDeleteCoupon}
        onCancel={() => !isDeleting && setDeleteCouponTarget(null)}
        isDestructive={true}
      />
    </div>
  );
}
