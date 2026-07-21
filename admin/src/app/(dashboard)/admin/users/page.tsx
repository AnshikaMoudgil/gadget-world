"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { Profile } from "@/lib/types";

export default function UsersPage() {
  const [users, setUsers] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const supabase = createBrowserSupabaseClient();

  const loadUsers = useCallback(async () => {
    setLoading(true);
    let query = supabase.from("profiles").select("*").order("created_at", { ascending: false });
    if (search) query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%,phone_number.ilike.%${search}%`);
    if (roleFilter) query = query.eq("role", roleFilter);
    const { data } = await query;
    if (data) setUsers(data);
    setLoading(false);
  }, [search, roleFilter]);

  useEffect(() => { loadUsers(); }, [loadUsers]);

  const toggleSuspend = async (user: Profile) => {
    if (user.role === "superadmin") { showToast("error", "Cannot suspend a superadmin"); return; }
    const { error } = await supabase.from("profiles").update({ is_suspended: !user.is_suspended }).eq("id", user.id);
    if (!error) { setUsers((prev) => prev.map((u) => u.id === user.id ? { ...u, is_suspended: !u.is_suspended } : u)); showToast("success", `User ${!user.is_suspended ? "suspended" : "unsuspended"}`); }
    else { showToast("error", error.message); }
  };

  const changeRole = async (user: Profile, newRole: string) => {
    if (user.role === "superadmin") { showToast("error", "Cannot change superadmin role"); return; }
    const { error } = await supabase.from("profiles").update({ role: newRole }).eq("id", user.id);
    if (!error) { setUsers((prev) => prev.map((u) => u.id === user.id ? { ...u, role: newRole as Profile["role"] } : u)); showToast("success", `Role changed to ${newRole}`); }
    else { showToast("error", error.message); }
  };

  const showToast = (type: string, message: string) => { setToast({ type, message }); setTimeout(() => setToast(null), 3000); };

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Users</h1>
      </div>

      <div className="flex gap-2 items-center flex-wrap mb-6">
        <div className="relative">
          <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-tertiary text-sm pointer-events-none">🔍</span>
          <input type="text" className="form-input pl-10 min-w-[280px]" placeholder="Search by name, email or phone..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <select className="form-select" value={roleFilter} onChange={(e) => setRoleFilter(e.target.value)}>
          <option value="">All Roles</option>
          <option value="customer">Customer</option>
          <option value="admin">Admin</option>
          <option value="superadmin">Superadmin</option>
        </select>
      </div>

      <div className="glass-card overflow-hidden">
        {loading ? (
          <div className="p-12 flex items-center justify-center"><div className="spinner spinner-lg" /></div>
        ) : users.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-text-tertiary">
            <div className="text-5xl mb-4 opacity-50">👥</div>
            <h3 className="text-lg text-text-secondary mb-1">No users found</h3>
            <p className="text-sm max-w-[360px]">Adjust your search or filters.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead><tr><th>User</th><th>Phone</th><th>Role</th><th>Status</th><th>Joined</th><th>Actions</th></tr></thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.id}>
                    <td>
                      <div>
                        <div className="font-medium">{user.full_name || "—"}</div>
                        <div className="text-xs text-text-tertiary">{user.email || "—"}</div>
                      </div>
                    </td>
                    <td className="text-sm">{user.phone_number || "—"}</td>
                    <td>
                      <select
                        className="form-select min-w-[120px] py-1.5 pl-2.5 pr-7 text-[0.8125rem]"
                        value={user.role}
                        onChange={(e) => changeRole(user, e.target.value)}
                        disabled={user.role === "superadmin"}
                      >
                        <option value="customer">Customer</option>
                        <option value="admin">Admin</option>
                        <option value="superadmin">Superadmin</option>
                      </select>
                    </td>
                    <td>
                      {user.is_suspended
                        ? <span className="badge badge-danger">Suspended</span>
                        : <span className="badge badge-success">Active</span>}
                    </td>
                    <td className="text-[0.8125rem] text-text-tertiary">{new Date(user.created_at).toLocaleDateString()}</td>
                    <td>
                      <button
                        className={`btn btn-sm ${user.is_suspended ? "btn-secondary" : "btn-danger"}`}
                        onClick={() => toggleSuspend(user)}
                        disabled={user.role === "superadmin"}
                      >
                        {user.is_suspended ? "Unsuspend" : "Suspend"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {toast && <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>{toast.message}</div>}
    </div>
  );
}
