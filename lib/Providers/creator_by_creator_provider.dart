import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/ResponseModels/creator_by_creator_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class CreatorByCreatorProvider extends GetConnect {
  Future<CreatorByCreatorResponse?> fetchByCreator() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await get(
          '$springbooturl/creator/by-creator',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorByCreatorResponse.fromJson(response.body);
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
