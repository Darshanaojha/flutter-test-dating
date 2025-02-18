import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class GenerateReferralPage extends StatefulWidget {
  const GenerateReferralPage({super.key});

  @override
  GenerateReferralPageState createState() => GenerateReferralPageState();
}

class GenerateReferralPageState extends State<GenerateReferralPage> {
  Controller controller = Get.put(Controller());
  final formKey = GlobalKey<FormState>();

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (int.tryParse(value) == null) {
      return 'Phone number must be a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.03;
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Referral Code'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Generate Referral Code and Refer to Your Friend',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80), // Curves the top-right corner
                  bottomLeft: Radius.circular(80)),
              child: Container(
                color: Colors.blueGrey[800],
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Referral Code Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ABC123',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: formKey,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter 10 digit phone number',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: validatePhoneNumber,
                onChanged: (value) {
                  controller.referalcoderequestmodel.mobile = value;
                },
              ),
            ),
            SizedBox(height: 20),
            Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: <Color>[
                    Color(0xff1f005c),
                    Color(0xff5b0060),
                    Color(0xff870160),
                    Color(0xffac255e),
                    Color(0xffca485c),
                    Color(0xffe16b5c),
                    Color(0xfff39060),
                    Color(0xffffb56b),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (controller.referalcoderequestmodel.validate()) {
                      controller
                          .requestreference(controller.referalcoderequestmodel);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: Colors.transparent,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Generate',
                  style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class LeafClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;

    // Start at the top-left corner
    path.lineTo(width * 0.85, 0);

    // Add curves to create leaf-like shape
    path.quadraticBezierTo(width, height / 4, width, height / 2);
    path.quadraticBezierTo(width, height * 0.75, width * 0.85, height);
    path.lineTo(width * 0.15, height);
    path.quadraticBezierTo(0, height * 0.75, 0, height / 2);
    path.quadraticBezierTo(0, height / 4, width * 0.15, 0);

    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
