import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../Models/ResponseModels/get_all_chat_history_page.dart';
import '../../constants.dart';
import '../chatpage/userchatpage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'pinrequestpage.dart';

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
        .where((user) =>
            user.username.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    fetchChatUserList();
  }

  fetchChatUserList() async {
    setState(() {
      isLoading = true;
    });
    await controller.fetchallchathistory();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getFilteredChatUsers().length} members',
                      style: AppTextStyles.customTextStyle(color: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(MessageRequestPage());
                        Get.snackbar('count',
                            controller.chatHistoryItem.length.toString());
                        print("Request button pressed");
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('Pin'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
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
                      itemCount: getFilteredChatUsers().length,
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
                                    'id': message.id,
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
                                        builder: (context) =>
                                            FullScreenImagePage(
                                          imageUrl: controller
                                                  .chatHistoryItem[index]
                                                  .profileImage, // fallback URL
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: controller.chatHistoryItem[index]
                                            .profileImage,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: message.useractivestatus ==
                                                      '1'
                                                  ? Colors.green
                                                  : Colors.transparent,
                                              width: 3.0,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              message.profileImage,
                                            ),
                                          ),
                                        ),
                                      
                                        if (message.useractivestatus == '1')
                                          Positioned(
                                            right: 9,
                                            bottom: 2,
                                            child: Container(
                                              width: 14,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: AppColors.activeColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.cursorColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
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
                                          message.username, 
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.04),
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
