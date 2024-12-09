class UpdateNewPackageResponse {
  bool success;
  Payload payload;
  Error error;

  UpdateNewPackageResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory UpdateNewPackageResponse.fromJson(Map<String, dynamic> json) {
    return UpdateNewPackageResponse(
      success: json['success'],
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
  String message;

  Payload({
    required this.message,
  });

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
  int code;
  String message;

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
