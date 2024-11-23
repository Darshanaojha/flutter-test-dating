class ConnectedUserResponseModel {
  bool? success;
  Payload? payload;
  Error? error;

  ConnectedUserResponseModel({this.success, this.payload, this.error});

  // Factory method to create an ApiResponse instance from JSON
  factory ConnectedUserResponseModel.fromJson(Map<String, dynamic> json) {
    return ConnectedUserResponseModel(
      success: json['success'],
      payload:
          json['payload'] != null ? Payload.fromJson(json['payload']) : null,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  // Method to convert an ApiResponse instance to JSON
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
  List<Connection>? data;

  Payload({this.message, this.data});

  // Factory method to create a Payload instance from JSON
  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Connection.fromJson(item))
          .toList(),
    );
  }

  // Method to convert a Payload instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class Connection {
  String? id;
  String? userId;
  String? connectionId;
  String? status;
  String? created;
  String? updated;
  String? name;
  String? username;
  String? profileImage;

  Connection({
    this.id,
    this.userId,
    this.connectionId,
    this.status,
    this.created,
    this.updated,
    this.name,
    this.username,
    this.profileImage,
  });

  // Factory method to create a UserData instance from JSON
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      userId: json['user_id'],
      connectionId: json['conection_id'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'],
      username: json['username'],
      profileImage: json['profile_image'],
    );
  }

  // Method to convert a UserData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conection_id': connectionId,
      'status': status,
      'created': created,
      'updated': updated,
      'name': name,
      'username': username,
      'profile_image': profileImage,
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
