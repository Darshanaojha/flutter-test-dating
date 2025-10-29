import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../Controllers/controller.dart';
import '../../../Models/RequestModels/update_profile_photo_request_model.dart';
import '../../../constants.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({super.key});

  @override
  EditPhotosPageState createState() => EditPhotosPageState();
}

class EditPhotosPageState extends State<EditPhotosPage> {
  Controller controller = Get.put(Controller());
  RxList<RxString> updatedImages = List.filled(6, "".obs).obs;
  RxList<File?> filePaths = <File?>[].obs;
  RxList<int> indexUpdated = <int>[].obs;

  @override
  void initState() {
    super.initState();
    intialize();
  }

  intialize() async {
    try {
      await controller.fetchAllHeadlines();
      await controller.fetchProfileUserPhotos();
      List<RxString> fetchedImages = controller.userPhotos?.images
              .map((image) => RxString(image))
              .toList() ??
          [];
      updatedImages.value = List.generate(
        6,
        (index) => index < fetchedImages.length ? fetchedImages[index] : "".obs,
      );
      filePaths.value = List.generate(6, (index) => null);
    } catch (e) {
      failure('Error', e.toString());
    }
  }

  bool isLoading = false;
  final picker = ImagePicker();

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        Get.snackbar('Permission Denied', "Camera permission is required to take photos.");
        return false;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // Permission is permanently denied or restricted, open app settings
      Get.snackbar(
        'Permission Required',
        "Camera permission has been permanently denied. Please enable it in app settings.",
        mainButton: TextButton(
          child: const Text("Open Settings"),
          onPressed: () {
            openAppSettings(); // This function from permission_handler opens the app's settings page
          },
        ),
        duration: const Duration(seconds: 5), // Keep the snackbar longer
      );
      return false;
    }
    return false; // Default case
  }


  Future<bool> requestGalleryPermission() async {
    Permission photoPermission;
    if (Platform.isAndroid) {
      // Consider adding checks for Android SDK version if you need very granular control
      // For API 33+
      // final androidInfo = await DeviceInfoPlugin().androidInfo;
      // if (androidInfo.version.sdkInt >= 33) {
      // photoPermission = Permission.photos;
      // } else {
      // photoPermission = Permission.storage;
      // }
      // However, permission_handler often abstracts this.
      // Starting with Permission.photos is generally a good approach.
      photoPermission = Permission.photos;
    } else {
      photoPermission = Permission.photos; // For iOS
    }

    var status = await photoPermission.status;

    if (status.isGranted || (status.isLimited && Platform.isIOS)) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      Get.snackbar(
        'Permission Required',
        "Gallery permission has been permanently denied. Please enable it in app settings.",
        mainButton: TextButton(
          child: const Text("Open Settings"),
          onPressed: () {
            openAppSettings();
          },
        ),
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    // Request the permission (photos first)
    status = await photoPermission.request();

    if (status.isGranted || (status.isLimited && Platform.isIOS)) {
      return true;
    } else if (Platform.isAndroid && (status.isDenied || status.isPermanentlyDenied)) {
      // If photos permission denied on Android, try storage as a fallback for older versions
      // or if the user somehow still gets here after a .photos denial.
      // (This fallback might be less necessary with modern permission_handler versions
      // but can be a safeguard).
      var storageStatus = await Permission.storage.status;
      if (storageStatus.isPermanentlyDenied || storageStatus.isRestricted) {
        Get.snackbar(
          'Permission Required',
          "Storage permission has been permanently denied. Please enable it in app settings.",
          mainButton: TextButton(onPressed: openAppSettings, child: const Text("Open Settings")),
          duration: const Duration(seconds: 5),
        );
        return false;
      }
      storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }
    }

    // If all attempts fail or permission is denied
    Get.snackbar(
      'Permission Denied',
      "Gallery permission is required. You can enable it in app settings.",
      mainButton: TextButton(
        child: const Text("Open Settings"),
        onPressed: () {
          openAppSettings();
        },
      ),
      duration: const Duration(seconds: 5),
    );
    return false;
  }


  Future<void> pickImage(int index, ImageSource source) async {
    try {
      bool permissionGranted = false;
      if (source == ImageSource.camera) {
        permissionGranted = await requestCameraPermission();
      } else if (source == ImageSource.gallery) {
        permissionGranted = await requestGalleryPermission();
      }

      if (!permissionGranted) {
        return; // Exit if permission was not granted
      }

      // Permission is granted, proceed to pick image
      final pickedFile = await picker.pickImage(source: source);
      print('Picked file: ${pickedFile?.path}');
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        print('Image file exists: ${await imageFile.exists()}');
        filePaths[index] = imageFile;
        filePaths.refresh(); // Assuming this is an Obx list

        final compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 50,
        );

        if (compressedImage != null) {
          String base64Image = base64Encode(compressedImage);
          updatedImages[index].value = base64Image; // Assuming RxString
          updatedImages.refresh(); // Assuming this is an Obx list

          if (!indexUpdated.contains(index)) indexUpdated.add(index);
          indexUpdated.refresh(); // Assuming this is an Obx list

          // success("Success", "Image updated successfully"); // Consider if Get.snackbar is better
          Get.snackbar("Success", "Image updated successfully");
        } else {
          // failure("Error", "Image compression failed");
          Get.snackbar("Error", "Image compression failed");
        }
      } else {
        // failure("Error", "No image selected");
        // Get.snackbar("Info", "No image selected"); // User might have just cancelled the picker
      }
    } catch (e) {
      // failure("Error", e.toString());
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
      print("Error picking image: $e");
    }

    // After picking and updating image (or failing)
    print('UpdatedImages: ${updatedImages.map((e) => e.value.isNotEmpty ? "ImagePresent" : "Empty").toList()}');
    print('FilePaths: $filePaths');
    print('IndexUpdated: $indexUpdated');
  }

  Future<void> deletePhoto(int index) async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      updatedImages[index].value = "";
      filePaths[index] = null;
      indexUpdated.removeWhere((i) => i == index);
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
                // SizedBox(width: 16),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     deletePhoto(index);
                //   },
                //   style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.inactiveColor),
                //   child: Text("Delete",
                //       style: AppTextStyles.buttonText
                //           .copyWith(fontSize: getResponsiveFontSize(0.03))),
                // ),
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
            Text(
              "Choose a source for your photo:",
              style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),
            ),
            Center(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      pickImage(index, ImageSource.camera);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor),
                    child: Text("Camera",
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      pickImage(
                        index,
                        ImageSource.gallery,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor),
                    child: Text("Gallery",
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                  ),
                ],
              ),
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
          child: Image.network(
            imagePath,
            fit: BoxFit.contain,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
          ),
        );
      },
    );
  }

  void showFullPhotoDialogFile(File imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Image.file(
            imagePath,
            fit: BoxFit.contain,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
          ),
        );
      },
    );
  }

  void onSubmit() async {
    UpdateProfilePhotoRequest updateProfilePhotoRequest =
        UpdateProfilePhotoRequest();

    print('updatedImages length is ${updatedImages.length}');

    for (int i = 0; i < updatedImages.length; i++) {
      if (updatedImages[i].value.isEmpty) {
        failure("Error", "Please upload all 6 photos.");
        return;
      }
      if (!indexUpdated.contains(i)) {
        String imageUrl = updatedImages[i].toString();
        String base64Image = await getAndSetImageAsBase64(imageUrl);
        print('returned string at $i is $base64Image');
        if (base64Image.isNotEmpty) {
          if (i == 0) {
            updateProfilePhotoRequest.img1 = base64Image;
          }
          if (i == 1) {
            updateProfilePhotoRequest.img2 = base64Image;
          }
          if (i == 2) {
            updateProfilePhotoRequest.img3 = base64Image;
          }
          if (i == 3) {
            updateProfilePhotoRequest.img4 = base64Image;
          }
          if (i == 4) {
            updateProfilePhotoRequest.img5 = base64Image;
          }
          if (i == 5) {
            updateProfilePhotoRequest.img6 = base64Image;
          }
        }
      }
    }
    for (int i in indexUpdated) {
      if (i == 0) {
        updateProfilePhotoRequest.img1 = updatedImages[0].value;
      }
      if (i == 1) {
        updateProfilePhotoRequest.img2 = updatedImages[1].value;
      }
      if (i == 2) {
        updateProfilePhotoRequest.img3 = updatedImages[2].value;
      }
      if (i == 3) {
        updateProfilePhotoRequest.img4 = updatedImages[3].value;
      }
      if (i == 4) {
        updateProfilePhotoRequest.img5 = updatedImages[4].value;
      }
      if (i == 5) {
        updateProfilePhotoRequest.img6 = updatedImages[5].value;
      }
    }
    print('first image is ${updateProfilePhotoRequest.img1}');
    print('second image is ${updateProfilePhotoRequest.img2}');
    print('third image is ${updateProfilePhotoRequest.img3}');
    print('four image is ${updateProfilePhotoRequest.img4}');
    print('fifth image is ${updateProfilePhotoRequest.img5}');
    print('sixth image is ${updateProfilePhotoRequest.img6}');
    if (updateProfilePhotoRequest.validate()) {
      controller.updateprofilephoto(updateProfilePhotoRequest);
    } else {
      failure("FAILED", "Please fill in all required fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double fontSize = screenSize.width * 0.03;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                        color: AppColors.progressColor,
                      ),
                    )
                  : Obx(() => GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: updatedImages.length,
                        itemBuilder: (context, index) {
                          RxString imageUrl = updatedImages.length > index
                              ? updatedImages[index]
                              : "".obs;
                          File? file = filePaths.length > index
                              ? filePaths[index]
                              : null;

                          if (indexUpdated.contains(index) && file != null) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () => showFullPhotoDialogFile(file),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file,
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
                          } else if (imageUrl.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () =>
                                    showFullPhotoDialog(imageUrl.value),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl.value,
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
                      )),
            ),
            SizedBox(height: screenSize.height * 0.03),
            Obx(() => Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          (controller.headlines.length > 11)
                              ? controller.headlines[11].title
                              : controller.headlines.isNotEmpty
                                  ? controller.headlines.first.title
                                  : "Loading Title...",
                          style: AppTextStyles.titleText.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          (controller.headlines.length > 11)
                              ? controller.headlines[11].description
                              : controller.headlines.isNotEmpty
                                  ? controller.headlines.first.description
                                  : "Loading Description...",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 10),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.safetyGuidelines.isEmpty
                        ? Center(
                            child: SpinKitCircle(
                              size: 35.0,
                              color: AppColors.progressColor,
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            child: Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.safetyGuidelines.length,
                                itemBuilder: (context, index) {
                                  var guideline =
                                      controller.safetyGuidelines[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning,
                                            color: AppColors.iconColor,
                                            size: fontSize,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  guideline.title,
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: fontSize - 2,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  guideline.description,
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: fontSize - 2,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.06),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 1),
                      colors: AppColors.gradientColor),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text('Submit', style: AppTextStyles.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getAndSetImageAsBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;
        String base64Image = base64Encode(imageBytes);
        return base64Image;
      } else {
        failure(
            "Failed to load image.", " Status code: ${response.statusCode}");
        return '';
      }
    } catch (e) {
      failure("Error downloading or processing the image:", e.toString());
      return '';
    }
  }
}
