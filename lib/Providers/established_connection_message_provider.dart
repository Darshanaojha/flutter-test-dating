import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/establish_connection_response_model.dart';
import '../constants.dart';
class EstablishConnectionProvider extends GetConnect {
  Future<EstablishConnectionResponse?> sendConnectionMessage(
      EstablishConnectionMessageRequest establishConnectionMessageRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token is not found');
        return null;
      }

      Get.snackbar('Request', establishConnectionMessageRequest.toJson().toString());

      Response response = await post(
        '$baseurl/Chats/establish_connection',
        establishConnectionMessageRequest.toJson(),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      Get.snackbar('Response', response.body.toString());

      if (response.statusCode == 200) {
        if (response.body['error'] != null) {
          final errorCode = response.body['error']['code'];
          final errorMessage = response.body['error']['message'];
          print(errorMessage.toString());
          if (errorCode == 0) {
            return EstablishConnectionResponse.fromJson(response.body);
          } else {
            failure('Error', errorMessage);
            return null;
          }
        } else {
          return EstablishConnectionResponse.fromJson(response.body);
        }
      } else {
        failure('Error', 'Unexpected error: ${response.body['error']['message']}');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      print('Exception occurred: $e');
      return null;
    }
  }
}
