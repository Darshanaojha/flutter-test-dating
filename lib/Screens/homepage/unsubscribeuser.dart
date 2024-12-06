import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../navigationbar/navigationpage.dart';
import '../navigationbar/unsubscribenavigation.dart';

class Unsubscribeuser extends StatefulWidget {
  const Unsubscribeuser({super.key});

  @override
  UnsubscribeuserState createState() => UnsubscribeuserState();
}

class UnsubscribeuserState extends State<Unsubscribeuser> {
  Controller controller = Get.put(Controller());

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  late Future<bool> _fetchProfileFuture;
  RxString selectedPlan = 'None'.obs;

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = initializeData();
  }

  Future<bool> initializeData() async {
    if (!await controller.fetchProfile()) return false;
    if (!await controller.fetchAllPackages()) return false;
    if (!await controller.fetchProfileUserPhotos()) return false;
    if (!await controller.fetchAllPackages()) return false;
    if (!await controller.fetchAllHeadlines()) return false;
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showFullImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.045;
    double bodyFontSize = size.width * 0.035;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FutureBuilder<bool>(
        future: _fetchProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // If the data is successfully loaded
          if (snapshot.hasData && snapshot.data!) {
            return SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 600,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: controller.userPhotos!.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () => showFullImageDialog(
                                context,
                                controller.userPhotos!.images[index],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  controller.userPhotos!.images[index],
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 350,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Display the user's name
                    Text(
                      controller.userData.first.name,
                      style: AppTextStyles.headingText.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
                    // Display the user's age and city
                    Row(
                      children: [
                        Text(
                          '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userData.first.dob).year} years old | ',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                          ),
                        ),
                        Text(
                          '${controller.userData.first.city} | ',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
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

                            // You can safely access properties of the package now
                            return GestureDetector(
                              onTap: () {
                                showPaymentConfirmationDialog(
                                  context,
                                  package.unit,
                                  package.id,
                                  '₹${package.offerAmount}',
                                );
                                controller.updateNewPackageRequestModel
                                    .packageId = package.id;
                                    Get.snackbar('', package.id.toString());
                              },
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
                                              style: AppTextStyles.bodyText
                                                  .copyWith(
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
                                              style: AppTextStyles.bodyText
                                                  .copyWith(
                                                fontSize: fontSize - 2,
                                                color: selectedPlan.value ==
                                                        package.unit
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 6),
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
          return Center(
            child: Text(
              'Failed to load data. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }

  Future<void> showPaymentConfirmationDialog(BuildContext context,
      String planType, String planId, String amount) async {
        controller.updateNewPackageRequestModel
                                    .packageId = planId;
    double fontSize = MediaQuery.of(context).size.width *
        0.03; // Adjust font size based on screen size
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
            // Make the content scrollable
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Ensure the column size adjusts to the content
              children: [
                Text(
                  "Do you want to subscribe to the $planType plan for $amount?",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[10].title
                      : "Loading Title...",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[10].description
                      : "Loading Title...",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10),
                // Add other widgets or content here as per your requirements
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
                // Add more widgets or content as necessary
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Handle cancellation or closing the dialog
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
                Get.offAll(NavigationBottomBar());
                controller.updatinguserpackage(
                    controller.updateNewPackageRequestModel);
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
