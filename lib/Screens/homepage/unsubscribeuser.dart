import 'dart:ui';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/userprofile/userprofilesummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/razorpaycontroller.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../constants.dart';

class Unsubscribeuser extends StatefulWidget {
  const Unsubscribeuser({super.key});

  @override
  UnsubscribeuserState createState() => UnsubscribeuserState();
}

class UnsubscribeuserState extends State<Unsubscribeuser>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  RazorpayController razorpaycontroller = Get.put(RazorpayController());
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  late Future<bool> _fetchProfileFuture;
  RxString selectedPlan = 'None'.obs;
  bool isProcessingPayment = false;
  

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = initializeData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
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

  Future<bool> initializeData() async {
    if (!await controller.fetchProfile()) return false;
    if (!await controller.fetchAllPackages()) return false;
    if (!await controller.fetchProfileUserPhotos()) return false;
    if (!await controller.fetchAllHeadlines()) return false;
    return true;
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
          backgroundColor: Colors.transparent,
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FutureBuilder<bool>(
            future: _fetchProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  // child: CircularProgressIndicator(),
                  child: Lottie.asset("assets/animations/Buyanimation.json",
                      repeat: true, reverse: true),
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
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   height: 600,
                        //   child: Scrollbar(
                        //     child: ListView.builder(
                        //       scrollDirection: Axis.vertical,
                        //       itemCount: controller.userPhotos!.images.length,
                        //       itemBuilder: (context, index) {
                        //         return Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: GestureDetector(
                        //             onTap: () => showFullImageDialog(
                        //               context,
                        //               controller.userPhotos!.images[index]
                        //                   .toString(),
                        //             ),
                        //             child: ClipRRect(
                        //               borderRadius: BorderRadius.circular(15),
                        //               child: Image.network(
                        //                 controller.userPhotos!.images[index],
                        //                 fit: BoxFit.cover,
                        //                 width: 150,
                        //                 height: 350,
                        //               ),
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 16),
                        // Text(
                        //   controller.userData.first.name,
                        //   style: AppTextStyles.headingText.copyWith(
                        //     fontSize: fontSize,
                        //   ),
                        // ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userData.first.dob).year} years old | ',
                        //       style: AppTextStyles.bodyText.copyWith(
                        //         fontSize: bodyFontSize,
                        //       ),
                        //     ),
                        //     Text(
                        //       '${controller.userData.first.city} | ',
                        //       style: AppTextStyles.bodyText.copyWith(
                        //         fontSize: bodyFontSize,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        UserProfileSummary(),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Available Packages",
                              style: AppTextStyles.headingText.copyWith(
                                fontSize: fontSize,
                                color: AppColors.textColor,
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
                                    final package =
                                        controller.packages[index];
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
                                          package.offerAmount,
                                        );
                                        controller
                                            .updateNewPackageRequestModel
                                            .packageId = package.id;
                                        razorpaycontroller.orderRequestModel
                                                .amount =
                                            package.offerAmount.toString();
                                        razorpaycontroller.orderRequestModel
                                            .packageId = package.id;
                                        razorpaycontroller
                                            .orderRequestModel.type = '2';
                                        print(razorpaycontroller
                                            .orderRequestModel
                                            .toJson()
                                            .toString());
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Obx(() {
                                              bool isSelected =
                                                  selectedPlan.value ==
                                                      package.id;
                                              return DecoratedBoxTransition(
                                                decoration: decorationTween
                                                    .animate(
                                                        _animationController),
                                                child: Card(
                                                  elevation: 8,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  clipBehavior:
                                                      Clip.antiAlias,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: isSelected
                                                          ? LinearGradient(
                                                              colors: AppColors
                                                                  .reversedGradientColor)
                                                          : null,
                                                      color: isSelected
                                                          ? null
                                                          : Colors.black,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: isSelected
                                                                ? AppColors
                                                                    .darkGradientColor
                                                                : AppColors
                                                                    .lightGradientColor,
                                                            size: fontSize *
                                                                1.5,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              "${toBeginningOfSentenceCase(package.unit.toLowerCase())} Plan  ₹${package.offerAmount}",
                                                              style: AppTextStyles
                                                                  .bodyText
                                                                  .copyWith(
                                                                fontSize:
                                                                    fontSize -
                                                                        4,
                                                                color: AppColors
                                                                    .textColor,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${offerPercentage.toStringAsFixed(0)}% OFF",
                                                            style: AppTextStyles
                                                                .bodyText
                                                                .copyWith(
                                                              fontSize:
                                                                  fontSize -
                                                                      6,
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                          // IconButton(
                                                          //     onPressed: () {},
                                                          //     icon: Icon(Icons
                                                          //         .arrow_drop_down_circle_outlined))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
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
                // return UserProfileSummary();
              }
              return Center(
                child: Text(
                  'Failed to load data. Please try again.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
          if (isProcessingPayment)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                    child: Lottie.asset(
                        "assets/animations/handloadinganimation.json")),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> showPaymentConfirmationDialog(BuildContext context,
      String planType, String planId, String amount) async {
    Size size = MediaQuery.of(context).size;
    controller.updateNewPackageRequestModel.packageId = planId;
    double fontSize = MediaQuery.of(context).size.width * 0.03;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            //   child: Container(
            //     color: Colors.black.withOpacity(0.5),
            //   ),
            // ),
            Center(
              child: Container(
                width: size.width * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: const Alignment(0.8, 1),
                    colors: AppColors.gradientBackgroundList,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Confirm Subscription",
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: fontSize + 4,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Do you want to subscribe to the $planType plan \n for Rs. $amount?",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: fontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  controller.headlines.isNotEmpty
                                      ? controller.headlines[10].title
                                      : "Loading Title...",
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: fontSize + 2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  controller.headlines.isNotEmpty
                                      ? controller.headlines[10].description
                                      : "Loading Description...",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: fontSize,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.reversedGradientColor,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SlideAction(
                              height: size.width * 0.1,
                              borderRadius: 12,
                              elevation: 0,
                              outerColor: Colors.transparent,
                              text: "Swipe to Pay",
                              textStyle: AppTextStyles.buttonText.copyWith(
                                fontSize: fontSize + 2,
                                color: Colors.white,
                              ),
                              innerColor: Colors.transparent,
                              sliderButtonIcon: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGradientColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.double_arrow_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              onSubmit: () async {
                                Navigator.of(context).pop();
                                setState(() {
                                  isProcessingPayment = true;
                                });
                                try {
                                  bool? isOrderCreated =
                                      await razorpaycontroller.createOrder(
                                          razorpaycontroller.orderRequestModel);
                                  if (isOrderCreated == true) {
                                    razorpaycontroller.initRazorpay();
                                    bool paymentSuccessful =
                                        await razorpaycontroller.startPayment(
                                      double.tryParse(amount) ?? 0.0,
                                      controller.userData.first.name,
                                      planId,
                                      controller.userData.first.mobile,
                                      controller.userData.first.email,
                                    );
                                    if (paymentSuccessful) {
                                      await _showSuccessDialog();
                                      controller.updatinguserpackage(controller
                                          .updateNewPackageRequestModel);
                                    }
                                  } else {
                                    failure("Order",
                                        "Your Payment Order Is Not Created");
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isProcessingPayment = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: AppColors.secondaryColor,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text("Payment Successful", style: AppTextStyles.titleText),
            ],
          ),
          content: Text(
            "Welcome to the Dating App! You have successfully subscribed to the plan. Enjoy all the premium features and benefits.",
            style: AppTextStyles.bodyText,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Awesome!", style: AppTextStyles.buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
