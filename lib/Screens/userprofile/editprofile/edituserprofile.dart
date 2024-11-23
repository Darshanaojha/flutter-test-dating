import 'dart:async';
import 'dart:math';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_desires_model_response.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../../../constants.dart';
import '../editphoto/edituserprofilephoto.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import SpinKit

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final Controller controller = Get.put(Controller());
  late List<String> photos;
  RxBool isLatLongFetched = false.obs;
  RxList<String> genderIds = <String>[].obs;
  List<bool> isImageLoading = [true, true, true, true];
  Timer? debounce;
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

  List<Category> categories = [];
  RxList<Desire> desiresList = <Desire>[].obs;

  RxList<Gender> genders = <Gender>[].obs;
  RxList<SubGenderRequest> subGenders = <SubGenderRequest>[].obs;
  Rx<String> selectedOption = ''.obs;

  // Future<void> fetchSubGender(SubGenderRequest request) async {
  //   await Future.delayed(Duration(seconds: 2));
  //   // Add dummy sub-gender data for this example
  //   subGenders.add(SubGenderRequest(genderId: request.genderId));
  // }

  List<String> interestsList = [];
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;
  TextEditingController interestController = TextEditingController();
  RxList<String> UpdatedselectedInterests = <String>[].obs;
  void addInterest() {
    Get.snackbar('intrest', UpdatedselectedInterests.toString());
    String newInterest = interestController.text.trim();
    if (newInterest.isNotEmpty) {
      setState(() {
        UpdatedselectedInterests.add(newInterest);
      });
      interestController.clear();
    }
  }

  void updateUserInterests() {
    controller.userRegistrationRequest.interest =
        UpdatedselectedInterests.join(', ');
  }

  void deleteInterest(int index) {
    setState(() {
      UpdatedselectedInterests.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    photos = controller.userRegistrationRequest.photos;
    debounce?.cancel();
    isLatLongFetched.value = false;
    fetchData();
    controller.fetchDesires();
    controller.fetchPreferences();
    controller.fetchGenders();
    loadImages();
    genderIds.addAll(controller.genders.map((gender) => gender.id));
    for (String genderId in genderIds) {
      controller.fetchSubGender(SubGenderRequest(genderId: genderId));
    }

    preferencesSelectedOptions.value =
        List<bool>.filled(controller.preferences.length, false);
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

  void onNickNameChanged(String value) {
    controller.userProfileUpdateRequest.nickname = value;
  }

  void onGenderChanged(String value) {
    controller.userProfileUpdateRequest.gender = value;
    print("Gender: $value");
  }

  void onSexualityChanged(String value) {
    controller.userProfileUpdateRequest.subGender = value;
    print("Sexuality: $value");
  }

  void onAboutChanged(String value) {
    controller.userProfileUpdateRequest.bio = value;
    print("About: $value");
  }

  void onAddressChnaged(String value) {
    controller.userProfileUpdateRequest.address = value;
    print('address: $value');
  }

  void onCityChanged(String value) {
    controller.userProfileUpdateRequest.city = value;

    isLatLongFetched.value = false;

    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }
    debounce = Timer(Duration(milliseconds: 1000), () {
      fetchLatLong();
    });
  }

  void onLatitudeChnage(String value) {
    controller.userProfileUpdateRequest.latitude = value;
  }

  void onLongitudeChnage(String value) {
    controller.userProfileUpdateRequest.longitude = value;
  }

  void onInterestsChanged(String value) {
    updateUserInterests();
    print("Interests: $value");
  }

  Future<void> fetchLatLong() async {
    try {
      print(controller.userRegistrationRequest.city);
      List<Location> locations =
          await locationFromAddress(controller.userProfileUpdateRequest.city);
      print(locations.first.toString());
      if (locations.isNotEmpty) {
        print('not empty');
        controller.userProfileUpdateRequest.latitude =
            locations.first.latitude.toString();
        controller.userProfileUpdateRequest.longitude =
            locations.first.longitude.toString();
        isLatLongFetched.value = true;
        print('set to true');
      } else {
        failure('correct ', 'No location found for the provided address..');
      }
    } catch (e) {
      print('location error -> ${e.toString()}');
      failure('', 'Error fetching location: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05;
    double bodyFontSize = screenWidth * 0.03;
    double chipFontSize = screenWidth * 0.03;
    final selectedGender = Rx<Gender?>(null);
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
                    color: AppColors.primaryColor,
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
                                      if (isImageLoading[index])
                                        SpinKitCircle(
                                          color: AppColors.activeColor,
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
                        SizedBox(
                          height: 40,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            backgroundColor: AppColors.buttonColor,
                            icon: Icon(Icons.visibility,
                                color: AppColors.textColor, size: 18),
                            label: Text(
                              'Preview',
                              style: AppTextStyles.textStyle.copyWith(
                                  fontSize: getResponsiveFontSize(0.03)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        SizedBox(
                          height: 40,
                          child: FloatingActionButton.extended(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                isLoading = false;
                              });

                              controller.updateProfile(
                                  controller.userProfileUpdateRequest);
                              success('Updated', 'Profile Saved!');
                            },
                            backgroundColor: AppColors.buttonColor,
                            icon: Icon(Icons.save,
                                color: AppColors.textColor, size: 18),
                            label: Text(
                              'Save',
                              style: AppTextStyles.textStyle.copyWith(
                                  fontSize: getResponsiveFontSize(0.03)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              isLoading
                  ? Center(
                      child: SpinKitCircle(
                        color: AppColors.activeColor,
                        size: 50.0,
                      ),
                    )
                  : Column(
                      children: [
                        InfoField(
                          initialValue:
                              controller.userRegistrationRequest.name.isNotEmpty
                                  ? controller.userRegistrationRequest.name
                                  : controller.userProfileUpdateRequest.name,
                          label: 'Name',
                          onChanged: onUserNameChanged,
                        ),
                        InfoField(
                          initialValue:
                              controller.userRegistrationRequest.dob.isNotEmpty
                                  ? controller.userRegistrationRequest.dob
                                  : controller.userProfileUpdateRequest.dob,
                          label: 'Date of Birth',
                          onChanged: onDobChanged,
                        ),
                        InfoField(
                          initialValue: controller
                                  .userRegistrationRequest.nickname.isNotEmpty
                              ? controller.userRegistrationRequest.nickname
                              : controller.userProfileUpdateRequest.nickname,
                          label: 'Nick name',
                          onChanged: onNickNameChanged,
                        ),
                        InfoField(
                          initialValue:
                              controller.userRegistrationRequest.bio.isNotEmpty
                                  ? controller.userRegistrationRequest.bio
                                  : controller.userProfileUpdateRequest.bio,
                          label: 'About',
                          onChanged: onAboutChanged,
                        ),
                        InfoField(
                          initialValue: controller
                                  .userRegistrationRequest.address.isNotEmpty
                              ? controller.userRegistrationRequest.address
                              : controller.userProfileUpdateRequest.address,
                          label: 'Address',
                          onChanged: onAddressChnaged,
                        ),
                        InfoField(
                          initialValue:
                              controller.userRegistrationRequest.city.isNotEmpty
                                  ? controller.userRegistrationRequest.city
                                  : controller.userProfileUpdateRequest.city,
                          label: 'City',
                          onChanged: onCityChanged,
                        ),
                        Obx(() {
                          if (isLatLongFetched.value) {
                            return Column(
                              children: [
                                InfoField(
                                  initialValue: controller
                                          .userRegistrationRequest
                                          .latitude
                                          .isNotEmpty
                                      ? controller
                                          .userRegistrationRequest.latitude
                                      : controller
                                          .userProfileUpdateRequest.latitude,
                                  label: 'Latitude',
                                  onChanged: onLatitudeChnage,
                                ),
                                InfoField(
                                  initialValue: controller
                                          .userRegistrationRequest
                                          .longitude
                                          .isNotEmpty
                                      ? controller
                                          .userRegistrationRequest.longitude
                                      : controller
                                          .userProfileUpdateRequest.longitude,
                                  label: 'Longitude',
                                  onChanged: onLongitudeChnage,
                                ),
                              ],
                            );
                          } else {
                            return isLoading
                                ? Center(
                                    child: SpinKitCircle(
                                      size: 90,
                                      color: AppColors.activeColor,
                                    ), // Show loading spinner while fetching
                                  )
                                : Container(); // Empty container if lat-long is not fetched
                          }
                        }),

                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Text('Gender'),
                                  Obx(() {
                                    if (controller.genders.isEmpty) {
                                      return Center(
                                        child: SpinKitCircle(
                                          size: 90,
                                          color: AppColors.acceptColor,
                                        ),
                                      );
                                    }
                                    return SingleChildScrollView(
                                      child: Column(
                                        children:
                                            controller.genders.map((gender) {
                                          return RadioListTile<Gender?>(
                                            title: Text(
                                              gender.title,
                                              style: AppTextStyles.bodyText
                                                  .copyWith(
                                                fontSize: bodyFontSize,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                            value: gender,
                                            groupValue: selectedGender.value,
                                            onChanged: (Gender? value) {
                                              selectedGender.value = value;

                                              // Safe parsing using tryParse
                                              final parsedGenderId =
                                                  int.tryParse(value?.id ?? '');

                                              if (parsedGenderId != null) {
                                                controller
                                                        .userProfileUpdateRequest
                                                        .gender =
                                                    parsedGenderId.toString();
                                              } else {
                                                controller
                                                    .userProfileUpdateRequest
                                                    .gender = '';
                                              }
                                             
                                                controller.fetchSubGender(
                                                    SubGenderRequest(
                                                        genderId: parsedGenderId.toString()));
                                          
                                            },
                                            activeColor: AppColors.buttonColor,
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Obx(() {
                          // Handle loading state for both genders and subGenders
                          // if (controller.genders.isEmpty || controller.subGenders.isEmpty) {
                          //   return Center(
                          //     child: SpinKitCircle(
                          //       size: 90,
                          //       color: AppColors.acceptColor,
                          //     ),
                          //   );
                          // }

                          // Return the Card with form elements
                          return Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .start, // Align content to top
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Ensure left alignment
                                children: [
                                  // Relationship Type Dropdown
                                  DropdownButtonFormField<String>(
                                    value: controller.userRegistrationRequest
                                            .lookingFor.isEmpty
                                        ? null
                                        : controller
                                            .userRegistrationRequest.lookingFor,
                                    decoration: InputDecoration(
                                      labelText: 'Relationship Type',
                                      labelStyle:
                                          AppTextStyles.labelText.copyWith(
                                        fontSize: titleFontSize,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: AppColors.textColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text(
                                          'Serious Relationship',
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: '2',
                                        child: Text(
                                          'Hookup',
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.userRegistrationRequest
                                            .lookingFor = value;
                                      }
                                    },
                                    iconEnabledColor: AppColors.textColor,
                                    iconDisabledColor: AppColors.inactiveColor,
                                  ),
                                  SizedBox(height: 5),
                                  Column(
                                    children: List.generate(
                                        controller.subGenders.length, (index) {
                                      return RadioListTile<String>(
                                        title: Text(
                                          controller.subGenders[index].title,
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                        value: controller.subGenders[index].id,
                                        groupValue: selectedOption.value,
                                        onChanged: (String? value) {
                                          selectedOption.value = value ?? '';
                                          controller.userProfileUpdateRequest
                                              .subGender = value ?? '';
                                        },
                                        activeColor: AppColors.buttonColor,
                                        contentPadding: EdgeInsets.zero,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        Obx(() {
                          if (controller.preferences.isEmpty) {
                            return Center(
                              child: SpinKitCircle(
                                size: 90,
                                color: AppColors.acceptColor,
                              ),
                            );
                          }

                          // Ensure preferencesSelectedOptions has the same length as preferences
                          if (preferencesSelectedOptions.length !=
                              controller.preferences.length) {
                            preferencesSelectedOptions.value =
                                List<bool>.filled(
                                    controller.preferences.length, false);
                          }

                          return Card(
                            color: AppColors.primaryColor,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Selected preferences",
                                    style:
                                        AppTextStyles.subheadingText.copyWith(
                                      fontSize: 18, // Customize font size
                                      color: AppColors.textColor,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                      height:
                                          20), // Space between title and list

                                  // ListView.builder without Expanded (use shrinkWrap)
                                  ListView.builder(
                                    shrinkWrap: true, // Prevent overflow issues
                                    physics:
                                        NeverScrollableScrollPhysics(), // Prevent scrolling of ListView if inside scrollable parent
                                    itemCount: controller.preferences.length,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        title: Text(
                                          controller.preferences[index].title,
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                        value:
                                            preferencesSelectedOptions[index],
                                        onChanged: (bool? value) {
                                          preferencesSelectedOptions[index] =
                                              value ?? false;
                                        },
                                        activeColor: AppColors.buttonColor,
                                        checkColor: Colors.white,
                                        contentPadding: EdgeInsets.zero,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

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
                                  children: List.generate(
                                      UpdatedselectedInterests.length, (index) {
                                    return Chip(
                                      label: Text(
                                        UpdatedselectedInterests[index],
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
                                          labelText: 'update Interest',
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
                        buildRelationshipStatusInterestStep(
                            context, MediaQuery.of(context).size),
                      ],
                    ),

              SizedBox(height: 16),

              // Privacy Settings
              Card(
                color: AppColors.primaryColor,
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

Widget buildRelationshipStatusInterestStep(
    BuildContext context, Size screenSize) {
  // Initialize controller inside build method
  Controller controller = Get.put(Controller());

  // Categories for relationship and kinks
  final relationshipCategory = controller.categories.firstWhere(
    (category) => category.category == 'Relationship',
    orElse: () => Category(category: 'Relationship', desires: []),
  );

  final kinksCategory = controller.categories.firstWhere(
    (category) => category.category == 'Kinks',
    orElse: () => Category(category: 'Kinks', desires: []),
  );

  List<String> options = [
    ...relationshipCategory.desires.map((desire) => desire.title),
    ...kinksCategory.desires.map((desire) => desire.title)
  ];

  // Reactive variables
  RxList<bool> selectedOptions = List.filled(options.length, false).obs;
  RxList<String> selectedStatus = <String>[].obs;
  RxList<int> selectedDesireIds = <int>[].obs;

  // Updates selected desires and desire IDs
  void updateSelectedStatus() {
    selectedStatus.clear();
    selectedDesireIds.clear();

    for (int i = 0; i < selectedOptions.length; i++) {
      if (selectedOptions[i]) {
        selectedStatus.add(options[i]);
        selectedDesireIds.add(int.parse(controller.categories
            .firstWhere((category) => category.category == 'Relationship')
            .desires[i]
            .id));
      }
    }
    controller.userProfileUpdateRequest.desires = selectedDesireIds;
  }

  // Toggle selection for desires
  void handleChipSelection(int index) {
    selectedOptions[index] = !selectedOptions[index];
    updateSelectedStatus();
  }

  double screenWidth = screenSize.width;
  double titleFontSize = screenWidth * 0.05;
  double bodyFontSize = screenWidth * 0.03;
  double chipFontSize = screenWidth * 0.03;

  return Card(
    color: AppColors.primaryColor,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected desires section (Chips)
            Obx(() {
              return selectedStatus.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You selected:",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: selectedStatus.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(status),
                                  backgroundColor: AppColors.buttonColor,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: chipFontSize,
                                  ),
                                  deleteIcon: Icon(
                                    Icons.delete,
                                    color: AppColors.deniedColor,
                                  ),
                                  onDeleted: () {
                                    int index = options.indexOf(status);
                                    selectedOptions[index] = false;
                                    updateSelectedStatus(); // Update after deletion
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                  : Container();
            }),
            Text(
              "Select your Desires:",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 10),

            // List of all desires to select from
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(options.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      handleChipSelection(
                          index); // Handle desire selection/deselection
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Chip(
                        label: Text(options[index]),
                        backgroundColor: selectedOptions[index]
                            ? AppColors.buttonColor
                            : AppColors.formFieldColor,
                        labelStyle: TextStyle(
                          color: selectedOptions[index]
                              ? Colors.white
                              : AppColors.textColor,
                          fontSize: chipFontSize,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 20),

            // Reset and Cancel Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Confirm reset selections
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Confirm Reset',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to clear your selections?',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Reset all selections
                              selectedOptions.value = List.filled(
                                  options.length, false); // Reset selections
                              updateSelectedStatus(); // Update status after reset
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text(
                              'Confirm',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deniedColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: AppTextStyles.buttonSize,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
  final String initialValue;
  final String label;
  final dynamic onChanged;
  const InfoField(
      {super.key,
      required this.initialValue,
      required this.label,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth *
          scale; // Adjust this scale for different text elements
    }

    TextEditingController controller =
        TextEditingController(text: initialValue);
    return Card(
      color: AppColors.primaryColor,
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
              controller: controller,
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
