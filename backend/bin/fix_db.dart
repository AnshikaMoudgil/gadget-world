import 'package:postgres/postgres.dart';

void main() async {
  try {
    final conn = await Connection.open(
      Endpoint(
        host: 'db.ndfrbagekmgsunvtkxjh.supabase.co',
        database: 'postgres',
        username: 'postgres',
        password: r'Gadgets@1207$32',
        port: 5432,
      ),
      settings: ConnectionSettings(sslMode: SslMode.require),
    );

    print('Connected to Postgres!');

    await conn.execute(
        'ALTER TABLE public.user_addresses ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT false;');
    print('Added is_deleted column to user_addresses.');

    await conn.close();
    print('Done.');
  } catch (e) {
    print('Error: $e');
  }
}
