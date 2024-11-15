class UserRegistrationResponse {
  final bool success;
  final UserRegistrationPayload payload;
  final ApiError error;

  UserRegistrationResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      success: json['success'],
      payload: UserRegistrationPayload.fromJson(json['payload']),
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

class UserRegistrationPayload {
  final String message;

  UserRegistrationPayload({
    required this.message,
  });

  // Factory constructor to create UserRegistrationPayload from JSON
  factory UserRegistrationPayload.fromJson(Map<String, dynamic> json) {
    return UserRegistrationPayload(
      message: json['message'] ?? '',
    );
  }

  // Method to convert UserRegistrationPayload object to JSON
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

