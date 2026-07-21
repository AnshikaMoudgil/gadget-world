import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/database/supabase_db.dart';
import '../../../core/config/env.dart';
import '../../cart/services/cart_service.dart';
import 'razorpay_service.dart';

class PaymentService {
  final CartService _cartService = CartService();
  final RazorpayService _razorpayService = RazorpayService();

  Future<Map<String, dynamic>> createOrder(String userId) async {
    // 1. Fetch user's cart
    final cartResult = await _cartService.getCart(userId);
    if (cartResult.isError) {
      throw Exception('Failed to load cart: ${cartResult.message}');
    }

    final cart = cartResult.data!;
    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    // 2. Calculate total amount in subunits (paise for INR)
    double totalAmount = 0;
    for (var item in cart.items) {
      final product = item.product;
      if (product == null) continue;

      final price = (product['price'] as num).toDouble();
      totalAmount += price * item.quantity;
    }

    if (totalAmount <= 0) {
      throw Exception('Invalid total amount');
    }

    final int amountSubunits = (totalAmount * 100).round();
    final String currency = 'INR';

    // 3. Create Razorpay order
    // receipt length must be <= 40
    final cartIdPart = cart.id.length > 8 ? cart.id.substring(0, 8) : cart.id;
    final receipt = 'c_${cartIdPart}_${DateTime.now().millisecondsSinceEpoch}';

    final razorpayOrder = await _razorpayService.createOrder(
      amountSubunits: amountSubunits,
      currency: currency,
      receipt: receipt,
    );

    final razorpayOrderId = razorpayOrder['id'] as String;

    // 4. Insert into database
    final paymentInsertResult =
        await SupabaseDb.querySingle(() => SupabaseDb.adminClient
            .from('payments')
            .insert({
              'user_id': userId,
              'razorpay_order_id': razorpayOrderId,
              'status': 'pending',
              'amount_subunits': amountSubunits,
              'currency': currency,
            })
            .select()
            .single());

    if (paymentInsertResult.isError) {
      throw Exception('Failed to save payment: ${paymentInsertResult.message}');
    }

    final paymentId = paymentInsertResult.data!['id'];

    // 5. Insert payment items
    for (var item in cart.items) {
      if (item.product == null) continue;
      final price = (item.product!['price'] as num).toDouble();

      await SupabaseDb.querySingle(() => SupabaseDb.adminClient
          .from('payment_items')
          .insert({
            'payment_id': paymentId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'amount_subunits': (price * 100).round(),
          })
          .select()
          .single());
    }

    // Return the response for frontend to initialize Razorpay SDK
    return {
      'orderId': razorpayOrderId,
      'amount': amountSubunits,
      'currency': currency,
      'keyId': Env.getOr('RAZORPAY_KEY_ID', 'rzp_test_mock'),
    };
  }

  Future<void> verifyPayment({
    required String userId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final keySecret = Env.getOr('RAZORPAY_KEY_SECRET', 'mock_secret');

    // 1. Generate signature
    final body = '$razorpayOrderId|$razorpayPaymentId';
    final hmac = Hmac(sha256, utf8.encode(keySecret));
    final digest = hmac.convert(utf8.encode(body));
    final expectedSignature = digest.toString();

    // 2. Compare signatures
    if (expectedSignature != razorpaySignature) {
      throw Exception('Invalid payment signature');
    }

    // 3. Update payment status
    final updateResult =
        await SupabaseDb.querySingle(() => SupabaseDb.adminClient
            .from('payments')
            .update({'status': 'completed'})
            .eq('razorpay_order_id', razorpayOrderId)
            .eq('user_id', userId) // ensure user owns the payment
            .select()
            .single());

    if (updateResult.isError || updateResult.data == null) {
      throw Exception('Failed to update payment status or payment not found.');
    }

    // 4. Fulfillment: Clear the user's cart
    await SupabaseDb.execute(() =>
        SupabaseDb.adminClient.from('carts').delete().eq('user_id', userId));
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final result = await SupabaseDb.query(
        () => SupabaseDb.adminClient.from('payments').select('''
          *,
          payment_items (*, products(*))
        ''').eq('user_id', userId).order('created_at', ascending: false));

    if (result.isError) {
      throw Exception('Failed to fetch orders: ${result.message}');
    }

    return List<Map<String, dynamic>>.from(result.data as List);
  }

  Future<void> processWebhook(String signature, String body) async {
    final webhookSecret = Env.getOr('RAZORPAY_WEBHOOK_SECRET', 'mock_secret');
    
    // 1. Verify signature
    final hmac = Hmac(sha256, utf8.encode(webhookSecret));
    final digest = hmac.convert(utf8.encode(body));
    if (digest.toString() != signature) {
      throw Exception('Invalid webhook signature');
    }

    // 2. Parse payload
    final payload = jsonDecode(body) as Map<String, dynamic>;
    final event = payload['event'] as String?;
    
    // 3. Log webhook
    try {
      await SupabaseDb.execute(() => SupabaseDb.adminClient
          .from('webhook_logs')
          .insert({'payload': payload, 'event': event}));
    } catch (e) {
      print('Failed to log webhook: $e');
    }

    // 4. Process payment.captured event
    if (event == 'payment.captured') {
      final paymentEntity = payload['payload']?['payment']?['entity'];
      if (paymentEntity != null) {
        final razorpayOrderId = paymentEntity['order_id'] as String?;
        if (razorpayOrderId != null) {
          // Look up payment and update if pending
          final paymentResult = await SupabaseDb.querySingle(() =>
              SupabaseDb.adminClient
                  .from('payments')
                  .select()
                  .eq('razorpay_order_id', razorpayOrderId)
                  .single());
                  
          if (!paymentResult.isError && paymentResult.data != null) {
            if (paymentResult.data!['status'] == 'pending') {
               await SupabaseDb.execute(() => SupabaseDb.adminClient
                  .from('payments')
                  .update({'status': 'completed'})
                  .eq('razorpay_order_id', razorpayOrderId));
               
               // Clear cart for the user
               final userId = paymentResult.data!['user_id'];
               await SupabaseDb.execute(() => SupabaseDb.adminClient
                  .from('carts')
                  .delete()
                  .eq('user_id', userId));
            }
          }
        }
      }
    }
  }
}
