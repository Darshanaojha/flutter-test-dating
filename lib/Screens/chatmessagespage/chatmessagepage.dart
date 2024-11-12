import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants.dart';
import '../chatpage/userchatpage.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final List<Map<String, dynamic>> chatUsers = [
    {
      'name': 'John Doe',
      'age': 25,
      'gender': 'Male',
      'imageUrl': 'https://www.example.com/profile1.jpg',
      'isOnline': true,
    },
    {
      'name': 'Jane Smith',
      'age': 28,
      'gender': 'Female',
      'imageUrl': 'https://www.example.com/profile2.jpg',
      'isOnline': false,
    },
    {
      'name': 'Alex Johnson',
      'age': 22,
      'gender': 'Non-binary',
      'imageUrl': 'https://www.example.com/profile3.jpg',
      'isOnline': true,
    },
  ];

  String searchQuery = '';
  bool isLoading = true;

  // Function to filter the chat users based on the search query
  List<Map<String, dynamic>> getFilteredChatUsers() {
    return chatUsers
        .where((user) =>
            user['name'].toLowerCase().contains(searchQuery.toLowerCase()))
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
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size; // For responsive design

    return Scaffold(
      backgroundColor:
          AppColors.secondaryColor, // Using the secondary color for background
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

                    hintStyle: AppTextStyles.customTextStyle(
                        color: Colors.grey), // Updated hint style
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
                    Text('Chatting Members', style: AppTextStyles.bodyText),
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
                  child: ListView.builder(
                    itemCount: getFilteredChatUsers().length,
                    itemBuilder: (context, index) {
                      final user = getFilteredChatUsers()[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to ChatPage when tapping anywhere in the row
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(user: user),
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
                                      builder: (context) => FullScreenImagePage(
                                        imageUrl: user['imageUrl'],
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: user['imageUrl'],
                                  child: CircleAvatar(
                                    radius: mQuery.width * 0.1,
                                    backgroundImage:
                                        NetworkImage(user['imageUrl']),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user['name'],
                                        style: AppTextStyles
                                            .bodyText, // Using heading style
                                      ),
                                      SizedBox(width: 40),
                                      if (user['isOnline'])
                                        Text(
                                          'Online',
                                          style: TextStyle(
                                            color: AppColors.activeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text('${user['age']} years old',
                                      style: AppTextStyles.bodyText),
                                  Text(user['gender'],
                                      style: AppTextStyles.bodyText),
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
          if (isLoading)
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: CircularProgressIndicator(
            //       color: AppColors.acceptColor, // Set loading spinner color
            //     ),
            //   ),
            // ),
            Center(
              child: SpinKitCircle(
                size: 150.0, // You can adjust the size as per your need
                color: AppColors.acceptColor, // Set the color of the heart
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

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
