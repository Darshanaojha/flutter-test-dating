import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  const EmailOtpVerificationPage({super.key});

  @override
  EmailOtpVerificationPageState createState() => EmailOtpVerificationPageState();
}

class EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final otpController = TextEditingController();
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }
  // GlobalKey for form validation
  final formKey = GlobalKey<FormState>();

  String? otpError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter OTP",
          style: AppTextStyles.headingText.copyWith(fontSize: getResponsiveFontSize(0.03)),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please enter the OTP sent to your email address.",
                style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // OTP field
                    TextFormField(
                      controller: otpController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        labelStyle: AppTextStyles.labelText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: otpError,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,  // Common OTP length
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "OTP is required";
                        }
                        if (value.length != 6) {
                          return "OTP must be 6 digits long";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Verify OTP",
                          style: AppTextStyles.buttonText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void verifyOTP() {
    // Clear previous error messages
    setState(() {
      otpError = null;
    });

    // Validate form
    if (formKey.currentState!.validate()) {
      // Proceed with the OTP verification logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP verified successfully",
            style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
          ),
          backgroundColor: AppColors.acceptColor,
        ),
      );
    }
  }
}
