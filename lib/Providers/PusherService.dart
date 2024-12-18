import 'dart:convert';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'package:pusher_client/pusher_client.dart';

import '../Models/RequestModels/send_message_request_model.dart';
import '../constants.dart';

class PusherService extends GetConnect {
  PusherClient? _pusher;
  late Channel _channel;

  void initPusher(int senderId, int receiverId) {
    String channelName = 'chat-$senderId-$receiverId';

    var options = PusherOptions(cluster: 'your-cluster');
    _pusher = PusherClient(
      'your-app-key',
      options,
      autoConnect: true,
    );

    _channel = _pusher!.subscribe(channelName);

    _channel.bind('server-message', (PusherEvent? event) {
      if (event != null) {
        var data = json.decode(event.data!);
        print('Received message: ${data['message']}');
      } else {
        print("Event is null");
      }
    });

    _pusher!.connect();
  }

  void sendMessageToChannel(int senderId, int receiverId, String message) {
    String channelName = 'chat-$senderId-$receiverId';

    _channel.trigger('client-message', {'message': message});
  }

  Future<bool> sendMessageApi(
      SendMessageRequestModel sendMessageRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return false;
      }

      Response response = await post(
        '$baseurl/Chats/sendMessage',
        sendMessageRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return true;
        } else {
          failure('Error', response.body['error']['message']);
          return false;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  void disconnectPusher() {
    _pusher?.disconnect();
  }
}
