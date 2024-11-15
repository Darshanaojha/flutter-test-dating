import 'package:dating_application/Providers/login_provider.dart';
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
      final DesiresResponse? response = await HomePageProvider().fetchDesires();
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
}
