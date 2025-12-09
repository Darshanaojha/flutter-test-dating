import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/user_upload_images_response_model.dart';
import '../constants.dart';
class UserProfileProvider extends GetConnect {
  Future<UserUploadImagesResponse?> fetchProfileUserPhotos(String id) async {
    print("id in fetchProfileUserPhotos: $id");
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      print("token in fetchProfileUserPhotos: $token");
      if (token == null || token.isEmpty) {
        failure('Error in fetchProfileUserPhotos', 'Token not found');
        return null;
      }
      Response response = await get(
        '$baseurl/Profile/userphotos/$id',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print("response body in fetchProfileUserPhotos: ${response.body}");
      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchProfileUserPhotos', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserUploadImagesResponse.fromJson(response.body);
        } else {
          failure('Error in fetchProfileUserPhotos', response.body['error']['message']);
          return null;
        }
      } else {
        // failure('Error in fetchProfileUserPhotos', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error in user photo', e.toString());
      return null;
    }
  }
}