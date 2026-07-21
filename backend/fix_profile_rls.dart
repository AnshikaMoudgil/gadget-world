import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://ndfrbagekmgsunvtkxjh.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kZnJiYWdla21nc3VudnRreGpoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4Mzg0NDU5MywiZXhwIjoyMDk5NDIwNTkzfQ.22EDXEWC8BbGC0mYa-zXQQ28Zoe7KaTNem1dfF3WowA' // Service role key
      );

  try {
    await supabase.rpc('execute_sql', params: {
      'query': '''
        ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
        
        DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
        CREATE POLICY "Users can view own profile"
          ON public.profiles
          FOR SELECT
          TO authenticated
          USING (auth.uid() = id);
          
        DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
        CREATE POLICY "Users can update own profile"
          ON public.profiles
          FOR UPDATE
          TO authenticated
          USING (auth.uid() = id);
      '''
    });
    print("RLS applied for profiles!");
  } catch (e) {
    print("RPC failed: \$e");
  }
}
