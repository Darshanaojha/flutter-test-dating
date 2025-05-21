import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../Controllers/controller.dart';
import '../../../../Models/ResponseModels/creators_subscription_history_response.dart';

class CreatorSubsPurchasedPage extends StatefulWidget {
  const CreatorSubsPurchasedPage({super.key});

  @override
  State<CreatorSubsPurchasedPage> createState() => _CreatorSubsPurchasedPageState();
}

class _CreatorSubsPurchasedPageState extends State<CreatorSubsPurchasedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Controller controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller.fetchCreatorsSubscriptionHistory();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Subscription History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: Obx(() {
        final allSubs = controller.creatorsSubscriptionHistory;
        final now = DateTime.now();
        final activeSubs = allSubs.where((s) => s.endDate != null && s.endDate!.isAfter(now)).toList();
        final expiredSubs = allSubs.where((s) => s.endDate != null && s.endDate!.isBefore(now)).toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _buildList(allSubs, width, height),
            _buildList(activeSubs, width, height),
            _buildList(expiredSubs, width, height),
          ],
        );
      }),
    );
  }

  Widget _buildList(List<CreatorSubscriptionHistory> subscriptions, double width, double height) {
    if (subscriptions.isEmpty) {
      return const Center(
        child: Text("No plans found", style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final plan = subscriptions[index];
        final isActive = plan.endDate != null && plan.endDate!.isAfter(DateTime.now());
        final statusColor = isActive ? Colors.green : Colors.red;
        final statusText = isActive ? "Active" : "Expired";

        return Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.01),
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Status and Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRibbon(statusText, statusColor, width),
                  SizedBox(height: height * 0.01),
                  // _buildInfoItem(Icons.currency_rupee, "${plan.amount ?? '-'}", width),
                  // SizedBox(height: height * 0.005),
                  // _buildInfoItem(Icons.access_time, plan.duration ?? '-', width),
                ],
              ),
              SizedBox(width: width * 0.04),
              // Right side: Plan name and dates
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   plan.name ?? '-',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: width * 0.045,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   textAlign: TextAlign.right,
                    // ),
                    SizedBox(height: height * 0.01),
                    _buildDateItem(plan.startDate, plan.endDate, width),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRibbon(String text, Color color, double width) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: width * 0.03),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.03,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, double width) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: width * 0.04),
        SizedBox(width: width * 0.015),
        Text(value, style: TextStyle(color: Colors.white, fontSize: width * 0.035)),
      ],
    );
  }

  Widget _buildDateItem(DateTime? start, DateTime? end, double width) {
    final startStr = start != null ? DateFormat('dd MMM yyyy').format(start) : '-';
    final endStr = end != null ? DateFormat('dd MMM yyyy').format(end) : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Start: $startStr",
          style: TextStyle(color: Colors.white70, fontSize: width * 0.035),
        ),
        Text(
          "End: $endStr",
          style: TextStyle(color: Colors.white70, fontSize: width * 0.035),
        ),
      ],
    );
  }
}
