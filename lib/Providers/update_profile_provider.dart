import 'package:dating_application/Models/RequestModels/user_profile_update_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_profile_update_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../constants.dart';

class UpdateProfileProvider extends GetConnect {
  Future<UserProfileUpdateResponse?> updateProfile(
      UserProfileUpdateRequest updateProfileRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      print(updateProfileRequest.toJson().toString());
      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/update_profile',
          updateProfileRequest.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }
        print('${response.statusCode}${response.body.toString()}');
        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return UserProfileUpdateResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
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
