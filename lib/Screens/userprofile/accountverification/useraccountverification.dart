import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/Screens/navigationbar/unsubscribenavigation.dart';
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
  bool isSubmitting = false;

  late Future<bool> _fetchVerification;

  @override
  void initState() {
    super.initState();
    _fetchVerification = initializeApp();
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
      controller.requestToVerifyAccount.identifyNo = controller.verificationtype.id;
    }
  }

  Future<String> encodeImageToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  void submitVerification() async {
    if (!isSelfieTaken) {
      failure('Error', "Please take a selfie to complete the verification.");
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await controller.verifyuseraccount(controller.requestToVerifyAccount);

    setState(() {
      isSubmitting = false;
    });

    bool isPackageSubscribed = await controller.userPackage();
    controller.fetchProfile();

    if (isPackageSubscribed) {
      Get.offAll(NavigationBottomBar());
    } else {
      Get.offAll(Unsubscribenavigation());
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
        future: _fetchVerification,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                size: 150.0,
                color: AppColors.progressColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Verification Type: ${controller.verificationtype.title}",
                          style: AppTextStyles.titleText.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description: ${controller.verificationtype.description}',
                          style: AppTextStyles.textStyle.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),

                        // Selfie image or camera button
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
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                          ),

                        const SizedBox(height: 50),

                        // Submit Verification button
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.textColor,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: (!isSelfieTaken || isSubmitting) ? null : submitVerification,
                              child: isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : Text(
                                      isSelfieTaken ? 'Submit Verification' : 'Take Selfie First',
                                      style: AppTextStyles.textStyle.copyWith(
                                        color: isSelfieTaken ? AppColors.primaryColor : Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: Text('No data available', style: TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }
}
