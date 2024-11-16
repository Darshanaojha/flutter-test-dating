import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/ResponseModels/chat_history_response_model.dart';
import '../constants.dart';

class ChatMessagePageProvider extends GetConnect {
  Future<ChatHistoryResponse?> chatHistory() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Chats/chat_history',
          null,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return ChatHistoryResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', 'Token is not found');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  
}
