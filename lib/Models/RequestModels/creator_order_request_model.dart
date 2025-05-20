class CreatorOrderRequest {
  final String packageId;
  final int pointsUsed;
  final double offerAmount;
  final double actualAmount;
  final double amountPayable;
  final String message;
  final String genreId;

  CreatorOrderRequest({
    required this.packageId,
    required this.pointsUsed,
    required this.offerAmount,
    required this.actualAmount,
    required this.amountPayable,
    required this.message,
    required this.genreId,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'pointsUsed': pointsUsed,
      'offerAmount': offerAmount,
      'actualAmount': actualAmount,
      'amountPayable': amountPayable,
      'message': message,
      'genreId': genreId,
    };
  }

  factory CreatorOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreatorOrderRequest(
      packageId: json['packageId'],
      pointsUsed: json['pointsUsed'],
      offerAmount: json['offerAmount'].toDouble(),
      actualAmount: json['actualAmount'].toDouble(),
      amountPayable: json['amountPayable'].toDouble(),
      message: json['message'],
      genreId: json['genreId'],
    );
  }
}
