import 'address.dart';

/// Request DTO for partially updating an existing address.
///
/// Every field is optional — only non-null values are sent to the DB.
class UpdateAddressRequest {
  final String? recipientName;
  final String? phoneNumber;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final AddressType? addressType;
  final bool? isDefault;

  UpdateAddressRequest({
    this.recipientName,
    this.phoneNumber,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.addressType,
    this.isDefault,
  });

  /// Parse from a JSON request body (snake_case keys).
  factory UpdateAddressRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAddressRequest(
      recipientName: json['recipient_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      addressType: json.containsKey('address_type')
          ? AddressType.fromString(json['address_type'] as String?)
          : null,
      isDefault: json['is_default'] as bool?,
    );
  }

  /// Serialize to a map containing only the fields that were set.
  /// Suitable for a Supabase partial UPDATE.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (recipientName != null) data['recipient_name'] = recipientName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (addressLine1 != null) data['address_line1'] = addressLine1;
    if (addressLine2 != null) data['address_line2'] = addressLine2;
    if (landmark != null) data['landmark'] = landmark;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (postalCode != null) data['postal_code'] = postalCode;
    if (country != null) data['country'] = country;
    if (addressType != null) data['address_type'] = addressType!.name;
    if (isDefault != null) data['is_default'] = isDefault;
    return data;
  }

  /// Returns true when no fields were provided (nothing to update).
  bool get isEmpty => toJson().isEmpty;

  /// Basic validation on the fields that *are* provided.
  /// Returns a list of error messages (empty = valid).
  List<String> validate() {
    final errors = <String>[];
    if (recipientName != null && recipientName!.trim().isEmpty) {
      errors.add('recipient_name cannot be blank');
    }
    if (phoneNumber != null && phoneNumber!.trim().isEmpty) {
      errors.add('phone_number cannot be blank');
    }
    if (addressLine1 != null && addressLine1!.trim().isEmpty) {
      errors.add('address_line1 cannot be blank');
    }
    if (city != null && city!.trim().isEmpty) {
      errors.add('city cannot be blank');
    }
    if (state != null && state!.trim().isEmpty) {
      errors.add('state cannot be blank');
    }
    if (postalCode != null &&
        !RegExp(r'^[1-9][0-9]{5}$').hasMatch(postalCode!)) {
      errors.add('postal_code must be a valid 6-digit Indian PIN code');
    }
    return errors;
  }
}
