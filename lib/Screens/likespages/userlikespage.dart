import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:flutter/material.dart';

class LikesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 100, color: Colors.pink),
            SizedBox(height: 20),
            Text(
              'Likes Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar:NavigationBottomBar() ,
    );
  }
}
