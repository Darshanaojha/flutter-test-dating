import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/controller.dart';
import '../../constants.dart';


class PackageListWidget extends StatefulWidget {


   PackageListWidget({super.key});



  @override
  PackageListWidgetState createState() => PackageListWidgetState();
}

class PackageListWidgetState extends State<PackageListWidget> {
  Controller controller = Get.put(Controller());
  RxString selectedPlan = 'None'.obs;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<bool> initializeData() async {
    if (!await controller.fetchAllPackages()) return false;
    if (!await controller.fetchAllHeadlines()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text("Packages"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Heading for the page
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Packages",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: fontSize + 2, // Increase font size for heading
                  color: AppColors.textColor,
                ),
              ),
            ),
            // Centered Package List
            Obx(() {
              if (controller.packages.isEmpty) {
                return Center(
                  child: Text(
                    "No packages available",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor,
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.packages.length,
                  itemBuilder: (context, index) {
                    final package = controller.packages[index];

                    return GestureDetector(
                      onTap: () {
                        _showPaymentConfirmationDialog(
                          context,
                          package.unit,
                          package.id,
                          '₹${package.offerAmount}',
                        );
                      },
                      child: Center( // Center the card on the page
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.orange,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: AppColors.iconColor,
                                        size: fontSize,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${package.unit} Plan - ₹${package.offerAmount}",
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize - 2,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return Text(
                                          selectedPlan.value == package.unit
                                              ? 'Selected'
                                              : 'Select',
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize - 2,
                                            color: selectedPlan.value == package.unit
                                                ? AppColors.buttonColor
                                                : AppColors.formFieldColor,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '20% OFF',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize - 6,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  // Show payment confirmation dialog
  Future<void> _showPaymentConfirmationDialog(BuildContext context,
      String planType, String planId, String amount) async {
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Subscription",
            style: AppTextStyles.titleText.copyWith(
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do you want to subscribe to the $planType plan for $amount?",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16),
                // Other content here
                Text(
                  "Additional information about the plan can go here.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Terms and conditions for the plan can also be shown here.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: fontSize,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Confirm",
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: fontSize,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
