import 'dart:core';
import '../../constants.dart'; 

class UpdateEmailIdRequest {
  String password;
  String newEmail;

  UpdateEmailIdRequest({
    required this.password,
    required this.newEmail,
  });

  // Factory constructor to create an instance from JSON
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
      // Validate fields individually
      validateNotEmpty(password, "Password");
      validateNotEmpty(newEmail, "New Email");

      validatePassword(password);
      validateEmail(newEmail);

      return true; // Validation passed
    } catch (e) {
      // Log or display the validation error message
      print("Validation failed: ${e.toString()}");
      return false; // Validation failed
    }
  }

  // Ensure the field is not empty
  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  // Password validation: at least 8 characters, one uppercase, one number, one special character
  void validatePassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*\(\)_\+\-=\[\]\{\};:,.<>\/?]).{8,}$');
    if (!passwordPattern.hasMatch(password)) {
      throw ArgumentError("Password must be at least 8 characters long, include one uppercase letter, one number, and one special character.");
    }
  }

  // Email validation: basic email format check
  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: New Email.");
    }
  }
}

