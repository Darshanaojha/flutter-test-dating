class PointAmountResponse {
  final bool success;
  final Payload payload;
  final ApiError error;

  PointAmountResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory PointAmountResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PointAmountResponse(
        success: false,
        payload: Payload(pointToAmount: []),
        error: ApiError(code: -1, message: "Invalid response"),
      );
    }

    return PointAmountResponse(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }
}

class Payload {
  final List<PointAmount> pointToAmount;

  Payload({required this.pointToAmount});

  factory Payload.fromJson(Map<String, dynamic>? json) {
    return Payload(
      pointToAmount: (json?['point_to_amount'] as List?)
              ?.map((e) => PointAmount.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PointAmount {
   String points;
   String amount;

  PointAmount({required this.points, required this.amount});

  factory PointAmount.fromJson(Map<String, dynamic>? json) {
    return PointAmount(
      points: json?['points'] ?? '0',
      amount: json?['amount'] ?? '0',
    );
  }
}

class ApiError {
  final int code;
  final String message;

  ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic>? json) {
    return ApiError(
      code: json?['code'] ?? 0,
      message: json?['message'] ?? '',
    );
  }
}
