import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../Controllers/controller.dart';
import '../../../../Models/ResponseModels/creator_transaction_history_response.dart';

class CreatorsTransactionPage extends StatefulWidget {
  const CreatorsTransactionPage({super.key});

  @override
  State<CreatorsTransactionPage> createState() =>
      _CreatorsTransactionPageState();
}

class _CreatorsTransactionPageState extends State<CreatorsTransactionPage> {
  final Controller controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    controller.fetchCreatorTransactionHistory();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Transactions'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.creatorTransactionHistory.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.creatorTransactionHistory.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white12),
          itemBuilder: (context, index) {
            final TransactionData tx =
                controller.creatorTransactionHistory[index];

            Color statusColor;
            switch (tx.paymentStatus.toLowerCase()) {
              case 'success':
              statusColor = Colors.green;
                break;
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
                leading:
                    const Icon(Icons.payments, color: Colors.amber, size: 36),
                title: Text(
                  "₹${tx.paidAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Message: ${tx.message.isNotEmpty ? tx.message : '-'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Points Used: ${tx.pointsUsed}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Date: ${formatDate(tx.created)}",
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 70, // or a value that fits your design, e.g. 60-80
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Chip(
                      label: Text(
                        tx.paymentStatus.isNotEmpty ? tx.paymentStatus : '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 0),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.black87,
                      title: const Text("Transaction Details",
                          style: TextStyle(color: Colors.amber)),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Order ID: ${tx.orderId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Razorpay ID: ${tx.razorpayId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Razorpay Payment ID: ${tx.razorpayPaymentId}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Payment Status: ${tx.paymentStatus}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Payment Method: ${tx.paymentMethod}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Amount: ₹${tx.amount.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "Paid Amount: ₹${tx.paidAmount.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Points Used: ${tx.pointsUsed}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Message: ${tx.message}",
                                style: const TextStyle(color: Colors.white)),
                            Text("Date: ${formatDate(tx.updated)}",
                                style: const TextStyle(color: Colors.white60)),
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
