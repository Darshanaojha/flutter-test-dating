
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../Models/RequestModels/delete_chat_history_request_model.dart';
import '../Models/ResponseModels/delete_chat_history_response.dart';
import '../constants.dart';

class DeleteChatHistoryProvider extends GetConnect {
  Future<DeleteChatResponse?> deletechathistoryprovider(
      DeleteChatRequest deleteChatRequest) async {
    try {
      

      final preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token is not found');
        return null;
      }

      final response = await post(
        '$baseurl/chats/delete_all_chat',
        jsonEncode(deleteChatRequest.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DeleteChatResponse.fromJson(response.body);
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