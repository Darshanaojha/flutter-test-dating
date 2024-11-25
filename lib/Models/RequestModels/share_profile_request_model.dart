class ShareProfileRequestModel {
  String? userId;

  ShareProfileRequestModel({this.userId});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }

  factory ShareProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return ShareProfileRequestModel(
      userId: json['user_id'],
    );
  }
}
