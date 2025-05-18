import 'package:dating_application/constants.dart';
import 'package:get/get.dart';
import 'package:dating_application/Models/RequestModels/add_user_to_content_request.dart';
import 'package:dating_application/Models/ResponseModels/add_user_to_content_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class AddUserToContentProvider extends GetConnect {
  Future<AddUserToContentResponse?> addUserToContent(
      AddUserToContentRequest request) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$springbooturl/creator/add-user-to-content',
          request.toJson(),
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
          return AddUserToContentResponse.fromJson(response.body);
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
