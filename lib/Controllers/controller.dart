import 'package:dating_application/Models/RequestModels/change_password_request.dart';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/change_password_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_benifites_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_gender_from_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_headlines_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_saftey_guidelines_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import 'package:dating_application/Models/ResponseModels/subgender_response_model.dart';
import 'package:dating_application/Models/ResponseModels/user_upload_images_response_model.dart';
import 'package:dating_application/Providers/change_password_provider.dart';
import 'package:dating_application/Providers/fetch_all_desires_provider.dart';
import 'package:dating_application/Providers/fetch_all_headlines_provider.dart';
import 'package:dating_application/Providers/fetch_all_preferences_provider.dart';
import 'package:dating_application/Providers/fetch_all_safety_guildlines_provider.dart';
import 'package:dating_application/Providers/login_provider.dart';
import 'package:dating_application/Providers/login_provider.dart';
import 'package:dating_application/Providers/user_profile_provider.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/RequestModels/registration_otp_request_model.dart';
import '../Models/RequestModels/registration_otp_verification_request_model.dart';
import '../Models/RequestModels/user_registration_request_model.dart';
import '../Models/ResponseModels/ProfileResponse.dart';
import '../Models/ResponseModels/all_active_user_resposne_model.dart';
import '../Models/ResponseModels/chat_history_response_model.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/get_all_desires_model_response.dart';
import '../Models/ResponseModels/registration_otp_response_model.dart';
import '../Models/ResponseModels/registration_otp_verification_response_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../Models/ResponseModels/user_registration_response_model.dart';
import '../Providers/chat_message_page_provider.dart';
import '../Providers/home_page_provider.dart';
import '../Providers/registration_provider.dart';
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

  Future<bool> register(UserRegistrationRequest userRegistrationRequest) async {
    try {
      final UserRegistrationResponse? response =
          await RegistrationProvider().register(userRegistrationRequest);
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

  Future<bool> sendOtp(RegistrationOTPRequest registrationOTPRequest) async {
    try {
      final RegistrationOtpResponse? response =
          await RegistrationProvider().sendOtp(registrationOTPRequest);
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

  Future<bool> otpVerification(
      RegistrationOtpVerificationRequest
          registrationOtpVerificationRequest) async {
    try {
      final RegistrationOtpVerificationResponse? response =
          await RegistrationProvider()
              .otpVerification(registrationOtpVerificationRequest);
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
          await RegistrationProvider().fetchCountries();

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

  RxList<Message> messages = <Message>[].obs;
  Future<bool> chatHistory() async {
    try {
      messages.clear();
      final ChatHistoryResponse? response =
          await ChatMessagePageProvider().chatHistory();
      if (response != null) {
        messages.addAll(response.payload.data);
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
      final DesiresResponse? response = await FetchAllDesiresProvider().fetchDesires();
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
  Future<bool> fetchProfile() async {
    try {
      userData.clear();
      ProfileResponse? response = await HomePageProvider().fetchProfile();
      if (response != null) {
        userData.addAll(response.payload.data);
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
      GenderResponse? response = await UserProfileProvider().fetchGenders();
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

  Future<bool> fetchBenefits() async {
    try {
      benefits.clear();
      BenefitsResponse? response = await UserProfileProvider().fetchBenefits();
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

  RxList<Headline> headlines = <Headline>[].obs;
  Future<bool> fetchHeadlines() async {
    try {
      headlines.clear();
      HeadlinesResponse? response =
          await FetchAllHeadlinesProvider().fetchAllHeadlines();
      if (response != null) {
        headlines.addAll(response.payload.data);
        success('success', 'successfully fetched the headlines');
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

  RxList<SubGenderData> subGenders = <SubGenderData>[].obs;
  Future<bool> fetchSubGender(SubGenderRequest subGenderRequest) async {
    try {
      subGenders.clear();
      SubGenderResponse? response =
          await UserProfileProvider().fetchSubGender(subGenderRequest);
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

  late UserImageData userPhotos;
  Future<bool> fetchProfileUserPhotos() async {
    try {
      UserUploadImagesResponse? response =
          await UserProfileProvider().fetchProfileUserPhotos();
      if (response != null) {
        userPhotos = response.payload.data;
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
}
