import 'dart:core';

class UpdateEmailIdRequest {
  final String password;
  final String newEmail;

  UpdateEmailIdRequest({
    required this.password,
    required this.newEmail,
  }) {

    validateNotEmpty(password, "Password");
    validatePassword(password);
   validateNotEmpty(newEmail, "New Email");
    validateEmail(newEmail);
  }


  factory UpdateEmailIdRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEmailIdRequest(
      password: json['password'],
      newEmail: json['new_email'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'new_email': newEmail,
    };
  }

  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }


  void validatePassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*\(\)_\+\-=\[\]\{\};:,.<>\/?]).{8,}$');
    if (!passwordPattern.hasMatch(password)) {
      throw ArgumentError("Password must be at least 8 characters long, and include one uppercase letter, one number, and one special character.");
    }
  }


  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: New Email.");
    }
  }
}
