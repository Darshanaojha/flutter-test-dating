import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  Controller controller = Get.put(Controller());
  final WebSocketService websocketService = WebSocketService();
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    websocketService.connect(controller.token.value);
  }

  void _sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      final messagePayload = {
        'sender_id': widget.senderId,
        'receiver_id': widget.receiverId,
        'message': messageText,
        'message_type': 1,
        'created': DateTime.now().toIso8601String(),
        'updated': DateTime.now().toIso8601String(),
        'status': 1,
        'is_edited': 0,
        'deleted_by_sender': 0,
        'deleted_by_receiver': 0,
        'deleted_at_sender': null,
        'deleted_at_receiver': null,
      };
      print(messagePayload.toString());
      websocketService.sendMessage('/app/sendMessage', messagePayload);

      setState(() {
        controller.messages.add(Message(
          id: '0',
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          message: messageText,
          messageType: 1,
          created: DateTime.now().toString(),
          updated: DateTime.now().toString(),
          status: 1,
          deletedBySender: 0,
          deletedByReceiver: 0,
          deletedAtReceiver: '0',
          deletedAtSender: '0',
          isEdited: 0,
        ));
      });

      messageController.clear();
    }
  }

  @override
  void dispose() {
    websocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.receiverName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Text(
                  "No chats available".toUpperCase(),
                  style: GoogleFonts.lato(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  bool isSentByUser = message.senderId == widget.senderId;

                  return GestureDetector(
                    onTap: () => _showMessageDialog(context, message, index),
                    child: Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: isSentByUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: AppColors.activeColor,
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, Message message, int index) {
    TextEditingController messageController =
        TextEditingController(text: message.message);

    bool isSentByUser = message.senderId == widget.senderId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit or Delete Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: AppColors.activeColor,
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Edit your message",
                  hintMaxLines: null,
                  enabled: isSentByUser,
                  hintStyle: TextStyle(
                    color: isSentByUser ? Colors.white : Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isSentByUser)
                    ElevatedButton(
                      onPressed: () {
                        _editMessage(messageController.text, index);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Save'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteMessage(index);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(String newMessage, int index) {
    if (newMessage.trim().isNotEmpty) {
      controller.messages[index] =
          controller.messages[index].copyWith(message: newMessage);
    }
    controller.messages[index].deletedAtReceiver = null;
    controller.messages[index].deletedAtSender = null;
    controller.updateChats(controller.messages[index]);
  }

  void _deleteMessage(int index) {
    Message message = controller.messages[index];
    if (message.senderId == controller.userData.first.id) {
      message.deletedBySender = 1;
      message.deletedAtSender = DateTime.now().toIso8601String();
      message.deletedAtReceiver = null;
    } else if (message.receiverId == controller.userData.first.id) {
      message.deletedByReceiver = 1;
      message.deletedAtReceiver = DateTime.now().toIso8601String();
      message.deletedAtSender = null;
    } else {
      failure("Error", "Not authorized to delete the message");
    }
    controller.updateChats(message);
    controller.messages.removeAt(index);
  }
}
