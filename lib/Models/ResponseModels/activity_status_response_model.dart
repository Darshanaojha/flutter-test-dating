class UpdateActivityStatusResponse {
  final bool success;
  final Payload payload;
  final Error error;


  UpdateActivityStatusResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

 
  factory UpdateActivityStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateActivityStatusResponse(
      success: json['success'] as bool,
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }
}

class Payload {
  final String message;

  Payload({required this.message});

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

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] as int,
      message: json['message'] as String,
    );
  }
}
