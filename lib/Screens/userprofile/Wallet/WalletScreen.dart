import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent, // Needed for gradient
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

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
                  child: Image.asset(
                    'assets/images/coin.png',
                    height: 50,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.pointamount.length,
                    itemBuilder: (context, index) {
                      final item = controller.pointamount[index];
                      return Card(
                        color: AppColors.formFieldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Points: ${item.points}',
                                style:
                                    AppTextStyles.transactionTextStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '₹${item.amount}',
                                style:
                                    AppTextStyles.transactionTextStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: AppColors
                            .gradientBackgroundList, // Your custom gradient colors
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white, // Required for ShaderMask
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // To show gradient
        elevation: 0, // Remove default shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Builder(
          builder: (context) {
            double fontSize =
                MediaQuery.of(context).size.width * 0.05; // ~5% of screen width
            return Text(
              'Wallet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showDialog();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.gradientBackgroundList,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66666666),
                blurRadius: 10.0,
                spreadRadius: 3.0,
                offset: Offset(0, 6.0),
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
            controller.totalpoint.isNotEmpty
                ? controller.totalpoint.first.points
                : "0",
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
                gradient: LinearGradient(
                  colors: AppColors
                      .gradientBackgroundList, // Use your custom gradient list
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                        child: Text(
                      "Error fetching data",
                      style: TextStyle(color: Colors.white),
                    ));
                  } else if (controller.transactions.isEmpty) {
                    return Center(
                        child: Text(
                      "No transactions found",
                      style: TextStyle(color: Colors.white),
                    ));
                  }

                  return Obx(() {
                    // Filter transactions with coin == "0.0"
                    var filteredTransactions = controller.transactions
                        .where((transaction) => transaction.coin == "0.0")
                        .toList();

                    if (filteredTransactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            "No transactions found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                var transaction = filteredTransactions[index];
                                bool isCredited = false;

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: isCredited
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2,
                                    ),
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
                              childCount: filteredTransactions.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
