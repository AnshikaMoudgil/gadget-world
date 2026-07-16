import '../../../core/database/supabase_db.dart';
import '../models/cart.dart';
import '../models/add_to_cart_request.dart';
import '../models/cart_item.dart';

class CartService {
  Future<DbResult<Cart>> getCart(String userId) async {
    // Check if cart exists
    var cartResult = await SupabaseDb.querySingle(() =>
        SupabaseDb.adminClient.from('carts').select().eq('user_id', userId).maybeSingle());
    
    if (cartResult.isError && cartResult.statusCode != 404) {
      return DbResult.error(cartResult.message!);
    }

    String cartId;
    if (cartResult.data == null) {
      // Create cart
      final createResult = await SupabaseDb.querySingle(() =>
          SupabaseDb.adminClient.from('carts').insert({'user_id': userId}).select().single());
      
      if (createResult.isError) return DbResult.error(createResult.message!);
      cartId = createResult.data!['id'];
    } else {
      cartId = cartResult.data!['id'];
    }

    // Fetch items with products and variants
    final itemsResult = await SupabaseDb.query(() =>
        SupabaseDb.adminClient
            .from('cart_items')
            .select('*, products(*), product_variants(*)')
            .eq('cart_id', cartId));

    if (itemsResult.isError) return DbResult.error(itemsResult.message!);

    final items = (itemsResult.data as List<dynamic>)
        .map((e) => CartItem.fromJson(e))
        .toList();

    return DbResult.success(Cart(id: cartId, userId: userId, items: items));
  }

  Future<DbResult<Cart>> addToCart(String userId, AddToCartRequest request) async {
    // 1. Get or create cart to ensure we have a cartId
    final cartResult = await getCart(userId);
    if (cartResult.isError) return cartResult;
    
    final cart = cartResult.data!;
    
    // 2. Check if item exists
    final existingItem = cart.items.where((i) => 
        i.productId == request.productId && i.variantId == request.variantId).firstOrNull;

    if (existingItem != null) {
      // Update quantity
      final updateResult = await SupabaseDb.querySingle(() =>
          SupabaseDb.adminClient
              .from('cart_items')
              .update({'quantity': existingItem.quantity + request.quantity})
              .eq('id', existingItem.id)
              .select()
              .single());
      if (updateResult.isError) return DbResult.error(updateResult.message!);
    } else {
      // Insert new
      final insertData = {
        'cart_id': cart.id,
        'product_id': request.productId,
        'quantity': request.quantity,
      };
      if (request.variantId != null) {
        insertData['variant_id'] = request.variantId!;
      }

      final insertResult = await SupabaseDb.querySingle(() =>
          SupabaseDb.adminClient
              .from('cart_items')
              .insert(insertData)
              .select()
              .single());
      if (insertResult.isError) return DbResult.error(insertResult.message!);
    }

    // Return the updated cart
    return getCart(userId);
  }

  Future<DbResult<Cart>> updateCartItemQuantity(String userId, String cartItemId, int quantity) async {
    // Verify ownership
    final cartResult = await getCart(userId);
    if (cartResult.isError) return cartResult;

    final cart = cartResult.data!;
    if (!cart.items.any((i) => i.id == cartItemId)) {
      return DbResult.error('Item not found in cart', statusCode: 404);
    }

    if (quantity <= 0) {
      return removeFromCart(userId, cartItemId);
    }

    final updateResult = await SupabaseDb.querySingle(() =>
        SupabaseDb.adminClient
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('id', cartItemId)
            .select()
            .single());

    if (updateResult.isError) return DbResult.error(updateResult.message!);

    return getCart(userId);
  }

  Future<DbResult<Cart>> removeFromCart(String userId, String cartItemId) async {
    final cartResult = await getCart(userId);
    if (cartResult.isError) return cartResult;

    final cart = cartResult.data!;
    if (!cart.items.any((i) => i.id == cartItemId)) {
      return DbResult.error('Item not found in cart', statusCode: 404);
    }

    final deleteResult = await SupabaseDb.execute(() =>
        SupabaseDb.adminClient.from('cart_items').delete().eq('id', cartItemId));

    if (deleteResult.isError) return DbResult.error(deleteResult.message!);

    return getCart(userId);
  }
}
