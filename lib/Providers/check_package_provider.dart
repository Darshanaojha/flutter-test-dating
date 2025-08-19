import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
class CheckPackageProvider extends GetConnect {
  Future<bool> checkUserPackage() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token != null && token.isNotEmpty) {
        Response response = await get(
          "$baseurl/Profile/check_user_package",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        print('check_user_package response : ${response.body}');
        if (response.statusCode == null || response.body == null) {
          failure('Error in checkUserPackage', 'Server Failed To Respond');
          return false;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return true;
          } else {
            failure('Error in checkUserPackage', response.body['error']['message']);
            return false;
          }
        } else {
          failure(
            'Error',
            response.body.toString(),
          );
          return false;
        }
      } else {
        failure('Error in checkUserPackage', 'Token not found');
        return false;
      }
    } catch (e) {
      failure('Error in checkUserPackage', e.toString());
      return false;
    }
  }
}
