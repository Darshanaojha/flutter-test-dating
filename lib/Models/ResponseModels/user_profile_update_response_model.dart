class UserProfileUpdateResponse {
  final bool success;
  final UserProfileUpdatePayload payload;
  final ApiError error;

  UserProfileUpdateResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create UserProfileUpdateResponse from JSON
  factory UserProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateResponse(
      success: json['success'],
      payload: UserProfileUpdatePayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert UserProfileUpdateResponse object to JSON
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

  // Factory constructor to create UserProfileUpdatePayload from JSON
  factory UserProfileUpdatePayload.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdatePayload(
      message: json['message'],
    );
  }

  // Method to convert UserProfileUpdatePayload object to JSON
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

  // Factory constructor to create ApiError from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'] ?? '', // Default to an empty string if message is null
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
