import 'package:dating_application/Screens/settings/appinfopages/licensepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  String logoUrl = "${ip}uploads/applogo/logo.png";
  String releaseDate = "2024-11-23";
  String version = "1.0";
  String createdDate = "2024-11-23 15:53:48";
  String about =
      "CAJED is a dating application designed to connect people and foster meaningful relationships. Our mission is to provide a safe and enjoyable platform for individuals to meet, interact, and build connections. We prioritize user privacy and security, ensuring that your experience is both fun and trustworthy. Join CAJED today and start your journey towards finding companionship and love.";

  @override
  Widget build(BuildContext context) {
    double fontSize = getResponsiveFontSize(0.04);
    double cardRadius = 24;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize =
                MediaQuery.of(context).size.width * 0.05; // ~5% of screen width
            return Text(
              'App Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        foregroundColor: AppColors.textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        logoUrl,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/cajed_logo.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // App Name
                    Text(
                      appName,
                      style: AppTextStyles.headingText.copyWith(
                        fontSize: fontSize * 1.3,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 18),

                    // Release Date
                    Text(
                      "Release Date: $releaseDate",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize * 0.9,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Version
                    Text(
                      "Version: $version",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize * 0.9,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 24),

                    // About Section
                    Text(
                      about,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize * 0.9,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 30),

                    // License Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.to(LicenseDetailsPage());
                        },
                        child: Text(
                          'View Licenses',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
