import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import 'CreatorFormPage.dart';

class PricingModel {
  final String title;
  final double offerAmount;
  final double actualAmount;
  final int duration;
  final String unit;
  final String description;
  final String type;

  PricingModel({
    required this.title,
    required this.offerAmount,
    required this.actualAmount,
    required this.duration,
    required this.unit,
    required this.description,
    required this.type,
  });
}

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  PricingPageState createState() => PricingPageState();
}

class PricingPageState extends State<PricingPage> {
  bool isYearly = false;
  int? selectedIndex;

  Gradient commonGradient = const LinearGradient(
    colors: [
      Color(0xff1f005c),
      Color(0xff5b0060),
      Color(0xff870160),
      Color(0xffac255e),
      Color(0xffca485c),
      Color(0xffe16b5c),
      Color(0xfff39060),
      Color(0xfffffb56b),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<PricingModel> get pricingPlans => [
        PricingModel(
          title: "Starter",
          offerAmount: isYearly ? 79.99 : 9.99,
          actualAmount: isYearly ? 99.99 : 14.99,
          duration: isYearly ? 12 : 1,
          unit: "month${isYearly ? 's' : ''}",
          description:
              "Access to basic features\nSupport via email\n1 project slot",
          type: "basic",
        ),
        PricingModel(
          title: "Pro",
          offerAmount: isYearly ? 149.99 : 19.99,
          actualAmount: isYearly ? 199.99 : 29.99,
          duration: isYearly ? 12 : 3,
          unit: "month${isYearly ? 's' : ''}",
          description:
              "Access to all features\nPriority support\n5 project slots",
          type: "cut",
        ),
        PricingModel(
          title: "Ultimate",
          offerAmount: isYearly ? 399.99 : 49.99,
          actualAmount: isYearly ? 499.99 : 59.99,
          duration: 12,
          unit: "months",
          description:
              "All features unlocked\nDedicated manager\nUnlimited projects",
          type: "premium",
        ),
      ];
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            // Toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Monthly",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: isYearly,
                  onChanged: (value) {
                    setState(() {
                      isYearly = value;
                    });
                  },
                  activeColor: Colors.amber,
                ),
                Text(
                  "Yearly",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),

            // Cards
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: pricingPlans.asMap().entries.map((entry) {
                      int index = entry.key;
                      PricingModel plan = entry.value;

                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: AnimatedScale(
                              duration: Duration(milliseconds: 200),
                              scale: selectedIndex == index ? 1.05 : 1.0,
                              child: PricingCard(
                                plan: plan,
                                gradient: commonGradient,
                                isSelected: selectedIndex == index,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final PricingModel plan;
  final Gradient gradient;
  final bool isSelected;

  const PricingCard({
    super.key,
    required this.plan,
    required this.gradient,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isHighlighted = plan.type == 'cut';
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (isHighlighted || isSelected)
            BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20),
        ],
        border: Border.all(
          color: isSelected ? Colors.amberAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            plan.title,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "₹${plan.offerAmount.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (plan.offerAmount < plan.actualAmount) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              "₹${plan.actualAmount.toStringAsFixed(2)}",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: getResponsiveFontSize(0.03),
                color: Colors.white,
              ),
            ),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "${plan.duration} ${plan.unit}",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          ...plan.description.split("\n").map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    feature,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            onPressed: () {
              Get.to(CreatorFormPage());
            },
            child: Text(
              "Buy Now",
              style: AppTextStyles.headingText.copyWith(
                fontSize: getResponsiveFontSize(0.035),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
        ],
      ),
    );
  }
}
