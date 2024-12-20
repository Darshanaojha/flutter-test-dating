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
    String mobile = json['mobile'] ?? '';
    return RegistrationOTPRequest(email: email, name: name, mobile: mobile);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'mobile': mobile,
    };
  }

  bool validate() {
    String? emailError = validateEmail(email);
    if (emailError != null) {
      failure("Invalid Email", emailError);
      return false;
    }

    String? nameError = validateName(name);
    if (nameError != null) {
      failure("Invalid Name", nameError);
      return false;
    }

    return true;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      failure("Error", "Email cannot be empty");
      return 'Email cannot be empty';
    }
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) {
      failure("Error", "Invalid email format");
      return 'Invalid email format';
    }

    return null;
  }

  static String? validateName(String name) {
    if (name.isEmpty) {
      failure("Error", "Name cannot be empty");
      return 'Name cannot be empty';
    }

    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(name)) {
      failure(
          'Error', 'Name can only contain alphabetic characters and spaces');
      return 'Name can only contain alphabetic characters and spaces';
    }

    return null;
  }
}
