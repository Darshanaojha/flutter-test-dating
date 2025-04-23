class BecomeCreatorPackagesResponseModel {
  final bool success;
  final String message;
  final List<PackageForCreator> data;

  BecomeCreatorPackagesResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BecomeCreatorPackagesResponseModel.fromJson(
      Map<String, dynamic> json) {
    return BecomeCreatorPackagesResponseModel(
      success: json['success'],
      message: json['message'],
      data: List<PackageForCreator>.from(
          json['data'].map((item) => PackageForCreator.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class PackageForCreator {
  final String id;
  final String title;
  final String description;
  final int duration;
  final double actualAmount;
  final int status;
  final DateTime? created;
  final DateTime? updated;
  final double offerAmount;
  final String unit;
  final String type;

  PackageForCreator({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.actualAmount,
    required this.status,
    this.created,
    this.updated,
    required this.offerAmount,
    required this.unit,
    required this.type,
  });

  factory PackageForCreator.fromJson(Map<String, dynamic> json) {
    return PackageForCreator(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      actualAmount: json['actualAmount'].toDouble(),
      status: json['status'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      offerAmount: json['offerAmount'].toDouble(),
      unit: json['unit'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'actualAmount': actualAmount,
      'status': status,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'offerAmount': offerAmount,
      'unit': unit,
      'type': type,
    };
  }
}
