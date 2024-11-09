import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'John Doe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Column(
        children: [
          Text("Hello, $_userName"),
          ElevatedButton(
            onPressed: () {
              // Only call setState when necessary, outside of build
              setState(() {
                _userName = 'Jane Doe';
              });
            },
            child: Text("Change Name"),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}

