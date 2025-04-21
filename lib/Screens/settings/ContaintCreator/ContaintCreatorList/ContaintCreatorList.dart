import 'package:dating_application/Screens/settings/ContaintCreator/creatorPlansScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../CreatorHomesScreen.dart';
import 'CreatorDetailsProfile.dart'; // Import the page we want to show

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
  final bool isSubscribed = true; // Flag to check if the user is subscribed

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            // Navigate to the Creator Home Screen when the icon is tapped
            if (isSubscribed) {
              Get.to(() => const CreatorHomeScreen());
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                if (isSubscribed) // Show the icon only if the user is subscribed
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/3.jpg",
                    ),
                  ),
                if (!isSubscribed) // Show the "Become a Creator" button if not subscribed
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.apps, size: 14, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: const Text(
          "Creators",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isCreator)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => PricingPage());
                },
                icon: const Icon(Icons.star, size: 18),
                label: const Text("Become a Creator"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1557682250-33bd709cbe85",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: ListView.builder(
              itemCount: creators.length,
              padding: const EdgeInsets.only(bottom: 20),
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
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.network(
                            creator.profileUrl,
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  creator.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Age: ${creator.age}",
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 13),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 18,
                                  runSpacing: 6,
                                  children: [
                                    _infoItem(Icons.photo, creator.photos),
                                    _infoItem(Icons.videocam, creator.videos),
                                    _infoItem(Icons.people, creator.followers),
                                    _infoItem(Icons.person_add, creator.following),
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

  Widget _infoItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 4),
        Text(
          "$count",
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
