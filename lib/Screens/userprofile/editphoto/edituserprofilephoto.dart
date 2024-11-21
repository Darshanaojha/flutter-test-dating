import 'dart:convert';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../Models/RequestModels/update_profile_photo_request_model.dart';
import '../../../constants.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({super.key});

  @override
  EditPhotosPageState createState() => EditPhotosPageState();
}

class EditPhotosPageState extends State<EditPhotosPage> {
  Controller controller = Get.put(Controller());
  List<String> photos = [];
  List<File> images = []; 
  bool isLoading = false;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  final picker = ImagePicker();

  // Function to request Camera permission
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
      photos.removeAt(index);
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
                  child: Text("Cancel",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePhoto(index); // Delete the photo
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.inactiveColor),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.activeColor),
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

  void updateProfilePhotoRequestFromPhotos() {
    List<String> updatedPhotos = List.from(photos);

    while (updatedPhotos.length < 6) {
      updatedPhotos.add('');
    }

    controller.updateProfilePhotoRequest = UpdateProfilePhotoRequest(
      img1: updatedPhotos.length > 0 ? updatedPhotos[0] : '',
      img2: updatedPhotos.length > 1 ? updatedPhotos[1] : '',
      img3: updatedPhotos.length > 2 ? updatedPhotos[2] : '',
      img4: updatedPhotos.length > 3 ? updatedPhotos[3] : '',
      img5: updatedPhotos.length > 4 ? updatedPhotos[4] : '',
      img6: updatedPhotos.length > 5 ? updatedPhotos[5] : '',
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
            height: MediaQuery.of(context).size.height *
                0.7, 
          ),
        );
      },
    );
  }

  void showPhotoSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source",
            style: AppTextStyles.titleText
                .copyWith(fontSize: getResponsiveFontSize(0.03))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera, color: AppColors.iconColor),
              title: Text("Camera",
                  style: AppTextStyles.bodyText
                      .copyWith(fontSize: getResponsiveFontSize(0.03))),
              onTap: () {
                Navigator.pop(context);
                pickImage(images.length,
                    ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album, color: AppColors.iconColor),
              title: Text("Gallery",
                  style: AppTextStyles.bodyText
                      .copyWith(fontSize: getResponsiveFontSize(0.03))),
              onTap: () {
                Navigator.pop(context);
                pickImage(images.length,
                    ImageSource.gallery); 
              },
            ),
          ],
        ),
      ),
    );
  }

  void onNextButtonPressed() {
    if (controller.userRegistrationRequest.photos.isNotEmpty) {
      updateProfilePhotoRequestFromPhotos();
      controller.updateprofilephoto(controller.updateProfilePhotoRequest);

      Get.to(UserProfilePage());
    } else {
      Get.snackbar("Error", "Please add at least one photo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Photos",
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
                        color: AppColors.activeColor,
                        size: 150.0,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 8.0, 
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount:
                          images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == images.length) {
                      
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: 40, color: AppColors.activeColor),
                              onPressed: () => showPhotoSelectionDialog(),
                            ),
                          );
                        } else {
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
                                      images[
                                          index], // Display the selected image
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onPressed: () => showDeleteOptions(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
            Text(
              "Impress the people around you with your best photo!",
              style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textColor,
                  fontSize: getResponsiveFontSize(0.03)),
            ),
            SizedBox(height: 20),
            Text("Guidelines and Ground Rules:",
                style: AppTextStyles.subheadingText),
            SizedBox(height: 8),
            Text(
              "1. Upload only your own photos.\n"
              "2. Avoid offensive or inappropriate images.\n"
              "3. Maintain good quality photos for better impression.\n"
              "4. Be respectful to others in your photos.\n",
              style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),
            ),
            Center(
              child: ElevatedButton(
                onPressed:
                    onNextButtonPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Submit', style: AppTextStyles.buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
