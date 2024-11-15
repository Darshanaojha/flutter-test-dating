
import 'package:dating_application/Screens/loginforgotpassword/forgotpasswordconformotp.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  PasswordInputPageState createState() => PasswordInputPageState();
}

class PasswordInputPageState extends State<PasswordInputPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Function to validate password strength
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Function to validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Password', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Set your password and confirm it.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Password Input Field
                    TextFormField(
                      controller: passwordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      validator: validatePassword,
                    ),
                    SizedBox(height: 20),

                    // Confirm Password Input Field
                    TextFormField(
                      controller: confirmPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
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
                      validator: validateConfirmPassword,
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password successfully set')),
                          );
                          // Handle password submission logic here, such as navigating to the next screen or saving the password.
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
                      Get.to(OTPConfirmationPage());
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
