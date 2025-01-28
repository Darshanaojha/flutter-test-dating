import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../Controllers/razorpaycontroller.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  PricingPageState createState() => PricingPageState();
}

class PricingPageState extends State<PricingPage>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  RazorpayController razorpaycontroller = Get.put(RazorpayController());
  RxString selectedPlan = ''.obs;
  RxString planId = ''.obs;
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  @override
  void initState() {
    super.initState();
    initializeData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await controller.fetchAllHeadlines();
    await controller.fetchAllPackages();
    await controller.fetchBenefits();
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
                      style: AppTextStyles.textStyle,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Click Benefits',
                        selectionColor: AppColors.FavouriteColor,
                      ),
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
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          Obx(() {
            return SizedBox(
              height: 500,
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.packages.length,
                  itemBuilder: (context, index) {
                    final package = controller.packages[index];
                    double offerPercentage = calculateOfferPercentage(
                        package.actualAmount, package.offerAmount);
                    double amount = double.tryParse(package.offerAmount) ?? 0.0; 
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            planId.value = package.id;
                            selectedPlan.value = package.id;
                          });
                          showPaymentConfirmationDialog(
                            context,
                            package.days,
                            amount
                          );
                          razorpaycontroller.orderRequestModel.amount =
                              package.offerAmount.toString();
                          razorpaycontroller.orderRequestModel.packageId =
                              package.id;
                          razorpaycontroller.orderRequestModel.type = '2';
                          print(razorpaycontroller.orderRequestModel
                              .toJson()
                              .toString());
                        },
                        child: Obx(() {
                          bool isSelected = selectedPlan.value == package.id;
                          return Container(
                            width: cardWidth,
                            margin: EdgeInsets.only(bottom: 16),
                            child: DecoratedBoxTransition(
                              decoration:
                                  decorationTween.animate(_animationController),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: isSelected
                                    ? Colors.green.shade500
                                    : Colors.black,
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
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize - 4,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${offerPercentage.toStringAsFixed(0)}% OFF",
                                        style: AppTextStyles.bodyText.copyWith(
                                          fontSize: fontSize - 2,
                                          color: Colors.red,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            showBenefitsBottomSheet(context);
                                          },
                                          icon: Icon(Icons
                                              .arrow_drop_down_circle_outlined))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> showPaymentConfirmationDialog(
      BuildContext context, String planId, double amount) async {
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
              onPressed: () async {
                bool? isOrderCreated = await razorpaycontroller
                    .createOrder(razorpaycontroller.orderRequestModel);
                if (isOrderCreated == true) {
                  razorpaycontroller.initRazorpay();
                  razorpaycontroller.openPayment(
                      amount, controller.userData.first.name, planId,  controller.userData.first.mobile,  controller.userData.first.email);
                } else {
                  failure("Order", "Your Payment Order Is Not Created");
                }
                // controller.updatinguserpackage(
                //     controller.updateNewPackageRequestModel);

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
                          style: AppTextStyles.textStyle,
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
