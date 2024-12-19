import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/userprofile/editprofile/edituserprofile.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/RequestModels/update_activity_status_request_model.dart';
import '../../constants.dart';
import '../chatmessagespage/ContactListScreen.dart';
import '../homepage/homepage.dart';
import '../likespages/userlikespage.dart';
import '../settings/setting.dart';
import '../userprofile/userprofilepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final List<Widget> screens = [
    HomePage(),
    LikesPage(),
   // ChatHistoryPage(),
   ContactListScreen(),
    UserProfilePage(),
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
                backgroundColor: AppColors.inactiveColor,
              ),
              onPressed: () {
                EncryptedSharedPreferences preferences =
                    EncryptedSharedPreferences.getInstance();
                preferences.clear();
                Get.offAll(() => Login());
                UpdateActivityStatusRequest updateActivityStatusRequest =
                    UpdateActivityStatusRequest(status: '0');
                controller.updateactivitystatus(updateActivityStatusRequest);
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navigationright,
                AppColors.navigationColorleft,
              ],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), // Optional: Rounded top-left corner
              topRight:
                  Radius.circular(30), // Optional: Rounded top-right corner
            ),
          ),
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
            // backgroundColor: AppColors.navigationColor,
            backgroundColor: Colors.transparent,
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
      ),
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navigationright,
                AppColors.navigationColorleft,
              ],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), // Optional: Rounded top-left corner
              topRight:
                  Radius.circular(30), // Optional: Rounded top-right corner
            ),
          ),
          child: CurvedNavigationBar(
            index: controller.selectedIndex.value,
            onTap: (index) {
              controller.navigateTo(index);
            },
            // backgroundColor:AppColors.primaryColor,
            // color: AppColors.navigationColor,
            backgroundColor: Colors.transparent,
            color: AppColors.navigationColor,
            height: 60,
            animationDuration: Duration(milliseconds: 300),
            items: <Widget>[
              Icon(
                Icons.home,
                size: 30,
                color: controller.selectedIndex.value == 0
                    ? AppColors.primaryColor
                    : AppColors.textColor,
              ),
              Icon(
                Icons.favorite,
                size: 30,
                color: controller.selectedIndex.value == 1
                    ? AppColors.primaryColor
                    : AppColors.textColor,
              ),
              Icon(
                Icons.messenger,
                size: 30,
                color: controller.selectedIndex.value == 2
                    ? AppColors.primaryColor
                    : AppColors.textColor,
              ),
              Icon(
                Icons.account_circle,
                size: 30,
                color: controller.selectedIndex.value == 3
                    ? AppColors.primaryColor
                    : AppColors.textColor,
              ),
            ],
          ),
        );
      }),
    );
  }
}
