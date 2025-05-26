import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dating_application/Models/ResponseModels/get_all_packages_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final Controller controller = Get.put(Controller());
  final RazorpayController razorpaycontroller = Get.put(RazorpayController());
  final RxString selectedPlan = ''.obs;
  final RxString planId = ''.obs;
  final RxBool ispointused = false.obs;
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  final RxInt selectedCoins = 0.obs;
  int selectedIndex = 0;
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
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
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
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
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
    await controller.gettotalpoint();
  }

  double calculateOfferPercentage(String actualAmount, String offerAmount) {
    double actual = double.tryParse(actualAmount) ?? 0.0;
    double offer = double.tryParse(offerAmount) ?? 0.0;
    return actual > 0 ? ((actual - offer) / actual) * 100 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            controller.headlines.length > 10
                ? controller.headlines[10].title
                : "Loading Title...",
          );
        }),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.packages.isEmpty) {
          return const Center(
            child: Text(
              "No packages available.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return Text(
                    controller.headlines.length > 10
                        ? controller.headlines[10].description
                        : "Loading Description...",
                    style: AppTextStyles.textStyle,
                  );
                }),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: const Color(0xff870160), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          FaIcon(FontAwesomeIcons.crown,
                              color: Colors.amber, size: 30),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 200,
                            child: Text(
                              "Your Best Match is One Upgrade Away!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CarouselSlider.builder(
                  itemCount: controller.packages.length,
                  itemBuilder: (context, index, realIndex) {
                    final package = controller.packages[index];
                    double offerPercentage = calculateOfferPercentage(
                      package.actualAmount,
                      package.offerAmount,
                    );

                    double amount = double.tryParse(package.offerAmount) ?? 0.0;

                    return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title & Description
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: const Color(0xff870160), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pinkAccent.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.workspace_premium,
                                            color: Colors.amber, size: 24),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            package.status,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    const Divider(
                                        color: Colors.pinkAccent, thickness: 1),
                                    const SizedBox(height: 6),
                                    Text(
                                      package.packagecategory,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Features
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: const Color(0xff870160), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pinkAccent.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: controller.benefits
                                      .map<Widget>((feature) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              FontAwesomeIcons.checkCircle,
                                              color: Color(0xff870160),
                                              size: 16),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              feature.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Pricing
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: const Color(0xff870160), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pinkAccent.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      package.packageTitle,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹${package.actualAmount}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${package.offerAmount}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ]));
                  },
                  options: CarouselOptions(
                    height: 420,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.90,
                    padEnds: false,
                    initialPage: 0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
                Builder(
                  builder: (context) {
                    final selectedPackage = controller.packages[selectedIndex];
                    final selectedAmount =
                        double.tryParse(selectedPackage.offerAmount) ?? 0.0;

                    return Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff1f005c).withOpacity(0.6),
                            Color(0xff5b0060).withOpacity(0.6),
                            Color(0xff870160).withOpacity(0.6),
                            Color(0xffac255e).withOpacity(0.6),
                            Color(0xffca485c).withOpacity(0.6),
                            Color(0xffe16b5c).withOpacity(0.6),
                            Color(0xfff39060).withOpacity(0.6),
                            Color(0xfffffb56b).withOpacity(0.6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextButton(
                        onPressed: () {
                          final selectedPackage =
                              controller.packages[selectedIndex];
                          final selectedAmount =
                              double.tryParse(selectedPackage.offerAmount) ??
                                  0.0;
                          _showSubscriptionDialog(
                              context, selectedPackage, selectedAmount);

                          // setState(() {
                          //   planId.value = selectedPackage.id;
                          //   selectedPlan.value = selectedPackage.id;
                          // });

                          // showPaymentConfirmationDialog(
                          //   context,
                          //   selectedPackage.days,
                          //   selectedAmount,
                          // );

                          // razorpaycontroller.orderRequestModel.amount =
                          //     selectedPackage.offerAmount.toString();
                          // razorpaycontroller.orderRequestModel.packageId =
                          //     selectedPackage.id;
                          // razorpaycontroller.orderRequestModel.type = '2';

                          // print(
                          //     "ORDER: ${razorpaycontroller.orderRequestModel.toJson()}");
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            "Subscribe Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showSubscriptionDialog(
      BuildContext context, Package selectedPackage, double selectedAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black
                    .withOpacity(0.5), // Semi-transparent black overlay
              ),
            ),

            // Dialog Box at Center
            Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width *
                      0.85, // Responsive width
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xff870160), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon at the Top
                      Icon(Icons.workspace_premium,
                          color: Colors.amber, size: 50),
                      SizedBox(height: 10),

                      // Title
                      Text(
                        "Subscription",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),

                      // Content
                      Text(
                        "You have not yet subscribed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      SizedBox(height: 20),

                      // Buttons Row
                      Row(
                        children: [
                          // Subscribe Later Button
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.redAccent),
                                ),
                              ),
                              child: Text(
                                "Subscribe Later",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),

                          // Subscribe Now Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  planId.value = selectedPackage.id;
                                  selectedPlan.value = selectedPackage.id;
                                });

                                showPaymentConfirmationDialog(
                                  context,
                                  selectedPackage.days,
                                  selectedAmount,
                                );

                                razorpaycontroller.orderRequestModel.amount =
                                    selectedPackage.offerAmount.toString();
                                razorpaycontroller.orderRequestModel.packageId =
                                    selectedPackage.id;
                                razorpaycontroller.orderRequestModel.type = '2';

                                print(
                                    "ORDER: ${razorpaycontroller.orderRequestModel.toJson()}");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff870160),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                "Subscribe Now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                              ispointused.value = true;
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
                  razorpaycontroller.orderRequestModel.ispointused =
                      ispointused.value == true ? "1" : "0";

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
