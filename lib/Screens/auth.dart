import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/register_subpag/useremailnameinput.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CombinedAuthScreen extends StatefulWidget {
  const CombinedAuthScreen({super.key});

  @override
  State<CombinedAuthScreen> createState() => _CombinedAuthScreenState();
}

class _CombinedAuthScreenState extends State<CombinedAuthScreen>
    with SingleTickerProviderStateMixin {
  bool showLogin = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Get.put(Controller());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.favouriteColor,
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(fontSize: fontSize * 1.2),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.22),
          child: Column(
            children: [
              SizedBox(height: 16),
              // Add your logo here
              SizedBox(
                height: 160,
                width: 160,
                child: Lottie.asset(
                  'assets/animations/LoginPageheart.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10),
              // Toggle buttons
              Container(
                width: size.width * 0.5,
                height: size.height * 0.04,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showLogin = true;
                          });
                          _animationController.forward();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                showLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: showLogin
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 1.25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showLogin = false;
                          });
                          _animationController.forward();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                !showLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: !showLogin
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: AuthCard(
        title: showLogin ? 'Login' : 'Register',
        animation: _animation,
        child: showLogin ? const Login() : const UserInputPage(),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Animation<double> animation;
  final double? maxHeight;

  const AuthCard({
    super.key,
    required this.title,
    required this.child,
    required this.animation,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.03;

    return FadeTransition(
      opacity: animation,
      child: Center(
        child: Container(
          width: size.width * 1.0,
          height: size.height * 1.0,
          constraints: BoxConstraints(
              maxWidth: 500, maxHeight: maxHeight ?? size.height),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
