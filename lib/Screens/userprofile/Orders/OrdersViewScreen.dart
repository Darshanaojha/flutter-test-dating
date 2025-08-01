import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  AllOrdersPageState createState() => AllOrdersPageState();
}

class AllOrdersPageState extends State<AllOrdersPage> {
  Controller controller = Get.put(Controller());
  late Future<bool> _fetchallorders;

  @override
  void initState() {
    super.initState();
    _fetchallorders = initializeData();
  }

  Future<bool> initializeData() async {
    return await controller.allOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Subscription History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.05,
            color: AppColors.textColor,
          ),
        ),
        foregroundColor: AppColors.textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: FutureBuilder<bool>(
        future: _fetchallorders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!) {
            return const Center(child: Text('No Orders Found.'));
          }

          return Obx(() {
            if (controller.orders.isEmpty) {
              return const Center(child: Text('No Orders Found.'));
            }

            final reversedOrders = controller.orders.reversed.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reversedOrders.length,
              itemBuilder: (context, index) {
                var order = reversedOrders[index];

                DateTime startDate = DateTime.parse(order.created);
                DateTime endDate = order.unit.toLowerCase().contains('day')
                    ? startDate.add(Duration(days: int.tryParse(order.days) ?? 0))
                    : startDate;

                String formattedStartDate = DateFormat('d-MM-yy').format(startDate);
                String formattedEndDate = DateFormat('d-MM-yy').format(endDate);

                bool isActive = DateTime.now().isBefore(endDate);

                return SubscriptionTile(
                  isActive: isActive,
                  from: formattedStartDate,
                  to: formattedEndDate,
                  title: order.packageTitle,
                );
              },
            );
          });
        },
      ),
    );
  }
}

class SubscriptionTile extends StatelessWidget {
  final bool isActive;
  final String from;
  final String to;
  final String title;

  const SubscriptionTile({
    super.key,
    required this.isActive,
    required this.from,
    required this.to,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    Widget labelBadge() {
      return isActive
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                'Active',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                'Expired',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
    }

    Widget innerContent(Color textColor) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.crown,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 60),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('from ', style: TextStyle(fontStyle: FontStyle.italic)),
                      Text(from, style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      const Text('to ', style: TextStyle(fontStyle: FontStyle.italic)),
                      Text(to, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: labelBadge(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: isActive
          ? Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: innerContent(Colors.white),
            )
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.disabled),
                borderRadius: BorderRadius.circular(12),
              ),
              child: innerContent(AppColors.disabled),
            ),
    );
  }
}
