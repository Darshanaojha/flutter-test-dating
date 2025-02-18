import 'dart:math';
import 'package:dating_application/Screens/login.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _requestPermissions();
  }

  void _requestPermissions() async {
    // Request notification permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      print('User declined notification permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    }

    // Request camera permission
    var cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print('Camera permission granted');
    } else if (cameraStatus.isDenied) {
      print('Camera permission denied');
    }

    // Request location permission
    var locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      print('Location permission granted');
    } else if (locationStatus.isDenied) {
      print('Location permission denied');
    }

    // Request storage permission
    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print('Storage permission granted');
    } else if (await Permission.storage.isRestricted) {
      print('Storage permission is restricted');
    } else {
      // Handle Android 13+ permissions
      var manageStorageStatus =
          await Permission.manageExternalStorage.request();

      if (manageStorageStatus.isGranted) {
        print('Manage external storage permission granted');
      } else if (manageStorageStatus.isPermanentlyDenied) {
        openAppSettings();
      } else {
        print('Manage external storage permission denied');
      }
    }

    // Request microphone permission
    var microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isGranted) {
      print('Microphone permission granted');
    } else if (microphoneStatus.isDenied) {
      print('Microphone permission denied');
    }

    // Speaker permission (typically implicitly granted when using audio output)
    // There's no specific permission for speaker access in Flutter.
    // Just ensure that the app can play audio properly, and you'll usually be good to go.
    print('Speaker permission is assumed granted when playing audio.');
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
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff1f005c),
                Color(0xff5b0060),
                Color(0xff870160),
                Color(0xffac255e),
                Color(0xffca485c),
                Color(0xffe16b5c),
                Color(0xfff39060),
                Color(0xffffb56b),
              ],
            ),
            borderRadius: BorderRadius.circular(
                30), 
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
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xff1f005c),
                Color(0xff5b0060),
                Color(0xff870160),
                Color(0xffac255e),
                Color(0xffca485c),
                Color(0xffe16b5c),
                Color(0xfff39060),
                Color(0xffffb56b),
              ],
            ),
            borderRadius: BorderRadius.circular(
                30), // You can adjust the border radius here
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
                      FontAwesome.house_chimney_solid,
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
                      FontAwesome.heart_solid,
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
                      FontAwesome.message_solid,
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
                      FontAwesome.person_chalkboard_solid,
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
