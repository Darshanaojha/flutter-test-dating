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
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize =
                MediaQuery.of(context).size.width * 0.05; // ~5% of screen width
            return Text(
              'Subscription History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        foregroundColor: AppColors.textColor,
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
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
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
                bool isActive = order.status == '1';

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getResponsiveHeight(context, 0.02),
                      vertical: getResponsiveHeight(context, 0.008)),
                  child: GestureDetector(
                    onTap: () {
                      // Add any onTap action here if needed
                    },
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(0.8, 1),
                              colors: AppColors.gradientBackgroundList,
                            ),
                          ),
                          padding: EdgeInsets.all(
                              getResponsiveHeight(context, 0.03)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row for avatar icon + title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: getResponsiveHeight(context, 0.035),
                                    backgroundColor: Colors.white24,
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: Colors.white,
                                      size: getResponsiveHeight(context, 0.035),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          getResponsiveHeight(context, 0.02)),
                                  Expanded(
                                    child: Text(
                                      order.packageTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: getResponsiveFontSize(
                                            context, 0.055),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 5,
                                            color: Colors.black54,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: getResponsiveHeight(context, 0.02)),
                              Text(
                                'Category: ${order.packageCategoryTitle}',
                                style: TextStyle(
                                  fontSize:
                                      getResponsiveFontSize(context, 0.037),
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(
                                  height: getResponsiveHeight(context, 0.015)),
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee,
                                      color: Colors.white70,
                                      size: getResponsiveFontSize(
                                          context, 0.045)),
                                  SizedBox(width: 4),
                                  Text(
                                    ' ${order.actualAmount}',
                                    style: TextStyle(
                                      fontSize:
                                          getResponsiveFontSize(context, 0.037),
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.schedule,
                                      color: Colors.white70,
                                      size: getResponsiveFontSize(
                                          context, 0.045)),
                                  SizedBox(width: 8),
                                  Text(
                                    '${order.days} ${order.unit}',
                                    style: TextStyle(
                                      fontSize:
                                          getResponsiveFontSize(context, 0.037),
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: getResponsiveHeight(context, 0.02)),
                              Divider(
                                color: Colors.white30,
                                thickness: 1,
                                height: 1,
                              ),
                              // SizedBox(
                              //     height: getResponsiveHeight(context, 0.02)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: getResponsiveHeight(context, 0.015),
                          right: getResponsiveHeight(context, 0.015),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors
                                  .transparent, // or Colors.white.withOpacity(0.1) if you want slight fill
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? Colors.amber.shade400
                                    : Colors.amber.shade400,
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: getResponsiveHeight(context, 0.005),
                              horizontal: getResponsiveHeight(context, 0.009),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Optional Icon here
                                // Icon(
                                //   isActive ? Icons.check_circle : Icons.cancel,
                                //   color: isActive ? Colors.greenAccent : Colors.redAccent,
                                //   size: getResponsiveFontSize(context, 0.045),
                                // ),
                                // SizedBox(width: 6),
                                Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize:
                                        getResponsiveFontSize(context, 0.038),
                                    //fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.greenAccent
                                        : Colors.amber.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
