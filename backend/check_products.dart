import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final supabase = SupabaseClient(
    env['SUPABASE_URL']!,
    env['SUPABASE_ANON_KEY']!,
  );

  try {
    // 1. Get a product
    final pRes = await supabase.from('products').select('id').limit(1).single();
    final pId = pRes['id'];

    // 2. Get a user
    final uRes = await supabase.auth.signUp(
        password: 'password123',
        email: 'test${DateTime.now().millisecondsSinceEpoch}@test.com');
    final userId = uRes.user!.id;

    // 3. Create cart
    final cRes = await supabase
        .from('carts')
        .insert({'user_id': userId})
        .select('id')
        .single();
    final cartId = cRes['id'];

    // 4. Insert item and fetch with join
    final iRes = await supabase
        .from('cart_items')
        .insert({'cart_id': cartId, 'product_id': pId, 'quantity': 1})
        .select('*, products(*), product_variants(*)')
        .single();

    print('INSERT SUCCESS:');
    print(iRes);
  } catch (e) {
    print('INSERT ERROR: $e');
  }
}
