
import '../../constants.dart'; // For basic UI error handling

class UserProfileUpdateRequest {
   String name;
   String latitude;
   String longitude;
   String address;
   String countryId;
   String state;
   String city;
   String dob;
   String nickname;
   String gender;
   String subGender;
   List<int>lang;
   List<dynamic> interest;
   String bio;
   String visibility;
   String emailAlerts;
   List<dynamic> preferences;
   List<dynamic> desires;

  UserProfileUpdateRequest({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.countryId,
    required this.state,
    required this.city,
    required this.dob,
    required this.nickname,
    required this.gender,
    required this.subGender,
    required this.interest,
    required this.bio,
    required this.visibility,
    required this.lang,
    required this.emailAlerts,
    required this.preferences,
    required this.desires,
  });

  factory UserProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateRequest(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      countryId: json['countryid'],
      state: json['state'] ?? '', // Default to an empty string if 'state' is null
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['subgender'],
      interest: json['interest'],
      bio: json['bio'],
      visibility: json["visibility_status"],
      lang: json['lang'],
      emailAlerts: json['emailalerts'],
      preferences: json['preferences'],
      desires: json['desires'],
    );
  }

  // Method to convert UserProfileUpdateRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'countryid': countryId,
      'state': state,
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'subgender': subGender,
      'interest': interest,
      'bio': bio,
      'visibility_status':visibility,
      'lang':lang,
      'emailalerts': emailAlerts,
      'preferences': preferences,
      'desires': desires,
    };
  }

  // Validation method
  bool validate() {
    try {
      // Validate required fields
      validateNotEmpty(name, 'Name');
      validateNotEmpty(address, 'Address');
      validateNotEmpty(countryId, 'Country ID');
      validateNotEmpty(city, 'City');
      validateNotEmpty(gender, 'Gender');
      validateNotEmpty(subGender, 'Sub-Gender');

      if (!isValidCoordinate(latitude)) {
        failure('Invalid Latitude', 'Latitude must be between -180 and 180.');
        return false;
      }
      if (!isValidCoordinate(longitude)) {
        failure('Invalid Longitude', 'Longitude must be between -180 and 180.');
        return false;
      }
      if (!isValidDate(dob)) {
        failure('Invalid Date of Birth', 'Date of Birth should be in YYYY/MM/DD format.');
        return false;
      }
      return true; // All validations passed
    } catch (e) {
      failure("Validation Error", e.toString());
      return false;
    }
  }

  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  bool isValidCoordinate(String coordinate) {
    final doubleValue = double.tryParse(coordinate);
    return doubleValue != null && doubleValue >= -180 && doubleValue <= 180;
  }
  bool isValidDate(String date) {
    final  datePattern = RegExp(r'^\d{4}/\d{2}/\d{2}$'); 
    return datePattern.hasMatch(date);
  }

}