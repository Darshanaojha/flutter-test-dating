import '../../constants.dart';

class SendMessageRequestModel {
   String senderId;
   String receiverId;
   dynamic message;
   int messageType;
  SendMessageRequestModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType,
    };
  }

  factory SendMessageRequestModel.fromJson(Map<String, dynamic> json) {
    return SendMessageRequestModel(
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      message: json['message'] as dynamic,
      messageType: json['message_type'] as int,
    );
  }

  bool validate() {
    if (senderId.isEmpty) {
      failure('Error', "Sender ID is required");
      return false;
    }
    if (receiverId.isEmpty) {
      failure('Error', "Receiver ID is required");
      return false;
    }
    if (message == null) {
      failure('Error', "Message is required");
      return false;
    }
    if (messageType != 1 && messageType != 2 && messageType != 3) {
      failure('Error', "Message Type is required or incorrect");
      return false;
    }

    return true;
  }
}
