
import 'dart:core';

class RegistrationOTPRequest {
  final String email;
  final String name;

  RegistrationOTPRequest({
    required this.email,
    required this.name,
  }) {
 
    validateEmail(email);
    validateName(name);
  }

  // Factory constructor to create OTPRequest from JSON
  factory RegistrationOTPRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String name = json['name'] ?? '';
    
    // Validate the fields before returning the object
    validateEmail(email);
    validateName(name);
    
    return RegistrationOTPRequest(
      email: email,
      name: name,
    );
  }

  // Method to convert OTPRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }

  // Validate email format
  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw FormatException('Email cannot be empty');
    }
    // Basic email validation check (you can improve with regex if necessary)
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      throw FormatException('Invalid email format');
    }
  }

  // Validate name (non-empty, alphabetic only)
  static void validateName(String name) {
    if (name.isEmpty) {
      throw FormatException('Name cannot be empty');
    }
    // Simple name validation (can be enhanced further)
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(name)) {
      throw FormatException('Name can only contain alphabetic characters and spaces');
    }
  }
}

