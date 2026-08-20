class UserSettings {
  final String id;
  final String userId;
  final bool orderUpdatesSms;
  final bool orderUpdatesEmail;
  final bool promotionsEmail;
  final String preferredTheme;
  final String preferredLanguage;

  UserSettings({
    required this.id,
    required this.userId,
    required this.orderUpdatesSms,
    required this.orderUpdatesEmail,
    required this.promotionsEmail,
    required this.preferredTheme,
    required this.preferredLanguage,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderUpdatesSms: json['order_updates_sms'] as bool? ?? true,
      orderUpdatesEmail: json['order_updates_email'] as bool? ?? true,
      promotionsEmail: json['promotions_email'] as bool? ?? false,
      preferredTheme: json['preferred_theme'] as String? ?? 'system',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_updates_sms': orderUpdatesSms,
      'order_updates_email': orderUpdatesEmail,
      'promotions_email': promotionsEmail,
      'preferred_theme': preferredTheme,
      'preferred_language': preferredLanguage,
    };
  }
}
