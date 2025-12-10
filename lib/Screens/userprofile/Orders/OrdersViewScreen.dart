import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/ResponseModels/all_orders_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added this line

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<AllOrdersPage> {
  final Controller controller = Get.put(Controller());
  late Future<bool> _fetchAllOrders;
  bool _isPlanExpired = false;

  @override
  void initState() {
    super.initState();
    _fetchAllOrders = controller.allOrders();
  }

  void _checkPlanExpiry() {
    final activeOrders =
        controller.orders.where((o) => o.status == '1').toList();
    if (activeOrders.isEmpty) {
      return;
    }

    activeOrders.sort((a, b) =>
        DateTime.parse(b.created).compareTo(DateTime.parse(a.created)));
    final latestActiveOrder = activeOrders.first;

    final createdDate = DateTime.parse(latestActiveOrder.created);
    final duration = int.tryParse(latestActiveOrder.days) ?? 0;
    Duration planDuration;
    switch (latestActiveOrder.unit.toLowerCase()) {
      case 'days':
        planDuration = Duration(days: duration);
        break;
      case 'months':
        planDuration = Duration(days: duration * 30);
        break;
      case 'years':
        planDuration = Duration(days: duration * 365);
        break;
      default:
        planDuration = Duration(days: duration);
    }
    final expiryDate = createdDate.add(planDuration);

    if (DateTime.now().isAfter(expiryDate)) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Plan Expired",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please renew your plan to continue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
        setState(() {
          _isPlanExpired = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<bool>(
        future: _fetchAllOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!) {
            return const Center(child: Text('No Orders Found.'));
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isPlanExpired) {
              _checkPlanExpiry();
            }
          });

          return Obx(() {
            if (controller.orders.isEmpty) {
              return const Center(child: Text('No Orders Found.'));
            }

            final reversedOrders = controller.orders.reversed.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reversedOrders.length,
              itemBuilder: (context, index) {
                final order = reversedOrders[index];
                return OrderTile(order: order);
              },
            );
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Packages",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.05,
          color: AppColors.textColor,
        ),
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
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;
  const OrderTile({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.bottomSheet(OrderDetailSheet(order: order)),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: AppColors.gradientBackgroundList),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientBackgroundList.last.withOpacity(0.6),
                  blurRadius: 5,
                  spreadRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.crown,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(height: 8),
                  Text(
                    order.packageTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${order.offerAmount}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                          DateFormat('MMM d, yyyy')
                              .format(DateTime.parse(order.created)),
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      Text(
                          DateFormat('h:mm a')
                              .format(DateTime.parse(order.created)),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Positioned on top of gradient border
          Positioned(
            top: 10,
            right: 13,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(getStatusColor(order.status)),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                getStatusText(order.status),
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getStatusText(String status) {
  switch (status) {
    case '1':
      return 'Active';
    case '2':
      return 'Inactive';
    case '3':
      return 'Declined';
    default:
      return 'Unknown';
  }
}

int getStatusColor(String status) {
  switch (status) {
    case '1':
      return 0xFF4CAF50; // green
    case '2':
      return 0xFFFFC107; // yellow
    case '3':
      return 0xFFF44336; // red
    default:
      return 0xFF9E9E9E; // grey
  }
}

class OrderDetailSheet extends StatelessWidget {
  final Order order;
  const OrderDetailSheet({required this.order, super.key});

  double getResponsiveFontSize(BuildContext context, double scale) {
    return MediaQuery.of(context).size.width * scale;
  }

  double getResponsiveHeight(BuildContext context, double scale) {
    return MediaQuery.of(context).size.height * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientBackgroundList,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.crown,
                      size: getResponsiveHeight(context, 0.06),
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Subscription Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveFontSize(context, 0.05),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.card_membership, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.packageTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(getStatusColor(order.status)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getStatusText(order.status),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.currency_rupee, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '₹ ${order.offerAmount}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.category, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Category: ${order.packageCategoryTitle}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duration: ${order.days} ${order.unit}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actual Amount: ₹ ${order.actualAmount}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.confirmation_number, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order ID: ${order.razorpayOrderId}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(order.created)),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: getResponsiveHeight(context, 0.04),
                    padding: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(context, 0.038),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
