class OrderRequestModel {
  String packageId;
  String amount;
  String points;
  String ispointused;
  String type;

  OrderRequestModel(
      {required this.packageId, required this.amount, required this.points, required this.ispointused, required this.type});

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
        packageId: json['package_id'],
        amount: json['amount'] ?? "0",
        points: json['points'] ?? "0",
        ispointused: json['ispointused'] ?? "0",
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    return {'package_id': packageId, 'amount': amount, 'points':points, 'ispointused':ispointused, 'type': type};
  }
}
