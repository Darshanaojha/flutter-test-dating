import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/ResponseModels/user_suggestions_response_model.dart';
import '../constants.dart';

class UserSuggestionsProvider extends GetConnect {
  Future<UserSuggestionsResponseModel?> userSuggestions() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await get(
        '$baseurl/Chats/user_suggestions',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['error']['code'] == 0) {
                print("user suggestion response in provider = ${response.body.toString()}");
          return UserSuggestionsResponseModel.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
