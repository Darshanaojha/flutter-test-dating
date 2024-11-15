// Desire Model
class Desire {
  final String id;
  final String desiresCategoryId;
  final String title;
  final String description;
  final String status;
  final String created;
  final String updated;

  Desire({
    required this.id,
    required this.desiresCategoryId,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory Desire.fromJson(Map<String, dynamic> json) {
    return Desire(
      id: json['id'],
      desiresCategoryId: json['desires_category_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desires_category_id': desiresCategoryId,
      'title': title,
      'description': description,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

// Category Model
class Category {
  final String category;
  final List<Desire> desires;

  Category({
    required this.category,
    required this.desires,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'],
      desires: (json['desire'] as List)
          .map((item) => Desire.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'desire': desires.map((desire) => desire.toJson()).toList(),
    };
  }
}

// Payload Model
class Payload {
  final String msg;
  final List<Category> data;

  Payload({
    required this.msg,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      msg: json['msg'],
      data: (json['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}

// Error Model
class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
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

// Top-level Response Model
class DesiresResponse {
  final bool success;
  final Payload payload;
  final Error error;

  DesiresResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory DesiresResponse.fromJson(Map<String, dynamic> json) {
    return DesiresResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
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
