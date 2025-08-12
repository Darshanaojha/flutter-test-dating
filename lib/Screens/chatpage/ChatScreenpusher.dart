import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

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
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import 'AudioCallPage.dart';
import '../userprofile/userprofilesummary.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
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
    final token = sharedPreferences
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
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          backgroundColor: Colors
              .transparent, // Make dialog background transparent for gradient
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.chat,
                      color: Colors.white, size: 48), // Changed to chat icon
                ),
                SizedBox(height: 18),
                Text(
                  "Edit Message",
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: 20,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  cursorColor: AppColors.activeColor,
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: "Edit your message",
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.buttonColor, width: 2.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGradientColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: Icon(Icons.check),
                      label: Text("Update"),
                      onPressed: () {
                        _editMessage(messageController.text, index);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
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

  RxString selectedReason = ''.obs;
  bool isLoading = true;
  RxBool isselected = false.obs;
  RxBool iswriting = false.obs;
  RxString reportDescription = ''.obs;

  @override
  void dispose() {
    websocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Get.bottomSheet(
              UserProfileSummary(
                userId: widget.receiverId,
              ),
              isScrollControlled: true,
              backgroundColor: AppColors.primaryColor,
              enterBottomSheetDuration: Duration(milliseconds: 300),
              exitBottomSheetDuration: Duration(milliseconds: 300),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.receiverImageUrl),
                radius: 20,
              ),
              SizedBox(width: 10),
              Text(
                widget.receiverName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 3,
                offset: Offset(0, 6),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
        ),
        actions: [
          if (selectedMessages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 12,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.gradientBackgroundList,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 24, horizontal: 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.chat,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            SizedBox(height: 18),
                            Text(
                              "Delete Messages",
                              style: AppTextStyles.headingText.copyWith(
                                fontSize: 20,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Choose an option to delete messages.",
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 22),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.mediumGradientColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                    ),
                                    icon: Icon(Icons.delete_sweep),
                                    label: Text("Delete Selected"),
                                    onPressed: () {
                                      deleteSelectedMessages();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                    ),
                                    icon: Icon(Icons.delete_forever),
                                    label: Text("Delete All"),
                                    onPressed: () {
                                      deleteAllMessages();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'audio') {
                if (await _requestPermission(
                    Permission.microphone, "Microphone")) {
                  Get.to(AudioCallPage(
                    caller: widget.senderId,
                    receiver: widget.receiverId,
                  ));
                }
              } else if (value == 'video') {
                if (await _requestPermission(Permission.camera, "Camera") &&
                    await _requestPermission(
                        Permission.microphone, "Microphone")) {
                  Get.to(VideoCallPage(
                    caller: widget.senderId,
                    receiver: widget.receiverId,
                  ));
                }
              } else if (value == 'report') {
                showReportUserDialog(widget.receiverId);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'audio',
                child: ListTile(leading: Icon(Icons.phone), title: Text('Audio Call')),
              ),
              const PopupMenuItem<String>(
                value: 'video',
                child: ListTile(leading: Icon(Icons.videocam), title: Text('Video Call')),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: ListTile(leading: Icon(Icons.report), title: Text('Report User')),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    controller: scrollController,
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      print(
                          "Message Image sensitivity: ${message.sensitivity}");
                      bool isSentByUser = message.senderId == widget.senderId;

                      return Slidable(
                        key: Key(message.id ?? ''),
                        // Specify the start-to-end action pane (Edit button)
                        startActionPane:
                            isSentByUser && message.imagePath == null
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
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            elevation: 12,
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: AppColors
                                                      .gradientBackgroundList,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 24, horizontal: 18),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                    padding: EdgeInsets.all(16),
                                                    child: Icon(
                                                      Icons.chat,
                                                      color: Colors.white,
                                                      size: 48,
                                                    ),
                                                  ),
                                                  SizedBox(height: 18),
                                                  Text(
                                                    "Delete Message",
                                                    style: AppTextStyles
                                                        .headingText
                                                        .copyWith(
                                                      fontSize: 20,
                                                      color:
                                                          AppColors.textColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "Are you sure you want to delete this message?",
                                                    style: AppTextStyles
                                                        .bodyText
                                                        .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 22),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          textStyle: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        child: Text("Cancel"),
                                                      ),
                                                      SizedBox(width: 8),
                                                      ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor: AppColors
                                                              .darkGradientColor,
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                          ),
                                                          elevation: 4,
                                                        ),
                                                        icon:
                                                            Icon(Icons.delete),
                                                        label: Text("Delete"),
                                                        onPressed: () {
                                                          deleteSingleMessage(
                                                              index);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                      message.message == null
                                          ? SizedBox.shrink()
                                          : BubbleSpecialThree(
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
                                          child: SensitiveImageWidget(
                                            imagePath: message.imagePath!,
                                            bearerToken: bearerToken!,
                                            sensitivity:
                                                message.sensitivity ?? 0,
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
                  // Message input with rounded card and slight elevation
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: TextField(
                          cursorColor: Colors.black87,
                          controller: messageController,
                          style: AppTextStyles.inputFieldText
                              .copyWith(fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTextStyles.bodyText
                                .copyWith(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image picker icon with gradient background
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.18),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.image, color: Colors.white),
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
                  ),
                  // Show selected image as a small avatar
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
                          radius: 22,
                          backgroundImage: FileImage(selectedImage!),
                        ),
                      ),
                    ),
                  // Send button with gradient background
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.18),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        final messageText = messageController.text.trim();
                        if (messageText.isNotEmpty || selectedImage != null) {
                          await _sendMessage(
                            message: messageText,
                            receiverId: widget.receiverId,
                            image: selectedImage,
                          );
                          messageController.clear();
                          setState(() {
                            selectedImage = null;
                          });
                          controller.fetchChats(widget.receiverId);
                        } else {
                          Get.snackbar("Empty Message",
                              "Please type a message or select an image.");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              final picked = await _pickImage(ImageSource.gallery);
              Navigator.pop(context, picked);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () async {
              final picked = await _pickImage(ImageSource.camera);
              Navigator.pop(context, picked);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(
      Permission permission, String permissionName) async {
    var status = await permission.status;
    if (status.isGranted || (status.isLimited && Platform.isIOS)) {
      return true;
    } else if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || (status.isLimited && Platform.isIOS)) {
        return true;
      } else {
        Get.snackbar(
            'Permission Denied', "$permissionName permission is required.");
        return false;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      Get.snackbar(
        'Permission Required',
        "$permissionName permission has been permanently denied. Please enable it in app settings.",
        mainButton: TextButton(
          child: const Text("Open Settings"),
          onPressed: () {
            openAppSettings();
          },
        ),
        duration: const Duration(seconds: 5),
      );
      return false;
    }
    return false;
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      // Handle platform-specific permissions
      if (Platform.isAndroid) {
        // On Android 13+, we need both photos and storage permissions
        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted) {
          return true;
        }

        // Request the appropriate permissions
        final status = await Permission.storage.request();
        if (status.isGranted) return true;

        // If storage is denied but photos is granted (Android 13+)
        if (await Permission.photos.isGranted) return true;

        // Final fallback request
        final photosStatus = await Permission.photos.request();
        return photosStatus.isGranted;
      } else if (Platform.isIOS) {
        // On iOS, we only need photos permission
        var status = await Permission.photos.status;

        if (status.isGranted || status.isLimited) {
          return true;
        }

        // Request permission if not determined
        status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }

      // Default case for other platforms
      return false;
    } catch (e) {
      print('Error checking gallery permission: $e');
      return false;
    }
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      bool permissionGranted = false;

      if (source == ImageSource.camera) {
        permissionGranted =
            await _requestPermission(Permission.camera, "Camera");
      } else if (source == ImageSource.gallery) {
        permissionGranted = await _requestGalleryPermission();

        // Additional check to prevent settings popup when permission is actually granted
        if (!permissionGranted) {
          final currentStatus = Platform.isAndroid
              ? (await Permission.storage.status).isGranted ||
                  (await Permission.photos.status).isGranted
              : (await Permission.photos.status).isGranted ||
                  (await Permission.photos.status).isLimited;

          if (currentStatus) {
            permissionGranted = true;
          }
        }
      }

      if (!permissionGranted) {
        // Only show settings suggestion if permission is truly denied
        final status = Platform.isAndroid
            ? await Permission.storage.status
            : await Permission.photos.status;

        if (status.isPermanentlyDenied || status.isRestricted) {
          _showPermissionSettingsDialog(
              context, Platform.isAndroid ? "Storage" : "Photos");
        }
        return null;
      }

      return await ImagePicker().pickImage(source: source);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void _showPermissionSettingsDialog(
      BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text(
            "$permissionName permission is required to access this feature. "
            "Please enable it in your device settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void showReportUserDialog(reporttouserid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          String displayText = selectedReason.value.isEmpty
              ? 'Select Reason'
              : selectedReason.value;
          String truncatedText = displayText.length > 30
              ? '${displayText.substring(0, 30)}...'
              : displayText;

          return AlertDialog(
            title: Text('Report User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.activeColor, width: 2),
                    ),
                  ),
                  onPressed: () {
                    showBottomSheet(
                      context: context,
                      label: "Select Reason",
                      options: controller.reportReasons
                          .map((reason) => reason.title)
                          .toList(),
                      onSelected: (String? value) {
                        Get.snackbar(
                            "selected reasonId",
                            controller
                                .reportUserReasonFeedbackRequestModel.reasonId
                                .toString());
                        if (value != null && value.isNotEmpty) {
                          selectedReason.value = value;
                          isselected.value = true;
                        } else {
                          isselected.value = false;
                        }
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          truncatedText,
                          style: AppTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.activeColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (isselected.value)
                  TextField(
                    cursorColor: AppColors.cursorColor,
                    maxLength: 60,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.textColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      reportDescription.value = value;
                      iswriting.value = value.isNotEmpty;
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: iswriting.value
                    ? () {
                        if (selectedReason.value.isNotEmpty &&
                            reportDescription.value.isNotEmpty) {
                          controller.reportUserReasonFeedbackRequestModel
                              .reasonId = selectedReason.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reason = reportDescription.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reportAgainst = reporttouserid;
                          Get.snackbar(
                              "selected reason",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reason
                                  .toString());
                          Get.snackbar(
                              "selected reasonId",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reasonId
                                  .toString());
                          Get.snackbar(
                              "selected report against",
                              controller.reportUserReasonFeedbackRequestModel
                                  .reportAgainst
                                  .toString());
                          controller.reportAgainstUser(
                              controller.reportUserReasonFeedbackRequestModel);
                          Navigator.pop(context);

                          success('Report Submitted',
                              'The user has been reported.');
                        } else {
                          failure('Error',
                              'Please select a reason and provide a description.');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Submit Report'),
              ),
            ],
          );
        });
      },
    );
  }

  void showBottomSheet({
    required BuildContext context,
    required String label,
    required List<String> options,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText.copyWith(fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: List.generate(options.length, (index) {
                    return RadioListTile<String>(
                      title:
                          Text(options[index], style: AppTextStyles.bodyText),
                      value: options[index],
                      groupValue: selectedReason.value,
                      onChanged: (String? value) {
                        onSelected(value);
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.activeColor,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// controller.encryptMessage( messageController.text.trim(), secretkey)

class SensitiveImageWidget extends StatefulWidget {
  final String imagePath;
  final String bearerToken;
  final int sensitivity;

  const SensitiveImageWidget({
    super.key,
    required this.imagePath,
    required this.bearerToken,
    required this.sensitivity,
  });

  @override
  State<SensitiveImageWidget> createState() => _SensitiveImageWidgetState();
}

class _SensitiveImageWidgetState extends State<SensitiveImageWidget> {
  bool _showBlur = true;
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImageBytes(widget.imagePath, widget.bearerToken);
  }

  @override
  void didUpdateWidget(covariant SensitiveImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath ||
        widget.bearerToken != oldWidget.bearerToken) {
      _imageFuture = _fetchImageBytes(widget.imagePath, widget.bearerToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.broken_image);
        } else if (snapshot.hasData) {
          Widget chatBubbleImage = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              snapshot.data!,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          );

          Widget fullScreenImage = Image.memory(
            snapshot.data!,
          );

          if (widget.sensitivity == 1 && _showBlur) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Sensitive Content"),
                    content: const Text(
                        "This image contains 18+ content. Are you sure you want to view it?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showBlur = false;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Proceed"),
                      ),
                    ],
                  ),
                );
              },
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: chatBubbleImage,
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Sensitive Content",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Not sensitive or user has chosen to view
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: InteractiveViewer(
                          child: fullScreenImage,
                        ),
                      ),
                    );
                  },
                );
              },
              child: chatBubbleImage,
            );
          }
        } else {
          return const SizedBox.shrink();
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
