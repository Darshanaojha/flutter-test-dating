import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_tooltip/super_tooltip.dart';
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

  RxInt selectedCoins = 0.obs;
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
                              context, package.days, amount);
                          razorpaycontroller.orderRequestModel.packageId =
                              package.id;
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

//  Future<void> showPaymentConfirmationDialog(
//     BuildContext context, String planId, double amount) async {
//   double fontSize = MediaQuery.of(context).size.width * 0.03;

//   // Fetch conversion values from API response
//   int coinValue = int.tryParse(controller.pointamount.first.points) ?? 100;
//   double amountValue = double.tryParse(controller.pointamount.first.amount) ?? 10.0;
//   double coinPrice = amountValue / coinValue; // ₹0.10 per coin

//   double availableCoins = double.tryParse(controller.totalpoint.first.points) ?? 0.0;
//   RxInt selectedCoins = 0.obs; // Reactive selected coins
//   RxDouble discountedAmount = amount.obs; // Reactive discounted amount

//   // Calculate the max coins user can apply (50% of amount)
//   int maxCoinsAllowed = ((amount / 2) * (coinValue / amountValue)).toInt();
//   maxCoinsAllowed = maxCoinsAllowed.clamp(0, availableCoins.toInt());

//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return Obx(() {
//         double totalPayable = discountedAmount.value - (selectedCoins.value * coinPrice);

//         return AlertDialog(
//           title: Text(
//             "Confirm Subscription",
//             style: AppTextStyles.titleText.copyWith(
//               fontSize: fontSize,
//               color: AppColors.textColor,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Do you want to subscribe to the selected plan?",
//                 style: AppTextStyles.bodyText.copyWith(
//                   fontSize: fontSize - 2,
//                   color: AppColors.textColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 15),

//               // Available Coins Display
//               Text(
//                 "Available Coins: ${availableCoins - selectedCoins.value}",
//                 style: AppTextStyles.titleText.copyWith(
//                   fontSize: fontSize,
//                   color: AppColors.textColor,
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // Coin Adjustment Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.remove_circle, color: Colors.red),
//                     onPressed: selectedCoins > 0
//                         ? () => selectedCoins.value -=10
//                         : null,
//                   ),
//                   Text(
//                     "${selectedCoins.value} Coins",
//                     style: AppTextStyles.titleText.copyWith(
//                       fontSize: fontSize,
//                       color: AppColors.textColor,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.add_circle, color: Colors.green),
//                     onPressed: selectedCoins < maxCoinsAllowed
//                         ? () => selectedCoins.value +=10
//                         : null,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 10),

//               // Updated Amount after Discount
//               Text(
//                 "Total Payable: ₹${totalPayable.toStringAsFixed(2)}",
//                 style: AppTextStyles.titleText.copyWith(
//                   fontSize: fontSize,
//                   color: AppColors.textColor,
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             // Cancel Button
//             TextButton(
//               onPressed: () {
//                 showCoinDialog(context, availableCoins);
//               },
//               child: Text(
//                 'Cancel',
//                 style: AppTextStyles.bodyText.copyWith(
//                   color: AppColors.deniedColor,
//                   fontSize: fontSize,
//                 ),
//               ),
//             ),

//             // Subscribe Button
//             TextButton(
//               onPressed: () async {
//                 bool? isOrderCreated = await razorpaycontroller.createOrder(
//                   razorpaycontroller.orderRequestModel,
//                 );

