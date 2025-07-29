import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dating_application/Providers/fcmService.dart';
import 'package:dating_application/Screens/auth.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Controllers/controller.dart';
import '../../Models/RequestModels/update_activity_status_request_model.dart';
import '../../constants.dart';
import '../chatmessagespage/ContactListScreen.dart';
import '../homepage/homepage.dart';
import '../likespages/userlikespage.dart';
import '../settings/setting.dart';
import '../userprofile/userprofilepage.dart';

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
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AppColors.reversedGradientColor,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  // child:
                  //     Icon(Icons.heart_broken, size: 48, color: Colors.white),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Lottie.asset(
                      'assets/animations/broken-heart.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Log Out?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: getResponsiveFontSize(context, 0.055),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out ?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: getResponsiveFontSize(context, 0.04),
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.8, 1),
                            colors: AppColors
                                .gradientColor, // Use the same gradient as Log Out
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Cancel',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.8, 1),
                            colors: AppColors.gradientColor,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            UpdateActivityStatusRequest
                                updateActivityStatusRequest =
                                UpdateActivityStatusRequest(status: '0');
                            controller.updateactivitystatus(
                                updateActivityStatusRequest);
                            FCMService().subscribeToTopic("unsubscribed");
                            final preferences =
                                EncryptedSharedPreferences.getInstance();
                            preferences.clear();
                            Get.offAll(() => CombinedAuthScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Text(
                            "Log Out",
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              colors: AppColors.gradientBackgroundList,
            ),
            borderRadius: BorderRadius.circular(30),
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
              colors: AppColors.gradientBackgroundList,
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
            color: Colors.black,
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
                          ? AppColors.textColor
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
                          ? AppColors.textColor
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
                          ? AppColors.textColor
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
                          ? AppColors.textColor
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
