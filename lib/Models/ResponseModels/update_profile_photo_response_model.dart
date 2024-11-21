class UserProfileUpdatePhotoResponse {
  final bool success;
  final Payload payload;
  final Error error;


  UserProfileUpdatePhotoResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory UserProfileUpdatePhotoResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdatePhotoResponse(
      success: json['success'] ?? false, 
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
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


class Error {
  final int code;
  final String message;

  // Constructor
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
