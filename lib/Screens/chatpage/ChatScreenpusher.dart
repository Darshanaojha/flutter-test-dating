import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Models/RequestModels/send_message_request_model.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Models/ResponseModels/get_all_chat_history_page.dart';
import '../../Providers/pusherService.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;

  const ChatScreen(
      {super.key,
      required this.senderId,
      required this.receiverId,
      required this.receiverName});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  Controller controller = Get.put(Controller());
  late final UserConnections connection;
  final TextEditingController messageController = TextEditingController();
  final PusherService pusherService = Get.put(PusherService());

  @override
  void initState() {
    super.initState();

    pusherService.initPusher(widget.senderId, widget.receiverId);

    // Listening for the server-message event
    pusherService.onServerMessageReceived = (receivedMessage) {
      setState(() {
        controller.messages.add(Message(
          id: 'someId', // You can replace with actual message ID
          senderId:
              widget.receiverId, // Assuming the other person sends this message
          receiverId: widget.senderId,
          message: receivedMessage,
          messageType: textMessage.toString(),
          created: DateTime.now().toString(),
          updated: DateTime.now().toString(),
          status: '1',
          deletedBySender: '',
          deletedByReceiver: '',
          isEdited: 'false',
        ));
      });
    };
  }

  void _sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      pusherService.sendMessageToChannel(
        widget.senderId,
        widget.receiverId,
        message,
      );

      // Send message to backend (API call)
      _sendMessageToBackend(message);

      // Add message to the list (sent by current user)
      setState(() {
        controller.messages.add(Message(
          id: 'someId',
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          message: message,
          messageType: textMessage.toString(),
          created: DateTime.now().toString(),
          updated: DateTime.now().toString(),
          status: '1',
          deletedBySender: '',
          deletedByReceiver: '',
          isEdited: 'false',
        ));
      });

      // Clear the input field
      messageController.clear();
    }
  }

  // Simulating an API call to send the message to the backend
  Future<void> _sendMessageToBackend(String message) async {
    SendMessageRequestModel requestModel = SendMessageRequestModel(
      senderId: widget.senderId.toString(),
      receiverId: widget.receiverId.toString(),
      message: message,
      messageType: textMessage,
    );

    if (requestModel.validate()) {
      await pusherService.sendMessageApi(requestModel);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Disconnect Pusher when the screen is disposed
    pusherService.disconnectPusher();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Chat with ${widget.receiverName}"), // Replace with actual receiver name if available
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Text("No chats available".toUpperCase(),
                    style: GoogleFonts.lato(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white));
              }
              return ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  bool isSentByUser = message.senderId == widget.senderId;
                  return Align(
                    alignment: isSentByUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                        color:
                            isSentByUser ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isSentByUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Text input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
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
