class ProfileLikeResponse {
  final bool success;
  final Payload payload;
  final Error error;

  ProfileLikeResponse({required this.success, required this.payload, required this.error});


  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }


  factory ProfileLikeResponse.fromJson(Map<String, dynamic> json) {
    return ProfileLikeResponse(
      success: json['success'] as bool,
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
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
      message: json['message'] as String,
    );
  }
}

class Error {
  final int code;
  final String message;

  Error({required this.code, required this.message});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] as int,
      message: json['message'] as String,
    );
  }
}
