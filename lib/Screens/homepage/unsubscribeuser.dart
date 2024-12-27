import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../navigationbar/navigationpage.dart';

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

  double calculateOfferPercentage(String actualAmount, String offerAmount) {
    double actual = double.parse(actualAmount);
    double offer = double.parse(offerAmount);
    return ((actual - offer) / actual) * 100;
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
                      child: Scrollbar(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: controller.userPhotos!.images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => showFullImageDialog(
                                  context,
                                  controller.userPhotos!.images[index]
                                      .toString(),
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
                    ),
                    SizedBox(height: 16),
                    Text(
                      controller.userData.first.name,
                      style: AppTextStyles.headingText.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
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
                        return SizedBox(
                          height: 200,
                          child: Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.packages.length,
                              itemBuilder: (context, index) {
                                final package = controller.packages[index];
                                double offerPercentage =
                                    calculateOfferPercentage(
                                        package.actualAmount,
                                        package.offerAmount);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPlan.value = package.id;
                                    });
                                    showPaymentConfirmationDialog(
                                      context,
                                      package.unit,
                                      package.id,
                                      '₹${package.offerAmount}',
                                    );
                                    controller.updateNewPackageRequestModel
                                        .packageId = package.id;
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Obx(() {
                                        bool isSelected =
                                            selectedPlan.value == package.id;
                                        return Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          color: isSelected
                                              ? Colors.green.shade500
                                              : Colors.grey,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: AppColors.iconColor,
                                                  size: fontSize * 1.5,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "${package.unit} Plan  ₹${package.offerAmount}",
                                                    style: AppTextStyles
                                                        .bodyText
                                                        .copyWith(
                                                      fontSize: fontSize - 4,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${offerPercentage.toStringAsFixed(0)}% OFF",
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: fontSize - 2,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      // showBenefitsBottomSheet(context);
                                                    },
                                                    icon: Icon(Icons
                                                        .arrow_drop_down_circle_outlined))
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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
    controller.updateNewPackageRequestModel.packageId = planId;
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Subscription",
            style: AppTextStyles.titleText.copyWith(
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          ),
          content: SizedBox(
            height: 200,
            child: Scrollbar(
              child: SingleChildScrollView(
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
