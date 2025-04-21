import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'ContaintCreatorPlansAdd/CreatorPlansPage.dart';
import 'CreatorProfile/CreatorProfileScreen.dart';
import 'CreatorsDashboard.dart';
import 'NewPostUpload/CreatorNewPost.dart';

class CreatorHomeScreen extends StatelessWidget {
  const CreatorHomeScreen({super.key});

  final String name = "Alex Creator";
  final String username = "alex.creates";
  final String bio = "Photographer | Storyteller | Digital Artist";
  final String paymentMode = "Bank Transfer";

  final String profileImagePath = 'assets/images/techlead.jpg';
  final String bannerImagePath = 'assets/images/techlead.jpg';
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("👋 Welcome Back",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),

      // 🔥 Drawer Added
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Profile Header in Drawer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(profileImagePath),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('@$username',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
              const Divider(color: Colors.white24),

              // 🔘 Drawer Buttons
              ListTile(
                leading:
                    const Icon(Icons.subscriptions, color: Colors.pinkAccent),
                title: const Text("Subscriptions",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.orange),
                title: const Text("Transactions",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.shopping_bag, color: Colors.greenAccent),
                title:
                    const Text("Orders", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Info
          Row(
            children: [
              GestureDetector(
                onTap: (){
                  Get.to(CreatorProfileScreen(name: name, profileUrl:profileImagePath , photos:10, videos: 17, followers: 199, following: 100,));
                },
                child: CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage(profileImagePath),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('@$username',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: Colors.pinkAccent, size: 22),
            ],
          ),

          const SizedBox(height: 30),

          // Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              bannerImagePath,
              height: 160,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 30),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => CreateNewPostPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.penToSquare,
                  label: "Create",
                  color: Colors.deepPurpleAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorPlansPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.cubes,
                  label: "Packages",
                  color: Colors.orangeAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorDashboardPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.chartPie,
                  label: "Analytics",
                  color: Colors.tealAccent.shade400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
              
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.artstation,
                  label: "Cretors",
                  color: Colors.deepPurpleAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorPlansPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.airbnb,
                  label: "All",
                  color: Colors.orangeAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorDashboardPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.democrat,
                  label: "Demo",
                  color: Colors.tealAccent.shade400,
                ),
              ),
            ],
          ),
                  const SizedBox(height: 30),

          // Earnings Info
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Monetization",
                    style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 6),
                Text(paymentMode,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Colors.greenAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text("Estimated Earnings: ",
                        style: TextStyle(color: Colors.white70)),
                    Text("\$1,200",
                        style: TextStyle(
                            color: Colors.greenAccent.shade100,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF1694),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon, required String label, required Color color}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
