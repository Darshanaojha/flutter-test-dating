import 'dart:convert';


class ReportReason {
  String id;
  String title;
  String description;
  String status;
  DateTime created;
  DateTime updated;

  ReportReason({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    required this.updated,
  });

  // Factory method to create a ReportReason from JSON
  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'].toString(),
      created: DateTime.parse(json['created'] ?? '0000-00-00 00:00:00'),
      updated: DateTime.parse(json['updated'] ?? '0000-00-00 00:00:00'),
    );
  }

  // Convert a ReportReason instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}

// Payload model to represent the payload section of the response
class Payload {
  String message;
  List<ReportReason> data;

  Payload({required this.message, required this.data});

  // Factory method to create Payload from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<ReportReason> reportReasons = dataList
        .map((reportReasonJson) => ReportReason.fromJson(reportReasonJson))
        .toList();

    return Payload(
      message: json['message'] ?? '',
      data: reportReasons,
    );
  }

  // Convert Payload instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((reportReason) => reportReason.toJson()).toList(),
    };
  }
}

// Error model to represent the error section of the response
class Error {
  int code;
  String message;

  Error({required this.code, required this.message});

  // Factory method to create Error from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  // Convert Error instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

class ReportUserForBlockOptionsResponseModel {
  bool success;
  Payload payload;
  Error error;

  ReportUserForBlockOptionsResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  // Factory method to create the response model from JSON
  factory ReportUserForBlockOptionsResponseModel.fromJson(Map<String, dynamic> json) {
    return ReportUserForBlockOptionsResponseModel(
      success: json['success'] ?? false,
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  // Convert the response model to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }

  // Method to parse a response model from a JSON string
  static ReportUserForBlockOptionsResponseModel fromJsonString(String str) {
    return ReportUserForBlockOptionsResponseModel.fromJson(json.decode(str));
  }

  // Method to convert the response model to a JSON string
  String toJsonString() {
    return json.encode(toJson());
  }
}
