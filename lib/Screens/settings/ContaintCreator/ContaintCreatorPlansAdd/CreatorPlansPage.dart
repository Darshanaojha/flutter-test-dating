import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'CreatorPlansAddPage.dart';
import 'CreatorPlansEdit.dart';

class SubscriptionModel {
  final String name;
  final String description;
  final double price;
  final List<String> features;

  const SubscriptionModel({
    required this.name,
    required this.description,
    required this.price,
    required this.features,
  });
}

class CreatorPlansPage extends StatelessWidget {
  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Basic',
      'description': 'Great for casual fans who want to support.',
      'features': ['Early Access', 'Support Badge'],
      'price': 5.0,
      'type': 'basic',
    },
    {
      'name': 'Premium',
      'description': 'Exclusive content and behind-the-scenes access.',
      'features': ['All from Basic', 'Exclusive Posts', 'Q&A Sessions'],
      'price': 15.0,
      'type': 'premium',
    },
    {
      'name': 'VIP',
      'description': 'Ultimate supporter tier with personal perks!',
      'features': ['All from Premium', '1-on-1 Chats', 'VIP Shoutouts'],
      'price': 30.0,
      'type': 'vip',
    },
  ];

  final Map<String, Color> typeColors = {
    'basic': const Color(0xff1f005c),
    'premium': const Color(0xff870160),
    'vip': const Color(0xfff39060),
  };

  Color getTypeColor(String type) =>
      typeColors[type.toLowerCase()] ?? Colors.grey.shade800;

  IconData getPlanIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vip':
        return FontAwesomeIcons.crown;
      case 'premium':
        return FontAwesomeIcons.gem;
      default:
        return FontAwesomeIcons.solidStar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Your Plans", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF1694),
        icon: const Icon(Icons.add),
        label: const Text("Add Plan"),
        onPressed: () {
          Get.to(AddSubscriptionFormPage());
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topBanner(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: plans
                    .map((plan) => _planCard(plan, isTablet, context))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBanner() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://source.unsplash.com/featured/?creator,abstract"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.3)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Monetize Your Content 🎯",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Manage your subscription plans below",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard(
      Map<String, dynamic> plan, bool isTablet, BuildContext context) {
    return Container(
      width: isTablet ? 280 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: getTypeColor(plan['type']),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.white10, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(getPlanIcon(plan['type']), color: Colors.amberAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    final model = SubscriptionModel(
                      name: plan['name'],
                      description: plan['description'],
                      price: plan['price'],
                      features: List<String>.from(plan['features']),
                    );

                    Get.to(() =>
                        SubscriptionEditScreen(subscription: model));
                  });
                },
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.remove_red_eye, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text("Preview", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(plan['description'],
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.from(plan['features'].map((f) => Chip(
                  label: Text(f, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.white30),
                ))),
          ),
          const SizedBox(height: 16),
          Text(
            "\$${plan['price'].toStringAsFixed(2)} / mo",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
