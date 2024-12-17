import 'package:flutter/material.dart';
import '../../constants.dart';

class MessageRequestPage extends StatefulWidget {
  const MessageRequestPage({super.key});

  @override
  MessageRequestPageState createState() => MessageRequestPageState();
}

class MessageRequestPageState extends State<MessageRequestPage> {
  final List<MessageRequest> messageRequests = [
    MessageRequest(
      senderName: "Trump America",
      senderProfileImage: "https://example.com/image1.jpg",
      lastMessage: "Hey, how are you?",
      senderId: "user1",
    ),
    MessageRequest(
      senderName: "Johnson Nework",
      senderProfileImage: "https://example.com/image2.jpg",
      lastMessage: "Are you free to chat?",
      senderId: "user2",
    ),
  ];

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
              itemCount: messageRequests.length,
              itemBuilder: (context, index) {
                final messageRequest = messageRequests[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: GestureDetector(
                      onTap: () => showImageDialog(messageRequest.senderProfileImage),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(messageRequest.senderProfileImage),
                        radius: screenWidth < 600 ? 30 : 40,
                      ),
                    ),
                    title: Text(
                      messageRequest.senderName,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth < 600 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      messageRequest.lastMessage,
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
                              senderName: messageRequest.senderName,
                              senderId: messageRequest.senderId,
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

  const ReplyMessagePage({super.key, required this.senderName, required this.senderId});

  @override
  ReplyMessagePageState createState() => ReplyMessagePageState();
}

class ReplyMessagePageState extends State<ReplyMessagePage> {
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reply to ${widget.senderName}", style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
    print('Message sent to $senderId: $message');
  }
}

class MessageRequest {
  final String senderName;
  final String senderProfileImage;
  final String lastMessage;
  final String senderId;

  MessageRequest({
    required this.senderName,
    required this.senderProfileImage,
    required this.lastMessage,
    required this.senderId,
  });
}

