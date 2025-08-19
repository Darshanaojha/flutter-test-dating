import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/pin_profile_pic_request_model.dart';
import '../Models/ResponseModels/pin_profile_pic_response_model.dart';
import '../constants.dart';
class PinProfilePicProvider extends GetConnect {
  Future<PinProfilePicResponseModel?> pinProfilePic(
      PinProfilePicRequestModel pinProfilePicRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in pinProfilePic', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Chats/user_suggestions',
        pinProfilePicRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in pinProfilePic', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return PinProfilePicResponseModel.fromJson(response.body);
        } else {
          failure('Error in pinProfilePic', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in pinProfilePic', e.toString());
      return null;
    }
  }
}
