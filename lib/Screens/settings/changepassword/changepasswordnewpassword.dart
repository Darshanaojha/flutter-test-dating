
import 'package:dating_application/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Models/RequestModels/change_password_request.dart';
import '../../../Providers/change_password_provider.dart';
import '../../../constants.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}
class ChangePasswordPageState extends State<ChangePasswordPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  
  final changePasswordProvider = ChangePasswordProvider();

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; 
  }


  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }


  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
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
        title: Text('Change Password', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter your current password and set a new one.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
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
                    TextFormField(
                      controller: newPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
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
                    TextFormField(
                      controller: confirmNewPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
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
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          String oldPassword = currentPasswordController.text;
                          String newPassword = newPasswordController.text;

                          final changePasswordRequest = ChangePasswordRequest(
                            oldPassword: oldPassword,
                            newPassword: newPassword,
                          );

                          try {
                            final response = await changePasswordProvider.changePassword(changePasswordRequest);

                            if (response != null) {
                             success('Success','Password successfully changed');
                            Get.offAll(Login());
                            } else {
                              failure('Failed', 'Failed to change password');
                            }
                          } catch (e) {
                          failure('Failed', 'An error occurred: ${e.toString()}');
                          }
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
