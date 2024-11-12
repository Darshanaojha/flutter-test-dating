import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

 
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), 
    )..forward();

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(seconds: 3), () {
      Get.offAll(() => Login()); 
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor, // Replace with your color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: opacityAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Text(
                    "FlamR",
                    style: GoogleFonts.lato(
                      fontSize: mQuery.width * 0.08,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10), 
              
              // Second Text (Application)
              FadeTransition(
                opacity: opacityAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Text(
                    "Application",
                    style: GoogleFonts.lato(
                      fontSize: mQuery.width * 0.04,
                      color: Colors.white,
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
