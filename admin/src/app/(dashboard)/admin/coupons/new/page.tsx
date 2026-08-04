"use client";

import { useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import CustomSelect from "@/components/CustomSelect";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import Link from "next/link";

export default function NewCouponPage() {
  const router = useRouter();
  const supabase = createBrowserSupabaseClient();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);

  const [formData, setFormData] = useState({
    code: "",
    discount_type: "percentage",
    discount_value: "",
    min_order_value: "0",
    max_discount_amount: "",
    usage_limit_per_user: "1",
    total_usage_limit: "",
    valid_from: "",
    valid_until: "",
    is_active: true,
  });

  const discountTypeOptions = [
    { value: "percentage", label: "Percentage (%)" },
    { value: "fixed_amount", label: "Fixed Amount (₹)" },
    { value: "free_shipping", label: "Free Shipping" },
  ];

  const handleSave = async () => {
    try {
      if (!formData.code.trim()) {
        showToast("error", "Coupon code is required");
        return;
      }
      
      const discountValue = parseFloat(formData.discount_value);
      if (formData.discount_type !== "free_shipping" && (isNaN(discountValue) || discountValue < 0)) {
        showToast("error", "Valid discount value is required");
        return;
      }

      setIsSubmitting(true);
      const { error } = await supabase.from("coupons").insert([
        {
          code: formData.code.toUpperCase().trim(),
          discount_type: formData.discount_type,
          discount_value: formData.discount_type === "free_shipping" ? 0 : discountValue,
          min_order_value: parseFloat(formData.min_order_value) || 0,
          max_discount_amount: formData.max_discount_amount ? parseFloat(formData.max_discount_amount) : null,
          usage_limit_per_user: formData.usage_limit_per_user ? parseInt(formData.usage_limit_per_user, 10) : null,
          total_usage_limit: formData.total_usage_limit ? parseInt(formData.total_usage_limit, 10) : null,
          valid_from: formData.valid_from ? new Date(formData.valid_from).toISOString() : null,
          valid_until: formData.valid_until ? new Date(formData.valid_until).toISOString() : null,
          is_active: formData.is_active,
        }
      ]);

      if (error) throw error;
      router.push("/admin/coupons");
    } catch (error) {
      showToast("error", getGenericErrorMessage(error, "Failed to create coupon"));
      setIsSubmitting(false);
    }
  };

  const showToast = (type: "success" | "error", message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 3000);
  };

  return (
    <div className="flex flex-col gap-6 w-full max-w-4xl mx-auto animate-in fade-in duration-500">
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
      <div className="flex items-center justify-between bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div className="flex items-center gap-4">
          <Link
            href="/admin/coupons"
            className="w-10 h-10 flex items-center justify-center rounded-full bg-slate-50 text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><line x1="19" y1="12" x2="5" y2="12" /><polyline points="12 19 5 12 12 5" /></svg>
          </Link>
          <div>
            <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight">Create Coupon</h1>
            <p className="text-sm text-slate-500 mt-1 font-medium">Add a new discount code for your customers.</p>
          </div>
        </div>
        <button
          onClick={handleSave}
          disabled={isSubmitting}
          className="inline-flex items-center justify-center px-6 py-2.5 bg-indigo-600 text-white text-sm font-bold rounded-xl hover:bg-indigo-700 hover:shadow-md hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:pointer-events-none"
        >
          {isSubmitting ? "Creating..." : "Create Coupon"}
        </button>
      </div>

      {/* Form Content */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-6 sm:p-8 space-y-8">
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2 col-span-2">
              <label className="text-sm font-bold text-slate-700 flex items-center gap-1">
                Coupon Code <span className="text-rose-500">*</span>
              </label>
              <input
                type="text"
                placeholder="e.g. SUMMER50"
                value={formData.code}
                onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900 placeholder:text-slate-400 placeholder:font-medium uppercase"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Discount Type</label>
              <CustomSelect
                options={discountTypeOptions}
                value={formData.discount_type}
                onChange={(v) => setFormData({ ...formData, discount_type: v })}
                placeholder="Select Type"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 flex items-center gap-1">
                Discount Value {formData.discount_type !== "free_shipping" && <span className="text-rose-500">*</span>}
              </label>
              <div className="relative">
                {formData.discount_type === "fixed_amount" && (
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500 font-semibold">₹</span>
                )}
                <input
                  type="number"
                  placeholder={formData.discount_type === "free_shipping" ? "N/A" : "e.g. 20"}
                  value={formData.discount_type === "free_shipping" ? "" : formData.discount_value}
                  onChange={(e) => setFormData({ ...formData, discount_value: e.target.value })}
                  disabled={formData.discount_type === "free_shipping"}
                  className={`w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900 ${formData.discount_type === "fixed_amount" ? "pl-8" : ""} ${formData.discount_type === "free_shipping" ? "opacity-50 cursor-not-allowed" : ""}`}
                />
                {formData.discount_type === "percentage" && (
                  <span className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 font-semibold">%</span>
                )}
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Minimum Order Value (₹)</label>
              <input
                type="number"
                placeholder="e.g. 1000"
                value={formData.min_order_value}
                onChange={(e) => setFormData({ ...formData, min_order_value: e.target.value })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Max Discount Amount (₹)</label>
              <input
                type="number"
                placeholder="Leave blank for unlimited"
                value={formData.max_discount_amount}
                onChange={(e) => setFormData({ ...formData, max_discount_amount: e.target.value })}
                disabled={formData.discount_type !== "percentage"}
                className={`w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900 ${formData.discount_type !== "percentage" ? "opacity-50 cursor-not-allowed" : ""}`}
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Usage Limit (Per User)</label>
              <input
                type="number"
                placeholder="e.g. 1 (Blank for unlimited)"
                value={formData.usage_limit_per_user}
                onChange={(e) => setFormData({ ...formData, usage_limit_per_user: e.target.value })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Total Usage Limit (Overall)</label>
              <input
                type="number"
                placeholder="e.g. 100 (Blank for unlimited)"
                value={formData.total_usage_limit}
                onChange={(e) => setFormData({ ...formData, total_usage_limit: e.target.value })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Valid From</label>
              <input
                type="datetime-local"
                value={formData.valid_from}
                onChange={(e) => setFormData({ ...formData, valid_from: e.target.value })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700">Valid Until</label>
              <input
                type="datetime-local"
                value={formData.valid_until}
                onChange={(e) => setFormData({ ...formData, valid_until: e.target.value })}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all font-semibold text-slate-900"
              />
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
            <div className="space-y-1">
              <h3 className="text-sm font-bold text-slate-900">Active Status</h3>
              <p className="text-xs text-slate-500 font-medium">Coupon can be used by customers immediately</p>
            </div>
            <button
              onClick={() => setFormData({ ...formData, is_active: !formData.is_active })}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${formData.is_active ? 'bg-emerald-500' : 'bg-slate-300'}`}
            >
              <span className={`inline-block h-5 w-5 transform rounded-full bg-white shadow-sm transition-transform ${formData.is_active ? 'translate-x-5' : 'translate-x-1'}`} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
