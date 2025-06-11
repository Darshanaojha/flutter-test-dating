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
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Set Password',
          style: AppTextStyles.headingText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize * 1.2,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.07, vertical: 30),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set your password and confirm it.',
                      style: AppTextStyles.bodyText
                          .copyWith(fontSize: fontSize, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            cursorColor: AppColors.cursorColor,
                            style: AppTextStyles.inputFieldText.copyWith(
                                fontSize: fontSize, color: Colors.white),
                            obscureText: passwordvisibility,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: AppTextStyles.bodyText.copyWith(
                                  fontSize: fontSize, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: AppColors.errorBorderColor),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordvisibility = !passwordvisibility;
                                  });
                                },
                                icon: Icon(
                                  passwordvisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            validator: validatePassword,
                            onChanged: (value) {
                              controller.forgetPasswordRequest.newPassword =
                                  value;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            cursorColor: AppColors.cursorColor,
                            style: AppTextStyles.inputFieldText.copyWith(
                                fontSize: fontSize, color: Colors.white),
                            obscureText: conformpasswordvisibility,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: AppTextStyles.bodyText.copyWith(
                                  fontSize: fontSize, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: AppColors.errorBorderColor),
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
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: validateConfirmPassword,
                            onChanged: (value) {
                              setState(() {
                                confirmPassword = value;
                              });
                            },
                          ),
                          SizedBox(height: 28),
                          // Gradient Submit Button
                          GestureDetector(
                            onTap: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                formKey.currentState?.save();
                                if (controller.forgetPasswordRequest
                                    .validate()) {
                                  await controller.getOtpForgetPassword(
                                      controller.forgetPasswordRequest);
                                }
                              } else {
                                failure('password', '');
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // gradient: LinearGradient(
                                //   colors: AppColors.gradientBackgroundList,
                                //   begin: Alignment.topLeft,
                                //   end: Alignment.bottomRight,
                                // ),
                                borderRadius: BorderRadius.circular(16),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.deepPurple.withOpacity(0.18),
                                //     blurRadius: 8,
                                //     offset: Offset(0, 4),
                                //   ),
                                // ],
                              ),
                              child: Center(
                                child: Text(
                                  'Submit',
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: fontSize * 0.8,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}
