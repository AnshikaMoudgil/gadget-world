import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final supabase = SupabaseClient(
    env['SUPABASE_URL']!,
    env['SUPABASE_SERVICE_ROLE_KEY']!,
  );

  try {
    // 1. Get a product
    final pRes = await supabase.from('products').select('id').limit(1).single();
    final pId = pRes['id'];

    // 2. We need a user ID. Let's just create a cart for a fake user UUID.
    final userId = '00000000-0000-0000-0000-000000000000';

    print('Testing carts insert...');
    final cRes = await supabase
        .from('carts')
        .insert({'user_id': userId})
        .select()
        .single();
    final cartId = cRes['id'];
    print('Cart created: $cartId');

    print('Testing cart_items insert...');
    final iRes = await supabase
        .from('cart_items')
        .insert({'cart_id': cartId, 'product_id': pId, 'quantity': 1})
        .select()
        .single();
    print('Item inserted: $iRes');
  } catch (e) {
    print('ERROR DETAILS: $e');
  }
}
