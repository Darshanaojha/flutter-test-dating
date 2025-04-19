




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';

// class CreatorsHomeScreen extends StatelessWidget {
//   final String username;
//   final String name;
//   final String bio;
//   final String paymentMode;
//   final File? profileImage;
//   final File? bannerImage;

//   const CreatorsHomeScreen({
//     super.key,
//     required this.username,
//     required this.name,
//     required this.bio,
//     required this.paymentMode,
//     this.profileImage,
//     this.bannerImage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isTablet = screenWidth > 600;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.white, size: isTablet ? 28 : 22),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: Text(
//           'Creator Home',
//           style: TextStyle(color: Colors.white, fontSize: isTablet ? 22 : 18),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications, color: Colors.white, size: isTablet ? 26 : 20),
//             onPressed: () {
//               // Handle notification click
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         backgroundColor: Colors.black,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.black),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: isTablet ? 50 : 35,
//                     backgroundImage: profileImage != null
//                         ? FileImage(profileImage!)
//                         : const AssetImage('assets/default_profile.png') as ImageProvider,
//                   ),
//                   SizedBox(width: isTablet ? 20 : 12),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: isTablet ? 18 : 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           username,
//                           style: TextStyle(color: Colors.white70, fontSize: isTablet ? 14 : 12),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 6),
//                         Text(
//                           bio,
//                           style: TextStyle(color: Colors.white54, fontSize: isTablet ? 13 : 11),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Sleek Cards
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Row(
//                 children: [
//                   _drawerCard(
//                     icon: Icons.folder_copy,
//                     label: 'My Content',
//                     onTap: () {
//                       Get.to(PostLibraryScreen());
//                     },
//                     isTablet: isTablet,
//                     width: screenWidth,
//                   ),
//                   SizedBox(width: screenWidth * 0.03),
//                   _drawerCard(
//                     icon: Icons.local_offer,
//                     label: 'My Packages',
//                     onTap: () {
//                       Get.to(ManageSubscriptionScreen());
//                     },
//                     isTablet: isTablet,
//                     width: screenWidth,
//                   ),
//                 ],
//               ),
//             ),

//             _buildSectionTitle('Account', isTablet),
//             _buildDrawerItem(FontAwesomeIcons.edit, 'Edit Profile', () {
//               Get.to(() => const CleanBlackFormPage());
//             }, isTablet),

//             _buildSectionTitle('Support & About', isTablet),
//             _buildDrawerItem(FontAwesomeIcons.shoppingBag, 'My Purchase', () {
//               Get.to(() => CreatorSubsPurchasedPage());
//             }, isTablet),
//             _buildDrawerItem(FontAwesomeIcons.creditCard, 'Payment Details', () {
//               // Handle Payment Details
//             }, isTablet),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.black,
//       body:CreatorsListPage(),
//     );
//   }

//   Widget _buildSectionTitle(String title, bool isTablet) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Colors.white70,
//           fontSize: isTablet ? 16 : 14,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isTablet) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white70, size: isTablet ? 22 : 18),
//       title: Text(title, style: TextStyle(color: Colors.white, fontSize: isTablet ? 16 : 14)),
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//     );
//   }

//   Widget _drawerCard({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required bool isTablet,
//     required double width,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           height: isTablet ? 80 : 70,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             border: Border.all(color: Colors.white, width: 0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white70, size: isTablet ? 30 : 24),
//               SizedBox(height: 6),
//               Text(
//                 label,
//                 style: TextStyle(color: Colors.white, fontSize: isTablet ? 14 : 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// class CreatorsListPage extends StatelessWidget {
//   final controller = Get.put(CreatorsController());

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Responsive sizes
//     double padding = screenWidth * 0.04;
//     double imageHeight = screenWidth * 0.35;
//     double avatarRadius = screenWidth * 0.08;
//     double nameFontSize = screenWidth * 0.045;
//     double bioFontSize = screenWidth * 0.035;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Obx(() {
//         return ListView.builder(
//           itemCount: controller.creators.length,
//           padding: EdgeInsets.all(padding),
//           itemBuilder: (context, index) {
//             final creator = controller.creators[index];
//             return GestureDetector(
//               onTap: () {
//                 Get.to(() => CreatorDashboardPage(creator: creator));
//               },
//               child: Container(
//                 margin: EdgeInsets.only(bottom: padding),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[900],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Banner image
//                     ClipRRect(
//                       borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(12)),
//                       child: Image.network(
//                         creator.bannerImageUrl,
//                         height: imageHeight,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(padding),
//                       child: Row(
//                         children: [
//                           // Profile image
//                           CircleAvatar(
//                             radius: avatarRadius,
//                             backgroundImage: NetworkImage(creator.profileImageUrl),
//                           ),
//                           SizedBox(width: padding),
//                           // Name and Bio
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   creator.displayName,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: nameFontSize,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   creator.bio,
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: bioFontSize,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
