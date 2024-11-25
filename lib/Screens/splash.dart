import 'dart:async';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_links/uni_links.dart';

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
  bool _isLoading = true; // Track loading state
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

    intialize();
        _handleIncomingLinks();
  }

  intialize() async {
    try {
      await controller.fetchAllHeadlines();
      await controller.fetchSafetyGuidelines();
      await controller.fetchAllPackages();
      await controller.reportReason();
      await controller.fetchlang();

      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        Get.offAll(() => Login());
      } else {
        Get.offAll(() => NavigationBottomBar());
      }
    } catch (e) {
      failure("Error", e.toString());

      Get.offAll(() => Login());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = uriLinkStream.listen((Uri? link) {
      if (link != null && link.host == "profile") {
        final userId = link.queryParameters['userId'];
        if (userId != null) {
          // Navigate to the profile page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProfilePage(userId: userId),
          //   ),
          // );
        }
      }
    }, onError: (err) {
      print('Failed to handle link: $err');
    });
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
                  color: AppColors.acceptColor,
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
                            color: Colors.orange,
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
                            color: Colors.orange,
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
