import 'package:dating_application/Models/ResponseModels/all_active_user_resposne_model.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

class FetchAllActiveUserProvider extends GetConnect {
  Future<AllActiveUsersResponse?> getAllActiveUser() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token != null && token.isNotEmpty) {
        Response response = await get(
          "$baseurl/Profile/fetch_all_active_user",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        print('sample ${response.body}');
        print(response.statusCode);
        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return AllActiveUsersResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
        } else {
          failure(
            'Error',
            response.body.toString(),
          );
          return null;
        }
      } else {
        failure('Error', 'Token not found');
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
    return null;
  }
}
