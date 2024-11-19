import 'dart:core';
import '../../constants.dart'; 

class UpdateEmailIdRequest {
 String password;
  String newEmail;

  UpdateEmailIdRequest({
    required this.password,
    required this.newEmail,
  });

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

  // Centralized validate method that checks all fields
  bool validate() {
    try {
      // Validate password
      validatePassword(password);

      // Validate email
      validateEmail(newEmail);

      // Validate non-empty fields
      validateNotEmpty(password, "Password");
      validateNotEmpty(newEmail, "New Email");

      return true; // All validations passed
    } catch (e) {
      // Show snackbar on validation failure
      failure("Validation Error", e.toString());
      return false;  // Validation failed
    }
  }

  // Validation for non-empty fields
  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  // Password validation
  void validatePassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*\(\)_\+\-=\[\]\{\};:,.<>\/?]).{8,}$');
    if (!passwordPattern.hasMatch(password)) {
      throw ArgumentError("Password must be at least 8 characters long, and include one uppercase letter, one number, and one special character.");
    }
  }

  // Email validation
  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: New Email.");
    }
  }


}
