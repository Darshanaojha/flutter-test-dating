import 'package:dating_application/Providers/ReferalCodeProvider.dart';
import 'package:dating_application/Providers/activity_status_provider.dart';
import 'package:dating_application/Providers/add_user_to_hookup_provider.dart';
import 'package:dating_application/Providers/app_setting_provider.dart';
import 'package:dating_application/Providers/check_package_provider.dart';
import 'package:dating_application/Providers/creator_order_provider.dart';
import 'package:dating_application/Providers/creators_all_content_provider.dart';
import 'package:dating_application/Providers/creators_all_orders_provider.dart';
import 'package:dating_application/Providers/creators_generic_provider.dart';
import 'package:dating_application/Providers/creatos_subscription_history_provider.dart';
import 'package:dating_application/Providers/delete_chat_history_provider.dart'
    show DeleteChatHistoryProvider;
import 'package:dating_application/Providers/fetch_all_add_on_provider.dart';
import 'package:dating_application/Providers/fetch_all_chat_history_page.dart';
import 'package:dating_application/Providers/fetch_all_creator_package_provider.dart';
import 'package:dating_application/Providers/fetch_all_faq_provider.dart';
import 'package:dating_application/Providers/fetch_all_favourites_provider.dart';
import 'package:dating_application/Providers/fetch_all_introslider_provider.dart';
import 'package:dating_application/Providers/fetch_subscripted_package_provider.dart';
import 'package:dating_application/Providers/get_content_by_id_provider.dart';
import 'package:dating_application/Providers/get_rejection_message.dart';
import 'package:dating_application/Providers/home_page_dislike_provider.dart';
import 'package:dating_application/Providers/share_profile_provider.dart';
import 'package:dating_application/Screens/loginforgotpassword/forgotpasswordotp.dart';
import 'package:dating_application/Screens/userprofile/membership/membershippage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../Models/ResponseModels/GetPointCreditedDebitedResponse.dart';
import '../Models/ResponseModels/GetUsersTotalPointsResponse.dart';
import '../Models/ResponseModels/ProfileResponse.dart';
import '../Models/ResponseModels/ReferalCodeResponse.dart';
import '../Models/ResponseModels/all_active_user_resposne_model.dart';
import '../Models/ResponseModels/all_orders_response_model.dart';
import '../Models/ResponseModels/all_transactions_response_model.dart'
    as AllTransactions;
import '../Models/ResponseModels/app_details_response_model.dart';
import '../Models/ResponseModels/app_setting_response_model.dart';
import '../Models/ResponseModels/block_user_response_model.dart';
import '../Models/ResponseModels/chat_history_response_model.dart';
import '../Models/ResponseModels/chat_response.dart';
import '../Models/ResponseModels/creator_transaction_history_response.dart';
import '../Models/ResponseModels/delete_message_response_model.dart';
import '../Models/ResponseModels/dislike_profile_response_model.dart';
import '../Models/ResponseModels/edit_message_response_model.dart';
import '../Models/ResponseModels/establish_connection_response_model.dart';
import '../Models/ResponseModels/forget_password_response_model.dart';
import '../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../Models/ResponseModels/get_all_addon_response_model.dart';
import '../Models/ResponseModels/get_all_chat_history_page.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/get_all_desires_model_response.dart';
import '../Models/ResponseModels/get_all_language_response_model.dart';
import '../Models/ResponseModels/get_all_like_history_response_model.dart';
import '../Models/ResponseModels/get_all_likes_pages_response.dart';
import '../Models/ResponseModels/get_all_subscripted_package_model.dart';
import '../Models/ResponseModels/get_all_verification_response_model.dart';
import '../Models/ResponseModels/get_report_user_options_response_model.dart';
import '../Models/ResponseModels/highlight_profile_status_response_model.dart';
import '../Models/ResponseModels/homepage_dislike_response_model.dart';
import '../Models/ResponseModels/liked_by_response_model.dart';
import '../Models/ResponseModels/marksasfavourite_response_model.dart';
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
import '../Models/ResponseModels/usernameupdate_response_model.dart';
import '../Models/ResponseModels/verify_account_response_model.dart';
import '../Providers/GetAllCreatorsProvider.dart';
import '../Providers/GetPointAmountProvider.dart';
import '../Providers/GetPointCreditedDebitedProvider.dart';
import '../Providers/add_user_to_creator_provider.dart';
import '../Providers/block_user_provider.dart';
import '../Providers/creator_transaction_history_provider.dart';
import '../Providers/delete_message_provider.dart';
import '../Providers/deletefavourite_provider_model.dart';
import '../Providers/dislike_profile_provider.dart';
import '../Providers/edit_message_provider.dart';
import '../Providers/established_connection_message_provider.dart';
import '../Providers/fcmService.dart';
import '../Providers/fetch_all_active_user_provider.dart';
import '../Providers/fetch_all_countries_provider.dart';
import '../Providers/fetch_all_genders_provider.dart';
import '../Providers/fetch_all_likes_history_provider.dart';
import '../Providers/fetch_all_packages_provider.dart';
import '../Providers/fetch_all_request_message_provider.dart';
import '../Providers/fetch_benefits_provider.dart';
import '../Providers/fetch_likes_page_provider.dart';
import '../Providers/fetch_sub_genders_provider.dart';
import '../Providers/fetch_verificationtype_provider.dart';
import '../Providers/highlight_profile_status_provider.dart';
import '../Providers/home_page_provider.dart';
import '../Providers/markasfavourite_provider.dart';
import '../Providers/master_setting_provider.dart';
import '../Providers/order_provider.dart';
import '../Providers/pin_profile_pic_provider.dart';
import '../Providers/post_like_provider.dart';
import '../Providers/profile_like_provider.dart';
import '../Providers/registration_provider.dart';
import '../Providers/report_against_user_provider.dart';
import '../Providers/report_reason_provider.dart';
import '../Providers/updateStatusProvider.dart';
import '../Providers/update_email_verification_provider.dart';
import '../Providers/update_emailid_provider.dart';
import '../Providers/update_hookup_status_provider.dart';
import '../Providers/update_incognito_mode_provider.dart';
import '../Providers/update_latitude_longitude_provider.dart';
import '../Providers/update_profile_photo_provider.dart';
import '../Providers/update_profile_provider.dart';
import '../Providers/update_visibility_status_provider.dart';
import '../Providers/updating_package_provider.dart';
import '../Providers/user_registration_provider.dart';
import '../Providers/user_suggestions_provider.dart';
import '../Providers/user_total_points_provider.dart';
import '../Providers/usernameupdate_provider.dart';
import '../Providers/verify_account_provider.dart';
import '../Providers/login_provider.dart';
import '../Providers/chat_provider.dart';
import '../Providers/fetch_all_language_provider.dart';
import '../Providers/fetch_all_desires_provider.dart';
import '../Providers/fetch_all_preferences_provider.dart';
import '../Providers/fetch_all_safety_guildlines_provider.dart';
import '../Providers/user_profile_provider.dart';
import '../Providers/change_password_provider.dart';
import '../Providers/fetch_all_headlines_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Screens referenced
import '../Screens/userprofile/accountverification/useraccountverification.dart';
import '../Screens/navigationbar/unsubscribenavigation.dart';
import '../Screens/auth.dart';
import '../Screens/navigationbar/navigationpage.dart';
import '../Screens/register_subpag/registerdetails.dart';
import '../Screens/register_subpag/registrationotp.dart';
import '../Screens/settings/updateemailid/updateemailotpverification.dart';
import '../constants.dart';
import '../Database/database_helper.dart';
import '../utils/logger.dart';
import 'package:logging/logging.dart';

