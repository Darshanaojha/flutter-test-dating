class LoginResponse {
  bool success;
  Payload payload;
  Error error;

  LoginResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // From JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
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

class Payload {
  String userId;
  String email;
  String contact;
  String token;

  Payload({
    required this.userId,
    required this.email,
    required this.contact,
    required this.token,
  });

  // From JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      token: json['token'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'contact': contact,
      'token': token,
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
