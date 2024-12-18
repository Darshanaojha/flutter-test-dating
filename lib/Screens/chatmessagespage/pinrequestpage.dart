import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/estabish_connection_request_model.dart';
import '../../constants.dart';

class MessageRequestPage extends StatefulWidget {
  const MessageRequestPage({super.key});

  @override
  MessageRequestPageState createState() => MessageRequestPageState();
}

class MessageRequestPageState extends State<MessageRequestPage> {
  Controller controller = Get.put(Controller());
  bool isLoading = false;
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

  @override
  void initState() {
    super.initState();
    fetchpingrequest();
  }

  fetchpingrequest() async {
    setState(() {
      isLoading = true;
    });
    await controller.fetchallpingrequestmessage();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Requests', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;

            return ListView.builder(
              itemCount: controller.messageRequest.length,
              itemBuilder: (context, index) {
                final messageRequest = controller.messageRequest[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: GestureDetector(
                      onTap: () => showImageDialog(messageRequest.profileImage),
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(messageRequest.profileImage),
                        radius: screenWidth < 600 ? 30 : 40,
                      ),
                    ),
                    title: Text(
                      messageRequest.name,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth < 600 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      icon: Icon(Icons.reply, color: AppColors.iconColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReplyMessagePage(
                              senderName: messageRequest.name,
                              senderId: messageRequest.id,
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
        ),
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
  Controller controller = Controller();
  EstablishConnectionMessageRequest establishConnectionMessageRequest =
      EstablishConnectionMessageRequest(
          message: '', receiverId: '', messagetype: textMessage);
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lastMessage,
                          style: AppTextStyles.bodyText
                              .copyWith(color: Colors.grey),
                        ),
                      ],
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
                  icon: Icon(Icons.send, color: AppColors.textColor),
                  onPressed: () {
                    sendMessage(widget.senderId, messageController.text);

                    messageController.clear();
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

  void sendMessage(String senderId, String message) {
    establishConnectionMessageRequest.message = message;
    establishConnectionMessageRequest.receiverId = senderId;

    controller.sendConnectionMessage(establishConnectionMessageRequest);
  }
}
