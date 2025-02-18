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
    // Return a default response if the JSON is null
    if (json == null) {
      return PointAmountResponse(
        success: false,
        payload: Payload(pointToAmount: []),
        error: ApiError(code: -1, message: "Invalid response"),
      );
    }

    return PointAmountResponse(
      success: json['success'] ?? false, // Fallback to false if 'success' key is missing
      payload: Payload.fromJson(json['payload']),
      error: ApiError.fromJson(json['error']),
    );
  }
}

class Payload {
  final List<PointAmount> pointToAmount;

  Payload({required this.pointToAmount});

  factory Payload.fromJson(Map<String, dynamic>? json) {
    // If 'point_to_amount' is missing or null, return an empty list
    return Payload(
      pointToAmount: (json?['point_to_amount'] as List?)
              ?.map((e) => PointAmount.fromJson(e))
              .toList() ??
          [], // Return empty list if 'point_to_amount' is not found
    );
  }
}

class PointAmount {
  final String points;
  final String amount;

  PointAmount({required this.points, required this.amount});

  factory PointAmount.fromJson(Map<String, dynamic>? json) {
    // Fallback to default values if points or amount are missing
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
    // Handle null or missing error fields gracefully
    return ApiError(
      code: json?['code'] ?? 0, // Default to 0 if 'code' is not found
      message: json?['message'] ?? '', // Default to empty string if 'message' is missing
    );
  }
}
