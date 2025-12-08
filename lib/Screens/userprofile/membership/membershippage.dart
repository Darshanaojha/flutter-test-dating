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
    controller.fetchAllPackages();
    controller.fetchProfile();
    controller.fetchProfileUserPhotos();

    print("Membership Page - User Data and Photos:");
    print(controller.userPhotos);
    print(controller.userData);

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
void dispose() {
  _animationController.dispose();   // 🔥 IMPORTANT
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //print(controller);
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Make background transparent for gradient
        elevation: 0, // Remove default shadow
        centerTitle: true,
        title: Text(
          'Membership',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
      body: SingleChildScrollView(
  child: Obx(() {
    // Only this part rebuilds when isLoading changes
    return controller.isLoading.value
        ? const Text("Loading... coz I am not a wizard")
        : Column(
            children: [
              Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: const EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        height: screenHeight * 0.5,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                controller.userPhotos?.img1 ?? ""),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Our Membership Services',
                      style: AppTextStyles.titleText
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    buildMembershipServiceItem(
                        title: 'Skip Profile', free: true, paid: true),
                    buildMembershipServiceItem(
                        title: 'Send Likes', free: false, paid: true),
                    buildMembershipServiceItem(
                        title: 'Explore Globally', free: true, paid: true),
                    buildMembershipServiceItem(
                        title: 'Free Message + Note (1 per day)',
                        free: false,
                        paid: true),
                    buildMembershipServiceItem(
                        title: 'See Who Likes You', free: false, paid: true),
                    buildMembershipServiceItem(
                        title: 'Chatting', free: false, paid: true),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ],
          );
  }),
),

      floatingActionButton: Padding(
        padding: EdgeInsets.all(22.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.reversedGradientColor,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white, // White outline
              width: 2.0, // Thickness of the outline
            ),
          ),
          child: AnimatedButton(
            text: 'Starting from ₹99',
            onPress: () {
              if (controller.userData.first.accountVerificationStatus != "1") {
                controller.showVerificationDialog(context);
                return;
              }
              Get.to(PricingPage());
            },
            transitionType: TransitionType.LEFT_TO_RIGHT,
            textStyle: AppTextStyles.buttonText.copyWith(fontSize: 12),
            backgroundColor: Colors.transparent,
            selectedBackgroundColor:
                Colors.transparent, // Keep transparent for gradient effect
            selectedTextColor: Colors.white,
            borderRadius: 16.0,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            animationDuration: Duration(milliseconds: 300),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                    // if (free)
                    //   Icon(
                    //     Icons.check,
                    //     color: AppColors.acceptColor,
                    //     size: 20,
                    //   ),
                    // if (!free)
                    //   Icon(
                    //     Icons.close,
                    //     color: AppColors.deniedColor,
                    //     size: 20,
                    //   ),
                    SizedBox(width: 10),
                    if (paid)
                      Icon(
                        Icons.check,
                        color: Colors.green,
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
