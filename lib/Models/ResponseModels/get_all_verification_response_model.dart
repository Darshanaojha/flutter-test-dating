
class GetVerificationTypeResponse {
  final bool success;
  final Payload payload;
  final Error error;

  GetVerificationTypeResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory GetVerificationTypeResponse.fromMap(Map<String, dynamic> json) =>
      GetVerificationTypeResponse(
        success: json["success"] ?? false, 
        payload: Payload.fromMap(json["payload"]),
        error: Error.fromMap(json["error"]),
      );


  Map<String, dynamic> toMap() => {
        "success": success,
        "payload": payload.toMap(),
        "error": error.toMap(),
      };
}

class Payload {
  final String message;
  final VerificationType data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromMap(Map<String, dynamic> json) => Payload(
        message: json["message"] ?? "", 
        data: VerificationType.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "data": data.toMap(),
      };
}

class VerificationType {
  final String id;
  final String title;
  final String description;
  final String status;
  final String created;
  final String updated;

  VerificationType({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    required this.updated,
  });


  factory VerificationType.fromMap(Map<String, dynamic> json) =>
      VerificationType(
        id: json["id"]?.toString() ?? "", 
        title: json["title"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        created: json["created"]?.toString() ?? "",
        updated: json["updated"]?.toString() ?? "",
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "status": status,
        "created": created,
        "updated": updated,
      };
}

class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromMap(Map<String, dynamic> json) => Error(
        code: json["code"] ?? 0, 
        message: json["message"]?.toString() ?? "",
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "message": message,
      };
}

