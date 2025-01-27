import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../Models/RequestModels/change_password_request.dart';
import '../../../constants.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final formKey = GlobalKey<FormState>();
  Controller controller = Get.find();
  bool currentpassword = true;
  bool newPassword = true;
  bool conformpassword = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() {}

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      failure('Password', 'Please enter a password');
      return 'Please enter a password';
    }
    if (value.length < 8) {
      failure('Password Length', 'Password must be at least 8 characters');
      return 'Password must be at least 8 characters';
    }
    if (!controller.changePasswordRequest.isValidPassword(value)) {
      failure("Password",
          "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character");
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != controller.changePasswordRequest.newPassword) {
      return 'Passwords do not match';
    }
    if (!controller.changePasswordRequest.isValidPassword(value)) {
      return 'Confirm password must meet the required criteria';
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
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
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
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      obscureText: currentpassword,
                      decoration: InputDecoration(
                          labelText: 'Current Password',
                          labelStyle: AppTextStyles.bodyText
                              .copyWith(fontSize: fontSize),
                          filled: true,
                          fillColor: AppColors.formFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.primaryColor),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.errorBorderColor),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  currentpassword = !currentpassword;
                                });
                              });
                            },
                            icon: Icon(
                              currentpassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                          )),
                      validator: validatePassword,
                      onChanged: (value) {
                        controller.changePasswordRequest.oldPassword = value;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      obscureText: newPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle:
                            AppTextStyles.bodyText.copyWith(fontSize: fontSize),
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
                          borderSide:
                              BorderSide(color: AppColors.errorBorderColor),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              newPassword = !newPassword;
                            });
                          },
                          icon: Icon(
                            newPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: validatePassword,
                      onChanged: (value) {
                        controller.changePasswordRequest.newPassword = value;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      obscureText: conformpassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle:
                            AppTextStyles.bodyText.copyWith(fontSize: fontSize),
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
                          borderSide:
                              BorderSide(color: AppColors.errorBorderColor),
                        ),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            conformpassword=!conformpassword;
                          });
                        }, icon: Icon(conformpassword?Icons.visibility_off:Icons.visibility,size:20))
                      ),
                      validator: validateConfirmPassword,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          String oldPassword =
                              controller.changePasswordRequest.oldPassword;
                          String newPassword =
                              controller.changePasswordRequest.newPassword;

                          final changePasswordRequest = ChangePasswordRequest(
                            oldPassword: oldPassword,
                            newPassword: newPassword,
                          );
                          if (changePasswordRequest.validate()) {
                            controller.changePassword(changePasswordRequest);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: fontSize),
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
