import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
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
  late final DecorationTween decorationTween;

  @override
  void initState() {
    super.initState();
    _fetchfaqs = initializeApp();

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(16.0),
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
        borderRadius: BorderRadius.circular(16.0),
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

  Future<bool> initializeApp() async {
    controller.faq.clear();
    await controller.fetchAllFaq();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.04;
    double cardRadius = 18;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: Text('FAQs',
            style: AppTextStyles.titleText.copyWith(fontSize: fontSize * 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: FutureBuilder(
          future: _fetchfaqs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  "assets/animations/notificationanimation.json",
                  repeat: true,
                  reverse: true,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: fontSize * 1.1),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (_expandedFaqs.isEmpty) {
                _expandedFaqs =
                    List.generate(controller.faq.length, (_) => false);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: AppTextStyles.headingText.copyWith(
                      fontSize: fontSize * 1.3,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.faq.length,
                      itemBuilder: (context, index) {
                        final faq = controller.faq[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientBackgroundList,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(cardRadius),
                              onTap: () {
                                setState(() {
                                  _expandedFaqs[index] = !_expandedFaqs[index];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        child: Icon(
                                          _expandedFaqs[index]
                                              ? Icons.question_answer
                                              : Icons.help_outline,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      title: Text(
                                        faq.question,
                                        style: AppTextStyles.labelText.copyWith(
                                          fontSize: fontSize * 1.08,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: Icon(
                                        _expandedFaqs[index]
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _expandedFaqs[index] =
                                              !_expandedFaqs[index];
                                        });
                                      },
                                    ),
                                    AnimatedCrossFade(
                                      firstChild: SizedBox.shrink(),
                                      secondChild: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18.0, vertical: 12),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.13),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            faq.ans,
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize,
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                            ),
                                          ),
                                        ),
                                      ),
                                      crossFadeState: _expandedFaqs[index]
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: Duration(milliseconds: 300),
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
                ],
              );
            }
            return Center(
              child: Text('No FAQs available',
                  style: TextStyle(fontSize: fontSize * 1.1)),
            );
          },
        ),
      ),
    );
  }
}
