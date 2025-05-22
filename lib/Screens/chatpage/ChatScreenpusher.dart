import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/chatpage/VideoCallPage.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';

import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import 'AudioCallPage.dart';

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

  // void _sendMessage() {
  //   final messageText = messageController.text.trim();
  //   if (messageText.isNotEmpty) {
  //     websocketService.sendMessage(
  //         '/app/sendMessage',
  //         Message(
  //                 id: null,
  //                 senderId: widget.senderId,
  //                 receiverId: widget.receiverId,
  //                 message: controller.encryptMessage(messageText, secretkey),
  //                 messageType: 1,
  //                 created: DateTime.now().toIso8601String(),
  //                 updated: DateTime.now().toIso8601String(),
  //                 status: 1,
  //                 isEdited: 0,
  //                 deletedBySender: 0,
  //                 deletedByReceiver: 0,
  //                 deletedAtReceiver: null,
  //                 deletedAtSender: null)
  //             .toJson());

  //     messageController.clear();
  //     controller.fetchChats(widget.receiverId);
  //   }
  // }

  Future<void> _sendMessage({
    required String message,
    required String receiverId,
    File? image,
  }) async {
    final sharedPreferences = EncryptedSharedPreferences.getInstance();
    final token = await sharedPreferences
        .getString('token'); // Await here if getString is async

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$springbooturl/ChatController/send-message'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['receiverId'] = receiverId;
    request.fields['message'] = message;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'), // or detect content type
        ),
      );
    }

    print("Sending message: $message");
    print('Receiver ID: $receiverId');
    print('Image: $image');

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('✅ Message sent successfully');
      } else {
        print('❌ Failed to send message. Status code: ${response.statusCode}');
        final body = await response.stream.bytesToString();
        print('Response body: $body');
      }
    } catch (e) {
      print('❗ Exception sending message: $e');
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
    List<Message> selectedMessages = controller.messages
        .where((m) => m.senderId == widget.senderId)
        .toList();
    bool success =
        await controller.deleteChats(selectedMessages); // Your method to delete
    if (success) {
      setState(() {
        controller.messages.removeWhere(
            (m) => selectedMessages.any((selected) => selected.id == m.id));
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

  void _editMessage(String newMessage, int index) async {
    if (newMessage.trim().isNotEmpty) {
      controller.messages[index] =
          controller.messages[index].copyWith(message: newMessage);
    }
    controller.messages[index].deletedAtReceiver = null;
    controller.messages[index].deletedAtSender = null;
    controller.messages[index].deletedBySender = 0;
    controller.messages[index].deletedByReceiver = 0;
    controller.messages[index].isEdited = 1;
    controller.messages[index].message = controller.encryptMessage(
        controller.messages[index].message, secretkey);

    controller.updateChats(controller.messages[index]);

    controller.messages[index].message = controller.decryptMessage(
        controller.messages[index].message, secretkey);
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
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () {
              Get.to(AudioCallPage(
                caller: widget.senderId,
                receiver: widget.receiverId,
              ));
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              Get.to(VideoCallPage(
                caller: widget.senderId,
                receiver: widget.receiverId,
              ));
            },
          ),
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
                    bool hasImage = message.imagePath != null &&
                        message.imagePath!.isNotEmpty;

                    return Slidable(
                      key: Key(message.id ?? ''),
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
                      endActionPane: isSentByUser
                          ? ActionPane(
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
                            )
                          : null,

                      child: GestureDetector(
                        onTap: () {
                          if (selectedMessages.isNotEmpty) {
                            if (isSentByUser) {
                              toggleSelection(message);
                            }
                          }
                        },
                        onLongPress: () {
                          if (selectedMessages.isEmpty) {
                            if (isSentByUser) {
                              Vibration.vibrate(duration: 100);
                              toggleSelection(message);
                            }
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
                                        sent: isSentByUser,
                                        delivered: isSentByUser,
                                        seen: isSentByUser,
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
                                      Container(
                                        padding: isSentByUser
                                            ? EdgeInsets.fromLTRB(0, 0, 5, 0)
                                            : EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: message.isEdited == 1
                                            ? Text(
                                                "(edited)",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                    if (hasImage)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            message.imagePath!,
                                            width: 180,
                                            height: 180,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.broken_image,
                                                        size: 60,
                                                        color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    BubbleSpecialThree(
                                      sent: isSentByUser,
                                      delivered: isSentByUser,
                                      seen: isSentByUser,
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
                                    Container(
                                      padding: isSentByUser
                                          ? EdgeInsets.fromLTRB(0, 0, 5, 0)
                                          : EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      child: message.isEdited == 1
                                          ? Text(
                                              "(edited)",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          : SizedBox.shrink(),
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
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue),
                  onPressed: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      File imageFile = File(pickedFile.path);
                      await _sendMessage(
                        message: '', // or a caption if you want
                        receiverId: widget.receiverId,
                        image: imageFile,
                      );
                      controller.fetchChats(widget.receiverId);
                    }
                  },
                ),
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
                  onPressed: () async {
                    if (messageController.text.trim().isNotEmpty) {
                      await _sendMessage(
                        message: messageController.text.trim(),
                        receiverId: widget.receiverId,
                      );
                      messageController.clear();
                      controller.fetchChats(widget.receiverId);
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

// controller.encryptMessage( messageController.text.trim(), secretkey)
