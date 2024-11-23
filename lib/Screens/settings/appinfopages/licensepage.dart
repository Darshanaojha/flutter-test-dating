import 'package:flutter/material.dart';

class LicenseDetailsPage extends StatefulWidget {
  const LicenseDetailsPage({super.key});

  @override
  LicenseDetailsPageState createState() => LicenseDetailsPageState();
}

class LicenseDetailsPageState extends State<LicenseDetailsPage> {
  String license = "abcd";
  String updatedTime = "2024-11-23 15:54:18"; 

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

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
              Text(
                "License: $license", 
                style: TextStyle(fontSize: getResponsiveFontSize(0.05), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "Updated: $updatedTime",
                style: TextStyle(fontSize: getResponsiveFontSize(0.04)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

