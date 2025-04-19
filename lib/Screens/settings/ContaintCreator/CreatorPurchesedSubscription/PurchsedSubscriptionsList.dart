




// import 'package:chatappgx/controller/CreatorSubscriptionPurchaseController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class CreatorSubsPurchasedPage extends StatefulWidget {
//   @override
//   _CreatorSubsPurchasedPageState createState() => _CreatorSubsPurchasedPageState();
// }

// class _CreatorSubsPurchasedPageState extends State<CreatorSubsPurchasedPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final SubscriptionController controller = Get.put(SubscriptionController());

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     controller.loadStaticCreatorSubscriptions(); // Load mock data
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Subscription History',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'All'),
//             Tab(text: 'Active'),
//             Tab(text: 'Expired'),
//           ],
//           indicatorColor: Colors.white,
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator(color: Colors.white));
//         }

//         final allSubs = controller.creatorSubscriptions;
//         final activeSubs = allSubs
//             .where((s) => s.planEndDate.isAfter(DateTime.now()))
//             .toList();
//         final expiredSubs = allSubs
//             .where((s) => s.planEndDate.isBefore(DateTime.now()))
//             .toList();

//         return TabBarView(
//           controller: _tabController,
//           children: [
//             _buildList(allSubs, screenWidth, screenHeight),
//             _buildList(activeSubs, screenWidth, screenHeight),
//             _buildList(expiredSubs, screenWidth, screenHeight),
//           ],
//         );
//       }),
//     );
//   }

//   Widget _buildList(List<SubscriptionModel> subscriptions, double width, double height) {
//     if (subscriptions.isEmpty) {
//       return const Center(
//         child: Text("No plans found",
//             style: TextStyle(color: Colors.white, fontSize: 16)),
//       );
//     }

//     return ListView.builder(
//       padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
//       itemCount: subscriptions.length,
//       itemBuilder: (context, index) {
//         final plan = subscriptions[index];
//         final isActive = plan.planEndDate.isAfter(DateTime.now());
//         final statusColor = isActive ? Colors.green : Colors.red;
//         final statusText = isActive ? "Active" : "Expired";

//         return Container(
//           margin: EdgeInsets.symmetric(vertical: height * 0.01),
//           padding: EdgeInsets.all(width * 0.04),
//           decoration: BoxDecoration(
//             color: Colors.grey[900],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: statusColor, width: 1.5),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Left side
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildRibbon(statusText, statusColor, width),
//                   SizedBox(height: height * 0.01),
//                   _buildInfoItem(Icons.currency_rupee, "${plan.planAmount}", width),
//                   SizedBox(height: height * 0.005),
//                   _buildInfoItem(Icons.access_time, plan.planDuration, width),
//                 ],
//               ),

//               SizedBox(width: width * 0.04),

//               /// Right side
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       plan.planName,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: width * 0.045,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.right,
//                     ),
//                     SizedBox(height: height * 0.01),
//                     _buildDateItem(plan.planStartDate, width),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRibbon(String text, Color color, double width) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 4, horizontal: width * 0.03),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//             color: Colors.white,
//             fontSize: width * 0.03,
//             fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildInfoItem(IconData icon, String value, double width) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.white70, size: width * 0.04),
//         SizedBox(width: width * 0.015),
//         Text(value, style: TextStyle(color: Colors.white, fontSize: width * 0.035)),
//       ],
//     );
//   }

//   Widget _buildDateItem(DateTime date, double width) {
//     return Column(
//       children: [
//         Text(
//           DateFormat('dd').format(date),
//           style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.05,
//               fontWeight: FontWeight.bold),
//         ),
//         Text(
//           DateFormat('MMM yyyy').format(date),
//           style: TextStyle(color: Colors.white70, fontSize: width * 0.035),
//         ),
//       ],
//     );
//   }
// }
