
class GetAllRequestPingMessageResponse {
  bool success;
  Payload payload;
  ErrorDetails error;

  GetAllRequestPingMessageResponse({
    required this.success,
    required this.payload,
    required this.error,
  });


  factory GetAllRequestPingMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetAllRequestPingMessageResponse(
      success: json["success"],
      payload: Payload.fromJson(json["payload"]),
      error: ErrorDetails.fromJson(json["error"]),
    );
  }


  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": payload.toJson(),
        "error": error.toJson(),
      };
}


class Payload {
  String message;
  List<MessageRequest> data;

  Payload({
    required this.message,
    required this.data,
  });

  
  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        message: json["message"],
        data: List<MessageRequest>.from(
            json["data"].map((x) => MessageRequest.fromJson(x))),
      );


  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class MessageRequest {
  String id;
  String userId;
  String conectionId;
  String type;
  String status;
  String created;
  String updated;
  String name;
  int messageSendByMe;
  String nickname;
  String email;
  String dob;
  String gender;
  String profileImage;
  String message;

  MessageRequest({
    required this.id,
    required this.userId,
    required this.conectionId,
    required this.type,
    required this.status,
    required this.created,
    required this.updated,
    required this.name,
    required this.messageSendByMe,
    required this.nickname,
    required this.email,
    required this.dob,
    required this.gender,
    required this.profileImage,
    required this.message,
  });


  factory MessageRequest.fromJson(Map<String, dynamic> json) => MessageRequest(
        id: json["id"],
        userId: json["user_id"],
        conectionId: json["conection_id"],
        type: json["type"],
        status: json["status"],
        created: json["created"],
        updated: json["updated"],
        name: json["name"],
        messageSendByMe: json["message_send_by_me"],
        nickname: json["nickname"],
        email: json["email"],
        dob: json["DOB"],
        gender: json["gender"],
        profileImage: json["profile_image"],
        message: json["message"],
      );


  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "conection_id": conectionId,
        "type": type,
        "status": status,
        "created": created,
        "updated": updated,
        "name": name,
        "message_send_by_me": messageSendByMe,
        "nickname": nickname,
        "email": email,
        "DOB": dob,
        "gender": gender,
        "profile_image": profileImage,
        "message": message,
      };
}


class ErrorDetails {
  int code;
  String message;

  ErrorDetails({
    required this.code,
    required this.message,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) => ErrorDetails(
        code: json["code"],
        message: json["message"],
      );


  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}
