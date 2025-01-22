import 'package:flutter/material.dart';

import '../../../constants.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  AllTransactionsPageState createState() => AllTransactionsPageState();
}

class AllTransactionsPageState extends State<AllTransactionsPage> {
  Future<Map<String, dynamic>> fetchTransactions() async {
    await Future.delayed(Duration(seconds: 2)); 
    return {
      "success": true,
      "payload": {
        "transactions": [
          {
            "id": "1",
            "user_id": "fb958dd6-2751-4341-914d-9c8bfc1ead8f",
            "order_id": "1",
            "package_id": "232d53f3-8ef7-44c7-bacf-91e19e1eb31c",
            "type": "2",
            "razorpay_order_id": "order_KRsmcszZtxvJS8",
            "razorpay_payment_id": "pay_IJkh2hn1S9P2rM",
            "payment_status": "success",
            "payment_method": "credit_card",
            "amount": "499.99",
            "created": "2025-01-14 12:57:09",
            "updated": "2025-01-14 12:57:09"
          },
        ]
      },
      "error": {
        "code": 0,
        "message": ""
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions'),
         backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.textColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!["success"]) {
            return Center(child: Text('No Transactions Found.'));
          }

          // Extract transactions
          List<dynamic> transactions = snapshot.data!['payload']['transactions'];

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
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
                          'Transaction ID: ${transaction['razorpay_payment_id'] ?? 'No ID'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Payment Method: ${transaction['payment_method'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Amount: \$${transaction['amount'] ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Payment Status: ${transaction['payment_status'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: transaction['payment_status'] == 'success' ? Colors.green : Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created: ${transaction['created'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Updated: ${transaction['updated'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID: ${transaction['order_id'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                // Handle more information or edit transaction
                                print('View more details for transaction ${transaction['id']}');
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
