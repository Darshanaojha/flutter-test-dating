
import '../../constants.dart';  // For snackbar error handling

class UpdateEmailVerificationRequest {
  String newEmail;
   String otp;

  UpdateEmailVerificationRequest({
    required this.newEmail,
    required this.otp,
  });

  // Factory constructor to create UpdateEmailVerificationRequest from JSON
  factory UpdateEmailVerificationRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEmailVerificationRequest(
      newEmail: json['new_email'],
      otp: json['otp'],
    );
  }

  // Method to convert UpdateEmailVerificationRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
      'otp': otp,
    };
  }

  // Validate email format
  bool isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  // Validate OTP (must be exactly 6 digits)
  bool isValidOtp(String otp) {
    final otpPattern = RegExp(r'^\d{6}$');
    return otpPattern.hasMatch(otp);
  }

  // Validate the entire request (email and OTP)
  bool validate() {
    // Validate email
    if (!isValidEmail(newEmail)) {
      failure("Invalid Email", "Please enter a valid email address.");
      return false;
    }

    // Validate OTP
    if (!isValidOtp(otp)) {
      failure("Invalid OTP", "OTP must be a 6-digit number.");
      return false;
    }

    return true;  // All validations passed
  }


}

