
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
    var list = json['data'] as List;
    List<Favourite> favouritesList =
        list.map((item) => Favourite.fromJson(item)).toList();

    return Payload(
      message: json['message'],
      data: favouritesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((favourite) => favourite.toJson()).toList(),
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
  String dob;
  String name;
  String username;
  String city;
  List<String> images;  

  Favourite({
    required this.id,
    required this.userId,
    required this.favouriteId,
    required this.status,
    required this.created,
    required this.updated,
    required this.dob,
    required this.name,
    required this.username,
    required this.city,
    required this.images,  
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    List<String> images = [
      json['img1'] as String? ?? '',
      json['img2'] as String? ?? '',
      json['img3'] as String? ?? '',
      json['img4'] as String? ?? '',
      json['img5'] as String? ?? '',
      json['img6'] as String? ?? '',
    ].where((img) => img.isNotEmpty).toList();  

    return Favourite(
      id: json['id'],
      userId: json['user_id'],
      favouriteId: json['favourite_id'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      dob: json['dob'],
      name: json['name'],
      username: json['username'],
      city : json['city'],
      images: images,  // Add images list to the object
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
      'dob': dob,
      'name': name,
      'username': username,
      'city':city,
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
