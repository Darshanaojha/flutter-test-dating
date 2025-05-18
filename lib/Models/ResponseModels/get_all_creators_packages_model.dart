class CreatorPackageResponse {
  final bool success;
  final String message;
  final List<PackageForCreator> data;

  CreatorPackageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorPackageResponse.fromJson(Map<String, dynamic> json) {
    return CreatorPackageResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((e) => PackageForCreator.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
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
    required this.created,
    required this.updated,
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
      actualAmount: (json['actualAmount'] as num).toDouble(),
      status: json['status'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      offerAmount: (json['offerAmount'] as num).toDouble(),
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

