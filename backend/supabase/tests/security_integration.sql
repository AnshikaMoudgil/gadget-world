\set ON_ERROR_STOP on

DO $$
BEGIN
  IF has_function_privilege(
    'anon',
    'public.confirm_order_payment(uuid,text,text,text,numeric,uuid)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'anon can execute confirm_order_payment';
  END IF;

  IF has_function_privilege(
    'authenticated',
    'public.confirm_order_payment(uuid,text,text,text,numeric,uuid)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'authenticated can execute confirm_order_payment';
  END IF;

  IF NOT has_function_privilege(
    'service_role',
    'public.confirm_order_payment(uuid,text,text,text,numeric,uuid)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'service_role cannot execute confirm_order_payment';
  END IF;

  IF has_function_privilege(
    'authenticated',
    'public.create_razorpay_checkout(uuid,uuid,uuid,text,text,numeric,text)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'authenticated can execute create_razorpay_checkout';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'orders'
      AND column_name = 'checkout_cart_id'
  ) THEN
    RAISE EXCEPTION 'orders.checkout_cart_id is missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'guard_profile_role_change' AND NOT tgisinternal
  ) THEN
    RAISE EXCEPTION 'profile role-change guard trigger is missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'webhook_logs'
      AND c.relrowsecurity AND c.relforcerowsecurity
  ) THEN
    RAISE EXCEPTION 'webhook_logs RLS is not enabled and forced';
  END IF;

  IF has_table_privilege('authenticated', 'public.webhook_logs', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated can select webhook_logs';
  END IF;

  IF has_function_privilege(
    'authenticated',
    'public.get_or_create_user_settings(uuid)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'authenticated can initialize settings through service RPC';
  END IF;
END
$$;

SELECT 'database security integration assertions passed' AS result;
