class UserLoginRequest {
  String email;
  String password;

  // Constructor
  UserLoginRequest({required this.email, required this.password});

  // From JSON method to create UserLoginRequest from a JSON map
  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      email: json['email'] ?? '',   // Use null-aware operators if necessary
      password: json['password'] ?? '',
    );
  }

  // You might also want to add toJson method if you want to serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
