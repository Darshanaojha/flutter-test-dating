import '../../constants.dart';

class RegistrationOTPRequest {
  String email;
  String name;
  String mobile;
  String referalcode;

  RegistrationOTPRequest({
    required this.email,
    required this.name,
    required this.mobile,
    required this.referalcode,
  });

  factory RegistrationOTPRequest.fromJson(Map<String, dynamic> json) {
    String email = json['email'] ?? '';
    String name = json['name'] ?? '';
    String mobile = json['mobile'] ?? '';
    String referalcode = json['referal_code'] ?? '';
    return RegistrationOTPRequest(
        email: email, name: name, mobile: mobile, referalcode: referalcode);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'mobile': mobile,
      'referal_code': referalcode,
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
    String? referalcodeerror = validateReferalCode(referalcode);
    if (referalcodeerror == null) {
      failure("Invalid Referal Code",
          "Referral code must be exactly 6 alphanumeric characters");
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

  static String? validateReferalCode(String referalcode) {
    if (referalcode.isNotEmpty ||
        !RegExp(r'^[a-zA-Z0-9]{6}$').hasMatch(referalcode)) {
      return 'Referral code must be exactly 6 alphanumeric characterssss';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      failure('Name', 'Please enter your name');
      return 'Please enter your name';
    }

    // Convert to lowercase first
    value = value.toLowerCase();

    // Regex: only alphabets, numbers, and underscore
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      failure('RE-Enter',
          'Must contain only letters and underscore (no spaces or special characters)');
      return 'Must contain only letter and underscore';
    }

    return null;
  }
}
