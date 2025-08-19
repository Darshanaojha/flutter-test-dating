import 'package:dating_application/Models/ResponseModels/get_all_request_message_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../constants.dart';
class FetchAllRequestMessageProvider extends GetConnect {
  Future<GetAllRequestPingMessageResponse?>
      fetchallrequestmessageprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in unknown_method', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/pings',
        null,
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
          return GetAllRequestPingMessageResponse.fromJson(response.body);
        } else {
          failure('Error in unknown_method', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in unknown_method', e.toString());
      return null;
    }
  }
}
