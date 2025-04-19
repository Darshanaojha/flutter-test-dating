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

  String appName = "FlamR";
  String logoUrl = "${ip}uploads/applogo/logo.png";
  String releaseDate = "2024-11-23";
  String version = "1.0";
  String createdDate = "2024-11-23 15:53:48";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Information',
          style: AppTextStyles.headingText.copyWith(
            fontSize: getResponsiveFontSize(0.035),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
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
                style: AppTextStyles.subheadingText.copyWith(
                  fontSize: getResponsiveFontSize(0.04),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 24),

              // App Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  logoUrl,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24),

              // Release Date
              Text(
                "Release Date: $releaseDate",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 12),

              // Version
              Text(
                "Version: $version",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),

              SizedBox(height: 24),

              // License Button
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: AppColors.buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    Get.to(LicenseDetailsPage());
                  },
                  child: Text(
                    'View Licenses',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: getResponsiveFontSize(0.035),
                      fontWeight: FontWeight.w500,
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
