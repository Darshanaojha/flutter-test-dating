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
    return screenWidth * scale; // Adjust this scale for different text elements
  }
  // You can define variables for any dynamic data you'd like to manage, for example:
  String appName = "FlamR";
  String logoUrl = "http://192.168.1.45/dating_backend_springboot/uploads/applogo/logo.png";
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
              ElevatedButton(
                onPressed: () {
                 Get.to(LicenseDetailsPage());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.activeColor,
                ),
                child: Text('View Licenses', style: AppTextStyles.headingText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
          ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
