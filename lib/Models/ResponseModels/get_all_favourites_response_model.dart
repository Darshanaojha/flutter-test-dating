class GetFavouritesResponse {
  bool success;
  Payload payload;
  Error error;

  GetFavouritesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetFavouritesResponse.fromJson(Map<String, dynamic> json) {
    return GetFavouritesResponse(
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

class Payload {
  String message;
  List<Favourite> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<Favourite> favourites = dataList.map((i) => Favourite.fromJson(i)).toList();

    return Payload(
      message: json['message'],
      data: favourites,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((f) => f.toJson()).toList(),
    };
  }
}

class Favourite {
  String id;
  String userId;
  String favouriteId;
  String status;
  String created;
  String updated;

  Favourite({
    required this.id,
    required this.userId,
    required this.favouriteId,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      id: json['id'],
      userId: json['user_id'],
      favouriteId: json['favourite_id'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'favourite_id': favouriteId,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class Error {
  int code;
  String message;

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
