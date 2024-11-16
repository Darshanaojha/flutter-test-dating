
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/RequestModels/forget_password_verification_request_model.dart';
import '../../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../../Providers/login_provider.dart';
import '../../constants.dart';
import '../login.dart';

class OTPInputPage extends StatefulWidget {
  const OTPInputPage({super.key});

  @override
  OTPInputPageState createState() => OTPInputPageState();
}

class OTPInputPageState extends State<OTPInputPage> {
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final TextEditingController passwordController = TextEditingController();  
  final TextEditingController confirmPasswordController = TextEditingController(); 

  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a digit';
    }
    if (!RegExp(r'^[0-9]$').hasMatch(value)) {
      return 'Enter a valid digit';
    }
    return null;
  }

  // Function to handle password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Function to handle confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }


  Future<void> verifyOTPAndResetPassword() async {
    if (formKey.currentState!.validate()) {
      String otp = otpControllers.map((controller) => controller.text).join('');

      String email = "user@example.com"; 
      
      String password = passwordController.text;

      ForgetPasswordVerificationRequest request = ForgetPasswordVerificationRequest(
        email: email,
        otp: otp,
        password: password,
      );

      try {
        LoginProvider provider = LoginProvider();
        ForgetPasswordVerificationResponse? response = await provider.otpVerificationForgetPassword(request);

        if (response != null && response.success) {
         success('Success', 'Password successfully reset!');
          Get.to(Login());
        } else {
          failure('Failed', 'Failed to reset password. Please try again.');
        }
      } catch (e) {
        failure('Failed', 'Failed to reset password. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter the 6-digit OTP sent to your email.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // OTP Fields (6 digits)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: screenWidth * 0.12,
                          child: TextFormField(
                            cursorColor: AppColors.cursorColor,
                            controller: otpControllers[index],
                            style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                            decoration: InputDecoration(
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
                            maxLength: 1, // Limit to 1 digit per input
                            textAlign: TextAlign.center,
                            validator: validateOTP,
                            onChanged: (value) {
                       
                          if (value.isNotEmpty && index < otpControllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        onSaved: (value) {
                    
                          otpControllers[index].text = value ?? '';
                        },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: verifyOTPAndResetPassword,
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
                    ElevatedButton(onPressed: (){Get.to(Login());}, child: Text("Next"))
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