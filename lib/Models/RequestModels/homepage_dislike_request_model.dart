class HomepageDislikeRequest {
  String userId;
  String connectionId;

  HomepageDislikeRequest({
    required this.userId,
    required this.connectionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'conection_id': connectionId,
    };
  }

  factory HomepageDislikeRequest.fromJson(Map<String, dynamic> json) {
    return HomepageDislikeRequest(
      userId: json['user_id'],
      connectionId: json['conection_id'],
    );
  }
}
