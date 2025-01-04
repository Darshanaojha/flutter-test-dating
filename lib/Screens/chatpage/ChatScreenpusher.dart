import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import 'package:vibration/vibration.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

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
      websocketService.sendMessage(
          '/app/sendMessage',
          Message(
                  id: null,
                  senderId: widget.senderId,
                  receiverId: widget.receiverId,
                  message: controller.encryptMessage(messageText, secretkey),
                  messageType: 1,
                  created: DateTime.now().toIso8601String(),
                  updated: DateTime.now().toIso8601String(),
                  status: 1,
                  isEdited: 0,
                  deletedBySender: 0,
                  deletedByReceiver: 0,
                  deletedAtReceiver: null,
                  deletedAtSender: null)
              .toJson());

      messageController.clear();
      controller.fetchChats(widget.receiverId);
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

  void _editMessage(String newMessage, int index) async{
    if (newMessage.trim().isNotEmpty) {
      controller.messages[index] =
          controller.messages[index].copyWith(message: newMessage);
    }
    controller.messages[index].deletedAtReceiver = null;
    controller.messages[index].deletedAtSender = null;
    controller.messages[index].deletedBySender = 0;
    controller.messages[index].deletedByReceiver = 0;
    controller.messages[index].message = controller.encryptMessage(
        controller.messages[index].message, secretkey);
    await controller.updateChats(controller.messages[index]);
    controller.fetchChats(widget.receiverId);
  }

  @override
  void dispose() {
    websocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        centerTitle: true,
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
            child: Obx(() => ListView.builder(
                  controller: scrollController,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    bool isSentByUser = message.senderId == widget.senderId;

                    return Slidable(
                      key: Key(message.id ?? ''),
                      endActionPane: ActionPane(
                        motion: DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Message"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          deleteSingleMessage(index);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Delete"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,

                            // label: 'Delete',
                          ),
                        ],
                      ),
                      // Specify the start-to-end action pane (Edit button)
                      startActionPane: isSentByUser
                          ? ActionPane(
                              motion: DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: isSentByUser
                                      ? (context) {
                                          _showMessageDialog(
                                              context, message, index);
                                        }
                                      : null, // Disable edit for messages not sent by the user
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  //  label: 'Edit',
                                ),
                              ],
                            )
                          : null,
                      child: GestureDetector(
                        onTap: () {
                          if (selectedMessages.isNotEmpty) {
                            toggleSelection(message);
                          }
                        },
                        onLongPress: () {
                          if (selectedMessages.isEmpty) {
                            Vibration.vibrate(duration: 100);
                            toggleSelection(message);
                          }
                        },
                        child: Stack(
                          children: [
                            // Wrap the message bubble in a container and conditionally change the background color
                            if (selectedMessages.contains(message))
                              Container(
                                color: Colors
                                    .red, // Set background color to yellow when selected
                                margin: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal:
                                        10), // Adjust margin for spacing
                                child: Align(
                                  alignment: isSentByUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isSentByUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      BubbleSpecialThree(
                                        text: message.message ?? '',
                                        isSender: isSentByUser,
                                        color: isSentByUser
                                            ? Colors.blueAccent
                                            : Colors.grey[300]!,
                                        textStyle: TextStyle(
                                          color: isSentByUser
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // If not selected, show the regular message bubble without background
                            if (!selectedMessages.contains(message))
                              Align(
                                alignment: isSentByUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: isSentByUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    BubbleSpecialThree(
                                      text: message.message ?? '',
                                      isSender: isSentByUser,
                                      color: isSentByUser
                                          ? Colors.blueAccent
                                          : Colors.grey[300]!,
                                      textStyle: TextStyle(
                                        color: isSentByUser
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
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
                  color: Colors.green,
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
