// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PricingPage extends StatelessWidget {
//   final Gradient commonGradient = LinearGradient(
//     colors: [
//       Color(0xff1f005c),
//       Color(0xff5b0060),
//       Color(0xff870160),
//       Color(0xffac255e),
//       Color(0xffca485c),
//       Color(0xffe16b5c),
//       Color(0xfff39060),
//       Color(0xfffffb56b),
//     ],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   // final PricingController controller = Get.put(PricingController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Color(0xFF1B1E38),

//       backgroundColor: Colors.black,
//       body: Center(
//         child: Obx(() => SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//           child: Row(
//             children: controller.pricingPlans.map((plan) {
//               return Row(
//                 children: [
//                   PricingCard(plan: plan, gradient: commonGradient),
//                   SizedBox(width: 20),
//                 ],
//               );
//             }).toList(),
//           ),
//         )),
//       ),
//     );
//   }
// }

// class PricingCard extends StatelessWidget {
//   final PricingModel plan;
//   final Gradient gradient;

//   const PricingCard({Key? key, required this.plan, required this.gradient}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool isHighlighted = plan.type == 'cut';

//     return Container(
//       width: 300,
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: gradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: isHighlighted ? [BoxShadow(color: Colors.black26, blurRadius: 12)] : [],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(plan.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70)),
//           SizedBox(height: 12),
//           Text("\$${plan.offerAmount}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
//           SizedBox(height: 6),
//           if (plan.offerAmount < plan.actualAmount)
//             Text("\$${plan.actualAmount}", style: TextStyle(fontSize: 16, color: Colors.white54, decoration: TextDecoration.lineThrough)),
//           SizedBox(height: 12),
//           Text("${plan.duration} ${plan.unit}", style: TextStyle(fontSize: 14, color: Colors.white70)),
//           SizedBox(height: 20),
//           ...plan.description.split("\n").map((feature) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Text(feature, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
//           )),
//           SizedBox(height: 24),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
// ,

//               backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),

//               foregroundColor: Colors.white,
//               shape: StadiumBorder(),
//               padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//             ),
//             onPressed: () {
//               Get.to(() => CleanBlackFormPage());
//             },
//             child: Text("Buy Now"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  @override
  _PricingPageState createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Monthly", style: TextStyle(color: Colors.white70)),
                Switch(
                  value: isYearly,
                  onChanged: (value) {
                    setState(() {
                      isYearly = value;
                    });
                  },
                  activeColor: Colors.amber,
                ),
                Text("Yearly", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),

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
                          SizedBox(width: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
    Key? key,
    required this.plan,
    required this.gradient,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isHighlighted = plan.type == 'cut';

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
          const SizedBox(height: 12),
          Text(
            "\$${plan.offerAmount.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (plan.offerAmount < plan.actualAmount) ...[
            const SizedBox(height: 6),
            Text(
              "\$${plan.actualAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            "${plan.duration} ${plan.unit}",
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ...plan.description.split("\n").map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    feature,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          const SizedBox(height: 24),
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
            child: const Text("Buy Now"),
          ),
        ],
      ),
    );
  }
}
