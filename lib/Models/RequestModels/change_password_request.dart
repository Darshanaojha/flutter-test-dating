class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  }) {
    // Validation for old password
    if (oldPassword.isEmpty) {
      throw ArgumentError("Old password is required.");
    }
    if (oldPassword.length < 8) {
      throw ArgumentError("Old password must be at least 8 characters long.");
    }

    // Validation for new password
    if (newPassword.isEmpty) {
      throw ArgumentError("New password is required.");
    }
    if (newPassword.length < 8) {
      throw ArgumentError("New password must be at least 8 characters long.");
    }
    if (newPassword == oldPassword) {
      throw ArgumentError("New password cannot be the same as old password.");
    }
    if (!isValidPassword(newPassword)) {
      throw ArgumentError("New password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.");
    }
  }

  // Factory constructor to create ChangePasswordRequest from JSON
  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      oldPassword: json['old_password'],
      newPassword: json['new_password'],
    );
  }

  // Method to convert ChangePasswordRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }

  // Helper method to validate password strength
  bool isValidPassword(String password) {
    final RegExp passwordPattern = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*()_+\-=\[\]{};:\\|,.<>\/?]).{8,}$');
    return passwordPattern.hasMatch(password);
  }
}
