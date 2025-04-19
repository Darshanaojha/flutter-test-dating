


// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CreatorDashboardPage extends StatelessWidget {
  
//   // final CreatorDashboardController controller = Get.put(CreatorDashboardController());

//   // CreatorDashboardPage({required this.creator, super.key});

//   final List<Map<String, dynamic>> samplePosts = List.generate(
//     10,
//         (index) => {
//       'username': 'CreatorUser',
//       'imageUrl': 'https://source.unsplash.com/random/400x400?sig=$index',
//       'isVideo': index % 3 == 0,
//       'description': 'This is post number $index by the creator.',
//     },
//   );

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // controller.setCreator(creator);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Obx(() => Text(
//           controller.creator.value?.username ?? '',
//           style: const TextStyle(color: Colors.white),
//         )),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(() {
//         final data = controller.creator.value;
//         if (data == null) return const Center(child: CircularProgressIndicator());

//         return ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // Banner + Profile
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Image.network(
//                   data.bannerImageUrl,
//                   width: screenWidth,
//                   height: screenHeight * 0.25,
//                   fit: BoxFit.cover,
//                 ),
//                 Positioned(
//                   left: screenWidth * 0.04,
//                   bottom: -screenHeight * 0.04,
//                   child: CircleAvatar(
//                     radius: screenWidth * 0.10,
//                     backgroundImage: NetworkImage(data.profileImageUrl),
//                     backgroundColor: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.06),

//             // Display Name + Bio
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data.displayName,
//                     style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: screenHeight * 0.005),
//                   Text(
//                     data.bio,
//                     style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.035),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),

//             // Buttons
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         side: const BorderSide(color: Colors.white),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                       ),
//                       child: const Text("Follow", style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.03),
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         side: const BorderSide(color: Colors.white),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                       ),
//                       child: const Text("Message", style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   IconButton(
//                     icon: const Icon(Icons.more_vert, color: Colors.white),
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         backgroundColor: Colors.black,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                         ),
//                         builder: (_) => Padding(
//                           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.03),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 width: 40,
//                                 height: 4,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white24,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight * 0.03),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white10,
//                                     foregroundColor: Colors.white,
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                                   ),
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Subscribe to unlock creator", style: TextStyle(fontSize: 16)),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),

//             // Feed Posts
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: samplePosts.length,
//               itemBuilder: (context, index) {
//                 final post = samplePosts[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
//                   color: Colors.black,
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListTile(
//                         leading: CircleAvatar(
//                           radius: screenWidth * 0.045,
//                           backgroundImage: NetworkImage(data.profileImageUrl),
//                         ),
//                         title: Text(
//                           post['username'],
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                         ),
//                         trailing: post['isVideo']
//                             ? const Icon(Icons.videocam, color: Colors.white)
//                             : const Icon(Icons.image, color: Colors.white),
//                       ),
//                       Stack(
//                         children: [
//                           Container(
//                             height: screenHeight * 0.35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               image: post['isVideo']
//                                   ? null
//                                   : DecorationImage(
//                                 image: NetworkImage(post['imageUrl']),
//                                 fit: BoxFit.cover,
//                               ),
//                               color: Colors.grey[900],
//                             ),
//                             child: post['isVideo']
//                                 ? const Center(
//                               child: Icon(Icons.videocam, size: 64, color: Colors.white70),
//                             )
//                                 : null,
//                           ),
//                           Positioned.fill(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: BackdropFilter(
//                                 filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                                 child: Container(
//                                   color: Colors.black.withOpacity(0.3),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Positioned.fill(
//                             child: Center(
//                               child: Icon(Icons.lock, size: 36, color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.04),
//                         child: Text(
//                           post['description'],
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
