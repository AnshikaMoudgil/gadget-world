class Profile {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? businessName;
  final String? gstin;
  final String? businessType;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.businessName,
    this.gstin,
    this.businessType,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
      businessName: json['business_name'] as String?,
      gstin: json['gstin'] as String?,
      businessType: json['business_type'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (businessName != null) 'business_name': businessName,
      if (gstin != null) 'gstin': gstin,
      if (businessType != null) 'business_type': businessType,
    };
  }

  Profile copyWith({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? businessName,
    String? gstin,
    String? businessType,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      businessName: businessName ?? this.businessName,
      gstin: gstin ?? this.gstin,
      businessType: businessType ?? this.businessType,
      createdAt: createdAt,
    );
  }
}
