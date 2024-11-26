import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  PricingPageState createState() => PricingPageState();
}

class PricingPageState extends State<PricingPage> {
  RxString selectedPlan = 'None'.obs;

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.05; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Become Our Prime Member'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Send unlimited likes, see who likes you first, filter by desires and find your people. Plus, you can chat with them!",
                style: AppTextStyles.labelText,
              ),
              SizedBox(height: 20),
              buildPaymentWidget(context),
              SizedBox(height: 30),
              buildProsAndCons(context),
              SizedBox(height: 50), 
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity, 
          child: ElevatedButton(
            onPressed: selectedPlan.value != 'None'
                ? () {
                    showPaymentConfirmationDialog(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPlan.value != 'None'
                  ? AppColors.activeColor
                  : AppColors.inactiveColor,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentWidget(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

    return Column(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Subscription Plans",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Choose a plan that suits you!",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Monthly Plan Section
        buildPlanCard(
          context,
          planType: 'Monthly',
          amount: '₹99/month',
          discount: '20% OFF',
          icon: Icons.calendar_today,
        ),
        SizedBox(height: 20),

        // Quarterly Plan Section
        buildPlanCard(
          context,
          planType: 'Quarterly',
          amount: '₹599/3 months',
          discount: '15% OFF',
          icon: Icons.calendar_view_day,
        ),
        SizedBox(height: 20),

        // Yearly Plan Section
        buildPlanCard(
          context,
          planType: 'Yearly',
          amount: '₹999/year',
          discount: '35% OFF',
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  Widget buildPlanCard(BuildContext context, {
    required String planType,
    required String amount,
    required String discount,
    required IconData icon,
  }) {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan.value = planType;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: selectedPlan.value == planType ? Colors.green : Colors.orange,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.iconColor,
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "$planType Plan - $amount",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                discount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize - 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProsAndCons(BuildContext context) {
  //  double fontSize = MediaQuery.of(context).size.width * 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pros of Becoming a Prime Member:",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 10),
        Text(
          "- Unlimited likes",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- See who likes you first",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Filter matches by your desires",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Ability to chat with matches",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 20),
        Text(
          "Cons of Becoming a Prime Member:",
          style: AppTextStyles.labelText,
        ),
        SizedBox(height: 10),
        Text(
          "- Requires a paid subscription",
          style: AppTextStyles.labelText,
        ),
        Text(
          "- Might not be affordable for everyone",
          style: AppTextStyles.labelText,
        ),
      ],
    );
  }

  // Show dialog when 'Continue' button is pressed
  Future<void> showPaymentConfirmationDialog(BuildContext context) async {
    double fontSize = MediaQuery.of(context).size.width * 0.05;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Subscription",
            style: AppTextStyles.titleText.copyWith(
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          ),
          content: Text(
            "Do you want to subscribe to the ${selectedPlan.value} plan?",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: fontSize - 2,
              color: AppColors.textColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.deniedColor,
                  fontSize: fontSize,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Proceed with the subscription logic
                print("Subscribed to ${selectedPlan.value}");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Subscribe',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.acceptColor,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
