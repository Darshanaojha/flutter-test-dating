import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/forget_password_request_model.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  PasswordInputPageState createState() => PasswordInputPageState();
}

class PasswordInputPageState extends State<PasswordInputPage> {
  final formKey = GlobalKey<FormState>();
  Controller controller = Get.find();
  bool passwordvisibility = true;
  bool conformpasswordvisibility = true;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    if (controller.forgetPasswordRequest.email.isNotEmpty) {
      controller.forgetPasswordRequest = ForgetPasswordRequest(
        email: controller.forgetPasswordRequest.email,
        newPassword: '',
      );
    }
  }

  String? password;
  String? confirmPassword;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    if (!hasDigit || !hasSpecialChar) {
      failure("Password",
          "Password must contain at least one digit and one special character.");
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != controller.forgetPasswordRequest.newPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Set Password', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
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
                    TextFormField(
                      cursorColor: AppColors.cursorColor,
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      obscureText: passwordvisibility,
                      decoration: InputDecoration(
                          labelText: 'Password',
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
                                  passwordvisibility = !passwordvisibility;
                                });
                              },
                              icon: Icon(passwordvisibility
                                  ? Icons.visibility_off
                                  : Icons.visibility))),
                      validator: validatePassword,
                      onChanged: (value) {
                        controller.forgetPasswordRequest.newPassword = value;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      cursorColor: AppColors.cursorColor,
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      obscureText: conformpasswordvisibility,
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
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
                                  conformpasswordvisibility =
                                      !conformpasswordvisibility;
                                });
                              },
                              icon: Icon(
                                  conformpasswordvisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20))),
                      validator: validateConfirmPassword,
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          if (controller.forgetPasswordRequest.validate()) {
                            await controller.getOtpForgetPassword(
                                controller.forgetPasswordRequest);
                          }
                        } else {
                          failure('password', '');
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
                      child: Text('Submit',
                          style: AppTextStyles.buttonText
                              .copyWith(fontSize: fontSize)),
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
