import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/database/supabase_db.dart';
import '../../../core/config/env.dart';
import '../../cart/services/cart_service.dart';
import 'razorpay_service.dart';

class PaymentService {
  final CartService _cartService = CartService();
  final RazorpayService _razorpayService = RazorpayService();

  Future<Map<String, dynamic>> createOrder(
    String userId, {
    String? addressId,
    double shippingFee = 0.0,
    double discount = 0.0,
  }) async {
    // 1. Fetch user's cart
    final cartResult = await _cartService.getCart(userId);
    if (cartResult.isError) {
      throw Exception('Failed to load cart: ${cartResult.message}');
    }

    final cart = cartResult.data!;
    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    // 2. Calculate total amount
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
    final cartIdPart = cart.id.length > 8 ? cart.id.substring(0, 8) : cart.id;
    final receipt = 'c_${cartIdPart}_${DateTime.now().millisecondsSinceEpoch}';

    final razorpayOrder = await _razorpayService.createOrder(
      amountSubunits: amountSubunits,
      currency: currency,
      receipt: receipt,
    );

    final razorpayOrderId = razorpayOrder['id'] as String;

    // 4. Create Order record in public.orders
    final orderInsertResult =
        await SupabaseDb.querySingle(() => SupabaseDb.adminClient
            .from('orders')
            .insert({
              'user_id': userId,
              'status': 'pending_payment',
              'payment_status': 'unpaid',
              'payment_method': 'razorpay',
              'total_amount': totalAmount + shippingFee - discount,
              'subtotal': totalAmount,
              if (addressId != null) 'address_id': addressId,
              'shipping_fee': shippingFee,
              'discount': discount,
            })
            .select()
            .single());

    if (orderInsertResult.isError) {
      throw Exception('Failed to create order: ${orderInsertResult.message}');
    }

    final String orderId = orderInsertResult.data!['id'];

    // 5. Insert order items into public.order_items
    for (var item in cart.items) {
      if (item.product == null) continue;
      final price = (item.product!['price'] as num).toDouble();
      final productName = item.product!['name'] as String? ?? 'Product';

      await SupabaseDb.querySingle(
          () => SupabaseDb.adminClient.from('order_items').insert({
                'order_id': orderId,
                'product_id': item.productId,
                'variant_id': item.variantId,
                'product_name': productName,
                'quantity': item.quantity,
                'unit_price': price,
                'total_price': price * item.quantity,
              }));
    }

    // 6. Insert payment row into public.payments
    final paymentInsertResult =
        await SupabaseDb.querySingle(() => SupabaseDb.adminClient
            .from('payments')
            .insert({
              'order_id': orderId,
              'provider': 'razorpay',
              'razorpay_order_id': razorpayOrderId,
              'amount': totalAmount + shippingFee - discount,
              'currency': currency,
              'status': 'created',
            })
            .select()
            .single());

    if (paymentInsertResult.isError) {
      throw Exception('Failed to save payment: ${paymentInsertResult.message}');
    }

    return {
      'orderId': razorpayOrderId,
      'amount': amountSubunits,
      'currency': currency,
      'keyId': Env.getOrNull('RAZORPAY_KEY_ID') ??
          Env.getOr('RAZORPAY_KEY_ID_A', 'rzp_test_mock'),
    };
  }

