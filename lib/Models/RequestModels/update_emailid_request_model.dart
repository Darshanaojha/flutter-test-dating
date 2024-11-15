import 'dart:core';

class UpdateEmailIdRequest {
  final String password;
  final String newEmail;

  UpdateEmailIdRequest({
    required this.password,
    required this.newEmail,
  }) {
    // Perform validations
    validateNotEmpty(password, "Password");
    validatePassword(password);
   validateNotEmpty(newEmail, "New Email");
    validateEmail(newEmail);
  }

  // Factory constructor to create UpdateEmailIdRequest from JSON
  factory UpdateEmailIdRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEmailIdRequest(
      password: json['password'],
      newEmail: json['new_email'],
    );
  }

  // Method to convert UpdateEmailIdRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'new_email': newEmail,
    };
  }

  // Helper function to validate that a field is not empty
  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  // Helper function to validate password (example validation)
  void validatePassword(String password) {
    // Password should be at least 8 characters long, contain at least one uppercase letter,
    // one lowercase letter, one number, and one special character
    final passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*\(\)_\+\-=\[\]\{\};:,.<>\/?]).{8,}$');
    if (!passwordPattern.hasMatch(password)) {
      throw ArgumentError("Password must be at least 8 characters long, and include one uppercase letter, one number, and one special character.");
    }
  }

  // Helper function to validate email format
  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: New Email.");
    }
  }
}
