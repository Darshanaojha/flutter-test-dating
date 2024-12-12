import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  UpdateEmailPageState createState() => UpdateEmailPageState();
}

class UpdateEmailPageState extends State<UpdateEmailPage> {
  Controller controller = Get.find();

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Email",
          style: AppTextStyles.headingText.copyWith(
              fontSize: getResponsiveFontSize(0.03)),
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
                style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03)),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Password Field
                    TextFormField(
                      obscureText: true,
                      style: AppTextStyles.inputFieldText.copyWith(
                          fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: AppTextStyles.labelText.copyWith(
                            fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        controller.updateEmailIdRequest.password = value;
                      },
                      onSaved: (value) {
                        controller.updateEmailIdRequest.password = value ?? '';
                      },
                    ),
                    SizedBox(height: 16),

                    // New Email Field
                    TextFormField(
                      style: AppTextStyles.inputFieldText.copyWith(
                          fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'New Email ID',
                        labelStyle: AppTextStyles.labelText.copyWith(
                            fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      onChanged: (value) {
                        controller.updateEmailIdRequest.newEmail = value;
                      },
                      onSaved: (value) {
                        controller.updateEmailIdRequest.newEmail = value ?? '';
                      },
                    ),
                    SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            // Save form data
                            formKey.currentState?.save();

                            // Call the update method
                            try {
                              
                              await controller.updateEmailId(
                                  controller.updateEmailIdRequest);
                              // Show success message
                             success(
                                "Success",
                                "Email has been updated successfully!",
                             
                              );
                            } catch (e) {
                              // Handle error
                             failure(
                                "Error",
                                "Failed to update email: ${e.toString()}",
                               
                              );
                            }
                          } else {
                            
                            failure(
                              "Error",
                              "Please fix the errors in the form.",
                             
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Update Email",
                          style: AppTextStyles.buttonText.copyWith(
                              fontSize: getResponsiveFontSize(0.03)),
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
    );
  }
}
