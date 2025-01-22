import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  AllOrdersPageState createState() => AllOrdersPageState();
}

class AllOrdersPageState extends State<AllOrdersPage> {
  Future<Map<String, dynamic>> fetchOrders() async {
    await Future.delayed(Duration(seconds: 2));
    return {
      "success": true,
      "payload": {
        "orders": [
          {
            "id": "1",
            "user_id": "fb958dd6-2751-4341-914d-9c8bfc1ead8f",
            "package_id": "232d53f3-8ef7-44c7-bacf-91e19e1eb31c",
            "type": "2",
            "amount": "100.00",
            "package_title": "Package One",
            "package_category_id": "a77e5350-fb9c-4b9f-ad8e-5b9af56718ef",
            "package_category_title": "Category One",
            "package_category_description":
                "We are thrilled to announce our strategic partnership.",
            "days": "30",
            "actual_amount": "120",
            "offer_amount": "100",
            "unit": "days",
            "addon_title": null,
            "addon_duration": null,
            "addon_duration_unit": null,
            "addon_amount": null,
            "status": "1",
            "created": "2025-01-14 10:39:34",
            "updated": "2025-01-14 10:39:34"
          },
        ]
      },
      "error": {"code": 0, "message": ""}
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.textColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!["success"]) {
            return Center(child: Text('No Orders Found.'));
          }
          List<dynamic> orders = snapshot.data!['payload']['orders'];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

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
                          order['package_title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Package Category: ${order['package_category_title'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Amount: \$${order['amount'] ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Days: ${order['days'] ?? '0'} ${order['unit'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${order['status'] == '1' ? 'Active' : 'Inactive'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: order['status'] == '1'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Created: ${order['created'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                print(
                                    'View more details for order ${order['id']}');
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
