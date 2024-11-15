class EditMessageResponse {
  final bool success;
  final Payload payload;
  final ApiError error;

  EditMessageResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory EditMessageResponse.fromJson(Map<String, dynamic> json) {
    return EditMessageResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
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

class Payload {
  final String message;

  Payload({
    required this.message,
  });

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
