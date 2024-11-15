
import 'package:dating_application/Screens/homepage/homepage.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';

class OTPConfirmationPage extends StatefulWidget {
  const OTPConfirmationPage({super.key});

  @override
  OTPConfirmationPageState createState() => OTPConfirmationPageState();
}

class OTPConfirmationPageState extends State<OTPConfirmationPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController confirmOtpController = TextEditingController();
   double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }
  // Function to validate OTP
  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  // Function to validate confirm OTP
  String? validateConfirmOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm the OTP';
    }
    if (value != otpController.text) {
      return 'OTPs do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03; // Adjust font size based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm OTP', style: AppTextStyles.headingText.copyWith(fontSize:fontSize)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter the OTP and confirm it.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    // OTP Input Field
                    TextFormField(
                      controller: otpController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        labelStyle: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                        filled: true,
                        fillColor: AppColors.formFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.errorBorderColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6, // Limit to 6 digits
                      textAlign: TextAlign.center,
                      validator: validateOTP,
                    ),
                    SizedBox(height: 20),

                    // Confirm OTP Input Field
                    TextFormField(
                      controller: confirmOtpController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'Confirm OTP',
                        labelStyle: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                        filled: true,
                        fillColor: AppColors.formFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.errorBorderColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6, // Limit to 6 digits
                      textAlign: TextAlign.center,
                      validator: validateConfirmOTP,
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('OTP successfully confirmed')),
                          );
                          // Handle OTP confirmation logic here, such as verifying with a backend or navigating to the next screen.
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
                      ),
                      
                    ),
                    ElevatedButton(onPressed:(){
                      Get.to(Login());
                    } , child: Text('Next'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
