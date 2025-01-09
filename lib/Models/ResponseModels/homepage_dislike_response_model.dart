class HomepageDislikeResponse {
  final bool success;
  final Payload payload;
  final ErrorDetails error;

  HomepageDislikeResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }

  factory HomepageDislikeResponse.fromJson(Map<String, dynamic> json) {
    return HomepageDislikeResponse(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}), 
      error: ErrorDetails.fromJson(json['error'] ?? {}),
    );
  }
}

class Payload {
  final String message;

  Payload({required this.message});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'] ?? '',
    );
  }
}

class ErrorDetails {
  final int code;
  final String message;

  ErrorDetails({required this.code, required this.message});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

