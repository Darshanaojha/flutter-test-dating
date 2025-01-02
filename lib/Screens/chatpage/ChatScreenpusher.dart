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
        actions: [
          IconButton(
            onPressed: () {
              controller.reportReason().then((value) {
                if (value == true) {
                  showUserOptionsDialog();
                }
              }).catchError((error) {
                print("Error reporting: $error");
              });
            },
            icon: Icon(
              Icons.info,
              color: AppColors.inactiveColor,
            ),
          ),
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

//// report user dailog box started.....................................................===========-------------------
  void showUserOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Block User'),
                onTap: () {
                  controller.blockUser(controller.blockToRequestModel);
                  Navigator.pop(context);
                  success('User Blocked', 'The user has been blocked.');
                },
              ),
              ListTile(
                title: Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  showReportUserDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  RxBool isselected = false.obs;
  RxBool iswriting = false.obs;

  void showReportUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          String displayText =
              controller.reportUserReasonFeedbackRequestModel.reasonId.isEmpty
                  ? 'Select Reason'
                  : controller.reportUserReasonFeedbackRequestModel.reasonId;
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
                        if (value != null && value.isNotEmpty) {
                          setState(() {
                            controller.reportUserReasonFeedbackRequestModel
                                .reasonId = value;
                            isselected.value = true;
                          });
                        } else {
                          setState(() {
                            isselected.value = false;
                          });
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
                      setState(() {
                        controller.reportUserReasonFeedbackRequestModel.reason =
                            value;
                        iswriting.value = value.isNotEmpty;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: iswriting.value
                    ? () {
                        if (controller.reportUserReasonFeedbackRequestModel
                                .reasonId.isNotEmpty &&
                            controller.reportUserReasonFeedbackRequestModel
                                .reason.isNotEmpty) {
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
                      groupValue: controller
                          .reportUserReasonFeedbackRequestModel.reasonId,
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
// reportt dailog box ended.....................................................=================--------------------------------------------------
