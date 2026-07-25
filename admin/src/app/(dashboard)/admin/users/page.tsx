"use client";

import { useEffect, useState, useCallback, useMemo } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import CustomSelect from "@/components/CustomSelect";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { Profile } from "@/lib/types";

export default function UsersPage() {
  const [users, setUsers] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);

  const supabase = createBrowserSupabaseClient();

  const loadUsers = useCallback(async () => {
    setLoading(true);
    let query = supabase.from("profiles").select("*").order("created_at", { ascending: false });

    if (search) {
      query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%,phone_number.ilike.%${search}%`);
    }
    if (roleFilter) {
      query = query.eq("role", roleFilter);
    }
    if (statusFilter === "active") {
      query = query.eq("is_suspended", false);
    } else if (statusFilter === "suspended") {
      query = query.eq("is_suspended", true);
    }

    const { data, error } = await query;
    if (error) {
      console.error("Error loading users:", error);
      showToast("error", getGenericErrorMessage(error, "Failed to load users"));
      setUsers([]);
    } else {
      setUsers(data as Profile[] ?? []);
    }
    setLoading(false);
  }, [search, roleFilter, statusFilter, supabase]);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  const toggleSuspend = async (user: Profile) => {
    if (user.role === "superadmin") {
      showToast("error", "Superadmin accounts cannot be suspended.");
      return;
    }

    const nextSuspended = !user.is_suspended;
    const { error } = await supabase
      .from("profiles")
      .update({ is_suspended: nextSuspended })
      .eq("id", user.id);

    if (!error) {
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, is_suspended: nextSuspended } : u))
      );
      showToast("success", `User account ${nextSuspended ? "suspended" : "unsuspended"} successfully.`);
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to update user status"));
    }
  };

  const changeRole = async (user: Profile, newRole: string) => {
    if (user.role === "superadmin") {
      showToast("error", "Superadmin roles cannot be modified.");
      return;
    }

    const { error } = await supabase
      .from("profiles")
      .update({ role: newRole })
      .eq("id", user.id);

    if (!error) {
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, role: newRole as Profile["role"] } : u))
      );
      showToast("success", `Role updated to ${newRole}.`);
    } else {
      showToast("error", getGenericErrorMessage(error, "Failed to update user role"));
    }
  };

  const showToast = (type: string, message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 4000);
  };

  // Stat summary calculations
  const stats = useMemo(() => {
    const total = users.length;
    const customers = users.filter((u) => u.role === "customer").length;
    const admins = users.filter((u) => u.role === "admin" || u.role === "superadmin").length;
    const suspended = users.filter((u) => u.is_suspended).length;
    return { total, customers, admins, suspended };
  }, [users]);

  // Helper for generating avatar initials
  const getInitials = (user: Profile) => {
    if (user.full_name && user.full_name.trim()) {
      const parts = user.full_name.trim().split(" ");
      if (parts.length >= 2) return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
      return parts[0].slice(0, 2).toUpperCase();
    }
    if (user.email && user.email.trim()) {
      return user.email.slice(0, 2).toUpperCase();
    }
    return "US";
  };

  return (
    <div className="space-y-6">
      {/* Toast Alert */}
      {toast && (
        <div
          className={`p-4 rounded-xl text-sm font-medium border fixed bottom-6 right-6 z-50 flex items-center justify-between shadow-2xl ${
            toast.type === "error"
              ? "bg-red-900 text-white border-red-700"
              : "bg-emerald-900 text-white border-emerald-700"
          }`}
        >
          <span>{toast.message}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">User Account Management</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage customer accounts, update administrative roles, and monitor account access.
          </p>
        </div>
      </div>

      {/* Quick KPI Stat Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-1">
          <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Accounts</span>
          <div className="text-2xl font-extrabold text-slate-900">{stats.total}</div>
        </div>
        <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-1">
          <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Customers</span>
          <div className="text-2xl font-extrabold text-blue-600">{stats.customers}</div>
        </div>
        <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-1">
          <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Administrators</span>
          <div className="text-2xl font-extrabold text-purple-600">{stats.admins}</div>
        </div>
        <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm space-y-1">
          <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Suspended</span>
          <div className="text-2xl font-extrabold text-rose-600">{stats.suspended}</div>
        </div>
      </div>

      {/* Full-Width Filter Toolbar */}
      <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm flex items-center justify-between gap-4 flex-wrap">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 w-full">
          <div className="relative">
            <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm pointer-events-none">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
              </svg>
            </span>
            <input
              type="text"
              className="w-full pl-10 pr-4 py-2 text-sm rounded-xl bg-slate-50 border border-slate-200 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-slate-800 font-medium"
              placeholder="Search by name, email, or phone..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <CustomSelect
            options={[
              { value: "", label: "All Roles" },
              { value: "customer", label: "Customer" },
              { value: "admin", label: "Admin" },
              { value: "superadmin", label: "Superadmin" },
            ]}
            value={roleFilter}
            onChange={setRoleFilter}
          />
          <CustomSelect
            options={[
              { value: "", label: "All Statuses" },
              { value: "active", label: "Active Accounts" },
              { value: "suspended", label: "Suspended Accounts" },
            ]}
            value={statusFilter}
            onChange={setStatusFilter}
          />
        </div>
      </div>

      {/* Users Table */}
      <div className="rounded-2xl bg-white border border-slate-200 shadow-sm overflow-hidden w-full">
        {loading ? (
          <div className="p-12 text-center text-slate-500 text-sm font-medium">
            Loading user accounts...
          </div>
        ) : users.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-slate-500">
            <h3 className="text-base font-semibold text-slate-900 mb-1">No user accounts found</h3>
            <p className="text-xs max-w-xs text-slate-500">
              {search || roleFilter || statusFilter
                ? "Try adjusting your search filters."
                : "No registered accounts exist in the database yet."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto w-full">
            <table className="w-full min-w-[900px] text-left text-sm">
              <thead className="bg-slate-100/80 text-slate-600 text-xs uppercase tracking-wider border-b border-slate-200 font-semibold">
                <tr>
                  <th className="px-5 py-4">User</th>
                  <th className="px-5 py-4">Phone Number</th>
                  <th className="px-5 py-4">Role</th>
                  <th className="px-5 py-4">Status</th>
                  <th className="px-5 py-4">Joined Date</th>
                  <th className="px-5 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 text-slate-900 bg-white">
                {users.map((user) => (
                  <tr key={user.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-3">
                        {/* Avatar Initials Circle */}
                        <div className="w-10 h-10 rounded-full bg-slate-900 text-white font-bold text-xs flex items-center justify-center shrink-0 shadow-sm">
                          {getInitials(user)}
                        </div>
                        <div>
                          <div className="font-bold text-sm text-slate-900">
                            {user.full_name && user.full_name.trim() ? user.full_name : "Customer Account"}
                          </div>
                          <div className="text-xs text-slate-500 font-medium">
                            {user.email || "No email linked"}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap text-xs text-slate-700 font-medium">
                      {user.phone_number || "—"}
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap min-w-[140px]">
                      <CustomSelect
                        options={[
                          { value: "customer", label: "Customer" },
                          { value: "admin", label: "Admin" },
                          { value: "superadmin", label: "Superadmin" },
                        ]}
                        value={user.role}
                        onChange={(newRole) => changeRole(user, newRole)}
                        disabled={user.role === "superadmin"}
                      />
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      {user.is_suspended ? (
                        <span className="px-2.5 py-1 text-[11px] font-bold rounded-full bg-rose-100 text-rose-800 border border-rose-300">
                          Suspended
                        </span>
                      ) : (
                        <span className="px-2.5 py-1 text-[11px] font-bold rounded-full bg-emerald-100 text-emerald-800 border border-emerald-300">
                          Active
                        </span>
                      )}
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap text-xs text-slate-500 font-medium">
                      {new Date(user.created_at).toLocaleDateString("en-US", {
                        year: "numeric",
                        month: "short",
                        day: "numeric",
                      })}
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap text-right">
                      <button
                        onClick={() => toggleSuspend(user)}
                        disabled={user.role === "superadmin"}
                        className={`px-4 py-1.5 text-xs font-bold rounded-xl border transition-colors shadow-xs ${
                          user.is_suspended
                            ? "bg-emerald-50 text-emerald-700 border-emerald-300 hover:bg-emerald-100"
                            : "bg-rose-50 text-rose-700 border-rose-200 hover:bg-rose-100 disabled:opacity-30 disabled:cursor-not-allowed"
                        }`}
                      >
                        {user.is_suspended ? "Unsuspend Account" : "Suspend Account"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
