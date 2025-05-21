class CreatorAllOrdersResponse {
  final bool success;
  final String message;
  final List<CreatorAllOrder> data;

  CreatorAllOrdersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorAllOrdersResponse.fromJson(Map<String, dynamic> json) {
    return CreatorAllOrdersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CreatorAllOrder.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CreatorAllOrder {
  final String id;
  final String receiptId;
  final String razorpayId;
  final String userId;
  final String packageId;
  final String type;
  final double actualAmount;
  final double offerAmount;
  final double paidAmount;
  final String packageTitle;
  final String packageDescription;
  final int? duration;
  final String unit;
  final String status;
  final int pointsUsed;
  final DateTime? created;
  final DateTime? updated;

  CreatorAllOrder({
    required this.id,
    required this.receiptId,
    required this.razorpayId,
    required this.userId,
    required this.packageId,
    required this.type,
    required this.actualAmount,
    required this.offerAmount,
    required this.paidAmount,
    required this.packageTitle,
    required this.packageDescription,
    this.duration,
    required this.unit,
    required this.status,
    required this.pointsUsed,
    this.created,
    this.updated,
  });

  factory CreatorAllOrder.fromJson(Map<String, dynamic> json) {
    return CreatorAllOrder(
      id: json['id'] ?? '',
      receiptId: json['receiptId'] ?? '',
      razorpayId: json['razorpayId'] ?? '',
      userId: json['userId'] ?? '',
      packageId: json['packageId'] ?? '',
      type: json['type'] ?? '',
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      offerAmount: (json['offerAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      packageTitle: json['packageTitle'] ?? '',
      packageDescription: json['packageDescription'] ?? '',
      duration: json['duration'],
      unit: json['unit'] ?? '',
      status: json['status'] ?? '',
      pointsUsed: json['pointsUsed'] ?? 0,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'])
          : null,
      updated: json['updated'] != null
          ? DateTime.tryParse(json['updated'])
          : null,
    );
  }
}
