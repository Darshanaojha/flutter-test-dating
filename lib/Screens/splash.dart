import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controllers/controller.dart';

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
  }

  intialize() async {
    try {
      // Fetch all headlines and safety guidelines
      await controller.fetchAllHeadlines();
      await controller.fetchSafetyGuidelines();

      // Check if user is authenticated
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      // Redirect based on token availability
      if (token == null || token.isEmpty) {
        Get.offAll(() => Login()); // No token, go to login
      } else {
        Get.offAll(() =>
            NavigationBottomBar()); // Token found, go to the main navigation
      }
    } catch (e) {
      // If an error occurs during initialization, navigate to login
      Get.offAll(() => Login());
      Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      // Ensure that loading state is set to false after initialization completes
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator() // Show loading indicator while data is being fetched
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
