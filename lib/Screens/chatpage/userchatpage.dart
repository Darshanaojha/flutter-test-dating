
import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/ResponseModels/get_all_chat_history_page.dart';

class ChatScreen extends StatelessWidget {
  Controller controller = Get.put(Controller());
  final UserConnections connection;
  final TextEditingController messageController = TextEditingController();

  ChatScreen({required this.connection});

  @override
  Widget build(BuildContext context) {

    RxList<Map<String, dynamic>> messages = [
      {"sender": "John", "message": "Hey, what's up?", "isSent": false},
      {"sender": "You", "message": "Not much, how about you?", "isSent": true},
    ].obs;

    return Scaffold(
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  bool isSent = message['isSent'];
                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSent ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message'],
                        style: TextStyle(
                            color: isSent ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Text input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      // Add message to the list (this would be an API call in a real app)
                      messages.add({
                        "sender": "You",
                        "message": messageController.text,
                        "isSent": true,
                      });

                      // Simulate receiving a response
                      Future.delayed(Duration(seconds: 1), () {
                        messages.add({
                          "sender": connection.name,
                          "message": "I'm good, thanks for asking!",
                          "isSent": false,
                        });
                      });

                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
