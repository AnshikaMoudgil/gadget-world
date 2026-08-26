-- Drop notification-related tables and functions
DROP TABLE IF EXISTS public.user_fcm_tokens CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;

DROP FUNCTION IF EXISTS public.mark_notifications_read(UUID[]);
DROP FUNCTION IF EXISTS public.mark_all_notifications_read();
DROP FUNCTION IF EXISTS public.get_unread_notification_count();

-- Also update user_settings table to drop notifications_enabled and fcm_token columns if they exist
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

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'user_settings'
        AND column_name = 'fcm_token'
    ) THEN
        ALTER TABLE public.user_settings DROP COLUMN fcm_token;
    END IF;
END $$;
