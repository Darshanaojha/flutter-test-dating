import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/get_all_chat_history_page.dart';
import '../constants.dart';
class FetchAllUserConnectionsProvider extends GetConnect {
  Future<GetAllChatHistoryPageResponse?>
      fetchalluserconnectionsprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in unknown_method', 'Token not found');
        return null;
      }

      Response response = await get(
        '$baseurl/Profile/connected_user',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in unknown_method', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GetAllChatHistoryPageResponse.fromJson(response.body);
        } else {
          failure('Error in unknown_method', response.body['error']['message']);
          return null;
        }
      } else {
        // failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in unknown_method', e.toString());
      return null;
    }
  }
}