import 'dart:core';

import 'package:dating_application/constants.dart';

class UpdateEmailIdRequest {
  String password;
  String newEmail;

  UpdateEmailIdRequest({
    required this.password,
    required this.newEmail,
  });

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

  bool validate() {
    try {
      validateNotEmpty(password, "Password");
      validateNotEmpty(newEmail, "New Email");

      validatePassword(password);
      validateEmail(newEmail);

      return true;
    } catch (e) {
      failure('Failed', "Validation failed: ${e.toString()}");
      print("Validation failed: ${e.toString()}");
      return false; 
    }
  }

  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      failure('Error',"$fieldName is required and cannot be empty.");
    }
  }

  void validatePassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*\(\)_\+\-=\[\]\{\};:,.<>\/?]).{8,}$');
    if (!passwordPattern.hasMatch(password)) {
      failure("Failed","Password must be at least 8 characters long, include one uppercase letter, one number, and one special character.");
    }
  }

  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      failure("Failed ","Invalid email format for field: New Email.");
    }
  }
}

