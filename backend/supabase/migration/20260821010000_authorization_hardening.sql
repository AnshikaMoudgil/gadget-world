-- Enforce privileged-field boundaries in the database. UI checks are only a
-- convenience and must not be the security boundary.

CREATE OR REPLACE FUNCTION public.guard_profile_role_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  -- Trusted backend maintenance uses the service-role key.
  IF auth.role() IS DISTINCT FROM 'service_role' AND
     NEW.role IS DISTINCT FROM OLD.role THEN
    IF auth.uid() = OLD.id THEN
      RAISE EXCEPTION 'Users cannot change their own role';
    END IF;
    IF NOT public.is_superadmin() THEN
      RAISE EXCEPTION 'Only an existing superadmin can change roles';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS guard_profile_role_change ON public.profiles;
CREATE TRIGGER guard_profile_role_change
  BEFORE UPDATE OF role ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_profile_role_change();

-- Customers communicate by inserting support_messages. Direct ticket updates
-- are removed so workflow, priority, assignment, and resolution remain
-- administrator-controlled.
DROP POLICY IF EXISTS "Users update own support tickets"
  ON public.support_tickets;

-- Message insertion still needs to update the ticket timestamp. Run only that
-- fixed update as the function owner instead of granting broad row updates.
CREATE OR REPLACE FUNCTION public.handle_support_message_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  UPDATE public.support_tickets
  SET updated_at = NOW()
  WHERE id = NEW.ticket_id;
  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_support_message_insert()
  FROM PUBLIC, anon, authenticated;
