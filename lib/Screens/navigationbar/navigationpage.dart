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
  final Rx<int> selectedIndex = 0.obs;
  final List<Widget> screens = [
    HomePage(),
    LikesPage(),
    ChatHistoryPage(),
    UserProfilePage()
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
  }
}

class NavigationBottomBar extends StatelessWidget {
  const NavigationBottomBar({super.key});

  double getResponsiveFontSize(BuildContext context, double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout',
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(context, 0.04))),
          content: Text('Are you sure you want to log out?',
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(context, 0.04))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.primaryColor, 
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('No',
                  style: AppTextStyles.headingText.copyWith(
                      fontSize: getResponsiveFontSize(context, 0.04))),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textColor,
                backgroundColor:
                    AppColors.inactiveColor, 
              ),
              onPressed: () {
                Get.offAll(() =>
                    Login());
              },
              child: Text('Yes',
                  style: AppTextStyles.headingText.copyWith(
                      fontSize: getResponsiveFontSize(context, 0.04))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          elevation: 5,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'FlamR',
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(context, 0.08),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.acceptColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) {
              controller.navigateTo(index);
            },
            backgroundColor: AppColors.primaryColor,
            height: 80,
            elevation: 1,
            destinations: [
              NavigationDestination(
                icon: AnimatedScale(
                  scale: controller.selectedIndex.value == 0 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.home),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: AnimatedScale(
                  scale: controller.selectedIndex.value == 1 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.favorite),
                ),
                label: 'Likes',
              ),
              NavigationDestination(
                icon: AnimatedScale(
                  scale: controller.selectedIndex.value == 2 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.message),
                ),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: AnimatedScale(
                  scale: controller.selectedIndex.value == 3 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.account_circle),
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      }),
    );
  }
}
