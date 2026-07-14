/// The type of a saved address.
enum AddressType {
  home,
  work,
  other;

  /// Parse a DB / JSON string into an [AddressType].
  /// Falls back to [AddressType.other] for unknown values.
  static AddressType fromString(String? value) {
    switch (value) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      case 'other':
        return AddressType.other;
      default:
        return AddressType.other;
    }
  }
}

/// Dart representation of a row in the `public.user_addresses` table.
class Address {
  final String? id;
  final String userId;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final AddressType addressType;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.id,
    required this.userId,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.addressType = AddressType.home,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Construct an [Address] from a Supabase row (snake_case keys).
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      recipientName: json['recipient_name'] as String,
      phoneNumber: json['phone_number'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: (json['country'] as String?) ?? 'India',
      addressType: AddressType.fromString(json['address_type'] as String?),
      isDefault: (json['is_default'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Serialize to a JSON map (snake_case keys matching the DB columns).
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'recipient_name': recipientName,
      'phone_number': phoneNumber,
      'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (landmark != null) 'landmark': landmark,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'address_type': addressType.name,
      'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Returns a copy of this address with the given fields replaced.
  Address copyWith({
    String? id,
    String? userId,
    String? recipientName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    AddressType? addressType,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
