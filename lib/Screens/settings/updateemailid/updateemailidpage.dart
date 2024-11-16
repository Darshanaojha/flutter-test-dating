import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Models/RequestModels/update_emailid_request_model.dart';
import '../../../Models/ResponseModels/update_emailid_response_model.dart';
import '../../../Providers/update_emailid_provider.dart';
import '../../../constants.dart';
import 'updateemailotpverification.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  UpdateEmailPageState createState() => UpdateEmailPageState();
}
class UpdateEmailPageState extends State<UpdateEmailPage> {
  final passwordController = TextEditingController();
  final newEmailController = TextEditingController();

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; 
  }


  final formKey = GlobalKey<FormState>();

  String? passwordError;
  String? emailError;


  final updateEmailProvider = UpdateEmailidProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Email",
          style: AppTextStyles.headingText.copyWith(fontSize: getResponsiveFontSize(0.03)),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your password and new email address to update your email.",
                style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: AppTextStyles.labelText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: passwordError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: newEmailController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'New Email ID',
                        labelStyle: AppTextStyles.labelText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: emailError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "New email is required";
                        }
                        final emailRegExp = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegExp.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: 200, // Set the width as needed
                      child: ElevatedButton(
                        onPressed: updateEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Update Email",
                          style: AppTextStyles.buttonText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Get.to(EmailOtpVerificationPage());
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

  void updateEmail() async {
    setState(() {
      passwordError = null;
      emailError = null;
    });


    if (formKey.currentState!.validate()) {
     
      final updateEmailIdRequest = UpdateEmailIdRequest(
        password: passwordController.text,
        newEmail: newEmailController.text,
      );

      try {

        UpdateEmailIdResponse? response = await updateEmailProvider.updateEmailId(updateEmailIdRequest);

        if (response != null) {

          success("Success", 'Email updated successfully!');
          Get.to(EmailOtpVerificationPage());
        } else {
     
         failure("Error",  "Failed to update email. Please try again.");
        }
      } catch (e) {
        failure("Error", "Error: $e");

      }
    }
  }
}
