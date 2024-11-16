class UserLoginRequest {
  String email;
  String password;


  UserLoginRequest({required this.email, required this.password});


  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      email: json['email'] ?? '', 
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
