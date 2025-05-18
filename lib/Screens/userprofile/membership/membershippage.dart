import 'package:dating_application/Screens/userprofile/plans/planspage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  MembershipPageState createState() => MembershipPageState();
}

class MembershipPageState extends State<MembershipPage>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
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
            Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(controller.userPhotos!.img1),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Membership Services',
                    style: AppTextStyles.titleText,
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
          child: AnimatedButton(
            text: 'Starting from ₹99',
            onPress: () {
              Get.to(PricingPage());
            },
            transitionType: TransitionType.LEFT_TO_RIGHT,
            textStyle: AppTextStyles.buttonText.copyWith(fontSize: 12),
            backgroundColor: AppColors.favouriteColor,
            selectedBackgroundColor: AppColors.activeColor,
            borderRadius: 16.0,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            animationDuration: Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  Widget buildMembershipServiceItem({
    required String title,
    required bool free,
    required bool paid,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DecoratedBoxTransition(
        decoration: decorationTween.animate(_animationController),
        child: Card(
          color: AppColors.secondaryColor,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textStyle,
                ),
                Row(
                  children: [
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
      ),
    );
  }
}
