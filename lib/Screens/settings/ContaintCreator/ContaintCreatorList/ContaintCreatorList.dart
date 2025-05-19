import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../../Controllers/controller.dart';
import '../../../../constants.dart';
import '../CreatorHomesScreen.dart';
import 'CreatorDetailsProfile.dart';
import 'package:dating_application/Screens/settings/ContaintCreator/creatorPlansScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreatorListPage extends StatefulWidget {
  const CreatorListPage({super.key});
  @override
  CreatorListPageState createState() => CreatorListPageState();
}

class CreatorListPageState extends State<CreatorListPage> {
  Controller controller = Get.put(Controller());
  final bool isCreator = true;
  final bool isSubscribed = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width * 0.02;
    // final screenHeight = size.height*0.02;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            if (isSubscribed) {
              Get.to(() => const CreatorHomeScreen());
            }
          },
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.5),
            child: Stack(
              children: [
                if (isSubscribed)
                  CircleAvatar(
                    radius: screenWidth * 2.5,
                    backgroundImage: const NetworkImage(
                        "https://randomuser.me/api/portraits/men/3.jpg"),
                  ),
                if (!isSubscribed)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.apps,
                          size: screenWidth * 0.7, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: Text(
          "Creators".toUpperCase(),
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.05),
            color: Colors.white,
          ),
        ),
        actions: [
          if (!isCreator)
            Padding(
              padding: EdgeInsets.only(right: screenWidth),
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => PricingPage()),
                icon: Icon(Icons.star, size: screenWidth * 0.9),
                label: Text(
                  "Become a Creator",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 1.2,
                      vertical: screenWidth * 0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 1.5),
                  ),
                  elevation: 6,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: controller.creators.length,
            padding: EdgeInsets.only(bottom: screenWidth * 2),
            itemBuilder: (context, index) {
              final creator = controller.creators[index];
              final imageUrl = creator.profileImage.isNotEmpty == true
                  ? creator.profileImage
                  : null;

              return GestureDetector(
                onTap: () async{
                 // await controller.getCreatorDetails(creator.creatorId);
                  Get.to(() => CreatorsProfilePage(
                        name: creator.name,
                        profileUrl: creator.profileImage,
                        photos: 10,//creator.imageCount,
                        videos: 10,//creator.videoCount,
                        followers: 10,//creator.followers,
                        following: 10,//creator.following,
                      ));
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.8,
                    vertical: screenWidth * 0.6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A0CA3), Color(0xFF7209B7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: screenWidth * 0.8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.8),
                          bottomLeft: Radius.circular(screenWidth * 0.8),
                        ),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: size.width * 0.3,
                                height: size.width * 0.3,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade800,
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  child: const Icon(Icons.person,
                                      color: Colors.white70, size: 40),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade800,
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white54, size: 40),
                                ),
                              )
                            : Container(
                                width: size.width * 0.3,
                                height: size.width * 0.3,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.person,
                                    color: Colors.white70, size: 40),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  creator.name ?? 'Unknown',
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: getResponsiveFontSize(0.034),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.3),
                              Text(
                                "Country: ${creator.country.name ?? 'N/A'}",
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03),
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.8),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    infoItem(
                                        context,
                                        Icons.photo,
                                        formatNumber(creator.imageCount),
                                        screenWidth),
                                    infoItem(
                                        context,
                                        Icons.videocam,
                                        formatNumber(creator.videoCount),
                                        screenWidth),
                                    infoItem(
                                        context,
                                        Icons.people,
                                        formatNumber(creator.followers),
                                        screenWidth),
                                    infoItem(
                                        context,
                                        Icons.person_add,
                                        formatNumber(creator.following),
                                        screenWidth),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget infoItem(
      BuildContext context, IconData icon, String label, double screenWidth) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Column(
      children: [
        Icon(icon, color: Colors.white, size: screenWidth * 2),
        SizedBox(height: screenWidth * 0.2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: getResponsiveFontSize(0.04),
          ),
        ),
      ],
    );
  }

  String formatNumber(dynamic numVal) {
    try {
      if (numVal == null) return "0";
      int number =
          numVal is int ? numVal : int.tryParse(numVal.toString()) ?? 0;

      if (number >= 1_000_000_000) {
        return "${(number / 1_000_000_000).toStringAsFixed(1)}B";
      } else if (number >= 1_000_000) {
        return "${(number / 1_000_000).toStringAsFixed(1)}M";
      } else if (number >= 1_000) {
        return "${(number / 1_000).toStringAsFixed(1)}K";
      } else {
        return number.toString();
      }
    } catch (e) {
      return "0";
    }
  }
}
