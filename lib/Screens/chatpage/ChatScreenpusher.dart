import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import 'package:vibration/vibration.dart';

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
      websocketService.sendMessage('/app/sendMessage', messagePayload);

      setState(() {
        controller.messages.add(Message(
          id: '0',
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          message: messageText,
          messageType: 1,
          created: DateTime.now().toIso8601String(),
          updated: DateTime.now().toIso8601String(),
          status: 1,
          deletedBySender: 0,
          deletedByReceiver: 0,
          deletedAtReceiver: null,
          deletedAtSender: null,
          isEdited: 0,
        ));
      });

      messageController.clear();
    }
  }

  List<Message> selectedMessages = []; // List to track selected messages
  // Toggle selection of a message
  void toggleSelection(Message message) {
    setState(() {
      if (selectedMessages.contains(message)) {
        selectedMessages.remove(message);
      } else {
        selectedMessages.add(message);
      }
    });
  }

  // Method to delete selected messages
  Future<void> deleteSelectedMessages() async {
    if (selectedMessages.isNotEmpty) {
      bool success = await controller
          .deleteChats(selectedMessages); // Your method to delete
      if (success) {
        setState(() {
          controller.messages
              .removeWhere((msg) => selectedMessages.contains(msg));
          selectedMessages.clear(); // Clear selected messages after deletion
        });
      } else {
        failure('Error', 'Error deleting the chat');
      }
    }
  }

  Future<void> deleteAllMessages() async {
   
    bool success = await controller
        .deleteChats(controller.messages); // Your method to delete
    if (success) {
      setState(() {
        controller.messages.clear();
        selectedMessages.clear();
      });
    } else {
      failure('Error', 'Error deleting the chat');
    }
  }


  Future<void> deleteSingleMessage(int index) async {
    selectedMessages.clear();
    selectedMessages.add(controller.messages[index]);
    bool success =
        await controller.deleteChats(selectedMessages); // Your method to delete
    if (success) {
      setState(() {
        controller.messages
            .removeWhere((msg) => selectedMessages.contains(msg));
        selectedMessages.clear(); // Clear selected messages after deletion
      });
    } else {
      failure('Error', 'Error deleting the chat');
    }
  }

  void _showMessageDialog(BuildContext context, Message message, int index) {
    TextEditingController messageController =
        TextEditingController(text: message.message);

    bool isSentByUser = message.senderId == widget.senderId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
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
                      child: Text('Edit'),
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
    controller.messages[index].deletedBySender = 0;
    controller.messages[index].deletedByReceiver = 0;
    controller.updateChats(controller.messages[index]);
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
        title: Text(widget.receiverName),
        actions: [
          // Add a delete button on the app bar
          selectedMessages.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete Messages"),
                          content: Text("Choose an option to delete messages."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Delete selected messages
                                deleteSelectedMessages();
                                Navigator.pop(context);
                              },
                              child: Text("Delete Selected Messages"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Delete all messages
                                deleteAllMessages();
                                Navigator.pop(context);
                              },
                              child: Text("Delete All Messages"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : SizedBox(),
        ],
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
                  return Dismissible(
                      key: Key(message.id ?? ''),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Delete Message"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Delete selected messages
                                      deleteSingleMessage(index);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Delete Message"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close dialog without action
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              );
                            },
                          );
                          return false;
                        } else if (direction == DismissDirection.startToEnd &&
                            isSentByUser) {
                          _showMessageDialog(context, message, index);
                          return false;
                        }
                        return false;
                      },
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onLongPress: () {
                          Vibration.vibrate(duration: 100);
                          toggleSelection(message);
                        },
                        // Long press to select
                        child: Align(
                          alignment: isSentByUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                              color: isSentByUser
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: selectedMessages.contains(message)
                                  ? Border.all(
                                      color: Colors.yellow,
                                      width: 2) // Highlight selected messages
                                  : Border.all(color: Colors.transparent),
                            ),
                            child: Text(
                              message.message ?? '',
                              style: TextStyle(
                                color:
                                    isSentByUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ));
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
}
