import 'dart:core';

import '../../constants.dart';

class RegistrationOtpVerificationRequest {
  String email;
  String otp;

  RegistrationOtpVerificationRequest({
    required this.email,
    required this.otp,
  });

  factory RegistrationOtpVerificationRequest.fromJson(
      Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String otp = json['otp'] ?? '';

    return RegistrationOtpVerificationRequest(
      email: email,
      otp: otp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  bool validate() {

    if (email.isEmpty) {

      failure("Invalid Email", "Email cannot be empty.");
      return false;
    }

    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      failure("Invalid Email", "Invalid email format.");
      return false;
    }

    // Validate OTP
    if (otp.isEmpty) {
      // Show custom error using snackbar
      failure("Invalid OTP", "OTP cannot be empty.");
      return false;
    }

    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(otp)) {
      failure("Invalid OTP", "OTP must be a 6-digit number.");
      return false;
    }

    // If both validations pass, return true
    return true;
  }
}
