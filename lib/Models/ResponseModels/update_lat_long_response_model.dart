class UpdateLatLongResponse {
  final bool success;
  final String? payload;
  final Error? error;

  UpdateLatLongResponse({
    required this.success,
    this.payload,
    this.error,
  });

  factory UpdateLatLongResponse.fromJson(Map<String, dynamic> json) {
    return UpdateLatLongResponse(
      success: json['success'] ?? false,
      payload: json['payload'] as String?,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload,
      'error': error?.toJson(),
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
