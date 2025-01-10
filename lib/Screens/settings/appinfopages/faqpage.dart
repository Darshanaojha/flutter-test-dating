import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../Controllers/controller.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  FaqPageState createState() => FaqPageState();
}

class FaqPageState extends State<FaqPage> with SingleTickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  List<bool> _expandedFaqs = [];
  late Future<bool> _fetchfaqs;
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  @override
  void initState() {
    super.initState();
    _fetchfaqs = initializeApp();
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

  Future<bool> initializeApp() async {
    controller.faq.clear();
    await controller.fetchAllFaq();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: _fetchfaqs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                    "assets/animations/notificationanimation.json",
                    repeat: true,
                    reverse: true),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (_expandedFaqs.isEmpty) {
                _expandedFaqs =
                    List.generate(controller.faq.length, (_) => false);
              }

              return ListView.builder(
                itemCount: controller.faq.length,
                itemBuilder: (context, index) {
                  final faq = controller.faq[index];
                  return DecoratedBoxTransition(
                    decoration: decorationTween.animate(_animationController),
                    child: Card(
                      color: AppColors.accentColor,
                      margin: EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(faq.question,style: TextStyle(fontSize: 9),),
                            trailing: IconButton(
                              icon: Icon(
                                _expandedFaqs[index]
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandedFaqs[index] = !_expandedFaqs[index];
                                });
                              },
                            ),
                          ),
                          if (_expandedFaqs[index])
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                faq.ans,
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text('No FAQs available', style: TextStyle(fontSize: 18)),
            );
          },
        ),
      ),
    );
  }
}
