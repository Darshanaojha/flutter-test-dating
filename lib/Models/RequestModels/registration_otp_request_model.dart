
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


  factory RegistrationOTPRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String name = json['name'] ?? '';
    

    validateEmail(email);
    validateName(name);
    
    return RegistrationOTPRequest(
      email: email,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }

  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw FormatException('Email cannot be empty');
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      throw FormatException('Invalid email format');
    }
  }


  static void validateName(String name) {
    if (name.isEmpty) {
      throw FormatException('Name cannot be empty');
    }

    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(name)) {
      throw FormatException('Name can only contain alphabetic characters and spaces');
    }
  }
}

