class Coupon {
  final String id;
  final String code;
  final String discountType; // 'percentage', 'fixed_amount', 'free_shipping'
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscountAmount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimitPerUser;
  final int? totalUsageLimit;
  final int timesUsed;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscountAmount,
    this.validFrom,
    this.validUntil,
    this.usageLimitPerUser,
    this.totalUsageLimit,
    required this.timesUsed,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderValue: (json['min_order_value'] as num).toDouble(),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : null,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      usageLimitPerUser: json['usage_limit_per_user'] as int?,
      totalUsageLimit: json['total_usage_limit'] as int?,
      timesUsed: json['times_used'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_value': minOrderValue,
      'max_discount_amount': maxDiscountAmount,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'usage_limit_per_user': usageLimitPerUser,
      'total_usage_limit': totalUsageLimit,
      'times_used': timesUsed,
      'is_active': isActive,
    };
  }
}
