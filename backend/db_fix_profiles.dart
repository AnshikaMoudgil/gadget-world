import 'package:postgres/postgres.dart';

void main() async {
  // postgres 3.x syntax
  final connection = await Connection.open(
    Endpoint(
      host: 'db.ndfrbagekmgsunvtkxjh.supabase.co',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: 'Gadgets@1207\$32',
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.require,
    ),
  );

  await connection.execute('''
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
  ''');

  print("RLS applied for profiles with UPDATE policy!");

  await connection.close();
}
