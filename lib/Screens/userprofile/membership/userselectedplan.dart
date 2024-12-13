
import 'package:dating_application/Screens/userprofile/membership/membershippage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';
class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> {
  Controller controller = Get.put(Controller());

  double getResponsiveFontSize(BuildContext context, double factor) {
    return MediaQuery.of(context).size.width * factor;
  }

  @override
  void initState() {
    super.initState();

    // Check if the data has already been fetched before calling the fetch method
    if (controller.subscripted.isEmpty) {
      controller.fetchAllsubscripted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Plans',
          style: AppTextStyles.headingText.copyWith(
            fontSize: getResponsiveFontSize(context, 0.05),
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        // Observe subscripted list, will rebuild on changes
        if (controller.subscripted.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: controller.subscripted.length,
                  itemBuilder: (context, index) {
                    return AnimatedScale(
                      scale: 1.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 500),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 12,  // Slight elevation for a better shadow effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),  // Soft rounded corners
                            side: BorderSide(
                              color: Colors.grey[600]!,  // Subtle dark border
                              width: 1.5,
                            ),
                          ),
                          color: Colors.grey[900],  // Darker background for the card
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.subscripted[index].packageTitle,
                                  style: AppTextStyles.headingText.copyWith(
                                    fontSize: getResponsiveFontSize(context, 0.04),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,  // White text for contrast
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Package ID:",
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white70,  // Slightly faded white
                                      ),
                                    ),
                                    Text(
                                      controller.subscripted[index].packageId,
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white,  // White text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "User ID:",
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white70,  // Slightly faded white
                                      ),
                                    ),
                                    Text(
                                      controller.subscripted[index].userId,
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white,  // White text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Days:",
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white70,  // Slightly faded white
                                      ),
                                    ),
                                    Text(
                                      controller.subscripted[index].days.toString(),
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white,  // White text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Actual Amount:",
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white70,  // Slightly faded white
                                      ),
                                    ),
                                    Text(
                                      "₹${controller.subscripted[index].actualAmount}",
                                      style: AppTextStyles.subheadingText.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white,  // White text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Offer Amount:",
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white70,  // Slightly faded white
                                      ),
                                    ),
                                    Text(
                                      "₹${controller.subscripted[index].offerAmount}",
                                      style: AppTextStyles.subheadingText.copyWith(
                                        fontSize: getResponsiveFontSize(context, 0.03),
                                        color: Colors.white,  // White text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Status: ${controller.subscripted[index].status == '1' ? 'Active' : 'Inactive'}",
                                    style: AppTextStyles.titleText.copyWith(
                                      fontSize: getResponsiveFontSize(context, 0.03),
                                      color: controller.subscripted[index].status == '1' 
                                        ? Colors.greenAccent 
                                        : Colors.redAccent,  // Green for active, red for inactive
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 1),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, double opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(MembershipPage());
                        print("Upgrade Package button pressed");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,  // Blue color for the button
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Click to Upgrade Your Package',
                        style: AppTextStyles.headingText.copyWith(
                          fontSize: getResponsiveFontSize(context, 0.04),
                          color: Colors.white,  // White text color on the button
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
