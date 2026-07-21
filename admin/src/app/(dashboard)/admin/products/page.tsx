"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { Product, Category, Brand } from "@/lib/types";
import Link from "next/link";

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [brandFilter, setBrandFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [page, setPage] = useState(0);
  const [total, setTotal] = useState(0);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const pageSize = 15;
  const supabase = createBrowserSupabaseClient();

  const loadProducts = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("products")
      .select("*, brand:brands(*), category:categories(*)", { count: "exact" })
      .order("created_at", { ascending: false })
      .range(page * pageSize, (page + 1) * pageSize - 1);

    if (search) query = query.ilike("name", `%${search}%`);
    if (categoryFilter) query = query.eq("category_id", categoryFilter);
    if (brandFilter) query = query.eq("brand_id", brandFilter);
    if (statusFilter === "active") query = query.eq("is_active", true);
    if (statusFilter === "inactive") query = query.eq("is_active", false);
    if (statusFilter === "featured") query = query.eq("is_featured", true);

    const { data, count, error } = await query;
    if (!error) {
      setProducts(data ?? []);
      setTotal(count ?? 0);
    }
    setLoading(false);
  }, [page, search, categoryFilter, brandFilter, statusFilter]);

  useEffect(() => { loadProducts(); }, [loadProducts]);

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

  const toggleActive = async (product: Product) => {
    const { error } = await supabase.from("products").update({ is_active: !product.is_active }).eq("id", product.id);
    if (!error) {
      setProducts((prev) => prev.map((p) => p.id === product.id ? { ...p, is_active: !p.is_active } : p));
      showToast("success", `Product ${!product.is_active ? "activated" : "deactivated"}`);
    }
  };

  const toggleFeatured = async (product: Product) => {
    const { error } = await supabase.from("products").update({ is_featured: !product.is_featured }).eq("id", product.id);
    if (!error) {
      setProducts((prev) => prev.map((p) => p.id === product.id ? { ...p, is_featured: !p.is_featured } : p));
      showToast("success", `Product ${!product.is_featured ? "featured" : "unfeatured"}`);
    }
  };

  const deleteProduct = async (id: string) => {
    if (!confirm("Are you sure you want to delete this product?")) return;
    const { error } = await supabase.from("products").delete().eq("id", id);
    if (!error) {
      setProducts((prev) => prev.filter((p) => p.id !== id));
      setTotal((t) => t - 1);
      showToast("success", "Product deleted");
    } else {
      showToast("error", "Failed to delete product");
    }
  };

  const showToast = (type: string, message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 3000);
  };

  const totalPages = Math.ceil(total / pageSize);

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Products</h1>
        <Link href="/admin/products/new" className="btn btn-primary">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
          Add Product
        </Link>
      </div>

      {/* Filters */}
      <div className="flex gap-2 items-center flex-wrap mb-6">
        <div className="relative">
          <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-tertiary text-sm pointer-events-none">🔍</span>
          <input
            type="text"
            className="form-input pl-10 min-w-[280px]"
            placeholder="Search products..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
          />
        </div>
        <select className="form-select" value={categoryFilter} onChange={(e) => { setCategoryFilter(e.target.value); setPage(0); }}>
          <option value="">All Categories</option>
          {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
        <select className="form-select" value={brandFilter} onChange={(e) => { setBrandFilter(e.target.value); setPage(0); }}>
          <option value="">All Brands</option>
          {brands.map((b) => <option key={b.id} value={b.id}>{b.name}</option>)}
        </select>
        <select className="form-select" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }}>
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="featured">Featured</option>
        </select>
      </div>

      <p className="text-[0.8125rem] text-text-tertiary mb-4">
        {total.toLocaleString()} product{total !== 1 ? "s" : ""} found
      </p>

      {/* Table */}
      <div className="glass-card overflow-hidden">
        {loading ? (
          <div className="p-12 flex items-center justify-center">
            <div className="spinner spinner-lg" />
          </div>
        ) : products.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-text-tertiary">
            <div className="text-5xl mb-4 opacity-50">📦</div>
            <h3 className="text-lg text-text-secondary mb-1">No products found</h3>
            <p className="text-sm max-w-[360px]">Try adjusting your filters or add a new product.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Category</th>
                  <th>Brand</th>
                  <th>Price</th>
                  <th>Stock</th>
                  <th>Status</th>
                  <th>Featured</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {products.map((product) => (
                  <tr key={product.id}>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="w-11 h-11 rounded-lg bg-bg-tertiary flex items-center justify-center overflow-hidden shrink-0">
                          {product.images?.[0] ? (
                            <img src={product.images[0]} alt={product.name} className="w-full h-full object-cover" />
                          ) : (
                            <span>📦</span>
                          )}
                        </div>
                        <div>
                          <div className="font-medium text-sm max-w-[250px] overflow-hidden text-ellipsis whitespace-nowrap">{product.name}</div>
                          <div className="text-xs text-text-tertiary">{product.slug}</div>
                        </div>
                      </div>
                    </td>
                    <td><span className="badge badge-neutral">{product.category?.name ?? "—"}</span></td>
                    <td>{product.brand?.name ?? "—"}</td>
                    <td>
                      <div>
                        <strong>₹{product.price.toLocaleString()}</strong>
                        {product.mrp && product.mrp > product.price && (
                          <div className="text-xs text-text-tertiary line-through">₹{product.mrp.toLocaleString()}</div>
                        )}
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${product.stock_quantity > 0 ? "badge-success" : "badge-danger"}`}>
                        {product.stock_quantity}
                      </span>
                    </td>
                    <td>
                      <label className="toggle" onClick={() => toggleActive(product)}>
                        <input type="checkbox" checked={product.is_active} readOnly />
                        <span className="slider" />
                      </label>
                    </td>
                    <td>
                      <label className="toggle" onClick={() => toggleFeatured(product)}>
                        <input type="checkbox" checked={product.is_featured} readOnly />
                        <span className="slider" />
                      </label>
                    </td>
                    <td>
                      <div className="flex gap-1">
                        <Link href={`/admin/products/${product.id}`} className="btn btn-ghost btn-sm" title="Edit">✏️</Link>
                        <button className="btn btn-ghost btn-sm" onClick={() => deleteProduct(product.id)} title="Delete">🗑️</button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-1 mt-6">
          <button className="w-9 h-9 flex items-center justify-center rounded-lg text-sm font-medium text-text-secondary hover:bg-glass-hover hover:text-text-primary transition-all disabled:opacity-30 disabled:cursor-not-allowed" disabled={page === 0} onClick={() => setPage(page - 1)}>‹</button>
          {Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
            const pageNum = totalPages <= 7 ? i : Math.max(0, Math.min(page - 3, totalPages - 7)) + i;
            return (
              <button
                key={pageNum}
                className={`w-9 h-9 flex items-center justify-center rounded-lg text-sm font-medium transition-all ${
                  page === pageNum
                    ? "bg-gradient-to-br from-accent to-accent-light text-black"
                    : "text-text-secondary hover:bg-glass-hover hover:text-text-primary"
                }`}
                onClick={() => setPage(pageNum)}
              >
                {pageNum + 1}
              </button>
            );
          })}
          <button className="w-9 h-9 flex items-center justify-center rounded-lg text-sm font-medium text-text-secondary hover:bg-glass-hover hover:text-text-primary transition-all disabled:opacity-30 disabled:cursor-not-allowed" disabled={page >= totalPages - 1} onClick={() => setPage(page + 1)}>›</button>
        </div>
      )}

      {toast && <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>{toast.message}</div>}
    </div>
  );
}
