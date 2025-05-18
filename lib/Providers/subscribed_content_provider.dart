import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/ResponseModels/subscribed_content_response.dart';

class SubscribedContentProvider extends GetConnect {
  Future<SubscribedContentResponse?> fetchSubscribedContent() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await get(
          '$springbooturl/creator/subscribed-content/',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return SubscribedContentResponse.fromJson(response.body);
        } else {
          failure('Error', response.body.toString());
          return null;
        }
      } else {
        failure('Error', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
