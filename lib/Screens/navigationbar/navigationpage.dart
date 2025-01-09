import 'dart:math';
import 'package:dating_application/Screens/login.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
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
    ContactListScreen(),
    UserProfilePage(),
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
  }
}

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({super.key});

  @override
  NavigationBottomBarState createState() => NavigationBottomBarState();
}

class NavigationBottomBarState extends State<NavigationBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  final controller = Get.put(Controller());
  final navigationcontroller = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
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
        return navigationcontroller
            .screens[navigationcontroller.selectedIndex.value];
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
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: CurvedNavigationBar(
            index: navigationcontroller.selectedIndex.value,
            onTap: (index) {
              navigationcontroller.navigateTo(index);
              _animationController.forward(from: 0);
            },
            backgroundColor: Colors.transparent,
            color: AppColors.navigationColor,
            height: 60,
            animationDuration: Duration(milliseconds: 300),
            items: <Widget>[
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: navigationcontroller.selectedIndex.value == 0
                        ? _rotationAnimation.value
                        : 0.0,
                    child: Icon(
                      Icons.home,
                      size: 30,
                      color: navigationcontroller.selectedIndex.value == 0
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: navigationcontroller.selectedIndex.value == 1
                        ? _rotationAnimation.value
                        : 0.0,
                    child: Icon(
                      Icons.favorite,
                      size: 30,
                      color: navigationcontroller.selectedIndex.value == 1
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: navigationcontroller.selectedIndex.value == 2
                        ? _rotationAnimation.value
                        : 0.0,
                    child: Icon(
                      Icons.messenger,
                      size: 30,
                      color: navigationcontroller.selectedIndex.value == 2
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: navigationcontroller.selectedIndex.value == 3
                        ? _rotationAnimation.value
                        : 0.0,
                    child: Icon(
                      Icons.account_circle,
                      size: 30,
                      color: navigationcontroller.selectedIndex.value == 3
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
