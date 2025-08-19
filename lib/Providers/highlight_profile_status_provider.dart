import 'package:dating_application/Models/RequestModels/highlight_profile_status_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/highlight_profile_status_response_model.dart';
import '../constants.dart';
class HighlightProfileStatusProvider extends GetConnect {
  Future<HighlightProfileStatusResponse?> highlightProfileStatus(
      HighlightProfileStatusRequest highlightProfileStatusRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/request_to_highlight_accounts',
          highlightProfileStatusRequest.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == null || response.body == null) {
          failure('Error in highlightProfileStatus', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return HighlightProfileStatusResponse.fromJson(response.body);
          } else {
            failure('Error in highlightProfileStatus', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error in highlightProfileStatus', response.body.toString());
          return null;
        }
      } else {
        failure('Error in highlightProfileStatus', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in highlightProfileStatus', e.toString());
      return null;
    }
  }
}
