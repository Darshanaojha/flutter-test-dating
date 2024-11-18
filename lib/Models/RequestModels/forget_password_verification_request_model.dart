
import '../../constants.dart';

class ForgetPasswordVerificationRequest {
  String email;
   String otp;
   String password;

  ForgetPasswordVerificationRequest({
    required this.email,
    required this.otp,
    required this.password,
  });

  factory ForgetPasswordVerificationRequest.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordVerificationRequest(
      email: json['email'],
      otp: json['otp'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
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


  bool isValidPassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    return passwordPattern.hasMatch(password);
  }


  bool validate() {

    if (!isValidEmail(email)) {
      failure("Invalid Email", "Please enter a valid email address.");
      return false;
    }

   
    if (!isValidOtp(otp)) {
      failure("Invalid OTP", "OTP must be a 6-digit number.");
      return false;
    }

    if (!isValidPassword(password)) {
      failure("Invalid Password", "Password must be at least 8 characters long, containing both letters and numbers.");
      return false;
    }

    return true; 
  }
}


