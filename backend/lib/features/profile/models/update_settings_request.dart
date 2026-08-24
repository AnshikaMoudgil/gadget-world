class UpdateSettingsRequest {
  final bool? orderUpdatesSms;
  final bool? orderUpdatesEmail;
  final bool? promotionsEmail;
  final String? preferredTheme;
  final String? preferredLanguage;

  UpdateSettingsRequest({
    this.orderUpdatesSms,
    this.orderUpdatesEmail,
    this.promotionsEmail,
    this.preferredTheme,
    this.preferredLanguage,
  });

  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) {
    return UpdateSettingsRequest(
      orderUpdatesSms: json['order_updates_sms'] as bool?,
      orderUpdatesEmail: json['order_updates_email'] as bool?,
      promotionsEmail: json['promotions_email'] as bool?,
      preferredTheme: json['preferred_theme'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (orderUpdatesSms != null) {
      data['order_updates_sms'] = orderUpdatesSms;
    }
    if (orderUpdatesEmail != null) {
      data['order_updates_email'] = orderUpdatesEmail;
    }
    if (promotionsEmail != null) {
      data['promotions_email'] = promotionsEmail;
    }
    if (preferredTheme != null) {
      data['preferred_theme'] = preferredTheme;
    }
    if (preferredLanguage != null) {
      data['preferred_language'] = preferredLanguage;
    }
    return data;
  }

  String? validate() {
    if (toJson().isEmpty) return 'At least one setting is required';
    if (preferredTheme != null &&
        !{'light', 'dark', 'system'}.contains(preferredTheme)) {
      return 'preferred_theme is invalid';
    }
    if (preferredLanguage != null &&
        !RegExp(r'^[a-z]{2}(?:-[A-Z]{2})?$').hasMatch(preferredLanguage!)) {
      return 'preferred_language is invalid';
    }
    return null;
  }
}
