class TransactionRequestModel {
  String orderId;
  String packageId;
  String type;
  String message;
  String razorpayOrderId;
  String razorpayPaymentId;
  String paymentStatus;
  String paymentMethod;
  String transactionId;
  String amount;
  DateTime created;
  DateTime updated;

  TransactionRequestModel({
    required this.orderId,
    required this.packageId,
    required this.type,
    required this.message,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amount,
    required this.transactionId,
    required this.created,
    required this.updated,
  });

  factory TransactionRequestModel.fromJson(Map<String, dynamic> json) {
    return TransactionRequestModel(
      orderId: json['order_id'] ?? '',
      packageId: json['package_id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      amount: json['amount'] ?? '',
      transactionId: json['transactionId'] ?? '',
      created: DateTime.parse(
          json['created'] ?? DateTime.now().toIso8601String()), 
      updated: DateTime.parse(
          json['updated'] ?? DateTime.now().toIso8601String()), 
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'package_id': packageId,
      'type': type,
      'message': message,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'amount': amount,
      'transactionId': transactionId,
      'created': created.toIso8601String(), 
      'updated': updated.toIso8601String(),
    };
  }
}
