class UserRegistrationResponse {
   String message;
   String code;
   dynamic payload;

  UserRegistrationResponse({required this.message, required this.code, this.payload});

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      message: json['message'],
      code: json['code'],
      payload: json['payload'],
    );
  }
}


class UserRegistrationPayload {
  final String message;

  UserRegistrationPayload({
    required this.message,
  });


  factory UserRegistrationPayload.fromJson(Map<String, dynamic> json) {
    return UserRegistrationPayload(
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

  // Factory constructor to create ApiError from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'] ?? '', // Default to an empty string if message is null
    );
  }

  // Method to convert ApiError object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

