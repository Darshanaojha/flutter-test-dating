import 'dart:core';

class UpdateEmailVerificationRequest {
  final String newEmail;
  final String otp;

  UpdateEmailVerificationRequest({
    required this.newEmail,
    required this.otp,
  }) {
    if (newEmail.isEmpty) {
      throw ArgumentError("new_email cannot be empty.");
    }
    if (!isValidEmail(newEmail)) {
      throw ArgumentError("new_email is not in a valid email format.");
    }
    if (otp.isEmpty) {
      throw ArgumentError("otp cannot be empty.");
    }
    if (!isValidOtp(otp)) {
      throw ArgumentError("otp must be a 6-digit number.");
    }
  }

  factory UpdateEmailVerificationRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEmailVerificationRequest(
      newEmail: json['new_email'],
      otp: json['otp'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
      'otp': otp,
    };
  }

  bool isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  bool isValidOtp(String otp) {
    final otpPattern = RegExp(r'^\d{6}$');
    return otpPattern.hasMatch(otp);
  }
}
