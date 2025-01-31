import 'package:dating_application/Screens/settings/appinfopages/licensepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pushable_button/pushable_button.dart';
import '../../../constants.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  // You can define variables for any dynamic data you'd like to manage, for example:
  String appName = "FlamR";
  String logoUrl = "${ip}uploads/applogo/logo.png";
  String releaseDate = "2024-11-23";
  String version = "1.0";
  String createdDate = "2024-11-23 15:53:48";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Name
              Text(
                "App Name: $appName",
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                ),
              ),
              SizedBox(height: 20),

              // App Logo
              Image.network(
                logoUrl,
                height: 100,
                width: 100,
              ),
              SizedBox(height: 20),

              // Release Date
              Text(
                "Release Date: $releaseDate",
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                ),
              ),
              SizedBox(height: 10),

              // Version
              Text(
                "Version: $version",
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                ),
              ),

              SizedBox(height: 20),

              // License Button
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textColor,
                    backgroundColor: AppColors.buttonColor,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Get.to(LicenseDetailsPage());
                  },
                  child: Text(
                    'View Licenses',
                    style: AppTextStyles.headingText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
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
