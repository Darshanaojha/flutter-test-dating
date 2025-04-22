import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // To format the currency

import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  AllTransactionsPageState createState() => AllTransactionsPageState();
}

class AllTransactionsPageState extends State<AllTransactionsPage> {
  Controller controller = Get.put(Controller());
  late Future<void> _fetchAllTransactions;

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions = initializeData();
  }

  Future<bool> initializeData() async {
    if (!await controller.allTransactions()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions'),
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.textColor,
      ),
      body: FutureBuilder<void>(
        future: _fetchAllTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No Transaction Found.'));
          }

          return ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              var transaction = controller.transactions[index];
              double amount = double.tryParse(transaction.amount) ?? 0.0;
              var formattedAmount =
                  NumberFormat.currency(symbol: '₹').format(amount);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 15,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction ID: ${transaction.razorpayOrderId}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Payment Method: ${transaction.paymentMethod}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Amount: $formattedAmount',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[200],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Payment Status: ${transaction.paymentStatus}',
                          style: TextStyle(
                            fontSize: 8,
                            color: transaction.paymentStatus == 'success'
                                ? const Color.fromARGB(255, 183, 223, 184)
                                : Colors.grey[200],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created: ${transaction.created}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Updated: ${transaction.updated}',
                          style: TextStyle(
                            fontSize: 4,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID: ${transaction.orderId}',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                print(
                                    'View more details for transaction ${transaction.id}');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
