import 'package:supabase/supabase.dart';
import 'dart:convert';

void main() async {
  final supabase = SupabaseClient('https://ndfrbagekmgsunvtkxjh.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kZnJiYWdla21nc3VudnRreGpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4NDQ1OTMsImV4cCI6MjA5OTQyMDU5M30.6iXF9m9oEwtN4h8V1t1s3R9b9w8-xY4M-4K-4V4H6bQ' // anon key
      );

  try {
    // Authenticate as a user (I need user credentials)
    // Actually, I can just check if payments is public
    final res = await supabase.from('payments').select().limit(1);
    print("Payments with anon: $res");
  } catch (e) {
    print("Error with anon key: $e");
  }
}
