import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/RequestModels/add_user_to_creator_request.dart';
import 'package:dating_application/Models/ResponseModels/add_user_to_creator_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class AddUserToCreatorProvider extends GetConnect {
  Future<AddUserToCreatorResponse?> addUserToCreator(AddUserToCreatorRequest request) async {
    try {
      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$springbooturl/creator/add-user-to-creator',
          request.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in addUserToCreator', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return AddUserToCreatorResponse.fromJson(response.body);
        } else {
          failure('Error in addUserToCreator', response.body.toString());
          return null;
        }
      } else {
        failure('Error in addUserToCreator', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in addUserToCreator', e.toString());
      return null;
    }
  }
}