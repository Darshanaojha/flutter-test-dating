class PackagesResponseModel {
  bool success;
  Payload payload;
  Error error;

  PackagesResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory PackagesResponseModel.fromJson(Map<String, dynamic> json) {
    return PackagesResponseModel(
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
  List<GetAllPackagesResponseModel> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<GetAllPackagesResponseModel> data = dataList
        .map((item) => GetAllPackagesResponseModel.fromJson(item))
        .toList();

    return Payload(
      message: json['message'],
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class GetAllPackagesResponseModel {
  String id;
  String days;
  String actualAmount;
  String offerAmount;
  String unit;
  String status;
  String created;
  String updated;

  GetAllPackagesResponseModel({
    required this.id,
    required this.days,
    required this.actualAmount,
    required this.offerAmount,
    required this.unit,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory GetAllPackagesResponseModel.fromJson(Map<String, dynamic> json) {
    return GetAllPackagesResponseModel(
      id: json['id'],
      days: json['days'],
      actualAmount: json['actual_amount'],
      offerAmount: json['offer_amount'],
      unit: json['unit'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'days': days,
      'actual_amount': actualAmount,
      'offer_amount': offerAmount,
      'unit': unit,
      'status': status,
      'created': created,
      'updated': updated,
    };
  }
}

class Error {
  int code;
  String message;

  Error({required this.code, required this.message});

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
