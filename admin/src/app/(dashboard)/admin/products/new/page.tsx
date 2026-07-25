"use client";

import { useEffect, useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import MediaUploader from "@/components/MediaUploader";
import CustomSelect from "@/components/CustomSelect";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { Category, Brand } from "@/lib/types";

interface SpecItem {
  id: string;
  spec_key: string;
  spec_value: string;
}

export default function NewProductPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [specs, setSpecs] = useState<SpecItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const [imageList, setImageList] = useState<string[]>([]);
  const router = useRouter();
  const supabase = createBrowserSupabaseClient();

  const [form, setForm] = useState({
    name: "",
    slug: "",
    description: "",
    category_id: "",
    brand_id: "",
    price: "",
    mrp: "",
    stock_quantity: "0",
    is_active: true,
    is_featured: false,
    about_points: "",
  });

  useEffect(() => {
    async function loadFilters() {
      const [catRes, brandRes] = await Promise.all([
        supabase.from("categories").select("*").order("name"),
        supabase.from("brands").select("*").order("name"),
      ]);
      if (catRes.data) setCategories(catRes.data);
      if (brandRes.data) setBrands(brandRes.data);
    }
    loadFilters();
  }, [supabase]);

  const generateSlug = (name: string) =>
    name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    const checked = (e.target as HTMLInputElement).checked;
    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
      ...(name === "name" ? { slug: generateSlug(value) } : {}),
    }));
  };

  const addSpec = () => {
    setSpecs((prev) => [...prev, { id: crypto.randomUUID(), spec_key: "", spec_value: "" }]);
  };

  const updateSpec = (idx: number, field: "spec_key" | "spec_value", val: string) => {
    setSpecs((prev) => {
      const copy = [...prev];
      copy[idx] = { ...copy[idx], [field]: val };
      return copy;
    });
  };

  const removeSpec = (idx: number) => {
    setSpecs((prev) => prev.filter((_, i) => i !== idx));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const aboutPoints = form.about_points.split("\n").map((s) => s.trim()).filter(Boolean);

    const { data: newProd, error } = await supabase
      .from("products")
      .insert({
        name: form.name,
        slug: form.slug,
        description: form.description || null,
        category_id: form.category_id || null,
        brand_id: form.brand_id || null,
        price: parseFloat(form.price),
        mrp: form.mrp ? parseFloat(form.mrp) : null,
        stock_quantity: parseInt(form.stock_quantity),
        is_active: form.is_active,
        is_featured: form.is_featured,
        about_points: aboutPoints,
        images: imageList,
      })
      .select()
      .single();

    if (error || !newProd) {
      setLoading(false);
      setToast({ type: "error", message: getGenericErrorMessage(error, "Failed to create product") });
      setTimeout(() => setToast(null), 4000);
      return;
    }

    // Insert specs if any
    const validSpecs = specs.filter((s) => s.spec_key.trim() && s.spec_value.trim());
    if (validSpecs.length > 0) {
      await supabase.from("product_specs").insert(
        validSpecs.map((s, i) => ({
          product_id: newProd.id,
          spec_key: s.spec_key.trim(),
          spec_value: s.spec_value.trim(),
          display_order: i,
        }))
      );
    }

    setLoading(false);
    router.push("/admin/products");
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Add New Product</h1>
          <p className="text-sm text-slate-500 mt-1">Fill in product details, pricing, images, and technical specifications.</p>
        </div>
        <button className="px-4 py-2 text-xs font-semibold rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300 transition-colors" onClick={() => router.back()}>
          ← Back
        </button>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-6">
        {/* Basic Info */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-3">Basic Information</h2>
          <div className="grid grid-cols-2 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Product Name *</label>
              <input name="name" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" placeholder="e.g. Sony WH-1000XM5" value={form.name} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Slug</label>
              <input name="slug" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" value={form.slug} onChange={handleChange} required />
            </div>
          </div>
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-bold text-slate-700">Description</label>
            <textarea name="description" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" placeholder="Product description..." value={form.description} onChange={handleChange} rows={4} />
          </div>
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-bold text-slate-700">About Points (one bullet per line)</label>
            <textarea name="about_points" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" placeholder={"Industry-leading noise cancellation\n30-hour battery life"} value={form.about_points} onChange={handleChange} rows={4} />
          </div>
        </div>

        {/* Classification */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-3">Classification</h2>
          <div className="grid grid-cols-2 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Category</label>
              <CustomSelect
                options={[
                  { value: "", label: "Select category" },
                  ...categories.map((c) => ({ value: c.id, label: c.name })),
                ]}
                value={form.category_id}
                onChange={(val) => setForm((prev) => ({ ...prev, category_id: val }))}
                placeholder="Select category"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Brand</label>
              <CustomSelect
                options={[
                  { value: "", label: "Select brand" },
                  ...brands.map((b) => ({ value: b.id, label: b.name })),
                ]}
                value={form.brand_id}
                onChange={(val) => setForm((prev) => ({ ...prev, brand_id: val }))}
                placeholder="Select brand"
              />
            </div>
          </div>
        </div>

        {/* Pricing & Stock */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-3">Pricing & Stock</h2>
          <div className="grid grid-cols-3 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Price (₹) *</label>
              <input name="price" type="number" step="0.01" min="0" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" placeholder="0.00" value={form.price} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">MRP (₹)</label>
              <input name="mrp" type="number" step="0.01" min="0" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" placeholder="0.00" value={form.mrp} onChange={handleChange} />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-slate-700">Stock Quantity</label>
              <input name="stock_quantity" type="number" min="0" className="px-3.5 py-2.5 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-900 focus:outline-none focus:border-slate-800 font-medium" value={form.stock_quantity} onChange={handleChange} />
            </div>
          </div>
        </div>

        {/* Product Images */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm">
          <MediaUploader
            bucket="products"
            images={imageList}
            onChange={setImageList}
            multiple={true}
            label="Product Images (Uploaded to Supabase Bucket)"
          />
        </div>

        {/* Technical Specifications Section */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h2 className="text-base font-bold text-slate-900">Technical Specifications</h2>
              <p className="text-xs text-slate-500 mt-0.5">Add key specifications like Battery, Camera, Warranty, Storage, etc.</p>
            </div>
            <button
              type="button"
              onClick={addSpec}
              className="px-3 py-1.5 text-xs font-semibold rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300 transition-colors"
            >
              + Add Spec
            </button>
          </div>

          {specs.length === 0 ? (
            <p className="text-xs text-slate-400 italic">No specifications added yet. Click "+ Add Spec" above to add key-value specifications.</p>
          ) : (
            <div className="space-y-3">
              {specs.map((spec, idx) => (
                <div key={spec.id} className="flex items-center gap-3">
                  <input
                    className="flex-1 px-3.5 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-slate-800 font-medium"
                    placeholder="Key (e.g. Battery Backup)"
                    value={spec.spec_key}
                    onChange={(e) => updateSpec(idx, "spec_key", e.target.value)}
                  />
                  <input
                    className="flex-1 px-3.5 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-slate-800 font-medium"
                    placeholder="Value (e.g. Up to 10 Hours)"
                    value={spec.spec_value}
                    onChange={(e) => updateSpec(idx, "spec_value", e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => removeSpec(idx)}
                    className="px-3 py-2 text-xs font-bold rounded-xl bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200 transition-colors"
                  >
                    ✕
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Visibility */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-3">Visibility</h2>
          <div className="flex flex-col gap-2">
            <label className="flex items-center gap-2 text-sm text-slate-700 cursor-pointer font-medium">
              <input type="checkbox" name="is_active" checked={form.is_active} onChange={handleChange} className="w-4 h-4 rounded accent-slate-900" />
              <span>Active — visible to customers in store</span>
            </label>
            <label className="flex items-center gap-2 text-sm text-slate-700 cursor-pointer font-medium">
              <input type="checkbox" name="is_featured" checked={form.is_featured} onChange={handleChange} className="w-4 h-4 rounded accent-slate-900" />
              <span>Featured — promoted on homepage hero section</span>
            </label>
          </div>
        </div>

        {/* Form Action Buttons */}
        <div className="flex items-center justify-end gap-3 pt-2">
          <button type="button" className="px-5 py-2.5 text-xs font-semibold rounded-xl bg-slate-100 text-slate-700 hover:bg-slate-200 transition-colors" onClick={() => router.back()}>
            Cancel
          </button>
          <button type="submit" className="px-6 py-2.5 text-xs font-bold rounded-xl bg-slate-900 text-white hover:bg-slate-800 disabled:opacity-50 transition-colors shadow-md" disabled={loading}>
            {loading ? "Creating Product..." : "Create Product"}
          </button>
        </div>
      </form>

      {toast && (
        <div className={`p-4 rounded-xl text-sm font-medium border fixed bottom-6 right-6 z-50 shadow-2xl ${
          toast.type === "error" ? "bg-red-900 text-white border-red-700" : "bg-emerald-900 text-white border-emerald-700"
        }`}>
          {toast.message}
        </div>
      )}
    </div>
  );
}
