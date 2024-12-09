class LikeModel {
  String? likedBy;

  LikeModel({this.likedBy});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      likedBy: json['liked_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked_by': likedBy,
    };
  }
}
