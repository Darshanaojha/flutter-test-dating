import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

import '../../../Controllers/controller.dart';
import '../../../Models/RequestModels/update_profile_photo_request_model.dart';
import '../../../constants.dart';
import '../userprofilepage.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({super.key});

  @override
  EditPhotosPageState createState() => EditPhotosPageState();
}

class EditPhotosPageState extends State<EditPhotosPage> {
  Controller controller = Get.put(Controller());
  
  List<File> images = []; 
  bool isLoading = false;
  final picker = ImagePicker();
  
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    images = controller.userRegistrationRequest.photos
        .where((photo) => photo.isNotEmpty)
        .map((photo) => File(photo))
        .toList();
  }


  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      Get.snackbar('Permission Denied', "Camera permission denied");
    }
  }


  Future<void> requestGalleryPermission() async {
    var status = await Permission.photos.request();
    if (status.isDenied) {
      Get.snackbar('Permission Denied', "Gallery permission denied");
    }
  }

  Future<void> pickImage(int index, ImageSource source) async {
    if (source == ImageSource.camera) {
      await requestCameraPermission();
    } else if (source == ImageSource.gallery) {
      await requestGalleryPermission();
    }

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 50,
      );

      if (compressedImage != null) {
        String base64Image = base64Encode(compressedImage);
        if (index < controller.userRegistrationRequest.photos.length) {
          controller.userRegistrationRequest.photos[index] = base64Image;
        } else {
          controller.userRegistrationRequest.photos.add(base64Image);
        }
        if (index < images.length) {
          images[index] = imageFile;
        } else {
          images.add(imageFile);
        }

        setState(() {}); 
      } else {
        Get.snackbar("Error", "Image compression failed");
      }
    }
  }

  Future<void> deletePhoto(int index) async {
    setState(() {
      isLoading = true; 
    });

    setState(() {
      controller.userRegistrationRequest.photos
          .removeAt(index); 
      images.removeAt(index); 
      isLoading = false;
    });
  }


  void showDeleteOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete this photo?",
              style: AppTextStyles.bodyText
                  .copyWith(fontSize: getResponsiveFontSize(0.03)),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor),
                  child: Text("Cancel",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePhoto(index);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inactiveColor),
                  child: Text("Delete",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(index, ImageSource.gallery); 
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeColor),
                  child: Text("Edit",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void showPhotoSelectionDialog(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose a source for your photo:",  style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(index, ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor),
                  child: Text("Camera",style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(
                        index, ImageSource.gallery,);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor),
                  child: Text("Gallery",style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showFullPhotoDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
          ),
        );
      },
    );
  }

  void onSubmit() {
    controller.updateProfilePhotoRequest = UpdateProfilePhotoRequest(
      img1: controller.userRegistrationRequest.photos.isNotEmpty
          ? controller.userRegistrationRequest.photos[0]
          : '',
      img2: controller.userRegistrationRequest.photos.length > 1
          ? controller.userRegistrationRequest.photos[1]
          : '',
      img3: controller.userRegistrationRequest.photos.length > 2
          ? controller.userRegistrationRequest.photos[2]
          : '',
      img4: controller.userRegistrationRequest.photos.length > 3
          ? controller.userRegistrationRequest.photos[3]
          : '',
      img5: controller.userRegistrationRequest.photos.length > 4
          ? controller.userRegistrationRequest.photos[4]
          : '',
      img6: controller.userRegistrationRequest.photos.length > 5
          ? controller.userRegistrationRequest.photos[5]
          : '',
    );
    controller.updateprofilephoto(controller.updateProfilePhotoRequest);
    Get.to(UserProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize =MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Photos",
            style: AppTextStyles.titleText
                .copyWith(fontSize: getResponsiveFontSize(0.03))),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isLoading
                  ? Center(
                      child: SpinKitCircle(
                        size: 150.0,
                        color: AppColors.acceptColor,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 6, 
                      itemBuilder: (context, index) {
                        if (index < images.length) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () =>
                                  showFullPhotoDialog(images[index].path),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.more_vert,
                                        color: AppColors.activeColor),
                                    onPressed: () => showDeleteOptions(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () => showPhotoSelectionDialog(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.add_a_photo,
                                      size: 40, color: AppColors.activeColor),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
            SizedBox(height: screenSize.height*0.03),
            Text(
              "Guidelines and Ground Rules:",
              style: AppTextStyles.subheadingText,
            ),
            SizedBox(height: screenSize.height*0.05),
            Text(
              "1. Upload only your own photos.\n"
              "2. Avoid offensive or inappropriate images.\n"
              "3. Maintain good quality photos for better impression.\n"
              "4. Be respectful to others in your photos.\n",
              style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),
            ),
            SizedBox(height: screenSize.height*0.06),
            Center(
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Submit', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
