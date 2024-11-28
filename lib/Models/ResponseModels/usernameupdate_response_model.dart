class UsernameUpdateResponse {
  bool success;
  Payload payload;
  ErrorDetails error;

  // Constructor
  UsernameUpdateResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory method to create an instance from a JSON map
  factory UsernameUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UsernameUpdateResponse(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: ErrorDetails.fromJson(json['error'] ?? {}),
    );
  }

  // Method to convert the object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  String message;

  Payload({required this.message});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class ErrorDetails {
  int code;
  String message;

  ErrorDetails({required this.code, required this.message});

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'] ?? 0,
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
