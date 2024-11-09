import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'age': 25,
      'location': 'New York',
      'km': 10,
      'lastSeen': '2 hours ago',
      'desires': 'Looking for someone adventurous',
      'images': [
        'assets/images/image1.jpg',
        'assets/images/image1.jpg',
        'assets/images/image1.jpg',
      ]
    },
    {
      'name': 'Jane Smith',
      'age': 23,
      'location': 'Los Angeles',
      'km': 50,
      'lastSeen': '1 day ago',
      'desires': 'Looking for a partner who enjoys hiking',
      'images': [
        'assets/images/image2.jpg',
        'assets/images/image2.jpg',
        'assets/images/image2.jpg',
      ]
    },
    {
      'name': 'Sam Wilson',
      'age': 28,
      'location': 'Chicago',
      'km': 100,
      'lastSeen': '3 hours ago',
      'desires': 'Looking for someone to explore new places',
      'images': [
        'assets/images/image3.jpg',
        'assets/images/image3.jpg',
        'assets/images/image3.jpg',
      ]
    },
  ];

  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 5,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Dating App',
              style: AppTextStyles.headingText,
            ),
          ),
          backgroundColor: AppColors.acceptColor,  // Use the constant color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: users.length,
        onPageChanged: (index) {
          setState(() {
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Images Section with Vertical Scrolling (ListView)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: users[index]['images'].length,
                    itemBuilder: (context, imgIndex) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            users[index]['images'][imgIndex],
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // User Info Section
                Text(
                  users[index]['name'],
                  style: AppTextStyles.textStyle,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${users[index]['age']} years old | ',
                      style: AppTextStyles.textStyle,
                    ),
                    Text(
                      '${users[index]['location']} | ',
                      style: AppTextStyles.textStyle,
                    ),
                    Text(
                      '${users[index]['km']} km away',
                      style: AppTextStyles.textStyle,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Last Seen: ${users[index]['lastSeen']}',
                  style: AppTextStyles.textStyle,
                ),
                SizedBox(height: 12),
                Text(
                  'Desires:',
                  style: AppTextStyles.textStyle,
                ),
                SizedBox(height: 4),
                Text(
                  users[index]['desires'],
                  style: AppTextStyles.textStyle,
                ),
                SizedBox(height: 20),
                // Like and Dislike Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 30,
                        color: _isLiked ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          if (_isLiked) {
                            _isDisliked = false;
                          }
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        size: 30,
                        color: _isDisliked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isDisliked = !_isDisliked;
                          if (_isDisliked) {
                            _isLiked = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      // bottomNavigationBar: NavigationBottomBar(),
      bottomNavigationBar:  BottomNavigationBar(
        selectedItemColor: AppColors.iconColor, // Define AppColors in your project
        unselectedItemColor: AppColors.inactiveColor, // Define AppColors in your project
        backgroundColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        // currentIndex: _selectedIndex,  
        // onTap: _onItemTapped,  
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Likes',
            tooltip: 'Likes Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
            tooltip: 'Messages Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
            tooltip: 'Profile Page',
          ),
        ],
      ),
    );
  }
}
