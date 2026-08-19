"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import CustomSelect from "@/components/CustomSelect";
import ConfirmModal from "@/components/ConfirmModal";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { AppNotification, Profile } from "@/lib/types";

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [users, setUsers] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [typeFilter, setTypeFilter] = useState("all");
  const [page, setPage] = useState(0);
  const [total, setTotal] = useState(0);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);

  // Delete Target & Modal State
  const [deleteTarget, setDeleteTarget] = useState<AppNotification | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // Broadcast Modal State
  const [showBroadcastModal, setShowBroadcastModal] = useState(false);
  const [targetUser, setTargetUser] = useState<"all" | "single">("all");
  const [selectedUserId, setSelectedUserId] = useState("");
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [notificationType, setNotificationType] = useState<AppNotification["type"]>("system");
  const [referenceType, setReferenceType] = useState("");
  const [referenceId, setReferenceId] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [sending, setSending] = useState(false);

  const pageSize = 15;
  const supabase = createBrowserSupabaseClient();

  const loadNotifications = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("notifications")
      .select("*, profile:profiles!notifications_user_id_fkey(email, full_name)", { count: "exact" })
      .order("created_at", { ascending: false })
      .range(page * pageSize, (page + 1) * pageSize - 1);

    if (typeFilter !== "all") query = query.eq("type", typeFilter);

    const { data, count, error } = await query;
    if (error) {
      setToast({ type: "error", message: `Failed to load notifications: ${error.message}` });
    } else {
      const formatted = ((data as (AppNotification & { profile?: { email?: string; full_name?: string } })[]) ?? []).map((n) => ({
        ...n,
        user_email: n.profile?.email || n.profile?.full_name || n.user_id.slice(0, 8),
      }));
      setNotifications(formatted);
      setTotal(count ?? 0);
    }
    setLoading(false);
  }, [page, typeFilter, supabase]);

  useEffect(() => {
    loadNotifications();
  }, [loadNotifications]);

  useEffect(() => {
    async function loadUsers() {
      const { data } = await supabase.from("profiles").select("id, email, full_name").order("full_name");
      if (data) setUsers(data as Profile[]);
    }
    loadUsers();
  }, [supabase]);

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) {
      setToast({ type: "error", message: "Title and body are required" });
      return;
    }

    setSending(true);

    let targetUserIds: string[] = [];

    if (targetUser === "single") {
      if (!selectedUserId) {
        setToast({ type: "error", message: "Please select a target user" });
        setSending(false);
        return;
      }
      targetUserIds = [selectedUserId];
    } else {
      // Broadcast to all active profiles
      const { data: allProfiles, error: profilesErr } = await supabase.from("profiles").select("id");
      if (profilesErr || !allProfiles) {
        setToast({ type: "error", message: "Failed to fetch user list for broadcast" });
        setSending(false);
        return;
      }
      targetUserIds = allProfiles.map((p) => p.id);
    }

    const payload = targetUserIds.map((uid) => ({
      user_id: uid,
      title: title.trim(),
      body: body.trim(),
      type: notificationType,
      reference_type: referenceType.trim() || null,
      reference_id: referenceId.trim() || null,
      image_url: imageUrl.trim() || null,
      is_read: false,
    }));

    // Insert in batches of 100
    const batchSize = 100;
    let successCount = 0;
    for (let i = 0; i < payload.length; i += batchSize) {
      const batch = payload.slice(i, i + batchSize);
      const { error } = await supabase.from("notifications").insert(batch);
      if (!error) successCount += batch.length;
    }

    setToast({
      type: "success",
      message: `Notification broadcasted to ${successCount} user(s) successfully!`,
    });

    setShowBroadcastModal(false);
    setTitle("");
    setBody("");
    setReferenceType("");
    setReferenceId("");
    setImageUrl("");
    setSending(false);
    loadNotifications();
  };

  const handleDeleteNotification = async () => {
    if (!deleteTarget) return;
    setIsDeleting(true);
    const { error } = await supabase.from("notifications").delete().eq("id", deleteTarget.id);
    if (error) {
      setToast({ type: "error", message: getGenericErrorMessage(error, "Failed to delete notification") });
    } else {
      setToast({ type: "success", message: "Notification deleted successfully" });
      loadNotifications();
    }
    setIsDeleting(false);
    setDeleteTarget(null);
  };

  const getTypeBadge = (type: string) => {
    switch (type) {
      case "order_update":
        return "bg-blue-500/10 text-blue-400 border-blue-500/20";
      case "payment":
        return "bg-emerald-500/10 text-emerald-400 border-emerald-500/20";
      case "promotion":
        return "bg-purple-500/10 text-purple-400 border-purple-500/20";
      case "support":
        return "bg-amber-500/10 text-amber-400 border-amber-500/20";
      case "delivery":
        return "bg-sky-500/10 text-sky-400 border-sky-500/20";
      default:
        return "bg-zinc-500/10 text-zinc-400 border-zinc-500/20";
    }
  };

  return (
    <div className="space-y-6">
      {toast && (
        <div
          className={`p-4 rounded-xl text-sm font-medium border flex items-center justify-between ${
            toast.type === "error"
              ? "bg-rose-500/10 border-rose-500/20 text-rose-400"
              : "bg-emerald-500/10 border-emerald-500/20 text-emerald-400"
          }`}
        >
          <span>{toast.message}</span>
          <button onClick={() => setToast(null)} className="opacity-70 hover:opacity-100 ml-4">
            ✕
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text-primary">System Notifications</h1>
          <p className="text-sm text-text-muted mt-1">Broadcast promotional, order, and system alerts to app users</p>
        </div>
        <button
          onClick={() => setShowBroadcastModal(true)}
          className="px-4 py-2.5 rounded-xl bg-brand-primary text-black font-semibold text-sm hover:opacity-90 transition-opacity flex items-center gap-2 self-start sm:self-auto"
        >
          <span>📣 Broadcast Notification</span>
        </button>
      </div>

      {/* Filter Bar */}
      <div className="p-4 rounded-2xl bg-bg-card border border-border-color flex items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <label className="text-xs font-medium text-text-muted">Filter Type:</label>
          <div className="w-48">
            <CustomSelect
              options={[
                { value: "all", label: "All Types" },
                { value: "system", label: "System" },
                { value: "order_update", label: "Order Updates" },
                { value: "payment", label: "Payment" },
                { value: "promotion", label: "Promotions" },
                { value: "support", label: "Support" },
                { value: "delivery", label: "Delivery" },
              ]}
              value={typeFilter}
              onChange={setTypeFilter}
            />
          </div>
        </div>
      </div>

      {/* Notifications Table */}
      <div className="rounded-2xl bg-bg-card border border-border-color overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-bg-primary/50 text-text-muted text-xs uppercase tracking-wider border-b border-border-color">
              <tr>
                <th className="p-4">Notification Details</th>
                <th className="p-4">Recipient</th>
                <th className="p-4">Type</th>
                <th className="p-4">Read Status</th>
                <th className="p-4">Created At</th>
                <th className="p-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-color text-text-primary">
              {loading ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-text-muted">
                    Loading notifications...
                  </td>
                </tr>
              ) : notifications.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-text-muted">
                    No notifications sent yet.
                  </td>
                </tr>
              ) : (
                notifications.map((n) => (
                  <tr key={n.id} className="hover:bg-bg-primary/40 transition-colors">
                    <td className="p-4 max-w-sm">
                      <div className="font-semibold text-text-primary text-sm line-clamp-1">{n.title}</div>
                      <div className="text-xs text-text-muted line-clamp-2 mt-0.5">{n.body}</div>
                    </td>
                    <td className="p-4 whitespace-nowrap text-xs text-text-muted">
                      {n.user_email}
                    </td>
                    <td className="p-4 whitespace-nowrap">
                      <span className={`px-2.5 py-1 text-[11px] font-semibold rounded-full border capitalize ${getTypeBadge(n.type)}`}>
                        {n.type.replace("_", " ")}
                      </span>
                    </td>
                    <td className="p-4 whitespace-nowrap text-xs">
                      {n.is_read ? (
                        <span className="text-emerald-400 font-medium">Read</span>
                      ) : (
                        <span className="text-amber-400 font-medium">Unread</span>
                      )}
                    </td>
                    <td className="p-4 whitespace-nowrap text-xs text-text-muted">
                      {new Date(n.created_at).toLocaleString()}
                    </td>
                    <td className="p-4 whitespace-nowrap text-right">
                      <button
                        onClick={() => setDeleteTarget(n)}
                        className="px-3 py-1.5 text-xs font-medium rounded-lg bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 border border-rose-500/20 transition-colors cursor-pointer"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-4 border-t border-border-color flex items-center justify-between text-xs text-text-muted">
          <div>
            Showing {notifications.length > 0 ? page * pageSize + 1 : 0} to{" "}
            {Math.min((page + 1) * pageSize, total)} of {total} notifications
          </div>
          <div className="flex gap-2">
            <button
              disabled={page === 0}
              onClick={() => setPage(page - 1)}
              className="px-3 py-1.5 rounded-lg border border-border-color disabled:opacity-40 hover:bg-bg-primary text-text-primary"
            >
              Previous
            </button>
            <button
              disabled={(page + 1) * pageSize >= total}
              onClick={() => setPage(page + 1)}
              className="px-3 py-1.5 rounded-lg border border-border-color disabled:opacity-40 hover:bg-bg-primary text-text-primary"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* Broadcast Modal */}
      {showBroadcastModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
          <div className="w-full max-w-lg rounded-2xl bg-bg-card border border-border-color p-6 space-y-5 shadow-2xl">
            <div className="flex items-center justify-between border-b border-border-color pb-3">
              <h3 className="text-lg font-bold text-text-primary">Send System Notification</h3>
              <button
                onClick={() => setShowBroadcastModal(false)}
                className="text-text-muted hover:text-text-primary text-sm p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleBroadcast} className="space-y-4 text-xs">
              <div>
                <label className="block text-text-muted mb-1 font-medium">Target Audience</label>
                <div className="flex gap-4">
                  <label className="flex items-center gap-2 text-text-primary cursor-pointer">
                    <input
                      type="radio"
                      name="target"
                      value="all"
                      checked={targetUser === "all"}
                      onChange={() => setTargetUser("all")}
                      className="accent-brand-primary"
                    />
                    All App Users
                  </label>
                  <label className="flex items-center gap-2 text-text-primary cursor-pointer">
                    <input
                      type="radio"
                      name="target"
                      value="single"
                      checked={targetUser === "single"}
                      onChange={() => setTargetUser("single")}
                      className="accent-brand-primary"
                    />
                    Specific User
                  </label>
                </div>
              </div>

              {targetUser === "single" && (
                <div>
                  <label className="block text-text-muted mb-1 font-medium">Select User</label>
                  <CustomSelect
                    options={[
                      { value: "", label: "-- Choose User --" },
                      ...users.map((u) => ({
                        value: u.id,
                        label: u.full_name ? `${u.full_name} (${u.email || u.id.slice(0, 8)})` : u.email || u.id,
                      })),
                    ]}
                    value={selectedUserId}
                    onChange={setSelectedUserId}
                    placeholder="-- Choose User --"
                  />
                </div>
              )}

              <div>
                <label className="block text-text-muted mb-1 font-medium">Notification Type</label>
                <CustomSelect
                  options={[
                    { value: "system", label: "System Announcement" },
                    { value: "promotion", label: "Promotion / Sale" },
                    { value: "order_update", label: "Order Update" },
                    { value: "payment", label: "Payment Alert" },
                    { value: "support", label: "Support Alert" },
                    { value: "delivery", label: "Delivery Status" },
                  ]}
                  value={notificationType}
                  onChange={(val) => setNotificationType(val as AppNotification["type"])}
                />
              </div>

              <div>
                <label className="block text-text-muted mb-1 font-medium">Title</label>
                <input
                  type="text"
                  placeholder="e.g. Flash Sale Live! 20% Off Audio Gadgets"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-bg-primary border border-border-color text-text-primary focus:outline-none"
                  required
                />
              </div>

              <div>
                <label className="block text-text-muted mb-1 font-medium">Body Message</label>
                <textarea
                  rows={3}
                  placeholder="Enter detailed notification content..."
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-bg-primary border border-border-color text-text-primary focus:outline-none resize-none"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-text-muted mb-1 font-medium">Reference Type (Optional)</label>
                  <input
                    type="text"
                    placeholder="e.g. order, product"
                    value={referenceType}
                    onChange={(e) => setReferenceType(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-bg-primary border border-border-color text-text-primary focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-text-muted mb-1 font-medium">Reference ID/Slug (Optional)</label>
                  <input
                    type="text"
                    placeholder="UUID or slug"
                    value={referenceId}
                    onChange={(e) => setReferenceId(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-bg-primary border border-border-color text-text-primary focus:outline-none"
                  />
                </div>
              </div>

              <div className="pt-3 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowBroadcastModal(false)}
                  className="w-1/2 py-2.5 font-medium rounded-xl border border-border-color text-text-primary hover:bg-bg-primary"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={sending}
                  className="w-1/2 py-2.5 font-semibold rounded-xl bg-brand-primary text-black hover:opacity-90 disabled:opacity-50"
                >
                  {sending ? "Sending..." : "Send Notification"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
