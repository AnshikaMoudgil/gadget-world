"use client";

export default function OrdersPage() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Orders</h1>
      </div>

      <div className="glass-card p-12 flex flex-col items-center text-center">
        <div className="text-accent-light opacity-60 mb-6 animate-pulse-slow">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
            <line x1="3" y1="6" x2="21" y2="6" />
            <path d="M16 10a4 4 0 0 1-8 0" />
          </svg>
        </div>

        <h2 className="text-xl font-bold mb-2">Orders Management</h2>
        <p className="text-text-secondary text-[0.9375rem] max-w-[480px] mb-8">
          This page will display and manage customer orders once the orders table migration is applied.
        </p>

        <div className="grid grid-cols-2 gap-4 max-w-[600px] w-full mb-8 max-sm:grid-cols-1">
          {[
            { icon: "📋", title: "View Orders", desc: "Browse all orders with filters by status, date, and customer." },
            { icon: "🔄", title: "Update Status", desc: "Change order status — pending, confirmed, shipped, delivered, cancelled." },
            { icon: "📊", title: "Order Analytics", desc: "Track revenue, order volume, and average order value." },
            { icon: "📦", title: "Order Details", desc: "View line items, shipping address, and payment info for each order." },
          ].map((f) => (
            <div key={f.title} className="flex gap-2 text-left p-4 bg-bg-tertiary rounded-lg border border-glass-border">
              <span className="text-xl shrink-0 mt-0.5">{f.icon}</span>
              <div>
                <strong className="text-[0.8125rem] block mb-0.5">{f.title}</strong>
                <p className="text-xs text-text-tertiary leading-snug">{f.desc}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="inline-flex items-center gap-2 px-4 py-2.5 bg-info-bg text-info rounded-lg text-[0.8125rem] font-medium">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10" />
            <line x1="12" y1="8" x2="12" y2="12" />
            <line x1="12" y1="16" x2="12.01" y2="16" />
          </svg>
          <span>Run the orders migration to enable this feature.</span>
        </div>
      </div>
    </div>
  );
}
