class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String mobileNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.mobileNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      mobileNumber: json['mobileNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
    };
  }
}
