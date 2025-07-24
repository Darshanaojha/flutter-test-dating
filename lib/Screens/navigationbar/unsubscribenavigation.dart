import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dating_application/Screens/auth.dart';
import 'package:dating_application/Screens/homepage/unsubscribeuser.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Controllers/controller.dart';
import '../../Models/RequestModels/update_activity_status_request_model.dart';
import '../../constants.dart';
import '../settings/setting.dart';
import '../userprofile/membership/membershippage.dart';

class UnSubscribeNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxString selectedPlan = 'None'.obs;

  final List<Widget> screens = [
    Unsubscribeuser(),
    UserProfilePage(),
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
    showPackagesDialog();
  }

  void showPackagesDialog() {
    final context = Get.context!;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    double baseFont = screenWidth * 0.065; // Roughly responsive
    double smallFont = screenWidth * 0.035;
    double buttonFont = screenWidth * 0.04;
    double buttonPaddingH = screenWidth * 0.05;
    double buttonPaddingV = screenHeight * 0.012;

    Get.defaultDialog(
      title: '',
      backgroundColor: Colors.transparent,
      barrierDismissible: false,
      radius: 15.0,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Subscribe to Enjoy',
              style: TextStyle(
                fontSize: baseFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "Choose a Subscription Plan",
              style: AppTextStyles.titleText.copyWith(
                fontSize: smallFont,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPaddingH,
                      vertical: buttonPaddingV,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: buttonFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                ElevatedButton(
                  onPressed: () {
                    Get.to(MembershipPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPaddingH,
                      vertical: buttonPaddingV,
                    ),
                  ),
                  child: Text(
                    'Subscribe',
                    style: TextStyle(
                      fontSize: buttonFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Unsubscribenavigation extends StatefulWidget {
  const Unsubscribenavigation({super.key});

  @override
  UnsubscribenavigationState createState() => UnsubscribenavigationState();
}

class UnsubscribenavigationState extends State<Unsubscribenavigation>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  Controller controller = Get.put(Controller());

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  double getResponsiveFontSize(BuildContext context, double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                Get.offAll(() => CombinedAuthScreen());
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
    final navigationcontroller = Get.put(UnSubscribeNavigationController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent, // Transparent to show gradient
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CurvedNavigationBar(
          index: selectedIndex,
          height: 60.0,
          items: <Widget>[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: selectedIndex == 0 ? _rotationAnimation.value : 0.0,
                  child: Icon(
                    Icons.home,
                    size: 30,
                    color: selectedIndex == 0
                        ? AppColors.primaryColor
                        : Colors.white,
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: selectedIndex == 1 ? _rotationAnimation.value : 0.0,
                  child: Icon(
                    Icons.account_circle,
                    size: 30,
                    color: selectedIndex == 1
                        ? AppColors.primaryColor
                        : Colors.white,
                  ),
                );
              },
            ),
          ],
          color: Colors.transparent, // Make bar see-through for gradient
          buttonBackgroundColor: AppColors.acceptColor,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              selectedIndex = index;
              _animationController.forward(from: 0);
            });
            navigationcontroller.navigateTo(index);
          },
        ),
      ),
    );
  }
}
