import 'package:dating_application/Models/ResponseModels/get_all_introslider_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';

class FetchAllIntroSliderProvider extends GetConnect {
  Future<IntroSliderResponse?> fetchAllIntroSliderProvider() async {
    try {
      debugPrint("Ip address:$baseurl");
      final response = await get('$baseurl/Common/all_intro_sliders');
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['error']['code'] == 0) {
          return IntroSliderResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error',
            'Failed to fetch data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
