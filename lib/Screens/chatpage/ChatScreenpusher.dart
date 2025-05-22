import 'dart:io';
import 'dart:typed_data';

import 'package:dating_application/Screens/chatpage/VideoCallPage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import 'package:vibration/vibration.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

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
  File? selectedImage;
  final TextEditingController messageController = TextEditingController();
  String? bearerToken =
      EncryptedSharedPreferences.getInstance().getString('token');
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
        controller.messages[index].message ?? '', secretkey);

    controller.updateChats(controller.messages[index]);

    controller.messages[index].message = controller.decryptMessage(
        controller.messages[index].message ?? '', secretkey);
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
                                    message.message == null ? SizedBox.shrink():
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
                                    if (message.imagePath != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: buildImageWithAuth(
                                            message.imagePath!, bearerToken!),
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
                Row(
                  children: [
                    // Image picker icon (only selects and stores image)
                    IconButton(
                      icon: Icon(Icons.image),
                      color: Colors.orange,
                      onPressed: () async {
                        final pickedFile = await showModalBottomSheet<XFile?>(
                          context: context,
                          builder: (context) => _buildImagePickerOptions(),
                        );

                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    if (selectedImage != null)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: Image.file(selectedImage!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: FileImage(selectedImage!),
                          ),
                        ),
                      ),

                    // Send button (sends text + selected image if any)
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.green,
                      onPressed: () async {
                        final messageText = messageController.text.trim();

                        if (messageText.isNotEmpty || selectedImage != null) {
                          await _sendMessage(
                            message: messageText,
                            receiverId: widget.receiverId,
                            image: selectedImage,
                          );

                          // Clear after sending
                          messageController.clear();
                          selectedImage = null;
                          controller.fetchChats(widget.receiverId);
                        } else {
                          Get.snackbar("Empty Message",
                              "Please type a message or select an image.");
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerOptions() {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'),
            onTap: () async {
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              Navigator.pop(context, picked);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () async {
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              Navigator.pop(context, picked);
            },
          ),
        ],
      ),
    );
  }

  FutureBuilder<Uint8List> buildImageWithAuth(
      String imagePath, String bearerToken) {
    return FutureBuilder<Uint8List>(
      future: _fetchImageBytes(imagePath, bearerToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Icon(Icons.broken_image);
        } else if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(
                    child: Image.memory(snapshot.data!),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Future<Uint8List> _fetchImageBytes(
      String imagePath, String bearerToken) async {

    final response = await http.get(
      Uri.parse('$springbooturl/ChatController/uploads/$imagePath'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
  
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }
}

// controller.encryptMessage( messageController.text.trim(), secretkey)