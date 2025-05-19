class PackageResponse {
  final bool success;
  final String message;
  final List<PackageModel> data;

  PackageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PackageResponse.fromJson(Map<String, dynamic> json) {
    return PackageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PackageModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PackageModel {
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

  PackageModel({
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

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      actualAmount: (json['actualAmount'] is num)
          ? (json['actualAmount'] as num).toDouble()
          : 0.0,
      status: json['status'] ?? 0,
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      offerAmount: (json['offerAmount'] is num)
          ? (json['offerAmount'] as num).toDouble()
          : 0.0,
      unit: json['unit'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
