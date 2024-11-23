class LikeModel {
  String? likedBy;

  LikeModel({this.likedBy});

  // Factory method to create a LikeModel instance from JSON
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      likedBy: json['liked_by'],
    );
  }

  // Method to convert a LikeModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'liked_by': likedBy,
    };
  }
}
