class OrderRequestModel {
  String packageId;
  String amount;
  String points;
  String type;

  OrderRequestModel(
      {required this.packageId, required this.amount, required this.points, required this.type});

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
        packageId: json['package_id'],
        amount: json['amount'],
        points: json['points'],
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    return {'package_id': packageId, 'amount': amount, 'points':points, 'type': type};
  }
}
