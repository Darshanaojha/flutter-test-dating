import 'package:dating_application/Models/ResponseModels/get_rejection_message_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';
import 'package:encrypt_shared_preferences/provider.dart';


class GetRejectionMessageProvider extends GetConnect {
  Future<GetRejectionMessageModel?> getRejectionMessageProvider() async {
    try {
      EncryptedSharedPreferences preferences =
      EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      final response = await get(
        '$baseurl/Profile/get_rejection_reason',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == null || response.body == null) {
        failure('Error in getRejectionMessageProvider', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GetRejectionMessageModel.fromJson(response.body);
        } else {
          failure('Error in getRejectionMessageProvider', response.body['error']['message']);
          return null;
        }
      } else {
        failure(
          'Error',
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure('Error in getRejectionMessageProvider', e.toString());
      return null;
    }
  }
}