class AppSettingResponse {
  final bool success;
  final String payload;
  final Error error;

  AppSettingResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory AppSettingResponse.fromJson(Map<String, dynamic> json) {
    return AppSettingResponse(
      success: json['success'],
      payload: json['payload'],
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload,
      'error': error.toJson(),
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