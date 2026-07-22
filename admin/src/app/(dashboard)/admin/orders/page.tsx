"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import type { Order } from "@/lib/types";

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);
  const supabase = createBrowserSupabaseClient();

  const loadOrders = useCallback(async () => {
    setLoading(true);
    try {
      let query = supabase
        .from("orders")
        .select("*, profile:profiles(*), items:order_items(*)")
        .order("created_at", { ascending: false });

      if (search) query = query.or(`order_number.ilike.%${search}%`);
      if (statusFilter) query = query.eq("status", statusFilter);

      const { data, error } = await query;
      if (!error && data) {
        setOrders(data as Order[]);
      }
    } catch (err) {
      console.error("Failed to load orders:", err);
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter]);

  useEffect(() => {
    loadOrders();
  }, [loadOrders]);

  const updateOrderStatus = async (orderId: string, newStatus: Order["status"]) => {
    const { error } = await supabase
      .from("orders")
      .update({ status: newStatus })
      .eq("id", orderId);

    if (!error) {
      setOrders((prev) =>
        prev.map((o) => (o.id === orderId ? { ...o, status: newStatus } : o))
      );
      showToast("success", `Order status updated to ${newStatus}`);
    } else {
      showToast("error", error.message);
    }
  };

  const updatePaymentStatus = async (orderId: string, newPaymentStatus: Order["payment_status"]) => {
    const { error } = await supabase
      .from("orders")
      .update({ payment_status: newPaymentStatus })
      .eq("id", orderId);

    if (!error) {
      setOrders((prev) =>
        prev.map((o) => (o.id === orderId ? { ...o, payment_status: newPaymentStatus } : o))
      );
      showToast("success", `Payment status updated to ${newPaymentStatus}`);
    } else {
      showToast("error", error.message);
    }
  };

  const showToast = (type: string, message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 3000);
  };

  const getStatusBadgeClass = (status: string) => {
    switch (status) {
      case "delivered":
      case "confirmed":
        return "badge-success";
      case "shipped":
      case "processing":
        return "badge-info";
      case "pending_payment":
      case "pending":
        return "badge-warning";
      case "cancelled":
        return "badge-danger";
      default:
        return "badge-neutral";
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Orders</h1>
          <p className="text-text-secondary text-sm mt-1">
            Manage customer orders, track payments, and update fulfillment statuses.
          </p>
        </div>
      </div>

      <div className="flex gap-2 items-center flex-wrap mb-6">
        <div className="relative">
          <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-tertiary text-sm pointer-events-none">🔍</span>
          <input
            type="text"
            className="form-input pl-10 min-w-[280px]"
            placeholder="Search by order number..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select className="form-select" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
          <option value="">All Statuses</option>
          <option value="pending_payment">Pending Payment</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="processing">Processing</option>
          <option value="shipped">Shipped</option>
          <option value="delivered">Delivered</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>

      <div className="glass-card overflow-hidden">
        {loading ? (
          <div className="p-12 flex items-center justify-center">
            <div className="spinner spinner-lg" />
          </div>
        ) : orders.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-text-tertiary">
            <div className="text-5xl mb-4 opacity-50">🛒</div>
            <h3 className="text-lg text-text-secondary mb-1">No orders found</h3>
            <p className="text-sm max-w-[360px]">
              {statusFilter || search
                ? "Try adjusting your filters or search terms."
                : "No customer orders have been placed yet."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Order #</th>
                  <th>Customer</th>
                  <th>Total Amount</th>
                  <th>Method</th>
                  <th>Payment Status</th>
                  <th>Order Status</th>
                  <th>Placed At</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order) => (
                  <tr key={order.id}>
                    <td>
                      <strong className="font-mono text-sm">{order.order_number}</strong>
                    </td>
                    <td>
                      <div>
                        <div className="font-medium text-sm">
                          {order.profile?.full_name || "Customer"}
                        </div>
                        <div className="text-xs text-text-tertiary">
                          {order.profile?.email || order.profile?.phone_number || "—"}
                        </div>
                      </div>
                    </td>
                    <td>
                      <strong className="text-sm">₹{order.total_amount.toLocaleString()}</strong>
                      {order.items && order.items.length > 0 && (
                        <div className="text-xs text-text-tertiary">
                          {order.items.length} item{order.items.length > 1 ? "s" : ""}
                        </div>
                      )}
                    </td>
                    <td>
                      <span className="uppercase text-xs font-semibold text-text-secondary">
                        {order.payment_method}
                      </span>
                    </td>
                    <td>
                      <select
                        className="form-select min-w-[130px] py-1.5 pl-2.5 pr-7 text-[0.8125rem]"
                        value={order.payment_status}
                        onChange={(e) => updatePaymentStatus(order.id, e.target.value as Order["payment_status"])}
                      >
                        <option value="unpaid">Unpaid</option>
                        <option value="processing">Processing</option>
                        <option value="paid">Paid</option>
                        <option value="failed">Failed</option>
                        <option value="refunded">Refunded</option>
                      </select>
                    </td>
                    <td>
                      <div className="flex items-center gap-2">
                        <span className={`badge ${getStatusBadgeClass(order.status)}`}>
                          {order.status}
                        </span>
                        <select
                          className="form-select min-w-[140px] py-1.5 pl-2.5 pr-7 text-[0.8125rem]"
                          value={order.status}
                          onChange={(e) => updateOrderStatus(order.id, e.target.value as Order["status"])}
                        >
                          <option value="pending_payment">Pending Payment</option>
                          <option value="pending">Pending</option>
                          <option value="confirmed">Confirmed</option>
                          <option value="processing">Processing</option>
                          <option value="shipped">Shipped</option>
                          <option value="delivered">Delivered</option>
                          <option value="cancelled">Cancelled</option>
                        </select>
                      </div>
                    </td>
                    <td className="text-[0.8125rem] text-text-tertiary">
                      {new Date(order.created_at).toLocaleDateString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {toast && (
        <div className={`toast ${toast.type === "success" ? "toast-success" : "toast-error"}`}>
          {toast.message}
        </div>
      )}
    </div>
  );
}
