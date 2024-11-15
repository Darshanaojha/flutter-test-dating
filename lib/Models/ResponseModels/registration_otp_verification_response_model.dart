class RegistrationOtpVerificationResponse {
  final bool success;
  final RegistrationOtpVerificationPayload payload;
  final ApiError error;

  RegistrationOtpVerificationResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create RegistrationOtpVerificationResponse from JSON
  factory RegistrationOtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpVerificationResponse(
      success: json['success'],
      payload: RegistrationOtpVerificationPayload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }

  // Method to convert RegistrationOtpVerificationResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class RegistrationOtpVerificationPayload {
  final String message;

  RegistrationOtpVerificationPayload({
    required this.message,
  });

  // Factory constructor to create RegistrationOtpVerificationPayload from JSON
  factory RegistrationOtpVerificationPayload.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpVerificationPayload(
      message: json['message'] ?? '', // Default to empty string if message is null
    );
  }

  // Method to convert RegistrationOtpVerificationPayload object to JSON
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
      message: json['message'] ?? '', // Default to empty string if message is null
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
