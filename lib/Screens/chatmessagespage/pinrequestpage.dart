import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/estabish_connection_request_model.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class MessageRequestPage extends StatefulWidget {
  const MessageRequestPage({super.key});

  @override
  MessageRequestPageState createState() => MessageRequestPageState();
}

class MessageRequestPageState extends State<MessageRequestPage> {
  final Controller controller = Get.find();

  void showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: 300,
                width: 300,
              ),
            ),
          ),
        );
      },
    );
  }

  String formatRequestDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('dd/MM/yy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.05;
            return Text(
              'Message Requests',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        foregroundColor: AppColors.textColor,
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
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          final receivedMessages = controller.messageRequest
              .where((request) => request.messageSendByMe == 0)
              .toList();

          if (receivedMessages.isEmpty) {
            return Center(
              child: Lottie.asset(
                "assets/animations/requestmessageanimation.json",
                repeat: true,
                reverse: true,
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;

              return ListView.builder(
                itemCount: receivedMessages.length,
                itemBuilder: (context, index) {
                  final messageRequest = receivedMessages[index];

                  return Card(
                    // margin: EdgeInsets.only(bottom: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      leading: GestureDetector(
                        onTap: () =>
                            showImageDialog(messageRequest.profileImage),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(messageRequest.profileImage),
                          radius: screenWidth < 600 ? 30 : 40,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              messageRequest.name,
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: screenWidth < 600 ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            formatRequestDate(messageRequest.created),
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.disabled,
                              fontSize: screenWidth < 600 ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        messageRequest.message,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.disabled,
                          fontSize: screenWidth < 600 ? 14 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.reply,
                            color: AppColors.lightGradientColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyMessagePage(
                                senderName: messageRequest.name,
                                senderId: messageRequest.userId,
                                lastMessage: messageRequest.message,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}

class ReplyMessagePage extends StatefulWidget {
  final String senderName;
  final String senderId;
  final String lastMessage;

  const ReplyMessagePage({
    super.key,
    required this.senderName,
    required this.senderId,
    required this.lastMessage,
  });

  @override
  ReplyMessagePageState createState() => ReplyMessagePageState();
}

class ReplyMessagePageState extends State<ReplyMessagePage> {
  TextEditingController messageController = TextEditingController();
  final Controller controller = Get.find();
  EstablishConnectionMessageRequest establishConnectionMessageRequest =
      EstablishConnectionMessageRequest(
          message: '', receiverId: '', messagetype: textMessage);
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reply to ${widget.senderName}",
            style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lastMessage,
                            style: AppTextStyles.bodyText
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Write your message...',
                labelStyle: AppTextStyles.bodyText,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isSending
                      ? CircularProgressIndicator(color: AppColors.textColor)
                      : Icon(Icons.send, color: AppColors.textColor),
                  onPressed: _isSending
                      ? null
                      : () {
                          sendMessage(widget.senderId, messageController.text);
                        },
                ),
              ),
              style: AppTextStyles.bodyText,
              cursorColor: AppColors.cursorColor,
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String senderId, String message) async {
    if (message.trim().isEmpty) {
      failure("Message Empty", "Please write a message to send.");
      return;
    }
    setState(() {
      _isSending = true;
    });

    establishConnectionMessageRequest.message = message;
    establishConnectionMessageRequest.receiverId = senderId;

    bool success =
        await controller.sendConnectionMessage(establishConnectionMessageRequest);

    if (success) {
      await controller.fetchallpingrequestmessage();
      await controller.fetchalluserconnections();
      messageController.clear();
    }

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }
}
