"use client";

import MediaUploader from "@/components/MediaUploader";
import ConfirmModal from "@/components/ConfirmModal";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { Category } from "@/lib/types";

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState({ name: "", slug: "", image_url: "", is_active: true });
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Category | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const supabase = createBrowserSupabaseClient();

  const loadCategories = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase.from("categories").select("*").order("name");
    if (!error) {
      setCategories(data ?? []);
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to load categories"));
    }
    setLoading(false);
  }, []);

  useEffect(() => { loadCategories(); }, [loadCategories]);

  const generateSlug = (name: string) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

  const openCreate = () => { setEditingId(null); setForm({ name: "", slug: "", image_url: "", is_active: true }); setShowModal(true); };
  const openEdit = (cat: Category) => { setEditingId(cat.id); setForm({ name: cat.name, slug: cat.slug, image_url: cat.image_url || "", is_active: cat.is_active }); setShowModal(true); };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const payload = { name: form.name, slug: form.slug, image_url: form.image_url || null, is_active: form.is_active };
    let error;
    if (editingId) { ({ error } = await supabase.from("categories").update(payload).eq("id", editingId)); }
    else { ({ error } = await supabase.from("categories").insert(payload)); }
    setSaving(false);
    if (error) {
      showToast("error", getGenericErrorMessage(error, "Failed to save category"));
    } else {
      setShowModal(false);
      loadCategories();
      showToast("success", editingId ? "Category updated" : "Category created");
    }
  };

  const handleDeleteCategory = async () => {
    if (!deleteTarget) return;
    setIsDeleting(true);
    const { error } = await supabase.from("categories").delete().eq("id", deleteTarget.id);
    if (!error) {
      setCategories((prev) => prev.filter((c) => c.id !== deleteTarget.id));
      showToast("success", "Category deleted successfully");
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to delete category"));
    }
    setIsDeleting(false);
    setDeleteTarget(null);
  };

  const toggleActive = async (cat: Category) => {
    const { error } = await supabase.from("categories").update({ is_active: !cat.is_active }).eq("id", cat.id);
    if (!error) {
      setCategories((prev) => prev.map((c) => c.id === cat.id ? { ...c, is_active: !c.is_active } : c));
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to update category status"));
    }
  };

  const showToast = (type: string, message: string) => { setToast({ type, message }); setTimeout(() => setToast(null), 3500); };

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Categories</h1>
        <button className="btn btn-primary" onClick={openCreate}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></svg>
          Add Category
        </button>
      </div>

      <div className="glass-card overflow-hidden">
        {loading ? (
          <div className="p-12 flex items-center justify-center"><div className="spinner spinner-lg" /></div>
        ) : categories.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-text-tertiary">
            <div className="text-5xl mb-4 opacity-50">📂</div>
            <h3 className="text-lg text-text-secondary mb-1">No categories yet</h3>
            <p className="text-sm max-w-[360px]">Create your first product category to get started.</p>
          </div>
        ) : (
          <table className="data-table">
            <thead><tr><th>Name</th><th>Slug</th><th>Status</th><th>Created</th><th>Actions</th></tr></thead>
            <tbody>
              {categories.map((cat) => (
                <tr key={cat.id}>
                  <td>
                    <div className="flex items-center gap-2">
                      {cat.image_url && <img src={cat.image_url} alt={cat.name} className="w-8 h-8 rounded object-cover" />}
                      <strong>{cat.name}</strong>
                    </div>
                  </td>
                  <td><code className="text-[0.8125rem] text-text-tertiary">{cat.slug}</code></td>
                  <td>
                    <button
                      onClick={() => toggleActive(cat)}
                      className={`px-3 py-1 text-xs font-bold rounded-full border transition-all ${
                        cat.is_active
                          ? "bg-emerald-100 text-emerald-800 border-emerald-300 hover:bg-emerald-200"
                          : "bg-slate-100 text-slate-600 border-slate-300 hover:bg-slate-200"
                      }`}
                    >
                      {cat.is_active ? "Active" : "Inactive"}
                    </button>
                  </td>
                  <td className="text-[0.8125rem] text-text-tertiary">{new Date(cat.created_at).toLocaleDateString()}</td>
                  <td>
                    <div className="flex gap-2">
                      <button
                        onClick={() => openEdit(cat)}
                        className="px-3 py-1.5 text-xs font-semibold rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300 transition-colors"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => setDeleteTarget(cat)}
                        className="px-3 py-1.5 text-xs font-semibold rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 transition-colors"
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2 className="text-lg font-semibold mb-4">{editingId ? "Edit Category" : "New Category"}</h2>
            <form onSubmit={handleSubmit}>
              <div className="flex flex-col gap-1.5 mb-4">
                <label className="form-label">Name *</label>
                <input className="form-input" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value, slug: editingId ? form.slug : generateSlug(e.target.value) })} required autoFocus />
              </div>
              <div className="flex flex-col gap-1.5 mb-4">
                <label className="form-label">Slug</label>
                <input className="form-input" value={form.slug} onChange={(e) => setForm({ ...form, slug: e.target.value })} required />
              </div>
              <div className="mb-4">
                <MediaUploader
                  bucket="categories"
                  images={form.image_url ? [form.image_url] : []}
                  onChange={(imgs) => setForm({ ...form, image_url: imgs[0] || "" })}
                  multiple={false}
                  label="Category Image (Uploaded to Supabase Bucket)"
                />
              </div>
              <label className="flex items-center gap-2 text-sm text-text-secondary cursor-pointer">
                <input type="checkbox" checked={form.is_active} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} className="w-[18px] h-[18px] accent-accent" />
                Active
              </label>
              <div className="flex gap-2 justify-end mt-6">
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" disabled={saving}>
                  {saving ? <><span className="spinner" /> Saving...</> : editingId ? "Save Changes" : "Create"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Confirmation Modal */}
      <ConfirmModal
        isOpen={!!deleteTarget}
        title="Delete Category"
        message={`Are you sure you want to delete "${deleteTarget?.name}"? Products assigned to this category may be affected.`}
        confirmLabel="Delete Category"
        variant="danger"
        isLoading={isDeleting}
        onConfirm={handleDeleteCategory}
        onCancel={() => setDeleteTarget(null)}
      />

      {toast && <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>{toast.message}</div>}
    </div>
  );
}
