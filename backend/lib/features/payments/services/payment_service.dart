import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/database/supabase_db.dart';
import '../../../core/config/env.dart';
import '../../cart/services/cart_service.dart';
import '../../coupons/services/coupon_service.dart';
import 'razorpay_service.dart';

class PaymentService {
  final CartService _cartService = CartService();
  final RazorpayService _razorpayService = RazorpayService();
  final CouponService _couponService = CouponService();

  Future<Map<String, dynamic>> createOrder(
    String userId, {
    String? addressId,
    String? couponCode,
  }) async {
    if (addressId == null || addressId.isEmpty) {
      throw Exception('A shipping address is required');
    }

    // Preflight the checkout to avoid creating a Razorpay order for an obviously
    // invalid cart. The database RPC repeats all validations under row locks.
    final cartResult = await _cartService.getCart(userId);
    if (cartResult.isError) {
      throw Exception('Failed to load cart: ${cartResult.message}');
    }

    final cart = cartResult.data!;
    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final requestedCouponCode = couponCode == null || couponCode.trim().isEmpty
        ? null
        : couponCode.trim().toUpperCase();

    // Avoid creating another provider order for a sequential retry. The atomic
    // checkout RPC enforces the same rule under a cart-row lock for races.
    final activeCheckout = await SupabaseDb.querySingle(() => SupabaseDb
        .adminClient
        .from('orders')
        .select('''
          id,
          shipping_address_id,
          coupon_code,
          payments!inner(razorpay_order_id, amount, currency, status)
        ''')
        .eq('checkout_cart_id', cart.id)
        .inFilter('status', ['pending_payment', 'pending'])
        .gt('stock_reservation_expires_at',
            DateTime.now().toUtc().toIso8601String())
        .limit(1)
        .maybeSingle());
    if (!activeCheckout.isError && activeCheckout.data != null) {
      final existingAddressId =
          activeCheckout.data!['shipping_address_id'] as String?;
      final existingCouponCode =
          (activeCheckout.data!['coupon_code'] as String?)?.toUpperCase();
      final checkoutInputsMatch = existingAddressId == addressId &&
          existingCouponCode == requestedCouponCode;
      final existingPayments =
          activeCheckout.data!['payments'] as List<dynamic>? ?? const [];
      final existingPayment = existingPayments
          .whereType<Map<String, dynamic>>()
          .where((payment) => payment['status'] == 'created')
          .firstOrNull;
      final existingProviderOrderId =
          existingPayment?['razorpay_order_id'] as String?;
      final existingAmount = existingPayment?['amount'] as num?;
      if (checkoutInputsMatch &&
          existingProviderOrderId != null &&
          existingAmount != null) {
        return {
          'orderId': existingProviderOrderId,
          'amount': (existingAmount.toDouble() * 100).round(),
          'currency': existingPayment?['currency'] as String? ?? 'INR',
          'keyId': Env.getOrNull('RAZORPAY_KEY_ID') ??
              Env.getOr('RAZORPAY_KEY_ID_A', 'rzp_test_mock'),
          'reused': true,
        };
      }

      // Address/coupon changes must never reuse a provider order created from
      // older checkout inputs. Cancelling also releases its stock and coupon
      // reservation through the database status-change trigger.
      final cancelled = await SupabaseDb.execute(() => SupabaseDb.adminClient
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', activeCheckout.data!['id'])
          .eq('user_id', userId)
          .inFilter('status', ['pending_payment', 'pending']));
      if (cancelled.isError) {
        throw Exception(
            'Unable to replace the previous checkout: ${cancelled.message}');
      }
    }
    if (activeCheckout.isError && activeCheckout.statusCode != 404) {
      throw Exception(
          'Failed to check for an active checkout: ${activeCheckout.message}');
    }

    double subtotal = 0;
    for (var item in cart.items) {
      final product = item.product;
      if (product == null || product['is_active'] != true) {
        throw Exception('Cart contains an unavailable product');
      }

      if (item.quantity <= 0) {
        throw Exception('Cart contains an invalid quantity');
      }

      num price;
      if (item.variantId != null) {
        final variant = item.variant;
        if (variant == null ||
            variant['id'] != item.variantId ||
            variant['product_id'] != item.productId) {
          throw Exception('Cart contains an invalid product variant');
        }
        if ((variant['stock_quantity'] as num? ?? 0) < item.quantity) {
          throw Exception('Insufficient stock for ${product['name']}');
        }
        price = variant['price'] as num? ?? product['price'] as num;
      } else {
        if ((product['stock_quantity'] as num? ?? 0) < item.quantity) {
          throw Exception('Insufficient stock for ${product['name']}');
        }
        price = product['price'] as num;
      }

      subtotal += price.toDouble() * item.quantity;
    }

    if (subtotal <= 0) {
      throw Exception('Invalid total amount');
    }

    double shippingFee = subtotal > 50000 ? 0.0 : 299.0;
    double discount = 0.0;
    String? validCouponCode;

    if (requestedCouponCode != null) {
      final couponRes = await _couponService.validateCoupon(
          requestedCouponCode, subtotal, userId);
      if (couponRes['valid'] == true) {
        discount = (couponRes['discount_amount'] as num).toDouble();
        validCouponCode = requestedCouponCode;
        if (couponRes['coupon'] != null) {
          if (couponRes['coupon']['discount_type'] == 'free_shipping') {
            shippingFee = 0.0;
          }
        }
      }
    }

    final double finalAmount = subtotal + shippingFee - discount;

    final int amountSubunits = (finalAmount * 100).round();
    final String currency = 'INR';

    final cartIdPart = cart.id.length > 8 ? cart.id.substring(0, 8) : cart.id;
    final receipt = 'c_${cartIdPart}_${DateTime.now().millisecondsSinceEpoch}';

    final razorpayOrder = await _razorpayService.createOrder(
      amountSubunits: amountSubunits,
      currency: currency,
      receipt: receipt,
    );

    final razorpayOrderId = razorpayOrder['id'] as String;

    // The RPC re-reads and locks the cart/catalog/address, recalculates the
    // totals, creates all checkout records, and reserves stock atomically.
    final checkoutResult = await SupabaseDb.querySingle<Map<String, dynamic>>(
        () async => Map<String, dynamic>.from(await SupabaseDb.adminClient
                .rpc('create_razorpay_checkout', params: {
              'p_user_id': userId,
              'p_cart_id': cart.id,
              'p_address_id': addressId,
              'p_razorpay_order_id': razorpayOrderId,
              'p_currency': currency,
              'p_expected_amount': finalAmount,
              'p_coupon_code': validCouponCode,
            }) as Map));

    if (checkoutResult.isError || checkoutResult.data == null) {
      throw Exception(
          'Failed to create checkout securely: ${checkoutResult.message}');
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

    // 2. Fetch payment record to find order_id and ensure ownership
    final paymentRes = await SupabaseDb.querySingle(() => SupabaseDb.adminClient
        .from('payments')
        .select('*, orders!inner(user_id)')
        .eq('razorpay_order_id', razorpayOrderId)
        .eq('orders.user_id', userId)
        .maybeSingle());

    if (paymentRes.isError || paymentRes.data == null) {
      throw Exception('Payment not found for order: $razorpayOrderId');
    }

    final String orderId = paymentRes.data!['order_id'];
    final double amount = (paymentRes.data!['amount'] as num).toDouble();
    final String currency = paymentRes.data!['currency'] as String? ?? 'INR';

    // 3. Verify the payment state with Razorpay. A valid checkout signature only
    // proves the IDs came from Razorpay; it does not prove the payment was
    // captured (for example, when manual capture is enabled).
    var providerPayment =
        await _razorpayService.fetchPayment(razorpayPaymentId);
    if (providerPayment['id'] != razorpayPaymentId ||
        providerPayment['order_id'] != razorpayOrderId) {
      throw Exception('Razorpay payment does not match the supplied payment');
    }

    final providerAmount = providerPayment['amount'];
    final expectedAmountSubunits = (amount * 100).round();
    if (providerAmount is! num ||
        providerAmount.toInt() != expectedAmountSubunits) {
      throw Exception('Razorpay payment amount mismatch');
    }

    if (providerPayment['currency'] != currency) {
      throw Exception('Razorpay payment currency mismatch');
    }

    // Razorpay can invoke the client success callback while a payment is only
    // authorized, particularly when manual capture is enabled. Capture it on
    // the trusted server only after all identity and amount checks above pass.
    if (providerPayment['status'] == 'authorized') {
      providerPayment = await _razorpayService.capturePayment(
        paymentId: razorpayPaymentId,
        amountSubunits: expectedAmountSubunits,
        currency: currency,
      );
    }

    // Auto-capture can also take a moment to become visible through the fetch
    // endpoint. Retry briefly without ever treating a non-captured state as
    // paid.
    for (var attempt = 0;
        providerPayment['status'] != 'captured' && attempt < 3;
        attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      providerPayment = await _razorpayService.fetchPayment(razorpayPaymentId);
    }

    if (providerPayment['status'] != 'captured') {
      throw Exception(
          'Razorpay payment is not captured (status: ${providerPayment['status'] ?? 'unknown'})');
    }

    // 4. Confirm the payment atomically in the database.
    final rpcResult = await SupabaseDb.execute(() => SupabaseDb.adminClient.rpc(
          'confirm_order_payment',
          params: {
            'p_order_id': orderId,
            'p_razorpay_payment_id': razorpayPaymentId,
            'p_razorpay_order_id': razorpayOrderId,
            'p_razorpay_signature': razorpaySignature,
            'p_amount': amount,
            'p_user_id': userId,
          },
        ));

    if (rpcResult.isError) {
      throw Exception(
          'Payment confirmation failed securely: ${rpcResult.message}');
    }

    // 5. Clear cart for user
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
          id,
          order_number,
          status,
          payment_status,
          payment_method,
          total_amount,
          subtotal,
          shipping_fee,
          tax_amount,
          discount_amount,
          coupon_code,
          shipping_address_snapshot,
          shipped_at,
          delivered_at,
          created_at,
          updated_at,
          order_items (
            id,
            product_id,
            variant_id,
            product_name,
            variant_name,
            quantity,
            unit_price,
            total_price,
            products (id, slug, name, images)
          ),
          payments (razorpay_order_id, status, amount, currency, created_at),
          user_addresses!orders_shipping_address_id_fkey (
            id,
            recipient_name,
            phone_number,
            address_line1,
            address_line2,
            landmark,
            city,
            state,
            postal_code,
            country,
            address_type
          )
        ''').eq('user_id', userId).order('created_at', ascending: false));

    if (result.isError) {
      throw Exception('Failed to fetch orders: ${result.message}');
    }

    return List<Map<String, dynamic>>.from(result.data as List);
  }

  Future<void> processWebhook(
      String eventId, String signature, String body) async {
    final webhookSecret = Env.getOrNull('RAZORPAY_WEBHOOK_SECRET');

    if (webhookSecret == null) {
      throw Exception('RAZORPAY_WEBHOOK_SECRET is missing. Webhooks disabled.');
    }

    final hmac = Hmac(sha256, utf8.encode(webhookSecret));
    final digest = hmac.convert(utf8.encode(body));
    if (digest.toString() != signature) {
      throw Exception('Invalid webhook signature');
    }
    final payload = jsonDecode(body) as Map<String, dynamic>;
    final event = payload['event'] as String?;
    final eventPayload = payload['payload'];
    final paymentEntity = eventPayload is Map<String, dynamic>
        ? eventPayload['payment'] is Map<String, dynamic>
            ? (eventPayload['payment'] as Map<String, dynamic>)['entity']
            : null
        : null;
    final paymentAudit = paymentEntity is Map<String, dynamic>
        ? (<String, dynamic>{
            'payment_id': paymentEntity['id'],
            'order_id': paymentEntity['order_id'],
            'status': paymentEntity['status'],
            'amount': paymentEntity['amount'],
            'currency': paymentEntity['currency'],
          }..removeWhere((_, value) => value == null))
        : <String, dynamic>{};

    final claim = await SupabaseDb.querySingle<bool>(() async =>
        await SupabaseDb.adminClient.rpc('claim_razorpay_webhook', params: {
          'p_event_id': eventId,
          'p_event_type': event ?? 'unknown',
          // Store only identifiers and payment-state metadata required for an
          // audit trail. Never persist the raw provider/customer payload.
          'p_payload': paymentAudit,
        }) as bool);
    if (claim.isError) {
      throw Exception('Unable to claim webhook event: ${claim.message}');
    }
    if (claim.data != true) return;

    try {
      if (event == 'payment.captured') {
        if (paymentEntity is! Map<String, dynamic>) {
          throw Exception('Captured webhook is missing payment details');
        }

        final razorpayOrderId = paymentEntity['order_id'] as String?;
        final razorpayPaymentId = paymentEntity['id'] as String?;
        final razorpayAmount = paymentEntity['amount'] as num?;
        if (razorpayOrderId == null ||
            razorpayOrderId.isEmpty ||
            razorpayPaymentId == null ||
            razorpayPaymentId.isEmpty ||
            razorpayAmount == null) {
          throw Exception('Captured webhook has invalid payment details');
        }

        final paymentResult = await SupabaseDb.querySingle(() => SupabaseDb
            .adminClient
            .from('payments')
            .select()
            .eq('razorpay_order_id', razorpayOrderId)
            .maybeSingle());

        if (paymentResult.isError || paymentResult.data == null) {
          throw Exception('Webhook payment does not match a known order');
        }

        final orderId = paymentResult.data!['order_id'];
        final amount = (paymentResult.data!['amount'] as num).toDouble();
        if (razorpayAmount.toInt() != (amount * 100).round()) {
          throw Exception('Webhook payment amount mismatch');
        }

        final rpcResult = await SupabaseDb.execute(
            () => SupabaseDb.adminClient.rpc('confirm_order_payment', params: {
                  'p_order_id': orderId,
                  'p_razorpay_payment_id': razorpayPaymentId,
                  'p_razorpay_order_id': razorpayOrderId,
                  'p_razorpay_signature': 'webhook',
                  'p_amount': amount,
                }));

        if (rpcResult.isError) {
          throw Exception(
              'Webhook payment confirmation failed: ${rpcResult.message}');
        }
      }
      final completed = await SupabaseDb.execute(() => SupabaseDb.adminClient
          .rpc('complete_razorpay_webhook', params: {'p_event_id': eventId}));
      if (completed.isError) {
        throw Exception(
            'Unable to complete webhook event: ${completed.message}');
      }
    } catch (_) {
      await SupabaseDb.execute(() => SupabaseDb.adminClient
          .rpc('release_razorpay_webhook', params: {'p_event_id': eventId}));
      rethrow;
    }
  }
}
