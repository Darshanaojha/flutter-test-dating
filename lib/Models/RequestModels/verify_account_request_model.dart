import 'dart:convert';

class RequestToVerifyAccount {
  String identifyImage;
  String identifyNo;

  RequestToVerifyAccount({
    required this.identifyImage,
    required this.identifyNo,
  });

  String toJson() => json.encode({
        'identify_image': identifyImage,
        'identify_no': identifyNo,
      });

  factory RequestToVerifyAccount.fromJson(String str) {
    final Map<String, dynamic> jsonMap = json.decode(str);
    return RequestToVerifyAccount(
      identifyImage: jsonMap['identify_image'] ?? '',
      identifyNo: jsonMap['identify_no'] ?? '',
    );
  }
}