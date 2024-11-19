import '../../constants.dart';

class ChangePasswordRequest {
   String oldPassword;
  String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      oldPassword: json['old_password'],
      newPassword: json['new_password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }

  // Password validation method using regex
  bool isValidPassword(String password) {
    final RegExp passwordPattern = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*()_+\-=\[\]{};:\\|,.<>\/?]).{8,}$',
    );
    return passwordPattern.hasMatch(password);
  }

  // Method to validate both old and new password
  bool validate() {
    // Validate old password
    if (!isValidPassword(oldPassword)) {
      failure("Invalid Old Password", "Your old password doesn't meet the requirements.");
      return false;
    }

    // Validate new password
    if (!isValidPassword(newPassword)) {
      failure("Invalid New Password", "Your new password doesn't meet the requirements.");
      return false;
    }

    // Check if the new password is different from the old password
    if (oldPassword == newPassword) {
      failure("Password Match Error", "Your new password cannot be the same as your old password.");
      return false;
    }

    return true; // All validations passed
  }
}

