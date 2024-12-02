import 'package:dating_application/Screens/userprofile/plans/planspage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../Controllers/controller.dart';
import '../../../constants.dart';
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  MembershipPageState createState() => MembershipPageState();
}

class MembershipPageState extends State<MembershipPage> {
  Controller controller = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
   // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Membership'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo section taking up 40% of the screen height
            Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(controller.userPhotos!.img1),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Membership services section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Membership Services',
                    style: AppTextStyles.subheadingText,
                  ),
                  SizedBox(height: 10),
                  buildMembershipServiceItem(
                    title: 'Skip Profile',
                    free: true,
                    paid: true,
                  ),
                  buildMembershipServiceItem(
                    title: 'Send Likes',
                    free: false,
                    paid: true,
                  ),
                  buildMembershipServiceItem(
                    title: 'Explore Globally',
                    free: true,
                    paid: true,
                  ),
                  buildMembershipServiceItem(
                    title: 'Free Message + Note (1 per day)',
                    free: false,
                    paid: true,
                  ),
                  buildMembershipServiceItem(
                    title: 'See Who Likes You',
                    free: false,
                    paid: true,
                  ),
                  buildMembershipServiceItem(
                    title: 'Chatting',
                    free: false,
                    paid: true,
                  ),
                  SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),

   
      floatingActionButton: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () {
              // Handle membership purchase logic here
              Get.to(PricingPage());
            },
            label: Text(
              'Starting from ₹99',
              style: AppTextStyles.buttonText.copyWith(fontSize: 14),
            ),
            icon: Icon(
              Icons.payment,
              color: AppColors.textColor,
            ),
            backgroundColor: AppColors.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Function to build membership service item
  Widget buildMembershipServiceItem({
    required String title,
    required bool free,
    required bool paid,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: AppColors.secondaryColor,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.textStyle,
              ),
              Row(
                children: [
                  // Free service mark
                  if (free)
                    Icon(
                      Icons.check,
                      color: AppColors.acceptColor,
                      size: 20,
                    ),
                  if (!free)
                    Icon(
                      Icons.close,
                      color: AppColors.deniedColor,
                      size: 20,
                    ),
                  SizedBox(width: 10),
                  // Paid service mark
                  if (paid)
                    Icon(
                      Icons.check,
                      color: AppColors.acceptColor,
                      size: 20,
                    ),
                  if (!paid)
                    Icon(
                      Icons.close,
                      color: AppColors.deniedColor,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
