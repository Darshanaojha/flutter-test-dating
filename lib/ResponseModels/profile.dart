class ProfileResponse {
  bool success;
  User payload;
  Error error;

  ProfileResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // From JSON
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      payload: User.fromJson(json['payload'] ?? {}),
      error: Error.fromJson(json['error'] ?? {}),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class User {
  String id;
  String name;
  String email;
  String mobile;
  String city;
  String state;
  String address;
  String gender;
  String password;
  String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.city,
    required this.state,
    required this.address,
    required this.gender,
    required this.password,
    required this.status,
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      password: json['password'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'city': city,
      'state': state,
      'address': address,
      'gender': gender,
      'password': password,
      'status': status,
    };
  }
}

class Error {
  int code;
  String message;

  Error({
    required this.code,
    required this.message,
  });

  // From JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
