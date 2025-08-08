import 'package:dating_application/Screens/userprofile/membership/membershippage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pushable_button/pushable_button.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';
import 'package:intl/intl.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  double getResponsiveFontSize(BuildContext context, double factor) {
    return MediaQuery.of(context).size.width * factor;
  }

  @override
  void initState() {
    super.initState();

    if (controller.subscripted.isEmpty) {
      controller.fetchAllsubscripted();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Your Plans',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: getResponsiveFontSize(context, 0.05),
            color: AppColors.textColor,
          ),
        ),
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
      body: Obx(() {
        if (controller.subscripted.isEmpty) {
          return Center(
              child: Text("No plans found",
                  style: AppTextStyles.headingText.copyWith(
                    fontSize: getResponsiveFontSize(context, 0.04),
                    color: Colors.white,
                  )));
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: controller.subscripted.length,
                  itemBuilder: (context, index) {
                    final plan = controller.subscripted[index];
                    final bool isActive = plan.status == '1';
                    final DateTime subscriptionDate = DateTime.parse(plan.date);
                    DateTime expiryDate;

                    switch (plan.unit.toLowerCase()) {
                      case 'days':
                        expiryDate = subscriptionDate.add(Duration(days: int.parse(plan.days)));
                        break;
                      case 'months':
                        expiryDate = DateTime(subscriptionDate.year, subscriptionDate.month + int.parse(plan.days), subscriptionDate.day);
                        break;
                      case 'years':
                        expiryDate = DateTime(subscriptionDate.year + int.parse(plan.days), subscriptionDate.month, subscriptionDate.day);
                        break;
                      default:
                        expiryDate = subscriptionDate;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.grey[900],
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.gradientBackgroundList,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan.packageTitle,
                                    style: AppTextStyles.headingText.copyWith(
                                      fontSize: getResponsiveFontSize(context, 0.045),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isActive ? Colors.white : Colors.red, width: 1),
                                    ),
                                    child: Text(
                                      isActive ? 'Active' : 'Inactive',
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: isActive ? Colors.greenAccent : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildInfoRow(context, "Subscribed on:", DateFormat.yMMMd().format(subscriptionDate)),
                              _buildInfoRow(context, "Expires on:", DateFormat.yMMMd().format(expiryDate)),
                              _buildInfoRow(context, "Duration:", "${plan.days} ${plan.unit}"),
                              Divider(color: Colors.white24, height: 24),
                              _buildPriceRow(context, "Actual Price:", plan.actualAmount, strikethrough: true),
                              _buildPriceRow(context, "Offer Price:", plan.offerAmount),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: PushableButton(
            //     onPressed: () {
            //       Get.to(MembershipPage());
            //     },
            //     hslColor: HSLColor.fromColor(AppColors.mediumGradientColor),
            //     height: 60.0,
            //     elevation: 8.0,
            //     shadow: BoxShadow(
            //       color: Colors.black.withOpacity(0.3),
            //       blurRadius: 6.0,
            //       spreadRadius: 2.0,
            //       offset: Offset(0, 4),
            //     ),
            //     child: Text(
            //       'Upgrade Your Package',
            //       style: AppTextStyles.headingText.copyWith(
            //         fontSize: getResponsiveFontSize(context, 0.04),
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textStyle.copyWith(
              fontSize: getResponsiveFontSize(context, 0.035),
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textStyle.copyWith(
              fontSize: getResponsiveFontSize(context, 0.035),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool strikethrough = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textStyle.copyWith(
              fontSize: getResponsiveFontSize(context, 0.035),
              color: Colors.white70,
            ),
          ),
          Text(
            "₹$value",
            style: AppTextStyles.subheadingText.copyWith(
              fontSize: getResponsiveFontSize(context, 0.04),
              color:  Colors.white,
              fontWeight: strikethrough ? FontWeight.normal : FontWeight.bold,
              decoration: strikethrough ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
