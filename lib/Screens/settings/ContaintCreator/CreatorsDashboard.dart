


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

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CreatorDashboardPage extends StatelessWidget {
  const CreatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("📊 Creator Dashboard", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle("Earnings Overview", isTablet),
          const SizedBox(height: 12),
          _earningsChart(),

          const SizedBox(height: 30),
          _sectionTitle("Revenue Breakdown", isTablet),
          const SizedBox(height: 12),
          _revenuePieChart(),

          const SizedBox(height: 30),
          _sectionTitle("Key Stats", isTablet),
          const SizedBox(height: 12),
          _statsGrid(),

          const SizedBox(height: 30),
          _sectionTitle("Recent Activity", isTablet),
          const SizedBox(height: 12),
          ..._recentActivityList(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white70,
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _earningsChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 50),
                  FlSpot(1, 70),
                  FlSpot(2, 60),
                  FlSpot(3, 90),
                  FlSpot(4, 100),
                  FlSpot(5, 80),
                  FlSpot(6, 110),
                ],
                isCurved: true,
                color: Colors.pinkAccent,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.pinkAccent.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _revenuePieChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                sections: [
                  PieChartSectionData(
                    color: Colors.pinkAccent,
                    value: 45,
                    title: 'Subs\n45%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: 30,
                    title: 'Tips\n30%',
                    radius: 55,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: 25,
                    title: 'Content\n25%',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Legend(color: Colors.pinkAccent, label: "Subscriptions"),
              _Legend(color: Colors.blueAccent, label: "Tips"),
              _Legend(color: Colors.greenAccent, label: "Paid Content"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard("Total Subscribers", "1.2K", Icons.people),
        _statCard("Total Posts", "48", Icons.image),
        _statCard("Avg. Earnings/Post", "\$25", Icons.monetization_on),
        _statCard("Engagement Rate", "13.5%", Icons.trending_up),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  List<Widget> _recentActivityList() {
    final activities = [
      "You earned \$30 from a new subscription.",
      "New post received 120 likes.",
      "Subscriber ‘@user89’ sent you a tip.",
      "You gained 14 new followers.",
    ];

    return activities
        .map((activity) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: const Icon(Icons.bolt, color: Colors.pinkAccent),
              title: Text(activity, style: const TextStyle(color: Colors.white70)),
            ))
        .toList();
  }
}

// Reusable legend widget
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
