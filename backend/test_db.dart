import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://ndfrbagekmgsunvtkxjh.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kZnJiYWdla21nc3VudnRreGpoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4Mzg0NDU5MywiZXhwIjoyMDk5NDIwNTkzfQ.22EDXEWC8BbGC0mYa-zXQQ28Zoe7KaTNem1dfF3WowA' // Service role key
      );

  final res = await supabase.from('profiles').select();
  print('Profiles: $res');
}
