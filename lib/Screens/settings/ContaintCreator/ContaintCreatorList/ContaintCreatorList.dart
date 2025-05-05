import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../../../../constants.dart';
import '../CreatorHomesScreen.dart';
import 'CreatorDetailsProfile.dart';
import 'package:dating_application/Screens/settings/ContaintCreator/creatorPlansScreen.dart';

class Creator {
  final String name;
  final int age;
  final String profileUrl;
  final int photos;
  final int videos;
  final int followers;
  final int following;

  Creator({
    required this.name,
    required this.age,
    required this.profileUrl,
    required this.photos,
    required this.videos,
    required this.followers,
    required this.following,
  });
}

class CreatorListPage extends StatelessWidget {
  CreatorListPage({super.key});

  final bool isCreator = true;
  final bool isSubscribed = true;

  final List<Creator> creators = [
    Creator(
      name: "Father Smith",
      age: 28,
      profileUrl: "https://randomuser.me/api/portraits/women/10.jpg",
      photos: 25,
      videos: 12,
      followers: 340,
      following: 120,
    ),
    Creator(
      name: "Johny Pirates",
      age: 34,
      profileUrl: "https://randomuser.me/api/portraits/men/11.jpg",
      photos: 42,
      videos: 8,
      followers: 220,
      following: 85,
    ),
    Creator(
      name: "Lunaiysna Joseff",
      age: 25,
      profileUrl: "https://randomuser.me/api/portraits/women/15.jpg",
      photos: 19,
      videos: 5,
      followers: 410,
      following: 150,
    ),
  ];
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
          "Creators",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
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
          Container(
            height: size.height * 0.25,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.unsplash.com/photo-1557682250-33bd709cbe85"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.2),
            child: ListView.builder(
              itemCount: creators.length,
              padding: EdgeInsets.only(bottom: screenWidth * 2),
              itemBuilder: (context, index) {
                final creator = creators[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => CreatorsProfilePage(
                          name: creator.name,
                          profileUrl: creator.profileUrl,
                          photos: creator.photos,
                          videos: creator.videos,
                          followers: creator.followers,
                          following: creator.following,
                        ));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.8,
                        vertical: screenWidth * 0.6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF870160), Color(0xFFAC255E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
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
                          child: Image.network(
                            creator.profileUrl,
                            width: size.width * 0.3,
                            height: size.width * 0.3,
                            fit: BoxFit.cover,
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
                                    creator.name,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.3),
                                Text(
                                  "Age: ${creator.age}",
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: getResponsiveFontSize(0.03),
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 1.2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoItem(context, Icons.photo,
                                        creator.photos, screenWidth),
                                    _infoItem(context, Icons.videocam,
                                        creator.videos, screenWidth),
                                    _infoItem(context, Icons.people,
                                        creator.followers, screenWidth),
                                    _infoItem(context, Icons.person_add,
                                        creator.following, screenWidth),
                                  ],
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
          ),
        ],
      ),
    );
  }

  Widget _infoItem(context, IconData icon, int count, double screenWidth) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: screenWidth * 1.2),
        SizedBox(width: screenWidth * 0.4),
        Text(
          "$count",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
