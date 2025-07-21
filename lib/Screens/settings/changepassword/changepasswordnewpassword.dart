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

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    required double fontSize,
  }) {
    return TextFormField(
      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
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
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize =
                MediaQuery.of(context).size.width * 0.05; // ~5% of screen width
            return Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        foregroundColor: AppColors.textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double fontSize = screenWidth * 0.035;

          return Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 30,
              ),
              child: Container(
                width: screenWidth > 500
                    ? 450
                    : double.infinity, // Responsive width
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Enter your current password and set a new one.',
                        style:
                            AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildPasswordField(
                              label: 'Current Password',
                              obscureText: currentpassword,
                              onToggle: () => setState(
                                  () => currentpassword = !currentpassword),
                              onChanged: (value) => controller
                                  .changePasswordRequest.oldPassword = value,
                              validator: validatePassword,
                              fontSize: fontSize,
                            ),
                            SizedBox(height: 20),
                            _buildPasswordField(
                              label: 'New Password',
                              obscureText: newPassword,
                              onToggle: () =>
                                  setState(() => newPassword = !newPassword),
                              onChanged: (value) => controller
                                  .changePasswordRequest.newPassword = value,
                              validator: validatePassword,
                              fontSize: fontSize,
                            ),
                            SizedBox(height: 20),
                            _buildPasswordField(
                              label: 'Confirm New Password',
                              obscureText: conformpassword,
                              onToggle: () => setState(
                                  () => conformpassword = !conformpassword),
                              validator: validateConfirmPassword,
                              fontSize: fontSize,
                            ),
                            SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  String oldPassword = controller
                                      .changePasswordRequest.oldPassword;
                                  String newPassword = controller
                                      .changePasswordRequest.newPassword;

                                  final changePasswordRequest =
                                      ChangePasswordRequest(
                                    oldPassword: oldPassword,
                                    newPassword: newPassword,
                                  );
                                  if (changePasswordRequest.validate()) {
                                    controller
                                        .changePassword(changePasswordRequest);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: AppTextStyles.buttonText.copyWith(
                                    fontSize: fontSize, color: Colors.black),
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
          );
        },
      ),
    );
  }
}
