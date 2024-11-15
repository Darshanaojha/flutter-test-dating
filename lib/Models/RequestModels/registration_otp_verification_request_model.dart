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

  // Factory constructor to create OtpVerificationRequest from JSON
  factory RegistrationOtpVerificationRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String otp = json['otp'] ?? '';
    
    // Validate fields before creating the object
    validateEmail(email);
    validateOtp(otp);
    
    return RegistrationOtpVerificationRequest(
      email: email,
      otp: otp,
    );
  }

  // Method to convert OtpVerificationRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
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

  // Validate OTP (assumes OTP is a 6-digit number, but you can adjust length as needed)
  static void validateOtp(String otp) {
    if (otp.isEmpty) {
      throw FormatException('OTP cannot be empty');
    }
    // Ensure OTP is a 6-digit number (you can adjust this as needed)
    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(otp)) {
      throw FormatException('OTP must be a 6-digit number');
    }
  }
}
