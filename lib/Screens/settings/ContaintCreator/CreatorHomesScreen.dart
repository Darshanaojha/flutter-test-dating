import 'package:dating_application/Screens/settings/ContaintCreator/CreatorPurchasedSubscription/PurchasedSubscriptionsList.dart';
import 'package:dating_application/Screens/settings/ContaintCreator/CreatorsAllContentPage.dart';
import 'package:dating_application/Screens/settings/ContaintCreator/CreatorsOrders/CreatorsTransactionPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../Controllers/controller.dart';
import '../../../constants.dart';
import 'ContaintCreatorPlansAdd/CreatorPlansPage.dart';
import 'CreatorProfile/CreatorProfileScreen.dart';
import 'CreatorsDashboard.dart';
import 'CreatorsOrders/CreatorsOrdersPage.dart';
import 'NewPostUpload/CreatorNewPost.dart';

class CreatorHomeScreen extends StatelessWidget {
  CreatorHomeScreen({super.key});

  final Controller controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    // Fetch profile when the widget is built (if not already fetched)
    controller.fetchProfile();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "👋 Welcome Back",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/techlead.jpg'),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alex Creator",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          '@alex.creates',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading:
                    const Icon(Icons.subscriptions, color: Colors.pinkAccent),
                title: Text(
                  "Subscriptions",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Get.to(CreatorSubsPurchasedPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.orange),
                title: Text(
                  "Transactions",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Get.to(CreatorsTransactionPage());
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.shopping_bag, color: Colors.greenAccent),
                title:
                    const Text("Orders", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.to(CreatorsOrdersPage());
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.shopping_bag, color: Colors.blueAccent),
                title: const Text("My Contents",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.to(CreatorsAllContentPage());
                },
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Dynamic Profile Info
          Obx(() {
            if (controller.userData.isEmpty) {
              return Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 16,
                          color: Colors.grey[800],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          width: 60,
                          height: 12,
                          color: Colors.grey[800],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified,
                      color: Colors.pinkAccent, size: 22),
                ],
              );
            }
            final user = controller.userData.first;
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(CreatorProfileScreen());
                  },
                  child: CircleAvatar(
                    radius: 34,
                    backgroundImage: user.profileImage.isNotEmpty
                        ? NetworkImage(user.profileImage)
                        : const AssetImage('assets/images/techlead.jpg')
                            as ImageProvider,
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: getResponsiveFontSize(0.03),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '@${user.username}',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: getResponsiveFontSize(0.03),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.accountVerificationStatus == "1" ||
                    user.accountVerificationStatus.toLowerCase() == "verified")
                  const Icon(Icons.verified,
                      color: Colors.pinkAccent, size: 22),
              ],
            );
          }),

          SizedBox(height: screenHeight * 0.01),

          // Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/techlead.jpg',
              height: 160,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

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

          SizedBox(height: screenHeight * 0.01),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     GestureDetector(
          //       onTap: () {},
          //       child: _actionCard(
          //         context,
          //         icon: FontAwesomeIcons.artstation,
          //         label: "Cretors",
          //         color: Colors.deepPurpleAccent,
          //       ),
          //     ),
          //     GestureDetector(
          //       onTap: () {
          //         Get.to(CreatorPlansPage());
          //       },
          //       child: _actionCard(
          //         context,
          //         icon: FontAwesomeIcons.airbnb,
          //         label: "All",
          //         color: Colors.orangeAccent,
          //       ),
          //     ),
          //     GestureDetector(
          //       onTap: () {
          //         Get.to(CreatorDashboardPage());
          //       },
          //       child: _actionCard(
          //         context,
          //         icon: FontAwesomeIcons.democrat,
          //         label: "Demo",
          //         color: Colors.tealAccent.shade400,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(CreatorSubsPurchasedPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.artstation,
                  label: "Subcriptions",
                  color: Colors.deepPurpleAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorsTransactionPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.airbnb,
                  label: "Transactions",
                  color: Colors.orangeAccent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(CreatorsOrdersPage());
                },
                child: _actionCard(
                  context,
                  icon: FontAwesomeIcons.list,
                  label: "Orders",
                  color: Colors.tealAccent.shade400,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),

          // Earnings Info
          // Container(
          //   padding: const EdgeInsets.all(18),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[850],
          //     borderRadius: BorderRadius.circular(14),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Monetization",
          //         style: AppTextStyles.bodyText.copyWith(
          //           fontSize: getResponsiveFontSize(0.03),
          //           color: Colors.white,
          //         ),
          //       ),
          //       SizedBox(height: screenHeight * 0.01),
          //       Text(
          //         paymentMode,
          //         style: AppTextStyles.bodyText.copyWith(
          //           fontSize: getResponsiveFontSize(0.03),
          //           color: Colors.white,
          //         ),
          //       ),
          //       SizedBox(height: screenHeight * 0.01),
          //       Row(
          //         children: [
          //           const Icon(Icons.account_balance_wallet,
          //               color: Colors.greenAccent, size: 20),
          //           SizedBox(width: screenWidth * 0.01),
          //           Text(
          //             "Estimated Earnings: ",
          //             style: AppTextStyles.bodyText.copyWith(
          //               fontSize: getResponsiveFontSize(0.03),
          //               color: Colors.white,
          //             ),
          //           ),
          //           Text(
          //             "\$1,200",
          //             style: AppTextStyles.bodyText.copyWith(
          //               fontSize: getResponsiveFontSize(0.03),
          //               color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 16),
          _CreatorsContentPreview(),

          SizedBox(height: screenHeight * 0.01),
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
    // final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: screenHeight * 0.01),
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Add this widget to the same file or as a separate widget file
class _CreatorsContentPreview extends StatelessWidget {
  _CreatorsContentPreview();

  final Controller controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final contentList = controller.creatorContent;
      if (contentList.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Content",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              TextButton(
                onPressed: () => Get.to(const CreatorsAllContentPage()),
                child: const Text("See All",
                    style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Content",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              TextButton(
                onPressed: () => Get.to(const CreatorsAllContentPage()),
                child: const Text("See All",
                    style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: contentList.length > 3 ? 3 : contentList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final content = contentList[index];
                return GestureDetector(
                  onTap: () {
                    // Optionally show details or navigate
                  },
                  child: Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 180,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildMediaThumbnail(content.contentName),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content.contentTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    content.contentDescription,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMediaThumbnail(String contentName) {
    final isImage = contentName.toLowerCase().endsWith('.png') ||
        contentName.toLowerCase().endsWith('.jpg') ||
        contentName.toLowerCase().endsWith('.jpeg') ||
        contentName.toLowerCase().endsWith('.gif');
    final isVideo = contentName.toLowerCase().endsWith('.mp4') ||
        contentName.toLowerCase().endsWith('.mov') ||
        contentName.toLowerCase().endsWith('.avi');
    final String url = contentName;

    if (isImage) {
      return Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    } else if (isVideo) {
      return Container(
        width: 60,
        height: 60,
        color: Colors.black26,
        child: const Icon(Icons.videocam, color: Colors.amber, size: 32),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[800],
        child: const Icon(Icons.insert_drive_file, color: Colors.white38),
      );
    }
  }
}
