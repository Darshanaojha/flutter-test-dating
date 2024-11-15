class ForgetPasswordVerificationResponse {
  final bool success;
  final Payload payload;
  final ErrorDetails error;

  ForgetPasswordVerificationResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create ForgetPasswordVerificationResponse from JSON
  factory ForgetPasswordVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordVerificationResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: ErrorDetails.fromJson(json['error']),
    );
  }

  // Method to convert ForgetPasswordVerificationResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final String message;

  Payload({required this.message});

  // Factory constructor to create Payload from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
    );
  }

  // Method to convert Payload object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class ErrorDetails {
  final int code;
  final String message;

  ErrorDetails({required this.code, required this.message});

  // Factory constructor to create ErrorDetails from JSON
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert ErrorDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
