class UpdateLatLongResponse {
  bool success;
  Payload payload;
  Error error;

  UpdateLatLongResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory constructor to create an instance from JSON
  factory UpdateLatLongResponse.fromJson(Map<String, dynamic> json) {
    return UpdateLatLongResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Method to convert instance to JSON
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

  // Factory constructor to create an instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
    );
  }

  // Method to convert instance to JSON
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

  // Factory constructor to create an instance from JSON
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
