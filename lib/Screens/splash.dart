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

import '../Providers/fcmService.dart';
import '../constants.dart';
import 'introsliderpages/introsliderswipepage.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;
  Controller controller = Get.put(Controller());
  bool _isLoading = true;
  bool isSeenUser = false;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

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
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token'); // <-- await here
      debugPrint("Token: $token");
      bool? value = preferences.getBoolean('isSeenUser'); // <-- await here
      if (value == null || value == false) {
        controller.fetchAllIntroSlider().then((value) {
          if (value == true) {
            preferences.setBoolean('isSeenUser', true);
            Get.offAll(() => IntroSlidingPages());
          } else {
            failure('Error', 'Failed to fetch the intro slider');
          }
        });
        return;
      }
      // await controller.fetchAllHeadlines();
      await controller.fetchSafetyGuidelines();
      await controller.fetchlang();
      await controller.fetchDesires();
      await controller.fetchGenders();
      await controller.fetchCountries();
      String? packageStatus;
      if (token == null || token.isEmpty) {
        Get.offAll(() => CombinedAuthScreen());
        return;
      } else {
        await controller.fetchAllPackages();
        await controller.fetchSafetyGuidelines();
        await controller.fetchallfavourites();
        await controller.fetchalluserconnections();
        await controller.fetchAllverificationtype();
        await controller.fetchAllsubscripted();
        await controller.fetchProfile().then((_) async {
          packageStatus = controller.userData.first.packageStatus;
          if (packageStatus != null && packageStatus!.isNotEmpty) {
            if (packageStatus == "1") {
              await controller.userSuggestions();
              await controller.fetchProfileUserPhotos();
              await controller.likesuserpage();
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
          }
        });
      }

      UpdateActivityStatusRequest updateActivityStatusRequest =
          UpdateActivityStatusRequest(status: '1');
      controller.updateactivitystatus(updateActivityStatusRequest);
    } catch (e) {
      failure("Error in fetchLocation", e.toString());
      print(e.toString());
      Get.offAll(() => CombinedAuthScreen());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: _isLoading
              ? SpinKitCircle(
                  size: 150,
                  color: AppColors.progressColor,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: opacityAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: Text(
                          "FlamR",
                          style: GoogleFonts.raleway(
                            fontSize: mQuery.width * 0.08,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    FadeTransition(
                      opacity: opacityAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: Text(
                          "Application",
                          style: GoogleFonts.raleway(
                            fontSize: mQuery.width * 0.04,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
