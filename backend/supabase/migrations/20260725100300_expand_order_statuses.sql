-- =========================================================================
-- Expand Orders Status CHECK Constraint
-- =========================================================================
-- Add out_for_delivery, return_requested, and returned to allowed statuses.
-- =========================================================================

ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE public.orders ADD CONSTRAINT orders_status_check
  CHECK (status IN (
    'pending_payment', 'pending', 'confirmed', 'processing',
    'shipped', 'out_for_delivery', 'delivered',
    'return_requested', 'returned', 'cancelled'
  ));
