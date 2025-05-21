class CreatorOrderResponse {
  final bool success;
  final String message;
  final List<OrderData> data;

  CreatorOrderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreatorOrderResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => OrderData.fromJson(item))
          .toList(),
    );
  }
}

class OrderData {
  final double amount;
  final int pointsUsed;
  final String razorpayOrderId;

  OrderData({
    required this.amount,
    required this.pointsUsed,
    required this.razorpayOrderId,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      amount: json['amount'].toDouble(),
      pointsUsed: json['pointsUsed'],
      razorpayOrderId: json['razorpayOrderId'],
    );
  }
}
