import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/usernameupdate_request_model.dart';
import '../Models/ResponseModels/usernameupdate_response_model.dart';
import '../constants.dart';
class UsernameUpdateProvider extends GetConnect {
  Future<UsernameUpdateResponse?> updateUsername(
      UsernameUpdateRequest usernameUpdateRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/update_username',
          usernameUpdateRequest.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == null || response.body == null) {
          failure('Error in updateUsername', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return UsernameUpdateResponse.fromJson(response.body);
          } else {
            failure('Error in updateUsername', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error in updateUsername', response.body.toString());
          return null;
        }
      } else {
        failure('Error in updateUsername', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in updateUsername', e.toString());
      return null;
    }
  }
}
