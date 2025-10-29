import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dating_application/Models/ResponseModels/get_all_packages_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../Controllers/controller.dart';
import '../../../Controllers/razorpaycontroller.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../navigationbar/navigationpage.dart';

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
  bool isProcessingPayment = false;

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
    // await controller.fetchAllHeadlines();
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
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0,
        centerTitle: true,
        title: Obx(() {
          double fontSize = MediaQuery.of(context).size.width * 0.05;
          return Text(
            controller.headlines.length > 10
                ? controller.headlines[10].title
                : "Loading Title...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          );
        }),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.gradientBackgroundList,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66666666),
                blurRadius: 10.0,
                spreadRadius: 3.0,
                offset: Offset(0, 6.0),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.crown,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: const Text(
                                  "Your Best Match is One Upgrade Away!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                        calculateOfferPercentage(
                          package.actualAmount,
                          package.offerAmount,
                        );

                        double.tryParse(package.offerAmount) ?? 0.0;

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 15),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment(0.8, 1),
                                          colors:
                                              AppColors.gradientBackgroundList,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.workspace_premium,
                                                  color: Colors.white,
                                                  size: 24),
                                              const SizedBox(width: 9),
                                              Expanded(
                                                child: Text(
                                                  package.packagecategory,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Expanded(
                                                child: Text(
                                                  package.packageDescription,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(0.8, 1),
                                        colors:
                                            AppColors.gradientBackgroundList,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Obx(() => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: controller.benefits
                                              .map<Widget>((feature) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 6.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      FontAwesomeIcons
                                                          .checkCircle,
                                                      color: Colors.white,
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
                                        )),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(0.8, 1),
                                        colors:
                                            AppColors.gradientBackgroundList,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
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
                                                color: Colors.white,
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
                        height: 450,
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
                        final selectedPackage =
                            controller.packages[selectedIndex];
                        final selectedAmount =
                            double.tryParse(selectedPackage.offerAmount) ?? 0.0;

                        return Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(0.8, 1),
                              colors: AppColors.gradientBackgroundList,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _showSubscriptionDialog(
                                  context, selectedPackage, selectedAmount);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
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

  void _showSubscriptionDialog(
      BuildContext context, Package selectedPackage, double selectedAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium,
                          color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Subscription",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You have not yet subscribed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: AppColors.gradientBackgroundList,
                                  ).createShader(
                                    Rect.fromLTWH(
                                        0, 0, bounds.width, bounds.height),
                                  ),
                                  child: Text(
                                    "Subscribe Later",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppColors.reversedGradientColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    planId.value = selectedPackage.id;
                                    selectedPlan.value = selectedPackage.id;
                                  });

                                  Navigator.of(context).pop();

                                  showPaymentConfirmationDialog(
                                    context,
                                    selectedPackage.days,
                                    selectedAmount,
                                  );

                                  razorpaycontroller.orderRequestModel.amount =
                                      selectedPackage.offerAmount.toString();
                                  razorpaycontroller.orderRequestModel
                                      .packageId = selectedPackage.id;
                                  razorpaycontroller.orderRequestModel.type =
                                      '2';

                                  print(
                                      "ORDER: ${razorpaycontroller.orderRequestModel.toJson()}");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Subscribe Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

  Future<void> showPaymentConfirmationDialog(
      BuildContext context, String planId, double amount) async {
    double fontSize = MediaQuery.of(context).size.width * 0.03;

    double coinValue = controller.pointamount.isNotEmpty
        ? double.tryParse(controller.pointamount.first.points) ?? 0.0
        : 0.0;
    double amountValue = controller.pointamount.isNotEmpty
        ? double.tryParse(controller.pointamount.first.amount) ?? 0.0
        : 0.0;
    double coinPrice = coinValue > 0 ? amountValue / coinValue : 0.0;

    double availableCoins = controller.totalpoint.isNotEmpty
        ? double.tryParse(controller.totalpoint.first.points) ?? 0.0
        : 0.0;
    RxBool useCoins = false.obs;
    RxDouble discountedAmount = amount.obs;

    double thresholdPercentage = controller.packages.isNotEmpty
        ? double.tryParse(controller.packages.first.threshold) ?? 0
        : 0;
    int maxCoinsAllowed = ((thresholdPercentage / 100) * amount).toInt();
    maxCoinsAllowed = maxCoinsAllowed.clamp(0, availableCoins.toInt());

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return Obx(() {
          selectedCoins.value = useCoins.value ? maxCoinsAllowed : 0;
          double discountAmount = selectedCoins.value * coinPrice;
          double totalPayable = discountedAmount.value - discountAmount;

          return Stack(children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
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
                        // Title and Close Button Row
                        SizedBox(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "Confirm Subscription",
                                style: AppTextStyles.titleText.copyWith(
                                  fontSize: fontSize + 4,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Scrollable Content
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Do you want to subscribe to the selected plan?",
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: fontSize - 1,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Available Coins: ${availableCoins - selectedCoins.value}",
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: fontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (availableCoins >= maxCoinsAllowed &&
                                    maxCoinsAllowed > 0)
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
                                          "Redeem ${thresholdPercentage.toInt()}% using coins",
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SuperTooltip(
                                        popupDirection: TooltipDirection.up,
                                        content: Text(
                                          "Use up to ${thresholdPercentage.toInt()}% of the amount using coins.",
                                          style: AppTextStyles.bodyText
                                              .copyWith(fontSize: fontSize),
                                        ),
                                        child: const Icon(Icons.info,
                                            color: Colors.white, size: 12),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    "Not enough coins to apply a discount.",
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: fontSize,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                if (useCoins.value)
                                  Text(
                                    "Coins Used: ${selectedCoins.value} (₹${discountAmount.toStringAsFixed(2)} discount)",
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: fontSize,
                                      color: Colors.lightGreenAccent,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  "Total Payable: ₹${totalPayable.toStringAsFixed(2)}",
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: fontSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Swipe to Pay Button at the Bottom
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
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: SlideAction(
                              height: size.width * 0.1,
                              borderRadius: 12,
                              elevation: 0,
                              outerColor: Colors.transparent,
                              text: "Swipe to Pay",
                              textStyle: AppTextStyles.buttonText.copyWith(
                                fontSize: fontSize,
                                color: Colors.white,
                              ),
                              innerColor: Colors.transparent,
                              sliderButtonIcon: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGradientColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: const Icon(
                                      Icons.double_arrow_outlined,
                                      color: Colors.white,
                                    ),
                                  )),
                              onSubmit: () async {
                                Navigator.of(context)
                                    .pop(); // Close confirmation dialog

                                setState(() {
                                  isProcessingPayment = true;
                                });

                                try {
                                  razorpaycontroller.orderRequestModel.amount =
                                      totalPayable.toString();
                                  razorpaycontroller
                                          .orderRequestModel.ispointused =
                                      ispointused.value == true ? "1" : "0";
                                  razorpaycontroller.orderRequestModel.points =
                                      selectedCoins.value.toString();
                                  razorpaycontroller.orderRequestModel.type = '2';

                                  bool? isOrderCreated =
                                      await razorpaycontroller.createOrder(
                                    razorpaycontroller.orderRequestModel,
                                  );

                                  if (isOrderCreated == true) {
                                    razorpaycontroller.initRazorpay();
                                    bool paymentSuccessful =
                                        await razorpaycontroller.startPayment(
                                      totalPayable,
                                      controller.userData.first.name,
                                      planId,
                                      controller.userData.first.mobile,
                                      controller.userData.first.email,
                                    );

                                    if (paymentSuccessful) {
                                      await _showSuccessDialog();
                                      Get.offAll(() => NavigationBottomBar());
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
          ]);
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
