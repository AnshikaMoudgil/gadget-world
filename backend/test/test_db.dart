import 'package:backend/core/config/env.dart';
import 'package:backend/core/database/supabase_db.dart';

void main() {
  Env.load();
  SupabaseDb.init();

  SupabaseDb.querySingle(
          () => SupabaseDb.adminClient.from('user_addresses').select().limit(1))
      .then((res) => print('SUCCESS: \${res.data}'))
      .catchError((e) => print('ERROR: \$e'));
}
