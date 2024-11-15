class ForgetPasswordResponse {
  final bool success;
  final ForgetPasswordPayload payload;
  final ForgetPasswordError error;

  ForgetPasswordResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create ForgetPasswordResponse from JSON
  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      success: json['success'],
      payload: ForgetPasswordPayload.fromJson(json['payload']),
      error: ForgetPasswordError.fromJson(json['error']),
    );
  }

  // Method to convert ForgetPasswordResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class ForgetPasswordPayload {
  final String message;

  ForgetPasswordPayload({
    required this.message,
  });

  // Factory constructor to create ForgetPasswordPayload from JSON
  factory ForgetPasswordPayload.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordPayload(
      message: json['message'],
    );
  }

  // Method to convert ForgetPasswordPayload object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class ForgetPasswordError {
  final int code;
  final String message;

  ForgetPasswordError({
    required this.code,
    required this.message,
  });

  // Factory constructor to create ForgetPasswordError from JSON
  factory ForgetPasswordError.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordError(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert ForgetPasswordError object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
