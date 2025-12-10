import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    return await controller.allTransactions();
  }

  double getResponsiveFontSize(BuildContext context, double scale) {
    return MediaQuery.of(context).size.width * scale;
  }

  double getResponsiveHeight(BuildContext context, double scale) {
    return MediaQuery.of(context).size.height * scale;
  }

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 22);
      case '2':
        return Icon(Icons.arrow_upward_rounded, color: Colors.amber, size: 22);
      case '3':
        return Icon(Icons.arrow_upward_rounded, color: Colors.red, size: 22);
      default:
        return Icon(Icons.arrow_upward_rounded, color: Colors.grey, size: 22);
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return 'Success';
      case '2':
        return 'Cancelled';
      case '3':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.amber;
      case '3':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: getResponsiveFontSize(context, 0.05),
            color: AppColors.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          }
          if (controller.transactions.isEmpty) {
            return Center(
                child: Text('No Transaction Found.',
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              var transaction = controller.transactions[index];
              double amount = double.tryParse(transaction.amount) ?? 0.0;
              var formattedAmount =
                  NumberFormat.currency(symbol: '₹').format(amount);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.gradientBackgroundList,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(2.5),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppColors.gradientBackgroundList,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.all(2.5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  size: getResponsiveHeight(
                                                      context, 0.06),
                                                  color: Colors.white),
                                              SizedBox(height: 8),
                                              Text(
                                                "Transaction Details",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      getResponsiveFontSize(
                                                          context, 0.05),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Icon(Icons.confirmation_number,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                transaction.razorpayOrderId ?? "-",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.assignment,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                transaction.orderId,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.currency_rupee,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                formattedAmount,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                getStatusText(transaction.paymentStatus),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(    
                                              child: Text(
                                                DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(transaction.created)),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            padding: EdgeInsets.all(2.5),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: AppColors
                                                    .gradientBackgroundList,
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              height: getResponsiveHeight(
                                                  context, 0.04),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Close",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      getResponsiveFontSize(
                                                          context, 0.038),
                                                ),
                                              ),
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
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.gradientBackgroundList,
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.15),
                                radius: 20,
                                child: getStatusIcon(transaction.paymentStatus),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${transaction.razorpayOrderId ?? "-"}',
                                      style: TextStyle(
                                        fontSize: getResponsiveFontSize(
                                            context, 0.034),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formattedAmount,
                                      style: TextStyle(
                                        fontSize: getResponsiveFontSize(
                                            context, 0.032),
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(
                                                transaction.updated)),
                                        style: TextStyle(
                                          fontSize: getResponsiveFontSize(
                                              context, 0.025),
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: getStatusColor(transaction.paymentStatus),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          getStatusText(transaction.paymentStatus),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: getResponsiveFontSize(context, 0.035)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
