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
  status: string;
  total: number;
  items_count: number;
  created_at: string;
  updated_at: string;
  profile?: Profile;
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
