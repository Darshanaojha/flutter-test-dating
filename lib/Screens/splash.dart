import 'dart:async';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/update_activity_status_request_model.dart';
import 'package:dating_application/Screens/auth.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/Screens/navigationbar/unsubscribenavigation.dart';
import 'package:dating_application/main.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../Providers/fcmService.dart';
import '../constants.dart';
import 'introsliderpages/introsliderswipepage.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController _lottieController;
  final Completer<void> _lottieCompleter = Completer<void>();
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;
  Controller controller = Get.put(Controller());
  bool isSeenUser = false;
  StreamSubscription? _linkSubscription;
  late TickerFuture _fadeScaleAnimationFuture;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeScaleAnimationFuture = animationController.forward();

    _lottieController = AnimationController(vsync: this);

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Show dialog if IPs are not set
      if (ipAddress.isEmpty || ipSpringAddress.isEmpty) {
        await (context
                .findAncestorStateOfType<MainAppState>()
                ?.showIpDialog(context) ??
            Future.value());
      }
      intialize(); // Only call after IPs are set
    });
  }

  intialize() async {
    await Future.wait([
      _performInitializationAndNavigate(),
      Future.delayed(const Duration(seconds: 20)), // <-- Adjust the delay here
    ]);
  }

  Future<void> _performInitializationAndNavigate() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');
      debugPrint("Token: $token");
      bool? value = preferences.getBoolean('isSeenUser');

      if (value == null || value == false) {
        bool success = await controller.fetchAllIntroSlider();
        if (success) {
          preferences.setBoolean('isSeenUser', true);
          Get.offAll(() => IntroSlidingPages());
        } else {
          failure('Error', 'Failed to fetch the intro slider');
          Get.offAll(() => CombinedAuthScreen()); // Fallback
        }
        return;
      }

      await controller.fetchAllHeadlines();
      await controller.fetchSafetyGuidelines();
      await controller.fetchDesires();
      await controller.fetchGenders();
      await controller.fetchCountries();

      if (token == null || token.isEmpty) {
        Get.offAll(() => CombinedAuthScreen());
        return;
      }

      await controller.fetchAllPackages();
      await controller.fetchSafetyGuidelines();
      await controller.fetchalluserconnections();
      await controller.fetchAllverificationtype();
      await controller.fetchAllsubscripted();
      await controller.fetchProfile();

      String? packageStatus = controller.userData.first.packageStatus;
      if (packageStatus != null && packageStatus.isNotEmpty) {
        if (packageStatus == "1") {
          await controller.fetchallfavourites();
          await controller.userSuggestions();
          await controller.fetchProfileUserPhotos();
          FCMService().subscribeToTopic("subscribed");
          FCMService().subscribeToTopic(controller.userData.first.id);
          FCMService().subscribeToTopic("alluser");
          Get.offAll(() => NavigationBottomBar());
        } else {
          FCMService().subscribeToTopic("unsubscribed");
          FCMService().subscribeToTopic(controller.userData.first.id);
          FCMService().subscribeToTopic("alluser");
          Get.offAll(() => Unsubscribenavigation());
        }
      } else {
        // Fallback if packageStatus is null or empty after login
        Get.offAll(() => CombinedAuthScreen());
      }

      UpdateActivityStatusRequest updateActivityStatusRequest =
          UpdateActivityStatusRequest(status: '1');
      controller.updateactivitystatus(updateActivityStatusRequest);
    } catch (e) {
      failure("Error during initialization", e.toString());
      print(e.toString());
      Get.offAll(() => CombinedAuthScreen());
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    _lottieController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: opacityAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Lottie.asset(
                        'assets/animations/cajed_lottie.json',
                        controller: _lottieController,
                        height: mQuery.width,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          _lottieController.forward().whenComplete(() {
                            _lottieController
                                .forward(from: 0.0)
                                .whenComplete(() {
                              if (!_lottieCompleter.isCompleted) {
                                _lottieCompleter.complete();
                              }
                            });
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: opacityAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Text(
                        appName,
                        style: AppTextStyles.headingText.copyWith(
                          fontSize: mQuery.width * 0.1,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RusticRoadway',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: Text(
                      "Made in India with ❤️ and l*st",
                      style: AppTextStyles.headingText.copyWith(
                        fontSize: mQuery.width * 0.04,
                        color: AppColors.textColor.withOpacity(0.8),
                        fontFamily: 'RusticRoadway',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
