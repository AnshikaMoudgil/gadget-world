import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://ndfrbagekmgsunvtkxjh.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kZnJiYWdla21nc3VudnRreGpoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4Mzg0NDU5MywiZXhwIjoyMDk5NDIwNTkzfQ.22EDXEWC8BbGC0mYa-zXQQ28Zoe7KaTNem1dfF3WowA' // Service role key
      );

  try {
    await supabase.rpc('execute_sql', params: {
      'query': '''
        ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
        ALTER TABLE public.payment_items ENABLE ROW LEVEL SECURITY;
        
        DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
        CREATE POLICY "Users can view own payments"
          ON public.payments
          FOR SELECT
          TO authenticated
          USING (auth.uid() = user_id);
          
        DROP POLICY IF EXISTS "Users can view own payment items" ON public.payment_items;
        CREATE POLICY "Users can view own payment items"
          ON public.payment_items
          FOR SELECT
          TO authenticated
          USING (
            payment_id IN (
              SELECT id FROM public.payments WHERE user_id = auth.uid()
            )
          );
      '''
    });
    print("RLS applied!");
  } catch (e) {
    print(
        "RPC failed, trying raw query if possible or we might need another way: $e");
  }
}
