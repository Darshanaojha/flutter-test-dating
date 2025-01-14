class OrderRequestModel {
  String packageId;
  String amount;
  String type;

  OrderRequestModel(
      {required this.packageId, required this.amount, required this.type});

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
        packageId: json['package_id'],
        amount: json['amount'],
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    return {'package_id': packageId, 'amount': amount, 'type': type};
  }
}
