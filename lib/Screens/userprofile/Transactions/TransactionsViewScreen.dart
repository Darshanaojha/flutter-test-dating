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

  double getResponsiveFontSize(BuildContext context, double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  double getResponsiveHeight(BuildContext context, double scale) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            double fontSize =
                MediaQuery.of(context).size.width * 0.05; // ~5% of screen width
            return Text(
              'All Transactions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        centerTitle: true, // To center the title as in your SafeArea + Center
        backgroundColor:
            Colors.transparent, // Needed to show gradient from flexibleSpace
        elevation: 0, // Remove default shadow to use custom shadow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 3,
                offset: Offset(0, 6),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
        ),
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

          if (controller.transactions.isEmpty) {
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
                padding: EdgeInsets.symmetric(
                  horizontal: getResponsiveHeight(context, 0.015),
                  vertical: getResponsiveHeight(context, 0.008),
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        EdgeInsets.all(getResponsiveHeight(context, 0.018)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction ID: ${transaction.razorpayOrderId ?? "-"}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.038),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Order ID: ${transaction.orderId}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.034),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Payment Method: ${transaction.paymentMethod ?? "-"}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.032),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Amount: $formattedAmount',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.038),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Payment Status: ${transaction.paymentStatus}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.032),
                            color: transaction.paymentStatus == 'success'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Message: ${transaction.message}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.03),
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: getResponsiveHeight(context, 0.008)),
                        Text(
                          'Created: ${transaction.created}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.028),
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          'Updated: ${transaction.updated}',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 0.025),
                            color: Colors.white60,
                          ),
                        ),
                        //SizedBox(height: getResponsiveHeight(context, 0.012)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.info_outline,
                                  color: Colors.white,
                                  size: getResponsiveFontSize(context, 0.045)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.all(16),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Text(
                                                "Transaction Details",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Transaction ID: ${transaction.razorpayOrderId ?? "-"}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Order ID: ${transaction.orderId}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Payment Method: ${transaction.paymentMethod ?? "-"}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Amount: $formattedAmount',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Payment Status: ${transaction.paymentStatus}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Message: ${transaction.message}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Created: ${transaction.created}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'Updated: ${transaction.updated}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  "Close",
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.textColor),
                                                ),
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
