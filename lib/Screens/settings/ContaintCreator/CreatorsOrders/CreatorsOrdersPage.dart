import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../Controllers/controller.dart';

class CreatorsOrdersPage extends StatefulWidget {
  const CreatorsOrdersPage({super.key});

  @override
  State<CreatorsOrdersPage> createState() => _CreatorsOrdersPageState();
}

class _CreatorsOrdersPageState extends State<CreatorsOrdersPage> {
  final Controller controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    controller.fetchCreatorsAllOrders();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Creator Orders'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.creatorsAllOrders.isEmpty) {
          return const Center(
            child: Text(
              "No orders found.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.creatorsAllOrders.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white12),
          itemBuilder: (context, index) {
            final order = controller.creatorsAllOrders[index];
            Color statusColor;
            switch (order.status.toLowerCase()) {
              case 'success':
              case 'completed':
                statusColor = Colors.green;
                break;
              case 'failed':
              case 'cancelled':
                statusColor = Colors.red;
                break;
              case 'pending':
                statusColor = Colors.orange;
                break;
              default:
                statusColor = Colors.grey;
            }
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt_long,
                    color: Colors.amber, size: 36),
                title: Text(
                  order.packageTitle.isNotEmpty
                      ? order.packageTitle
                      : 'No Title',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.packageDescription.isNotEmpty
                          ? order.packageDescription
                          : '-',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Paid: ₹${order.paidAmount.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Points Used: ${order.pointsUsed}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Created: ${formatDate(order.created)}",
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    order.status.isNotEmpty ? order.status : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: statusColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.black87,
                      title: const Text("Order Details",
                          style: TextStyle(color: Colors.amber)),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Order ID: ${order.id}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Receipt ID: ${order.receiptId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Razorpay ID: ${order.razorpayId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("User ID: ${order.userId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Package ID: ${order.packageId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Type: ${order.type}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "Actual Amount: ₹${order.actualAmount.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "Offer Amount: ₹${order.offerAmount.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "Paid Amount: ₹${order.paidAmount.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "Duration: ${order.duration ?? '-'} ${order.unit}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Status: ${order.status}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Points Used: ${order.pointsUsed}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Created: ${formatDate(order.created)}",
                                style: const TextStyle(color: Colors.white54)),
                            Text("Updated: ${formatDate(order.updated)}",
                                style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close",
                              style: TextStyle(color: Colors.amber)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
