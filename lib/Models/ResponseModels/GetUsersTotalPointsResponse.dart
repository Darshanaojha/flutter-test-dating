class GetUsersTotalPoints {
  bool success;
  Payload payload;
  ErrorInfo error;

  GetUsersTotalPoints({
    required this.success,
    required this.error,
    required this.payload,
  });

  factory GetUsersTotalPoints.fromJson(Map<String, dynamic> json) {
    return GetUsersTotalPoints(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload'] ?? {}),
      error: ErrorInfo.fromJson(json['error'] ?? {}),
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
  Point point; // ✅ Change List<Point> to a single Point

  Payload({required this.point});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      point: Point.fromJson(json['point'] ?? {}), // ✅ Fix here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point': point.toJson(),
    };
  }
}

class Point {
   String points;

  Point({required this.points});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
    };
  }
}

class ErrorInfo {
  int code;
  String message;

  ErrorInfo({
    required this.code,
    required this.message,
  });

  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
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
