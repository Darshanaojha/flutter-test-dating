import 'dart:async';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_country_response_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../../Models/RequestModels/user_profile_update_request_model.dart';
import '../../../Models/ResponseModels/ProfileResponse.dart';
import '../../../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../../../constants.dart';
import '../editphoto/edituserprofilephoto.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final Controller controller = Get.put(Controller());

  RxBool isLatLongFetched = false.obs;
  RxList<String> genderIds = <String>[].obs;
  List<bool> isImageLoading = [];
  Timer? debounce;
  bool hideMeOnFlame = true;
  bool incognitoMode = false;
  RxBool emailAlerts = true.obs;
  RxBool visibility_status = true.obs;
  bool optOutOfPingNote = true;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  bool isLoading = false;

  Country? selectedCountry;
  RxList<Gender> genders = <Gender>[].obs;
  RxList<SubGenderRequest> subGenders = <SubGenderRequest>[].obs;
  Rx<String> selectedOption = ''.obs;

  List<String> interestsList = [];
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;

  TextEditingController interestController = TextEditingController();
  RxList<String> UpdatedselectedInterests = <String>[].obs;
  void addInterest() {
    Get.snackbar('intrest', UpdatedselectedInterests.toString());
    String newInterest = interestController.text.trim();
    if (newInterest.isNotEmpty) {
      if (!UpdatedselectedInterests.contains(newInterest)) {
        UpdatedselectedInterests.add(newInterest);
        interestsList.add(newInterest);
        Get.snackbar('Interest Added', newInterest);
        interestController.clear();
      } else {
        Get.snackbar(
            'Duplicate Interest', 'This interest has already been added.');
      }
    }
  }

  void updateUserInterests() {
    controller.userProfileUpdateRequest.interest =
        UpdatedselectedInterests.join(', ');
  }

  void deleteInterest(int index) {
    UpdatedselectedInterests.removeAt(index);
  }

  late Future<bool> _fetchProfileFuture;
  @override
  void initState() {
    super.initState();
    intialize();
    _fetchProfileFuture = fetchAllData();
  }

  Future<bool> fetchAllData() async {
    controller.fetchProfile().then((value) {
      if (value == true) {
        controller.userProfileUpdateRequest.preferences =
            controller.userPreferences.map((p) => p.preferenceId).toList();
        controller.userProfileUpdateRequest.lang =
            controller.userLang.map((l) => l.langId).toList();
      }
      return false;
    });
    if (!await controller.fetchCountries()) return false;
    if (!await controller.fetchGenders()) return false;
    if (!await controller.fetchPreferences()) return false;
    if (!await controller.fetchlang()) return false;
    if (!await controller.fetchDesires()) return false;

    return true;
  }

  intialize() async {
    try {
      debounce?.cancel();
      isLatLongFetched.value = false;

      genderIds.addAll(controller.genders.map((gender) => gender.id));
      for (String genderId in genderIds) {
        controller.fetchSubGender(SubGenderRequest(genderId: genderId));
      }

      preferencesSelectedOptions.value =
          List<bool>.filled(controller.preferences.length, false);
      List<int> matchingIndexes = [];
      for (var p in controller.userPreferences) {
        int index = controller.preferences
            .indexWhere((preference) => preference.id == p.preferenceId);
        if (index != -1) {
          matchingIndexes.add(index);
          preferencesSelectedOptions[index] = true;
               
        }
      }
      print("Matching indexes: $matchingIndexes");
    } catch (e) {
      failure('Error', e.toString());
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
    // double chipFontSize = screenWidth * 0.03;
    final selectedGender = Rx<Gender?>(null);
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: FutureBuilder<bool>(
            future: _fetchProfileFuture, //controller.fetchProfile(),
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
                    'Error loading user profile: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    'No data available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return SingleChildScrollView(
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
                                  Text(
                                    "Photos",
                                    style: AppTextStyles.textStyle.copyWith(
                                      fontSize: getResponsiveFontSize(0.03),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    height: 350,
                                    child: controller.userPhotos!.images.isEmpty
                                        ? Center(
                                            child: Text("No images available"))
                                        : ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: controller
                                                .userPhotos!.images.length,
                                            itemBuilder: (context, index) {
                                              String imageUrl = controller
                                                  .userPhotos!.images[index];

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          showFullImageDialog(
                                                              context,
                                                              imageUrl), // show full image on tap
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          imageUrl,
                                                          fit: BoxFit.cover,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.45,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Center(
                                                              child: Icon(
                                                                  Icons.error),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await controller.fetchProfileUserPhotos();
                                      Get.to(EditPhotosPage());
                                    },
                                    icon: Icon(Icons.edit,
                                        color: AppColors.iconColor),
                                    label: Text(
                                      'Edit Photos',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: AppColors.iconColor,
                                        fontSize: getResponsiveFontSize(0.04),
                                      ),
                                    ),
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
                                          fontSize:
                                              getResponsiveFontSize(0.03)),
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
                                      await Future.delayed(
                                          Duration(seconds: 2));
                                      setState(() {
                                        isLoading = false;
                                      });
                                      print(
                                          'desires are : ${controller.userProfileUpdateRequest.desires}');
                                      UserProfileUpdateRequest
                                          userProfileUpdateRequest =
                                          UserProfileUpdateRequest(
                                        name: controller
                                                .userProfileUpdateRequest
                                                .name
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest.name
                                            : controller.userData.first.name,
                                        latitude: controller
                                                .userProfileUpdateRequest
                                                .latitude
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .latitude
                                            : controller
                                                .userData.first.latitude,
                                        longitude: controller
                                                .userProfileUpdateRequest
                                                .longitude
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .longitude
                                            : controller
                                                .userData.first.longitude,
                                        address: controller
                                                .userProfileUpdateRequest
                                                .address
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .address
                                            : controller.userData.first.address,
                                        countryId: controller
                                                .userProfileUpdateRequest
                                                .countryId
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .countryId
                                            : controller
                                                .userData.first.countryId,
                                        city: controller
                                                .userProfileUpdateRequest
                                                .city
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest.city
                                            : controller.userData.first.city,
                                        dob: controller.userProfileUpdateRequest
                                                .dob.isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest.dob
                                            : controller.userData.first.dob,
                                        nickname: controller
                                                .userProfileUpdateRequest
                                                .nickname
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .nickname
                                            : controller
                                                .userData.first.nickname,
                                        gender: controller
                                                .userProfileUpdateRequest
                                                .gender
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest.gender
                                            : controller.userData.first.gender,
                                        subGender: controller
                                                .userProfileUpdateRequest
                                                .subGender
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .subGender
                                            : controller
                                                .userData.first.subGender,
                                        lang: controller
                                            .userProfileUpdateRequest.lang,
                                        interest: controller
                                                .userProfileUpdateRequest
                                                .interest
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .interest
                                            : controller
                                                .userData.first.interest,
                                        bio: controller.userProfileUpdateRequest
                                                .bio.isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest.bio
                                            : controller.userData.first.bio,
                                        visibility: controller
                                            .userProfileUpdateRequest
                                            .visibility,
                                        emailAlerts: controller
                                                .userProfileUpdateRequest
                                                .emailAlerts
                                                .isNotEmpty
                                            ? controller
                                                .userProfileUpdateRequest
                                                .emailAlerts
                                            : controller
                                                .userData.first.emailAlerts,
                                        preferences: controller
                                            .userProfileUpdateRequest
                                            .preferences,
                                        desires: controller
                                            .userProfileUpdateRequest.desires,
                                      );
                                        List<int> selectedPreferences = [];
                                      for (int i = 0;
                                          i < preferencesSelectedOptions.length;
                                          i++) {
                                        if (preferencesSelectedOptions[i]) {
                                          selectedPreferences.add(int.parse(
                                              controller.preferences[i].id));
                                        }
                                      }
                                      controller.userProfileUpdateRequest
                                          .preferences = selectedPreferences;
                                      emailAlerts.value == true
                                          ? controller.userProfileUpdateRequest
                                              .emailAlerts = "1"
                                          : "0";
                                      visibility_status.value == true
                                          ? controller.userProfileUpdateRequest
                                              .visibility = '1'
                                          : '0';
                                      controller.updateProfile(
                                          userProfileUpdateRequest);
                                    },
                                    backgroundColor: AppColors.buttonColor,
                                    icon: Icon(Icons.save,
                                        color: AppColors.textColor, size: 18),
                                    label: Text(
                                      'Save',
                                      style: AppTextStyles.textStyle.copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.03)),
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
                              child: CircularProgressIndicator(
                                color: AppColors.progressColor,
                              ),
                            )
                          : Column(
                              children: [
                                InfoField(
                                  initialValue:
                                      controller.userData.first.name.isNotEmpty
                                          ? controller.userData.first.name
                                          : controller
                                              .userProfileUpdateRequest.name,
                                  label: 'Name',
                                  onChanged: onUserNameChanged,
                                ),
                                InfoField(
                                  initialValue: controller
                                          .userData.first.dob.isNotEmpty
                                      ? controller.userData.first.dob
                                      : controller.userProfileUpdateRequest.dob,
                                  label: 'Date of Birth',
                                  onChanged: onDobChanged,
                                ),
                                InfoField(
                                  initialValue: controller
                                          .userData.first.nickname.isNotEmpty
                                      ? controller.userData.first.nickname
                                      : controller
                                          .userProfileUpdateRequest.nickname,
                                  label: 'Nick name',
                                  onChanged: onNickNameChanged,
                                ),
                                InfoField(
                                  initialValue: controller
                                          .userData.first.bio.isNotEmpty
                                      ? controller.userData.first.bio
                                      : controller.userProfileUpdateRequest.bio,
                                  label: 'About',
                                  onChanged: onAboutChanged,
                                ),
                                // InfoField(
                                // initialValue: controller
                                //         .userData.first.username.isNotEmpty
                                //     ? controller.userData.first.username
                                //     : '',
                                //   label: 'User Name',
                                //   onChanged: onusernameChanged,
                                // ),
                                Obx(() {
                                  if (controller.countries.isEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.progressColor,
                                      ),
                                    );
                                  }
                                  Country? initialCountry =
                                      controller.countries.firstWhere(
                                    (country) =>
                                        country.id ==
                                        controller.userData.first.countryId,
                                  );

                                  return buildDropdown<Country>(
                                    "Country",
                                    controller.countries,
                                    initialCountry,
                                    selectedCountry,
                                    16.0,
                                    (Country? value) {
                                      controller.userProfileUpdateRequest
                                          .countryId = value?.id ?? '';
                                    },
                                    displayValue: (Country country) =>
                                        country.name,
                                  );
                                }),
                                InfoField(
                                  initialValue: controller
                                          .userData.first.address.isNotEmpty
                                      ? controller.userData.first.address
                                      : controller
                                          .userProfileUpdateRequest.address,
                                  label: 'Address',
                                  onChanged: onAddressChnaged,
                                ),
                                InfoField(
                                  initialValue:
                                      controller.userData.first.city.isNotEmpty
                                          ? controller.userData.first.city
                                          : controller
                                              .userProfileUpdateRequest.city,
                                  label: 'City',
                                  onChanged: onCityChanged,
                                ),
                                Obx(() {
                                  if (isLatLongFetched.value) {
                                    return Column(
                                      children: [
                                        InfoField(
                                          initialValue: controller.userData
                                                  .first.latitude.isNotEmpty
                                              ? controller
                                                  .userData.first.latitude
                                              : controller
                                                  .userProfileUpdateRequest
                                                  .latitude,
                                          label: 'Latitude',
                                          onChanged: onLatitudeChnage,
                                        ),
                                        InfoField(
                                          initialValue: controller.userData
                                                  .first.longitude.isNotEmpty
                                              ? controller
                                                  .userData.first.longitude
                                              : controller
                                                  .userProfileUpdateRequest
                                                  .longitude,
                                          label: 'Longitude',
                                          onChanged: onLongitudeChnage,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.progressColor,
                                            ), // Show loading spinner while fetching
                                          )
                                        : Container(); // Empty container if lat-long is not fetched
                                  }
                                }),
                                languages(context),
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
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      AppColors.progressColor,
                                                ),
                                              );
                                            }
                                            if (selectedGender.value == null &&
                                                controller
                                                    .userData.isNotEmpty) {
                                              String? genderFromUserData =
                                                  controller
                                                      .userData.first.gender;
                                              if (genderFromUserData
                                                  .isNotEmpty) {
                                                selectedGender.value = controller
                                                    .genders
                                                    .firstWhere(
                                                        (gender) =>
                                                            gender.id ==
                                                            genderFromUserData,
                                                        orElse: () => controller
                                                            .genders.first);
                                              }
                                            }
                                            return SingleChildScrollView(
                                              child: Column(
                                                children: controller.genders
                                                    .map((gender) {
                                                  return RadioListTile<Gender?>(
                                                    title: Text(
                                                      gender.title,
                                                      style: AppTextStyles
                                                          .bodyText
                                                          .copyWith(
                                                        fontSize: bodyFontSize,
                                                        color:
                                                            AppColors.textColor,
                                                      ),
                                                    ),
                                                    value: gender,
                                                    groupValue:
                                                        selectedGender.value,
                                                    onChanged: (Gender? value) {
                                                      selectedGender.value =
                                                          value;

                                                      // Safe parsing using tryParse
                                                      final parsedGenderId =
                                                          int.tryParse(
                                                              value?.id ?? '');

                                                      if (parsedGenderId !=
                                                          null) {
                                                        controller
                                                                .userProfileUpdateRequest
                                                                .gender =
                                                            parsedGenderId
                                                                .toString();
                                                      } else {
                                                        controller
                                                            .userProfileUpdateRequest
                                                            .gender = '';
                                                      }

                                                      controller.fetchSubGender(
                                                          SubGenderRequest(
                                                              genderId:
                                                                  parsedGenderId
                                                                      .toString()));
                                                    },
                                                    activeColor:
                                                        AppColors.buttonColor,
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
                                  String? initialLookingForValue =
                                      controller.userData.first.lookingFor;

                                  return Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            value: initialLookingForValue
                                                        ?.isEmpty ??
                                                    true
                                                ? null
                                                : initialLookingForValue,
                                            decoration: InputDecoration(
                                              labelText: 'Relationship Type',
                                              labelStyle: AppTextStyles
                                                  .labelText
                                                  .copyWith(
                                                fontSize: titleFontSize,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: AppColors.textColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: '1',
                                                child: Text(
                                                  'Serious Relationship',
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: bodyFontSize,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: '2',
                                                child: Text(
                                                  'Hookup',
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: bodyFontSize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                controller
                                                    .userRegistrationRequest
                                                    .lookingFor = value;
                                              }
                                            },
                                            iconEnabledColor:
                                                AppColors.textColor,
                                            iconDisabledColor:
                                                AppColors.inactiveColor,
                                          ),
                                          SizedBox(height: 5),
                                          Column(
                                            children: List.generate(
                                                controller.subGenders.length,
                                                (index) {
                                              if (selectedOption.value == '' &&
                                                  controller
                                                      .userData.isNotEmpty) {
                                                String? subGenderFromUserData =
                                                    controller.userData.first
                                                        .subGender;
                                                if (subGenderFromUserData
                                                    .isNotEmpty) {
                                                  selectedOption.value =
                                                      subGenderFromUserData;
                                                }
                                              }
                                              return RadioListTile<String>(
                                                title: Text(
                                                  controller
                                                      .subGenders[index].title,
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: bodyFontSize,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                value: controller
                                                    .subGenders[index].id,
                                                groupValue:
                                                    selectedOption.value,
                                                onChanged: (String? value) {
                                                  selectedOption.value =
                                                      value ?? '';
                                                  controller
                                                      .userProfileUpdateRequest
                                                      .subGender = value ?? '';
                                                },
                                                activeColor:
                                                    AppColors.buttonColor,
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
                                      child: CircularProgressIndicator(
                                        color: AppColors.progressColor,
                                      ),
                                    );
                                  }
                                  if (preferencesSelectedOptions.length !=
                                      controller.preferences.length) {
                                    preferencesSelectedOptions.value =
                                        List<bool>.filled(
                                            controller.preferences.length,
                                            false);
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Your Selected Preferences",
                                            style: AppTextStyles.subheadingText
                                                .copyWith(
                                              fontSize: 18,
                                              color: AppColors.textColor,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(height: 20),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                controller.preferences.length,
                                            itemBuilder: (context, index) {
                                              return CheckboxListTile(
                                                title: Text(
                                                  controller
                                                      .preferences[index].title,
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                    fontSize: bodyFontSize,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                value:
                                                    preferencesSelectedOptions[
                                                        index],
                                                         
                                                onChanged: (bool? value) {
                                                  preferencesSelectedOptions[
                                                      index] = value ?? false;
                                                },
                                                activeColor:
                                                    AppColors.buttonColor,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Interests",
                                            style: AppTextStyles.subheadingText
                                              ..copyWith(
                                                  fontSize:
                                                      getResponsiveFontSize(
                                                          0.03))),
                                        SizedBox(height: 10),
                                        Obx(() {
                                          interestsList = controller.userData
                                                  .first.interest.isNotEmpty
                                              ? controller
                                                  .userData.first.interest
                                                  .split(',')
                                              : [];
                                          if (UpdatedselectedInterests
                                              .isEmpty) {
                                            UpdatedselectedInterests.addAll(
                                                interestsList);
                                          }
                                          return Wrap(
                                            spacing: 8.0,
                                            children: List.generate(
                                                UpdatedselectedInterests.length,
                                                (index) {
                                              return Chip(
                                                label: Text(
                                                  UpdatedselectedInterests[
                                                      index],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                backgroundColor:
                                                    AppColors.chipColor,
                                                deleteIcon: Icon(Icons.delete,
                                                    color: AppColors
                                                        .inactiveColor),
                                                onDeleted: () =>
                                                    deleteInterest(index),
                                              );
                                            }),
                                          );
                                        }),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: interestController,
                                                cursorColor:
                                                    AppColors.cursorColor,
                                                decoration: InputDecoration(
                                                  labelText: 'update Interest',
                                                  labelStyle: AppTextStyles
                                                      .buttonText
                                                      .copyWith(
                                                          fontSize:
                                                              getResponsiveFontSize(
                                                                  0.03)),
                                                  filled: true,
                                                  fillColor:
                                                      AppColors.formFieldColor,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add,
                                                  color: AppColors.activeColor),
                                              onPressed: addInterest,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                buildRelationshipStatusInterestStep(
                                    context, MediaQuery.of(context).size),
                              ],
                            ),
                      SizedBox(height: 16),
                      Card(
                        color: AppColors.primaryColor,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Privacy Settings",
                                  style: AppTextStyles.subheadingText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03))),
                              SizedBox(height: 10),
                              PrivacyToggle(
                                label: "Email Alert",
                                value: emailAlerts.value,
                                onChanged: (val) =>
                                    setState(() => emailAlerts.value = val),
                              ),
                              PrivacyToggle(
                                label: visibility_status.value
                                    ? "Online Visible"
                                    : "Hide Online ",
                                value: visibility_status.value,
                                onChanged: (val) => setState(() {
                                  visibility_status.value = val;
                                }),
                              ),
                              PrivacyToggle(
                                label: "Hide me on Flame",
                                value: hideMeOnFlame,
                                onChanged: (val) =>
                                    setState(() => hideMeOnFlame = val),
                              ),
                              SizedBox(height: 10),
                              PrivacyToggle(
                                label: "Incognito Mode",
                                value: incognitoMode,
                                onChanged: (val) =>
                                    setState(() => incognitoMode = val),
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
              );
            }));
  }
}

Widget buildDropdown<T>(
  String label,
  List<T> items,
  T? selectedValue,
  initialCountry,
  double fontSize,
  Function(T?) onChanged, {
  String Function(T)? displayValue,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<T>(
      value: selectedValue,
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(
            displayValue != null ? displayValue(value) : value.toString(),
            style: AppTextStyles.textStyle.copyWith(fontSize: fontSize),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.formFieldColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
      dropdownColor: AppColors.secondaryColor,
    ),
  );
}

Widget buildRelationshipStatusInterestStep(
    BuildContext context, Size screenSize) {
  Controller controller = Get.put(Controller());
  RxList<bool> selectedOptions =
      List.filled(controller.desires.length, false).obs;
  RxList<UserDesire> selectedDesires = controller.userDesire;
  controller.userProfileUpdateRequest.desires =
      selectedDesires.map((userDesire) => userDesire.desiresId).toList();
  // Populate selectedOptions based on controller.userDesire
  for (var userDesire in controller.userDesire) {
    int index =
        controller.desires.indexWhere((d) => d.id == userDesire.desiresId);
    if (index != -1) {
      selectedOptions[index] = true;
    }
  }

  // Handle chip selection
  double screenWidth = screenSize.width;
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
            Obx(() {
              return selectedDesires.isNotEmpty
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
                            children: selectedDesires.map((desire) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(desire.title),
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
                                    // Remove desire on deletion
                                    selectedDesires.remove(desire);
                                    int index = controller.desires.indexWhere(
                                        (d) => d.id == desire.desiresId);
                                    if (index != -1) {
                                      selectedOptions[index] = false;
                                    }
                                    controller
                                            .userProfileUpdateRequest.desires =
                                        selectedDesires
                                            .map((userDesire) =>
                                                userDesire.desiresId)
                                            .toList();
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
              "Select your Desires: ${controller.desires.length}",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 10),
            Obx(() {
              return controller.desires.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            List.generate(controller.desires.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              // Add desire to selected list
                              UserDesire userDesire = UserDesire(
                                  desiresId: controller.desires[index].id,
                                  title: controller.desires[index].title);

                              if (!selectedDesires.contains(userDesire)) {
                                selectedDesires.add(userDesire);
                                selectedOptions[index] = true;
                                controller.userProfileUpdateRequest.desires =
                                    selectedDesires
                                        .map((userDesire) =>
                                            userDesire.desiresId)
                                        .toList();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Chip(
                                label: Text(controller.desires[index].title),
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
                    )
                  : Container();
            }),

            SizedBox(height: 20),
            // Reset and Cancel Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
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
                              Navigator.pop(context);
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
                              selectedOptions.value =
                                  List.filled(selectedOptions.length, false);
                              selectedDesires.clear();
                              Navigator.pop(context);
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

RxList<String> selectedLanguages = <String>[].obs;
RxList<int> selectedLanguagesId = <int>[].obs;

RxString searchQuery = ''.obs;

Widget languages(BuildContext context) {
  if (selectedLanguages.isEmpty) {
    selectedLanguages.addAll(controller.userLang.map((lang) => lang.title));
  }
  controller.userProfileUpdateRequest.lang = selectedLanguagesId;
  return Card(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select Languages',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onPressed: () {
                  showLanguageSelectionBottomSheet(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Languages',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedLanguages.map((language) {
                  return Chip(
                    label: Text(language),
                    deleteIcon: Icon(Icons.cancel, size: 18),
                    onDeleted: () {
                      selectedLanguages.remove(language);
                      updateSelectedLanguageIds();
                    },
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(fontSize: 14),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    ),
  );
}

final Controller controller = Get.put(Controller());
void updateSelectedLanguageIds() {
  selectedLanguagesId.clear();
  for (int i = 0; i < controller.language.length; i++) {
    if (selectedLanguages.contains(controller.language[i].title)) {
      selectedLanguagesId.add(int.parse(controller.language[i].id));
    }
  }
  controller.userProfileUpdateRequest.lang = selectedLanguagesId;
}

void showLanguageSelectionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Languages',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),

            // Search input field
            TextField(
              onChanged: (query) {
                searchQuery.value = query;
              },
              decoration: InputDecoration(
                hintText: 'Search Languages...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            SizedBox(height: 10),

            Obx(() {
              // Filter languages based on the search query
              var filteredLanguages = controller.language
                  .where((language) => language.title
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()))
                  .toList();
              return Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredLanguages.length,
                  itemBuilder: (context, index) {
                    String language = filteredLanguages[index].title;
                    bool isSelected = selectedLanguages.contains(language);

                    return ChoiceChip(
                      label: Text(language),
                      selected: isSelected,
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      onSelected: (bool selected) {
                        print('in the on selected');
                        if (selected) {
                          if (!selectedLanguages.contains(language)) {
                            selectedLanguages.add(language);

                            // selectedLanguages
                            //     .add(controller.userLang.first.title);
                          }
                        } else {
                          selectedLanguages.remove(language);
                        }
                        updateSelectedLanguageIds(); // Update IDs
                      },
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 10),
            Obx(() {
              return SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal, // Make it horizontal scrollable
                child: Wrap(
                  spacing: 8, // Horizontal space between chips
                  runSpacing: 8, // Vertical space between chips
                  children: selectedLanguages.map((language) {
                    return Chip(
                      label: Text(language),
                      deleteIcon: Icon(Icons.cancel, size: 18), // Delete icon
                      onDeleted: () {
                        selectedLanguages.remove(language);
                        updateSelectedLanguageIds(); // Update IDs
                      },
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      labelStyle: TextStyle(fontSize: 14),
                    );
                  }).toList(),
                ),
              );
            }),

            // Done Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  updateSelectedLanguageIds();
                  Navigator.pop(context);
                  for (int i in selectedLanguagesId) {
                    print(i.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showFullImageDialog(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
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
class InfoField extends StatefulWidget {
  final String initialValue;
  final String label;
  final Function(String) onChanged;

  const InfoField({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  _InfoFieldState createState() => _InfoFieldState();
}

class _InfoFieldState extends State<InfoField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Card(
      color: AppColors.primaryColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.buttonText.copyWith(
                fontSize: getResponsiveFontSize(0.03),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              cursorColor: AppColors.cursorColor,
              controller: controller,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: getResponsiveFontSize(0.03),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.formFieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.onChanged,
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
