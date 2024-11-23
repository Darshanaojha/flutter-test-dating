class LikeHistoryResponse {
  bool? success;
  Payload? payload;
  Error? error;

  LikeHistoryResponse({this.success, this.payload, this.error});

  // Factory method to create a LikeHistoryResponse instance from JSON
  factory LikeHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LikeHistoryResponse(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  // Method to convert a LikeHistoryResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class Payload {
  String? message;
  int? likeCount;
  List<LikeData>? data;

  Payload({this.message, this.likeCount, this.data});

  // Factory method to create a Payload instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
      likeCount: json['likecount'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => LikeData.fromJson(item))
          .toList(),
    );
  }

  // Method to convert a Payload instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'likecount': likeCount,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class LikeData {
  String? id;
  String? userId;
  String? likedBy;
  String? status;
  String? created;
  String? updated;
  String? name;
  String? username;

  LikeData({
    this.id,
    this.userId,
    this.likedBy,
    this.status,
    this.created,
    this.updated,
    this.name,
    this.username,
  });

  // Factory method to create a LikeData instance from JSON
  factory LikeData.fromJson(Map<String, dynamic> json) {
    return LikeData(
      id: json['id'],
      userId: json['user_id'],
      likedBy: json['liked_by'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'],
      username: json['username'],
    );
  }

  // Method to convert a LikeData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'liked_by': likedBy,
      'status': status,
      'created': created,
      'updated': updated,
      'name': name,
      'username': username,
    };
  }
}

class Error {
  int? code;
  String? message;

  Error({this.code, this.message});

  // Factory method to create an ErrorDetails instance from JSON
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert an ErrorDetails instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
