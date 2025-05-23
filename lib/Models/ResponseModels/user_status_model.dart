class UserStatusModel {
  String userId;
  String status;
  String? lastSeen;

   UserStatusModel({
    required this.userId,
    required this.status,
    this.lastSeen,
  });

  factory UserStatusModel.fromJson(Map<String, dynamic> json) {
    return UserStatusModel(
      userId: json['userId']?.toString() ?? '', // ✅ Default to empty string if null
      status: json['status'] ?? '',
      lastSeen: json['lastSeen']?.toString() ?? '',   // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'lastSeen': lastSeen?.toString(),
    };
  }
  
  bool validate() {
    if (userId.isEmpty) {
      print("User ID is required");
      return false;
    }
    if (status.isEmpty) {
      print("Status is required");
      return false;
    }
    return true;
  }
  @override
  String toString() {
    return 'UserStatusModel(userId: $userId, status: $status, lastSeen: $lastSeen)';
  }
}
