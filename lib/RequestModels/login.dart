class LoginRequest {
  String email;
  String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(email: json['email'] ?? '', password: json['password'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  String? validate() {
    if (!_isValidEmail(email)) return 'Invalid email';
    if (!_isValidPassword(password)) return 'Password is invalid';
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }
}
