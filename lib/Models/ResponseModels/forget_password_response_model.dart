class ForgetPasswordResponse {
  final bool success;
  final ForgetPasswordPayload payload;
  final ForgetPasswordError error;

  ForgetPasswordResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      success: json['success'],
      payload: ForgetPasswordPayload.fromJson(json['payload']),
      error: ForgetPasswordError.fromJson(json['error']),
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

class ForgetPasswordPayload {
  final String message;

  ForgetPasswordPayload({
    required this.message,
  });

  factory ForgetPasswordPayload.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordPayload(
      message: json['message'],
    );
  }
   String extractOtp() {
    RegExp otpRegex = RegExp(r'\d{6}'); 
    return otpRegex.firstMatch(message)?.group(0) ?? ''; 
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class ForgetPasswordError {
  final int code;
  final String message;

  ForgetPasswordError({
    required this.code,
    required this.message,
  });

  factory ForgetPasswordError.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordError(
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
