class CreatorTransactionHistoryResponse {
  final bool success;
  final String message;
  final List<TransactionData> data;

  CreatorTransactionHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorTransactionHistoryResponse.fromJson(
      Map<String, dynamic> json) {
    return CreatorTransactionHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => TransactionData.fromJson(item))
              .toList() ??
          [],
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

class TransactionData {
  final String id;
  final String userId;
  final String orderId;
  final String razorpayId;
  final String razorpayPaymentId;
  final String paymentStatus;
  final String paymentMethod;
  final double amount;
  final String creatorId;
  final double paidAmount;
  final int pointsUsed;
  final String message;
  final DateTime created;
  final DateTime updated;

  TransactionData({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.razorpayId,
    required this.razorpayPaymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amount,
    required this.creatorId,
    required this.paidAmount,
    required this.pointsUsed,
    required this.message,
    required this.created,
    required this.updated,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      orderId: json['orderId'] ?? '',
      razorpayId: json['razorpayId'] ?? '',
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      creatorId: json['creatorId'] ?? '',
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      pointsUsed: json['pointsUsed'] ?? 0,
      message: json['message'] ?? '',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'razorpayId': razorpayId,
      'razorpayPaymentId': razorpayPaymentId,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'creatorId': creatorId,
      'paidAmount': paidAmount,
      'pointsUsed': pointsUsed,
      'message': message,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
