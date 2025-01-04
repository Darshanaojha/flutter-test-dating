import 'dart:convert';
import 'package:dating_application/Models/ResponseModels/chat_history_response_model.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../Controllers/controller.dart';
import '../constants.dart';

class WebSocketService {
  Controller controller = Get.put(Controller());
  static final WebSocketService _instance = WebSocketService._internal();
  late StompClient _stompClient;
  bool _isConnected = false;

  /// External callbacks for message handling and other events.
  Function(Map<String, dynamic>)? onMessageReceived;

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  /// Initialize and connect to the WebSocket server.
  Future<void> connect(String token) async {
    if (_isConnected) {
      print("Already connected to WebSocket.");
      return;
    }

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://192.168.1.9:8080/chat',
        onConnect: _onConnect,
        beforeConnect: () async {
          print('Connecting...');
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onWebSocketError: (error) => print('WebSocket Error: $error'),
        onDisconnect: (_) {
          print('Disconnected from WebSocket.');
          _isConnected = false;
        },
      ),
    );

    _stompClient.activate();
  }

  /// Callback triggered when WebSocket connection is established.
  void _onConnect(StompFrame frame) {
    print('WebSocket connected!');

    _isConnected = true;
    String topic = '/topic/${controller.userData.first.id}';

    _stompClient.subscribe(
      headers: {
        'Authorization': 'Bearer ${controller.token.value}',
      },
      destination: topic,
      callback: (frame) {
        if (frame.body != null && frame.body!.isNotEmpty) {
          try {
            print('Received frame: ${frame.body}');

            // Parse the message
            Message message = Message.fromJson(jsonDecode(frame.body!));

            // Validate message format before decryption
            if (!message.message.contains('::')) {
              print('Invalid encrypted message format: ${message.message}');
              return;
            }

            // Decrypt the message
            message.message =
                controller.decryptMessage(message.message, secretkey);
// Assuming message has an 'id' property
            if (controller.messages.any((m) => m.id == message.id)) {
              // Find the index of the message with the same ID
              int index =
                  controller.messages.indexWhere((m) => m.id == message.id);
              // Update the message at that index
              controller.messages[index] = message;
            } else {
              // If no message with the same ID exists, add the new message
              controller.messages.add(message);
            }

            // Add the message to the RxList

            // Log the decrypted message
            print('Decrypted message: ${message.message}');
          } catch (e) {
            print('Error in subscription callback: $e');
            print('Frame body: ${frame.body}');
          }
        } else {
          print('Received empty or null frame body.');
        }
      },
    );

    print('subscribed to the topic : $topic');
  }

  /// Send a message to the WebSocket server.
  void sendMessage(String destination, Map<String, dynamic> message) async {
    if (!_isConnected) {
      print('Cannot send message. Not connected to WebSocket.');
      return;
    }
    _stompClient.send(
      destination: destination,
      headers: {
        'Authorization': 'Bearer ${controller.token.value}',
      },
      body: jsonEncode(message),
    );
  }

  /// Disconnect from the WebSocket server.
  void disconnect() {
    if (_isConnected) {
      _stompClient.deactivate();
      _isConnected = false;
      print('Disconnected from WebSocket.');
    }
  }

  /// Check connection status.
  bool isConnected() => _isConnected;
}
