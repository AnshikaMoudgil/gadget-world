class UserSettings {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final bool orderUpdatesSms;
  final bool orderUpdatesEmail;
  final bool promotionsEmail;
  final String preferredTheme;
  final String preferredLanguage;

  UserSettings({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
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
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      orderUpdatesSms: json['order_updates_sms'] as bool? ?? true,
      orderUpdatesEmail: json['order_updates_email'] as bool? ?? true,
      promotionsEmail: json['promotions_email'] as bool? ?? false,
      preferredTheme: json['preferred_theme'] as String? ?? 'system',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
    );
  }
}
