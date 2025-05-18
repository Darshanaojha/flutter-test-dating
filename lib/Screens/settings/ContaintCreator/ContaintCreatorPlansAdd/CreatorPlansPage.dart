import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';
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

   CreatorPlansPage({super.key});

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
     double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  Text("Your Plans", style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  )),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF1694),
        icon: const Icon(Icons.add),
        label:  Text("Add Plan", style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  )),
        onPressed: () {
          Get.to(AddSubscriptionFormPage());
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topBanner(context),
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

  Widget _topBanner(context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }
  //  final screenWidth = MediaQuery.of(context).size.width * 0.02;
    final screenHeight = MediaQuery.of(context).size.height * 0.02;
    return Stack(
      children: [
        Container(
          height: 200,
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
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.8),
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
            children: [
              Text("Monetize Your Content 🎯",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  )),
            SizedBox(height: screenHeight* 0.01),
              Text("Manage your subscription plans below",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard(
      Map<String, dynamic> plan, bool isTablet, BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }
      //  final screenWidth = MediaQuery.of(context).size.width * 0.02;
    final screenHeight = MediaQuery.of(context).size.height * 0.02;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isTablet ? 280 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getTypeColor(plan['type']),
            getTypeColor(plan['type']).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                child: Text(plan['name'],
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
                      color: Colors.white,
                    )),
              ),
              PopupMenuButton<String>(
                color: Colors.grey[900],
                onSelected: (value) {
                  if (value == 'edit') {
                    final model = SubscriptionModel(
                      name: plan['name'],
                      description: plan['description'],
                      price: plan['price'],
                      features: List<String>.from(plan['features']),
                    );
                    Get.to(() => SubscriptionEditScreen(subscription: model));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text("Edit", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight* 0.01),
          Text(plan['description'],
              style: AppTextStyles.bodyText.copyWith(
                fontSize: getResponsiveFontSize(0.03),
                color: Colors.white,
              )),
        SizedBox(height: screenHeight* 0.01),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.from(plan['features'].map((f) => Chip(
                  label: Text(f,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: getResponsiveFontSize(0.03),
                        color: Colors.white,
                      )),
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.white30),
                ))),
          ),
          SizedBox(height: screenHeight* 0.01),
          Text("\$${plan['price'].toStringAsFixed(2)} / mo",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: getResponsiveFontSize(0.03),
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
