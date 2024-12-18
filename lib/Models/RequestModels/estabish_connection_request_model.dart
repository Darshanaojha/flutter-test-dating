class EstablishConnectionMessageRequest {
   String receiverId;
   String message;
   int messagetype;

  EstablishConnectionMessageRequest({
    required this.receiverId,
    required this.message,
    required this.messagetype,
  }) ;

  factory EstablishConnectionMessageRequest.fromJson(Map<String, dynamic> json) {
    return EstablishConnectionMessageRequest(
      receiverId: json['receiver_id'],
      message: json['message'],
      messagetype : json['message_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
      'message_type':messagetype,
    };
  }
}
