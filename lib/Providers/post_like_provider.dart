import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect.dart';
import '../Models/RequestModels/liked_by_request_model.dart';
import '../Models/ResponseModels/liked_by_response_model.dart';
import '../constants.dart';
class PostLikeProvider extends GetConnect {
  Future<LikedByResponseModel?> postLike(LikeModel likeModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in postLike', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/post_like',
        likeModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in postLike', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return LikedByResponseModel.fromJson(response.body);
        } else {
          failure('Error in postLike', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in postLike', e.toString());
      return null;
    }
  }
}
