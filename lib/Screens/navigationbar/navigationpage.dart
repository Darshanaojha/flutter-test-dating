import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dating_application/Providers/fcmService.dart';
import 'package:dating_application/Providers/WebSocketService.dart';
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
import '../../widgets/loading_overlay.dart';
import '../../services/logout_service.dart';
import '../chatmessagespage/ContactListScreen.dart';
import '../homepage/homepage.dart';
import '../likespages/userlikespage.dart';
import '../settings/setting.dart';
import '../userprofile/userprofilepage.dart';
import '../introsliderpages/introsliderswipepage.dart';

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
  final controller = Get.find<Controller>();
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
              gradient: AppColors.appBarGradient,
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
                          gradient: AppColors.appBarGradient,
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
                            // Close the dialog first
                            Navigator.of(context).pop();
                            
                            // Show loading overlay immediately
                            await showLoadingOverlay(
                              context,
                              messages: [
                                'Clearing session...',
                                'Syncing with server...',
                                'Finishing up...',
                              ],
                              messageDuration: const Duration(seconds: 1),
                              indicatorColor: AppColors.mediumGradientColor,
                            );

                            // Perform logout with timeout and status updates
                            final result = await LogoutService.performLogoutWithTimeout(
                              timeout: const Duration(seconds: 15),
                              onStatusUpdate: (status) {
                                // Status updates are handled by message cycling
                                debugPrint('Logout status: $status');
                              },
                            );

                            // Delete NavigationController if registered
                            try {
                              if (Get.isRegistered<NavigationController>()) {
                                Get.delete<NavigationController>();
                              }
                            } catch (e) {
                              debugPrint('Error deleting NavigationController: $e');
                            }

                            // Hide loading overlay
                            await hideLoadingOverlay();

                            // Handle result
                            if (result.success) {
                              // Navigate to auth screen only after successful logout
                              Get.offAll(() => CombinedAuthScreen());
                            } else {
                              // Show error dialog if logout failed
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Logout Error'),
                                    content: Text(
                                      result.errorMessage.isNotEmpty
                                          ? result.errorMessage
                                          : 'Logout failed. Please try again.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Force navigation even on error
                                          Get.offAll(() => CombinedAuthScreen());
                                        },
                                        child: const Text('Continue Anyway'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
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

  Future<bool> _onWillPop() async {
    if (navigationcontroller.selectedIndex.value != 0) {
      navigationcontroller.navigateTo(0);
      return false;
    } else {
      final shouldPop = await showExitDialog();
      return shouldPop ?? false;
    }
  }

  Future<bool?> showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exit App?',
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(context, 0.055),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to exit?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(context, 0.04),
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'No',
                        style: AppTextStyles.buttonText.copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Yes",
                        style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.06),
          child: AppBar(
            elevation: 0,
            title: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  appName,
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: getResponsiveFontSize(context, 0.07),
                    fontFamily: 'RusticRoadway',
                    // fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
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
              // Test button for intro slider
              IconButton(
                icon: Icon(Icons.slideshow, color: Colors.pink),
                onPressed: () {
                  Get.to(() => IntroSlidingPages());
                },
                tooltip: 'Test Intro Slider',
              ),
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
          return navigationcontroller
              .screens[navigationcontroller.selectedIndex.value];
        }),
        bottomNavigationBar: Obx(() {
          // Calculate responsive height: clamp between 55-70px based on screen size
          // Small phones get 55px, medium get 60px, large get 65-70px
          final double screenHeight = MediaQuery.of(context).size.height;
          final double navBarHeight = (screenHeight * 0.08).clamp(55.0, 70.0);
          
          return SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                borderRadius: BorderRadius.circular(
                    30), // You can adjust the border radius here
              ),
              child: CurvedNavigationBar(
              index: navigationcontroller.selectedIndex.value,
              onTap: (index) {
                navigationcontroller.navigateTo(index);

                // controller.userPackage().then((status) {

                //   if (!controller.isuserPackage.value) {
                //     failure('Subscription',
                //         'Please subscribe to use all this feature');

                //     WidgetsBinding.instance.addPostFrameCallback((_) {
                //       Get.offAll(Unsubscribenavigation());
                //     });
                //   }
                // }).catchError((error) {
                //   failure('Error',
                //       'Something went wrong while checking subscription.');
                // });

                _animationController.forward(from: 0);
              },
              backgroundColor: Colors.transparent,
              color: Colors.black,
              height: navBarHeight,
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
            ),
          );
        }),
      ),
    );
  }
}
