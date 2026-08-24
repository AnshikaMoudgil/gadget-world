import '../../../core/database/supabase_db.dart';
import '../models/cart.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart_item.dart';

class CartService {
  Future<DbResult<Cart>> getCart(String userId) async {
    var cartResult = await SupabaseDb.querySingle(() => SupabaseDb.adminClient
        .from('carts')
        .select()
        .eq('user_id', userId)
        .maybeSingle());

    // The conflict-safe upsert handles concurrent first requests without
    // rewriting the cart on every read.
    if (cartResult.statusCode == 404) {
      cartResult = await SupabaseDb.querySingle(() => SupabaseDb.adminClient
          .from('carts')
          .upsert({'user_id': userId}, onConflict: 'user_id')
          .select()
          .single());
    }

    if (cartResult.isError || cartResult.data == null) {
      return DbResult.error(
        cartResult.message ?? 'Unable to load cart.',
        statusCode: cartResult.statusCode,
        errorId: cartResult.errorId,
      );
    }
    final String cartId = cartResult.data!['id'];

    // Fetch items with products and variants
    final itemsResult = await SupabaseDb.query(() => SupabaseDb.adminClient
        .from('cart_items')
        .select('*, products(*), product_variants(*)')
        .eq('cart_id', cartId)
        .order('created_at', ascending: true));

    if (itemsResult.isError) {
      return DbResult.error(
        itemsResult.message!,
        statusCode: itemsResult.statusCode,
        errorId: itemsResult.errorId,
      );
    }

    final items = (itemsResult.data as List<dynamic>)
        .map((e) => CartItem.fromJson(e))
        .toList();

    return DbResult.success(Cart(id: cartId, userId: userId, items: items));
  }

  Future<DbResult<Cart>> addToCart(
      String userId, AddToCartRequest request) async {
    final result = await SupabaseDb.execute(
      () => SupabaseDb.adminClient.rpc('add_cart_item', params: {
        'p_user_id': userId,
        'p_product_id': request.productId,
        'p_variant_id': request.variantId,
        'p_quantity': request.quantity,
      }),
    );
    if (result.isError) {
      return DbResult.error(
        result.message!,
        statusCode: result.statusCode,
        errorId: result.errorId,
      );
    }

    // Return the updated cart
    return getCart(userId);
  }

  Future<DbResult<Cart>> updateCartItemQuantity(
      String userId, String cartItemId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(userId, cartItemId);
    }

    final updateResult = await SupabaseDb.execute(
      () => SupabaseDb.adminClient.rpc('set_cart_item_quantity', params: {
        'p_user_id': userId,
        'p_cart_item_id': cartItemId,
        'p_quantity': quantity,
      }),
    );

    if (updateResult.isError) {
      return DbResult.error(
        updateResult.message!,
        statusCode: updateResult.statusCode,
        errorId: updateResult.errorId,
      );
    }

    return getCart(userId);
  }

  Future<DbResult<Cart>> removeFromCart(
      String userId, String cartItemId) async {
    final deleteResult = await SupabaseDb.execute(
      () => SupabaseDb.adminClient.rpc('remove_cart_item', params: {
        'p_user_id': userId,
        'p_cart_item_id': cartItemId,
      }),
    );

    if (deleteResult.isError) {
      return DbResult.error(
        deleteResult.message!,
        statusCode: deleteResult.statusCode,
        errorId: deleteResult.errorId,
      );
    }

    return getCart(userId);
  }
}
