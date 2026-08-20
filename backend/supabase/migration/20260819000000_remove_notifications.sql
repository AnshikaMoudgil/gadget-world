-- Drop notification-related tables and functions
DROP TABLE IF EXISTS public.user_fcm_tokens CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;

DROP FUNCTION IF EXISTS public.mark_notifications_read(UUID[]);
DROP FUNCTION IF EXISTS public.mark_all_notifications_read();

-- Also update user_settings table to drop notifications_enabled column if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'user_settings'
        AND column_name = 'notifications_enabled'
    ) THEN
        ALTER TABLE public.user_settings DROP COLUMN notifications_enabled;
    END IF;
END $$;
