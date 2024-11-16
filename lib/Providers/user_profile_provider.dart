import 'dart:convert';
import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/RequestModels/update_emailid_request_model.dart';
import '../Models/ResponseModels/get_all_benifites_response_model.dart';
import '../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../Models/ResponseModels/get_all_headlines_response_model.dart';
import '../Models/ResponseModels/get_all_saftey_guidelines_response_model.dart';
import '../Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import '../Models/ResponseModels/subgender_response_model.dart';
import '../Models/ResponseModels/update_emailid_response_model.dart';
import '../Models/ResponseModels/user_upload_images_response_model.dart';
import '../constants.dart';

class UserProfileProvider extends GetConnect {
  Future<GenderResponse?> fetchGenders() async {
    try {
      Response response = await get('$baseurl/Common/gender');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GenderResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<UserPreferencesResponse?> fetchPreferences() async {
    try {
      Response response = await get('$baseUrl/Common/all_preferences');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserPreferencesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

// Benifits
  Future<BenefitsResponse?> fetchBenefits() async {
    try {
      Response response = await get('$baseUrl/Common/all_benefits');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return BenefitsResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

// Safety Guidelines
  Future<SafetyGuidelinesResponse?> fetchSafetyGuidelines() async {
    try {
      Response response = await get('$baseUrl/Common/all_safety_guidelines');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return SafetyGuidelinesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

// Headlines
  Future<HeadlinesResponse?> fetchHeadlines() async {
    try {
      Response response = await get('$baseUrl/Common/all_headlines');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return HeadlinesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

// Sub Gender
  Future<SubGenderResponse?> fetchSubGender(
      SubGenderRequest subGenderRequest) async {
    try {
      Response response =
          await post('$baseUrl/Common/sub_gender', subGenderRequest);

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return SubGenderResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<UserUploadImagesResponse?> fetchProfileUserPhotos() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await post(
        '$baseUrl/Profile/userphotos',
        null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserUploadImagesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
