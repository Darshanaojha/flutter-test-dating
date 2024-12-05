class UserLoginResponse {
  final bool success;
  final UserLoginPayload payload;
  final ApiError error;

  UserLoginResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      success: json['success'],
      payload: UserLoginPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class UserLoginPayload {
  final String userId;
  final String email;
  final String contact;
  final String status;
  final String packagestatus;
  final String token;

  UserLoginPayload({
    required this.userId,
    required this.email,
    required this.contact,
    required this.status,
    required this.packagestatus,
    required this.token,
  });

  factory UserLoginPayload.fromJson(Map<String, dynamic> json) {
    return UserLoginPayload(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      status: json['status'] ?? '',
      packagestatus: json['package_status'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'contact': contact,
      'status': status,
      'package_status': packagestatus,
      'token': token,
    };
  }
}

class ApiError {
  final int code;
  final String message;

  ApiError({
    required this.code,
    required this.message,
  });

  // Factory constructor to create ApiError from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'] ??
          '', // Default to an empty string if message is null
    );
  }

  // Method to convert ApiError object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
