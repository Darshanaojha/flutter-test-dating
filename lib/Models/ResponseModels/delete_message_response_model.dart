class DeleteMessageResponse {
  final bool success;
  final Payload payload;
  final Error error;

  DeleteMessageResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create DeleteMessageResponse from JSON
  factory DeleteMessageResponse.fromJson(Map<String, dynamic> json) {
    return DeleteMessageResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert DeleteMessageResponse object to JSON
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

class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
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
