
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// import '../../../Controllers/controller.dart';

// class MoodSelectionScreen extends StatefulWidget {
//   const MoodSelectionScreen({super.key});

//   @override
//   MoodSelectionScreenState createState() => MoodSelectionScreenState();
// }

// class MoodSelectionScreenState extends State<MoodSelectionScreen> {

//   final Random random = Random();
//   final List<String> emojiImages =
//   List.generate(7, (index) => 'assets/images/emoji/${index + 1}.png');
//   Controller controller = Get.put(Controller());
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
//             ),
//           );
//         }

//         if (controller.moods.isEmpty) {
//           return Center(
//             child: Text(
//               "No moods available. Please try again later.",
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//           );
//         }

//         return Stack(
//           children: [
//             /// Faint emoji background
//             ...List.generate(6, (index) {
//               bool isTopHalf = index.isEven;
//               double verticalOffset = isTopHalf
//                   ? random.nextDouble() * (screenHeight * 0.4)
//                   : screenHeight * 0.6 +
//                   random.nextDouble() * (screenHeight * 0.3);
//               double horizontalOffset =
//                   random.nextDouble() * (screenWidth * 0.8);

//               return Positioned(
//                 top: verticalOffset,
//                 left: horizontalOffset,
//                 child: Opacity(
//                   opacity: 0.25,
//                   child: Image.asset(
//                     emojiImages[random.nextInt(emojiImages.length)],
//                     width: 160,
//                     height: 160,
//                   ),
//                 ),
//               );
//             }),

//             /// Main Content
//             Positioned.fill(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 150),

//                       /// Greeting
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Hey,",
//                           style: TextStyle(
//                             fontSize: 38,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontFamily: "Roboto",
//                           ),
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "How are you feeling?",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                             fontFamily: "Roboto",
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 40),

//                       /// Carousel
//                       CarouselSlider.builder(
//                         itemCount: controller.moods.length,
//                         options: CarouselOptions(
//                           height: 140,
//                           enlargeCenterPage: true,
//                           autoPlay: false,
//                           enableInfiniteScroll: true,
//                           viewportFraction: 0.55,
//                         ),
//                         itemBuilder: (context, index, _) {
//                           bool isSelected = controller.selectedMoodId.value ==
//                               controller.moods[index]["id"];
//                           return GestureDetector(
//                             onTap: () {
//                               controller.selectedMoodId.value =
//                               controller.moods[index]["id"];
//                             },
//                             child: AnimatedContainer(
//                               duration: Duration(milliseconds: 300),
//                               margin: EdgeInsets.symmetric(horizontal: 6),
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 16, horizontal: 25),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Color(0xff870160)
//                                     : Colors.white10,
//                                 borderRadius: BorderRadius.circular(30),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? Color(0xff870160)
//                                       : Colors.white38,
//                                   width: isSelected ? 2.5 : 1,
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   controller.moods[index]["name"],
//                                   style: TextStyle(
//                                     fontSize: isSelected ? 20 : 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: isSelected
//                                         ? Colors.white
//                                         : Colors.white70,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),

//                       SizedBox(height: 50),

//                       /// Confirm Button
//                       _buildGradientButton(
//                         "Confirm Mood",
//                         controller.selectedMoodId.value == ""
//                             ? null
//                             : () async {
//                           await controller.setMood();
//                           Get.snackbar(
//                             "Mood Updated",
//                             "Your mood has been updated successfully",
//                             snackPosition: SnackPosition.TOP,
//                             backgroundColor: Colors.black,
//                             colorText: Colors.white,
//                             margin: EdgeInsets.all(12),
//                             borderRadius: 8,
//                             duration: Duration(seconds: 2),
//                           );
//                         },
//                       ),

//                       SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   /// Gradient Button
//   Widget _buildGradientButton(String text, VoidCallback? onPressed) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Opacity(
//         opacity: onPressed == null ? 0.4 : 1,
//         child: Container(
//           height: 55,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xff1f005c).withOpacity(0.4),
//                 Color(0xff5b0060).withOpacity(0.4),
//                 Color(0xff870160).withOpacity(0.4),
//                 Color(0xffac255e).withOpacity(0.4),
//                 Color(0xffca485c).withOpacity(0.4),
//                 Color(0xffe16b5c).withOpacity(0.4),
//                 Color(0xfff39060).withOpacity(0.4),
//               ],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//             borderRadius: BorderRadius.circular(50),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }