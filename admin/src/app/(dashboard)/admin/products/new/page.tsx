"use client";

import { useEffect, useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import type { Category, Brand } from "@/lib/types";

export default function NewProductPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const router = useRouter();
  const supabase = createBrowserSupabaseClient();

  const [form, setForm] = useState({
    name: "", slug: "", description: "", category_id: "", brand_id: "",
    price: "", mrp: "", stock_quantity: "0", is_active: true, is_featured: false,
    about_points: "", images: "",
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
  }, []);

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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const aboutPoints = form.about_points.split("\n").map((s) => s.trim()).filter(Boolean);
    const images = form.images.split("\n").map((s) => s.trim()).filter(Boolean);

    const { error } = await supabase.from("products").insert({
      name: form.name, slug: form.slug, description: form.description || null,
      category_id: form.category_id || null, brand_id: form.brand_id || null,
      price: parseFloat(form.price), mrp: form.mrp ? parseFloat(form.mrp) : null,
      stock_quantity: parseInt(form.stock_quantity), is_active: form.is_active,
      is_featured: form.is_featured, about_points: aboutPoints, images,
    });

    setLoading(false);
    if (error) {
      setToast({ type: "error", message: error.message });
      setTimeout(() => setToast(null), 4000);
    } else {
      router.push("/admin/products");
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Add New Product</h1>
        <button className="btn btn-secondary" onClick={() => router.back()}>← Back</button>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        {/* Basic Info */}
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Basic Information</h2>
          <div className="grid grid-cols-2 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Product Name *</label>
              <input name="name" className="form-input" placeholder="e.g. Sony WH-1000XM5" value={form.name} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Slug</label>
              <input name="slug" className="form-input" value={form.slug} onChange={handleChange} required />
            </div>
          </div>
          <div className="flex flex-col gap-1.5 mt-4">
            <label className="form-label">Description</label>
            <textarea name="description" className="form-textarea" placeholder="Product description..." value={form.description} onChange={handleChange} rows={4} />
          </div>
          <div className="flex flex-col gap-1.5 mt-4">
            <label className="form-label">About Points (one per line)</label>
            <textarea name="about_points" className="form-textarea" placeholder={"Industry-leading noise cancellation\n30-hour battery life"} value={form.about_points} onChange={handleChange} rows={4} />
          </div>
        </div>

        {/* Classification */}
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Classification</h2>
          <div className="grid grid-cols-2 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Category</label>
              <select name="category_id" className="form-select" value={form.category_id} onChange={handleChange}>
                <option value="">Select category</option>
                {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Brand</label>
              <select name="brand_id" className="form-select" value={form.brand_id} onChange={handleChange}>
                <option value="">Select brand</option>
                {brands.map((b) => <option key={b.id} value={b.id}>{b.name}</option>)}
              </select>
            </div>
          </div>
        </div>

        {/* Pricing */}
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Pricing & Stock</h2>
          <div className="grid grid-cols-3 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Price (₹) *</label>
              <input name="price" type="number" step="0.01" min="0" className="form-input" placeholder="0.00" value={form.price} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">MRP (₹)</label>
              <input name="mrp" type="number" step="0.01" min="0" className="form-input" placeholder="0.00" value={form.mrp} onChange={handleChange} />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Stock Quantity</label>
              <input name="stock_quantity" type="number" min="0" className="form-input" value={form.stock_quantity} onChange={handleChange} />
            </div>
          </div>
        </div>

        {/* Images */}
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Images</h2>
          <div className="flex flex-col gap-1.5">
            <label className="form-label">Image URLs (one per line)</label>
            <textarea name="images" className="form-textarea" placeholder={"https://example.com/image1.jpg\nhttps://example.com/image2.jpg"} value={form.images} onChange={handleChange} rows={3} />
          </div>
        </div>

        {/* Visibility */}
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Visibility</h2>
          <div className="flex flex-col gap-2">
            <label className="flex items-center gap-2 text-sm text-text-secondary cursor-pointer">
              <input type="checkbox" name="is_active" checked={form.is_active} onChange={handleChange} className="w-[18px] h-[18px] accent-accent" />
              <span>Active — visible to customers</span>
            </label>
            <label className="flex items-center gap-2 text-sm text-text-secondary cursor-pointer">
              <input type="checkbox" name="is_featured" checked={form.is_featured} onChange={handleChange} className="w-[18px] h-[18px] accent-accent" />
              <span>Featured — promoted on home page</span>
            </label>
          </div>
        </div>

        <div className="flex gap-2 justify-end">
          <button type="button" className="btn btn-secondary" onClick={() => router.back()}>Cancel</button>
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? <><span className="spinner" /> Creating...</> : "Create Product"}
          </button>
        </div>
      </form>

      {toast && <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>{toast.message}</div>}
    </div>
  );
}
