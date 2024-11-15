import 'package:dating_application/Models/ResponseModels/delete_message_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../Models/RequestModels/delete_message_request_model.dart';
import '../constants.dart';

class DeleteMessageProvider extends GetConnect {

  Future<DeleteMessageResponse?> deleteMessage(DeleteMessageRequest request) async {
    try {
 
      String? validationError = request.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      final preferences = await EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        throw ArgumentError('Authorization token is missing');
      }

      final response = await post(
        '$baseUrl/Chats/delete_message',
        jsonEncode(request.toJson()), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  
        },
      );

      if (response.statusCode == 200) {

        if (response.body['error']['code'] == 0) {
   
          return DeleteMessageResponse.fromJson(response.body);
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
