import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Models/RequestModels/change_password_request.dart';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/change_password_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_benifites_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_faq_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_gender_from_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_headlines_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_packages_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_saftey_guidelines_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import 'package:dating_application/Models/ResponseModels/subgender_response_model.dart';
import 'package:dating_application/Models/ResponseModels/user_upload_images_response_model.dart';
import 'package:dating_application/Providers/change_password_provider.dart';
import 'package:dating_application/Providers/fetch_all_desires_provider.dart';
import 'package:dating_application/Providers/fetch_all_faq_provider.dart';
import 'package:dating_application/Providers/fetch_all_headlines_provider.dart';
import 'package:dating_application/Providers/fetch_all_preferences_provider.dart';
import 'package:dating_application/Providers/fetch_all_safety_guildlines_provider.dart';
import 'package:dating_application/Providers/login_provider.dart';
import 'package:dating_application/Providers/share_profile_provider.dart';
import 'package:dating_application/Providers/user_profile_provider.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../Models/RequestModels/block_User_request_model.dart';
import '../Models/RequestModels/delete_message_request_model.dart';
import '../Models/RequestModels/edit_message_request_model.dart';
import '../Models/RequestModels/estabish_connection_request_model.dart';
import '../Models/RequestModels/forget_password_request_model.dart';
import '../Models/RequestModels/forget_password_verification_request_model.dart';
import '../Models/RequestModels/liked_by_request_model.dart';
import '../Models/RequestModels/pin_profile_pic_request_model.dart';
import '../Models/RequestModels/registration_otp_request_model.dart';
import '../Models/RequestModels/registration_otp_verification_request_model.dart';
import '../Models/RequestModels/report_user_reason_feedback_request_model.dart';
import '../Models/RequestModels/share_profile_request_model.dart';
import '../Models/RequestModels/update_emailid_otp_verification_request_model.dart';
import '../Models/RequestModels/update_emailid_request_model.dart';
import '../Models/RequestModels/update_lat_long_request_model.dart';
import '../Models/RequestModels/update_profile_photo_request_model.dart';
import '../Models/RequestModels/update_visibility_status_request_model.dart';
import '../Models/RequestModels/user_profile_update_request_model.dart';
import '../Models/RequestModels/user_registration_request_model.dart';
import '../Models/ResponseModels/ProfileResponse.dart';
import '../Models/ResponseModels/all_active_user_resposne_model.dart';
import '../Models/ResponseModels/app_details_response_model.dart';
import '../Models/ResponseModels/block_user_response_model.dart';
import '../Models/ResponseModels/chat_history_response_model.dart';
import '../Models/ResponseModels/connected_user_response_model.dart';
import '../Models/ResponseModels/delete_message_response_model.dart';
import '../Models/ResponseModels/edit_message_response_model.dart';
import '../Models/ResponseModels/establish_connection_response_model.dart';
import '../Models/ResponseModels/forget_password_response_model.dart';
import '../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/get_all_desires_model_response.dart';
import '../Models/ResponseModels/get_all_language_response_model.dart';
import '../Models/ResponseModels/get_report_user_options_response_model.dart';
import '../Models/ResponseModels/like_history_response_model.dart';
import '../Models/ResponseModels/liked_by_response_model.dart';
import '../Models/ResponseModels/pin_profile_pic_response_model.dart';
import '../Models/ResponseModels/registration_otp_response_model.dart';
import '../Models/ResponseModels/registration_otp_verification_response_model.dart';
import '../Models/ResponseModels/report_user_reason_feedback_response_model.dart';
import '../Models/ResponseModels/share_profile_response_model.dart';
import '../Models/ResponseModels/update_emailid_otp_verification_response_model.dart';
import '../Models/ResponseModels/update_emailid_response_model.dart';
import '../Models/ResponseModels/update_lat_long_response_model.dart';
import '../Models/ResponseModels/update_profile_photo_response_model.dart';
import '../Models/ResponseModels/update_visibility_status_response_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../Models/ResponseModels/user_profile_update_response_model.dart';
import '../Models/ResponseModels/user_registration_response_model.dart';
import '../Models/ResponseModels/user_suggestions_response_model.dart';
import '../Providers/block_user_provider.dart';
import '../Providers/chat_message_page_provider.dart';
import '../Providers/connected_user_provider.dart';
import '../Providers/delete_message_provider.dart';
import '../Providers/edit_message_provider.dart';
import '../Providers/established_connection_message_provider.dart';
import '../Providers/fetch_all_active_user_provider.dart';
import '../Providers/fetch_all_countries_provider.dart';
import '../Providers/fetch_all_genders_provider.dart';
import '../Providers/fetch_all_language_provider.dart';
import '../Providers/fetch_all_packages_provider.dart';
import '../Providers/fetch_benefits_provider.dart';
import '../Providers/fetch_sub_genders_provider.dart';
import '../Providers/home_page_provider.dart';
import '../Providers/likes_history_provider.dart';
import '../Providers/master_setting_provider.dart';
import '../Providers/pin_profile_pic_provider.dart';
import '../Providers/post_like_provider.dart';
import '../Providers/registration_provider.dart';
import '../Providers/report_against_user_provider.dart';
import '../Providers/report_reason_provider.dart';
import '../Providers/update_email_verification_provider.dart';
import '../Providers/update_emailid_provider.dart';
import '../Providers/update_latitude_longitude_provider.dart';
import '../Providers/update_profile_photo_provider.dart';
import '../Providers/update_profile_provider.dart';
import '../Providers/update_visibility_status_provider.dart';
import '../Providers/user_registration_provider.dart';
import '../Providers/user_suggestions_provider.dart';
import '../Screens/login.dart';
import '../constants.dart';

