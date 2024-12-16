import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../Models/ResponseModels/get_all_chat_history_page.dart';
import '../../constants.dart';
import '../chatpage/userchatpage.dart';
import 'package:timeago/timeago.dart' as timeago;
class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ChatHistoryPageState createState() => ChatHistoryPageState();
}

class ChatHistoryPageState extends State<ChatHistoryPage> {
  Controller controller = Get.put(Controller());
  String searchQuery = '';
  bool isLoading = true;

  List<ChatHistoryItem> getFilteredChatUsers() {
    return controller.chatHistoryItem
        .where((user) => user.username.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    fetchChatUser();
  }

  fetchChatUser() async {
    setState(() {
      isLoading = true;
    });
    await controller.chatHistory();
    setState(() {
      isLoading = false;
    });
  }

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  Widget build(BuildContext context) {
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
                    hintStyle: AppTextStyles.customTextStyle(color: Colors.grey),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chatting Members',
                      style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                    ),
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
                          style: AppTextStyles.customTextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Displaying the list of chat users
                Expanded(
                  child: Obx(() {
                    final chatMessages = controller.chatHistoryItem;

                    if (chatMessages.isEmpty) {
                      return Center(
                        child: Text(
                          'No chats available.',
                          style: AppTextStyles.bodyText,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: getFilteredChatUsers().length, // Use filtered list
                      itemBuilder: (context, index) {
                        final message = getFilteredChatUsers()[index];
                        final lastMessageTime = message.created;
                        String timeAgoText = (lastMessageTime.isNotEmpty)
                            ? timeago.format(DateTime.parse(lastMessageTime))
                            : 'No messages yet';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  user: {
                                    'id': message.id, // Use correct ID
                                    'userName': message.username,
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImagePage(
                                          imageUrl: message.profileImage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: message.profileImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 3.0,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: MediaQuery.of(context).size.width * 0.08,
                                        backgroundImage: CachedNetworkImageProvider(message.profileImage),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          message.username,
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: getResponsiveFontSize(0.04),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
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
              Navigator.pop(context);
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
