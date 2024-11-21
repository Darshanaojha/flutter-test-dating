class EstablishConnectionMessageRequest {
   String receiverId;
   String message;

  EstablishConnectionMessageRequest({
    required this.receiverId,
    required this.message,
  }) ;

  factory EstablishConnectionMessageRequest.fromJson(Map<String, dynamic> json) {
    return EstablishConnectionMessageRequest(
      receiverId: json['receiver_id'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
    };
  }
}
