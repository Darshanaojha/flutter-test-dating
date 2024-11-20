
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/ResponseModels/get_all_desires_model_response.dart';
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

  bool hideMeOnFlame = true;
  bool incognitoMode = false;
  bool optOutOfPingNote = true;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  bool isLoading = false;
  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  final Controller controller = Get.put(Controller());

  List<Category> categories = [];
  // RxList<Desire> desiresList = <Desire>[].obs;

  List<String> interestsList = [];

  // Future<void> fetchDesires() async {
  //   final success = await controller.fetchDesires();
  //   if (success) {
  //     categories = controller.categories;
  //     for (var category in categories) {
  //       desiresList.addAll(
  //           category.desires); // Assuming `category.desire` is a List<Desire>
  //     }
  //     // for (var element in desiresList) {
  //     //   print(element);
  //     // }
  //   }
  // }

  TextEditingController interestController = TextEditingController();

  // Method to handle adding interest to the list
  void addInterest() {
    Get.snackbar('intrest', interestsList.toString());
    String newInterest = interestController.text.trim();
    if (newInterest.isNotEmpty) {
      setState(() {
        interestsList.add(newInterest);
      });
      interestController.clear();
    }
  }

  void deleteInterest(int index) {
    setState(() {
      interestsList.removeAt(index);
    });
  }

  List<String> desiresList = [];

  TextEditingController desireController = TextEditingController();

  void addDesire() {
    String newDesire = desireController.text.trim();
    if (newDesire.isNotEmpty) {
      setState(() {
        desiresList.add(newDesire);
      });
      desireController.clear();
    }
  }

  void deleteDesire(int index) {
    setState(() {
      desiresList.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    loadImages();
    // fetchDesires();
  }

  void loadImages() {
    for (int i = 0; i < photos.length; i++) {
      final image = AssetImage(photos[i]);
      final imageStream = image.resolve(ImageConfiguration());

      imageStream.addListener(
        ImageStreamListener(
          (ImageInfo info, bool synchronousCall) {
            setState(() {
              isImageLoading[i] = false;
            });
          },
          onError: (exception, stackTrace) {
            setState(() {
              isImageLoading[i] = false;
            });
          },
        ),
      );
    }
  }

  void onUserNameChanged(String value) {
    controller.userProfileUpdateRequest.name = value;
  }

  void onDobChanged(String value) {
    controller.userProfileUpdateRequest.dob = value;
    print("Date of Birth: $value");
  }

  void onGenderChanged(String value) {
    controller.userProfileUpdateRequest.gender = value;
    print("Gender: $value");
  }

  void onEmailChanged(String value) {
    controller.userProfileUpdateRequest.emailAlerts = value;
    print("Email: $value");
  }

  void onSexualityChanged(String value) {
    controller.userProfileUpdateRequest.subGender = value;
    print("Sexuality: $value");
  }

  void onAboutChanged(String value) {
    controller.userProfileUpdateRequest.bio = value;
    print("About: $value");
  }

  void onInterestsChanged(String value) {
    // controller.userProfileUpdateRequest.interest=value;
    print("Interests: $value");
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
                          SizedBox(
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
                        SizedBox(
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
                        SizedBox(
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
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          label: 'Date of Birth',
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          label: 'Gender',
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          label: 'Email',
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          label: 'Sexuality',
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          label: 'About',
                          onChanged: onUserNameChanged,
                        ),
                        Card(
                          color: AppColors.primaryColor,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Interests",
                                    style: AppTextStyles.subheadingText
                                      ..copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.03))),

                                SizedBox(height: 10),
                                // Wrap the list of interests with Chips
                                Wrap(
                                  spacing: 8.0,
                                  children: List.generate(interestsList.length,
                                      (index) {
                                    return Chip(
                                      label: Text(
                                        interestsList[index],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      backgroundColor: AppColors.chipColor,
                                      // Add a delete icon inside the Chip
                                      deleteIcon: Icon(Icons.delete,
                                          color: AppColors.inactiveColor),
                                      onDeleted: () => deleteInterest(
                                          index), // Delete on press
                                    );
                                  }),
                                ),
                                SizedBox(height: 10),
                                // Row with TextField and Add button
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: interestController,
                                        cursorColor: AppColors.cursorColor,
                                        decoration: InputDecoration(
                                          labelText: 'Add Interest',
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
                                          color: AppColors.activeColor),
                                      onPressed:
                                          addInterest, // Add interest when pressed
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Desires Section with Chips
                        Card(
                          color: AppColors.primaryColor,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Desires",
                                    style: AppTextStyles.subheadingText
                                        .copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.03))),

                                SizedBox(height: 10),

                                // Wrap widget to display the list of desires as Chips
                                Wrap(
                                  spacing: 8.0,
                                  children: List.generate(desiresList.length,
                                      (index) {
                                    return Chip(
                                      label: Text(
                                        desiresList[
                                            index], // Display desire text
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      backgroundColor: AppColors.chipColor,
                                      deleteIcon: Icon(Icons.delete,
                                          color: AppColors.inactiveColor),
                                      onDeleted: () =>
                                          deleteDesire(index), // Delete desire
                                    );
                                  }),
                                ),

                                SizedBox(height: 10),

                                // Row with TextField and Add button
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            desireController, // Connect TextField to controller
                                        cursorColor: AppColors.cursorColor,
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
                                          color: AppColors.activeColor),
                                      onPressed:
                                          addDesire, // Call addDesire method on button press
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
  final dynamic onChanged;
  const InfoField({super.key, required this.label, required this.onChanged});

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
              onChanged: onChanged,
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

  const PrivacyToggle(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged});

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
