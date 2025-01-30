import 'package:dating_application/Models/ResponseModels/get_all_favourites_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../constants.dart';

class FetchAllFavouritesProvider extends GetConnect {
  Future<GetFavouritesResponse?> fetchallfavouritesprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      final response = await get(
        '$baseurl/Profile/getFavourites',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          print("favourites response = ${response.body.toString()}");
          return GetFavouritesResponse.fromJson(response.body);
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
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
