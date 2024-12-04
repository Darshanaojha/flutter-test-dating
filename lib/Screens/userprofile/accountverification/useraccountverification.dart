import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  initializeApp() async {
    await controller.fetchAllverificationtype();
    setState(() {
      isLoading = false;
    });
  }

  // Take a photo using the camera
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
          controller.verificationtype!.id;
    }
  }

  // Function to encode the image to Base64
  Future<String> encodeImageToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  // Submit the verification
  void submitVerification()  {
    if (isSelfieTaken) {
      controller
          .verifyuseraccount(controller.requestToVerifyAccount);
          
    } else {
      failure('Error', "Please take a selfie to complete the verification.");
    }
  }

  // Show full image in a dialog
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
      appBar: AppBar(title: Text('Account Verification')),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while data is being fetched
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      "Verification Type: ${controller.verificationtype?.title ?? 'Loading...'}", // Handle null safely
                      style: AppTextStyles.titleText,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    // Description
                    Text(
                      'Description: ${controller.verificationtype?.description ?? 'Loading...'}', // Handle null safely
                      style: AppTextStyles.bodyText,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),

                    // Photo Option: Selfie (Centered)
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
                          Icons.camera_alt, // Camera icon
                          color: AppColors.textColor, // Color for the icon
                          size: 30, // Icon size
                        ),
                      ),

                    SizedBox(height: 50),

                    // Centered Submit Button
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
}