  Future<void> verifyPayment({
    required String userId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final keySecret = Env.getOrNull('RAZORPAY_KEY_SECRET') ??
        Env.get('RAZORPAY_KEY_SECRET_A');

    // 1. Verify Razorpay signature
    final body = '$razorpayOrderId|$razorpayPaymentId';
    final hmac = Hmac(sha256, utf8.encode(keySecret));
    final digest = hmac.convert(utf8.encode(body));
    final expectedSignature = digest.toString();

    if (expectedSignature != razorpaySignature) {
      throw Exception('Invalid payment signature');
    }

    // 2. Fetch payment record to find order_id
    final paymentRes = await SupabaseDb.querySingle(() => SupabaseDb.adminClient
        .from('payments')
        .select()
        .eq('razorpay_order_id', razorpayOrderId)
        .maybeSingle());

    if (paymentRes.isError || paymentRes.data == null) {
      throw Exception('Payment not found for order: $razorpayOrderId');
    }

    final String orderId = paymentRes.data!['order_id'];
    final double amount = (paymentRes.data!['amount'] as num).toDouble();

    // 3. Call confirm_order_payment RPC or update orders/payments directly
    final rpcResult = await SupabaseDb.execute(() => SupabaseDb.adminClient.rpc(
          'confirm_order_payment',
          params: {
            'p_order_id': orderId,
            'p_razorpay_payment_id': razorpayPaymentId,
            'p_razorpay_order_id': razorpayOrderId,
            'p_razorpay_signature': razorpaySignature,
            'p_amount': amount,
          },
        ));

    if (rpcResult.isError) {
      await SupabaseDb.adminClient.from('payments').update({
        'status': 'captured',
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      }).eq('razorpay_order_id', razorpayOrderId);

      await SupabaseDb.adminClient.from('orders').update(
          {'status': 'confirmed', 'payment_status': 'paid'}).eq('id', orderId);
    }

    // 4. Clear cart for user
    final cartRes = await SupabaseDb.adminClient
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (cartRes != null && cartRes['id'] != null) {
      await SupabaseDb.adminClient
          .from('cart_items')
          .delete()
          .eq('cart_id', cartRes['id']);
    }
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final result = await SupabaseDb.query(
        () => SupabaseDb.adminClient.from('orders').select('''
          *,
          order_items (*, products(*)),
          payments (*),
          user_addresses!orders_address_id_fkey (*)
        ''').eq('user_id', userId).order('created_at', ascending: false));

    if (result.isError) {
      throw Exception('Failed to fetch orders: ${result.message}');
    }

    return List<Map<String, dynamic>>.from(result.data as List);
  }

  Future<void> processWebhook(String signature, String body) async {
    final webhookSecret = Env.getOr('RAZORPAY_WEBHOOK_SECRET', 'mock_secret');

    if (webhookSecret != 'mock_secret') {
      final hmac = Hmac(sha256, utf8.encode(webhookSecret));
      final digest = hmac.convert(utf8.encode(body));
      if (digest.toString() != signature) {
        throw Exception('Invalid webhook signature');
      }
    }

    final payload = jsonDecode(body) as Map<String, dynamic>;
    final event = payload['event'] as String?;

    try {
      await SupabaseDb.execute(() => SupabaseDb.adminClient
          .from('webhook_logs')
          .insert({'payload': payload, 'event_type': event ?? 'unknown'}));
    } catch (_) {}

    if (event == 'payment.captured') {
      final paymentEntity = payload['payload']?['payment']?['entity'];
      if (paymentEntity != null) {
        final razorpayOrderId = paymentEntity['order_id'] as String?;
        final razorpayPaymentId = paymentEntity['id'] as String?;
        if (razorpayOrderId != null) {
          final paymentResult = await SupabaseDb.querySingle(() => SupabaseDb
              .adminClient
              .from('payments')
              .select()
              .eq('razorpay_order_id', razorpayOrderId)
              .maybeSingle());

          if (!paymentResult.isError && paymentResult.data != null) {
            final orderId = paymentResult.data!['order_id'];
            final amount = (paymentResult.data!['amount'] as num).toDouble();
            await SupabaseDb.adminClient.rpc('confirm_order_payment', params: {
              'p_order_id': orderId,
              'p_razorpay_payment_id': razorpayPaymentId ?? '',
              'p_razorpay_order_id': razorpayOrderId,
              'p_razorpay_signature': 'webhook',
              'p_amount': amount,
            });
          }
        }
      }
    }
  }
}
