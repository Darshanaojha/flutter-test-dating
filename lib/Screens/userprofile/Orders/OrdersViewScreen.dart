import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controllers/controller.dart';

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
    if (!await controller.allOrders()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.textColor,
      ),
      body: FutureBuilder<bool>(
        future: _fetchallorders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!) {
            return Center(child: Text('No Orders Found.'));
          }

          return Obx(() {
            if (controller.orders.isEmpty) {
              return Center(child: Text('No Orders Found.'));
            }

            return ListView.builder(
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                var order = controller.orders[index];
                return Padding(
                  padding: EdgeInsets.all(getResponsiveHeight(context, 0.01)),
                  child: Card(
                    elevation: 15,
                    shadowColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.all(getResponsiveHeight(context, 0.02)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.packageTitle,
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 0.045),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: getResponsiveHeight(context, 0.008)),
                          Text(
                            'Package Category: ${order.packageCategoryTitle}',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 0.035),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: getResponsiveHeight(context, 0.008)),
                          Text(
                            'Amount: ₹${order.actualAmount}',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 0.035),
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: getResponsiveHeight(context, 0.008)),
                          Text(
                            'Days: ${order.days} ${order.unit}',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 0.035),
                              color: const Color.fromARGB(255, 0, 84, 152),
                            ),
                          ),
                          SizedBox(height: getResponsiveHeight(context, 0.008)),
                          Text(
                            'Status: ${order.status == '1' ? 'Active' : 'Inactive'}',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 0.035),
                              color: order.status == '1'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          SizedBox(height: getResponsiveHeight(context, 0.012)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created: ${order.created}',
                                style: TextStyle(
                                  fontSize:
                                      getResponsiveFontSize(context, 0.03),
                                  color: Colors.grey[500],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline,
                                    size:
                                        getResponsiveFontSize(context, 0.045)),
                                onPressed: () {
                                  print(
                                      'View more details for order ${order.id}');
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
          });
        },
      ),
    );
  }
}

double getResponsiveFontSize(BuildContext context, double scale) {
  double screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * scale;
}

double getResponsiveHeight(BuildContext context, double scale) {
  double screenHeight = MediaQuery.of(context).size.height;
  return screenHeight * scale;
}
