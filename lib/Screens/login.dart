import 'package:dating_application/Models/ResponseModels/user_login_response_model.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/Screens/navigationbar/unsubscribenavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/user_login_request_model.dart';
import '../Providers/fcmService.dart';
import '../constants.dart';
import 'loginforgotpassword/forgotpasswordemail.dart';
import 'register_subpag/useremailnameinput.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final formKey = GlobalKey<FormState>();
  late UserLoginRequest loginRequest;
  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  bool isLoading = false;
  bool _isObscured = true;
  bool emailvisibility = true;
  @override
  void initState() {
    super.initState();
    loginRequest = UserLoginRequest(email: '', password: '');

    animationController = AnimationController(
      duration: Duration(seconds: 1),
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
        child: Center(
          child: FadeTransition(
            opacity: fadeInAnimation,
            child: Container(
              width: size.width * 0.96,
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      buildTextField('Email', (value) {
                        loginRequest.email = value;
                      }, TextInputType.emailAddress, size, fontSize),
                      buildPasswordField('Password', (value) {
                        loginRequest.password = value;
                      }, size, fontSize),
                      SizedBox(height: size.height * 0.05),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();

                            setState(() {
                              isLoading = true;
                            });
                            UserLoginResponse? response =
                                await controller.login(loginRequest);

                            setState(() {
                              isLoading = false;
                            });

                            if (response != null) {
                              if (response.success == true) {
                                String packagestatus =
                                    response.payload.packagestatus;
                                if (packagestatus == '0') {
                                  FCMService().subscribeToTopic("unsubscribed");
                                  FCMService().subscribeToTopic(
                                      response.payload.userId);
                                  FCMService().subscribeToTopic("alluser");
                                  Get.offAll(Unsubscribenavigation());
                                } else if (packagestatus == '1') {
                                  FCMService().subscribeToTopic("subscribed");
                                  FCMService().subscribeToTopic(
                                      response.payload.userId);
                                  FCMService().subscribeToTopic("alluser");
                                  Get.offAll(NavigationBottomBar());
                                }
                              } else {
                                Get.snackbar(
                                  'Login Failed',
                                  'Invalid credentials or network error.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.textColor,
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: AppTextStyles.buttonText
                              .copyWith(fontSize: fontSize),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      buildForgotPasswordButton(fontSize),
                      buildRegisterButton(size, fontSize),
                    ],
                  ),
                ),
              ),
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
        obscureText: emailvisibility,
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
                onPressed: () {
                setState(() {
                    emailvisibility = !emailvisibility;
                });
                },
                icon: Icon(
                    emailvisibility ? Icons.visibility_off : Icons.visibility,
                    size: 20))),
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
