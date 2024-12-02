
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
    controller.fetchAllsubscripted();
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
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: controller.fetchAllsubscripted(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), 
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
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
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.subscripted[index].packageTitle,
                                        style: AppTextStyles.headingText.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.04),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Package ID: ${controller.subscripted[index].packageId}",
                                        style: AppTextStyles.textStyle.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "User ID: ${controller.subscripted[index].userId}",
                                        style: AppTextStyles.textStyle.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Days: ${controller.subscripted[index].days}",
                                        style: AppTextStyles.textStyle.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Actual Amount: ₹${controller.subscripted[index].actualAmount}",
                                        style: AppTextStyles.subheadingText.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Offer Amount: ₹${controller.subscripted[index].offerAmount}",
                                        style: AppTextStyles.subheadingText.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Status: ${controller.subscripted[index].status == '1' ? 'Active' : 'Inactive'}",
                                        style: AppTextStyles.titleText.copyWith(
                                          fontSize: getResponsiveFontSize(context, 0.03),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
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
                            backgroundColor: Colors.blue,
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
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Default return in case of unexpected state
          return Center(
            child: Text("Unexpected state"),
          );
        },
      ),
    );
  }
}