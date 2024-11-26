
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  FaqPageState createState() => FaqPageState();
}

class FaqPageState extends State<FaqPage> {
  
Controller controller = Get.put(Controller());
  @override
  void initState() {
    super.initState();
    controller.fetchAllFaq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: controller.faq.isEmpty
            ? Center(child: SpinKitCircle(
              size: 90,
             color: AppColors.progressColor,
            )) 
            : ListView.builder(
                itemCount: controller.faq.length,
                itemBuilder: (context, index) {
                  final faq = controller.faq[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(faq.question),
                      subtitle: Text(faq.ans),
                      isThreeLine: true,
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Get.to(FaqDetailPage(faq: faq)); 
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}