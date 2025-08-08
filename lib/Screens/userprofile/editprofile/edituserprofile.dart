import 'dart:async';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_country_response_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pushable_button/pushable_button.dart';
import '../../../Models/RequestModels/user_profile_update_request_model.dart';
import '../../../Models/ResponseModels/ProfileResponse.dart';
import '../../../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../../../constants.dart';
import '../editphoto/edituserprofilephoto.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxBool isLatLongFetched = false.obs;
  RxList<String> genderIds = <String>[].obs;
  List<bool> isImageLoading = [];
  Timer? debounce;
  bool hideMeOnFlame = true;
  bool incognitoMode = false;
  RxBool emailAlerts = true.obs;
  RxBool visibility_status = true.obs;
  bool optOutOfPingNote = true;
  RxBool showAddHint = false.obs;

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  late RxList<bool> selectedOptions;
  late RxList<UserDesire> selectedDesires;
  RxList<Gender> genders = <Gender>[].obs;
  RxList<SubGenderRequest> subGenders = <SubGenderRequest>[].obs;
  Rx<String> selectedOption = ''.obs;
  Rx<Gender?> selectedGender = Rx<Gender?>(null);

  // Removed duplicate initState method to fix duplicate definition error
  RxString selectedSubGender = ''.obs;
  List<String> interestsList = [];
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;
  RxList<String> selectedPreferences = <String>[].obs;
  TextEditingController interestController = TextEditingController();
  RxList<String> updatedSelectedInterests = <String>[].obs;
  final RxString interestError = ''.obs;
  RxString errorMessage = ''.obs; // Declare this at the top of your class
  RxBool preferencesError = false.obs;
  RxBool languageError = false.obs; // reactive bool to track error
  RxString interestInstruction = ''.obs;

  void addInterest() {
    String newInterest = interestController.text.trim();
    if (newInterest.isNotEmpty) {
      if (!updatedSelectedInterests.contains(newInterest)) {
        updatedSelectedInterests.add(newInterest);

        controller.userData.first.interest = updatedSelectedInterests.join(',');

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
        updatedSelectedInterests.join(', ');
  }

  void deleteInterest(int index) {
    updatedSelectedInterests.removeAt(index);
    controller.userData.first.interest = updatedSelectedInterests.join(',');

    // Show error if list becomes empty
    if (updatedSelectedInterests.isEmpty) {
      interestError.value = "Interest is required";
    } else {
      interestError.value = '';
    }

    print("Updated backend interest: ${controller.userData.first.interest}");
  }

  late Future<bool> _fetchProfileFuture;

  Future<bool> _loadProfileData() async {
    bool success = await fetchAllData();
    if (success) {
      await initialize();
    }
    return success;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = _loadProfileData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
    );
    selectedDesires = controller.userDesire;
    interestController.addListener(() {
      showAddHint.value = interestController.text.trim().isNotEmpty;
    });
    interestController.addListener(() {
      if (interestController.text.trim().isNotEmpty) {
        interestInstruction.value = "Click on add to save";
      } else {
        interestInstruction.value = "";
      }
    });
  }

  Future<bool> fetchAllData() async {
    if (await controller.fetchProfile()) {
      controller.userProfileUpdateRequest.preferences =
          controller.userPreferences.map((p) => p.preferenceId).toList();
      controller.userProfileUpdateRequest.lang =
          controller.userLang.map((l) => l.langId).toList();
    }
    if (!await controller.fetchCountries()) return false;
    if (!await controller.fetchGenders()) return false;
    if (!await controller.fetchPreferences()) return false;
    if (!await controller.fetchlang()) return false;
    if (!await controller.fetchDesires()) return false;

    return true;
  }

  initialize() async {
    try {
      debounce?.cancel();
      isLatLongFetched.value = false;

      Gender? initialGender;
      if (controller.userData.isNotEmpty &&
          controller.userData.first.gender.isNotEmpty) {
        final userGenderId = controller.userData.first.gender;
        initialGender = controller.genders.firstWhere(
          (g) => g.id == userGenderId,
          orElse: () => controller.genders.first,
        );
      } else if (controller.genders.isNotEmpty) {
        initialGender = controller.genders.first;
      }

      selectedGender.value = initialGender;

      if (selectedGender.value != null) {
        await controller.fetchSubGender(SubGenderRequest(
          genderId: selectedGender.value!.id,
        ));
      }

      preferencesSelectedOptions.value =
          List<bool>.filled(controller.preferences.length, false);
      List<String> matchingIndexes = [];
      for (var p in controller.userPreferences) {
        int index = controller.preferences
            .indexWhere((preference) => preference.id == p.preferenceId);
        if (index != -1) {
          matchingIndexes.add(index.toString());
          preferencesSelectedOptions[index] = true;
        }
      }
      // print("Matching indexes: $matchingIndexes");

      // print(
      //     "DOB : ${controller.userProfileUpdateRequest.dob} and previous ${controller.userData.first.dob}");
      // selectedDate = DateFormat('dd/MM/yyyy')
      //     .parse(controller.userProfileUpdateRequest.dob);
      // print("SelectedDate: $selectedDate");

      latitudeController.text = controller.userData.first.latitude.isNotEmpty
          ? controller.userData.first.latitude
          : controller.userProfileUpdateRequest.latitude;

      longitudeController.text = controller.userData.first.longitude.isNotEmpty
          ? controller.userData.first.longitude
          : controller.userProfileUpdateRequest.longitude;

      selectedOptions = RxList<bool>.filled(controller.desires.length, false);
      selectedDesires = controller.userDesire;
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
    debounce = Timer(Duration(milliseconds: 800), () {
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

  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 3) {
      return 'Name should be at least 3 characters long';
    }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    //   failure('RE-Enter', 'Name must contain only alphabets');
    //   return 'Name must contain only alphabets';
    // }
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]').hasMatch(value)) {
      failure(
          'RE-Enter', 'Name must not contain numbers or special characters');
      return 'Name must not contain numbers or special characters';
    }
    return null;
  }

  String? validateLatitude(String value) {
    if (value.isEmpty) {
      return 'Latitude cannot be empty';
    }
    try {
      double latitude = double.parse(value);
      if (latitude < -90 || latitude > 90) {
        return 'Latitude must be between -90 and 90 degrees';
      }
    } catch (e) {
      return 'Latitude must be a valid number';
    }
    return null;
  }

  String? validateLongitude(String value) {
    if (value.isEmpty) {
      return 'Longitude cannot be empty';
    }
    try {
      double longitude = double.parse(value);
      if (longitude < -180 || longitude > 180) {
        return 'Longitude must be between -180 and 180 degrees';
      }
    } catch (e) {
      return 'Longitude must be a valid number';
    }
    return null;
  }

  String? validateAddress(String value) {
    if (value.isEmpty) {
      failure("Invalid Address", "Address cannot be empty.");
      return 'Address cannot be empty';
    }

    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      failure("Invalid Address", "Address cannot contain only numbers.");
      return "Address cannot contain only numbers.";
    }

    if (RegExp(r'^[^\w\s]+$').hasMatch(value)) {
      failure(
          "Invalid Address", "Address cannot contain only special characters.");
      return "Address cannot contain only special characters.";
    }
    if (RegExp(r'(?=.*[0-9])(?=.*[^\w\s])').hasMatch(value)) {
      failure("Invalid Address",
          "Address cannot contain only special characters and numbers.");

      return "Address cannot contain only special characters.";
    }

    return null;
  }

  String? validateCountryId(String value) {
    if (value.isEmpty) {
      return 'Country ID cannot be empty';
    }
    return null;
  }

  String? validateCity(String value) {
    if (value.isEmpty) {
      return 'City cannot be empty';
    }
    return null;
  }

  String? validateNickname(String value) {
    if (value.isEmpty) {
      return 'Nickname cannot be empty';
    }
    if (value.length < 3) {
      return 'Nickname should be at least 3 characters long';
    }
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Nickname must not contain numbers or special characters.';
    }
    return null;
  }

  String? validateGender(String value) {
    if (value.isEmpty) {
      return 'Gender cannot be empty';
    }
    return null;
  }

  String? validateSubGender(String value) {
    if (value.isEmpty) {
      return 'Sub-gender cannot be empty';
    }
    return null;
  }

  String? validateLang(List<String> value) {
    if (value.isEmpty) {
      return 'At least one language should be selected';
    }
    return null;
  }

  String? validateInterest(String value) {
    if (value.isEmpty) {
      return 'Interest cannot be empty';
    }
    return null;
  }

  String? validateBio(String value) {
    if (value.isEmpty) {
      return 'Bio cannot be empty';
    }
    return null;
  }

  String? validateVisibility(String value) {
    if (value.isEmpty) {
      return 'Visibility cannot be empty';
    }
    return null;
  }

  String? validateEmailAlerts(String value) {
    if (value.isEmpty) {
      return 'Email Alerts cannot be empty';
    }
    return null;
  }

  String? validatePreferences(List<String> value) {
    if (value.isEmpty) {
      return 'Preferences cannot be empty';
    }
    return null;
  }

  String? validateDesires(List<String> value) {
    if (value.isEmpty) {
      return 'Desires cannot be empty';
    }
    return null;
  }

  String? validateDob(String value) {
    if (value.isEmpty) {
      return 'Date of birth cannot be empty';
    }

    DateTime dob = DateFormat('dd/MM/yyyy').parse(value);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;

    // Adjust for month and day
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    // ❌ Don't allow future DOB
    if (dob.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    if (age < 18) {
      return 'You must be at least 18 years old to proceed.';
    }

    return null;
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

  Widget dobPicker({
    required BuildContext context,
    required String initialValue,
    required Function(String) onChanged,
    required String? Function(String)? validator,
    required String label,
  }) {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    String? errorText;

    void validateInput(String value) {
      if (validator != null) {
        errorText = validator(value);
      }
    }

    Future<void> selectDate() async {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime eighteenYearsAgo = today.subtract(Duration(days: (18 * 365) + 5)); // Added 5 days to account for leap years

      DateTime defaultInitial = eighteenYearsAgo; // default to 18 years ago

      DateTime? initialDate;
      try {
        if (initialValue.isNotEmpty) {
          DateTime parsed = DateFormat('MM/dd/yyyy').parseStrict(initialValue);
          initialDate =
              parsed.isAfter(eighteenYearsAgo) ? defaultInitial : parsed;
        }
      } catch (_) {
        initialDate = defaultInitial;
      }

      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? defaultInitial,
        firstDate: DateTime(1900),
        lastDate: eighteenYearsAgo,
        helpText: "Select your Date of Birth",
      );

      if (pickedDate != null) {
        String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
        controller.text = formattedDate;
        onChanged(formattedDate);
        validateInput(formattedDate);
      }
    }

    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return GestureDetector(
      onTap: selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          cursorColor: AppColors.cursorColor,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: label, // <--- Floating label inside input
            labelStyle: AppTextStyles.labelText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white70,
            ),
            floatingLabelStyle: AppTextStyles.labelText.copyWith(
              fontSize: getResponsiveFontSize(0.028),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            hintText: "Select your Date of Birth",
            filled: true,
            fillColor: AppColors.formFieldColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.textColor, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            errorText: errorText,
          ),
          onChanged: (value) {
            onChanged(value);
            validateInput(value);
          },
        ),
      ),
    );
  }

  Widget buildTextFieldForLatLong({
    required String label,
    required String value,
    required Function(String) onChanged,
    double fontSize = 15.0,
    bool isDisabled = false,
  }) {
    TextEditingController controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DecoratedBoxTransition(
        decoration: decorationTween.animate(_animationController),
        child: TextFormField(
          controller: controller,
          obscureText: false,
          enabled: !isDisabled,
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
          style: AppTextStyles.inputFieldText.copyWith(
            fontSize: fontSize,
            color: isDisabled ? AppColors.textColor : null,
          ),
          cursorColor:
              isDisabled ? AppColors.primaryColor : AppColors.textColor,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.labelText.copyWith(
              fontSize: fontSize,
              color: isDisabled ? Colors.grey : AppColors.textColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey : AppColors.textColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey : AppColors.textColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey : AppColors.textColor,
              ),
            ),
            fillColor:
                isDisabled ? AppColors.primaryColor : AppColors.formFieldColor,
            filled: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenheight = screenSize.height;
    // double titleFontSize = screenWidth * 0.03;
    double bodyFontSize = screenWidth * 0.03;

    // double chipFontSize = screenWidth * 0.03;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparent for gradient
          elevation: 0, // Remove default shadow
          centerTitle: true,

          title: Builder(
            builder: (context) {
              double fontSize = MediaQuery.of(context).size.width *
                  0.05; // ~5% of screen width
              return Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: AppColors.textColor,
                ),
              );
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: AppColors.gradientBackgroundList,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66666666),
                  blurRadius: 10.0,
                  spreadRadius: 3.0,
                  offset: Offset(0, 6.0),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
            ),
          ),
        ),
        body: FutureBuilder<bool>(
            future: _fetchProfileFuture, //controller.fetchProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    // child: SpinKitCircle(
                    //   size: 150.0,
                    //   color: AppColors.progressColor,
                    // ),
                    child: Lottie.asset(
                        "assets/animations/editprofileanimation.json"));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading user profile: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data != true) {
                return Center(
                  child: Text(
                    'No data available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          DecoratedBoxTransition(
                            decoration:
                                decorationTween.animate(_animationController),
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.gradientBackgroundList,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      child: (controller.userPhotos == null ||
                                              controller
                                                  .userPhotos!.images.isEmpty)
                                          ? const Center(
                                              child: Text("No images available",
                                                  style: TextStyle(
                                                      color: Colors.white)))
                                          : Scrollbar(
                                              child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount: controller
                                                    .userPhotos!.images.length,
                                                itemBuilder: (context, index) {
                                                  String imageUrl = controller
                                                      .userPhotos!
                                                      .images[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0),
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () =>
                                                              showFullImageDialog(
                                                                  context,
                                                                  imageUrl),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
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
                                                                  0.35,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return child;
                                                                } else {
                                                                  return const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  );
                                                                }
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.55,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.25,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .broken_image,
                                                                    size: 48,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
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
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await controller
                                            .fetchProfileUserPhotos();
                                        Get.to(EditPhotosPage());
                                      },
                                      icon: Builder(
                                        builder: (context) {
                                          double iconSize =
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04; // 4% of screen width
                                          return Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: iconSize,
                                          );
                                        },
                                      ),
                                      label: Text(
                                        'Edit Photos',
                                        style:
                                            AppTextStyles.buttonText.copyWith(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02, // 2% font size as example
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            right: 2,
                            child: Transform.rotate(
                              angle: 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.textColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: Colors.black87,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Photos',
                                      style: AppTextStyles.textStyle.copyWith(
                                        fontSize: getResponsiveFontSize(0.03),
                                        color: Colors.black87,
                                      ),
                                    ),

                                    // Text(
                                    //   'Photos',
                                    //   style: AppTextStyles.titleText.copyWith(
                                    //     fontSize: 10,
                                    //     foreground: Paint()
                                    //       ..shader = LinearGradient(
                                    //         colors: AppColors
                                    //             .gradientBackgroundList,
                                    //       ).createShader(
                                    //         Rect.fromLTWH(0, 0, 200,
                                    //             70), // You can adjust size
                                    //       ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.progressColor,
                              ),
                            )
                          : Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  InfoField(
                                    initialValue: controller
                                            .userProfileUpdateRequest
                                            .name
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.name
                                        : controller.userData.first.name,
                                    label: 'Name',
                                    onChanged: onUserNameChanged,
                                    validator: (value) {
                                      return validateName(value);
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            AppColors.gradientBackgroundList,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    child: dobPicker(
                                      context: context,
                                      initialValue: controller
                                              .userProfileUpdateRequest
                                              .dob
                                              .isNotEmpty
                                          ? controller
                                              .userProfileUpdateRequest.dob
                                          : controller.userData.first.dob,
                                      onChanged: (value) {
                                        controller.userProfileUpdateRequest
                                            .dob = value;
                                        print("Date of Birth: $value");
                                      },
                                      validator: (value) => validateDob(value),
                                      label: 'Date of Birth',
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  InfoField(
                                    initialValue: controller
                                            .userProfileUpdateRequest
                                            .nickname
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.nickname
                                        : controller.userData.first.nickname,
                                    label: 'Nick name',
                                    onChanged: onNickNameChanged,
                                    validator: (value) {
                                      return validateNickname(value.trim());
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  InfoField(
                                    initialValue: controller
                                            .userProfileUpdateRequest
                                            .bio
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.bio
                                        : controller.userData.first.bio,
                                    label: 'About',
                                    onChanged: onAboutChanged,
                                    validator: (value) {
                                      return validateBio(value);
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  DecoratedBoxTransition(
                                    decoration: decorationTween
                                        .animate(_animationController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            12), // Match Card's shape
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        elevation:
                                            0, // Remove elevation as Container has shadow
                                        color: Colors
                                            .transparent, // Make card transparent
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Country: ${controller.selectedCountry.value?.name ?? ''}",
                                                style: const TextStyle(
                                                    fontSize: 12.0),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Obx(() {
                                                if (controller
                                                    .countries.isEmpty) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: AppColors
                                                          .progressColor,
                                                    ),
                                                  );
                                                }
                                                return buildDropdownWithBottomSheet<
                                                    Country>(
                                                  context,
                                                  "Country",
                                                  controller.countries,
                                                  controller.initialCountry,
                                                  controller.selectedCountry,
                                                  12.0,
                                                  (Country? value) {
                                                    if (value != null) {
                                                      controller
                                                          .userProfileUpdateRequest
                                                          .countryId = value.id;
                                                      Get.snackbar('Selected',
                                                          value.name);
                                                    }
                                                  },
                                                  displayValue:
                                                      (Country country) =>
                                                          country.name,
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  InfoField(
                                    initialValue: controller
                                            .userProfileUpdateRequest
                                            .address
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.address
                                        : controller.userData.first.address,
                                    label: 'Address',
                                    onChanged: onAddressChnaged,
                                    validator: (value) {
                                      return validateAddress(value);
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  InfoField(
                                    initialValue: controller
                                            .userProfileUpdateRequest
                                            .city
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.city
                                        : controller.userData.first.city,
                                    label: 'City',
                                    onChanged: (value) {
                                      onCityChanged(value);
                                    },
                                    validator: (value) {
                                      return validateCity(value);
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  Obx(() {
                                    if (isLatLongFetched.value) {
                                      return Column(
                                        children: [
                                          // buildTextFieldForLatLong(
                                          //   label: 'Latitude',
                                          //   value: controller
                                          //       .userProfileUpdateRequest
                                          //       .latitude,
                                          //   onChanged: (value) {
                                          //     setState(() {
                                          //       onLatitudeChnage(value);
                                          //     });
                                          //   },
                                          //   isDisabled: true,
                                          // ),
                                          // buildTextFieldForLatLong(
                                          //   label: 'Longitude',
                                          //   value: controller
                                          //       .userProfileUpdateRequest
                                          //       .longitude,
                                          //   onChanged: (value) {
                                          //     setState(() {
                                          //       onLongitudeChnage(value);
                                          //     });
                                          //   },
                                          //   isDisabled: true,
                                          // ),
                                        ],
                                      );
                                    } else {
                                      return isLoading
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.progressColor,
                                              ),
                                            )
                                          : Container();
                                    }
                                  }),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.001,
                                  ),
                                  languages(context),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  DecoratedBoxTransition(
                                    decoration: decorationTween
                                        .animate(_animationController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        color: Colors
                                            .transparent, // Keep transparent so gradient is visible
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Gender',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // Set text color to white
                                                    fontWeight: FontWeight
                                                        .bold, // Make text bold
                                                    fontSize:
                                                        16, // Optional: set font size
                                                  ),
                                                ),
                                                Obx(() {
                                                  if (controller
                                                      .genders.isEmpty) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: AppColors
                                                            .progressColor,
                                                      ),
                                                    );
                                                  }
                                                  if (selectedGender.value ==
                                                          null &&
                                                      controller.userData
                                                          .isNotEmpty) {
                                                    String? genderFromUserData =
                                                        controller.userData
                                                            .first.gender;
                                                    if (genderFromUserData
                                                        .isNotEmpty) {
                                                      selectedGender.value =
                                                          controller.genders
                                                              .firstWhere(
                                                        (gender) =>
                                                            gender.id ==
                                                            genderFromUserData,
                                                        orElse: () => controller
                                                            .genders.first,
                                                      );
                                                    }
                                                  }
                                                  return SizedBox(
                                                    height: 200,
                                                    child: Scrollbar(
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: controller
                                                              .genders
                                                              .map((gender) {
                                                            return RadioListTile<
                                                                Gender?>(
                                                              title: Text(
                                                                gender.title,
                                                                style: AppTextStyles
                                                                    .bodyText
                                                                    .copyWith(
                                                                  fontSize:
                                                                      bodyFontSize,
                                                                  color: AppColors
                                                                      .textColor,
                                                                ),
                                                              ),
                                                              value: gender,
                                                              groupValue:
                                                                  selectedGender
                                                                      .value,
                                                              onChanged:
                                                                  (Gender?
                                                                      value) {
                                                                selectedGender
                                                                        .value =
                                                                    value;

                                                                final parsedGenderId =
                                                                    value?.id ??
                                                                        '';

                                                                controller
                                                                        .userProfileUpdateRequest
                                                                        .gender =
                                                                    parsedGenderId
                                                                        .toString();

                                                                controller
                                                                    .fetchSubGender(
                                                                        SubGenderRequest(
                                                                  genderId:
                                                                      parsedGenderId
                                                                          .toString(),
                                                                ));
                                                              },
                                                              activeColor:
                                                                  AppColors
                                                                      .buttonColor,
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  Obx(() {
                                    String initialLookingFor = controller
                                            .userProfileUpdateRequest
                                            .lookingFor
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.lookingFor
                                        : controller.userData.first.lookingFor;

                                    return DecoratedBoxTransition(
                                      decoration: decorationTween
                                          .animate(_animationController),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: AppColors
                                                .gradientBackgroundList,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Card(
                                          color: Colors
                                              .transparent, // Transparent to show gradient from Container
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildSelectableFieldRelationship<
                                                    String>(
                                                  "Relationship Type",
                                                  ['1', '2'],
                                                  initialLookingFor.isEmpty
                                                      ? null
                                                      : initialLookingFor,
                                                  bodyFontSize,
                                                  (String? value) {
                                                    setState(() {
                                                      controller
                                                          .userProfileUpdateRequest
                                                          .lookingFor = value ?? '';
                                                    });
                                                  },
                                                  displayValue: (String value) {
                                                    if (value == '1') {
                                                      return 'Serious Relationship';
                                                    } else if (value == '2') {
                                                      return 'Hookup';
                                                    }
                                                    return '';
                                                  },
                                                  context: context,
                                                ),
                                                SizedBox(height: 20),
                                                Center(
                                                  child: Text(
                                                    'Sub Gender',
                                                    style: AppTextStyles
                                                        .bodyText
                                                        .copyWith(
                                                      fontSize: bodyFontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  height: 200,
                                                  child: Scrollbar(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: List.generate(
                                                            controller
                                                                .subGenders
                                                                .length,
                                                            (index) {
                                                          if (selectedSubGender
                                                                      .value ==
                                                                  '' &&
                                                              controller
                                                                  .userData
                                                                  .isNotEmpty) {
                                                            String?
                                                                subGenderFromUserData =
                                                                controller
                                                                    .userData
                                                                    .first
                                                                    .subGender;
                                                            if (subGenderFromUserData
                                                                .isNotEmpty) {
                                                              selectedSubGender
                                                                      .value =
                                                                  subGenderFromUserData;
                                                            }
                                                          }

                                                          return RadioListTile<
                                                              String>(
                                                            title: Text(
                                                              controller
                                                                  .subGenders[
                                                                      index]
                                                                  .title,
                                                              style:
                                                                  AppTextStyles
                                                                      .bodyText
                                                                      .copyWith(
                                                                fontSize:
                                                                    bodyFontSize,
                                                                color: AppColors
                                                                    .textColor,
                                                              ),
                                                            ),
                                                            value: controller
                                                                .subGenders[
                                                                    index]
                                                                .id,
                                                            groupValue:
                                                                selectedSubGender
                                                                    .value,
                                                            onChanged: (String?
                                                                value) {
                                                              selectedSubGender
                                                                      .value =
                                                                  value ?? '';
                                                              controller
                                                                      .userProfileUpdateRequest
                                                                      .subGender =
                                                                  value ?? '';
                                                            },
                                                            activeColor:
                                                                AppColors
                                                                    .buttonColor,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          );
                                                        }),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
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
                                    for (var p in controller.userPreferences) {
                                      int index =
                                          controller.preferences.indexWhere(
                                        (preference) =>
                                            preference.id == p.preferenceId,
                                      );
                                      if (index != -1 &&
                                          !selectedPreferences
                                              .contains(index.toString())) {
                                        selectedPreferences
                                            .add(index.toString());
                                        preferencesSelectedOptions[index] =
                                            true;
                                      }
                                    }

                                    return DecoratedBoxTransition(
                                      decoration: decorationTween
                                          .animate(_animationController),
                                      child: Card(
                                        color: Colors.transparent,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: AppColors
                                                  .gradientBackgroundList,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Your Selected Preferences",
                                                  style: AppTextStyles
                                                      .subheadingText
                                                      .copyWith(
                                                    fontSize: 14,
                                                    color: AppColors.textColor,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                Obx(() => preferencesError.value
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4.0),
                                                        child: Text(
                                                          "Preference is required",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox.shrink()),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  height: 300,
                                                  child: Scrollbar(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount: controller
                                                            .preferences.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return CheckboxListTile(
                                                            title: Text(
                                                              controller
                                                                  .preferences[
                                                                      index]
                                                                  .title,
                                                              style:
                                                                  AppTextStyles
                                                                      .bodyText
                                                                      .copyWith(
                                                                fontSize:
                                                                    bodyFontSize,
                                                                color: AppColors
                                                                    .textColor,
                                                              ),
                                                            ),
                                                            value:
                                                                preferencesSelectedOptions[
                                                                    index],
                                                            onChanged:
                                                                (bool? value) {
                                                              preferencesSelectedOptions[
                                                                      index] =
                                                                  value ??
                                                                      false;

                                                              if (preferencesSelectedOptions[
                                                                  index]) {
                                                                selectedPreferences
                                                                    .add(controller
                                                                        .preferences[
                                                                            index]
                                                                        .id);
                                                              } else {
                                                                selectedPreferences
                                                                    .remove(controller
                                                                        .preferences[
                                                                            index]
                                                                        .id);
                                                              }

                                                              preferencesError
                                                                      .value =
                                                                  !preferencesSelectedOptions
                                                                      .contains(
                                                                          true);
                                                            },
                                                            activeColor:
                                                                AppColors
                                                                    .buttonColor,
                                                            checkColor:
                                                                Colors.white,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  DecoratedBoxTransition(
                                    decoration: decorationTween
                                        .animate(_animationController),
                                    child: Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: AppColors
                                                .gradientBackgroundList,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Center(
                                              child: Text(
                                                "Interests",
                                                style: AppTextStyles.textStyle
                                                    .copyWith(
                                                  fontSize:
                                                      getResponsiveFontSize(
                                                          0.04),
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign
                                                    .center, // optional for safety
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // Input field + Add button
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            interestController,
                                                        cursorColor: AppColors
                                                            .cursorColor,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Update Interest',
                                                          labelStyle:
                                                              AppTextStyles
                                                                  .buttonText
                                                                  .copyWith(
                                                            fontSize:
                                                                getResponsiveFontSize(
                                                                    0.03),
                                                          ),
                                                          filled: true,
                                                          fillColor: AppColors
                                                              .formFieldColor,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.green,
                                                              width: 2.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .textColor,
                                                              width: 1.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                      Obx(() {
                                                        return interestInstruction
                                                                .value
                                                                .isNotEmpty
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            6.0),
                                                                child: Text(
                                                                  interestInstruction
                                                                      .value,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .orange,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox.shrink();
                                                      }),
                                                      Obx(() {
                                                        return interestError
                                                                .value
                                                                .isNotEmpty
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            6.0),
                                                                child: Text(
                                                                  interestError
                                                                      .value,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              )
                                                            : SizedBox.shrink();
                                                      }),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.add,
                                                      color: Colors.white),
                                                  onPressed: addInterest,
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            // Chips display
                                            Obx(() {
                                              if (updatedSelectedInterests
                                                      .isEmpty &&
                                                  controller.userData.first
                                                      .interest.isNotEmpty) {
                                                updatedSelectedInterests.addAll(
                                                  controller
                                                      .userData.first.interest
                                                      .split(',')
                                                      .toSet(),
                                                );
                                              }

                                              return Wrap(
                                                spacing: 8.0,
                                                children: List.generate(
                                                    updatedSelectedInterests
                                                        .length, (index) {
                                                  final interest =
                                                      updatedSelectedInterests[
                                                          index];
                                                  return Chip(
                                                    label: Text(
                                                      interest,
                                                      style: const TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                    backgroundColor:
                                                        AppColors.chipColor,
                                                    deleteIcon: Icon(
                                                        Icons.delete,
                                                        color: AppColors
                                                            .inactiveColor),
                                                    onDeleted: () {
                                                      deleteInterest(index);
                                                      updateUserInterests();
                                                    },
                                                  );
                                                }),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  buildRelationshipStatusInterestStep(
                                      context, MediaQuery.of(context).size),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      DecoratedBoxTransition(
                        decoration:
                            decorationTween.animate(_animationController),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientBackgroundList,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 2,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.gradientBackgroundList,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        "Privacy Settings",
                                        style: AppTextStyles.subheadingText
                                            .copyWith(
                                          fontSize: getResponsiveFontSize(0.04),
                                          color: Colors
                                              .white, // Ensure it's readable on gradient
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    PrivacyToggle(
                                      label: "Email Alert",
                                      value: emailAlerts.value,
                                      onChanged: (val) => setState(
                                          () => emailAlerts.value = val),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    PrivacyToggle(
                                      label: visibility_status.value
                                          ? "Online Visible"
                                          : "Hide Online",
                                      value: visibility_status.value,
                                      onChanged: (val) {
                                        setState(() {
                                          visibility_status.value = val;
                                          controller.userProfileUpdateRequest
                                              .visibility = val ? '1' : '0';
                                        });
                                      },
                                    ),
                                    // Add other toggles here if needed
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        height: screenheight * 0.06,
                        width: screenWidth * 2,
                        child: DecoratedBoxTransition(
                          decoration:
                              decorationTween.animate(_animationController),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(0.8, 1),
                                colors: AppColors.gradientBackgroundList,
                              ),
                              borderRadius: BorderRadius.circular(
                                  30), // You can adjust the border radius here
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                print(
                                    'desires are : ${controller.userProfileUpdateRequest.desires}');
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (!preferencesSelectedOptions
                                      .contains(true)) {
                                    failure('Validation Error',
                                        'Preference is required. Please select at least one.');
                                    return;
                                  }
                                  if (selectedLanguages.isEmpty) {
                                    print("select language");
                                    return;
                                  }
                                  List<String> selectedPreferences = [];
                                  for (int i = 0;
                                      i < preferencesSelectedOptions.length;
                                      i++) {
                                    if (preferencesSelectedOptions[i]) {
                                      selectedPreferences
                                          .add(controller.preferences[i].id);
                                    }
                                  }
                                  controller.userProfileUpdateRequest
                                      .preferences = selectedPreferences;
                                  UserProfileUpdateRequest
                                      userProfileUpdateRequest =
                                      UserProfileUpdateRequest(
                                    name: controller.userProfileUpdateRequest
                                            .name.isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.name
                                        : controller.userData.first.name,
                                    latitude: controller
                                            .userProfileUpdateRequest
                                            .latitude
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.latitude
                                        : controller.userData.first.latitude,
                                    longitude: controller
                                            .userProfileUpdateRequest
                                            .longitude
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.longitude
                                        : controller.userData.first.longitude,
                                    address: controller.userProfileUpdateRequest
                                            .address.isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.address
                                        : controller.userData.first.address,
                                    countryId: controller
                                            .userProfileUpdateRequest
                                            .countryId
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.countryId
                                        : controller.userData.first.countryId,
                                    city: controller.userProfileUpdateRequest
                                            .city.isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.city
                                        : controller.userData.first.city,
                                    dob: controller.userProfileUpdateRequest.dob
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.dob
                                        : controller.userData.first.dob,
                                    nickname: controller
                                            .userProfileUpdateRequest
                                            .nickname
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.nickname
                                        : controller.userData.first.nickname,
                                    gender: controller.userProfileUpdateRequest
                                            .gender.isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.gender
                                        : controller.userData.first.gender,
                                    subGender: controller
                                            .userProfileUpdateRequest
                                            .subGender
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.subGender
                                        : controller.userData.first.subGender,
                                    lang: controller
                                        .userProfileUpdateRequest.lang,
                                    interest: controller
                                            .userProfileUpdateRequest
                                            .interest
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.interest
                                        : controller.userData.first.interest,
                                    bio: controller.userProfileUpdateRequest.bio
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.bio
                                        : controller.userData.first.bio,
                                    visibility: controller
                                            .userProfileUpdateRequest
                                            .visibility
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.visibility
                                        : controller
                                            .userData.first.userActiveStatus,
                                    emailAlerts: controller
                                            .userProfileUpdateRequest
                                            .emailAlerts
                                            .isNotEmpty
                                        ? controller.userProfileUpdateRequest
                                            .emailAlerts
                                        : controller.userData.first.emailAlerts,
                                    lookingFor: controller
                                            .userProfileUpdateRequest
                                            .lookingFor
                                            .isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.lookingFor
                                        : controller.userData.first.lookingFor,
                                    preferences: controller
                                        .userProfileUpdateRequest.preferences,
                                    desires: controller.userProfileUpdateRequest
                                            .desires.isNotEmpty
                                        ? controller
                                            .userProfileUpdateRequest.desires
                                        : controller.userDesire,
                                  );

                                  emailAlerts.value == true
                                      ? controller.userProfileUpdateRequest
                                          .emailAlerts = "1"
                                      : "0";
                                  visibility_status.value == true
                                      ? controller.userProfileUpdateRequest
                                          .visibility = '1'
                                      : '0';
                                  if (userProfileUpdateRequest.validate()) {
                                    controller.updateProfile(
                                        userProfileUpdateRequest);
                                  }
                                  return;
                                } else {
                                  failure("Invalid", 'Form is invalid');
                                  return;
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Save',
                                    style: AppTextStyles.headingText.copyWith(
                                      fontSize: getResponsiveFontSize(0.04),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Country selectedCountry = Country(
      id: '', name: '', countryCode: '', status: '', created: '', updated: '');
  Widget buildDropdownWithBottomSheet<T>(
    BuildContext context,
    String label,
    List<T> items,
    T? initialValue,
    Rx<T?> selectedValue,
    double fontSize,
    Function(T?) onChanged, {
    String? Function(T?)? validator,
    String Function(T)? displayValue,
  }) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Text(
                  "Select $label",
                  style: AppTextStyles.labelText.copyWith(fontSize: fontSize),
                ),
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        T item = items[index];
                        return ListTile(
                          title: Text(
                            displayValue != null
                                ? displayValue(item)
                                : item.toString(),
                            style: AppTextStyles.textStyle
                                .copyWith(fontSize: fontSize),
                          ),
                          onTap: () {
                            selectedValue.value = item;
                            onChanged(item);
                            Navigator.pop(context);
                          },
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.formFieldColor),
          color: AppColors.formFieldColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                return Text(
                  selectedValue.value != null
                      ? (displayValue != null
                          ? displayValue(selectedValue.value as T)
                          : selectedValue.value.toString())
                      : controller.initialCountry!.name.toString(),
                  style:
                      AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                );
              }),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.activeColor),
          ],
        ),
      ),
    );
  }

  Widget buildSelectableFieldRelationship<T>(
    String label,
    List<T> items,
    T? selectedValue,
    double fontSize,
    Function(T?) onChanged, {
    String Function(T)? displayValue,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _showBottomSheet<T>(
            context, items, selectedValue, onChanged, displayValue),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedValue != null
                      ? displayValue!(selectedValue)
                      : 'Select $label',
                  style:
                      AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.activeColor),
            ],
          ),
        ),
      ),
    );
  }

// Method to show the bottom sheet
  void _showBottomSheet<T>(
    BuildContext context,
    List<T> items,
    T? selectedValue,
    Function(T?) onChanged,
    String Function(T)? displayValue,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Select $selectedValue",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    T item = items[index];
                    return ListTile(
                      title: Text(displayValue != null
                          ? displayValue(item)
                          : item.toString()),
                      onTap: () {
                        onChanged(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// RxList<bool> selectedOptions =
//     List.filled(controller.desires.length, false).obs;
// RxList<UserDesire> selectedDesires = controller.userDesire;
  Widget buildRelationshipStatusInterestStep(
      BuildContext context, Size screenSize) {
    // Removed initialization here to avoid late initialization error

    controller.userProfileUpdateRequest.desires =
        selectedDesires.map((userDesire) => userDesire.desiresId).toList();

    for (var userDesire in controller.userDesire) {
      int index =
          controller.desires.indexWhere((d) => d.id == userDesire.desiresId);
      if (index != -1) {
        selectedOptions[index] = true;
      }
    }

    double screenWidth = screenSize.width;
    double bodyFontSize = screenWidth * 0.04;
    double chipFontSize = screenWidth * 0.03;

    return DecoratedBoxTransition(
      decoration: decorationTween.animate(_animationController),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.transparent,
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
                              SizedBox(height: screenSize.height * 0.02),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: selectedDesires.map((desire) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(desire.title),
                                        backgroundColor: AppColors.chipColor,
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: chipFontSize,
                                        ),
                                        deleteIcon: Icon(Icons.delete,
                                            color: AppColors.deniedColor),
                                        onDeleted: () {
                                          selectedDesires.remove(desire);
                                          int index = controller.desires
                                              .indexWhere((d) =>
                                                  d.id == desire.desiresId);
                                          if (index != -1) {
                                            selectedOptions[index] = false;
                                          }
                                          controller.userProfileUpdateRequest
                                                  .desires =
                                              selectedDesires
                                                  .map((userDesire) =>
                                                      userDesire.desiresId)
                                                  .toList();

                                          if (selectedDesires.isEmpty) {
                                            errorMessage.value =
                                                'Desires are required';
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                            ],
                          )
                        : Container();
                  }),
                  Obx(() => errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            errorMessage.value,
                            style: TextStyle(
                                color: Colors.red, fontSize: bodyFontSize),
                          ),
                        )
                      : Container()),
                  Text(
                    "Select your Desires: ${controller.desires.length}",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Obx(() {
                    return controller.desires.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(controller.desires.length,
                                  (index) {
                                return GestureDetector(
                                  onTap: () {
                                    UserDesire userDesire = UserDesire(
                                      desiresId: controller.desires[index].id,
                                      title: controller.desires[index].title,
                                    );

                                    if (!selectedDesires.any((desire) =>
                                        desire.desiresId ==
                                        userDesire.desiresId)) {
                                      selectedDesires.add(userDesire);
                                      selectedOptions[index] = true;
                                      controller.userProfileUpdateRequest
                                              .desires =
                                          selectedDesires
                                              .map((userDesire) =>
                                                  userDesire.desiresId)
                                              .toList();
                                      errorMessage.value = ''; // Clear error
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Chip(
                                      label:
                                          Text(controller.desires[index].title),
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
                  SizedBox(height: screenSize.height * 0.01),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.inactiveColor,
                      ),
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
                                    selectedOptions.value = List.filled(
                                        selectedOptions.length, false);
                                    selectedDesires.clear();
                                    errorMessage.value = 'Desires are required';
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
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: bodyFontSize,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  RxList<String> selectedLanguages = <String>[].obs;
  RxList<String> selectedLanguagesId = <String>[].obs;
  RxString searchQuery = ''.obs;

  Widget languages(BuildContext context) {
    // Initialize selectedLanguages if empty
    if (selectedLanguages.isEmpty) {
      selectedLanguages.addAll(controller.userLang.map((lang) => lang.title));
    }
    updateSelectedLanguageIds();
    controller.userProfileUpdateRequest.lang = selectedLanguagesId;

    // Update error state whenever languages list changes
    languageError.value = selectedLanguages.isEmpty;

    return DecoratedBoxTransition(
      decoration: decorationTween.animate(_animationController),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// White header section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.formFieldColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Select Languages',
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: getResponsiveFontSize(0.028),
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.2,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showLanguageSelectionBottomSheet(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Select',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: getResponsiveFontSize(0.026),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                            size: getResponsiveFontSize(0.035),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Show error message if no languages selected
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: languageError.value
                      ? Text(
                          'Language is required',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox(height: 0),
                );
              }),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              Obx(() {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedLanguages.map((language) {
                      return Chip(
                        label: Text(
                          language,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                        deleteIcon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 18,
                          color: Colors.black,
                        ),
                        onDeleted: () {
                          selectedLanguages.remove(language);
                          updateSelectedLanguageIds();

                          // Update error when user deletes
                          languageError.value = selectedLanguages.isEmpty;
                        },
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(fontSize: 9),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void updateSelectedLanguageIds() {
    selectedLanguagesId.clear();
    for (int i = 0; i < controller.language.length; i++) {
      if (selectedLanguages.contains(controller.language[i].title)) {
        selectedLanguagesId.add(controller.language[i].id);
      }
    }
    controller.userProfileUpdateRequest.lang = selectedLanguagesId;
    // print("Selected Lang Id : ${selectedLanguagesId.toList()}");
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
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
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
              Expanded(
                child: Obx(() {
                  var filteredLanguages = controller.language
                      .where((language) => language.title
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase()))
                      .toList();

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: filteredLanguages.length,
                    itemBuilder: (context, index) {
                      String language = filteredLanguages[index].title;

                      return Obx(() {
                        bool isSelected = selectedLanguages.contains(language);
                        return ChoiceChip(
                          label: Text(language),
                          selected: isSelected,
                          selectedColor: Colors.blue.withOpacity(0.3),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              if (!selectedLanguages.contains(language)) {
                                selectedLanguages.add(language);
                              }
                            } else {
                              selectedLanguages.remove(language);
                            }
                            updateSelectedLanguageIds();
                          },
                        );
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 90.0, // Set your desired button width here
                  height: 60.0,
                  child: PushableButton(
                    onPressed: () {
                      updateSelectedLanguageIds();
                      Navigator.pop(context);
                      print("Languages: ${selectedLanguages.toList()}");
                    },
                    // Required by the widget, provide a dummy solid color
                    hslColor: HSLColor.fromColor(
                        AppColors.gradientBackgroundList.first),
                    height: 50.0,
                    elevation: 8.0,
                    shadow: BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 4),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.gradientBackgroundList,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showFullImageDialog(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
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

class InfoField extends StatefulWidget {
  final String initialValue;
  final String label;
  final Function(String) onChanged;
  final String? Function(String)? validator;

  const InfoField({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
    required this.validator,
  });

  @override
  InfoFieldState createState() => InfoFieldState();
}

class InfoFieldState extends State<InfoField> with TickerProviderStateMixin {
  late TextEditingController controller;
  String? _errorText;

  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void validateInput(String value) {
    if (widget.validator != null) {
      String? error = widget.validator!(value);
      setState(() {
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return DecoratedBoxTransition(
      decoration: decorationTween.animate(_animationController),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12), // match your border radius
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   widget.label,
              //   style: AppTextStyles.buttonText.copyWith(
              //     fontSize: getResponsiveFontSize(0.03),
              //   ),
              // ),
              //SizedBox(height: 10),
              TextFormField(
                // ✅ Changed from TextField to TextFormField
                cursorColor: AppColors.cursorColor,
                controller: controller,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  // ✅ Floating label added here
                  labelText: widget.label,
                  labelStyle: AppTextStyles.labelText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  floatingLabelStyle: AppTextStyles.labelText.copyWith(
                    fontSize: getResponsiveFontSize(0.028),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: AppColors.formFieldColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.textColor, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  errorText: _errorText,
                ),
                onChanged: (value) {
                  widget.onChanged(value);
                  validateInput(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      return screenWidth * scale;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyText
                  .copyWith(fontSize: getResponsiveFontSize(0.03))),
          Transform.scale(
            scale: 0.6,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accentColor,
              inactiveThumbColor: AppColors.progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

class GenderValidator {
  static bool validateGenderId(String genderId) {
    try {
      int parsedGenderId = int.parse(genderId);
      if (parsedGenderId <= 0) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
