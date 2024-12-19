import 'package:dating_application/Models/ResponseModels/get_all_chat_history_page.dart';
import 'package:dating_application/Screens/chatmessagespage/pinrequestpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/chat_history_request_model.dart';
import '../../constants.dart';
import '../chatpage/ChatScreen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  ContactListScreenState createState() => ContactListScreenState();
}

class ContactListScreenState extends State<ContactListScreen> {
  Controller controller = Get.put(Controller());
  String searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    await controller.fetchalluserconnections();
    setState(() {
      isLoading = false;
    });
  }

  List<UserConnections> getFilteredUsers() {
    return controller.userConnections
        .where((user) =>
            user.name!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField
                TextField(
                  cursorColor: AppColors.cursorColor,
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Contacts...',
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

                // Row with number of members and Ping button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getFilteredUsers().length} members',
                      style: AppTextStyles.customTextStyle(color: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(MessageRequestPage());
                        Get.snackbar('count',
                            controller.userConnections.length.toString());
                        print("Ping button pressed");
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
                      child: Text('Ping'),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // ListView of contacts
                Expanded(
                  child: ListView.builder(
                    itemCount: getFilteredUsers().length,
                    itemBuilder: (context, index) {
                      final connection = getFilteredUsers()[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            debugPrint(
                                'User ID: ${controller.userData.first.id}');
                            debugPrint(
                                'Connection ID: ${connection.conectionId}');

                            ChatHistoryRequestModel chatHistoryRequestModel =
                                ChatHistoryRequestModel(
                                    userId: connection.conectionId);
                            controller
                                .chatHistory(chatHistoryRequestModel)
                                .then((value) {
                              if (value == true) {
                                Get.to(() => ChatScreen(
                                      senderId: controller.userData.first.id,
                                      receiverId: connection.conectionId,
                                      receiverName: connection.name,
                                    ));
                              }
                            });
                          },
                          child: Row(
                            children: [
                              // GestureDetector for profile image
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImagePage(
                                        imageUrl: connection
                                            .profileImage!, // image URL
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: connection.profileImage!,
                                  child: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage:
                                        NetworkImage(connection.profileImage!),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    connection.name!,
                                    style: AppTextStyles.customTextStyle(
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Hi there!',
                                    style: AppTextStyles.customTextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Loading spinner when the data is being fetched
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
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
