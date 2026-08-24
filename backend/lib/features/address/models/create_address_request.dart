import 'address.dart';

/// Request DTO for creating a new user address.
///
/// Contains only the mutable, client-supplied fields — no `id`, `userId`,
/// or timestamps (those are set by the server / DB).
class CreateAddressRequest {
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

  CreateAddressRequest({
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
  });

  /// Parse from a JSON request body (snake_case keys).
  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) {
    return CreateAddressRequest(
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
    );
  }

  /// Serialize to a map suitable for a Supabase INSERT.
  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  /// Basic validation. Returns a list of error messages (empty = valid).
  List<String> validate() {
    final errors = <String>[];
    if (recipientName.trim().isEmpty) {
      errors.add('recipient_name is required');
    } else if (recipientName.length > 100) {
      errors.add('recipient_name cannot exceed 100 characters');
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phoneNumber.trim())) {
      errors.add('phone_number must contain 10 to 15 digits');
    }
    if (addressLine1.trim().isEmpty) {
      errors.add('address_line1 is required');
    } else if (addressLine1.length > 200) {
      errors.add('address_line1 cannot exceed 200 characters');
    }
    if (addressLine2 != null && addressLine2!.length > 200) {
      errors.add('address_line2 cannot exceed 200 characters');
    }
    if (landmark != null && landmark!.length > 200) {
      errors.add('landmark cannot exceed 200 characters');
    }
    if (city.trim().isEmpty || city.length > 100) {
      errors.add('city must contain 1 to 100 characters');
    }
    if (state.trim().isEmpty || state.length > 100) {
      errors.add('state must contain 1 to 100 characters');
    }
    if (country.trim().isEmpty || country.length > 100) {
      errors.add('country must contain 1 to 100 characters');
    }
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(postalCode)) {
      errors.add('postal_code must be a valid 6-digit Indian PIN code');
    }
    return errors;
  }
}
