import 'dart:convert';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../Models/RequestModels/send_message_request_model.dart';
import '../constants.dart';

class PusherService extends GetConnect {
  late PusherChannelsFlutter pusher;
  late PusherChannel _channel;
  Function(String)? onServerMessageReceived;
  Future<void> initPusher(String senderId, String receiverId) async {
    String channelName = 'private-chat-$senderId-$receiverId';

    pusher = PusherChannelsFlutter();
    dynamic onAuthorizer(
        String channelName, String socketId, dynamic options) async {
      try {
        EncryptedSharedPreferences preferences =
            await EncryptedSharedPreferences.getInstance();
        String? token = preferences.getString('token');

        if (token == null || token.isEmpty) {
          failure('Error', 'Token not found');
          return false;
        }
        final response = await post(
          '$baseurl/Chats/getAuthorizationForChannel',
          {
            'channel_name': channelName,
            'socket_id': socketId,
            'sender_id': senderId,
          },
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Internal Server Error');
          return null;
        }
        if (response.statusCode == 200) {
          var payload = json.decode(response.body['payload']);
          String authToken = payload['auth'];
          print(authToken);
          return {'auth': authToken};
        } else {
          throw Exception('Failed to authorize');
        }
      } catch (e) {
        print('Authorization error: $e');
        return {'error': 'Authorization failed'};
      }
    }

    await pusher.init(
      apiKey: PusherConstants.key,
      cluster: PusherConstants.cluster,
      useTLS: true,
      activityTimeout: 5000,
      pongTimeout: 5000,
      maxReconnectionAttempts: 10,
      maxReconnectGapInSeconds: 5,
      logToConsole: true,
      onConnectionStateChange: (currentState, previousState) {
        print("Connection state changed: $currentState -> $previousState");
      },
      onError: (error, code, message) {
        print("Error: $error | $code | $message");
      },
      onEvent: (PusherEvent? event) {
        if (event != null) {
          var data = json.decode(event.data);
          print('Received message: ${data['message']}');
        } else {
          print("Event is null");
        }
      },
      onAuthorizer: onAuthorizer,
    );

    await pusher.connect();

    pusher.subscribe(channelName: channelName).then((PusherChannel channel) {
      _channel = channel;

      _channel.onEvent = (dynamic event) {
        if (onServerMessageReceived != null) {
          onServerMessageReceived!(event.data);
        }
        PusherEvent? pusherEvent = event as PusherEvent?;

        if (pusherEvent != null) {
          var data = json.decode(pusherEvent.data);
          success('Message', data['message']);
        } else {
          print("Event is null");
        }
      };
    }).catchError((error) {
      print('Error subscribing to channel: $error');
    });
  }

  void sendMessageToChannel(
      String senderId, String receiverId, String message) {
    String channelName = 'private-chat-$senderId-$receiverId';
    PusherEvent event = PusherEvent(
        channelName: channelName,
        eventName: 'client-message',
        data: json.encode({'message': message}),
        userId: senderId);
    print(event.toString());
    pusher.trigger(event).catchError((error) {
      print('Error sending message: $error');
    });
  }

  void disconnectPusher() {
    pusher.disconnect();
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
          print('message sent to backend successfully');
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
}
