class RegistrationOtpResponse {
  final bool success;
  final RegistrationOtpPayload payload;
  final ApiError error;

  RegistrationOtpResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create RegistrationOtpResponse from JSON
  factory RegistrationOtpResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpResponse(
      success: json['success'],
      payload: RegistrationOtpPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert RegistrationOtpResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class RegistrationOtpPayload {
  final String message;

  RegistrationOtpPayload({
    required this.message,
  });

  // Factory constructor to create RegistrationOtpPayload from JSON
  factory RegistrationOtpPayload.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpPayload(
      message: json['message'] ?? '',
    );
  }

  // Method to convert RegistrationOtpPayload object to JSON
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

