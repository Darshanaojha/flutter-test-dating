class UserProfileUpdateResponse {
  final bool success;
  final UserProfileUpdatePayload payload;
  final ApiError error;

  UserProfileUpdateResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory UserProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateResponse(
      success: json['success'],
      payload: UserProfileUpdatePayload.fromJson(json['payload']),
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

class UserProfileUpdatePayload {
  final String message;

  UserProfileUpdatePayload({
    required this.message,
  });

  factory UserProfileUpdatePayload.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdatePayload(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
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

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
