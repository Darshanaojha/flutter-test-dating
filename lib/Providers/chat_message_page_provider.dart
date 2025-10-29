import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/chat_history_request_model.dart';
import '../Models/ResponseModels/chat_history_response_model.dart';
import '../constants.dart';
class ChatMessagePageProvider extends GetConnect {
  Future<ChatHistoryResponse?> chatHistory(
      ChatHistoryRequestModel chatHistoryRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      print(token);
      print("zzzzz ${chatHistoryRequestModel.toJson()}");
      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Chats/chat_history',
          chatHistoryRequestModel.toJson(),
          headers: {
            'content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print("zzzzz ${chatHistoryRequestModel.toJson()}");
        print("kkkkkk ${response.body}");
        if (response.statusCode == null || response.body == null) {
          failure('Error in chatHistory', 'Server Failed To Respond');
          return null;
        }
        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return ChatHistoryResponse.fromJson(response.body);
          } else {
            failure('Error in chatHistory', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error in chatHistory', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in chatHistory', 'Token is not found');
        return null;
      }
    } catch (e) {
      failure('Error in chatHistory', e.toString());

      return null;
    }
  }
}
