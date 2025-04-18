import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/deletefavourite_request_model.dart';
import '../Models/ResponseModels/deletefavourite_response_model.dart';
import '../constants.dart';

class DeletefavouriteProviderModel extends GetConnect {
  Future<DeleteFavouriteResponse?> deletefavouriteprovider(
      DeleteFavouritesRequest deleteFavouritesRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/deleteFavourites',
        deleteFavouritesRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DeleteFavouriteResponse.fromJson(response.body);
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
