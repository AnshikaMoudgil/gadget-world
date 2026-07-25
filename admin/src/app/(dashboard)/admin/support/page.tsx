"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import CustomSelect from "@/components/CustomSelect";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { SupportTicket, SupportMessage } from "@/lib/types";

export default function SupportTicketsPage() {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [priorityFilter, setPriorityFilter] = useState("all");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [page, setPage] = useState(0);
  const [total, setTotal] = useState(0);
  const [selectedTicket, setSelectedTicket] = useState<SupportTicket | null>(null);
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [replyText, setReplyText] = useState("");
  const [isInternalNote, setIsInternalNote] = useState(false);
  const [sendingReply, setSendingReply] = useState(false);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);

  const pageSize = 15;
  const supabase = createBrowserSupabaseClient();

  const loadTickets = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("support_tickets")
      .select("*, profile:profiles!support_tickets_user_id_fkey(*)", { count: "exact" })
      .order("updated_at", { ascending: false })
      .range(page * pageSize, (page + 1) * pageSize - 1);

    if (search) query = query.or(`subject.ilike.%${search}%,ticket_number.ilike.%${search}%`);
    if (statusFilter !== "all") query = query.eq("status", statusFilter);
    if (priorityFilter !== "all") query = query.eq("priority", priorityFilter);
    if (categoryFilter !== "all") query = query.eq("category", categoryFilter);

    const { data, count, error } = await query;
    if (error) {
      setToast({ type: "error", message: getGenericErrorMessage(error, "Failed to load support tickets") });
    } else {
      setTickets((data as SupportTicket[]) ?? []);
      setTotal(count ?? 0);
    }
    setLoading(false);
  }, [page, search, statusFilter, priorityFilter, categoryFilter, supabase]);

  useEffect(() => {
    loadTickets();
  }, [loadTickets]);

  const loadMessages = async (ticketId: string) => {
    setLoadingMessages(true);
    const { data, error } = await supabase
      .from("support_messages")
      .select("*, sender:profiles!support_messages_sender_id_fkey(*)")
      .eq("ticket_id", ticketId)
      .order("created_at", { ascending: true });

    if (error) {
      setToast({ type: "error", message: `Failed to load thread: ${error.message}` });
    } else {
      setMessages((data as SupportMessage[]) ?? []);
    }
    setLoadingMessages(false);
  };

  const handleSelectTicket = (ticket: SupportTicket) => {
    setSelectedTicket(ticket);
    loadMessages(ticket.id);
  };

  const updateTicketStatus = async (ticketId: string, newStatus: string) => {
    const updateData: Record<string, unknown> = {
      status: newStatus,
      updated_at: new Date().toISOString(),
    };
    if (newStatus === "resolved" || newStatus === "closed") {
      updateData.resolved_at = new Date().toISOString();
    }

    const { error } = await supabase
      .from("support_tickets")
      .update(updateData)
      .eq("id", ticketId);

    if (error) {
      setToast({ type: "error", message: `Failed to update status: ${error.message}` });
    } else {
      setToast({ type: "success", message: `Ticket status updated to ${newStatus}` });
      if (selectedTicket && selectedTicket.id === ticketId) {
        setSelectedTicket({ ...selectedTicket, status: newStatus as SupportTicket["status"] });
      }
      loadTickets();
    }
  };

  const updateTicketPriority = async (ticketId: string, newPriority: string) => {
    const { error } = await supabase
      .from("support_tickets")
      .update({ priority: newPriority, updated_at: new Date().toISOString() })
      .eq("id", ticketId);

    if (error) {
      setToast({ type: "error", message: `Failed to update priority: ${error.message}` });
    } else {
      setToast({ type: "success", message: `Ticket priority updated to ${newPriority}` });
      if (selectedTicket && selectedTicket.id === ticketId) {
        setSelectedTicket({ ...selectedTicket, priority: newPriority as SupportTicket["priority"] });
      }
      loadTickets();
    }
  };

  const handleSendReply = async () => {
    if (!selectedTicket || !replyText.trim()) return;
    setSendingReply(true);

    const { data: userData } = await supabase.auth.getUser();
    if (!userData.user) {
      setToast({ type: "error", message: "Admin user not authenticated" });
      setSendingReply(false);
      return;
    }

    const { error } = await supabase.from("support_messages").insert({
      ticket_id: selectedTicket.id,
      sender_id: userData.user.id,
      sender_role: "admin",
      message: replyText.trim(),
      is_internal: isInternalNote,
    });

    if (error) {
      setToast({ type: "error", message: `Failed to send reply: ${error.message}` });
    } else {
      setToast({ type: "success", message: isInternalNote ? "Internal note added" : "Reply sent to customer" });
      setReplyText("");
      setIsInternalNote(false);
      loadMessages(selectedTicket.id);

      // Auto update ticket status to in_progress or waiting_customer if open
      if (selectedTicket.status === "open") {
        updateTicketStatus(selectedTicket.id, "in_progress");
      }
    }
    setSendingReply(false);
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "open":
        return "bg-amber-500/10 text-amber-500 border-amber-500/20";
      case "in_progress":
        return "bg-blue-500/10 text-blue-500 border-blue-500/20";
      case "waiting_customer":
        return "bg-purple-500/10 text-purple-500 border-purple-500/20";
      case "resolved":
        return "bg-emerald-500/10 text-emerald-500 border-emerald-500/20";
      case "closed":
        return "bg-zinc-500/10 text-zinc-400 border-zinc-500/20";
      default:
        return "bg-zinc-500/10 text-zinc-400 border-zinc-500/20";
    }
  };

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "urgent":
        return "bg-rose-500/10 text-rose-500 border-rose-500/20";
      case "high":
        return "bg-orange-500/10 text-orange-500 border-orange-500/20";
      case "medium":
        return "bg-sky-500/10 text-sky-500 border-sky-500/20";
      case "low":
        return "bg-slate-500/10 text-slate-400 border-slate-500/20";
      default:
        return "bg-slate-500/10 text-slate-400 border-slate-500/20";
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
          <h1 className="text-2xl font-bold tracking-tight text-text-primary">Support Tickets</h1>
          <p className="text-sm text-text-muted mt-1">Manage customer queries, complaints, and ticket responses</p>
        </div>
      </div>

      {/* Filters & Search */}
      <div className="p-4 rounded-2xl bg-bg-card border border-border-color space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3">
          <input
            type="text"
            placeholder="Search by ticket # or subject..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-3.5 py-2 text-sm rounded-xl bg-bg-primary border border-border-color text-text-primary placeholder:text-text-muted focus:outline-none focus:border-brand-primary"
          />
          <CustomSelect
            options={[
              { value: "all", label: "All Statuses" },
              { value: "open", label: "Open" },
              { value: "in_progress", label: "In Progress" },
              { value: "waiting_customer", label: "Waiting on Customer" },
              { value: "resolved", label: "Resolved" },
              { value: "closed", label: "Closed" },
            ]}
            value={statusFilter}
            onChange={setStatusFilter}
          />
          <CustomSelect
            options={[
              { value: "all", label: "All Priorities" },
              { value: "urgent", label: "Urgent" },
              { value: "high", label: "High" },
              { value: "medium", label: "Medium" },
              { value: "low", label: "Low" },
            ]}
            value={priorityFilter}
            onChange={setPriorityFilter}
          />
          <CustomSelect
            options={[
              { value: "all", label: "All Categories" },
              { value: "general", label: "General" },
              { value: "order_issue", label: "Order Issue" },
              { value: "payment", label: "Payment" },
              { value: "delivery", label: "Delivery" },
              { value: "return_refund", label: "Return & Refund" },
              { value: "product", label: "Product" },
              { value: "account", label: "Account" },
              { value: "other", label: "Other" },
            ]}
            value={categoryFilter}
            onChange={setCategoryFilter}
          />
        </div>
      </div>

      {/* Main Content Layout (Table + Thread Drawer) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Tickets Table */}
        <div className={`lg:col-span-${selectedTicket ? "2" : "3"} space-y-4`}>
          <div className="rounded-2xl bg-bg-card border border-border-color overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-bg-primary/50 text-text-muted text-xs uppercase tracking-wider border-b border-border-color">
                  <tr>
                    <th className="p-4">Ticket</th>
                    <th className="p-4">Customer</th>
                    <th className="p-4">Category</th>
                    <th className="p-4">Priority</th>
                    <th className="p-4">Status</th>
                    <th className="p-4">Updated</th>
                    <th className="p-4 text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border-color text-text-primary">
                  {loading ? (
                    <tr>
                      <td colSpan={7} className="p-8 text-center text-text-muted">
                        Loading support tickets...
                      </td>
                    </tr>
                  ) : tickets.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="p-8 text-center text-text-muted">
                        No support tickets found matching your filters.
                      </td>
                    </tr>
                  ) : (
                    tickets.map((t) => (
                      <tr
                        key={t.id}
                        onClick={() => handleSelectTicket(t)}
                        className={`hover:bg-bg-primary/40 cursor-pointer transition-colors ${
                          selectedTicket?.id === t.id ? "bg-bg-primary/80 font-medium" : ""
                        }`}
                      >
                        <td className="p-4 whitespace-nowrap">
                          <div className="font-mono text-xs font-semibold text-brand-primary">{t.ticket_number}</div>
                          <div className="font-medium text-sm text-text-primary truncate max-w-[200px]">{t.subject}</div>
                        </td>
                        <td className="p-4 whitespace-nowrap">
                          <div className="text-sm font-medium">{t.profile?.full_name || "Unknown User"}</div>
                          <div className="text-xs text-text-muted">{t.profile?.email || t.user_id.slice(0, 8)}</div>
                        </td>
                        <td className="p-4 whitespace-nowrap capitalize text-xs text-text-muted">
                          {t.category.replace("_", " ")}
                        </td>
                        <td className="p-4 whitespace-nowrap">
                          <span className={`px-2.5 py-1 text-[11px] font-semibold rounded-full border capitalize ${getPriorityBadge(t.priority)}`}>
                            {t.priority}
                          </span>
                        </td>
                        <td className="p-4 whitespace-nowrap">
                          <span className={`px-2.5 py-1 text-[11px] font-semibold rounded-full border capitalize ${getStatusBadge(t.status)}`}>
                            {t.status.replace("_", " ")}
                          </span>
                        </td>
                        <td className="p-4 whitespace-nowrap text-xs text-text-muted">
                          {new Date(t.updated_at).toLocaleDateString()}
                        </td>
                        <td className="p-4 whitespace-nowrap text-right">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleSelectTicket(t);
                            }}
                            className="px-3 py-1.5 text-xs font-medium rounded-lg bg-bg-primary border border-border-color hover:border-brand-primary text-text-primary transition-colors"
                          >
                            View
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
                Showing {tickets.length > 0 ? page * pageSize + 1 : 0} to{" "}
                {Math.min((page + 1) * pageSize, total)} of {total} tickets
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
        </div>

        {/* Thread & Detail View Side Panel */}
        {selectedTicket && (
          <div className="rounded-2xl bg-bg-card border border-border-color p-5 space-y-4 flex flex-col h-[750px] sticky top-6">
            <div className="flex items-center justify-between pb-3 border-b border-border-color">
              <div>
                <span className="font-mono text-xs text-brand-primary font-bold">{selectedTicket.ticket_number}</span>
                <h3 className="font-semibold text-text-primary text-base line-clamp-1">{selectedTicket.subject}</h3>
              </div>
              <button
                onClick={() => setSelectedTicket(null)}
                className="p-1 rounded-lg hover:bg-bg-primary text-text-muted"
              >
                ✕
              </button>
            </div>

            {/* Ticket Metadata Controls */}
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div>
                <label className="text-text-muted block mb-1">Status</label>
                <CustomSelect
                  options={[
                    { value: "open", label: "Open" },
                    { value: "in_progress", label: "In Progress" },
                    { value: "waiting_customer", label: "Waiting Customer" },
                    { value: "resolved", label: "Resolved" },
                    { value: "closed", label: "Closed" },
                  ]}
                  value={selectedTicket.status}
                  onChange={(val) => updateTicketStatus(selectedTicket.id, val)}
                  size="sm"
                />
              </div>
              <div>
                <label className="text-text-muted block mb-1">Priority</label>
                <CustomSelect
                  options={[
                    { value: "low", label: "Low" },
                    { value: "medium", label: "Medium" },
                    { value: "high", label: "High" },
                    { value: "urgent", label: "Urgent" },
                  ]}
                  value={selectedTicket.priority}
                  onChange={(val) => updateTicketPriority(selectedTicket.id, val)}
                  size="sm"
                />
              </div>
            </div>

            {/* Messages Thread */}
            <div className="flex-1 overflow-y-auto space-y-3 p-3 rounded-xl bg-bg-primary/50 border border-border-color">
              {loadingMessages ? (
                <div className="text-center py-8 text-xs text-text-muted">Loading thread...</div>
              ) : messages.length === 0 ? (
                <div className="text-center py-8 text-xs text-text-muted">No messages in thread yet.</div>
              ) : (
                messages.map((m) => {
                  const isAdmin = m.sender_role === "admin";
                  return (
                    <div
                      key={m.id}
                      className={`p-3 rounded-xl text-xs space-y-1 ${
                        m.is_internal
                          ? "bg-amber-500/10 border border-amber-500/20 text-amber-200"
                          : isAdmin
                          ? "bg-brand-primary/10 border border-brand-primary/20 text-text-primary ml-4"
                          : "bg-bg-card border border-border-color text-text-primary mr-4"
                      }`}
                    >
                      <div className="flex items-center justify-between font-medium text-[11px] opacity-80">
                        <span>
                          {m.is_internal ? "🔒 Internal Note" : m.sender?.full_name || (isAdmin ? "Admin Support" : "Customer")}
                        </span>
                        <span>{new Date(m.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}</span>
                      </div>
                      <p className="whitespace-pre-wrap leading-relaxed">{m.message}</p>
                    </div>
                  );
                })
              )}
            </div>

            {/* Reply Editor */}
            <div className="space-y-2 pt-2 border-t border-border-color">
              <div className="flex items-center justify-between">
                <label className="text-xs font-medium text-text-muted">Reply to ticket</label>
                <label className="flex items-center gap-1.5 text-xs text-amber-400 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={isInternalNote}
                    onChange={(e) => setIsInternalNote(e.target.checked)}
                    className="rounded bg-bg-primary border-border-color"
                  />
                  Internal Note
                </label>
              </div>
              <textarea
                rows={3}
                placeholder={isInternalNote ? "Write internal staff note..." : "Write response to customer..."}
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                className="w-full p-2.5 text-xs rounded-xl bg-bg-primary border border-border-color text-text-primary placeholder:text-text-muted focus:outline-none focus:border-brand-primary resize-none"
              />
              <button
                disabled={sendingReply || !replyText.trim()}
                onClick={handleSendReply}
                className="w-full py-2 text-xs font-semibold rounded-xl bg-brand-primary text-black disabled:opacity-50 hover:opacity-90 transition-opacity"
              >
                {sendingReply ? "Sending..." : isInternalNote ? "Add Note" : "Send Reply"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
