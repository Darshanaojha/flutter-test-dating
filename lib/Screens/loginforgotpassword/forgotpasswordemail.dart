
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

  initialize(){
    
  }
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
    double fontSize = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text('Email Input', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter your email address to proceed.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
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
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppTextStyles.labelText
                            .copyWith(fontSize: fontSize),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          success('Success',
                              'Email Submitted: ${controller.forgetPasswordRequest.email}');
                              controller.getOtpForgetPassword(controller.forgetPasswordRequest);
                          Get.to(PasswordInputPage());
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
                    ElevatedButton(
                        onPressed: () {
                          Get.to(PasswordInputPage());
                        },
                        child: Text('Next'))
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
