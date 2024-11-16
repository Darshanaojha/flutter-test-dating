import 'dart:core';

class RegistrationOtpVerificationRequest {
  final String email;
  final String otp;

  RegistrationOtpVerificationRequest({
    required this.email,
    required this.otp,
  }) {
 
    validateEmail(email);
    validateOtp(otp);
  }

  factory RegistrationOtpVerificationRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String otp = json['otp'] ?? '';

    validateEmail(email);
    validateOtp(otp);
    
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

  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw FormatException('Email cannot be empty');
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      throw FormatException('Invalid email format');
    }
  }


  static void validateOtp(String otp) {
    if (otp.isEmpty) {
      throw FormatException('OTP cannot be empty');
    }

    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(otp)) {
      throw FormatException('OTP must be a 6-digit number');
    }
  }
}
