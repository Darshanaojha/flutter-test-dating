class RegistrationOtpResponse {
  final bool success;
  final RegistrationOtpPayload payload;
  final ApiError error;

  RegistrationOtpResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory RegistrationOtpResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpResponse(
      success: json['success'],
      payload: RegistrationOtpPayload.fromJson(json['payload']),
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

class RegistrationOtpPayload {
  final String message;

  RegistrationOtpPayload({
    required this.message,
  });


  factory RegistrationOtpPayload.fromJson(Map<String, dynamic> json) {
    return RegistrationOtpPayload(
      message: json['message'] ?? '',
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

