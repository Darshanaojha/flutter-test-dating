

import '../../constants.dart';

class ForgetPasswordRequest {
  String email;
  String newPassword;

  ForgetPasswordRequest({
    required this.email,
    required this.newPassword,
  });

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

  bool isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordPattern.hasMatch(password);
  }

  bool validate() {
    if (!isValidEmail(email)) {
      failure("Invalid Email", "Please enter a valid email address.");
      return false;
    }

    if (!isValidPassword(newPassword)) {
      failure("Invalid Password", "Password must contain at least one uppercase letter, one number, and one special character.");
      return false;
    }

    return true; 
  }
}



