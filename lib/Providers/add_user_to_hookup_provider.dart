import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class AddHookupRequestProvider extends GetConnect {
  Future<bool> addHookupRequest({required String interestedId}) async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      final token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$springbooturl/chat-hookup/add',
          {
            'interestedId': interestedId,
          },
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return false;
        }

        if (response.statusCode == 200) {
          success('Success', 'Hookup request sent');
          return true;
        } else {
          failure('Error', response.body.toString());
          return false;
        }
      } else {
        failure('Error', 'Token not found');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }
}
