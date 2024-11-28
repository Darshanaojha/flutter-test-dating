class UsernameUpdateRequest {
  String username;


  UsernameUpdateRequest({required this.username});


  factory UsernameUpdateRequest.fromJson(Map<String, dynamic> json) {
    return UsernameUpdateRequest(
      username: json['username'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}