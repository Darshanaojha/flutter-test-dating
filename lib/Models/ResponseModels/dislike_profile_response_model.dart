import 'dart:convert';

class DislikeProfileResponse {
  final bool success;
  final Payload payload;
  final ErrorDetails error;

  DislikeProfileResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory DislikeProfileResponse.fromMap(Map<String, dynamic> map) {
    return DislikeProfileResponse(
      success: map['success'] ?? false,
      payload: Payload.fromMap(map['payload'] ?? {}),
      error: ErrorDetails.fromMap(map['error'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'payload': payload.toMap(),
      'error': error.toMap(),
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory DislikeProfileResponse.fromJson(String source) {
    return DislikeProfileResponse.fromMap(json.decode(source));
  }
}

class Payload {
  final String message;


  Payload({required this.message});


  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      message: map['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
    };
  }
}

class ErrorDetails {
  final int code;
  final String message;


  ErrorDetails({required this.code, required this.message});


  factory ErrorDetails.fromMap(Map<String, dynamic> map) {
    return ErrorDetails(
      code: map['code'] ?? 0,
      message: map['message'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }
}
