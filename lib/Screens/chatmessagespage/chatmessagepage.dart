import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Messages Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBottomBar(),  // Reuse NavigationBottomBar
    );
  }
}
