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
  RxString selectedPlan = ''.obs; // Only store selected plan's ID
  RxString planId = ''.obs;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await controller.fetchAllHeadlines();
    await controller.fetchAllPackages();
    await controller.fetchBenefits(); // Ensure benefits are fetched
  }

  double calculateOfferPercentage(String actualAmount, String offerAmount) {
    double actual = double.parse(actualAmount);
    double offer = double.parse(offerAmount);
    return ((actual - offer) / actual) * 100;
  }

  @override
  Widget build(BuildContext context) {
    double responsiveHeight = MediaQuery.of(context).size.height * 0.07;
    // double responsiveWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(controller.headlines.isNotEmpty
              ? controller.headlines[10].title
              : "Loading Title...");
        }),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return Text(
                      controller.headlines.isNotEmpty
                          ? controller.headlines[10].description
                          : "Loading Title...",
                      style: AppTextStyles.labelText,
                    );
                  }),
                  SizedBox(height: responsiveHeight),
                  buildPaymentWidget(context),
                  SizedBox(height: responsiveHeight),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showBenefitsBottomSheet(context);
                      },
                      child: Text('Click Benefits'),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentWidget(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 22), // Vertical padding to add space
      child: Column(
        children: [
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.packages.length,
              itemBuilder: (context, index) {
                final package = controller.packages[index];
                double offerPercentage = calculateOfferPercentage(
                    package.actualAmount, package.offerAmount);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        planId.value = package.id;
                        selectedPlan.value = package.id;
                      });
                      showPaymentConfirmationDialog(context, planId.value);
                    },
                    child: Obx(() {
                      bool isSelected = selectedPlan.value == package.id;
                      return Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation:
                              6, // Reduced elevation for a flatter card appearance
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Smaller border radius
                          ),
                          color: isSelected
                              ? Colors.green.shade500
                              : Colors.grey,
                          child: Padding(
                            padding: const EdgeInsets.all(
                                10.0), // Reduced padding inside the card
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.iconColor,
                                  size: fontSize * 1.5, // Adjusted icon size
                                ),
                                SizedBox(
                                    width:
                                        8), // Reduced spacing between icon and text
                                Expanded(
                                  child: Text(
                                    "${package.unit} Plan - ₹${package.offerAmount}",
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize:
                                          fontSize - 4, // Reduced font size
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${offerPercentage.toStringAsFixed(0)}% OFF",
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: fontSize -
                                        2, // Reduced font size for offer
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> showPaymentConfirmationDialog(
      BuildContext context, String planId) async {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

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
          content: Text(
            "Do you want to subscribe to the selected plan?",
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
                print("Subscribed to the selected plan");
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

  void showBenefitsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Benefits of Becoming a Prime Member:",
                style: AppTextStyles.titleText,
              ),
              SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (controller.benefits.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: controller.benefits.length,
                    itemBuilder: (context, index) {
                      final benefit = controller.benefits[index];
                      return ListTile(
                        title: Text(
                          benefit.title,
                          style: AppTextStyles.bodyText,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