// Request models
import '../Models/RequestModels/add_user_to_creator_request.dart';
import '../Models/RequestModels/app_setting_request_model.dart';
import '../Models/RequestModels/block_User_request_model.dart';
import '../Models/RequestModels/delete_message_request_model.dart';
import '../Models/RequestModels/deletefavourite_request_model.dart';
import '../Models/RequestModels/dislike_profile_request_model.dart';
import '../Models/RequestModels/edit_message_request_model.dart';
import '../Models/RequestModels/estabish_connection_request_model.dart';
import '../Models/RequestModels/forget_password_request_model.dart';
import '../Models/RequestModels/forget_password_verification_request_model.dart';
import '../Models/RequestModels/highlight_profile_status_request_model.dart';
import '../Models/RequestModels/homepage_dislike_request_model.dart';
import '../Models/RequestModels/liked_by_request_model.dart';
import '../Models/RequestModels/marksasfavourite_request_model.dart';
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
import '../Models/RequestModels/user_login_request_model.dart';
import '../Models/RequestModels/user_profile_update_request_model.dart';
import '../Models/RequestModels/user_registration_request_model.dart';
import '../Models/RequestModels/usernameupdate_request_model.dart';
import '../Models/RequestModels/verify_account_request_model.dart';
import '../Models/RequestModels/homepage_dislike_request_model.dart';
import '../Models/RequestModels/ReferalCodeRequestModel.dart';
import '../Models/RequestModels/profile_like_request_model.dart';
import '../Models/RequestModels/subgender_request_model.dart';
import '../Models/RequestModels/change_password_request.dart';
import '../Models/RequestModels/update_activity_status_request_model.dart';
import '../Models/RequestModels/creator_order_request_model.dart';
import '../Models/RequestModels/delete_chat_history_request_model.dart';
import '../Models/RequestModels/send_message_request_model.dart';
import '../Models/RequestModels/chat_history_request_model.dart';
import '../Models/RequestModels/transaction_request_model.dart';
import '../Models/RequestModels/order_request_model.dart';
import '../Models/RequestModels/updating_package_request_model.dart';

// Response models (ensure needed types are available)
import '../Models/ResponseModels/all_transactions_response_model.dart';
import '../Models/ResponseModels/creator_package_response.dart';
import '../Models/ResponseModels/get_all_benifites_response_model.dart';
import '../Models/ResponseModels/ReferalCodeResponse.dart';
import '../Models/ResponseModels/creators_subscription_history_response.dart';
import '../Models/ResponseModels/get_all_request_message_response.dart';
import '../Models/ResponseModels/edit_message_response_model.dart';
import '../Models/ResponseModels/creator_order_response_model.dart';
import '../Models/ResponseModels/GetUsersTotalPointsResponse.dart';
import '../Models/ResponseModels/change_password_response_model.dart';
import '../Models/ResponseModels/creators_content_model.dart';
import '../Models/ResponseModels/get_all_subscripted_package_model.dart';
import '../Models/ResponseModels/get_content_by_id_response.dart';
import '../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/update_lat_long_response_model.dart';
import '../Models/ResponseModels/app_details_response_model.dart';
import '../Models/ResponseModels/connected_user_response_model.dart';
import '../Models/ResponseModels/user_profile_update_response_model.dart';
import '../Models/ResponseModels/delete_message_response_model.dart';
import '../Models/ResponseModels/get_all_headlines_response_model.dart';
import '../Models/ResponseModels/subgender_response_model.dart';
import '../Models/ResponseModels/user_status_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../Models/ResponseModels/registration_otp_verification_response_model.dart';
import '../Models/ResponseModels/get_all_desires_model_response.dart';
import '../Models/ResponseModels/order_response_model.dart';
import '../Models/ResponseModels/delete_chat_history_response.dart';
import '../Models/ResponseModels/get_all_introslider_response.dart';
import '../Models/ResponseModels/creators_generic_response.dart';
import '../Models/ResponseModels/get_all_like_history_response_model.dart';
import '../Models/ResponseModels/liked_by_response_model.dart';
import '../Models/ResponseModels/fetch_all_creators_response.dart';
import '../Models/ResponseModels/homepage_dislike_response_model.dart';
import '../Models/ResponseModels/report_user_reason_feedback_response_model.dart';
import '../Models/ResponseModels/update_creator_content_response.dart';
import '../Models/ResponseModels/ProfileResponse.dart';
import '../Models/ResponseModels/pin_profile_pic_response_model.dart';
import '../Models/ResponseModels/block_user_response_model.dart';
import '../Models/ResponseModels/add_user_to_content_response.dart';
import '../Models/ResponseModels/all_orders_response_model.dart';
import '../Models/ResponseModels/creator_transaction_response.dart';
import '../Models/ResponseModels/update_emailid_otp_verification_response_model.dart';
import '../Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import '../Models/ResponseModels/updateStatusResponse.dart';
import '../Models/ResponseModels/establish_connection_response_model.dart';
import '../Models/ResponseModels/add_user_to_creator_response.dart';
import '../Models/ResponseModels/user_suggestions_response_model.dart';
import '../Models/ResponseModels/registration_otp_response_model.dart';
import '../Models/ResponseModels/highlight_profile_status_response_model.dart';
import '../Models/ResponseModels/GetAllCreatorsResponse.dart';
import '../Models/ResponseModels/share_profile_response_model.dart';
import '../Models/ResponseModels/deletefavourite_response_model.dart';
import '../Models/ResponseModels/usernameupdate_response_model.dart';
import '../Models/ResponseModels/user_registration_response_model.dart';
import '../Models/ResponseModels/update_visibility_status_response_model.dart';
import '../Models/ResponseModels/subscribed_content_response.dart';
import '../Models/ResponseModels/chat_history_response_model.dart';
import '../Models/ResponseModels/creator_transaction_history_response.dart';
import '../Models/ResponseModels/get_all_faq_response_model.dart';
import '../Models/ResponseModels/update_emailid_response_model.dart';
import '../Models/ResponseModels/all_active_user_resposne_model.dart';
import '../Models/ResponseModels/forget_password_response_model.dart';
import '../Models/ResponseModels/get_all_addon_response_model.dart';
import '../Models/ResponseModels/get_all_packages_response_model.dart';
import '../Models/ResponseModels/verify_account_response_model.dart';
import '../Models/ResponseModels/get_all_likes_pages_response.dart';
import '../Models/ResponseModels/update_profile_photo_response_model.dart';
import '../Models/ResponseModels/creators_all_orders_response.dart';
import '../Models/ResponseModels/get_all_chat_history_page.dart';
import '../Models/ResponseModels/creator_by_creator_response.dart';
import '../Models/ResponseModels/GetPointCreditedDebitedResponse.dart';
import '../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../Models/ResponseModels/app_setting_response_model.dart';
import '../Models/ResponseModels/activity_status_response_model.dart';
import '../Models/ResponseModels/get_all_verification_response_model.dart';
import '../Models/ResponseModels/get_all_favourites_response_model.dart';
import '../Models/ResponseModels/get_all_creators_packages_model.dart';
import '../Models/ResponseModels/profile_like_response_model.dart';
import '../Models/ResponseModels/GetPointAmountResponse.dart';
import '../Models/ResponseModels/updating_package_response_model.dart';
import '../Models/ResponseModels/get_all_language_response_model.dart';
import '../Models/ResponseModels/chat_response.dart';
import '../Models/ResponseModels/dislike_profile_response_model.dart';
import '../Models/ResponseModels/transaction_response_model.dart';
import '../Models/ResponseModels/user_upload_images_response_model.dart';
import '../Models/ResponseModels/get_all_saftey_guidelines_response_model.dart';
import '../Models/ResponseModels/marksasfavourite_response_model.dart';
import '../Models/ResponseModels/get_report_user_options_response_model.dart';

class Controller extends GetxController {
  final Logger logger = setup_logger(); // Initialize the logger
  RxString token = ''.obs;

