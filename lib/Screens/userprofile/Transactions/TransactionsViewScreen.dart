import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // To format the currency
import 'package:timeago/timeago.dart' as timeago;

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

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 28);
      case '2':
        return Icon(Icons.arrow_upward_rounded, color: Colors.amber, size: 28);
      case '3':
        return Icon(Icons.arrow_upward_rounded, color: Colors.red, size: 28);
      default:
        return Icon(Icons.arrow_upward_rounded, color: Colors.grey, size: 28);
    }
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

          return ListView.separated(
            itemCount: controller.transactions.length,
            separatorBuilder: (context, index) => SizedBox(
              height: getResponsiveHeight(
                  context, 0.004), // smaller space between cards
            ),
            itemBuilder: (context, index) {
              var transaction = controller.transactions[index];
              double amount = double.tryParse(transaction.amount) ?? 0.0;
              var formattedAmount =
                  NumberFormat.currency(symbol: '₹').format(amount);

              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.gradientBackgroundList,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: TextStyle(color: Colors.white)),
                              Text('Order ID: ${transaction.orderId}',
                                  style: TextStyle(color: Colors.white)),
                              // Text(
                              //     'Payment Method: ${transaction.paymentMethod ?? "-"}',
                              //     style: TextStyle(color: Colors.white)),
                              Text('Amount: $formattedAmount',
                                  style: TextStyle(color: Colors.white)),
                              Text(
                                'Payment Status: ${transaction.paymentStatus == '1' ? 'Success' : transaction.paymentStatus == '2' ? 'Pending' : transaction.paymentStatus == '3' ? 'Cancel' : 'Unknown'}',
                                style: TextStyle(color: Colors.white),
                              ),
                              // Text('Message: ${transaction.message}',
                              //     style: TextStyle(color: Colors.white)),
                              Text('Created: ${transaction.created}',
                                  style: TextStyle(color: Colors.white)),
                              Text('Updated: ${transaction.updated}',
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Close",
                                    style:
                                        TextStyle(color: AppColors.textColor),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getResponsiveHeight(context, 0.015),
                    vertical:
                        getResponsiveHeight(context, 0.0001), // reduced spacing
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Status icon on left
                          Padding(
                            padding: EdgeInsets.only(
                              right: getResponsiveHeight(context, 0.018),
                            ),
                            child: CircleAvatar(
                              radius: getResponsiveHeight(context, 0.035),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: getStatusIcon(transaction.paymentStatus),
                            ),
                          ),

                          // Right side content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID : ${transaction.razorpayOrderId ?? "-"}',
                                  style: TextStyle(
                                    fontSize:
                                        getResponsiveFontSize(context, 0.036),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        getResponsiveHeight(context, 0.008)),
                                Text(
                                  '$formattedAmount',
                                  style: TextStyle(
                                    fontSize:
                                        getResponsiveFontSize(context, 0.035),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        getResponsiveHeight(context, 0.008)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      timeago.format(
                                        DateTime.parse(transaction.updated),
                                        locale: 'en_short_numeric',
                                        allowFromNow: true,
                                      ),
                                      style: TextStyle(
                                        fontSize: getResponsiveFontSize(
                                            context, 0.025),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
          );
        },
      ),
    );
  }
}
