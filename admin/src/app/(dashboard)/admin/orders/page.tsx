"use client";

import { useEffect, useState, useCallback } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase";
import CustomSelect from "@/components/CustomSelect";
import { getGenericErrorMessage } from "@/lib/errorUtils";
import type { Order, OrderItem, Profile } from "@/lib/types";

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [paymentStatusFilter, setPaymentStatusFilter] = useState("");
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [toast, setToast] = useState<{ type: string; message: string } | null>(null);

  // Delivery update form state inside drawer
  const [deliveryStatus, setDeliveryStatus] = useState<Order["status"]>("pending");
  const [paymentStatus, setPaymentStatus] = useState<Order["payment_status"]>("unpaid");
  const [deliveryNotes, setDeliveryNotes] = useState("");
  const [courierName, setCourierName] = useState("");
  const [trackingNumber, setTrackingNumber] = useState("");
  const [updating, setUpdating] = useState(false);

  const supabase = createBrowserSupabaseClient();

  const loadOrders = useCallback(async () => {
    setLoading(true);
    try {
      let query = supabase
        .from("orders")
        .select("*, items:order_items(*)")
        .order("created_at", { ascending: false });

      if (search) query = query.or(`order_number.ilike.%${search}%`);
      if (statusFilter) query = query.eq("status", statusFilter);
      if (paymentStatusFilter) query = query.eq("payment_status", paymentStatusFilter);

      const { data: ordersData, error: ordersErr } = await query;
      if (ordersErr) {
        console.error("Error fetching orders:", ordersErr);
        showToast("error", getGenericErrorMessage(ordersErr, "Failed to load orders"));
        setOrders([]);
        return;
      }

      if (ordersData && ordersData.length > 0) {
        const userIds = Array.from(new Set(ordersData.map((o) => o.user_id).filter(Boolean)));
        const { data: profilesData } = await supabase
          .from("profiles")
          .select("*")
          .in("id", userIds);

        const profileMap = new Map((profilesData as Profile[] ?? []).map((p) => [p.id, p]));

        const mergedOrders = ordersData.map((o) => ({
          ...o,
          profile: profileMap.get(o.user_id) || null,
        }));

        setOrders(mergedOrders as Order[]);
      } else {
        setOrders([]);
      }
    } catch (err) {
      console.error("Failed to load orders:", err);
      showToast("error", getGenericErrorMessage(err, "An error occurred while loading orders."));
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter, paymentStatusFilter, supabase]);

  useEffect(() => {
    loadOrders();
  }, [loadOrders]);

  const openOrderDrawer = (order: Order) => {
    setSelectedOrder(order);
    setDeliveryStatus(order.status);
    setPaymentStatus(order.payment_status);
    setDeliveryNotes(order.notes || "");
    
    if (order.notes && order.notes.includes("Courier:")) {
      const courierMatch = order.notes.match(/Courier:\s*([^,|]+)/);
      const trackingMatch = order.notes.match(/Tracking:\s*([^,|]+)/);
      if (courierMatch) setCourierName(courierMatch[1].trim());
      if (trackingMatch) setTrackingNumber(trackingMatch[1].trim());
    } else {
      setCourierName("");
      setTrackingNumber("");
    }
  };

  const handleUpdateDeliveryAndFulfillment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedOrder) return;

    setUpdating(true);

    let updatedNotes = deliveryNotes.trim();
    if (courierName.trim() || trackingNumber.trim()) {
      const trackingInfo = `Courier: ${courierName.trim() || "N/A"} | Tracking: ${trackingNumber.trim() || "N/A"}`;
      updatedNotes = updatedNotes ? `${trackingInfo}\n${updatedNotes}` : trackingInfo;
    }

    const { error } = await supabase
      .from("orders")
      .update({
        status: deliveryStatus,
        payment_status: paymentStatus,
        notes: updatedNotes || null,
        updated_at: new Date().toISOString(),
      })
      .eq("id", selectedOrder.id);

    if (error) {
      showToast("error", getGenericErrorMessage(error, "Failed to update order"));
    } else {
      if (deliveryStatus !== selectedOrder.status) {
        let statusTitle = `Order ${selectedOrder.order_number} Update`;
        if (deliveryStatus === "shipped") statusTitle = `Order ${selectedOrder.order_number} Shipped`;
        if (deliveryStatus === "out_for_delivery") statusTitle = `Order ${selectedOrder.order_number} Out for Delivery`;
        if (deliveryStatus === "delivered") statusTitle = `Order ${selectedOrder.order_number} Delivered`;
        if (deliveryStatus === "confirmed") statusTitle = `Order ${selectedOrder.order_number} Confirmed`;
        if (deliveryStatus === "return_requested") statusTitle = `Return Requested for ${selectedOrder.order_number}`;
        if (deliveryStatus === "returned") statusTitle = `Order ${selectedOrder.order_number} Returned`;


      }

      showToast("success", `Delivery status updated to "${deliveryStatus.replace("_", " ")}" successfully!`);
      
      const updatedOrder = {
        ...selectedOrder,
        status: deliveryStatus,
        payment_status: paymentStatus,
        notes: updatedNotes || null,
      };
      setSelectedOrder(updatedOrder);

      setOrders((prev) =>
        prev.map((o) => (o.id === selectedOrder.id ? updatedOrder : o))
      );
    }

    setUpdating(false);
  };

  const showToast = (type: string, message: string) => {
    setToast({ type, message });
    setTimeout(() => setToast(null), 4000);
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "delivered":
        return "bg-emerald-100 text-emerald-800 border-emerald-300 font-semibold";
      case "out_for_delivery":
        return "bg-teal-100 text-teal-800 border-teal-300 font-semibold";
      case "confirmed":
        return "bg-blue-100 text-blue-800 border-blue-300 font-semibold";
      case "shipped":
        return "bg-sky-100 text-sky-800 border-sky-300 font-semibold";
      case "processing":
        return "bg-indigo-100 text-indigo-800 border-indigo-300 font-semibold";
      case "pending_payment":
      case "pending":
        return "bg-amber-100 text-amber-800 border-amber-300 font-semibold";
      case "return_requested":
        return "bg-purple-100 text-purple-800 border-purple-300 font-semibold";
      case "returned":
        return "bg-orange-100 text-orange-800 border-orange-300 font-semibold";
      case "cancelled":
        return "bg-rose-100 text-rose-800 border-rose-300 font-semibold";
      default:
        return "bg-slate-100 text-slate-700 border-slate-300 font-semibold";
    }
  };

  const getPaymentBadge = (status: string) => {
    switch (status) {
      case "paid":
        return "bg-emerald-100 text-emerald-800 border-emerald-300 font-semibold";
      case "processing":
        return "bg-blue-100 text-blue-800 border-blue-300 font-semibold";
      case "unpaid":
        return "bg-amber-100 text-amber-800 border-amber-300 font-semibold";
      case "failed":
      case "refunded":
        return "bg-rose-100 text-rose-800 border-rose-300 font-semibold";
      default:
        return "bg-slate-100 text-slate-700 border-slate-300 font-semibold";
    }
  };

  return (
    <div className="space-y-6">
      {/* Toast Notification */}
      {toast && (
        <div
          className={`p-4 rounded-xl text-sm font-medium border fixed bottom-6 right-6 z-[100] flex items-center justify-between shadow-2xl ${
            toast.type === "error"
              ? "bg-red-900 text-white border-red-700"
              : "bg-emerald-900 text-white border-emerald-700"
          }`}
        >
          <span>{toast.message}</span>
        </div>
      )}

      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Order & Delivery Management</h1>
          <p className="text-sm text-slate-500 mt-1">
            Track customer orders, manage payment statuses, and update courier/delivery details manually.
          </p>
        </div>
      </div>

      {/* Full-width Search & Filters */}
      <div className="p-4 rounded-2xl bg-white border border-slate-200 shadow-sm flex items-center justify-between gap-4 flex-wrap">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 w-full">
          <div className="relative">
            <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm pointer-events-none">🔍</span>
            <input
              type="text"
              className="w-full pl-10 pr-4 py-2 text-sm rounded-xl bg-slate-50 border border-slate-200 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-slate-800"
              placeholder="Search order number..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <CustomSelect
            options={[
              { value: "", label: "All Delivery Statuses" },
              { value: "pending_payment", label: "Pending Payment" },
              { value: "pending", label: "Pending Confirmation" },
              { value: "confirmed", label: "Confirmed" },
              { value: "processing", label: "Processing / Packing" },
              { value: "shipped", label: "Shipped / Dispatched" },
              { value: "out_for_delivery", label: "Out for Delivery" },
              { value: "delivered", label: "Delivered" },
              { value: "return_requested", label: "Return Requested" },
              { value: "returned", label: "Returned / Refunded" },
              { value: "cancelled", label: "Cancelled" },
            ]}
            value={statusFilter}
            onChange={setStatusFilter}
          />
          <CustomSelect
            options={[
              { value: "", label: "All Payment Statuses" },
              { value: "unpaid", label: "Unpaid" },
              { value: "processing", label: "Processing" },
              { value: "paid", label: "Paid" },
              { value: "failed", label: "Failed" },
              { value: "refunded", label: "Refunded" },
            ]}
            value={paymentStatusFilter}
            onChange={setPaymentStatusFilter}
          />
        </div>
      </div>

      {/* Spacious 100% Width Orders Table */}
      <div className="rounded-2xl bg-white border border-slate-200 shadow-sm overflow-hidden w-full">
        {loading ? (
          <div className="p-12 text-center text-slate-500 text-sm font-medium">
            Loading customer orders...
          </div>
        ) : orders.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center text-slate-500">
            <h3 className="text-base font-semibold text-slate-900 mb-1">No orders found</h3>
            <p className="text-xs max-w-xs text-slate-500">
              {statusFilter || search || paymentStatusFilter
                ? "Try adjusting your filters or search query."
                : "No customer orders have been recorded in the database yet."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto w-full">
            <table className="w-full min-w-[1000px] text-left text-sm">
              <thead className="bg-slate-100/80 text-slate-600 text-xs uppercase tracking-wider border-b border-slate-200 font-semibold">
                <tr>
                  <th className="px-5 py-4">Order #</th>
                  <th className="px-5 py-4">Customer Details</th>
                  <th className="px-5 py-4">Total Amount</th>
                  <th className="px-5 py-4">Payment Method</th>
                  <th className="px-5 py-4">Payment Status</th>
                  <th className="px-5 py-4">Delivery Status</th>
                  <th className="px-5 py-4">Date</th>
                  <th className="px-5 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 text-slate-900 bg-white">
                {orders.map((order) => (
                  <tr
                    key={order.id}
                    onClick={() => openOrderDrawer(order)}
                    className={`hover:bg-slate-50 cursor-pointer transition-colors ${
                      selectedOrder?.id === order.id ? "bg-slate-100/70" : ""
                    }`}
                  >
                    <td className="px-5 py-4 whitespace-nowrap">
                      <strong className="font-mono text-xs text-slate-900 font-bold">{order.order_number}</strong>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      <div className="font-semibold text-sm text-slate-900">{order.profile?.full_name || "Customer"}</div>
                      <div className="text-xs text-slate-500">
                        {order.profile?.email || order.profile?.phone_number || order.user_id.slice(0, 8)}
                      </div>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      <div className="font-bold text-sm text-slate-900">₹{Number(order.total_amount).toLocaleString()}</div>
                      {order.items && (
                        <div className="text-xs text-slate-500 font-medium">
                          {order.items.length} item{order.items.length > 1 ? "s" : ""}
                        </div>
                      )}
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      <span className="uppercase text-xs font-semibold text-slate-600">
                        {order.payment_method}
                      </span>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-1 text-[11px] font-bold rounded-full border capitalize ${getPaymentBadge(order.payment_status)}`}>
                        {order.payment_status}
                      </span>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-1 text-[11px] font-bold rounded-full border capitalize ${getStatusBadge(order.status)}`}>
                        {order.status.replace("_", " ")}
                      </span>
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap text-xs text-slate-500 font-medium">
                      {new Date(order.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-5 py-4 whitespace-nowrap text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          openOrderDrawer(order);
                        }}
                        className="px-4 py-2 text-xs font-bold rounded-xl bg-slate-900 text-white hover:bg-slate-800 transition-colors shadow-sm"
                      >
                        Manage Delivery
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Solid Opaque Backdrop & Right Slide-Over Modal */}
      {selectedOrder && (
        <div
          className="fixed inset-0 z-50 flex justify-end bg-slate-950/70 backdrop-blur-xs animate-in fade-in duration-200"
          onClick={() => setSelectedOrder(null)}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-xl bg-white border-l border-slate-200 h-full overflow-y-auto p-6 space-y-6 shadow-2xl text-slate-900 relative z-10"
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between border-b border-slate-200 pb-4">
              <div>
                <span className="font-mono text-xs text-slate-500 font-bold">{selectedOrder.order_number}</span>
                <h2 className="text-xl font-extrabold text-slate-900">Order & Delivery Manager</h2>
              </div>
              <button
                onClick={() => setSelectedOrder(null)}
                className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-700 font-bold hover:bg-slate-200 text-xs transition-colors flex items-center gap-1"
              >
                ✕ Close
              </button>
            </div>

            {/* Customer Details Box */}
            <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 space-y-1 text-xs">
              <span className="text-slate-500 font-bold uppercase tracking-wider block text-[10px] mb-1">Customer Details</span>
              <div className="font-bold text-sm text-slate-900">{selectedOrder.profile?.full_name || "Customer"}</div>
              <div className="text-slate-600 font-medium">{selectedOrder.profile?.email || "No email provided"}</div>
              <div className="text-slate-600 font-medium">{selectedOrder.profile?.phone_number || "No phone provided"}</div>
            </div>

            {/* Delivery Update Form */}
            <form onSubmit={handleUpdateDeliveryAndFulfillment} className="p-5 rounded-2xl bg-slate-50 border border-slate-200 space-y-4 shadow-sm">
              <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                Update Delivery & Tracking Status
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                <div>
                  <label className="block text-slate-700 mb-1 font-semibold">Delivery Status</label>
                  <CustomSelect
                    options={[
                      { value: "pending_payment", label: "Pending Payment" },
                      { value: "pending", label: "Pending Confirmation" },
                      { value: "confirmed", label: "Confirmed" },
                      { value: "processing", label: "Processing / Packing" },
                      { value: "shipped", label: "Shipped / Dispatched" },
                      { value: "out_for_delivery", label: "Out for Delivery" },
                      { value: "delivered", label: "Delivered" },
                      { value: "return_requested", label: "Return Requested" },
                      { value: "returned", label: "Returned / Refunded" },
                      { value: "cancelled", label: "Cancelled" },
                    ]}
                    value={deliveryStatus}
                    onChange={(val) => setDeliveryStatus(val as Order["status"])}
                  />
                </div>
                <div>
                  <label className="block text-slate-700 mb-1 font-semibold">Payment Status</label>
                  <CustomSelect
                    options={[
                      { value: "unpaid", label: "Unpaid" },
                      { value: "processing", label: "Processing" },
                      { value: "paid", label: "Paid" },
                      { value: "failed", label: "Failed" },
                      { value: "refunded", label: "Refunded" },
                    ]}
                    value={paymentStatus}
                    onChange={(val) => setPaymentStatus(val as Order["payment_status"])}
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                <div>
                  <label className="block text-slate-700 mb-1 font-semibold">Courier Partner Name</label>
                  <input
                    type="text"
                    placeholder="e.g. BlueDart, Delhivery, FedEx"
                    value={courierName}
                    onChange={(e) => setCourierName(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-white border border-slate-300 text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-900 font-medium"
                  />
                </div>
                <div>
                  <label className="block text-slate-700 mb-1 font-semibold">Tracking / AWB Number</label>
                  <input
                    type="text"
                    placeholder="e.g. AWB987654321"
                    value={trackingNumber}
                    onChange={(e) => setTrackingNumber(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-white border border-slate-300 text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-900 font-medium"
                  />
                </div>
              </div>

              <div className="text-xs">
                <label className="block text-slate-700 mb-1 font-semibold">Delivery Notes / Updates</label>
                <textarea
                  rows={2}
                  placeholder="e.g. Dispatched via express air. Delivery expected by Monday."
                  value={deliveryNotes}
                  onChange={(e) => setDeliveryNotes(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-white border border-slate-300 text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-900 resize-none font-medium"
                />
              </div>

              <button
                type="submit"
                disabled={updating}
                className="w-full py-3 text-xs font-bold rounded-xl bg-slate-900 text-white hover:bg-slate-800 disabled:opacity-50 transition-colors shadow-md"
              >
                {updating ? "Saving Update..." : "Save Delivery Status & Notify Customer"}
              </button>
            </form>

            {/* Purchased Items Box */}
            <div className="space-y-3">
              <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider">Purchased Items</h4>
              <div className="space-y-2">
                {selectedOrder.items && selectedOrder.items.length > 0 ? (
                  selectedOrder.items.map((item: OrderItem) => (
                    <div key={item.id} className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
                      <div>
                        <div className="font-bold text-slate-900">{item.product_name}</div>
                        {item.variant_name && <div className="text-slate-500 text-[11px] font-medium">{item.variant_name}</div>}
                        <div className="text-slate-500 text-[11px] font-medium mt-0.5">Qty: {item.quantity} × ₹{Number(item.unit_price).toLocaleString()}</div>
                      </div>
                      <div className="font-extrabold text-slate-900 text-sm">
                        ₹{Number(item.total_price).toLocaleString()}
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="text-xs text-slate-400 italic">No items attached to order.</div>
                )}
              </div>
            </div>

            {/* Pricing Summary Box */}
            <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 space-y-2 text-xs">
              <div className="flex justify-between text-slate-600 font-medium">
                <span>Subtotal</span>
                <span>₹{Number(selectedOrder.subtotal).toLocaleString()}</span>
              </div>
              <div className="flex justify-between text-slate-600 font-medium">
                <span>Shipping Fee</span>
                <span>₹{Number(selectedOrder.shipping_fee).toLocaleString()}</span>
              </div>
              <div className="flex justify-between text-slate-600 font-medium">
                <span>Tax</span>
                <span>₹{Number(selectedOrder.tax_amount).toLocaleString()}</span>
              </div>
              <div className="flex justify-between font-extrabold text-slate-900 text-base pt-2 border-t border-slate-200">
                <span>Total Amount</span>
                <span>₹{Number(selectedOrder.total_amount).toLocaleString()}</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
