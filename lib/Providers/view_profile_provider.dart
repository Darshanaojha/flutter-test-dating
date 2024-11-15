import 'package:dating_application/Models/RequestModels/user_profile_update_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_profile_update_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

class ViewProfileProvider extends GetConnect {
  // View Profile
  Future<UserProfileUpdateResponse?> fetchProfile(
      UserProfileUpdateRequest userProfileUpdateRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$baseurl/Profile/profile',
          userProfileUpdateRequest,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return UserProfileUpdateResponse.fromJson(response.body);
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
