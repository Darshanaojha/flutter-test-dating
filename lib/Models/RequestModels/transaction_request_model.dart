class TransactionRequestModel {
  String orderId;
  String packageId;
  String type;
  String razorPayOrderId;
  String razorPayPaymentId;
  String paymentStatus;
  String paymentMethod;
  String amount;
  String status;
  String created;
  String updated;

  // Constructor with named parameters
  TransactionRequestModel({
    required this.orderId,
    required this.packageId,
    required this.type,
    required this.razorPayOrderId,
    required this.razorPayPaymentId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.created,
    required this.updated,
  });

  // Factory constructor to create an instance from JSON
  factory TransactionRequestModel.fromJson(Map<String, dynamic> json) {
    return TransactionRequestModel(
      orderId: json['order_id'],
      packageId: json['package_id'],
      type: json['type'],
      razorPayOrderId: json['razorpay_order_id'],
      razorPayPaymentId: json['razorpay_payment_id'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      amount: json['amount'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  // Method to convert the object to JSON map
  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "package_id": packageId,
      "type": type,
      "razorpay_order_id": razorPayOrderId,
      "razorpay_payment_id": razorPayPaymentId,
      "payment_status": paymentStatus,
      "payment_method": paymentMethod,
      "amount": amount,
      "status": status,
      "created": created,
      "updated": updated,
    };
  }
}
