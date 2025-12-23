import 'package:dating_application/Models/ResponseModels/user_login_response_model.dart';
import 'package:dating_application/Screens/auth.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/Screens/navigationbar/unsubscribenavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/user_login_request_model.dart';
import '../Providers/fcmService.dart';
import '../constants.dart';
import '../widgets/loading_overlay.dart';
import '../services/login_service.dart';
import 'loginforgotpassword/forgotpasswordemail.dart';
import 'register_subpag/useremailnameinput.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  late final Controller controller;
  final formKey = GlobalKey<FormState>();
  late UserLoginRequest loginRequest;
  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  bool _isObscured = true;
  bool emailvisibility = true;
  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<Controller>()
        ? Get.find<Controller>()
        : Get.put(Controller(), permanent: true);
    loginRequest = UserLoginRequest(email: '', password: '');

    animationController = AnimationController(
      duration: Duration(milliseconds: 360),
      vsync: this,
    )..forward();

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.03;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: AuthCard(
          title: 'Login',
          animation: fadeInAnimation,
          maxHeight: size.height * 1.0,
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: size.height * 0.03),
                buildTextField('Email', (value) {
                  loginRequest.email = value;
                }, TextInputType.emailAddress, size, fontSize),
                buildPasswordField('Password', (value) {
                  loginRequest.password = value;
                }, size, fontSize),
                SizedBox(height: size.height * 0.03),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 1),
                      colors: AppColors.gradientBackgroundList,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        try {
                          // Show loading overlay immediately
                          await showLoadingOverlay(
                            context,
                            messages: [
                              'Authenticating...',
                              'Setting up your account...',
                              'Configuring notifications...',
                            ],
                            messageDuration: const Duration(seconds: 2),
                            showBrandingAnimation: true,
                          );

                          // Perform login with timeout and status updates
                          final LoginResult result = await LoginService.performLoginWithTimeout(
                            loginRequest: loginRequest,
                            controller: controller,
                            onStatusUpdate: (status) {
                              debugPrint('Login status: $status');
                            },
                          );

                          // Hide loading overlay
                          await hideLoadingOverlay();

                          // Handle result
                          if (result.success && result.loginResponse != null) {
                            final String packagestatus = result.packageStatus ?? '0';
                            
                            if (packagestatus == '0') {
                              Get.offAll(Unsubscribenavigation());
                            } else {
                              // Status '1', '4', or any other - navigate to main app
                              Get.offAll(NavigationBottomBar());
                            }
                          } else {
                            // Show error message
                            if (result.timedOut) {
                              Get.snackbar(
                                'Login Timeout',
                                'Login took too long. Please check your connection and try again.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 4),
                              );
                            } else {
                              final String errorMsg = result.errorMessage.isNotEmpty
                                  ? result.errorMessage
                                  : 'Login failed. Please check your credentials.';
                              
                            Get.snackbar(
                              'Login Failed',
                                errorMsg,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                                duration: const Duration(seconds: 4),
                            );
                          }
                          }
                        } catch (e) {
                          // Hide loading overlay on error
                          await hideLoadingOverlay();
                          
                          debugPrint('Error during login: $e');
                          Get.snackbar(
                            'Login Error',
                            'An unexpected error occurred. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 4),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.textColor,
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style:
                          AppTextStyles.buttonText.copyWith(fontSize: fontSize),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                buildForgotPasswordButton(fontSize),
                // buildRegisterButton(size, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String) onSaved,
      TextInputType type, Size size, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: type,
        obscureText: false,
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          fillColor: AppColors.formFieldColor,
          filled: true,
        ),
        onSaved: (value) => onSaved(value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget buildPasswordField(
      String label, Function(String) onSaved, Size size, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: _isObscured,
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          fillColor: AppColors.formFieldColor,
          filled: true,
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ),
        onSaved: (value) => onSaved(value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget buildForgotPasswordButton(double fontSize) {
    return TextButton(
      onPressed: () {
        Get.to(() => EmailInputPage());
      },
      child: Text(
        'Forgot Password?',
        style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
      ),
    );
  }

  Widget buildRegisterButton(Size size, double fontSize) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        TextButton(
          onPressed: () {
            Get.to(UserInputPage());
            // Get.to(OTPVerificationPage());
            // Get.to(RegisterProfilePage());
          },
          child: Text(
            'Don\'t have an account? Register here',
            style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}
