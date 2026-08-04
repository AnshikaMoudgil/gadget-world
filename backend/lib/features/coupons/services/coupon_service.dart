import '../../../core/database/supabase_db.dart';
import '../models/coupon.dart';

class CouponService {
  /// Validates a coupon code and calculates the discount for a given cart total.
  Future<Map<String, dynamic>> validateCoupon(
      String code, double cartTotal, String userId) async {
    // 1. Fetch the coupon
    final couponResult = await SupabaseDb.querySingle(() => SupabaseDb
        .adminClient
        .from('coupons')
        .select()
        .eq('code', code.toUpperCase())
        .maybeSingle());

    if (couponResult.isError || couponResult.data == null) {
      return {'valid': false, 'message': 'Invalid coupon code.'};
    }

    final coupon = Coupon.fromJson(couponResult.data!);

    // 2. Basic validations
    if (!coupon.isActive) {
      return {'valid': false, 'message': 'This coupon is no longer active.'};
    }

    final now = DateTime.now();
    if (coupon.validFrom != null && now.isBefore(coupon.validFrom!)) {
      return {'valid': false, 'message': 'This coupon is not yet valid.'};
    }

    if (coupon.validUntil != null && now.isAfter(coupon.validUntil!)) {
      return {'valid': false, 'message': 'This coupon has expired.'};
    }

    if (cartTotal < coupon.minOrderValue) {
      return {
        'valid': false,
        'message':
            'Minimum order value of ₹${coupon.minOrderValue} required for this coupon.'
      };
    }

    if (coupon.totalUsageLimit != null &&
        coupon.timesUsed >= coupon.totalUsageLimit!) {
      return {'valid': false, 'message': 'Coupon usage limit reached.'};
    }

    // 3. User usage limit validation
    if (coupon.usageLimitPerUser != null) {
      final usageResult = await SupabaseDb.query(() => SupabaseDb.adminClient
          .from('user_coupons')
          .select('id')
          .eq('coupon_id', coupon.id)
          .eq('user_id', userId));

      if (usageResult.isError) {
        return {'valid': false, 'message': 'Failed to validate coupon usage.'};
      }

      final usageCount = (usageResult.data as List).length;
      if (usageCount >= coupon.usageLimitPerUser!) {
        return {
          'valid': false,
          'message': 'You have reached the usage limit for this coupon.'
        };
      }
    }

    // 4. Calculate Discount
    double discountAmount = 0;

    switch (coupon.discountType) {
      case 'percentage':
        discountAmount = (cartTotal * coupon.discountValue) / 100;
        if (coupon.maxDiscountAmount != null &&
            discountAmount > coupon.maxDiscountAmount!) {
          discountAmount = coupon.maxDiscountAmount!;
        }
        break;
      case 'fixed_amount':
        discountAmount = coupon.discountValue;
        if (discountAmount > cartTotal) {
          discountAmount = cartTotal; // Prevent negative totals
        }
        break;
      case 'free_shipping':
        // The frontend will handle zeroing the shipping fee if discount type is free_shipping.
        // We set discountAmount to 0 for subtotal, but it effectively removes shipping.
        discountAmount = 0;
        break;
      default:
        return {'valid': false, 'message': 'Invalid discount type.'};
    }

    return {
      'valid': true,
      'discount_amount': discountAmount,
      'discount_type': coupon.discountType,
      'coupon': coupon.toJson(),
      'message': 'Coupon applied successfully!'
    };
  }

  /// Records a coupon usage and updates times_used
  Future<void> recordCouponUsage(
      String couponId, String userId, String orderId) async {
    await SupabaseDb.execute(() => SupabaseDb.adminClient
        .from('user_coupons')
        .insert(
            {'user_id': userId, 'coupon_id': couponId, 'order_id': orderId}));

    await SupabaseDb.execute(() => SupabaseDb.adminClient.rpc(
        'increment_coupon_usage', // We can either create an RPC or just update. Let's do a direct fetch and update, or an RPC.
        // Alternatively, since we use Dart Admin Client, we can just read and write or use Supabase functions.
        // Let's do a direct update. It might have race conditions, but for this scale it's acceptable.
        // Actually, we can use a raw sql or just an RPC. Let's do a simple read/write.
        params: {'c_id': couponId}));
  }

  /// Simpler increment using Dart
  Future<void> incrementUsage(String couponId) async {
    final couponResult = await SupabaseDb.querySingle(() => SupabaseDb
        .adminClient
        .from('coupons')
        .select('times_used')
        .eq('id', couponId)
        .single());

    if (!couponResult.isError) {
      final current = couponResult.data!['times_used'] as int;
      await SupabaseDb.execute(() => SupabaseDb.adminClient
          .from('coupons')
          .update({'times_used': current + 1}).eq('id', couponId));
    }
  }
}
