import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/ResponseModels/get_content_by_id_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class GetContentByIdProvider extends GetConnect {
  Future<CreatorContentByIdResponse?> fetchContentById(String contentId) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await get(
          '$springbooturl/creator/get-content-by-id/$contentId',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in fetchContentById', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorContentByIdResponse.fromJson(response.body);
        } else {
          failure('Error in fetchContentById', response.body.toString());
          return null;
        }
      } else {
        failure('Error in fetchContentById', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in fetchContentById', e.toString());
      return null;
    }
  }
}
