import 'dart:async';
import 'dart:convert';
import 'dart:ui';
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
import '../../../Models/ResponseModels/get_all_language_response_model.dart';
import '../../../Models/ResponseModels/get_all_desires_model_response.dart';
import '../../../Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import '../../../constants.dart';
import '../../../Widgets/glassmorphism_background.dart';
import '../../../Widgets/glass_surface.dart';
import '../../../Widgets/glass_input_field.dart';
import '../../../Widgets/glass_chip.dart';
import '../../../Widgets/glass_tile.dart';
import '../editphoto/edituserprofilephoto.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  bool _photosUpdated = false;
  late Controller controller;
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

  /// Helper function to normalize base64 string (add padding if needed)
  String _normalizeBase64(String base64) {
    // Remove data URL prefix if present
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    // Remove whitespace
    clean = clean.trim();
    // Add padding if needed (base64 strings should be divisible by 4)
    int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  /// Helper function to check if a string is a base64 image
  bool _isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    // If it starts with http, it's definitely a URL
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return false;
    }
    // If it starts with /, it might be a base64 string (like /9j/ for JPEG)
    // or it could be a path - check if it's long enough to be base64
    if (image.startsWith('/') && image.length > 50) {
      // Likely base64 if it's long and starts with /9j/ (JPEG) or /iVB (PNG)
      if (image.startsWith('/9j/') || image.startsWith('/iVB')) {
        try {
          String normalized = _normalizeBase64(image);
          base64Decode(normalized);
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
    String cleanImage = image.contains(',') ? image.split(',')[1] : image;
    cleanImage = cleanImage.trim();
    // Base64 strings should be reasonably long (at least 20 chars for a tiny image)
    if (cleanImage.length < 20) return false;
    // Try to normalize and decode
    try {
      String normalized = _normalizeBase64(cleanImage);
      base64Decode(normalized);
      return true;
    } catch (e) {
      return false;
    }
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
  RxBool desiresError = false.obs; // Error state for desires
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

  // Mock data mode removed - using only backend data

  Future<bool> _loadProfileData() async {
    // Using only backend data - no mock data mode
    try {
      print('EditProfile: Starting _loadProfileData...');
      
      // Add timeout to prevent hanging forever
      bool success = await fetchAllData().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          print('EditProfile: fetchAllData timed out after 60 seconds');
          return false;
        },
      );
      
      print('EditProfile: fetchAllData completed with success: $success');
      if (success) {
        print('EditProfile: Initializing data...');
        try {
          await initialize().timeout(
            Duration(seconds: 30),
            onTimeout: () {
              print('EditProfile: initialize timed out after 30 seconds');
            },
          );
          print('EditProfile: Initialization completed');
        } catch (initError) {
          print('EditProfile: Initialize failed but continuing: $initError');
          // Continue even if initialization fails partially
        }
        return true;
      } else {
        print('EditProfile: fetchAllData failed, cannot initialize');
        return false;
      }
    } catch (e, stackTrace) {
      print('EditProfile: Error in _loadProfileData: $e');
      print('EditProfile: Stack trace: $stackTrace');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controller - use existing if available, otherwise create new
    try {
      controller = Get.find<Controller>();
    } catch (e) {
      controller = Get.put(Controller());
    }
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
    try {
      print('EditProfile: Starting fetchAllData...');
      
      // Fetch profile first - this is critical
      print('EditProfile: Fetching profile...');
      bool profileSuccess = await controller.fetchProfile();
      print('EditProfile: Profile fetch result: $profileSuccess');
      
      if (!profileSuccess) {
        print('EditProfile: Profile fetch failed, returning false');
        return false;
      }
      
      // Set preferences and languages from fetched profile
      if (controller.userPreferences.isNotEmpty) {
      controller.userProfileUpdateRequest.preferences =
          controller.userPreferences.map((p) => p.preferenceId).toList();
        print('EditProfile: Set ${controller.userProfileUpdateRequest.preferences.length} preferences');
      }
      if (controller.userLang.isNotEmpty) {
      controller.userProfileUpdateRequest.lang =
          controller.userLang.map((l) => l.langId).toList();
        print('EditProfile: Set ${controller.userProfileUpdateRequest.lang.length} languages');
      }
      
      // Fetch other required data
      print('EditProfile: Fetching countries...');
      if (!await controller.fetchCountries()) {
        print('EditProfile: Failed to fetch countries');
        return false;
      }
      
      print('EditProfile: Fetching genders...');
      if (!await controller.fetchGenders()) {
        print('EditProfile: Failed to fetch genders');
        return false;
      }
      
      print('EditProfile: Fetching preferences...');
      if (!await controller.fetchPreferences()) {
        print('EditProfile: Failed to fetch preferences');
        return false;
      }
      
      print('EditProfile: Fetching languages...');
      if (!await controller.fetchlang()) {
        print('EditProfile: Failed to fetch languages');
        return false;
      }
      
      print('EditProfile: Fetching desires...');
      if (!await controller.fetchDesires()) {
        print('EditProfile: Failed to fetch desires');
        return false;
      }
      
      print('EditProfile: All data fetched successfully');
    return true;
    } catch (e, stackTrace) {
      print('EditProfile: Exception in fetchAllData: $e');
      print('EditProfile: Stack trace: $stackTrace');
      return false;
    }
  }

  initialize() async {
    try {
      print('EditProfile: Starting initialize...');
      
      // Check if required data is available
      if (controller.userData.isEmpty) {
        print('EditProfile: userData is empty, cannot initialize');
        throw Exception('User data not available');
      }
      
      if (controller.genders.isEmpty) {
        print('EditProfile: genders is empty, cannot initialize');
        throw Exception('Genders data not available');
      }
      
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
        print('EditProfile: Fetching sub-genders for gender: ${selectedGender.value!.id}');
        await controller.fetchSubGender(SubGenderRequest(
          genderId: selectedGender.value!.id,
        ));
      }

      if (controller.preferences.isNotEmpty) {
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
      }

      if (controller.userData.isNotEmpty) {
      latitudeController.text = controller.userData.first.latitude.isNotEmpty
          ? controller.userData.first.latitude
          : controller.userProfileUpdateRequest.latitude;

      longitudeController.text = controller.userData.first.longitude.isNotEmpty
          ? controller.userData.first.longitude
          : controller.userProfileUpdateRequest.longitude;
      }

      if (controller.desires.isNotEmpty) {
      selectedOptions = RxList<bool>.filled(controller.desires.length, false);
      }
      selectedDesires = controller.userDesire;
      
      print('EditProfile: Initialize completed successfully');
    } catch (e, stackTrace) {
      print('EditProfile: Error in initialize: $e');
      print('EditProfile: Stack trace: $stackTrace');
      failure('Error', e.toString());
      rethrow; // Re-throw to let _loadProfileData know initialization failed
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
    // Allow Unicode letters, spaces, and hyphens only
    if (!RegExp(r'^[\p{L}\p{M}\s\-]+$', unicode: true).hasMatch(value)) {
      failure(
          'RE-Enter', 'Name must contain only letters, spaces, and hyphens');
      return 'Name must contain only letters, spaces, and hyphens';
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
    // Allow Unicode letters, spaces, underscores, and hyphens only (no digits)
    if (!RegExp(r'^[\p{L}\p{M}\s\-_]+$', unicode: true).hasMatch(value)) {
      return 'Nickname must contain only letters, spaces, underscores, and hyphens';
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
      DateTime eighteenYearsAgo = today.subtract(Duration(
          days: (18 * 365) + 5)); // Added 5 days to account for leap years

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

    return GestureDetector(
      onTap: selectDate,
      child: AbsorbPointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15.0,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 8.0,
                    spreadRadius: -1.0,
                    offset: const Offset(-1, -1),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                cursorColor: AppColors.cursorColor,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: "Select your Date of Birth",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  errorText: errorText,
                ),
                onChanged: (value) {
                  onChanged(value);
                  validateInput(value);
                },
              ),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Builder(
            builder: (context) {
              double fontSize = MediaQuery.of(context).size.width * 0.05;
              return Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.white.withOpacity(0.9),
                ),
              );
            },
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GlassmorphismBackground(
          child: FutureBuilder<bool>(
            future: _fetchProfileFuture, //controller.fetchProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: Lottie.asset(
                      "assets/animations/editprofileanimation.json",
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      repeat: true,
                      reverse: false,
                      animate: true,
                    ));
              }
              if (snapshot.hasError) {
                return Center(
                  child: GlassSurface(
                    child: Text(
                      'Error loading user profile: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data != true) {
                return Center(
                  child: GlassSurface(
                    child: Text(
                      'No data available.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassTile(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Photos',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: (controller.userPhotos == null ||
                                      controller.userPhotos!.images.isEmpty)
                                  ? Center(
                                      child: Text(
                                        "No images available",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.userPhotos!.images.length,
                                      itemBuilder: (context, index) {
                                        String imageUrl = controller
                                            .userPhotos!.images[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: GestureDetector(
                                            onTap: () => showFullImageDialog(
                                                context, imageUrl),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: _isBase64Image(imageUrl)
                                                  ? Builder(
                                                      builder: (context) {
                                                        try {
                                                          String normalizedBase64 = _normalizeBase64(imageUrl);
                                                          return Image.memory(
                                                            base64Decode(normalizedBase64),
                                                            fit: BoxFit.cover,
                                                            width: MediaQuery.of(context).size.width * 0.3,
                                                            height: MediaQuery.of(context).size.height * 0.25,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Container(
                                                                width: MediaQuery.of(context).size.width * 0.3,
                                                                height: MediaQuery.of(context).size.height * 0.25,
                                                                alignment: Alignment.center,
                                                                color: Colors.grey.shade200,
                                                                child: const Icon(
                                                                  Icons.broken_image,
                                                                  size: 48,
                                                                  color: Colors.grey,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        } catch (e) {
                                                          return Container(
                                                            width: MediaQuery.of(context).size.width * 0.3,
                                                            height: MediaQuery.of(context).size.height * 0.25,
                                                            alignment: Alignment.center,
                                                            color: Colors.grey.shade200,
                                                            child: const Icon(
                                                              Icons.broken_image,
                                                              size: 48,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    )
                                                  : Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: MediaQuery.of(context).size.width * 0.3,
                                                      height: MediaQuery.of(context).size.height * 0.25,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          return child;
                                                        } else {
                                                          return Container(
                                                            width: MediaQuery.of(context).size.width * 0.3,
                                                            height: MediaQuery.of(context).size.height * 0.25,
                                                            alignment: Alignment.center,
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                      loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                              color: Colors.white.withOpacity(0.7),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          width: MediaQuery.of(context).size.width * 0.3,
                                                          height: MediaQuery.of(context).size.height * 0.25,
                                                          alignment: Alignment.center,
                                                          color: Colors.grey.shade200,
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            size: 48,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 4),
                            GlassButton(
                              text: 'Edit Photos',
                              icon: Icons.camera_alt,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditPhotosPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
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
                                  // Combined Personal Information Tile
                                  GlassTile(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name
                                        GlassInputField(
                                          label: 'Name',
                                          controller: TextEditingController(
                                            text: controller
                                                        .userProfileUpdateRequest
                                                        .name
                                                        .isNotEmpty
                                                    ? controller
                                                        .userProfileUpdateRequest.name
                                                    : controller.userData.first.name,
                                          ),
                                          onChanged: onUserNameChanged,
                                          validator: (value) {
                                            return validateName(value ?? '');
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Email
                                        GlassInputField(
                                          label: 'Email',
                                          controller: TextEditingController(text: controller.userData.first.email),
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 12),
                                        // Date of Birth
                                        dobPicker(
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
                                        const SizedBox(height: 12),
                                        // Nickname
                                        GlassInputField(
                                          label: 'Nick name',
                                          controller: TextEditingController(
                                            text: controller
                                                        .userProfileUpdateRequest
                                                        .nickname
                                                        .isNotEmpty
                                                    ? controller
                                                        .userProfileUpdateRequest.nickname
                                                    : controller.userData.first.nickname,
                                          ),
                                          onChanged: onNickNameChanged,
                                          validator: (value) {
                                            return validateNickname(value?.trim() ?? '');
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // About
                                        GlassInputField(
                                          label: 'About',
                                          controller: TextEditingController(
                                            text: controller
                                                        .userProfileUpdateRequest
                                                        .bio
                                                        .isNotEmpty
                                                    ? controller
                                                        .userProfileUpdateRequest.bio
                                                    : controller.userData.first.bio,
                                          ),
                                          maxLines: 5,
                                          onChanged: onAboutChanged,
                                          validator: (value) {
                                            return validateBio(value ?? '');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  // Combined Location & Language Tile
                                  GlassTile(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Country
                                        Text(
                                          "Country: ${controller.selectedCountry.value?.name ?? ''}",
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Obx(() {
                                          if (controller.countries.isEmpty) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white.withOpacity(0.7),
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
                                        const SizedBox(height: 12),
                                        // City
                                        GlassInputField(
                                          label: 'City',
                                          controller: TextEditingController(
                                            text: controller
                                                        .userProfileUpdateRequest
                                                        .city
                                                        .isNotEmpty
                                                    ? controller
                                                        .userProfileUpdateRequest.city
                                                    : controller.userData.first.city,
                                          ),
                                          onChanged: (value) {
                                            onCityChanged(value);
                                          },
                                          validator: (value) {
                                            return validateCity(value ?? '');
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Address
                                        GlassInputField(
                                          label: 'Address',
                                          controller: TextEditingController(
                                            text: controller
                                                        .userProfileUpdateRequest
                                                        .address
                                                        .isNotEmpty
                                                    ? controller
                                                        .userProfileUpdateRequest.address
                                                    : controller.userData.first.address,
                                          ),
                                          onChanged: onAddressChnaged,
                                          validator: (value) {
                                            return validateAddress(value ?? '');
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Languages
                                        _languagesContent(context),
                                      ],
                                    ),
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
                                        0.01,
                                  ),
                                  genderAndRelationship(context),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  preferencesAndDesires(context),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  GlassTile(
                                    margin: const EdgeInsets.only(bottom: 10),
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
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(12.0),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(12.0),
                                                          border: Border.all(
                                                            color: Colors.white.withOpacity(0.18),
                                                            width: 1.0,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.2),
                                                              blurRadius: 15.0,
                                                              offset: const Offset(0, 6),
                                                            ),
                                                            BoxShadow(
                                                              color: Colors.white.withOpacity(0.08),
                                                              blurRadius: 8.0,
                                                              spreadRadius: -1.0,
                                                              offset: const Offset(-1, -1),
                                                            ),
                                                          ],
                                                        ),
                                                        child: TextField(
                                                          controller: interestController,
                                                          cursorColor: AppColors.cursorColor,
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.9),
                                                            fontSize: 15,
                                                          ),
                                                          decoration: InputDecoration(
                                                            labelText: 'Type Your Interest Here...',
                                                            labelStyle: TextStyle(
                                                              color: Colors.white.withOpacity(0.7),
                                                              fontSize: 14,
                                                            ),
                                                            hintStyle: TextStyle(
                                                              color: Colors.white.withOpacity(0.5),
                                                              fontSize: 15,
                                                            ),
                                                            border: InputBorder.none,
                                                            enabledBorder: InputBorder.none,
                                                            focusedBorder: InputBorder.none,
                                                            errorBorder: InputBorder.none,
                                                            disabledBorder: InputBorder.none,
                                                            focusedErrorBorder: InputBorder.none,
                                                            contentPadding: const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 8,
                                                            ),
                                                          ),
                                                        ),
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
                                            runSpacing:
                                                8.0, // Added for vertical spacing
                                            children: List.generate(
                                                updatedSelectedInterests
                                                    .length, (index) {
                                              final interest =
                                                  updatedSelectedInterests[
                                                      index];
                                              return Container(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 12.0,
                                                        top: 8.0,
                                                        bottom: 8.0,
                                                        right: 8.0),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: AppColors
                                                        .gradientBackgroundList,
                                                    begin:
                                                        Alignment.topLeft,
                                                    end: Alignment
                                                        .bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      interest,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              Colors.white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                    ),
                                                    SizedBox(width: 8.0),
                                                    GestureDetector(
                                                      onTap: () {
                                                        deleteInterest(
                                                            index);
                                                        updateUserInterests();
                                                      },
                                                      child: Icon(
                                                        Icons.cancel,
                                                        color: Colors.white
                                                            .withOpacity(
                                                                0.8),
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
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
                      GlassTile(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10.0),
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
                                  if (!selectedOptions.contains(true)) {
                                    failure('Validation Error',
                                        'Desire is required. Please select at least one.');
                                    desiresError.value = true;
                                    return;
                                  }
                                  if (selectedLanguages.isEmpty) {
                                    print("select language");
                                    return;
                                  }
                                  // Update desires IDs before submission
                                  updateSelectedDesiresIds();
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
              ),
            );
          },
        ),
      ),
    );
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
            padding: const EdgeInsets.symmetric(vertical: 6.0),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15.0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 8.0,
                  spreadRadius: -1.0,
                  offset: const Offset(-1, -1),
                ),
              ],
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    );
                  }),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          padding: EdgeInsets.all(10.0),
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
        selectedDesires.map((d) => d.desiresId).toList();

    print('EditProfile: Controller Desires: ${controller.userDesire.length}');
    for (var ud in controller.userDesire) {
      int index =
          controller.desires.indexWhere((d) => d.id == ud.desiresId);
      if (index != -1) {
        print('EditProfile: Selected Desires: ${ud.desiresId} and index is: $index');
        selectedOptions[index] = true;
        selectedDesires.add(ud);
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
            padding: const EdgeInsets.all(10.0),
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
                                        backgroundColor:
                                            AppColors.darkGradientColor,
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: chipFontSize,
                                        ),
                                        deleteIcon: Icon(Icons.close,
                                            color: Colors.white70),
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
                                                  .map((ud) =>
                                                      ud.desiresId)
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
                          padding: const EdgeInsets.only(bottom: 4.0),
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
                              spacing: 6,
                              runSpacing: 6,
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
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Chip(
                                      label:
                                          Text(controller.desires[index].title),
                                      backgroundColor: selectedOptions[index]
                                          ? AppColors.mediumGradientColor
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
                        backgroundColor: AppColors.darkGradientColor,
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
  RxString selectedGenderDisplay = ''.obs; // For displaying selected gender
  RxString genderSearchQuery = ''.obs; // Search query for gender selection
  RxBool genderError = false.obs; // Error state for gender
  RxString selectedSubGenderDisplay = ''.obs; // For displaying selected sub-gender
  RxString subGenderSearchQuery = ''.obs; // Search query for sub-gender selection
  RxBool subGenderError = false.obs; // Error state for sub-gender
  RxBool subGenderNeedsSelection = false.obs; // Flag to indicate sub-gender needs selection after gender change
  RxString preferencesSearchQuery = ''.obs; // Search query for preferences selection
  RxString desiresSearchQuery = ''.obs; // Search query for desires selection

  Widget _languagesContent(BuildContext context) {
    // Initialize selectedLanguages if empty
    if (selectedLanguages.isEmpty) {
      selectedLanguages.addAll(controller.userLang.map((lang) => lang.title));
    }
    updateSelectedLanguageIds();
    controller.userProfileUpdateRequest.lang = selectedLanguagesId;

    // Update error state whenever languages list changes
    languageError.value = selectedLanguages.isEmpty;

    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Languages',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
            GlassButton(
              text: selectedLanguages.isEmpty ? 'Select' : 'Edit',
              icon: Icons.language,
              fontSize: 14,
              borderRadius: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: () {
                showLanguageSelectionBottomSheet(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (languageError.value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Language is required',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (selectedLanguages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No languages selected',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedLanguages.map((language) {
              return GestureDetector(
                onTap: () {
                  selectedLanguages.remove(language);
                  updateSelectedLanguageIds();
                  languageError.value = selectedLanguages.isEmpty;
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    top: 8.0,
                    bottom: 8.0,
                    right: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.cancel,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget languages(BuildContext context, {bool includeContainer = true}) {
    Widget content = _languagesContent(context);
    
    if (!includeContainer) {
      return content;
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: content,
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassSurface(
          margin: EdgeInsets.zero,
          borderRadius: 20.0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Languages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.9)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final searchController = TextEditingController(text: searchQuery.value);
                    return GlassInputField(
                      label: 'Search Languages',
                      hint: 'Type to search...',
                      controller: searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        searchQuery.value = value ?? '';
                        searchController.text = value ?? '';
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Obx(() {
                    if (controller.language.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language_outlined,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No languages available',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var filteredLanguages = controller.language
                        .where((language) => language.title
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase()))
                        .toList();

                    if (filteredLanguages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No languages found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: filteredLanguages.map((language) {
                          String languageTitle = language.title;
                          return Obx(() {
                            bool isSelected = selectedLanguages.contains(languageTitle);
                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  selectedLanguages.remove(languageTitle);
                                } else {
                                  if (!selectedLanguages.contains(languageTitle)) {
                                    selectedLanguages.add(languageTitle);
                                  }
                                }
                                updateSelectedLanguageIds();
                                languageError.value = selectedLanguages.isEmpty;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : AppColors.formFieldColor,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  languageTitle,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        updateSelectedLanguageIds();
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genderContent(BuildContext context) {
    // Initialize selectedGenderDisplay if empty
    if (selectedGenderDisplay.isEmpty) {
      if (selectedGender.value != null) {
        selectedGenderDisplay.value = selectedGender.value!.title;
      } else if (controller.userData.isNotEmpty) {
        String? genderFromUserData = controller.userData.first.gender;
        if (genderFromUserData.isNotEmpty) {
          try {
            selectedGender.value = controller.genders.firstWhere(
              (gender) => gender.id == genderFromUserData,
              orElse: () => controller.genders.first,
            );
            selectedGenderDisplay.value = selectedGender.value!.title;
          } catch (e) {
            // Gender not found, will be empty
          }
        }
      }
    }

    // Update error state
    genderError.value = selectedGender.value == null;

    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Gender',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Obx(() => GlassButton(
              text: selectedGenderDisplay.isEmpty ? 'Select' : 'Edit',
              icon: Icons.person,
              fontSize: 14,
              borderRadius: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: () {
                showGenderSelectionBottomSheet(context);
              },
            )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (genderError.value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Gender is required',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (selectedGenderDisplay.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No gender selected',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              GestureDetector(
                onTap: () {
                  selectedGender.value = null;
                  selectedGenderDisplay.value = '';
                  controller.userProfileUpdateRequest.gender = '';
                  genderError.value = true;
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    top: 8.0,
                    bottom: 8.0,
                    right: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedGenderDisplay.value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.cancel,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget gender(BuildContext context, {bool includeContainer = true}) {
    Widget content = _genderContent(context);
    
    if (!includeContainer) {
      return content;
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: content,
          ),
        ),
      ),
    );
  }

  void showGenderSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassSurface(
          margin: EdgeInsets.zero,
          borderRadius: 20.0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.9)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final searchController = TextEditingController(text: genderSearchQuery.value);
                    return GlassInputField(
                      label: 'Search Gender',
                      hint: 'Type to search...',
                      controller: searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        genderSearchQuery.value = value ?? '';
                        searchController.text = value ?? '';
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Obx(() {
                    if (controller.genders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No genders available',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var filteredGenders = controller.genders
                        .where((gender) => gender.title
                            .toLowerCase()
                            .contains(genderSearchQuery.value.toLowerCase()))
                        .toList();

                    if (filteredGenders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No genders found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: filteredGenders.map((gender) {
                          return Obx(() {
                            bool isSelected = selectedGender.value?.id == gender.id;
                            return GestureDetector(
                              onTap: () {
                                selectedGender.value = gender;
                                selectedGenderDisplay.value = gender.title;
                                final parsedGenderId = gender.id;
                                controller.userProfileUpdateRequest.gender = parsedGenderId.toString();
                                // Clear sub-gender when gender changes
                                selectedSubGender.value = '';
                                selectedSubGenderDisplay.value = '';
                                controller.userProfileUpdateRequest.subGender = '';
                                subGenderNeedsSelection.value = true;
                                subGenderError.value = true;
                                controller.fetchSubGender(SubGenderRequest(
                                  genderId: parsedGenderId.toString(),
                                ));
                                genderError.value = false;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : AppColors.formFieldColor,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  gender.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  text: 'Done',
                  icon: Icons.check,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _subGenderContent(BuildContext context) {
    // Initialize selectedSubGenderDisplay if empty
    if (selectedSubGenderDisplay.isEmpty && selectedSubGender.value.isNotEmpty && controller.subGenders.isNotEmpty) {
      try {
        final subGender = controller.subGenders.firstWhere(
          (sg) => sg.id == selectedSubGender.value,
        );
        selectedSubGenderDisplay.value = subGender.title;
      } catch (e) {
        // Sub-gender not found, try to initialize from userData
        if (controller.userData.isNotEmpty) {
          String? subGenderFromUserData = controller.userData.first.subGender;
          if (subGenderFromUserData.isNotEmpty && subGenderFromUserData == selectedSubGender.value) {
            // Wait for sub-genders to load
          }
        }
      }
    } else if (selectedSubGender.value.isEmpty && controller.userData.isNotEmpty && controller.subGenders.isNotEmpty) {
      String? subGenderFromUserData = controller.userData.first.subGender;
      if (subGenderFromUserData.isNotEmpty) {
        selectedSubGender.value = subGenderFromUserData;
        try {
          final subGender = controller.subGenders.firstWhere(
            (sg) => sg.id == subGenderFromUserData,
          );
          selectedSubGenderDisplay.value = subGender.title;
          subGenderNeedsSelection.value = false;
        } catch (e) {
          // Sub-gender not found
        }
      }
    }
    
    // Update display if sub-genders are loaded and we have a selected sub-gender
    if (selectedSubGender.value.isNotEmpty && selectedSubGenderDisplay.isEmpty && controller.subGenders.isNotEmpty) {
      try {
        final subGender = controller.subGenders.firstWhere(
          (sg) => sg.id == selectedSubGender.value,
        );
        selectedSubGenderDisplay.value = subGender.title;
      } catch (e) {
        // Sub-gender not found
      }
    }

    // Update error state - sub-gender is required if gender is selected
    if (selectedGender.value != null) {
      subGenderError.value = selectedSubGender.value.isEmpty;
    } else {
      subGenderError.value = false; // No error if no gender selected
    }

    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Sub Gender',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Obx(() {
                    if (subGenderNeedsSelection.value && selectedSubGender.value.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Obx(() => GlassButton(
              text: selectedSubGenderDisplay.isEmpty ? 'Select' : 'Edit',
              icon: Icons.person_outline,
              fontSize: 14,
              borderRadius: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: () {
                if (selectedGender.value == null) {
                  Get.snackbar('Error', 'Please select a gender first');
                  return;
                }
                showSubGenderSelectionBottomSheet(context);
              },
            )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (subGenderError.value && selectedGender.value != null) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Sub Gender is required',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (selectedSubGenderDisplay.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                selectedGender.value == null
                    ? 'Select a gender first'
                    : 'No sub gender selected',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              GestureDetector(
                onTap: () {
                  selectedSubGender.value = '';
                  selectedSubGenderDisplay.value = '';
                  controller.userProfileUpdateRequest.subGender = '';
                  subGenderError.value = selectedGender.value != null;
                  subGenderNeedsSelection.value = selectedGender.value != null;
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    top: 8.0,
                    bottom: 8.0,
                    right: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedSubGenderDisplay.value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.cancel,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget subGender(BuildContext context, {bool includeContainer = true}) {
    Widget content = _subGenderContent(context);
    
    if (!includeContainer) {
      return content;
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: content,
          ),
        ),
      ),
    );
  }

  void showSubGenderSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassSurface(
          margin: EdgeInsets.zero,
          borderRadius: 20.0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Sub Gender',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.9)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final searchController = TextEditingController(text: subGenderSearchQuery.value);
                    return GlassInputField(
                      label: 'Search Sub Gender',
                      hint: 'Type to search...',
                      controller: searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        subGenderSearchQuery.value = value ?? '';
                        searchController.text = value ?? '';
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Obx(() {
                    if (controller.subGenders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No sub genders available',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select a gender first',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var filteredSubGenders = controller.subGenders
                        .where((subGender) => subGender.title
                            .toLowerCase()
                            .contains(subGenderSearchQuery.value.toLowerCase()))
                        .toList();

                    if (filteredSubGenders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No sub genders found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: filteredSubGenders.map((subGender) {
                          return Obx(() {
                            bool isSelected = selectedSubGender.value == subGender.id;
                            return GestureDetector(
                              onTap: () {
                                selectedSubGender.value = subGender.id;
                                selectedSubGenderDisplay.value = subGender.title;
                                controller.userProfileUpdateRequest.subGender = subGender.id;
                                subGenderError.value = false;
                                subGenderNeedsSelection.value = false;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : AppColors.formFieldColor,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  subGender.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  text: 'Done',
                  icon: Icons.check,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget genderAndRelationship(BuildContext context) {
    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

    return GlassTile(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relationship Type at the top
          Obx(() {
            String initialLookingFor = controller
                    .userProfileUpdateRequest
                    .lookingFor
                    .isNotEmpty
                ? controller
                    .userProfileUpdateRequest.lookingFor
                : controller.userData.first.lookingFor;

            return buildSelectableFieldRelationship<String>(
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
            );
          }),
          const SizedBox(height: 12),
          // Gender
          _genderContent(context),
          const SizedBox(height: 12),
          // Sub Gender
          _subGenderContent(context),
        ],
      ),
    );
  }

  void updateSelectedPreferencesIds() {
    // Update controller.userProfileUpdateRequest.preferences with IDs
    // This matches the old logic: collect IDs from preferencesSelectedOptions
    List<String> selectedPreferences = [];
    for (int i = 0; i < preferencesSelectedOptions.length; i++) {
      if (preferencesSelectedOptions[i]) {
        selectedPreferences.add(controller.preferences[i].id);
      }
    }
    controller.userProfileUpdateRequest.preferences = selectedPreferences;
    preferencesError.value = !preferencesSelectedOptions.contains(true);
  }

  Widget preferences(BuildContext context) {
    // Initialize preferencesSelectedOptions from backend userPreferences
    // This matches the old logic in initialize() function (lines 567-579)
    // Use Obx to reactively initialize when data becomes available
    Obx(() {
      if (controller.preferences.isNotEmpty) {
        if (preferencesSelectedOptions.length != controller.preferences.length) {
          preferencesSelectedOptions.value =
              List<bool>.filled(controller.preferences.length, false);
          // Match userPreferences with preferences by ID and set selected options
          for (var p in controller.userPreferences) {
            int index = controller.preferences
                .indexWhere((preference) => preference.id == p.preferenceId);
            if (index != -1) {
              preferencesSelectedOptions[index] = true;
            }
          }
        }
      }
      return const SizedBox.shrink();
    });

    // Update error state
    preferencesError.value = !preferencesSelectedOptions.contains(true);

    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Preferences',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Obx(() => GlassButton(
                      text: !preferencesSelectedOptions.contains(true) ? 'Select' : 'Edit',
                      icon: Icons.favorite,
                      fontSize: 14,
                      borderRadius: 20.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      onPressed: () async {
                        // Ensure preferences are loaded before showing bottom sheet
                        if (controller.preferences.isEmpty) {
                          await controller.fetchPreferences();
                        }
                        showPreferencesSelectionBottomSheet(context);
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (preferencesError.value) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Preference is required',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                Obx(() {
                  // Get selected preferences based on preferencesSelectedOptions
                  List<String> selectedPrefs = [];
                  for (int i = 0; i < preferencesSelectedOptions.length && i < controller.preferences.length; i++) {
                    if (preferencesSelectedOptions[i]) {
                      selectedPrefs.add(controller.preferences[i].title);
                    }
                  }
                  
                  if (selectedPrefs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No preferences selected',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: selectedPrefs.map((preference) {
                      return GestureDetector(
                        onTap: () {
                          // Find the index and unselect it
                          int index = controller.preferences.indexWhere((p) => p.title == preference);
                          if (index != -1) {
                            preferencesSelectedOptions[index] = false;
                            updateSelectedPreferencesIds();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 12.0,
                            top: 8.0,
                            bottom: 8.0,
                            right: 8.0,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientBackgroundList,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                preference,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Icon(
                                Icons.cancel,
                                color: Colors.white.withOpacity(0.8),
                                size: 20.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showPreferencesSelectionBottomSheet(BuildContext context) {
    // Ensure preferencesSelectedOptions is initialized before showing bottom sheet
    if (controller.preferences.isNotEmpty && preferencesSelectedOptions.length != controller.preferences.length) {
      preferencesSelectedOptions.value =
          List<bool>.filled(controller.preferences.length, false);
      // Match userPreferences with preferences by ID and set selected options
      for (var p in controller.userPreferences) {
        int index = controller.preferences
            .indexWhere((preference) => preference.id == p.preferenceId);
        if (index != -1) {
          preferencesSelectedOptions[index] = true;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassSurface(
          margin: EdgeInsets.zero,
          borderRadius: 20.0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.9)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final searchController = TextEditingController(text: preferencesSearchQuery.value);
                    return GlassInputField(
                      label: 'Search Preferences',
                      hint: 'Type to search...',
                      controller: searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        preferencesSearchQuery.value = value ?? '';
                        searchController.text = value ?? '';
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Obx(() {
                    if (controller.preferences.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Loading preferences...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var filteredPreferences = controller.preferences
                        .where((preference) => preference.title
                            .toLowerCase()
                            .contains(preferencesSearchQuery.value.toLowerCase()))
                        .toList();

                    if (filteredPreferences.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No preferences found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: filteredPreferences.map((preference) {
                          // Find the index of this preference in controller.preferences
                          int preferenceIndex = controller.preferences.indexWhere((p) => p.id == preference.id);
                          return Obx(() {
                            bool isSelected = preferenceIndex != -1 && 
                                preferenceIndex < preferencesSelectedOptions.length &&
                                preferencesSelectedOptions[preferenceIndex];
                            return GestureDetector(
                              onTap: () {
                                if (preferenceIndex != -1) {
                                  // Toggle selection using preferencesSelectedOptions
                                  if (preferenceIndex < preferencesSelectedOptions.length) {
                                    preferencesSelectedOptions[preferenceIndex] = !preferencesSelectedOptions[preferenceIndex];
                                    updateSelectedPreferencesIds();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : AppColors.formFieldColor,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  preference.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  text: 'Done',
                  icon: Icons.check,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onPressed: () {
                    updateSelectedPreferencesIds();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateSelectedDesiresIds() {
    // Build list of selected desire IDs from selectedOptions
    List<String> selectedDesireIds = [];
    for (int i = 0; i < selectedOptions.length && i < controller.desires.length; i++) {
      if (selectedOptions[i]) {
        selectedDesireIds.add(controller.desires[i].id);
      }
    }
    controller.userProfileUpdateRequest.desires = selectedDesireIds;
    desiresError.value = !selectedOptions.contains(true);
    
    // Update selectedDesires list for display
    selectedDesires.clear();
    for (int i = 0; i < selectedOptions.length && i < controller.desires.length; i++) {
      if (selectedOptions[i]) {
        selectedDesires.add(UserDesire(
          desiresId: controller.desires[i].id,
          title: controller.desires[i].title,
        ));
      }
    }
  }

  // Widget desires(BuildContext context) {
  //   // Initialize selectedOptions from backend userDesire
  //   print('EditProfile: Desires: ${controller.userDesire.length}');
  //   for (var d in controller.userDesire) {
  //       print('EditProfile: Desires: ${d.desiresId} ${d.title}');
  //     }
  //   Obx(() {
  //     print('EditProfile: Controller Desires: ${controller.desires.length}');
  //     if (controller.desires.isNotEmpty) {
  //       // Initialize or update selectedOptions if needed
  //       print('EditProfile: Controller Desires: ${controller.desires.length}');
  //       bool needsInit = selectedOptions.length != controller.desires.length;
  //       if (needsInit) {
  //         selectedOptions.value = List<bool>.filled(controller.desires.length, false);
  //       }
        
  //       // Always sync with userDesire from backend (in case it changes)
  //       List<bool> updatedOptions = List<bool>.filled(controller.desires.length, false);
        
  //       // Match userDesire with desires by ID and set selected options
  //       for (var d in controller.userDesire) {
  //         int index = controller.desires.indexWhere((desire) => desire.id == d.desiresId);
  //         print('EditProfile: Desires: ${d.desiresId} ${d.title} and index is: $index');
  //        // selectedDesires.add(d);
  //         if (index != -1 && index < updatedOptions.length) {
  //           updatedOptions[index] = true;
  //         }
  //       }
        
  //       // Check if update is needed by comparing with current selectedOptions
  //       bool needsUpdate = needsInit;
  //       if (!needsUpdate && selectedOptions.length == updatedOptions.length) {
  //         for (int i = 0; i < selectedOptions.length; i++) {
  //           if (selectedOptions[i] != updatedOptions[i]) {
  //             needsUpdate = true;
  //             break;
  //           }
  //         }
  //       }
  //       print('EditProfile: Needs Update: $needsUpdate');
        
  //       // Update if there were changes
  //       if (needsUpdate) {
  //         selectedOptions.value = updatedOptions;
  //         // Update selectedDesires list
  //         updateSelectedDesiresIds();
  //       }
  //     }
  //     return const SizedBox.shrink();
  //   });

  //   // Update error state
  //   desiresError.value = !selectedOptions.contains(true);

  //   // Calculate font size
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   double bodyFontSize = screenWidth * 0.04;

  //   return DecoratedBoxTransition(
  //     decoration: decorationTween.animate(_animationController),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: AppColors.gradientBackgroundList,
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Card(
  //         elevation: 8,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         color: Colors.transparent,
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       'Desires',
  //                       style: AppTextStyles.bodyText.copyWith(
  //                         fontSize: bodyFontSize,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.textColor,
  //                       ),
  //                     ),
  //                   ),
  //                   Obx(() => GlassButton(
  //                     text: !selectedOptions.contains(true) ? 'Select' : 'Edit',
  //                     icon: Icons.favorite_border,
  //                     fontSize: 14,
  //                     borderRadius: 20.0,
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                     onPressed: () async {
  //                       // Ensure desires are loaded before showing bottom sheet
  //                       if (controller.desires.isEmpty) {
  //                         await controller.fetchDesires();
  //                       }
  //                       showDesiresSelectionBottomSheet(context);
  //                     },
  //                   )),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Obx(() {
  //                 if (desiresError.value) {
  //                   return Padding(
  //                     padding: const EdgeInsets.only(bottom: 4),
  //                     child: Text(
  //                       'Desire is required',
  //                       style: TextStyle(
  //                         color: Colors.red.shade300,
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   );
  //                 }
  //                 return const SizedBox.shrink();
  //               }),
  //               Obx(() {
  //                 // Ensure selectedOptions is initialized
  //                 if (controller.desires.isNotEmpty && selectedOptions.length != controller.desires.length) {
  //                   selectedOptions.value = List<bool>.filled(controller.desires.length, false);
  //                   // Match userDesire with desires by ID
  //                   for (var d in controller.userDesire) {
  //                     int index = controller.desires.indexWhere((desire) => desire.id == d.desiresId);
  //                     if (index != -1 && index < selectedOptions.length) {
  //                       selectedOptions[index] = true;
  //                     }
  //                   }
  //                   updateSelectedDesiresIds();
  //                 }
                  
  //                 // Get selected desires based on selectedOptions
  //                 List<String> selectedDesireTitles = [];
  //                 if (controller.desires.isNotEmpty && selectedOptions.length == controller.desires.length) {
  //                   for (int i = 0; i < selectedOptions.length && i < controller.desires.length; i++) {
  //                     if (selectedOptions[i]) {
  //                       selectedDesireTitles.add(controller.desires[i].title);
  //                     }
  //                   }
  //                 }
                  
  //                 if (selectedDesireTitles.isEmpty) {
  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 4),
  //                     child: Text(
  //                       'No desires selected',
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.5),
  //                         fontSize: 14,
  //                         fontStyle: FontStyle.italic,
  //                       ),
  //                     ),
  //                   );
  //                 }
  //                 return Wrap(
  //                   spacing: 8.0,
  //                   runSpacing: 8.0,
  //                   children: selectedDesireTitles.map((desire) {
  //                     return GestureDetector(
  //                       onTap: () {
  //                         // Find the index and unselect it
  //                         int index = controller.desires.indexWhere((d) => d.title == desire);
  //                         if (index != -1 && index < selectedOptions.length) {
  //                           selectedOptions[index] = false;
  //                           updateSelectedDesiresIds();
  //                         }
  //                       },
  //                       child: Container(
  //                         padding: const EdgeInsets.only(
  //                           left: 12.0,
  //                           top: 8.0,
  //                           bottom: 8.0,
  //                           right: 8.0,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: AppColors.gradientBackgroundList,
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomRight,
  //                           ),
  //                           borderRadius: BorderRadius.circular(25.0),
  //                           border: Border.all(
  //                             color: Colors.white,
  //                             width: 1.5,
  //                           ),
  //                         ),
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Text(
  //                               desire,
  //                               style: const TextStyle(
  //                                 fontSize: 15,
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                             const SizedBox(width: 8.0),
  //                             Icon(
  //                               Icons.cancel,
  //                               color: Colors.white.withOpacity(0.8),
  //                               size: 20.0,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //                 );
  //               }),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

Widget desires(BuildContext context) {
  // Static logs (runs once per build)
  print('EditProfile: userDesire length: ${controller.userDesire.length}');
  for (var d in controller.userDesire) {
    print('EditProfile: userDesire → ${d.desiresId} ${d.title}');
  }

  return Obx(() {
    // 🔥 THIS NOW EXECUTES
    print('EditProfile: controller.desires length: ${controller.desires.length}');

    /// -------------------------------
    /// 🔁 SYNC LOGIC (reactive)
    /// -------------------------------
    if (controller.desires.isNotEmpty) {
      final int len = controller.desires.length;
      bool needsInit = selectedOptions.length != len;

      // Init selectedOptions length
      if (needsInit) {
        selectedOptions.value = List<bool>.filled(len, false);
      }

      // Build updated selection list
      final List<bool> updatedOptions = List<bool>.filled(len, false);

      for (var d in controller.userDesire) {
        int index = controller.desires
            .indexWhere((desire) => desire.id == d.desiresId);

        print(
          'EditProfile: match desireId=${d.desiresId}, index=$index',
        );

        if (index != -1) {
          updatedOptions[index] = true;
        }
      }

      // Detect changes
      bool needsUpdate = needsInit;
      if (!needsUpdate) {
        for (int i = 0; i < len; i++) {
          if (selectedOptions[i] != updatedOptions[i]) {
            needsUpdate = true;
            break;
          }
        }
      }

      print('EditProfile: needsUpdate = $needsUpdate');

      if (needsUpdate) {
        selectedOptions.value = updatedOptions;
        updateSelectedDesiresIds();
      }
    }

    /// -------------------------------
    /// ❗ Error state (reactive)
    /// -------------------------------
    desiresError.value = !selectedOptions.contains(true);

    /// -------------------------------
    /// 📐 UI
    /// -------------------------------
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bodyFontSize = screenWidth * 0.04;

    // Selected desire titles
    final List<String> selectedTitles = [];
    if (controller.desires.isNotEmpty &&
        selectedOptions.length == controller.desires.length) {
      for (int i = 0; i < selectedOptions.length; i++) {
        if (selectedOptions[i]) {
          selectedTitles.add(controller.desires[i].title);
        }
      }
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------------------------------
                /// Header
                /// -------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Desires',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    GlassButton(
                      text: selectedTitles.isEmpty ? 'Select' : 'Edit',
                      icon: Icons.favorite_border,
                      fontSize: 14,
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      onPressed: () async {
                        if (controller.desires.isEmpty) {
                          await controller.fetchDesires();
                        }
                        showDesiresSelectionBottomSheet(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// -------------------------------
                /// Error
                /// -------------------------------
                if (desiresError.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Desire is required',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                /// -------------------------------
                /// Selected Chips
                /// -------------------------------
                if (selectedTitles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'No desires selected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedTitles.map((title) {
                      final int index = controller.desires
                          .indexWhere((d) => d.title == title);

                      return GestureDetector(
                        onTap: () {
                          if (index != -1) {
                            selectedOptions[index] = false;
                            updateSelectedDesiresIds();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientBackgroundList,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.cancel,
                                size: 20,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  });
}

  Widget preferencesAndDesires(BuildContext context) {
    // Calculate font size
    double screenWidth = MediaQuery.of(context).size.width;
    double bodyFontSize = screenWidth * 0.04;

    return GlassTile(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferences Section
          // Initialize preferencesSelectedOptions from backend userPreferences
          Obx(() {
            if (controller.preferences.isNotEmpty) {
              if (preferencesSelectedOptions.length != controller.preferences.length) {
                preferencesSelectedOptions.value =
                    List<bool>.filled(controller.preferences.length, false);
                // Match userPreferences with preferences by ID and set selected options
                for (var p in controller.userPreferences) {
                  int index = controller.preferences
                      .indexWhere((preference) => preference.id == p.preferenceId);
                  if (index != -1) {
                    preferencesSelectedOptions[index] = true;
                  }
                }
              }
            }
            return const SizedBox.shrink();
          }),

          // Update error state
          Obx(() {
            preferencesError.value = !preferencesSelectedOptions.contains(true);
            return const SizedBox.shrink();
          }),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Preferences',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Obx(() => GlassButton(
                text: !preferencesSelectedOptions.contains(true) ? 'Select' : 'Edit',
                icon: Icons.favorite,
                fontSize: 14,
                borderRadius: 20.0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: () async {
                  // Ensure preferences are loaded before showing bottom sheet
                  if (controller.preferences.isEmpty) {
                    await controller.fetchPreferences();
                  }
                  showPreferencesSelectionBottomSheet(context);
                },
              )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (preferencesError.value) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Preference is required',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            // Get selected preferences based on preferencesSelectedOptions
            List<String> selectedPrefs = [];
            for (int i = 0; i < preferencesSelectedOptions.length && i < controller.preferences.length; i++) {
              if (preferencesSelectedOptions[i]) {
                selectedPrefs.add(controller.preferences[i].title);
              }
            }
            
            if (selectedPrefs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'No preferences selected',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: selectedPrefs.map((preference) {
                return GestureDetector(
                  onTap: () {
                    // Find the index and unselect it
                    int index = controller.preferences.indexWhere((p) => p.title == preference);
                    if (index != -1) {
                      preferencesSelectedOptions[index] = false;
                      updateSelectedPreferencesIds();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preference,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          Icons.cancel,
                          color: Colors.white.withOpacity(0.8),
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Desires Section
          Builder(
            builder: (context) {
              // Static logs (runs once per build)
              print('EditProfile: userDesire length: ${controller.userDesire.length}');
              for (var d in controller.userDesire) {
                print('EditProfile: userDesire → ${d.desiresId} ${d.title}');
              }

              return Obx(() {
                // 🔥 THIS NOW EXECUTES
                print('EditProfile: controller.desires length: ${controller.desires.length}');

                /// -------------------------------
                /// 🔁 SYNC LOGIC (reactive)
                /// -------------------------------
                if (controller.desires.isNotEmpty) {
                  final int len = controller.desires.length;
                  bool needsInit = selectedOptions.length != len;

                  // Init selectedOptions length
                  if (needsInit) {
                    selectedOptions.value = List<bool>.filled(len, false);
                  }

                  // Build updated selection list
                  final List<bool> updatedOptions = List<bool>.filled(len, false);

                  for (var d in controller.userDesire) {
                    int index = controller.desires
                        .indexWhere((desire) => desire.id == d.desiresId);

                    print(
                      'EditProfile: match desireId=${d.desiresId}, index=$index',
                    );

                    if (index != -1) {
                      updatedOptions[index] = true;
                    }
                  }

                  // Detect changes
                  bool needsUpdate = needsInit;
                  if (!needsUpdate) {
                    for (int i = 0; i < len; i++) {
                      if (selectedOptions[i] != updatedOptions[i]) {
                        needsUpdate = true;
                        break;
                      }
                    }
                  }

                  print('EditProfile: needsUpdate = $needsUpdate');

                  if (needsUpdate) {
                    selectedOptions.value = updatedOptions;
                    updateSelectedDesiresIds();
                  }
                }

                /// -------------------------------
                /// ❗ Error state (reactive)
                /// -------------------------------
                desiresError.value = !selectedOptions.contains(true);

                // Selected desire titles
                final List<String> selectedTitles = [];
                if (controller.desires.isNotEmpty &&
                    selectedOptions.length == controller.desires.length) {
                  for (int i = 0; i < selectedOptions.length; i++) {
                    if (selectedOptions[i]) {
                      selectedTitles.add(controller.desires[i].title);
                    }
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// -------------------------------
                    /// Header
                    /// -------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Desires',
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: bodyFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        GlassButton(
                          text: selectedTitles.isEmpty ? 'Select' : 'Edit',
                          icon: Icons.favorite_border,
                          fontSize: 14,
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          onPressed: () async {
                            if (controller.desires.isEmpty) {
                              await controller.fetchDesires();
                            }
                            showDesiresSelectionBottomSheet(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// -------------------------------
                    /// Error
                    /// -------------------------------
                    if (desiresError.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Desire is required',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    /// -------------------------------
                    /// Selected Chips
                    /// -------------------------------
                    if (selectedTitles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'No desires selected',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedTitles.map((title) {
                          final int index = controller.desires
                              .indexWhere((d) => d.title == title);

                          return GestureDetector(
                            onTap: () {
                              if (index != -1) {
                                selectedOptions[index] = false;
                                updateSelectedDesiresIds();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.gradientBackgroundList,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                );
              });
            },
          ),
        ],
      ),
    );
  }

  void showDesiresSelectionBottomSheet(BuildContext context) {
    // Ensure selectedOptions is initialized before showing bottom sheet
    if (controller.desires.isNotEmpty && selectedOptions.length != controller.desires.length) {
      selectedOptions.value = List<bool>.filled(controller.desires.length, false);
      // Match userDesire with desires by ID and set selected options
      for (var d in controller.userDesire) {
        int index = controller.desires.indexWhere((desire) => desire.id == d.desiresId);
        if (index != -1) {
          selectedOptions[index] = true;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassSurface(
          margin: EdgeInsets.zero,
          borderRadius: 20.0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Desires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.9)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final searchController = TextEditingController(text: desiresSearchQuery.value);
                    return GlassInputField(
                      label: 'Search Desires',
                      hint: 'Type to search...',
                      controller: searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        desiresSearchQuery.value = value ?? '';
                        searchController.text = value ?? '';
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Obx(() {
                    if (controller.desires.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Loading desires...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var filteredDesires = controller.desires
                        .where((desire) => desire.title
                            .toLowerCase()
                            .contains(desiresSearchQuery.value.toLowerCase()))
                        .toList();

                    if (filteredDesires.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No desires found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: filteredDesires.map((desire) {
                          // Find the index of this desire in controller.desires
                          int desireIndex = controller.desires.indexWhere((d) => d.id == desire.id);
                          return Obx(() {
                            bool isSelected = desireIndex != -1 && 
                                desireIndex < selectedOptions.length &&
                                selectedOptions[desireIndex];
                            return GestureDetector(
                              onTap: () {
                                if (desireIndex != -1) {
                                  // Toggle selection using selectedOptions
                                  if (desireIndex < selectedOptions.length) {
                                    selectedOptions[desireIndex] = !selectedOptions[desireIndex];
                                    updateSelectedDesiresIds();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : AppColors.formFieldColor,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  desire.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  text: 'Done',
                  icon: Icons.check,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onPressed: () {
                    updateSelectedDesiresIds();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showFullImageDialog(BuildContext context, String imagePath) {
  // Helper function to normalize base64 string
  String normalizeBase64(String base64) {
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    clean = clean.trim();
    int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  // Helper function to check if a string is a base64 image
  bool isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return false;
    }
    if (image.startsWith('/') && image.length > 50) {
      if (image.startsWith('/9j/') || image.startsWith('/iVB')) {
        try {
          String normalized = normalizeBase64(image);
          base64Decode(normalized);
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    String cleanImage = image.contains(',') ? image.split(',')[1] : image;
    cleanImage = cleanImage.trim();
    if (cleanImage.length < 20) return false;
    try {
      String normalized = normalizeBase64(cleanImage);
      base64Decode(normalized);
      return true;
    } catch (e) {
      return false;
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: isBase64Image(imagePath)
                ? Builder(
                    builder: (context) {
                      try {
                        String normalizedBase64 = normalizeBase64(imagePath);
                        return Image.memory(
                          base64Decode(normalizedBase64),
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          errorBuilder: (context, error, stackTrace) {
                            print('Full image dialog base64 decode error: $error');
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      } catch (e) {
                        print('Error decoding base64 in full image dialog: $e');
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  )
                : Image.network(
              imagePath,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
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
  final bool readOnly;

  const InfoField({
    super.key,
    required this.initialValue,
    required this.label,
    required this.onChanged,
    required this.validator,
    this.readOnly = false,
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
    // Stop and reset the animation before disposing
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.reset();
    _animationController.dispose();
    // Note: debounce Timer will auto-cleanup when widget is disposed
    // Don't dispose GetX controller - it's managed by GetX
    // controller.dispose();
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
          padding: const EdgeInsets.all(8.0),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
