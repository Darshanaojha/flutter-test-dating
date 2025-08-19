import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class UpdateIncognitoStatusProvider extends GetConnect {
  Future<bool> updateIncognitoStatus({required int status}) async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      final token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await put(
          '$springbooturl/users/incognito-status-update',
          {
            'status': status,
          },
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in updateIncognitoStatus', 'Server Failed To Respond');
          return false;
        }

        if (response.statusCode == 200) {
          success('Success', 'Incognito status updated');
          return true;
        } else {
          failure('Error in updateIncognitoStatus', response.body.toString());
          return false;
        }
      } else {
        failure('Error in updateIncognitoStatus', 'Token not found');
        return false;
      }
    } catch (e) {
      failure('Error in updateIncognitoStatus', e.toString());
      return false;
    }
  }
}