class Controller extends GetxController {
  Future<void> storeUserData(UserLoginResponse userLoginResponse) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      await preferences.setString('token', userLoginResponse.payload.token);
      await preferences.setString('userId', userLoginResponse.payload.userId);
      await preferences.setString('email', userLoginResponse.payload.email);
      await preferences.setString('contact', userLoginResponse.payload.contact);
    } catch (e) {
      failure('Error', e.toString());
    }
  }

  UserRegistrationRequest userRegistrationRequest = UserRegistrationRequest(
    name: '',
    email: '',
    mobile: '',
    latitude: '',
    longitude: '',
    address: '',
    password: '',
    countryId: '',
    city: '',
    dob: '',
    nickname: '',
    gender: '',
    subGender: '',
    preferences: [],
    desires: [],
    interest: '',
    bio: '',
    imgcount: '',
    lang: [],
    photos: [],
    packageId: '',
    emailAlerts: '',
    username: '',
    lookingFor: '',
  );

  Future<bool> register(UserRegistrationRequest userRegistrationRequest) async {
    try {
      final UserRegistrationResponse? response =
          await UserRegistrationProvider()
              .userRegistration(userRegistrationRequest);

      if (response != null && response.success) {
        success('Success', response.payload.message);
        Get.offAll(Login());
        return true;
      } else {
        failure('Error', 'Registration failed. Please try again.');
        return false;
      }
    } catch (e) {
      failure('Error', 'An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  Future<bool> login(dynamic userLoginRequest) async {
    try {
      final UserLoginResponse? response =
          await LoginProvider().userLogin(userLoginRequest);

      if (response != null) {
        await storeUserData(response);
        success('Success', 'Login successful!');
        return true;
      } else {
        failure('Error', 'Login failed. Please check your credentials.');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RegistrationOTPRequest registrationOTPRequest =
      RegistrationOTPRequest(email: '', name: '');

  Future<bool> getOtpForRegistration(
      RegistrationOTPRequest registrationOTPRequest) async {
    try {
      final RegistrationOtpResponse? response = await RegistrationProvider()
          .getOtpForRegistration(registrationOTPRequest);
      if (response != null) {
        String message = response.payload.message;
        RegExp otpRegExp = RegExp(r'(\d{6})');
        Match? otpMatch = otpRegExp.firstMatch(message);
        EncryptedSharedPreferences prefs =
            EncryptedSharedPreferences.getInstance();
        await prefs.setString(
            'registrationemail', registrationOTPRequest.email);
        if (otpMatch != null) {
          String otp = otpMatch.group(0) ?? 'OTP not found';

          EncryptedSharedPreferences prefs =
              EncryptedSharedPreferences.getInstance();
          await prefs.setString('registrationotp', otp);
          success('OTP Received', 'Your OTP is: $otp');
          success('success', response.payload.message);
          return true;
        } else {
          failure('Error', 'OTP not found in the response');
          return false;
        }
      }
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> otpVerificationForRegistration(
      RegistrationOtpVerificationRequest
          registrationOtpVerificationRequest) async {
    try {
      final RegistrationOtpVerificationResponse? response =
          await RegistrationProvider().otpVerificationForRegistration(
              registrationOtpVerificationRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      }
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Country> countries = <Country>[].obs;

  Future<bool> fetchCountries() async {
    try {
      countries.clear();

      final CountryResponse? response =
          await FetchAllCountriesProvider().fetchCountries();

      if (response != null && response.payload.data.isNotEmpty) {
        countries.addAll(response.payload.data);
        success('Success', 'Countries fetched successfully');
        return true;
      } else {
        failure('Error', 'No countries found in the response');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  String getCountryById(String id) {
    try {
      final country = countries.firstWhere((c) => c.id == id);
      return country.name;
    } catch (e) {
      return "Country not found";
    }
  }

  RxList<Language> language = <Language>[].obs;

  Future<bool> fetchlang() async {
    try {
      language.clear();

      final GetAllLanguagesResponse? response =
          await FetchAllLanguageProvider().fetchlang();

      if (response != null && response.payload.data.isNotEmpty) {
        language.addAll(response.payload.data);
        success('Success', 'Languages fetched successfully');
        return true;
      } else {
        failure('Error', 'No Languages found in the response');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  

  RxList<Message> messages = <Message>[].obs;
  Future<bool> chatHistory() async {
    try {
      messages.clear();
      final ChatHistoryResponse? response =
          await ChatMessagePageProvider().chatHistory();
      if (response != null) {
        messages.addAll(response.payload.data);
        for (var m in messages) {
          print(m.toJson().toString());
        }

        success('success', 'chat history fetched successfully');
        return true;
      } else {
        failure('Error', 'Error fetching the chat history');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Category> categories = <Category>[].obs;
  Future<bool> fetchDesires() async {
    try {
      categories.clear();
      final DesiresResponse? response =
          await FetchAllDesiresProvider().fetchDesires();
      if (response != null) {
        categories.addAll(response.payload.data);
        success('success', 'successfully fetched all the desires');
        return true;
      } else {
        failure('Error', 'Error fetching the desires');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<UserData> userData = <UserData>[].obs;
  RxList<UserDesire> userDesire = <UserDesire>[].obs;
  RxList<UserPreferences> userPreferences = <UserPreferences>[].obs;
  RxList<UserLang> userLang = <UserLang>[].obs;
  Future<bool> fetchProfile() async {
    try {
      userData.clear();
      userDesire.clear();
      userPreferences.clear();
      userLang.clear();
      UserProfileResponse? response = await HomePageProvider().fetchProfile();
      if (response != null) {
        userData.addAll(response.payload.data);
        userDesire.addAll(response.payload.desires);
        userPreferences.addAll(response.payload.preferences);
        userLang.addAll(response.payload.lang);
        success('success', 'successfully fetched the user profile');
        return true;
      } else {
        failure('Error', 'Error fetching the user profile');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<UserDetails> userDetails = <UserDetails>[].obs;
  Future<bool> fetchAllActiveUsers() async {
    try {
      final AllActiveUsersResponse? response =
          await HomePageProvider().fetchAllActiveUsers();
      if (response != null) {
        userDetails.addAll(response.payload.data);
        success('success', 'successfully fetched all the active users');
        return true;
      } else {
        failure('Error', 'Error fetching all active users');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Gender> genders = <Gender>[].obs;

  Future<bool> fetchGenders() async {
    try {
      genders.clear();
      GenderResponse? response = await FetchAllGendersProvider().fetchGenders();
      if (response != null) {
        genders.addAll(response.payload.data);
        success('success', 'Genders fetched successfully');
        return true;
      } else {
        failure('Error', 'Error fetching the genders');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<UserPreference> preferences = <UserPreference>[].obs;
  Future<bool> fetchPreferences() async {
    try {
      preferences.clear();
      UserPreferencesResponse? response =
          await FetchAllPreferencesProvider().fetchPreferences();
      if (response != null) {
        preferences.addAll(response.payload.data);
        success('success', 'User preferences fetched successfully');
        return true;
      } else {
        failure('Error', 'Error fetching the preferences');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Benefit> benefits = <Benefit>[].obs;
  RxString selectedBenefit = 'None'.obs;
  Future<bool> fetchBenefits() async {
    try {
      benefits.clear();
      BenefitsResponse? response =
          await FetchBenefitsProvider().fetchBenefits();
      if (response != null) {
        benefits.addAll(response.payload.data);
        success('success', 'Successfully fetched the benefits');
        return true;
      } else {
        failure('Error', 'Failed to fetch the benefits');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  var packages = <Package>[].obs;

  Future<bool> fetchAllPackages() async {
    try {
      packages.clear();

      GetAllPackagesResponseModel? response =
          await FetchAllPackagesProvider().fetchAllPackages();

      if (response != null && response.success) {
        packages.addAll(response.payload.data);
        success('Success', 'Successfully fetched all the packages');
        return true;
      } else {
        failure('Error', response?.error.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      failure('Error', 'An exception occurred: ${e.toString()}');
      return false;
    }
  }

  RxList<SafetyGuideline> safetyGuidelines = <SafetyGuideline>[].obs;

  Future<bool> fetchSafetyGuidelines() async {
    try {
      safetyGuidelines.clear();
      SafetyGuidelinesResponse? response =
          await FetchAllSafetyGuildlinesProvider().fetchAllSafetyGuidelines();
      if (response != null) {
        safetyGuidelines.addAll(response.payload.data);
        success('success', 'successfully fetched the safety guidelines');
        return true;
      } else {
        failure('Error', 'Failed to fetch the safety guidelines');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<SubGenderData> subGenders = <SubGenderData>[].obs;
  Future<bool> fetchSubGender(SubGenderRequest subGenderRequest) async {
    try {
      subGenders.clear();
      SubGenderResponse? response =
          await FetchSubGendersProvider().getSubGenders(subGenderRequest);
      if (response != null) {
        subGenders.addAll(response.payload.data);
        success('success', 'successfully fetched the sub genders');
        return true;
      } else {
        failure('Error', 'Failed to fetch the sub genders');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UserImageData? userPhotos;
  Future<bool> fetchProfileUserPhotos() async {
    try {
      UserUploadImagesResponse? response =
          await UserProfileProvider().fetchProfileUserPhotos();
      if (response != null && response.payload != null) {
        userPhotos = response.payload!.data;
        success('success', 'successfully fetched the user profile photos');
        return true;
      } else {
        failure('Error', 'Failed to fetch the  user profile photos');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  ChangePasswordRequest changePasswordRequest =
      ChangePasswordRequest(oldPassword: '', newPassword: '');
  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      ChangePasswordResponse? response =
          await ChangePasswordProvider().changePassword(request);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to change the password');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> deleteMessage(DeleteMessageRequest request) async {
    try {
      DeleteMessageResponse? response =
          await DeleteMessageProvider().deleteMessage(request);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to delete the message');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> editMessage(EditMessageRequest request) async {
    try {
      EditMessageResponse? response =
          await EditMessageProvider().editMessage(request);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to edit the message');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> sendConnectionMessage(
      EstablishConnectionMessageRequest request) async {
    try {
      EstablishConnectionResponse? response =
          await EstablishConnectionProvider().sendConnectionMessage(request);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to send the connection message');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<UserDetails> activeUsers = <UserDetails>[].obs;
  Future<bool> getAllActiveUser() async {
    try {
      activeUsers.clear();
      AllActiveUsersResponse? response =
          await FetchAllActiveUserProvider().getAllActiveUser();
      if (response != null) {
        activeUsers.addAll(response.payload.data);
        success('success', 'Successfully fetched all the active users');
        return true;
      } else {
        failure('Error', 'Failed to get all the active users');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Headline> headlines = <Headline>[].obs;

  Future<bool> fetchAllHeadlines() async {
    try {
      headlines.clear();
      HeadlinesResponse? response =
          await FetchAllHeadlinesProvider().fetchAllHeadlines();
      if (response != null) {
        headlines.addAll(response.payload.data);
        success('success', 'successfully fetched all the headlines');
        return true;
      } else {
        failure('Error', 'Failed to fetch the headlines');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  ForgetPasswordRequest forgetPasswordRequest =
      ForgetPasswordRequest(email: '', newPassword: '');
  Future<void> storeOtp(String otp) async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setString('otp', otp);
  }

  Future<bool> getOtpForgetPassword(
      ForgetPasswordRequest forgetPasswordRequest) async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setString('forgetpasswordemail', forgetPasswordRequest.email);
    await prefs.setString('forgetpassword', forgetPasswordRequest.newPassword);

    try {
      // Call the API to get OTP
      ForgetPasswordResponse? response =
          await LoginProvider().getOtpForgetPassword(forgetPasswordRequest);

      if (response != null) {
        // Extract OTP from the message
        String message = response.payload.message;
        print(message);

        // Regex to match the OTP in the message
        RegExp otpRegExp = RegExp(r'(\d{6})'); // 6-digit OTP
        Match? otpMatch = otpRegExp.firstMatch(message);

        if (otpMatch != null) {
          // Extract OTP
          String otp = otpMatch.group(0)!;
          success('Success', 'OTP sent successfully: $otp');

          // Optionally, store the OTP for future use (if needed)
          await storeOtp(otp);

          return true; // OTP extraction succeeded
        } else {
          failure('Error', 'OTP not found in the message');
          return false; // OTP extraction failed
        }
      } else {
        failure('Error', 'Failed to get the OTP');
        return false; // API response was null
      }
    } catch (e) {
      failure('Error', e.toString());
      return false; // Handle exception
    }
  }

  ForgetPasswordVerificationRequest forgetPasswordVerificationRequest =
      ForgetPasswordVerificationRequest(email: '', otp: '', password: '');
  Future<bool> otpVerificationForgetPassword(
      ForgetPasswordVerificationRequest
          forgetPasswordVerificationRequest) async {
    try {
      ForgetPasswordVerificationResponse? response = await LoginProvider()
          .otpVerificationForgetPassword(forgetPasswordVerificationRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to verify otp for forget password');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateEmailIdRequest updateEmailIdRequest =
      UpdateEmailIdRequest(password: '', newEmail: '');
  Future<bool> updateEmailId(UpdateEmailIdRequest updateEmailIdRequest) async {
    try {
      UpdateEmailIdResponse? response =
          await UpdateEmailidProvider().updateEmailId(updateEmailIdRequest);
      EncryptedSharedPreferences prefs =
          EncryptedSharedPreferences.getInstance();
      await prefs.setString('update_email', updateEmailIdRequest.newEmail);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to update email');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateEmailVerificationRequest updateEmailVerificationRequest =
      UpdateEmailVerificationRequest(newEmail: '', otp: '');
  Future<bool> verifyEmailOtp(UpdateEmailVerificationRequest request) async {
    try {
      UpdateEmailVerificationResponse? response =
          await UpdateEmailVerificationProvider().verifyEmailOtp(request);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to verify otp for email');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UserProfileUpdateRequest userProfileUpdateRequest = UserProfileUpdateRequest(
    name: "",
    latitude: "",
    longitude: "",
    address: "",
    countryId: "",
    state: "",
    city: "",
    dob: "",
    nickname: "",
    gender: "",
    subGender: "",
    lang: [],
    interest: '',
    bio: '',
    visibility: '',
    emailAlerts: '',
    preferences: [],
    desires: [],
  );

  Future<bool> updateProfile(
      UserProfileUpdateRequest updateProfileRequest) async {
    try {
      UserProfileUpdateResponse? response =
          await UpdateProfileProvider().updateProfile(updateProfileRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to update the profile');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<String?> addOrUpdateImage(int photos) async {
    try {
      // Request necessary permissions
      if (!await requestCameraPermission()) {
        return 'Camera permission denied';
      }
      if (!await requestLocationPermission()) {
        return 'Location permission denied';
      }

      // Pick image from the camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // Compress the image
        final compressedImage = await FlutterImageCompress.compressWithFile(
          image.path, // Correctly pass the image path here
          quality: 50, // Compression quality (adjust as needed)
        );

        if (compressedImage != null) {
          // Convert the compressed image to base64
          String base64Image = base64Encode(compressedImage);

          // Save the image path and base64 data based on the page
          if (photos == 1) {
            userRegistrationRequest.photos.add(base64Image);
          } else if (photos == 2) {
            userRegistrationRequest.photos.add(base64Image);
          } else if (photos == 3) {
            userRegistrationRequest.photos.add(base64Image);
          } else if (photos == 4) {
            userRegistrationRequest.photos.add(base64Image);
          } else {
            return 'Invalid page number';
          }

          return base64Image;
        } else {
          failure('Error', 'Image compression failed');
          return null;
        }
      } else {
        return 'No image selected';
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<String?> addOrUpdateGalleryImage(int page) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final File galleryImage = File(image.path);

        // Compress the image
        final compressedImage = await FlutterImageCompress.compressWithFile(
          galleryImage.path,
          quality: 50,
        );

        if (compressedImage != null) {
          final String base64Image = base64Encode(compressedImage);

          // Add the image to the photos list for the respective page
          switch (page) {
            case 1:
              userRegistrationRequest.photos.add(base64Image);
              break;
            case 2:
              userRegistrationRequest.photos.add(base64Image);
              break;
            case 3:
              userRegistrationRequest.photos.add(base64Image);
              break;
            case 4:
              userRegistrationRequest.photos.add(base64Image);
              break;
            default:
              return 'Invalid page number';
          }

          return base64Image;
        } else {
          failure('Error', 'Failed to compress the image');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<String?> chooseSourceToPickImage(String ch, int page) async {
    String? base64EncodedImage;

    if (ch == "C") {
      await addOrUpdateImage(page).then((value) {
        base64EncodedImage = value; // Get base64 image data from camera
      });
    } else if (ch == "G") {
      await addOrUpdateGalleryImage(page).then((value) {
        base64EncodedImage = value; // Get base64 image data from gallery
      });
    }
    return base64EncodedImage;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Future<bool> requestStoragePermission() async {
  //   final status = await Permission.storage.request();
  //   return status.isGranted;
  // }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();

    // Check if the permission is granted
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // You can show a dialog or snackbar to inform the user why the permission is needed
      // and prompt them to allow it.
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();

      return false;
    }
    failure("Manually Open Setting ", "Allow all to open camera");
    return false; // Handle other cases as needed
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  BlockToRequestModel blockToRequestModel = BlockToRequestModel(blockto: '');

  Future<bool> blockUser(BlockToRequestModel blockToRequestModel) async {
    try {
      BlockUserResponseModel? response =
          await BlockUserProvider().blockUser(blockToRequestModel);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to block the user');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  ReportUserReasonFeedbackRequestModel reportUserReasonFeedbackRequestModel =
      ReportUserReasonFeedbackRequestModel(
          reportAgainst: '', reasonId: '', reason: '');
  Future<bool> reportAgainstUser(
      ReportUserReasonFeedbackRequestModel
          reportUserReasonFeedbackRequestModel) async {
    try {
      ReportUserReasonFeedbackResponseModel? response =
          await ReportUserProvider()
              .reportAgainstUser(reportUserReasonFeedbackRequestModel);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to report the user');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<ReportReason> reportReasons = <ReportReason>[].obs;
  Future<bool> reportReason() async {
    try {
      reportReasons.clear();
      ReportUserForBlockOptionsResponseModel? response =
          await ReportReasonProvider().reportReason();
      if (response != null) {
        success('success', response.payload.message);
        reportReasons.addAll(response.payload.data);

        return true;
      } else {
        failure('Error', 'Failed to fetch the reasons of report');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateProfilePhotoRequest updateProfilePhotoRequest =
      UpdateProfilePhotoRequest(
          img1: '', img2: '', img3: '', img4: '', img5: '', img6: '');
  Future<bool> updateprofilephoto(
      UpdateProfilePhotoRequest updateProfilePhotoRequest) async {
    try {
      UserProfileUpdatePhotoResponse? response =
          await UpdateProfilePhotoProvider()
              .updateprofilephoto(updateProfilePhotoRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to report the user');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateLatLongRequest updateLatLongRequest = UpdateLatLongRequest(
    latitude: '',
    longitude: '',
    city: '',
    address: '',
  );
  Future<bool> updatelatlong(UpdateLatLongRequest updateLatLongRequest) async {
    try {
      UpdateLatLongResponse? response = await UpdateLatitudeLongitudeProvider()
          .updatelatlong(updateLatLongRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to report the user');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxMap<String, RxList<User>> userSuggestionsMap = <String, RxList<User>>{
    'desireBase': <User>[].obs,
    'locationBase': <User>[].obs,
    'preferenceBase': <User>[].obs,
  }.obs;

  Future<bool> userSuggestions() async {
    try {
      UserSuggestionsResponseModel? response =
          await UserSuggestionsProvider().userSuggestions();
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);

        if (response.payload!.desireBase != null &&
            response.payload!.desireBase!.isNotEmpty) {
          userSuggestionsMap['desireBase']!
              .assignAll(response.payload!.desireBase!);
        }

        if (response.payload!.locationBase != null &&
            response.payload!.locationBase!.isNotEmpty) {
          userSuggestionsMap['locationBase']!
              .assignAll(response.payload!.locationBase!);
        }

        if (response.payload!.preferenceBase != null &&
            response.payload!.preferenceBase!.isNotEmpty) {
          userSuggestionsMap['preferenceBase']!
              .assignAll(response.payload!.preferenceBase!);
        }

        return true;
      } else {
        failure('Error', 'Failed to fetch the user suggestions');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> postLike(LikeModel likeModel) async {
    try {
      LikedByResponseModel? response =
          await PostLikeProvider().postLike(likeModel);
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        return true;
      }

      failure('Error', 'Failed to process the like request.');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Connection> connections = <Connection>[].obs;

  Future<bool> connectedUser() async {
    try {
      connections.clear();
      ConnectedUserResponseModel? response =
          await ConnectedUserProvider().connectedUser();
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        if (response.payload!.data != null &&
            response.payload!.data!.isNotEmpty) {
          connections.addAll(response.payload!.data!);
          return true;
        } else {
          return true;
        }
      }
      failure('Error', 'Failed to fetch the connections.');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<LikeData> likes = <LikeData>[].obs;
  Future<bool> likedHistory() async {
    try {
      likes.clear();
      LikeHistoryResponse? response =
          await LikesHistoryProvider().likedHistory();
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        if (response.payload!.data != null &&
            response.payload!.data!.isNotEmpty) {
          likes.addAll(response.payload!.data!);
          return true;
        } else {
          return true;
        }
      }

      failure('Error', 'Failed to fetch the connections');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> pinProfilePic(
      PinProfilePicRequestModel pinProfilePicRequestModel) async {
    try {
      PinProfilePicResponseModel? response = await PinProfilePicProvider()
          .pinProfilePic(pinProfilePicRequestModel);
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        return true;
      }

      failure('Error', 'Failed to pin the profile pic.');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  AppDetailsData? appDetails;
  Future<bool> masterSetting() async {
    try {
      AppDetailsResponse? response =
          await MasterSettingProvider().masterSetting();
      if (response != null && response.payload != null) {
        success('Success', response.payload!.msg);
        appDetails = response.payload?.data;
        return true;
      }

      failure('Error', 'Failed to fetch the application settings');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> updateVisibilityStatus(
      UpdateVisibilityStatusRequestModel
          updateVisibilityStatusRequestModel) async {
    try {
      UpdateVisibilityStatusResponseModel? response =
          await UpdateVisibilityStatusProvider()
              .updateVisibilityStatus(updateVisibilityStatusRequestModel);
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        return true;
      }
      failure('Error', 'Failed to update the visibility status');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  void shareProfile(String userId) {
    String profileLink = 'myapp://profile?userId=$userId';
    Share.share('Check out this profile: $profileLink');
  }

  ShareProfileResponseModel? sharedUser;
  Future<ShareProfileResponseModel?> shareProfileUser(
      ShareProfileRequestModel shareProfileRequestModel) async {
    try {
      ShareProfileResponseModel? response = await ShareProfileProvider()
          .shareProfileUser(shareProfileRequestModel);
      if (response != null && response.payload != null) {
        sharedUser = response;
        return sharedUser;
      }
      failure('Error', 'Failed to fetch the shared profile');
      return null;
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  RxList<FAQItem> faq = <FAQItem>[].obs;

  Future<FAQResponseModel?> fetchAllFaq() async {
    try {
      faq.clear();
      final FAQResponseModel? response = await FetchAllFaqProvider().fetchFaq();
      if (response != null && response.payload.data.isNotEmpty) {
        faq.addAll(response.payload.data);
        // for (var v in response.payload.data) {
        //   print(v.toJson().toString());
        // }
        success('Success', 'FAQs fetched successfully');
        return response;
      } else {
        failure('Error', 'No FAQs found in the response');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
