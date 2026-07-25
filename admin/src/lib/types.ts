/* ------------------------------------------------------------------ */
/*  Shared TypeScript types matching the Supabase schema               */
/* ------------------------------------------------------------------ */

export interface Profile {
  id: string;
  full_name: string | null;
  email: string | null;
  phone_number: string | null;
  date_of_birth: string | null;
  role: "customer" | "admin" | "superadmin";
  is_suspended: boolean;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  image_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Brand {
  id: string;
  name: string;
  slug: string;
  logo_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Product {
  id: string;
  slug: string;
  name: string;
  brand_id: string | null;
  category_id: string | null;
  description: string | null;
  about_points: string[];
  images: string[];
  price: number;
  mrp: number | null;
  stock_quantity: number;
  is_active: boolean;
  is_featured: boolean;
  created_at: string;
  updated_at: string;
  // Joined fields
  brand?: Brand;
  category?: Category;
}

export interface ProductSpec {
  id: string;
  product_id: string;
  spec_key: string;
  spec_value: string;
  display_order: number;
}

export interface ProductFeature {
  id: string;
  product_id: string;
  type: "highlight" | "compatibility";
  title: string;
  description: string;
  icon: string;
  display_order: number;
  created_at: string;
}

export interface VariantGroup {
  id: string;
  product_id: string;
  group_name: string;
  display_order: number;
  options?: VariantOption[];
}

export interface VariantOption {
  id: string;
  group_id: string;
  value: string;
  display_order: number;
}

export interface ProductVariant {
  id: string;
  product_id: string;
  sku: string | null;
  variant_name: string;
  price: number | null;
  images: string[];
  stock_quantity: number;
  display_order: number;
  created_at: string;
}

export interface Order {
  id: string;
  user_id: string;
  shipping_address_id: string | null;
  order_number: string;
  status: "pending_payment" | "pending" | "confirmed" | "processing" | "shipped" | "out_for_delivery" | "delivered" | "return_requested" | "returned" | "cancelled";
  payment_status: "unpaid" | "processing" | "paid" | "failed" | "refunded";
  payment_method: "cod" | "razorpay" | "bank_transfer" | "upi";
  total_amount: number;
  subtotal: number;
  shipping_fee: number;
  tax_amount: number;
  notes: string | null;
  created_at: string;
  updated_at: string;
  profile?: Profile;
  items?: OrderItem[];
  payment?: Payment;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  variant_id: string | null;
  product_name: string;
  variant_name: string | null;
  quantity: number;
  unit_price: number;
  total_price: number;
  created_at: string;
}

export interface Payment {
  id: string;
  order_id: string;
  provider: string;
  razorpay_payment_id: string | null;
  razorpay_order_id: string | null;
  razorpay_signature: string | null;
  amount: number;
  currency: string;
  status: "created" | "authorized" | "captured" | "failed" | "refunded";
  raw_response: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface AdminAuditLog {
  id: string;
  actor_id: string | null;
  action: string;
  section: string;
  details: Record<string, unknown> | null;
  created_at: string;
}

export interface DashboardStats {
  totalProducts: number;
  totalCategories: number;
  totalBrands: number;
  totalUsers: number;
  totalOrders: number;
  activeProducts: number;
}

export interface SupportTicket {
  id: string;
  user_id: string;
  order_id: string | null;
  ticket_number: string;
  subject: string;
  category: "general" | "order_issue" | "payment" | "delivery" | "return_refund" | "product" | "account" | "other";
  status: "open" | "in_progress" | "waiting_customer" | "resolved" | "closed";
  priority: "low" | "medium" | "high" | "urgent";
  assigned_to: string | null;
  resolved_at: string | null;
  created_at: string;
  updated_at: string;
  profile?: Profile;
  messages?: SupportMessage[];
}

export interface SupportMessage {
  id: string;
  ticket_id: string;
  sender_id: string;
  sender_role: "customer" | "admin";
  message: string;
  attachments: Record<string, unknown>[];
  is_internal: boolean;
  created_at: string;
  sender?: Profile;
}

export interface AppNotification {
  id: string;
  user_id: string;
  title: string;
  body: string;
  type: "order_update" | "payment" | "promotion" | "support" | "system" | "delivery";
  reference_type: string | null;
  reference_id: string | null;
  image_url: string | null;
  is_read: boolean;
  read_at: string | null;
  created_at: string;
  user_email?: string;
}
