class AddUserToCreatorRequest {
  final String creatorId;
  final String userId;
  final String status;

  AddUserToCreatorRequest({
    required this.creatorId,
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'userId': userId,
      'status': status,
    };
  }
}
