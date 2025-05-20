class CreatorTransactionRequest {
  final String paymentMethod;
  final String paymentStatus;
  final String razorpayPaymentId;
  final String razorpayId;
  final String genreId;
  final double amount;
  final double amountPayable;

  CreatorTransactionRequest({
    required this.paymentMethod,
    required this.paymentStatus,
    required this.razorpayPaymentId,
    required this.razorpayId,
    required this.genreId,
    required this.amount,
    required this.amountPayable,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayId': razorpayId,
      'genreId': genreId,
      'amount': amount,
      'amountPayable': amountPayable,
    };
  }
}
