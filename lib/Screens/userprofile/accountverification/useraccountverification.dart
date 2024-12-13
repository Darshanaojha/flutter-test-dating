import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class PhotoVerificationPage extends StatefulWidget {
  const PhotoVerificationPage({super.key});

  @override
  PhotoVerificationPageState createState() => PhotoVerificationPageState();
}

class PhotoVerificationPageState extends State<PhotoVerificationPage> {
  Controller controller = Get.put(Controller());
  final ImagePicker _picker = ImagePicker();
  bool isSelfieTaken = false;
  String selfiePath = '';
  bool isLoading = true;
  late Future<bool> _fetchverification;

  @override
  void initState() {
    super.initState();
    _fetchverification = initializeApp();
  }

  Future<bool> initializeApp() async {
    await controller.fetchAllverificationtype();
    setState(() {
      isLoading = false;
    });
    return true;
  }

  void takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selfiePath = image.path;
        isSelfieTaken = true;
      });
      final base64Image = await encodeImageToBase64(image.path);
      print('Base64 Encoded Image: $base64Image');
      controller.requestToVerifyAccount.identifyImage = base64Image;
      controller.requestToVerifyAccount.identifyNo =
          controller.verificationtype.id;
    }
  }

  Future<String> encodeImageToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  void submitVerification() {
    if (isSelfieTaken) {
      controller.verifyuseraccount(controller.requestToVerifyAccount);
    } else {
      failure('Error', "Please take a selfie to complete the verification.");
    }
  }

  void showFullImageDialog(String photoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.file(
            File(photoPath),
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _fetchverification,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                size: 150.0,
                color: AppColors.progressColor,
              ),
            );
          }
          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', // Show error message
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          // Data loaded successfully
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Verification Type: ${controller.verificationtype.title}",
                        style: AppTextStyles.titleText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Description: ${controller.verificationtype.description}',
                        style: AppTextStyles.bodyText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      if (isSelfieTaken)
                        GestureDetector(
                          onTap: () => showFullImageDialog(selfiePath),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(selfiePath),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: takePhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.textColor,
                            size: 30,
                          ),
                        ),
                      SizedBox(height: 50),
                      Center(
                        child: ElevatedButton(
                          onPressed: submitVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.requestToVerifyAccount
                                    .identifyImage.isNotEmpty
                                ? AppColors.buttonColor
                                : AppColors.activeColor,
                          ),
                          child: Text('Submit Verification',
                              style: AppTextStyles.buttonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Fallback case if no data or something unexpected occurs
          return Center(
            child: Text('No data available', style: TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }
}
