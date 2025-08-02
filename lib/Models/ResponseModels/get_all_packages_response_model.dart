class GetAllPackagesResponseModel {
  bool success;
  Payload payload;
  Error error;

  GetAllPackagesResponseModel({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetAllPackagesResponseModel.fromJson(Map<String, dynamic> json) {
    return GetAllPackagesResponseModel(
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
  List<Package> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<Package> data =
        dataList.map((item) => Package.fromJson(item)).toList();

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

class Package {
  String id;
  String packageTitle;
  String packageCategoryId;
  String packagecategory;
  String packageDescription;
  String days;
  String actualAmount;
  String offerAmount;
  String unit;
  String points;
  String pointamount;
  String threshold;
  String status;
  String created;
  String updated;

  Package({
    required this.id,
    required this.packageTitle,
    required this.packageDescription,
    required this.packageCategoryId,
    required this.packagecategory,
    required this.days,
    required this.actualAmount,
    required this.offerAmount,
    required this.unit,
    required this.points,
    required this.pointamount,
    required this.threshold,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      packageTitle: json['package_title'] ?? '',
      packageCategoryId: json['package_category_id'] ?? '',
      packagecategory: json['packagecategory'] ?? '',
      packageDescription: json['description'] ?? '',
      days: json['days'].toString(),
      actualAmount: json['actual_amount'].toString(),
      offerAmount: json['offer_amount'].toString(),
      unit: json['unit'] ?? '',
      points: json['points'].toString(),
      pointamount: json['point_amount'].toString(),
      threshold: json['threshold'].toString(),
      status: json['status'].toString(),
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_title': packageTitle,
      'package_category_id': packageCategoryId,
      'packagecategory': packagecategory,
      'description': packageDescription,
      'days': days,
      'actual_amount': actualAmount,
      'offer_amount': offerAmount,
      'unit': unit,
      'points': points,
      'points_amount': pointamount,
      'threshold': threshold,
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
