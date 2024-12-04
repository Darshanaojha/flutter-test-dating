import 'dart:convert';

class RequestToVerifyAccount {
   String identifyImage;
   String identifyNo;

  RequestToVerifyAccount({
    required this.identifyImage,
    required this.identifyNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'identify_image': identifyImage,
      'identify_no': identifyNo,
    };
  }

  factory RequestToVerifyAccount.fromMap(Map<String, dynamic> map) {
    return RequestToVerifyAccount(
      identifyImage: map['identify_image'] ?? '',
      identifyNo: map['identify_no'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestToVerifyAccount.fromJson(String str) =>
      RequestToVerifyAccount.fromMap(json.decode(str));
}
