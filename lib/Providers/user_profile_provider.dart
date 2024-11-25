import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/ResponseModels/user_upload_images_response_model.dart';
import '../constants.dart';

class UserProfileProvider extends GetConnect {
  Future<UserUploadImagesResponse?> fetchProfileUserPhotos() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await post(
        '$baseurl/Profile/userphotos',
        null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
  
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
        
          return UserUploadImagesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
