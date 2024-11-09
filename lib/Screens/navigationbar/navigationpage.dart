import 'package:flutter/material.dart';
import '../../constants.dart';
import '../chatmessagespage/chatmessagepage.dart';
import '../homepage/homepage.dart';
import '../likespages/userlikespage.dart';
import '../userprofile/userprofilepage.dart';



class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({super.key});

  @override
  NavigationBottomBarState createState() => NavigationBottomBarState();
}

class NavigationBottomBarState extends State<NavigationBottomBar> {
  // Track the selected index
  int _selectedIndex = 0;

  // List of pages corresponding to each tab in the BottomNavigationBar
  final List<Widget> _pages = [
    HomePage(),    // HomePage
    LikesPage(),   // LikesPage
    MessagesPage(),// MessagesPage
    ProfilePage(), // ProfilePage
  ];

  // Function to handle navigation when a tab is tapped
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    // Perform actions like fetching data before navigating (optional)
    switch (index) {
      case 0:
     
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
      
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LikesPage()),
        );
        break;
      case 2:
      
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MessagesPage()),
        );
        break;
      case 3:
  
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page based on index
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.iconColor, // Define AppColors in your project
        unselectedItemColor: AppColors.inactiveColor, // Define AppColors in your project
        backgroundColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Navigate when a tab is tapped
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

