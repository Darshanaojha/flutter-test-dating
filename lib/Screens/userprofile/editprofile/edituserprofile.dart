import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../editphoto/edituserprofilephoto.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import SpinKit

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  List<String> photos = [
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
  ];

  List<bool> isImageLoading = [true, true, true, true];

  TextEditingController userNameController =
      TextEditingController(text: "John Doe");
  TextEditingController dobController =
      TextEditingController(text: "1990-01-01");
  TextEditingController genderController = TextEditingController(text: "Male");
  TextEditingController emailController = TextEditingController(text: "email");
  TextEditingController sexualityController =
      TextEditingController(text: "Straight");
  TextEditingController aboutController =
      TextEditingController(text: "Love outdoor adventures, books, and music.");
  List<String> desires = ["Travel", "Fitness"];
  TextEditingController interestsController =
      TextEditingController(text: "Hiking, Cooking, Reading");

  bool hideMeOnFlame = true;
  bool incognitoMode = false;
  bool optOutOfPingNote = true;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  final TextEditingController desireController = TextEditingController();

  bool isLoading = false; // Track loading state
  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    loadImages();
  }

  // Custom method to load images and stop the loading spinner
  void loadImages() {
    for (int i = 0; i < photos.length; i++) {
      // Create an ImageStream for each image
      final image = AssetImage(photos[i]);
      final imageStream = image.resolve(ImageConfiguration());

      // Listen for when the image has finished loading
      imageStream.addListener(
        ImageStreamListener(
          (ImageInfo info, bool synchronousCall) {
            // Update the loading state to false when image is loaded
            setState(() {
              isImageLoading[i] = false;
            });
          },
          onError: (exception, stackTrace) {
            // Handle errors (e.g., if image is not found)
            setState(() {
              isImageLoading[i] = false; // Stop the loading indicator on error
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Card(
                    color: AppColors.secondaryColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Photos",
                              style: AppTextStyles.textStyle.copyWith(
                                  fontSize: getResponsiveFontSize(0.03))),
                          SizedBox(height: 5),
                          Container(
                            height: 350,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // GestureDetector to handle tap on image
                                      GestureDetector(
                                        onTap: () => showFullImageDialog(
                                            context, photos[index]),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            photos[index],
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.45,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // Show spinner if image is still loading
                                      if (isImageLoading[index])
                                        SpinKitCircle(
                                          color: AppColors
                                              .activeColor, // Your color here
                                          size: 50.0,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Get.to(EditPhotosPage());
                            },
                            icon: Icon(Icons.edit, color: AppColors.iconColor),
                            label: Text('Edit Photos',
                                style: AppTextStyles.buttonText.copyWith(
                                    color: AppColors.iconColor,
                                    fontSize: getResponsiveFontSize(0.04))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 16,
                    child: Row(
                      children: [
                        // Preview button
                        Container(
                          height: 40, // Decrease height of the button
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              // Preview action here
                            },
                            backgroundColor: AppColors.buttonColor,
                            icon: Icon(Icons.visibility,
                                color: AppColors.textColor,
                                size: 18), // Adjust icon size
                            label: Text(
                              'Preview',
                              style: AppTextStyles.textStyle.copyWith(
                                  fontSize: getResponsiveFontSize(
                                      0.03)), // Adjust font size for the label
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust border radius if needed
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Save button
                        Container(
                          height: 40, // Decrease height of the button
                          child: FloatingActionButton.extended(
                            onPressed: () async {
                              // Start loading
                              setState(() {
                                isLoading = true;
                              });

                              // Simulate a save action (could be an API call)
                              await Future.delayed(Duration(seconds: 2));

                              // Stop loading
                              setState(() {
                                isLoading = false;
                              });

                              // Show success message (could be replaced with an actual save action)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profile Saved!')),
                              );
                            },
                            backgroundColor: AppColors.buttonColor,
                            icon: Icon(Icons.save,
                                color: AppColors.textColor,
                                size: 18), // Adjust icon size
                            label: Text(
                              'Save',
                              style: AppTextStyles.textStyle.copyWith(
                                  fontSize: getResponsiveFontSize(
                                      0.03)), // Adjust font size for the label
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust border radius if needed
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Editable User Info Cards
              isLoading
                  ? Center(
                      child: SpinKitCircle(
                        color: AppColors.activeColor, // Customize color
                        size: 50.0, // Size of spinner
                      ),
                    )
                  : Column(
                      children: [
                        InfoField(
                          label: 'Name',
                          controller: userNameController,
                        ),
                        InfoField(
                          label: 'Date of Birth',
                          controller: dobController,
                        ),
                        InfoField(
                          label: 'Gender',
                          controller: genderController,
                        ),
                        InfoField(
                          label: 'Email',
                          controller: emailController,
                        ),
                        InfoField(
                          label: 'Sexuality',
                          controller: sexualityController,
                        ),
                        InfoField(
                          label: 'About',
                          controller: aboutController,
                        ),
                        InfoField(
                          label: 'Interests',
                          controller: interestsController,
                        ),

                        // Desires Section with Chips
                        Card(
                          color: AppColors.secondaryColor,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Desires",
                                    style: AppTextStyles.subheadingText
                                      ..copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.03))),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 8.0,
                                  children: desires
                                      .map((desire) => Chip(
                                            label: Text(desire,
                                                style: AppTextStyles.bodyText
                                                    .copyWith(
                                                        fontSize:
                                                            getResponsiveFontSize(
                                                                0.03))),
                                            backgroundColor:
                                                AppColors.chipColor,
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: desireController,
                                        cursorColor: AppColors
                                            .cursorColor, // White cursor color
                                        decoration: InputDecoration(
                                          labelText: 'Add Desire',
                                          labelStyle: AppTextStyles.buttonText
                                              .copyWith(
                                                  fontSize:
                                                      getResponsiveFontSize(
                                                          0.03)),
                                          filled: true,
                                          fillColor: AppColors.formFieldColor,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add,
                                          color: AppColors.iconColor),
                                      onPressed: () {
                                        if (desireController.text.isNotEmpty) {
                                          setState(() {
                                            desires.add(desireController.text);
                                            desireController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

              SizedBox(height: 16),

              // Privacy Settings
              Card(
                color: AppColors.secondaryColor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Privacy Settings",
                          style: AppTextStyles.subheadingText
                              .copyWith(fontSize: getResponsiveFontSize(0.03))),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Hide me on Flame",
                        value: hideMeOnFlame,
                        onChanged: (val) => setState(() => hideMeOnFlame = val),
                      ),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Incognito Mode",
                        value: incognitoMode,
                        onChanged: (val) => setState(() => incognitoMode = val),
                      ),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Opt out of Ping + Note",
                        value: optOutOfPingNote,
                        onChanged: (val) =>
                            setState(() => optOutOfPingNote = val),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showFullImageDialog(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close dialog on tap
          child: Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // Adjust the image size to fit
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
      );
    },
  );
}

// Custom Widget for User Info
class InfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const InfoField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }

    return Card(
      color: AppColors.secondaryColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.buttonText
                    .copyWith(fontSize: getResponsiveFontSize(0.03))),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              cursorColor: AppColors.cursorColor, // White cursor color
              style: AppTextStyles.bodyText
                  .copyWith(fontSize: getResponsiveFontSize(0.03)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.formFieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Divider(color: AppColors.textColor),
          ],
        ),
      ),
    );
  }
}

// Privacy Toggle Widget
class PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  PrivacyToggle(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyText
                .copyWith(fontSize: getResponsiveFontSize(0.03))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.activeColor,
          inactiveThumbColor: AppColors.inactiveColor,
        ),
      ],
    );
  }
}
