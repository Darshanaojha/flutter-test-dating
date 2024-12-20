
import '../../constants.dart'; 

class UserLoginRequest {
  String email;
  String password;

  UserLoginRequest({required this.email, required this.password});

  // Factory constructor to create UserLoginRequest from JSON
  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Method to convert UserLoginRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Validation method
  bool validate() {
    try {
      validateEmail(email);
      validatePassword(password);

      return true;
    } catch (e) {
      // Show snackbar on validation failure
      failure("Validation Error", e.toString());
      return false;  // Validation failed
    }
  }

  void validateEmail(String email) {
    if (email.isEmpty) {
      throw ArgumentError("Email cannot be empty.");
    }

    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format.");
    }
  }

  void validatePassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError("Password cannot be empty.");
    }
    if (password.length < 8) {
      throw ArgumentError("Password must be at least 8 characters long.");
    }
  }
}
