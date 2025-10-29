import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/update_emailid_request_model.dart';
import '../Models/ResponseModels/update_emailid_response_model.dart';
import '../constants.dart';

class UpdateEmailidProvider extends GetConnect {
  Future<UpdateEmailIdResponse?> updateEmailId(
      UpdateEmailIdRequest updateEmailIdRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      print("Request updateEmailId : ${updateEmailIdRequest.toJson()}");

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/update_email',
          updateEmailIdRequest.toJson(),
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
            print("Response updateEmailId : ${response.body}");
            return UpdateEmailIdResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error', response.body.toString());
          return null;
        }
      } else {
        failure('Error', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
