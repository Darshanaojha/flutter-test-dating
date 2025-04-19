
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