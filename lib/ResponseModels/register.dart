class RegisterResponse {
  bool success;
  Payload payload;
  Error error;

  RegisterResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // From JSON
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: Error.fromJson(json['error'] ?? {}),
    );
  }

  // To JSON
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

  // From JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class Error {
  int code;
  String message;

  Error({required this.code, required this.message});

  // From JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
