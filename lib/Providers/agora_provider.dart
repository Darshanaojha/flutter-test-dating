
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

class AgoraProvider extends GetConnect {
  Future<bool> sendNotification(String channelName, String callerName,
      String receiverId, String type) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', "Token not found");
        return false;
      }
      Response response = await post(
        "$springbooturl/api/agora/sendNotification",
        {
          "channelName": channelName,
          "callerName": callerName,
          "receiverId": receiverId,
          "type": type
        },
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      print('${response.statusCode} , ${response.body.toString()}');
      if (response.statusCode == null || response.body == null) {
        failure("Error", "No response from server");
        return false;
      }
      if (response.statusCode == 200) {
        if (response.body['success'] == true) {
          return true;
        } else {
          failure('Error', response.body['message']);
          return false;
        }
      } else {
        failure('Error', response.body['message']);
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }
}