//                 if (isOrderCreated == true) {
//                   razorpaycontroller.initRazorpay();
//                   razorpaycontroller.openPayment(
//                     totalPayable,
//                     controller.userData.first.name,
//                     planId,
//                     controller.userData.first.mobile,
//                     controller.userData.first.email,
//                   );
//                 } else {
//                   failure("Order", "Your Payment Order Is Not Created");
//                 }
//                 Navigator.of(context).pop();
//                 print("Subscribed to plan id $planId");
//               },
//               child: Text(
//                 'Subscribe',
//                 style: AppTextStyles.bodyText.copyWith(
//                   color: AppColors.acceptColor,
//                   fontSize: fontSize,
//                 ),
//               ),
//             ),
//           ],
//         );
//       });
//     },
//   );
// }

  // Future<void> showPaymentConfirmationDialog(
  //     BuildContext context, String planId, double amount) async {
  //   double fontSize = MediaQuery.of(context).size.width * 0.03;

  //   // Fetch conversion values from API response
  //   int coinValue = int.tryParse(controller.pointamount.first.points) ?? 0;
  //   double amountValue =
  //       double.tryParse(controller.pointamount.first.amount) ?? 0.0;
  //   double coinPrice = amountValue / coinValue; // ₹0.10 per coin

  //   double availableCoins =
  //       double.tryParse(controller.totalpoint.first.points) ?? 0.0;
  //   RxBool useCoins = false.obs; // Checkbox state
  //   RxDouble discountedAmount = amount.obs; // Reactive discounted amount

  //   // Get the percentage threshold for max coin usage
  //   double thresholdPercentage =
  //       double.tryParse(controller.packages.first.threshold) ?? 0;
  //   int maxCoinsAllowed =
  //       ((thresholdPercentage / 100) * availableCoins).toInt();
  //   maxCoinsAllowed = maxCoinsAllowed.clamp(0, availableCoins.toInt());

  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Obx(() {
  //         // Apply discount if checkbox is selected
  //         selectedCoins.value = useCoins.value ? maxCoinsAllowed : 0;
  //         double discountAmount = selectedCoins.value * coinPrice;
  //         double totalPayable = discountedAmount.value - discountAmount;

  //         return AlertDialog(
  //           title: Text(
  //             "Confirm Subscription",
  //             style: AppTextStyles.titleText.copyWith(
  //               fontSize: fontSize,
  //               color: AppColors.textColor,
  //             ),
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 "Do you want to subscribe to the selected plan?",
  //                 style: AppTextStyles.bodyText.copyWith(
  //                   fontSize: fontSize - 2,
  //                   color: AppColors.textColor,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 15),
  //               Text(
  //                 "Available Coins: ${availableCoins - selectedCoins.value}",
  //                 style: AppTextStyles.titleText.copyWith(
  //                   fontSize: fontSize,
  //                   color: AppColors.textColor,
  //                 ),
  //               ),
  //               const SizedBox(height: 5),
  //               if (availableCoins > 0)
  //                 if (availableCoins > 0)
  //                   Row(
  //                     mainAxisAlignment:
  //                         MainAxisAlignment.start,
  //                     children: [
  //                       Obx(() => Checkbox(
  //                             value: useCoins.value,
  //                             onChanged: (bool? value) {
  //                               useCoins.value = value ?? false;
  //                             },
  //                           )),
  //                       Expanded(
  //                         child: Text(
  //                           "Redeem ${thresholdPercentage.toInt()}% of available coins",
  //                           style: AppTextStyles.bodyText.copyWith(
  //                             fontSize: fontSize,
  //                             color: AppColors.textColor,
  //                           ),
  //                           overflow: TextOverflow
  //                               .ellipsis, // Ensures text doesn't overflow
  //                         ),
  //                       ),
  //                       const SizedBox(width: 5),
  //                       SuperTooltip(
  //                         popupDirection: TooltipDirection.up,
  //                         content: Text(
  //                           "You can use up to ${thresholdPercentage.toInt()}% of your available coins for a discount.",
  //                           style: AppTextStyles.bodyText
  //                               .copyWith(fontSize: fontSize),
  //                         ),
  //                         child: Icon(Icons.info, color: Colors.blue, size: 12),
  //                       ),
  //                     ],
  //                   ),

  //               if (useCoins.value)
  //                 Text(
  //                   "Coins Used: $selectedCoins (₹${discountAmount.toStringAsFixed(2)} discount)",
  //                   style: AppTextStyles.bodyText.copyWith(
  //                     fontSize: fontSize,
  //                     color: Colors.green,
  //                   ),
  //                 ),

  //               const SizedBox(height: 10),

  //               // Updated Amount after Discount
  //               Text(
  //                 "Total Payable: ₹${totalPayable.toStringAsFixed(2)}",
  //                 style: AppTextStyles.titleText.copyWith(
  //                   fontSize: fontSize,
  //                   color: AppColors.textColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: <Widget>[
  //             // Cancel Button
  //             TextButton(
  //               onPressed: () {
  //                 showCoinDialog(context, availableCoins);
  //               },
  //               child: Text(
  //                 'Cancel',
  //                 style: AppTextStyles.bodyText.copyWith(
  //                   color: AppColors.deniedColor,
  //                   fontSize: fontSize,
  //                 ),
  //               ),
  //             ),

  //             // Subscribe Button
  //             TextButton(
  //               onPressed: () async {
  //                 bool? isOrderCreated = await razorpaycontroller.createOrder(
  //                   razorpaycontroller.orderRequestModel,
  //                 );

  //                 if (isOrderCreated == true) {
  //                   razorpaycontroller.initRazorpay();
  //                   razorpaycontroller.openPayment(
  //                     totalPayable,
  //                     controller.userData.first.name,
  //                     planId,
  //                     controller.userData.first.mobile,
  //                     controller.userData.first.email,
  //                   );
  //                 } else {
  //                   failure("Order", "Your Payment Order Is Not Created");
  //                 }
  //                 Navigator.of(context).pop();
  //                 print("Subscribed to plan id $planId");
  //               },
  //               child: Text(
  //                 'Subscribe',
  //                 style: AppTextStyles.bodyText.copyWith(
  //                   color: AppColors.acceptColor,
  //                   fontSize: fontSize,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  Future<void> showPaymentConfirmationDialog(
      BuildContext context, String planId, double amount) async {
    double fontSize = MediaQuery.of(context).size.width * 0.03;

    // Fetch conversion values from API response
    int coinValue = int.tryParse(controller.pointamount.first.points) ?? 0;
    double amountValue =
        double.tryParse(controller.pointamount.first.amount) ?? 0.0;
    double coinPrice = amountValue / coinValue; // ₹0.10 per coin

    double availableCoins =
        double.tryParse(controller.totalpoint.first.points) ?? 0.0;
    RxBool useCoins = false.obs; // Checkbox state
    RxDouble discountedAmount = amount.obs; // Reactive discounted amount

    // Get the percentage threshold for max coin usage
    double thresholdPercentage =
        double.tryParse(controller.packages.first.threshold) ?? 0;
    int maxCoinsAllowed = ((thresholdPercentage / 100) * amount).toInt();
    maxCoinsAllowed = maxCoinsAllowed.clamp(0, availableCoins.toInt());

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(() {
          // Apply discount if checkbox is selected
          selectedCoins.value = useCoins.value ? maxCoinsAllowed : 0;
          double discountAmount = selectedCoins.value * coinPrice;
          double totalPayable = discountedAmount.value - discountAmount;

          return AlertDialog(
            title: Text(
              "Confirm Subscription",
              style: AppTextStyles.titleText.copyWith(
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do you want to subscribe to the selected plan?",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Available Coins Display
                Text(
                  "Available Coins: ${availableCoins - selectedCoins.value}",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 5),

                if (availableCoins >= maxCoinsAllowed && maxCoinsAllowed > 0)
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: useCoins.value,
                            onChanged: (bool? value) {
                              useCoins.value = value ?? false;
                            },
                          )),
                      Expanded(
                        child: Text(
                          "Redeem ${thresholdPercentage.toInt()}% of your payable amount using coins",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SuperTooltip(
                        popupDirection: TooltipDirection.up,
                        content: Text(
                          "You can use up to ${thresholdPercentage.toInt()}% of your payable amount using available coins.",
                          style: AppTextStyles.bodyText
                              .copyWith(fontSize: fontSize),
                        ),
                        child: Icon(Icons.info, color: Colors.blue, size: 12),
                      ),
                    ],
                  )
                else
                  Text(
                    "Not enough coins to apply a discount.",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize,
                      color: Colors.red,
                    ),
                  ),

                if (useCoins.value)
                  Text(
                    "Coins Used: $selectedCoins (₹${discountAmount.toStringAsFixed(2)} discount)",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize,
                      color: Colors.green,
                    ),
                  ),

                const SizedBox(height: 10),

                // Updated Amount after Discount
                Text(
                  "Total Payable: ₹${totalPayable.toStringAsFixed(2)}",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              // Cancel Button
              TextButton(
                onPressed: () {
                  Get.snackbar('', planId.toString());
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.deniedColor,
                  ),
                ),
              ),

              // Subscribe Button
              TextButton(
                onPressed: () async {
                  razorpaycontroller.orderRequestModel.amount =
                      totalPayable.toString();
                  //  packages.offerAmount.toString();

                  razorpaycontroller.orderRequestModel.points =
                      selectedCoins.value.toString();
                  razorpaycontroller.orderRequestModel.type = '2';
                  print(
                      razorpaycontroller.orderRequestModel.toJson().toString());
                  bool? isOrderCreated = await razorpaycontroller.createOrder(
                    razorpaycontroller.orderRequestModel,
                  );

                  if (isOrderCreated == true) {
                    razorpaycontroller.initRazorpay();
                    razorpaycontroller.openPayment(
                      totalPayable,
                      controller.userData.first.name,
                      planId,
                      controller.userData.first.mobile,
                      controller.userData.first.email,
                    );
                  } else {
                    failure("Order", "Your Payment Order Is Not Created");
                  }
                  Navigator.of(context).pop();
                  print("Subscribed to plan id $planId");
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
        });
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
