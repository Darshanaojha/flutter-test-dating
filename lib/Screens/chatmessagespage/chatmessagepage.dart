import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../constants.dart';
import '../chatpage/userchatpage.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ChatHistoryPageState createState() => ChatHistoryPageState();
}

class ChatHistoryPageState extends State<ChatHistoryPage> {
  // final List<Map<String, dynamic>> chatUsers = [
  //   {
  //     'name': 'John Doe',
  //     'age': 25,
  //     'gender': 'Male',
  //     'imageUrl': 'https://www.example.com/profile1.jpg',
  //     'isOnline': true,
  //     'lastMessageTime': DateTime.now().subtract(Duration(minutes: 10)),
  //   },
  //   {
  //     'name': 'Jane Smith',
  //     'age': 28,
  //     'gender': 'Female',
  //     'imageUrl': 'https://www.example.com/profile2.jpg',
  //     'isOnline': false,
  //     'lastMessageTime': null, // This is the problematic null value
  //   },
  //   {
  //     'name': 'Alex Johnson',
  //     'age': 22,
  //     'gender': 'Non-binary',
  //     'imageUrl': 'https://www.example.com/profile3.jpg',
  //     'isOnline': true,
  //     'lastMessageTime': DateTime.now().subtract(Duration(days: 1)),
  //   },
  // ];

  final List<Message> chatUser = [];
  Controller controller = Get.put(Controller());

  String searchQuery = '';
  bool isLoading = true;

  // Function to filter the chat users based on the search query
  List<Message> getFilteredChatUsers() {
    return controller.messages
        .where((user) =>
            user.id.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });

    fetchChatUser();
  }

  fetchChatUser() async {
    await controller.chatHistory();
  }

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  @override
  Widget build(BuildContext context) {
   // final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  cursorColor: AppColors.cursorColor,
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Chat Users...',
                    hintStyle:
                        AppTextStyles.customTextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: AppColors.iconColor),
                    filled: true,
                    fillColor: AppColors.formFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Online status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chatting Members',
                        style: AppTextStyles.bodyText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: AppColors.activeColor,
                          size: 14,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${getFilteredChatUsers().length} members',
                          style:
                              AppTextStyles.customTextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // List of chat users
                Expanded(
                  child: Obx(() {
                    final chatMessages =
                        controller.messages; // Accessing RxList<Message>

                    if (chatMessages.isEmpty) {
                      return Center(
                        child: Text(
                          'No chats available.',
                          style: AppTextStyles.bodyText,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = chatMessages[index];

                        // Handle null lastMessageTime
                        final lastMessageTime = message.created;
                        String timeAgoText = lastMessageTime.isNotEmpty
                            ? timeago.format(DateTime.parse(lastMessageTime))
                            : 'No messages yet';

                        return GestureDetector(
                          onTap: () {
                            // Navigate to ChatPage when tapping anywhere in the row
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  user: {
                                    'id': message.id,
                                    'userName': message.id,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Block navigation to ChatPage when tapping on image
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImagePage(
                                          imageUrl: 'assets/images/image.png',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'assets/images/image.png',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: true
                                            ? Border.all(
                                                color: Colors.green,
                                                width: 3.0,
                                              )
                                           
                                            : null ,
                                      ),
                                      child: CircleAvatar(
                                        radius:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        backgroundImage: AssetImage(
                                            'assets/images/image.png'),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          message.id,
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.04),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    // Display time since last message
                                    Text(
                                      timeAgoText,
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: Colors.grey,
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
                  }),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: SpinKitCircle(
                size: 150.0,
                color: AppColors.progressColor,
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(
                  context); // Close the full-screen image view when tapped
            },
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
