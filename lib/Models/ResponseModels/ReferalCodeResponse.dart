class ReferralCodeResponse {
  bool success;
  ReferralCodePayload payload;
  ReferralError error;

  ReferralCodeResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory ReferralCodeResponse.fromJson(Map<String, dynamic> json) {
    return ReferralCodeResponse(
      success: json['success'] ?? false,
      payload: ReferralCodePayload.fromJson(json['payload'] ?? {}),
      error: ReferralError.fromJson(json['error'] ?? {}),
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

class ReferralCodePayload {
  String referralCode;

  ReferralCodePayload({required this.referralCode});

  factory ReferralCodePayload.fromJson(Map<String, dynamic> json) {
    return ReferralCodePayload(
      referralCode: (json['referal_code'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referal_code': referralCode,
    };
  }
}


class ReferralError {
  int code;
  String message;

  ReferralError({required this.code, required this.message});

  factory ReferralError.fromJson(Map<String, dynamic> json) {
    return ReferralError(
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
