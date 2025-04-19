

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class ManageSubscriptionScreen extends StatelessWidget {
//   // final controller = Get.put(ManageSubscriptionController());

//   final Map<String, Color> typeColors = {
//     'basic': Color(0xff1f005c),
//     'premium': Color(0xff870160),
//     'vip': Color(0xfff39060),
//   };

//   Color getTypeColor(String type) {
//     return typeColors[type.toLowerCase()] ?? Colors.grey.shade800;
//   }

//   IconData getPlanIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'vip':
//         return FontAwesomeIcons.crown;
//       case 'premium':
//         return FontAwesomeIcons.gem;
//       default:
//         return FontAwesomeIcons.solidStar;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (controller.selectedIndex.value != -1) {
//           controller.selectedIndex.value = -1;
//           return false;
//         }
//         return true;
//       },
//       child: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: () {
//           controller.selectedIndex.value = -1;
//         },
//         child: Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             title: const Text("Manage Subscriptions", style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.black,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           body: Obx(() {
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: controller.subscriptions.length,
//               itemBuilder: (context, index) {
//                 final sub = controller.subscriptions[index];
//                 return GestureDetector(
//                   onLongPress: () => controller.selectedIndex.value = index,
//                   child: Stack(
//                     children: [
//                       Card(
//                         color: getTypeColor(sub.type),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                         elevation: 4,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Left content
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         FaIcon(
//                                           getPlanIcon(sub.type),
//                                           color: Colors.amberAccent,
//                                           size: 18,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           sub.name,
//                                           style: const TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       sub.description,
//                                       style: const TextStyle(color: Colors.white70, fontSize: 14),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Wrap(
//                                       spacing: 8,
//                                       runSpacing: 8,
//                                       children: sub.features.map((f) {
//                                         return Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(12),
//                                             border: Border.all(color: Colors.white30),
//                                             color: Colors.white10,
//                                           ),
//                                           child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 13)),
//                                         );
//                                       }).toList(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // Right content
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Text(
//                                         "\$${sub.price.toStringAsFixed(2)}",
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       const Text(
//                                         "/month",
//                                         style: TextStyle(color: Colors.white70, fontSize: 12),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Switch(
//                                     value: sub.isActive,
//                                     onChanged: (_) => controller.toggleActiveStatus(index),
//                                     activeColor: const Color(0xFFFF1694),
//                                     inactiveThumbColor: Colors.grey,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Overlay for long press actions
//                       Obx(() {
//                         return controller.selectedIndex.value == index
//                             ? Positioned.fill(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Center(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.edit, color: Colors.white, size: 28),
//                                     onPressed: () {
//                                       controller.editSubscription(index);
//                                       controller.selectedIndex.value = -1;
//                                     },
//                                   ),
//                                   const SizedBox(width: 24),
//                                   IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
//                                     onPressed: () {
//                                       controller.deleteSubscription(index);
//                                       controller.selectedIndex.value = -1;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                             : const SizedBox.shrink();
//                       }),
//                     ],
//                   ),
//                 );
//               },
//             );
//           }),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Get.to(()=> AddSubscriptionScreen());
//             },
//             backgroundColor: const Color(0xFFFF1694),
//             child: const Icon(Icons.add, color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }
