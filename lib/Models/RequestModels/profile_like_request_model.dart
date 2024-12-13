class ProfileLikeRequest {
   String likedBy;

  ProfileLikeRequest({required this.likedBy});

  Map<String, dynamic> toJson() {
    return {
      'liked_by': likedBy,
    };
  }

  factory ProfileLikeRequest.fromJson(Map<String, dynamic> json) {
    return ProfileLikeRequest(
      likedBy: json['liked_by'] as String,
    );
  }
}
