class ForgetPasswordRequest {
  final String email;
  final String newPassword;

  ForgetPasswordRequest({
    required this.email,
    required this.newPassword,
  }) {

    if (!_isValidEmail(email)) {
      throw ArgumentError("Invalid email format.");
    }
    if (!_isValidPassword(newPassword)) {
      throw ArgumentError("Password does not meet required criteria.");
    }
  }

  factory ForgetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordRequest(
      email: json['email'],
      newPassword: json['new_password'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_password': newPassword,
    };
  }


  bool _isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordPattern.hasMatch(password);
  }
}
