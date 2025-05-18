import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import 'CreatorFormPage.dart';
import '../../../Controllers/controller.dart';
import '../../../Models/ResponseModels/get_all_creators_packages_model.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  PricingPageState createState() => PricingPageState();
}

class PricingPageState extends State<PricingPage> {
  String selectedType = 'CUT'; // Default filter
  int? selectedIndex;

  final Controller controller = Get.put(Controller());

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

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  String getTypeDescription(String type) {
    switch (type) {
      case 'CUT':
        return "CUT plans offer exclusive, time-limited deals for creators.";
      case 'NORMAL':
        return "NORMAL plans provide standard access to premium features.";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    controller.fetchAllPackagesForCreator();
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
            // Type filter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('CUT'),
                  selected: selectedType == 'CUT',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = 'CUT';
                      selectedIndex = null;
                    });
                  },
                  selectedColor: Colors.amber,
                  labelStyle: TextStyle(
                    color: selectedType == 'CUT' ? Colors.black : Colors.white,
                  ),
                  backgroundColor: Colors.grey[800],
                ),
                SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('NORMAL'),
                  selected: selectedType == 'NORMAL',
                  onSelected: (selected) {
                    setState(() {
                      selectedType = 'NORMAL';
                      selectedIndex = null;
                    });
                  },
                  selectedColor: Colors.amber,
                  labelStyle: TextStyle(
                    color:
                        selectedType == 'NORMAL' ? Colors.black : Colors.white,
                  ),
                  backgroundColor: Colors.grey[800],
                ),
              ],
            ),
            SizedBox(height: 8),
            // Short description for selected type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                getTypeDescription(selectedType),
                style: AppTextStyles.bodyText.copyWith(
                  color: Colors.white70,
                  fontSize: getResponsiveFontSize(0.028),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            // Cards
            Expanded(
              child: Center(
                child: Obx(() {
                  if (controller.packageforcreator.isEmpty) {
                    return const CircularProgressIndicator();
                  }
                  final filteredPlans = controller.packageforcreator
                      .where((plan) => plan.type.toUpperCase() == selectedType)
                      .toList();
                  if (filteredPlans.isEmpty) {
                    return Text(
                      "No plans available for this type.",
                      style:
                          AppTextStyles.bodyText.copyWith(color: Colors.white),
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: filteredPlans.asMap().entries.map((entry) {
                        int index = entry.key;
                        PackageForCreator plan = entry.value;
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: selectedIndex == index ? 1.05 : 1.0,
                                child: CreatorPricingCard(
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
                  );
                }),
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

class CreatorPricingCard extends StatelessWidget {
  final PackageForCreator plan;
  final Gradient gradient;
  final bool isSelected;

  const CreatorPricingCard({
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
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "₹${plan.offerAmount.toStringAsFixed(2)}",
            style: const TextStyle(
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
                decoration: TextDecoration.lineThrough,
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
