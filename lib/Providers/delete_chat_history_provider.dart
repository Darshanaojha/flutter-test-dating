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
        failure('Error in deletechathistoryprovider', 'Token is not found');
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
      if (response.statusCode == null || response.body == null) {
        failure('Error in deletechathistoryprovider', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DeleteChatResponse.fromJson(response.body);
        } else {
          failure('Error in deletechathistoryprovider', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in deletechathistoryprovider', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error in deletechathistoryprovider', e.toString());
      return null;
    }
  }
}
