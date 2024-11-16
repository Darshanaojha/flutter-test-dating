class ForgetPasswordVerificationResponse {
  final bool success;
  final Payload payload;
  final ErrorDetails error;

  ForgetPasswordVerificationResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory ForgetPasswordVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordVerificationResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: ErrorDetails.fromJson(json['error']),
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

class Payload {
  final String message;

  Payload({required this.message});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
    );
  }

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

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
