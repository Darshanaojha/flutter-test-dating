import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constants.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({super.key});

  @override
  EditPhotosPageState createState() => EditPhotosPageState();
}

class EditPhotosPageState extends State<EditPhotosPage> {
  List<String> photos = [
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
  ];
  double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }
  final picker = ImagePicker();
  bool isLoading = false; // Track loading state
  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  // Function to pick an image from the gallery or camera
  Future<void> pickImage(ImageSource source) async {
    setState(() {
      isLoading = true; // Show loading spinner when picking image
    });

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        photos.add(pickedFile.path); // Add the new photo to the list
        isLoading = false; // Hide loading spinner once image is picked
      });
    } else {
      setState(() {
        isLoading = false; // Hide loading spinner if no image is picked
      });
    }
  }

  // Function to delete a photo
  Future<void> deletePhoto(int index) async {
    setState(() {
      isLoading = true; // Show loading spinner when deleting
    });

    setState(() {
      photos.removeAt(index); // Remove the selected photo
      isLoading = false; // Hide loading spinner after deletion
    });
  }

  // Show bottom sheet with delete and cancel options
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
              style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: AppTextStyles.buttonText.copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePhoto(index); // Delete the photo
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Delete", style: AppTextStyles.buttonText.copyWith(fontSize: getResponsiveFontSize(0.03)),),
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
            height: MediaQuery.of(context).size.height *
                0.7, // Adjust height as needed
          ),
        );
      },
    );
  }

  // Show the photo selection dialog (camera or gallery)
  void showPhotoSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source", style: AppTextStyles.titleText.copyWith(fontSize: getResponsiveFontSize(0.03)),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera, color: AppColors.iconColor),
              title: Text("Camera", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera); // Pick image from camera
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album, color: AppColors.iconColor),
              title: Text("Gallery", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery); // Pick image from gallery
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Photos", style: AppTextStyles.titleText.copyWith(fontSize: getResponsiveFontSize(0.03)),),
        backgroundColor: AppColors.primaryColor, // Your primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Grid
            Expanded(
              child: isLoading // Show spinner if loading
                  ? Center(
                      child: SpinKitCircle(
                        color: AppColors.activeColor, // Color for spinner
                        size: 150.0, // Size of spinner
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of columns in the grid
                        crossAxisSpacing: 8.0, // Spacing between columns
                        mainAxisSpacing: 8.0, // Spacing between rows
                        childAspectRatio:
                            1.0, // Aspect ratio of each photo cell
                      ),
                      itemCount:
                          photos.length + 1, // One extra for the "Add" button
                      itemBuilder: (context, index) {
                        if (index == photos.length) {
                          // Show the "Add" button at the bottom
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: 40, color: AppColors.activeColor),
                              onPressed: showPhotoSelectionDialog,
                            ),
                          );
                        } else {
                          // Show each photo with a 3-dot icon
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () => showFullPhotoDialog(photos[index]),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(photos[
                                          index]), // Use File widget to load the image
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

            // Motivational Line for the photo
            Text(
              "Impress the people around you with your best photo!",
              style:
                  AppTextStyles.bodyText.copyWith(color: AppColors.textColor,fontSize: getResponsiveFontSize(0.03)),
            ),

            SizedBox(height: 20),

            // Guidelines and Ground Rules
            Text(
              "Guidelines and Ground Rules:",
              style: AppTextStyles.subheadingText,
            ),
            SizedBox(height: 8),
            Text(
              "1. Upload only your own photos.\n"
              "2. Avoid offensive or inappropriate images.\n"
              "3. Maintain good quality photos for better impression.\n"
              "4. Be respectful to others in your photos.\n",
              style: AppTextStyles.bodyText.copyWith(color: Colors.grey,fontSize: getResponsiveFontSize(0.03)),
            ),
          ],
        ),
      ),
    );
  }
}
