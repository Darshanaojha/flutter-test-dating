class ForgetPasswordVerificationRequest {
  final String email;
  final String otp;
  final String password;

  ForgetPasswordVerificationRequest({
    required this.email,
    required this.otp,
    required this.password,
  }) {

    if (!_isValidEmail(email)) {
      throw ArgumentError("Invalid email format.");
    }
    if (otp.isEmpty) {
      throw ArgumentError("OTP is required.");
    }
    if (password.isEmpty) {
      throw ArgumentError("Password is required.");
    }
    if (!_isValidPassword(password)) {
      throw ArgumentError("Password must contain at least 8 characters, including upper/lowercase and numbers.");
    }
  }

  factory ForgetPasswordVerificationRequest.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordVerificationRequest(
      email: json['email'],
      otp: json['otp'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
    };
  }
  bool _isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    return passwordPattern.hasMatch(password);
  }
}
