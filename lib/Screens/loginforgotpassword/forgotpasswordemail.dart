import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/controller.dart';
import '../../constants.dart';
import 'forgotpaswordenter.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  EmailInputPageState createState() => EmailInputPageState();
}

class EmailInputPageState extends State<EmailInputPage> {
  final formKey = GlobalKey<FormState>();
  Controller controller = Get.find();

  TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() {}
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.045;

    return Scaffold(
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
          'Forgot Password',
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
                      'Enter your email address to proceed.',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            cursorColor: AppColors.cursorColor,
                            style: AppTextStyles.inputFieldText.copyWith(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: AppTextStyles.labelText.copyWith(
                                fontSize: fontSize,
                                color: Colors.white70,
                              ),
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
                            ),
                            validator: validateEmail,
                            onChanged: (value) {
                              setState(() {
                                controller.forgetPasswordRequest.email = value;
                              });
                            },
                            onSaved: (value) {
                              controller.forgetPasswordRequest.email =
                                  value.toString();
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 28),
                          // Gradient Submit Button
                          GestureDetector(
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                success('Success',
                                    'Email Submitted: ${controller.forgetPasswordRequest.email}');

                                // controller.getOtpForgetPassword(
                                //     controller.forgetPasswordRequest);
                                Get.to(PasswordInputPage());
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
                                    color: Colors.black87,
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
