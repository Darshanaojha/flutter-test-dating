import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/establish_connection_response_model.dart';
import '../constants.dart';

class EstablishConnectionProvider extends GetConnect {
  Future<EstablishConnectionResponse?> sendConnectionMessage(
      EstablishConnectionMessageRequest request) async {
    try {

      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token is not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Chats/establish_connection',
        request.toJson(),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return EstablishConnectionResponse.fromJson(response.body);
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
