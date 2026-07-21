import 'package:postgres/postgres.dart';

void main() async {
  var connection = PostgreSQLConnection(
    'db.ndfrbagekmgsunvtkxjh.supabase.co',
    5432,
    'postgres',
    username: 'postgres',
    password: 'Gadgets@1207\$32',
    useSSL: true,
  );

  await connection.open();

  await connection.query('''
    ALTER TABLE public.payments DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.payment_items DISABLE ROW LEVEL SECURITY;
  ''');

  print("RLS Disabled for payments and payment_items!");

  await connection.close();
}
