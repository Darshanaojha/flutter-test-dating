import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class GenerateReferralPage extends StatefulWidget {
  const GenerateReferralPage({super.key});

  @override
  GenerateReferralPageState createState() => GenerateReferralPageState();
}

class GenerateReferralPageState extends State<GenerateReferralPage> {
  Controller controller = Get.put(Controller());
  final formKey = GlobalKey<FormState>();

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (int.tryParse(value) == null) {
      return 'Phone number must be a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.03;
    double cardRadius = 24;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            'Generate Referral Code',
            style: AppTextStyles.titleText.copyWith(fontSize: fontSize * 1.2),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Refer a Friend!',
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: fontSize * 1.5,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Generate your referral code and share it with your friends.',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize * 1.1,
                    color: AppColors.textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                // Referral Code Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Your Referral Code',
                          style: AppTextStyles.labelText.copyWith(
                            color: Colors.white,
                            fontSize: fontSize * 1.1,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ABC123', // Replace with actual code if available
                          style: AppTextStyles.headingText.copyWith(
                            color: Colors.white,
                            fontSize: fontSize * 1.6,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28),
                // Phone Number Input
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 16),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter 10 digit phone number',
                          labelStyle: AppTextStyles.labelText
                              .copyWith(fontSize: fontSize),
                          filled: true,
                          fillColor: AppColors.formFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.textColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: AppColors.activeColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.textColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                        ),
                        style: AppTextStyles.inputFieldText
                            .copyWith(fontSize: fontSize),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: validatePhoneNumber,
                        onChanged: (value) {
                          controller.referalcoderequestmodel.mobile = value;
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28),
                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: AppColors.gradientBackgroundList,
                      ),
                      borderRadius: BorderRadius.circular(
                          30), // You can adjust the border radius here
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (controller.referalcoderequestmodel.validate()) {
                            controller.requestreference(
                                controller.referalcoderequestmodel);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Generate',
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: fontSize * 1.1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
