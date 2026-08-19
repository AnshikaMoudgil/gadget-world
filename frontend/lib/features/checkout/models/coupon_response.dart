class CouponResponse {
  final bool valid;
  final double discountAmount;
  final String? discountType;
  final Map<String, dynamic>? couponData;
  final String message;

  CouponResponse({
    required this.valid,
    required this.discountAmount,
    this.discountType,
    this.couponData,
    required this.message,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      valid: json['valid'] as bool? ?? false,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String?,
      couponData: json['coupon'] as Map<String, dynamic>?,
      message: json['message'] as String? ?? '',
    );
  }
}
