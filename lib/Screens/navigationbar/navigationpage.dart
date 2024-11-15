import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../chatmessagespage/chatmessagepage.dart';
import '../homepage/homepage.dart';
import '../likespages/userlikespage.dart';
import '../settings/setting.dart';
import '../userprofile/userprofilepage.dart';

class NavigationController extends GetxController {
  // Track the selected index
  final Rx<int> selectedIndex = 0.obs;

  // Store the pages themselves (not the result of Get.to())
  final List<Widget> screens = [
    HomePage(),
    LikesPage(),
    ChatHistoryPage(),
    UserProfilePage()
  ];

  // Method to navigate to a different screen
  void navigateTo(int index) {
    selectedIndex.value = index;
  }
}
class NavigationBottomBar extends StatelessWidget {
  const NavigationBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 5,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('FlamR', style: AppTextStyles.headingText),
            ),
          ),
          backgroundColor: AppColors.acceptColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          // Add the Settings icon to the leading side (left side)
          leading: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          // Add the Logout button to the actions (right side)
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                // Add your logout functionality here
                // Example:
                Get.offAll(() => Login()); // Redirect to Login Page
              },
            ),
          ],
        ),
      ),
      // Use Obx to reactively display the selected screen based on selectedIndex
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),

      // The Bottom Navigation Bar with animated icons
      bottomNavigationBar: Obx(() {
        return NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.navigateTo(index); // Change the index and navigate
          },
          backgroundColor: AppColors.primaryColor,
          height: 80,
          elevation: 1,
          destinations: [
            NavigationDestination(
              icon: AnimatedScale(
                scale: controller.selectedIndex.value == 0
                    ? 1.2
                    : 1.0, // Scale effect on selection
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: AnimatedScale(
                scale: controller.selectedIndex.value == 1
                    ? 1.2
                    : 1.0, // Scale effect on selection
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.favorite),
              ),
              label: 'Likes',
            ),
            NavigationDestination(
              icon: AnimatedScale(
                scale: controller.selectedIndex.value == 2
                    ? 1.2
                    : 1.0, // Scale effect on selection
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.message),
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: AnimatedScale(
                scale: controller.selectedIndex.value == 3
                    ? 1.2
                    : 1.0, // Scale effect on selection
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.account_circle),
              ),
              label: 'Profile',
            ),
          ],
        );
      }),
    );
  }
}
