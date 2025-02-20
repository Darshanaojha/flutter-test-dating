import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  WalletPageState createState() => WalletPageState();
}

class WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Future<bool> _fetchpagedata;
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    _fetchpagedata = fetchAllData();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> fetchAllData() async {
    if (!await controller.getpointdetailsamount()) return false;
    if (!await controller.gettotalpoint()) return false;

    return true;
  }

  void _showDialog() {
    if (controller.pointamount.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Transaction Details'),
            content: Text('No transactions found!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return; // Prevent proceeding to avoid error when data is empty
    }

    // Continue with the dialog if data is available
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Transaction Details')),
          content: Column(
            children: [
              // Animated Coin
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28,
                    child: child,
                  );
                },
                child: Image.asset('assets/images/coin.png'),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.pointamount.length,
                  itemBuilder: (context, index) {
                    final item = controller.pointamount[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Points: ${item.points}',
                            style: AppTextStyles.transactionTextStyle,
                          ),
                          Text(
                            '₹${item.amount}',
                            style: AppTextStyles.transactionTextStyle,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Wallet', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/coin.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${controller.totalpoint.isNotEmpty ? controller.totalpoint.first.points : "0"}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: FutureBuilder(
                future: fetchAllData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Error fetching data",
                            style: TextStyle(color: Colors.white)));
                  } else if (controller.transactions.isEmpty) {
                    return Center(
                        child: Text("No transactions found",
                            style: TextStyle(color: Colors.white)));
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var transaction = controller.transactions[index];
                              bool isCredited = false;

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: isCredited
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2),
                                ),
                                elevation: 5,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: isCredited
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        title: Text(
                                          isCredited ? 'Credited' : 'Debited',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'Transaction ID: ${transaction.id}'),
                                        trailing: Icon(
                                          isCredited
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isCredited
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: controller.transactions.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