  Future<void> storeUserData(UserLoginResponse userLoginResponse) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      await preferences.setString('token', userLoginResponse.payload.token);
      await preferences.setString('userId', userLoginResponse.payload.userId);
      await preferences.setString('email', userLoginResponse.payload.email);
      await preferences.setString('contact', userLoginResponse.payload.contact);
      await preferences.setString('status', userLoginResponse.payload.status);
      await preferences.setString(
          'package_status', userLoginResponse.payload.packagestatus);
      debugPrint(
          "User Token save : ${preferences.getString('token').toString()}");
      token.value = userLoginResponse.payload.token;
    } catch (e) {
      failure('Error storeUserData', e.toString());
    }
  }

  bool isSeenUser = false;

  UserRegistrationRequest userRegistrationRequest = UserRegistrationRequest(
    name: '',
    email: '',
    mobile: '',
    countryCode: '',
    referalcode: '',
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
    emailAlerts: '',
    username: '',
    lookingFor: '',
  );

  Future<Map<String, String>?> register(
      UserRegistrationRequest userRegistrationRequest) async {
    try {
      final UserRegistrationResponse? response =
          await UserRegistrationProvider()
              .userRegistration(userRegistrationRequest);

      print(response);

      if (response != null && response.success) {
        success('Success', response.payload.message);

        // Assuming request has email & password fields
        // return {
        //   'email': userRegistrationRequest.email,
        //   'password': userRegistrationRequest.password,
        // };
        final loginRequest = UserLoginRequest(
          email: userRegistrationRequest.email,
          password: userRegistrationRequest.password,
        );
        print("loginRequest.email");
        print(loginRequest.email);
        print("ginRequest.pasword");
        print(loginRequest.password);
        UserLoginResponse? responses = await login(loginRequest);
        if (responses != null) {
          if (responses.success == true) {
            String packagestatus = responses.payload.packagestatus;
            if (packagestatus == '0') {
              FCMService().subscribeToTopic("unsubscribed");
              FCMService().subscribeToTopic(responses.payload.userId);
              FCMService().subscribeToTopic("alluser");
              Get.offAll(Unsubscribenavigation());
            } else if (packagestatus == '1') {
              FCMService().subscribeToTopic("subscribed");
              FCMService().subscribeToTopic(responses.payload.userId);
              FCMService().subscribeToTopic("alluser");
              Get.offAll(NavigationBottomBar());
            }
          } else {
            Get.snackbar(
              'Login Failed',
              'Invalid credentials or network error.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        failure('Error', 'Registration failed. Please try again.');
        return null;
      }
    } catch (e) {
      failure(
          'Error register', 'An unexpected error occurred: ${e.toString()}');
      return null;
    }
    return null;
  }

  Future<UserLoginResponse?> login(dynamic userLoginRequest) async {
    try {
      final UserLoginResponse? response =
          await LoginProvider().userLogin(userLoginRequest);

      if (response != null) {
        await storeUserData(response);
        success('Success', 'Login successful!');

        return response;
      } else {
        failure('Error', 'Login failed. Please check your credentials.');
        return null;
      }
    } catch (e) {
      failure('Error login', e.toString());
      return null;
    }
  }

  RegistrationOTPRequest registrationOTPRequest =
      RegistrationOTPRequest(email: '', name: '', mobile: '', referalcode: '');

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
          Get.to(OTPVerificationPage());
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

      print(response);
      if (response != null) {
        success('success', response.payload.message);
        Get.to(RegisterProfilePage());
        return true;
      }
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Country> countries = <Country>[].obs;
  Rx<Country?> selectedCountry = Rx<Country?>(null);

  Country? get initialCountry => countries.firstWhere(
        (country) => country.id == userData.first.countryId,
        orElse: () => countries.first,
      );

  Future<bool> fetchCountries() async {
    try {
      countries.clear();

      final CountryResponse? response =
          await FetchAllCountriesProvider().fetchCountries();

      if (response != null && response.payload.data.isNotEmpty) {
        countries.addAll(response.payload.data);
        // print('Countries fetched successfully');
        return true;
      } else {
        failure('Error', 'No countries found in the response');
        return false;
      }
    } catch (e) {
      failure('Error fetchCountries', e.toString());
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
        // print('Languages fetched successfully');
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

  /// Encrypts a message with the provided secret key.
  String encryptMessage(String message, String secretKey) {
    // Generate a random 16-byte IV
    final ivBytes = Uint8List(16);
    final random = Random.secure();
    for (int i = 0; i < ivBytes.length; i++) {
      ivBytes[i] = random.nextInt(256);
    }
    final iv = encrypt.IV(ivBytes);

    // Get the AES key
    final key = _getKey(secretKey);

    // Initialize the AES CBC encrypter
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Encrypt the message
    final encrypted = encrypter.encrypt(message, iv: iv);

    // Encode the encrypted message and IV to Base64
    final encodedEncryptedMessage = base64.encode(encrypted.bytes);
    final encodedIv = base64.encode(iv.bytes);

    // Combine the encoded parts
    return '$encodedEncryptedMessage::$encodedIv';
  }

  /// Decrypts an encrypted message with the provided secret key.
  String decryptMessage(String encryptedMessageWithIv, String secretKey) {
    // Split the message and IV from the encoded string
    final parts = encryptedMessageWithIv.split('::');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted message format.');
    }

    final encodedEncryptedMessage = parts[0];
    final encodedIv = parts[1];

    final encryptedMessage = base64.decode(encodedEncryptedMessage);
    final ivBytes = base64.decode(encodedIv);

    // Create an IV from the decoded bytes
    final iv = encrypt.IV(ivBytes);

    // Get the AES key
    final key = _getKey(secretKey);

    // Initialize the AES CBC decrypter
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Decrypt the message
    final decrypted =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedMessage), iv: iv);

    // Convert the decrypted bytes back to a string
    return utf8.decode(decrypted);
  }

  /// Generates a 256-bit AES key using SHA-256 hash of the secret key.
  encrypt.Key _getKey(String secretKey) {
    final keyBytes = sha256.convert(utf8.encode(secretKey)).bytes;
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  Future<bool> updateChats(Message message) async {
    try {
      final ChatResponse? response = await ChatProvider().updateChats(message);
      if (response != null) {
        return true;
      } else {
        failure('Error', 'Error updating the chat');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Message> messages = <Message>[].obs;

  Future<bool> fetchChats(String connectionId) async {
    try {
      final ChatResponse? response =
          await ChatProvider().fetchChats(connectionId);

      if (response != null && response.chats.isNotEmpty) {
        final fetchedMessages = response.chats;

        final existingIds = messages.map((msg) => msg.id).toSet();
        final newMessages = fetchedMessages
            .where((msg) => !existingIds.contains(msg.id))
            .toList();

        if (newMessages.isEmpty) {
          print('No new messages to add.');
          return true;
        }

        for (var message in newMessages) {
          try {
            if (message.message != null) {
              message.message = decryptMessage(message.message!, secretkey);
            }
          } catch (e) {
            print('Error decrypting message with ID: ${message.id}');
            print(e.toString());
          }
        }

        messages.addAll(newMessages);
        return true;
      } else {
        print('No chats found.');
        return true;
      }
    } catch (e) {
      print('Error fetching chats: $e');
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> deleteChats(List<Message> chats) async {
    try {
      final ChatResponse? response = await ChatProvider().deleteChats(chats);
      if (response != null) {
        return true;
      } else {
        failure('Error', 'Error deleting the chat');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Category> categories = <Category>[].obs;
  RxList<Desires> desires = <Desires>[].obs;
  Future<bool> fetchDesires() async {
    try {
      categories.clear();
      desires.clear();
      final DesiresResponse? response =
          await FetchAllDesiresProvider().fetchDesires();
      if (response != null) {
        categories.addAll(response.payload.data);
        for (var c in categories) {
          desires.addAll(c.desires);
        }
        print('successfully fetched all the desires');
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
  Future<bool> fetchProfile([String id = ""]) async {
    final dbHelper = DatabaseHelper();
    EncryptedSharedPreferences preferences =
        EncryptedSharedPreferences.getInstance();
    String? userId = await preferences.getString('userId');
    String cacheId = id.isEmpty ? (userId ?? 'currentUser') : id;

    try {
      isLoading.value = true;
      UserProfileResponse? response = await HomePageProvider().fetchProfile(id);
      if (response != null && response.success) {
        if (response.payload.data.isNotEmpty) {
          final user = response.payload.data.first;
          await dbHelper.saveUserProfile(user);
        }
        print(
            'Fetched user profile data: ${response.payload.data.first.toJson()}');
        userData.assignAll(response.payload.data);
        userDesire.assignAll(response.payload.desires);
        userPreferences.assignAll(response.payload.preferences);
        userLang.assignAll(response.payload.lang);
        print('successfully fetched the user profile from API');
        isLoading.value = false;
        return true;
      } else {
        final cachedUser = await dbHelper.getUserProfile(cacheId);
        if (cachedUser != null) {
          userData.assignAll([cachedUser]);
          print('successfully fetched the user profile from DB');
          isLoading.value = false;
          return true;
        }
        isLoading.value = false;
        failure('Error', 'Error fetching the user profile');
        return false;
      }
    } catch (e) {
      final cachedUser = await dbHelper.getUserProfile(cacheId);
      if (cachedUser != null) {
        userData.assignAll([cachedUser]);
        print('successfully fetched the user profile from DB on exception');
        isLoading.value = false;
        return true;
      }
      isLoading.value = false;
      print('Exception fetching profile: $e');
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
        print('successfully fetched all the active users');
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
        // print('Genders fetched successfully');
        return true;
      } else {
        failure('Error fetchGenders', 'Error fetching the genders');
        return false;
      }
    } catch (e) {
      failure('Error fetchGenders', e.toString());
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
        // print('User preferences fetched successfully');
        return true;
      } else {
        failure('Error fetchPreferences', 'Error fetching the preferences');
        return false;
      }
    } catch (e) {
      failure('Error fetchPreferences', e.toString());
      return false;
    }
  }

  RxList<Benefit> benefits = <Benefit>[].obs;
  RxBool isBenefitsLoading = false.obs;
  Future<bool> fetchBenefits() async {
    try {
      isBenefitsLoading.value = true;
      benefits.clear();
      BenefitsResponse? response =
          await FetchBenefitsProvider().fetchBenefits();
      if (response != null) {
        benefits.addAll(response.payload.data);
        print('Successfully fetched the benefits');
        return true;
      } else {
        failure('Error', 'Failed to fetch the benefits');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    } finally {
      isBenefitsLoading.value = false;
    }
  }

  RxList<Package> packages = <Package>[].obs;

  Future<bool> fetchAllPackages() async {
    try {
      isLoading.value = true;
      GetAllPackagesResponseModel? response =
          await FetchAllPackagesProvider().fetchAllPackages();

      if (response != null && response.success) {
        packages.assignAll(response.payload.data);
        print('Successfully fetched all the packages');
        isLoading.value = false;
        return true;
      } else {
        failure('Error', response?.error.message ?? 'Unknown error');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      failure('Error', 'An exception occurred: ${e.toString()}');
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
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
        print('successfully fetched the safety guidelines');
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
        print('successfully fetched the sub genders');
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
  Future<bool> fetchProfileUserPhotos([String id = ""]) async {
    try {
      isLoading.value = true;
      UserUploadImagesResponse? response =
          await UserProfileProvider().fetchProfileUserPhotos(id);
      if (response != null && response.payload != null) {
        userPhotos = response.payload!.data;
        print('successfully fetched the user profile photos');
        isLoading.value = false;
        return true;
      } else {
        failure('Error', 'Failed to fetch the  user profile photos');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
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
        Get.to(CombinedAuthScreen());
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
      EstablishConnectionMessageRequest
          establishConnectionMessageRequest) async {
    try {
      EstablishConnectionResponse? response =
          await EstablishConnectionProvider()
              .sendConnectionMessageprovider(establishConnectionMessageRequest);

      if (response != null) {
        if (!response.success) {
          failure('Error', response.error.message);
          return false;
        }
        // Always show success message when message is sent successfully
        if (response.payload.message.isNotEmpty) {
          success('Message Sent!', response.payload.message);
          Get.close(1);
          return true;
        } else {
          success('Message Sent!', 'Your message has been sent successfully');
        }
        Get.close(1);
        return true;
      } else {
        failure('Error', 'Failed to send the connection message');
        Get.close(1);
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
        debugPrint('successfully fetched all the headlines');
        return true;
      } else {
        debugPrint('Error : Failed to fetch the headlines');
        return false;
      }
    } catch (e) {
      failure('Error in headlines', e.toString());
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
      ForgetPasswordResponse? response =
          await LoginProvider().getOtpForgetPassword(forgetPasswordRequest);

      if (response != null) {
        String message = response.payload.message;
        // print(message);

        RegExp otpRegExp = RegExp(r'(\d{6})');
        Match? otpMatch = otpRegExp.firstMatch(message);

        if (otpMatch != null) {
          String otp = otpMatch.group(0)!;
          success('Success', 'OTP sent successfully: $otp');
          Get.to(OTPInputPage());

          await storeOtp(otp);

          return true;
        } else {
          failure('Error', 'OTP not found in the message');
          return false;
        }
      } else {
        failure('Error', 'Failed to get the OTP');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
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
        Get.to(CombinedAuthScreen());
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
        Get.to(EmailOtpVerificationPage());
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
        Get.close(3);
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
    city: "",
    dob: "",
    nickname: "",
    gender: "",
    subGender: "",
    lang: [],
    interest: '',
    bio: '',
    visibility: '',
    lookingFor: '',
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
        Get.close(1);
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
      if (!await requestCameraPermission()) {
        return 'Camera permission denied';
      }
      if (!await requestLocationPermission()) {
        return 'Location permission denied';
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final compressedImage = await FlutterImageCompress.compressWithFile(
          image.path,
          quality: 50,
        );

        if (compressedImage != null) {
          String base64Image = base64Encode(compressedImage);

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

        final compressedImage = await FlutterImageCompress.compressWithFile(
          galleryImage.path,
          quality: 50,
        );

        if (compressedImage != null) {
          final String base64Image = base64Encode(compressedImage);
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
        base64EncodedImage = value;
      });
    } else if (ch == "G") {
      await addOrUpdateGalleryImage(page).then((value) {
        base64EncodedImage = value;
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

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();

      return false;
    }
    failure("Manually Open Setting ", "Allow all to open camera");
    return false;
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
      print("fetched reason: "+response!.toJsonString());
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

  Future<bool> updateprofilephoto(
      UpdateProfilePhotoRequest updateProfilePhotoRequest) async {
    try {
      UserProfileUpdatePhotoResponse? response =
          await UpdateProfilePhotoProvider()
              .updateprofilephoto(updateProfilePhotoRequest);
      if (response != null) {
        success('success', response.payload.message);
        Get.close(2);
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
        success('success', response.payload);
        return true;
      } else {
        failure('Error', 'Failed to update lat long of the user');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateActivityStatusRequest updateActivityStatusRequest =
      UpdateActivityStatusRequest(status: '');
  Future<bool> updateactivitystatus(
      UpdateActivityStatusRequest updateActivityStatusRequest) async {
    try {
      UpdateActivityStatusResponse? response = await ActivityStatusProvider()
          .updateactivitystatusprovider(updateActivityStatusRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to update the activity status');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  // RxList<Object> getCurrentList(int filterIndex) {
  //   if (filterIndex == -1) {
  //     //return RxList<Object>(getAllUsers());
  //     return userSuggestionsList;
  //   }

  //   if (filterIndex == 3) {
  //     //return RxList<Object>(getAllUsers());
  //     return hookUpList;
  //   }
  //   switch (filterIndex) {
  //     case 0:
  //       return userNearByList;
  //     case 1:
  //       return userHighlightedList;
  //     case 2:
  //       return favourite;
  //     case 3:
  //       return hookUpList;
  //     default:
  //       return userSuggestionsList;
  //   }
  // }

  RxList<SuggestedUser> getCurrentList(int filterIndex) {
    switch (filterIndex) {
      case -1:
        return userSuggestionsList;
      case 0:
        return userNearByList;
      case 1:
        return userHighlightedList;
      case 2:
        return favourite
            .map((fav) => convertFavouriteToSuggestedUser(fav))
            .toList()
            .obs;
      case 3:
        return hookUpList;
      default:
        return <SuggestedUser>[].obs;
    }
  }

  RxList<SuggestedUser> userSuggestionsList = <SuggestedUser>[].obs;
  RxList<SuggestedUser> userHighlightedList = <SuggestedUser>[].obs;
  RxList<SuggestedUser> hookUpList = <SuggestedUser>[].obs;
  RxList<SuggestedUser> userNearByList = <SuggestedUser>[].obs;
  Set<String?> seenUserIds = {};
  SuggestedUser? lastUser;
  RxBool isCardLoading = false.obs;
  Future<bool> userSuggestions() async {
    try {
      isCardLoading.value = true;
      UserSuggestionsResponseModel? response =
          await UserSuggestionsProvider().userSuggestions();

      if (response != null && response.payload != null) {
        userSuggestionsList.value = response.payload!.desireBase;
        userNearByList.value = response.payload!.locationBase;
        userHighlightedList.value = response.payload!.highlightedAccount;
        hookUpList.value = response.payload!.hookup;

        userSuggestionsList.addAll(response.payload!.locationBase);
        userSuggestionsList.addAll(response.payload!.preferenceBase);
        userSuggestionsList.addAll(response.payload!.languageBase);

        logger.info("All user lists:");
        logger.info("Nearby: ${userNearByList.length}");
        logger.info("Desire: ${userSuggestionsList.length}");
        logger.info("Hookup: ${hookUpList.length}");
        logger.info("Highlight: ${userHighlightedList.length}");

        return true;
      } else {
        failure('Error', 'Failed to fetch the user suggestions');
        debugPrint(
            'Error: Failed to fetch the user suggestions, response is null');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    } finally {
      isCardLoading.value = false;
    }
  }

  LikeModel likeModel = LikeModel(likedBy: '');
  Future<bool> postLike(LikeModel likeModel) async {
    try {
      LikedByResponseModel? response =
          await PostLikeProvider().postLike(likeModel);
      if (response != null && response.payload != null) {
        success('Success', response.payload!.message);
        return true;
      }

      // failure('Error', 'Failed to process the like request.');
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
        // print('FAQs fetched successfully');
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

  UsernameUpdateRequest usernameUpdateRequest =
      UsernameUpdateRequest(username: '');
  Future<bool> updateusername(
      UsernameUpdateRequest usernameUpdateRequest) async {
    try {
      UsernameUpdateResponse? response =
          await UsernameUpdateProvider().updateUsername(usernameUpdateRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to update the username');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<PackageData> subscripted = <PackageData>[].obs;

  Future<bool> fetchAllsubscripted() async {
    subscripted.clear();
    try {
      SubscribedPackagesModel? response =
          await FetchSubscriptedPackageProvider().fetchAllSubscriptedPackage();
      if (response != null) {
        subscripted.addAll(response.payload.data);
        print('successfully fetched all the subscripted');
        return true;
      } else {
        failure('Error', 'Failed to fetch the subscripted');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  UpdateNewPackageRequestModel updateNewPackageRequestModel =
      UpdateNewPackageRequestModel(packageId: '');
  Future<bool> updatinguserpackage(
      UpdateNewPackageRequestModel updateNewPackageRequestModel) async {
    try {
      UpdateNewPackageResponse? response = await UpdatingPackageProvider()
          .updatingpackage(updateNewPackageRequestModel);
      if (response != null && response.success == true) {
        success('success', response.payload.message);
        Get.offAll(NavigationBottomBar());
        EncryptedSharedPreferences preferences =
            EncryptedSharedPreferences.getInstance();
        await preferences.setString('package_status', "1");
        return true;
      } else {
        failure('Error', 'Failed to update the userpackage');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  HighlightProfileStatusRequest highlightProfileStatusRequest =
      HighlightProfileStatusRequest(status: '');
  Future<bool> highlightProfile(
      HighlightProfileStatusRequest highlightProfileStatusRequest) async {
    try {
      HighlightProfileStatusResponse? response =
          await HighlightProfileStatusProvider()
              .highlightProfileStatus(highlightProfileStatusRequest);
      if (response != null) {
        success('success', response.payload.message);
        if (userData.isNotEmpty) {
          userData.first.accountHighlightStatus =
              highlightProfileStatusRequest.status;
          userData.refresh();
        }
        // Get.close(1);
        return true;
      } else {
        failure('Error', 'Failed to highlight your profile');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  VerificationType verificationtype = VerificationType(
      id: '', title: '', description: '', status: '', created: '', updated: '');

  Future<bool> fetchAllverificationtype() async {
    try {
      GetVerificationTypeResponse? response =
          await FetchVerificationtypeProvider().fetchAllVerificationProvider();

      if (response != null) {
        verificationtype = response.payload.data;
        print('successfully fetched all the verification');
        print("verification type: ${response.payload.data}");
        return true;
      } else {
        failure('Error', 'Failed to fetch the verification');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RequestToVerifyAccount requestToVerifyAccount =
      RequestToVerifyAccount(identifyImage: '', identifyNo: '');

  Future<int> verifyuseraccount(
      RequestToVerifyAccount requestToVerifyAccount) async {
    try {
      RequestToVerifyAccountResponse? response = await VerifyAccountProvider()
          .verifyaccountprovider(requestToVerifyAccount);
      if (response != null) {
        success('success', response.payload.message);
        Get.close(1);
        return response.payload.packageStatus;
      } else {
        failure('Error', 'Failed to submit the verification request');
        Get.close(1);
        return 0;
      }
    } catch (e) {
      failure('Error', e.toString());
      Get.close(1);
      return 0;
    }
  }

  RxList<Favourite> favourite = <Favourite>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Set<String?> seenFavouriteIds = {};

  Future<bool> fetchallfavourites() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      GetFavouritesResponse? response =
          await FetchAllFavouritesProvider().fetchallfavouritesprovider();

      if (response != null) {
        if (response.payload.data.isNotEmpty) {
          print('Successfully fetched all the favourites');
          favourite.assignAll(response.payload.data);
          print('Favourites length is = ${favourite.length}');
        } else {
          print('No favourites found, list is empty.');
        }
        return true;
      } else {
        failure('Error', 'Failed to fetch the favourites');
        hasError.value = true;
        print('Failed to fetch the favourites');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      hasError.value = true;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // RxList<Favourite> favourite = <Favourite>[].obs;

  // Future<bool> fetchallfavourites() async {
  //   try {
  //     GetFavouritesResponse? response =
  //         await FetchAllFavouritesProvider().fetchallfavouritesprovider();
  //     if (response != null) {
  //       favourite.assignAll(response.payload.data);
  //       print('successfully fetched all the favourites');
  //       print(favourite.first.city);
  //       print("favourites length is = ${favourite.length}");
  //       return true;
  //     } else {
  //       failure('Error', 'Failed to fetch the favourites');
  //       print('Failed to fetch the favourites');
  //       return false;
  //     }
  //   } catch (e) {
  //     failure('Error', e.toString());
  //     return false;
  //   }
  // }

  SuggestedUser convertFavouriteToSuggestedUser(Favourite favourite) {
    // Fix status mapping for UI compatibility
    String? status = favourite.status == "1"
        ? "online"
        : (favourite.status == "0" ? "offline" : favourite.status);

    // Fix profile image URL if needed
    String? profileImage = favourite.profileImage;
    if (profileImage != null && !profileImage.startsWith('http')) {
      profileImage = "${ip}uploads/user_pics/$profileImage";
    }

    return SuggestedUser(
      id: favourite.id,
      userId: favourite.userId,
      name: favourite.name,
      dob: favourite.dob,
      username: favourite.username,
      city: favourite.city,
      images: favourite.images,
      status: status,
      created: favourite.created,
      updated: favourite.updated,
      email: favourite.email,
      mobile: favourite.mobile,
      address: favourite.address,
      gender: favourite.gender,
      subGender: favourite.subGender,
      countryId: favourite.countryId,
      password: favourite.password,
      latitude: favourite.latitude,
      longitude: favourite.longitude,
      otp: favourite.otp,
      type: favourite.type,
      nickname: favourite.nickname,
      interest: favourite.interest,
      bio: favourite.bio,
      emailAlerts: favourite.emailAlerts,
      lookingFor: favourite.lookingFor,
      profileImage: profileImage,
      userActiveStatus: favourite.userActiveStatus,
      statusSetting: favourite.statusSetting,
      accountVerificationStatus: favourite.accountVerificationStatus,
      accountHighlightStatus: favourite.accountHighlightStatus,
      genderName: favourite.genderName,
      subGenderName: favourite.subGenderName,
      countryName: favourite.countryName,
      preferenceId: favourite.preferenceId,
      desiresId: favourite.desiresId,
      langId: favourite.langId,
    );
  }

  MarkFavouriteRequestModel markFavouriteRequestModel =
      MarkFavouriteRequestModel(favouriteId: '');

  Future<bool> markasfavourite(
      MarkFavouriteRequestModel markFavouriteRequestModel) async {
    try {
      MarkFavouriteResponse? response = await MarkasfavouriteProvider()
          .markasfavouriteprovider(markFavouriteRequestModel);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        // failure('Error', 'Failed to submit the mark as favourite request');
        return false;
      }
    } catch (e) {
      failure('Error in controllerr', e.toString());
      return false;
    }
  }

  DeleteFavouritesRequest deleteFavouritesRequest =
      DeleteFavouritesRequest(favouriteId: '');

  Future<bool> deletefavourite(
      DeleteFavouritesRequest deleteFavouritesRequest) async {
    try {
      DeleteFavouriteResponse? response = await DeletefavouriteProviderModel()
          .deletefavouriteprovider(deleteFavouritesRequest);
      if (response != null) {
        success('success', response.payload);
        return true;
      } else {
        failure('Error', 'Failed to submit the delete favourite request');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  AppSettingRequest appSettingRequest =
      AppSettingRequest(minimumAge: '', maximumAge: '', rangeKm: '');

  Future<bool> appsetting(AppSettingRequest appSettingRequest) async {
    try {
      AppSettingResponse? response =
          await AppSettingProvider().appsettingprovider(appSettingRequest);
      if (response != null) {
        success('success', response.payload);
        if (userData.isNotEmpty) {
          userData.first.rangeKm = appSettingRequest.rangeKm;
          userData.first.minimumAge = appSettingRequest.minimumAge;
          userData.first.maximumAge = appSettingRequest.maximumAge;
          userData.refresh();
        }
        Get.close(1);
        return true;
      } else {
        failure('Error', 'Failed to submit appsetting');
        Get.close(1);
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      Get.close(1);
      return false;
    }
  }

  ProfileLikeRequest profileLikeRequest = ProfileLikeRequest(likedBy: '');
  Future<ProfileLikeResponse?> profileLike(
      ProfileLikeRequest profileLikeRequest) async {
    try {
      ProfileLikeResponse? response =
          await ProfileLikeProvider().profileLikeProvider(profileLikeRequest);
      if (response != null) {
        return response;
      }

      // failure('Error', 'Failed to process the like request.');
      return null;
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  RxList<LikeRequestPages> likespage = <LikeRequestPages>[].obs;
  Future<bool> likesuserpage() async {
    try {
      likespage.clear();
      GetAllLikesResponse? response =
          await FetchLikesPageProvider().likespageprovider();
      if (response != null) {
        // success('Success', response.payload.message);
        if (response.payload.data.isNotEmpty) {
          likespage.assignAll(response.payload.data);
          print(response);
        }
        return true;
      } else {
        failure('Error', 'Failed to fetch the Likes Users');
        print("Error${'Failed to fetch the Likes Users'}");
        return false;
      }
    } catch (e) {
      likespage.clear();
      failure('Error', e.toString());
      print("Error${e.toString()}");
      return false;
    }
  }

  DislikeProfileRequest dislikeProfileRequest = DislikeProfileRequest(id: '');
  Future<bool> dislikeprofile(
      DislikeProfileRequest dislikeProfileRequest) async {
    try {
      DislikeProfileResponse? response = await DislikeProfileProvider()
          .dislikeProfileProvider(dislikeProfileRequest);
      if (response != null) {
        // success('Success', response.payload.message);
        return true;
      }
      // failure('Error', 'Failed to process the dislike request.');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  HomepageDislikeRequest homepageDislikeRequest =
      HomepageDislikeRequest(userId: '', connectionId: '');
  Future<bool> homepagedislikeprofile(
      HomepageDislikeRequest homepageDislikeRequest) async {
    try {
      HomepageDislikeResponse? response = await HomePageDislikeProvider()
          .homePageDislikeProvider(homepageDislikeRequest);
      if (response != null) {
        success('Success', response.payload.message);
        return true;
      }
      // failure(
      //     'Error', 'Failed to process the user suggestion dislike request.');
      return false;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<UserConnections> userConnections = <UserConnections>[].obs;

  Future<bool> fetchalluserconnections() async {
    try {
      userConnections.clear();
      GetAllChatHistoryPageResponse? response =
          await FetchAllUserConnectionsProvider()
              .fetchalluserconnectionsprovider();
      if (response != null) {
        userConnections.addAll(response.payload.data);
        print('Successfully fetched all the chat history page');
        return true;
      } else {
        // failure('Error', 'Failed to fetch the chat history page');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<MessageRequest> messageRequest = <MessageRequest>[].obs;
  Future<bool> fetchallpingrequestmessage() async {
    try {
      messageRequest.clear();
      GetAllRequestPingMessageResponse? response =
          await FetchAllRequestMessageProvider()
              .fetchallrequestmessageprovider();
      if (response != null) {
        // success('Success', response.payload.message);
        if (response.payload.data.isNotEmpty) {
          messageRequest.addAll(response.payload.data);

          return true;
        } else {
          return true;
        }
      } else {
        failure('Error', 'Failed to fetch the Ping Messages Request');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<SliderData> sliderData = <SliderData>[].obs;
  Future<bool> fetchAllIntroSlider() async {
    try {
      sliderData.clear();
      IntroSliderResponse? response =
          await FetchAllIntroSliderProvider().fetchAllIntroSliderProvider();

      if (response != null) {
        // success('Success', response.payload!.msg!);

        if (response.payload!.data!.isNotEmpty) {
          sliderData.addAll(response.payload!.data!);

          return true;
        } else {
          failure('No Data', 'No intro slider data found');
          return false;
        }
      } else {
        failure('Error', 'Failed to fetch the Intro Slider');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  DeleteChatRequest deleteChatRequest = DeleteChatRequest(deleteChatWith: '');

  Future<bool> deletechathistory(DeleteChatRequest deleteChatRequest) async {
    try {
      DeleteChatResponse? response = await DeleteChatHistoryProvider()
          .deletechathistoryprovider(deleteChatRequest);
      if (response != null) {
        success('success', response.payload.message);
        return true;
      } else {
        failure('Error', 'Failed to delete the Chat History');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Addon> addon = <Addon>[].obs;

  Future<bool> fetchAllAddOn() async {
    try {
      addon.clear();
      GetAllAddonsResponse? response =
          await FetchAllAddOnProvider().getalladdonprovider();

      if (response != null && response.success) {
        if (response.payload.data.isNotEmpty) {
          addon.addAll(response.payload.data);
          print('Successfully fetched all the add-ons.');
          return true;
        } else {
          failure('Error', 'No add-ons available.');
          return false;
        }
      } else {
        failure('Error', 'Failed to fetch add-ons.');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<AllTransactions.Transaction> transactions =
      <AllTransactions.Transaction>[].obs;
  Future<bool> allTransactions() async {
    try {
      AllTransactions.AllTransactionsResponseModel? response =
          await OrderProvider().allTransactions();
      if (response != null) {
        transactions.assignAll(response.payload.transactions);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<Order> orders = <Order>[].obs;
  Future<bool> allOrders() async {
    try {
      AllOrdersResponseModel? response = await OrderProvider().allOrders();
      if (response != null) {
        orders.assignAll(response.payload.orders);
        print("all orders length = ${orders.length.toString()}");
        print("all orders error = ${response.error.message}");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      failure('Error order controller', e.toString());
      return false;
    }
  }

  RxList<PointAmount> pointamount = <PointAmount>[].obs;
  Future<bool> getpointdetailsamount() async {
    try {
      PointAmountResponse? response =
          await GetPointAmountProvider().getpointamount();
      if (response != null) {
        pointamount.assignAll(response.payload.pointToAmount);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      failure("Error", e.toString());
      return false;
    }
  }

  ReferralCodeRequestModel referalcoderequestmodel =
      ReferralCodeRequestModel(mobile: '');
  Future<bool> requestreference(
      ReferralCodeRequestModel referalcoderequestmodel) async {
    try {
      ReferralCodeResponse? response = await ReferalCodeProvider()
          .referalcodeprovider(referalcoderequestmodel);
      if (response != null) {
        success("Success", response.payload.referralCode);
        String referralMessage =
            "Check out my referral code: ${response.payload.referralCode}";
        await Share.share(referralMessage); // This opens the native share sheet
        return true;
      } else {
        failure("error", response!.error.message);
        return false;
      }
    } catch (e) {
      failure("Error", e.toString());
      return false;
    }
  }

  RxList<CreditDebitHistory> creditdebithistory = <CreditDebitHistory>[].obs;
  Future<bool> getcreditdebithistory() async {
    try {
      GetPointCreditedDebitedResponse? response =
          await GetPointCreditedDebitedProvider()
              .getpointcrediteddebitedprovider();

      if (response != null) {
        creditdebithistory.assignAll(response.payload.creditdebithistory);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      failure("Error", e.toString());
      return false;
    }
  }

  RxList<Point> totalpoint = <Point>[].obs;

  Future<bool> gettotalpoint() async {
    try {
      GetUsersTotalPoints? response =
          await GetUsertotalPointsProvider().getusertotalpointsprovider();
      if (response != null) {
        totalpoint.assignAll([response.payload.point]);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      failure("Error", e.toString());
      return false;
    }
  }

  RxList<PackageForCreator> packageforcreator = <PackageForCreator>[].obs;

  Future<bool> fetchAllPackagesForCreator() async {
    try {
      CreatorPackageResponse? response =
          await FetchAllCreatorPackageProvider().fetchCreatorPackage();

      if (response != null && response.success) {
        packageforcreator.assignAll(response.data);
        debugPrint('Successfully fetched all the Packages For Creator');
        return true;
      } else {
        failure('Error', response?.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      failure('Error', 'An exception occurred: ${e.toString()}');
      return false;
    }
  }

  RxList<CreatorContent> creatorContent = <CreatorContent>[].obs;
  Future<bool> fetchAllCreatorContent() async {
    try {
      CreatorContentResponse? response =
          await CreatorAllContentProvider().fetchCreatorContent();

      if (response != null && response.success) {
        creatorContent.assignAll(response.data);
        debugPrint('Successfully fetched all the Packages For Creator');
        return true;
      } else {
        failure('Error', response?.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      failure('Error', 'An exception occurred: ${e.toString()}');
      return false;
    }
  }

  RxList<CreatorGeneric> creatorGeneric = <CreatorGeneric>[].obs;
  Future<bool> fetchAllCreatorGeneric() async {
    try {
      CreatorGenericResponse? response =
          await FetchAllCreatorGenericProvider().fetchCreatorGeneric();

      if (response != null && response.success) {
        // Flatten the list of lists
        final flatList = response.data.expand((x) => x).toList();
        creatorGeneric.assignAll(flatList);
        debugPrint('Successfully fetched all the Packages For Creator');
        return true;
      } else {
        failure('Error', response?.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      failure('Error', 'An exception occurred: ${e.toString()}');
      return false;
    }
  }

  RxList<Creator> creators = <Creator>[].obs;

  Future<bool?> getAllCreators() async {
    try {
      GetAllCreatorsResponse? response =
          await GetAllCreatorsProvider().getAllCreators();
      if (response != null && response.success) {
        creators.assignAll(response.data);
        return true;
      } else {
        failure('Error', 'Failed to fetch the creators');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<OrderData> creatorOrders = <OrderData>[].obs;

  Future<CreatorOrderResponse?> createCreatorOrder(
      CreatorOrderRequest request) async {
    try {
      final CreatorOrderResponse? response =
          await CreatorOrderProvider().createOrder(request);

      if (response != null && response.success && response.data.isNotEmpty) {
        creatorOrders.assignAll(response.data);
        success('Success', response.message);
        return response;
      } else {
        failure('Error', response?.message ?? 'Failed to create order');
        return response;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  RxList<TransactionData> creatorTransactionHistory = <TransactionData>[].obs;

  Future<bool> fetchCreatorTransactionHistory() async {
    try {
      final CreatorTransactionHistoryResponse? response =
          await CreatorTransactionHistoryProvider()
              .fetchCreatorTransactionHistory();

      if (response != null && response.success && response.data.isNotEmpty) {
        creatorTransactionHistory.assignAll(response.data);
        debugPrint('Successfully fetched creator transaction history');
        return true;
      } else {
        failure('Error', response?.message ?? 'No transaction history found');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<CreatorSubscriptionData> creatorSubscriptions =
      <CreatorSubscriptionData>[].obs;

  Future<AddUserToCreatorResponse?> addUserToCreator(
      AddUserToCreatorRequest request) async {
    try {
      final AddUserToCreatorResponse? response =
          await AddUserToCreatorProvider().addUserToCreator(request);

      if (response != null && response.data.isNotEmpty) {
        creatorSubscriptions.assignAll(response.data);
        success('Success', response.message);
        return response;
      } else {
        failure('Error', response?.message ?? 'Failed to add user to creator');
        return response;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  RxList<CreatorAllOrder> creatorsAllOrders = <CreatorAllOrder>[].obs;

  Future<bool> fetchCreatorsAllOrders() async {
    try {
      final CreatorAllOrdersResponse? response =
          await CreatorsAllOrdersProvider().fetchCreatorsAllOrders();

      if (response != null && response.data.isNotEmpty) {
        creatorsAllOrders.assignAll(response.data);
        debugPrint('Successfully fetched all creator orders');
        return true;
      } else {
        failure('Error', response?.message ?? 'No creator orders found');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<CreatorContentById> contentById = <CreatorContentById>[].obs;

  Future<bool> fetchContentById(String contentId) async {
    try {
      final CreatorContentByIdResponse? response =
          await GetContentByIdProvider().fetchContentById(contentId);

      if (response != null && response.success && response.data.isNotEmpty) {
        contentById.assignAll(response.data);
        debugPrint('Successfully fetched content by ID');
        return true;
      } else {
        failure('Error', response?.message ?? 'No content found for this ID');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  RxList<CreatorSubscriptionHistory> creatorsSubscriptionHistory =
      <CreatorSubscriptionHistory>[].obs;

  Future<bool> fetchCreatorsSubscriptionHistory() async {
    try {
      final CreatorSubscriptionHistoryResponse? response =
          await CreatorsSubscriptionHistoryProvider()
              .fetchCreatorsSubscriptionHistory();

      if (response != null && response.success && response.data.isNotEmpty) {
        creatorsSubscriptionHistory.assignAll(response.data);
        debugPrint('Successfully fetched creator subscription history');
        return true;
      } else {
        failure('Error', response?.message ?? 'No subscription history found');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> addUserToHookup(interestedId) async {
    try {
      final bool response = await AddHookupRequestProvider()
          .addHookupRequest(interestedId: interestedId);

      if (response) {
        success('Success', 'User added to hookup successfully');
        return true;
      } else {
        failure('Error', 'Failed to add user to hookup');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool?> updateStatus(String status) async {
    try {
      UpdateStatusResponse? response =
          await Updatestatusprovider().updateStatus(status);
      if (response != null) {
        // success('Success', response.message);
        return true;
      } else {
        failure('Error', 'Failed to update the status');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  List<Widget> buildVerificationButtons({
    required String status,
    required BuildContext context,
    required Size screenSize,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    // Reusable styled button: GRADIENT
    Widget gradientButton(String label, VoidCallback onPressed,
        {required bool disabled}) {
      return SizedBox(
        width: screenSize.width * 0.28,
        height: screenSize.height * 0.055,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.reversedGradientColor,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: disabled ? null : onPressed,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.textStyle.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Reusable styled button: WHITE WITH GRADIENT TEXT
    Widget whiteButton(String label, VoidCallback onPressed,
        {required bool disabled}) {
      return SizedBox(
        width: screenSize.width * 0.28,
        height: screenSize.height * 0.055,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: disabled ? null : onPressed,
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                blendMode: BlendMode.srcIn,
                child: Text(
                  label,
                  style: AppTextStyles.textStyle.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Now map status → buttons
    switch (status) {
      case '0': // ❌ Not submitted yet → Show OK only
        return [
          gradientButton("OK", onConfirm, disabled: false),
        ];

      case '1': // ✔️ Verified → Show Cancel + Confirm
        return [
          whiteButton("Cancel", onCancel, disabled: false),
          SizedBox(width: screenSize.width * 0.04),
          gradientButton("Confirm", onConfirm, disabled: false),
        ];

      case '2': // ❌ Rejected → Cancel + Reverify
        return [
          whiteButton("Cancel", onCancel, disabled: false),
          SizedBox(width: screenSize.width * 0.04),
          gradientButton("Reverify", onConfirm, disabled: false),
        ];

      case '3': // 🕒 Pending → show only informational OK to dismiss
        return [
          gradientButton("OK", onCancel, disabled: false),
        ];

      default:
        return [
          gradientButton("OK", onConfirm, disabled: false),
        ];
    }
  }

  // --- Verification helpers (reusable) ------------------------------
  String getVerificationMessage(String status) {
    switch (status) {
      case '0':
        return 'Not Applied for Verification';
      case '1':
        return 'Account Verified';
      case '2':
        return 'Verification Rejected';
      case '3':
        return 'Verification Pending';
      default:
        return 'Account Verification';
    }
  }

  String _getVerificationDialogBodyText(String status) {
    switch (status) {
      case '0':
        return 'You have not applied for verification. Submitting verification helps us confirm genuine profiles.';
      case '1':
        return 'Your account is verified.';
      case '2':
        return 'Your previous verification was rejected. You may re-submit with a clearer selfie or document.';
      case '3':
        return 'Your verification request is under review. Please wait until the admin approves your profile.';
      default:
        return 'Account verification information.';
    }
  }

  List<Widget> _buildVerificationActions(
      String status, BuildContext context, Size screenSize,
      {required VoidCallback onConfirm, required VoidCallback onCancel}) {
    return buildVerificationButtons(
      status: status,
      context: context,
      screenSize: screenSize,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  RxBool isuserPackage = false.obs;
  Future<bool> userPackage() async {
    try {
      bool response = await CheckPackageProvider().checkUserPackage();
      isuserPackage.value = response;
      return response;
    } catch (e) {
      failure('Error in userPackage', e.toString());
      return false;
    }
  }

  Future<bool> updateHookupStatus(int hookupStatus) async {
    try {
      final bool response = await UpdateHookupStatusProvider()
          .updateHookupStatus(hookupStatus: hookupStatus);

      if (response) {
        success('Success', 'Hookup status updated successfully');
        if (userData.isNotEmpty) {
          userData.first.hookupStatus = hookupStatus.toString();
          userData.refresh();
        }
        return true;
      } else {
        failure('Error', 'Failed to update hookup status');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  Future<bool> updateIncognitoStatus(int status) async {
    try {
      final bool response =
          await UpdateIncognitoStatusProvider().updateIncognitoStatus(
        status: status,
      );

      if (response) {
        success('Success', 'Incognito mode status updated');
        if (userData.isNotEmpty) {
          userData.first.incognativeMode = status.toString();
          userData.refresh();
        }
        return true;
      } else {
        failure('Error', 'Failed to update incognito mode status');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  List<SuggestedUser> getAllUsers() {
    final Set<String?> seen = {};
    final List<SuggestedUser> all = [];
    // Combine all lists, avoiding duplicates by userId
    for (var list in [
      userNearByList,
      userHighlightedList,
      hookUpList,
      userSuggestionsList,
    ]) {
      for (var user in list) {
        if (user.userId != null && !seen.contains(user.userId)) {
          all.add(user);
          seen.add(user.userId);
        }
      }
    }
    return all;
  }

  List<SuggestedUser> getListByFilter(int filterIndex) {
    switch (filterIndex) {
      case 0:
        return userNearByList;
      case 1:
        return userHighlightedList;
      case 2:
        return favourite.map(convertFavouriteToSuggestedUser).toList();
      case 3:
        return hookUpList;
      case -1: // All
        final Set<String?> seen = {};
        final List<SuggestedUser> all = [];
        for (var list in [
          userNearByList,
          userHighlightedList,
          hookUpList,
          userSuggestionsList,
        ]) {
          for (var user in list) {
            if (user.userId != null && !seen.contains(user.userId)) {
              all.add(user);
              seen.add(user.userId);
            }
          }
        }
        print(" Total users in ALL: ${all.length}");
        return all;
      default:
        return userSuggestionsList;
    }
  }

  void showPermissionDialog(String permissionName, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          'This permission is required for audio/video calls. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens the app settings
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Add these getters to check user status
  bool get isVerified =>
      userData.isNotEmpty && userData.first.accountVerificationStatus == "1";

  bool get isVerificationPending =>
      userData.isNotEmpty && userData.first.accountVerificationStatus == "3";

  bool get hasSubscription =>
      userData.isNotEmpty && userData.first.packageStatus == "1";

  // Helper method to check if user can interact
  Future<bool> canUserInteract(BuildContext context) async {
    if (!isVerified && !isVerificationPending) {
      // Not verified, show verification prompt
      showVerificationDialog(context);
      return false;
    }

    if (isVerificationPending) {
      // Verification pending
      showVerificationDialog(context);
      return false;
    }

    if (isVerified && !hasSubscription) {
      // Verified but not subscribed
      showPackagesDialog();
      return false;
    }

    return true; // User can interact
  }

  void showVerificationDialog(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final verificationStatus = userData.first.packageStatus ??
        '0'; //verificaton status is package status bro...
    final accountVerificationStatus =
        userData.first.accountVerificationStatus ?? '0';

    String getVerificationMessage(String status) {
      if (accountVerificationStatus == '1') {
        return 'Account verified.';
      }
      //VERIFICATION STATUS IS TO BE CHECKED ONLY.
      switch (status) {
        case '0': //dialog box wihth not applied for verification
          return 'Not Applied for Verification';
        // case '1':
        //   return 'Verification Accepted';
        case '2':
          return 'Verification Rejected';
        case '3':
          return 'Verification Pending';
        default:
          return 'lemme see';
      }
    }

//to get the rejection reason.
    // String getRejectionReason(String status) {
    //   String verificationStatus = userData.first.accountVerificationStatus;
    //   String rejectionReason =
    //       userData.first.rejectionReason ?? 'No reason provided.';
    //   if (accountVerificationStatus == '2') {
    //     return rejectionReason;
    //   } else {
    //     return '';
    //   }
    // }
    RxString rejectedMessage = "".obs;

    Future<String> loadRejectionReason() async {
      print("Loading rejection reason...");
      final res =
          await GetRejectionMessageProvider().getRejectionMessageProvider();
      if (res != null && res.payload.data != null) {
        print("Rejection reason loaded: ${res.payload.data!.feedback}");
        rejectedMessage.value = res.payload.data!.feedback;
      }

      return rejectedMessage.value;
    }

//a final function ot get correct buttons based on the verification statuses (package)
    List<Widget> _buildButtons(
        String status, BuildContext context, Size screenSize) {
      // if (verificationStatus == '0') {
      //   //dialog box of submit request with buttons cancel and verify.
      //   return []; // No actions needed for verified accounts
      // }
      switch (status) {
        case '0': //cancel and verify buttons
          return [];
        case '1': //account verified dialog box with ok button
          return [];
        case '2': //rejected dialog box with cancel and reverify buttons
          return [];
        case '3': //pending dialog with freezed buttons, cancel and verify.
          return [];
        default:
          return [
            // OK button
          ];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: screenSize.height * 0.28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Account Verification',
                    style:
                        AppTextStyles.titleText.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    getVerificationMessage(verificationStatus),
                    style: AppTextStyles.textStyle
                        .copyWith(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: verificationStatus == '2'
                      ? FutureBuilder<String>(
                          future: loadRejectionReason(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                "",
                                style: TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              );
                            }

                            return Text(
                              snapshot.data ?? "",
                              style: AppTextStyles.textStyle
                                  .copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            );
                          },
                        )
                      : verificationStatus == '3'
                          ? Text(
                              "Verification under review",
                              style: AppTextStyles.textStyle
                                  .copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              "To verify your account, you need to submit a photo.",
                              style: AppTextStyles.textStyle
                                  .copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildVerificationButtons(
                    status: verificationStatus,
                    context: context,
                    screenSize: screenSize,
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () {
                      Navigator.of(context).pop();
                      Future.microtask(
                        () => Get.to(() => const PhotoVerificationPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showPackagesDialog() {
    final context = Get.context!;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    double baseFont = screenWidth * 0.065; // Roughly responsive
    double smallFont = screenWidth * 0.035;
    double buttonFont = screenWidth * 0.04;

    Get.defaultDialog(
      title: '',
      backgroundColor: Colors.transparent,
      barrierDismissible: false,
      radius: 15.0,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Subscribe to Enjoy',
              style: TextStyle(
                fontSize: baseFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "Choose a Subscription Plan",
              style: AppTextStyles.titleText.copyWith(
                fontSize: smallFont,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Button with same styling structure
                SizedBox(
                    width: screenWidth * 0.28,
                    height: screenWidth * 0.12, // Consistent height
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(color: Colors.white),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          ),
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: AppColors.gradientBackgroundList,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleText.copyWith(
                              fontSize: buttonFont,
                              color: Colors.white, // overridden by ShaderMask
                            ),
                          ),
                        ),
                      ),
                    )),

                SizedBox(width: screenWidth * 0.03),

                // Subscribe Button
                SizedBox(
                  width: screenWidth * 0.28,
                  height: screenWidth * 0.12, // Same height
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: AppColors.reversedGradientColor,
                      ),
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(MembershipPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                        ),
                      ),
                      child: Text(
                        'Subscribe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: buttonFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
