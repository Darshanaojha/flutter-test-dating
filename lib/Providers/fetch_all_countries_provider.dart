import 'package:dating_application/Models/ResponseModels/get_all_country_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class FetchAllCountriesProvider extends GetConnect {
  Future<Country?> fetchCountries() async {
    try {
      Response response = await get('$baseurl/Common/country');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return Country.fromJson(response.body);
        } else {
          failure("Error", response.body['error']['message']);
          return null;
        }
      } else {
        failure(
          "Error",
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }
}
