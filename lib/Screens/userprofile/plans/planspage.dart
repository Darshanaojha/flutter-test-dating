import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controllers/controller.dart';
import '../../navigationbar/navigationpage.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  PricingPageState createState() => PricingPageState();
}

class PricingPageState extends State<PricingPage> {
  Controller controller = Get.put(Controller());
  RxString selectedPlan = 'None'.obs;
  RxString planId = ''.obs;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await controller.fetchAllHeadlines();
    await controller.fetchAllPackages();
  }

  @override
  Widget build(BuildContext context) {
    double responsiveheight = MediaQuery.of(context).size.height * 0.07;

    return Scaffold(
      appBar: AppBar(
        title: Text('Become Our Prime Member'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Send unlimited likes, see who likes you first, filter by desires and find your people. Plus, you can chat with them!",
                  style: AppTextStyles.labelText),
              SizedBox(height: responsiveheight),
              buildPaymentWidget(context),
              SizedBox(height: responsiveheight),
              buildProsAndCons(context),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentWidget(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

    return Column(
      children: [
        Obx(() {
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                ],
              ),
            ),
          );
        }),
        Obx(() {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.packages.length,
            itemBuilder: (context, index) {
              final package = controller.packages[index];

              return GestureDetector(
                onTap: () {
                  showPaymentConfirmationDialog(context, planId.value);
                  planId.value = package.id;
                  selectedPlan.value = package.unit;
                  controller.updateNewPackageRequestModel.packageId =
                      package.id;
                },
                child: Obx(() {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: selectedPlan.value == package.unit
                            ? Colors.green // Highlight selected plan in green
                            : Colors.orange,
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
                              Text(
                                selectedPlan.value == package.unit
                                    ? 'Selected'
                                    : 'Select',
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: fontSize - 2,
                                  color: selectedPlan.value == package.unit
                                      ? AppColors.buttonColor
                                      : AppColors.formFieldColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 2,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 6),
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
                  );
                }),
              );
            },
          );
        }),
      ],
    );
  }

  Widget buildProsAndCons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pros of Becoming a Prime Member:",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 10),
        Text(
          "- Unlimited likes",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- See who likes you first",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Filter matches by your desires",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Ability to chat with matches",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 20),
        Text(
          "Cons of Becoming a Prime Member:",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 10),
        Text(
          "- Requires a paid subscription",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Might not be affordable for everyone",
          style: AppTextStyles.labelText,
        ),
      ],
    );
  }

  Future<void> showPaymentConfirmationDialog(
      BuildContext context, String planId) async {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Subscription",
            style: AppTextStyles.titleText.copyWith(
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          ),
          content: Text(
            "Do you want to subscribe to the ${selectedPlan.value} plan?",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: fontSize - 2,
              color: AppColors.textColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.snackbar('', planId.toString());
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.deniedColor,
                  fontSize: fontSize,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.offAll(NavigationBottomBar());
                controller.updatinguserpackage(
                    controller.updateNewPackageRequestModel);

                print("Subscribed to plan id ${planId.toString()}");
                print("Subscribed to ${selectedPlan.value}");
              },
              child: Text(
                'Subscribe',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.acceptColor,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
