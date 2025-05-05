import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../constants.dart';

class CreatorDashboardPage extends StatelessWidget {
  const CreatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "📊 Creator Dashboard",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(context, "Earnings Overview", isTablet),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _earningsChart(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _sectionTitle(context, "Revenue Breakdown", isTablet),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _revenuePieChart(context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _sectionTitle(context, "Key Stats", isTablet),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _statsGrid(context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _sectionTitle(context, "Recent Activity", isTablet),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          ..._recentActivityList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF1694),
        onPressed: () {
          // Add functionality here
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _sectionTitle(context, String title, bool isTablet) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Text(
      title,
      style: AppTextStyles.bodyText.copyWith(
        fontSize: getResponsiveFontSize(0.03),
        color: Colors.white,
      ),
    );
  }

  Widget _earningsChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1f005c), Color(0xFF870160)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

  Widget _revenuePieChart(context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1f005c), Color(0xFF5b0060)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    titleStyle: AppTextStyles.bodyText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: 30,
                    title: 'Tips\n30%',
                    radius: 55,
                    titleStyle: AppTextStyles.bodyText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: 25,
                    title: 'Content\n25%',
                    radius: 50,
                    titleStyle: AppTextStyles.bodyText.copyWith(
                      fontSize: getResponsiveFontSize(0.03),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
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

  Widget _statsGrid(context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(context, "Total Subscribers", "1.2K", Icons.people),
        _statCard(context, "Total Posts", "48", Icons.image),
        _statCard(context, "Avg. Earnings/Post", "\$25", Icons.monetization_on),
        _statCard(context, "Engagement Rate", "13.5%", Icons.trending_up),
      ],
    );
  }

  Widget _statCard(context, String title, String value, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1f005c), Color(0xFF870160)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: screenHeight * 0.01),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.01),
          Text(
            title,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white,
            ),
          ),
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
              title:
                  Text(activity, style: const TextStyle(color: Colors.white70)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: screenWidth * 0.01),
        Text(
          label,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
