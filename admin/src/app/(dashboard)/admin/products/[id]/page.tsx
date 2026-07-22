"use client";

import { useEffect, useState } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import { useRouter, useParams } from "next/navigation";
import type { Category, Brand, ProductSpec, ProductFeature } from "@/lib/types";

export default function EditProductPage() {
  const { id } = useParams<{ id: string }>();
  const [categories, setCategories] = useState<Category[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [specs, setSpecs] = useState<ProductSpec[]>([]);
  const [features, setFeatures] = useState<ProductFeature[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const router = useRouter();
  const supabase = createBrowserSupabaseClient();

  const [form, setForm] = useState({
    name: "", slug: "", description: "", category_id: "", brand_id: "",
    price: "", mrp: "", stock_quantity: "0", is_active: true, is_featured: false,
    about_points: "", images: "",
  });

  useEffect(() => {
    async function load() {
      const [productRes, catRes, brandRes, specsRes, featuresRes] = await Promise.all([
        supabase.from("products").select("*").eq("id", id).single(),
        supabase.from("categories").select("*").order("name"),
        supabase.from("brands").select("*").order("name"),
        supabase.from("product_specs").select("*").eq("product_id", id).order("display_order"),
        supabase.from("product_features").select("*").eq("product_id", id).order("display_order"),
      ]);

      if (catRes.data) setCategories(catRes.data);
      if (brandRes.data) setBrands(brandRes.data);
      if (specsRes.data) setSpecs(specsRes.data);
      if (featuresRes.data) setFeatures(featuresRes.data);

      if (productRes.data) {
        const p = productRes.data;
        setForm({
          name: p.name, slug: p.slug, description: p.description || "",
          category_id: p.category_id || "", brand_id: p.brand_id || "",
          price: String(p.price), mrp: p.mrp ? String(p.mrp) : "",
          stock_quantity: String(p.stock_quantity), is_active: p.is_active,
          is_featured: p.is_featured, about_points: (p.about_points ?? []).join("\n"),
          images: (p.images ?? []).join("\n"),
        });
      }
      setLoading(false);
    }
    load();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    const checked = (e.target as HTMLInputElement).checked;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const aboutPoints = form.about_points.split("\n").map((s) => s.trim()).filter(Boolean);
    const images = form.images.split("\n").map((s) => s.trim()).filter(Boolean);

    const { error } = await supabase.from("products").update({
      name: form.name, slug: form.slug, description: form.description || null,
      category_id: form.category_id || null, brand_id: form.brand_id || null,
      price: parseFloat(form.price), mrp: form.mrp ? parseFloat(form.mrp) : null,
      stock_quantity: parseInt(form.stock_quantity), is_active: form.is_active,
      is_featured: form.is_featured, about_points: aboutPoints, images,
    }).eq("id", id);

    setSaving(false);
    showToast(error ? "error" : "success", error ? error.message : "Product updated successfully");
  };

  const showToast = (type: string, message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 3000);
  };

  const addSpec = () => setSpecs([...specs, { id: crypto.randomUUID(), product_id: id, spec_key: "", spec_value: "", display_order: specs.length }]);
  const updateSpec = (idx: number, key: string, value: string) => {
    const updated = [...specs]; updated[idx] = { ...updated[idx], [key]: value }; setSpecs(updated);
  };
  const removeSpec = (idx: number) => setSpecs(specs.filter((_, i) => i !== idx));

  const saveSpecs = async () => {
    await supabase.from("product_specs").delete().eq("product_id", id);
    if (specs.length > 0) {
      const { error } = await supabase.from("product_specs").insert(
        specs.map((s, i) => ({ product_id: id, spec_key: s.spec_key, spec_value: s.spec_value, display_order: i }))
      );
      showToast(error ? "error" : "success", error ? error.message : "Specs saved");
    } else {
      showToast("success", "Specs cleared");
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12">
        <div className="spinner spinner-lg" />
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Edit Product</h1>
        <button className="btn btn-secondary" onClick={() => router.back()}>← Back</button>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Basic Information</h2>
          <div className="grid grid-cols-2 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Product Name *</label>
              <input name="name" className="form-input" value={form.name} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Slug</label>
              <input name="slug" className="form-input" value={form.slug} onChange={handleChange} required />
            </div>
          </div>
          <div className="flex flex-col gap-1.5 mt-4">
            <label className="form-label">Description</label>
            <textarea name="description" className="form-textarea" value={form.description} onChange={handleChange} rows={4} />
          </div>
          <div className="flex flex-col gap-1.5 mt-4">
            <label className="form-label">About Points (one per line)</label>
            <textarea name="about_points" className="form-textarea" value={form.about_points} onChange={handleChange} rows={4} />
          </div>
        </div>

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

        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Pricing & Stock</h2>
          <div className="grid grid-cols-3 gap-4 max-md:grid-cols-1">
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Price (₹) *</label>
              <input name="price" type="number" step="0.01" min="0" className="form-input" value={form.price} onChange={handleChange} required />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">MRP (₹)</label>
              <input name="mrp" type="number" step="0.01" min="0" className="form-input" value={form.mrp} onChange={handleChange} />
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="form-label">Stock Quantity</label>
              <input name="stock_quantity" type="number" min="0" className="form-input" value={form.stock_quantity} onChange={handleChange} />
            </div>
          </div>
        </div>

        <div className="glass-card p-8">
          <h2 className="text-base font-semibold mb-4">Images</h2>
          <div className="flex flex-col gap-1.5">
            <label className="form-label">Image URLs (one per line)</label>
            <textarea name="images" className="form-textarea" value={form.images} onChange={handleChange} rows={3} />
          </div>
        </div>

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
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? <><span className="spinner" /> Saving...</> : "Save Changes"}
          </button>
        </div>
      </form>

      {/* Specs */}
      <div className="glass-card p-8 mt-4">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base font-semibold">Specifications</h2>
          <div className="flex gap-2">
            <button type="button" className="btn btn-secondary btn-sm" onClick={addSpec}>+ Add Spec</button>
            <button type="button" className="btn btn-primary btn-sm" onClick={saveSpecs}>Save Specs</button>
          </div>
        </div>
        {specs.length === 0 ? (
          <p className="text-text-tertiary text-sm">No specifications added yet.</p>
        ) : (
          <div className="flex flex-col gap-2">
            {specs.map((spec, idx) => (
              <div key={spec.id} className="flex gap-2 items-center">
                <input className="form-input flex-1" placeholder="Key (e.g. Battery)" value={spec.spec_key} onChange={(e) => updateSpec(idx, "spec_key", e.target.value)} />
                <input className="form-input flex-1" placeholder="Value (e.g. 5000mAh)" value={spec.spec_value} onChange={(e) => updateSpec(idx, "spec_value", e.target.value)} />
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removeSpec(idx)}>✕</button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Features */}
      {features.length > 0 && (
        <div className="glass-card p-8 mt-4">
          <h2 className="text-base font-semibold mb-4">Features</h2>
          <div className="flex flex-col gap-2">
            {features.map((f) => (
              <div key={f.id} className="flex gap-2 items-center p-2 bg-bg-tertiary rounded-lg">
                <span className="badge badge-info">{f.type}</span>
                <strong className="text-sm">{f.title}</strong>
                <span className="text-[0.8125rem] text-text-secondary">{f.description}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {toast && <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>{toast.message}</div>}
    </div>
  );
}
