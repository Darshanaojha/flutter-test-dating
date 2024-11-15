class UpdateEmailVerificationResponse {
  final bool success;
  final Payload payload;
  final Error error;

  UpdateEmailVerificationResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create UpdateEmailVerificationResponse from JSON
  factory UpdateEmailVerificationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateEmailVerificationResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert UpdateEmailVerificationResponse object to JSON
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

class Error {
  final int code;
  final String message;

  Error({required this.code, required this.message});

  // Factory constructor to create Error from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert Error object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
