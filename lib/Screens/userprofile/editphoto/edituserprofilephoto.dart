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
import '../userprofilepage.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({super.key});

  @override
  EditPhotosPageState createState() => EditPhotosPageState();
}

class EditPhotosPageState extends State<EditPhotosPage> {
  Controller controller = Get.put(Controller());
  RxList<RxString> updatedImages = <RxString>[].obs;
  RxList<File> filePaths = <File>[].obs;
  RxList<int> indexUpdated = <int>[].obs;

  @override
  void initState() {
    super.initState();
    intialize();
  }

  intialize() async {
    try {
      updatedImages.value = controller.userPhotos!.images
          .map((image) => RxString(image))
          .toList();
      filePaths.value =
          List.generate(updatedImages.length, (index) => File('')).obs;
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
    try {
      if (source == ImageSource.camera) {
        await requestCameraPermission();
      } else if (source == ImageSource.gallery) {
        await requestGalleryPermission();
      }
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        filePaths[index] = imageFile;
        final compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 50,
        );

        if (compressedImage != null) {
          String base64Image = base64Encode(compressedImage);
          if (index < updatedImages.length) {
            updatedImages[index] = base64Image.obs;
            indexUpdated.add(index);
          } else {
            updatedImages.add(base64Image.obs);
          }

          success("Success", "Image updated successfully");
        } else {
          failure("Error", "Image compression failed");
        }
      } else {
        failure("Error", "No image selected");
      }
    } catch (e) {
      failure("Error", e.toString());
    }
  }

  Future<void> deletePhoto(int index) async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      updatedImages.removeAt(index);
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
            Text(
              "Choose a source for your photo:",
              style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),
            ),
            Row(
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

    for (int i = 0; i < updatedImages.length; i++) {
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

    controller.updateprofilephoto(updateProfilePhotoRequest);
    Get.to(UserProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
                          RxString? imageUrl = updatedImages[index];
                          print('photo index is $index and url is $imageUrl');
                          if (indexUpdated.contains(index)) {
                            print('file path at $index is ${filePaths[index]}');
                          } else {
                            print('file path not at $index');
                          }
                          if (index < updatedImages.length) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () => indexUpdated.contains(index)
                                    ? showFullPhotoDialogFile(filePaths[index])
                                    : showFullPhotoDialog(imageUrl.value),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: indexUpdated.contains(index)
                                          ? Image.file(
                                              filePaths[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : Image.network(
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
            Text(
              "Guidelines and Ground Rules:",
              style: AppTextStyles.subheadingText,
            ),
            SizedBox(height: screenSize.height * 0.05),
            Text(
              "1. Upload only your own photos.\n"
              "2. Avoid offensive or inappropriate images.\n"
              "3. Maintain good quality photos for better impression.\n"
              "4. Be respectful to others in your photos.\n",
              style: AppTextStyles.bodyText.copyWith(
                  color: Colors.grey, fontSize: getResponsiveFontSize(0.03)),
            ),
            SizedBox(height: screenSize.height * 0.06),
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
