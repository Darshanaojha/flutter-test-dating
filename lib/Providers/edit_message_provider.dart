import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../Models/RequestModels/edit_message_request_model.dart';
import '../Models/ResponseModels/edit_message_response_model.dart';
import '../constants.dart';
class EditMessageProvider extends GetConnect {
  Future<EditMessageResponse?> editMessage(EditMessageRequest request) async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error in editMessage', 'Token is not found');
        return null;
      }

      // Make the API request
      final response = await post(
        '$baseurl/Chats/edit_message',
        jsonEncode(request.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in editMessage', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return EditMessageResponse.fromJson(response.body);
        } else {
          failure('Error in editMessage', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in editMessage', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error in editMessage', e.toString());
      return null;
    }
  }
}
