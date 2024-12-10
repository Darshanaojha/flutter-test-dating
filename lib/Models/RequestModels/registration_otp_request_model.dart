import '../../constants.dart';

class RegistrationOTPRequest {
  String email;
  String name;
  String mobile;

  RegistrationOTPRequest({
    required this.email,
    required this.name,
    required this.mobile,
  });

  factory RegistrationOTPRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String name = json['name'] ?? '';
    String mobile = json['mobile']?? '';
    return RegistrationOTPRequest(email: email, name: name, mobile: mobile);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'mobile':mobile,
    };
  }

  bool validate() {
    // Validate email
    String? emailError = validateEmail(email);
    if (emailError != null) {
      failure("Invalid Email", emailError);
      return false;
    }

    // Validate name
    String? nameError = validateName(name);
    if (nameError != null) {
      failure("Invalid Name", nameError);
      return false;
    }

    return true; // All validations passed
  }

  // Email validation method
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      return 'Invalid email format';
    }

    return null; // Valid email
  }

  // Name validation method
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }

    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(name)) {
      return 'Name can only contain alphabetic characters and spaces';
    }

    return null;
  }
}
