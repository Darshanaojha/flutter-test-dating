import '../../constants.dart';

class UserProfileUpdateRequest {
  String name;
  String latitude;
  String longitude;
  String address;
  String countryId;
  String city;
  String dob;
  String nickname;
  String gender;
  String subGender;
  List<dynamic> lang;
  String interest;
  String bio;
  String visibility;
  String emailAlerts;
  String lookingFor;
  List<dynamic> preferences;
  List<dynamic> desires;

  UserProfileUpdateRequest({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.countryId,
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
    required this.lookingFor,
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
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['subgender'],
      interest: json['interest'],
      bio: json['bio'],
      visibility: json["visibility_status"],
      lang: json['lang'] != null ? List<int>.from(json['lang']) : [],
      emailAlerts: json['emailalerts'],
      lookingFor: json['looking_for'],
      preferences: json['preferences'] ?? [],
      desires: json['desires'] ?? [],
    );
  }

  // Method to convert UserProfileUpdateRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitute': latitude,
      'longitude': longitude,
      'address': address,
      'country_id': countryId,
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'sub_gender': subGender,
      'interest': interest,
      'bio': bio,
      'visibility_status': visibility,
      'lang': lang,
      'email_alerts': emailAlerts,
      'looking_for':lookingFor,
      'preferences': preferences,
      'desires': desires,
    };
  }

  bool validate() {
    if (name.isEmpty || name == null) {
      failure('Name is required', 'Please provide your name.');
      return false;
    }
    if (latitude.isEmpty || latitude == null) {
      failure('Latitude is required', 'Please provide your latitude.');
      return false;
    }
    if (longitude.isEmpty || longitude == null) {
      failure('Longitude is required', 'Please provide your longitude.');
      return false;
    }
    if (address.isEmpty || address == null) {
      failure('Address is required', 'Please provide your address.');
      return false;
    }
    if (countryId.isEmpty || countryId == null) {
      failure('Country is required', 'Please select your country.');
      return false;
    }
    if (city.isEmpty || city == null) {
      failure('City is required', 'Please provide your city.');
      return false;
    }
    if (dob.isEmpty || dob == null) {
      failure(
          'Date of Birth is required', 'Please provide your date of birth.');
      return false;
    }
    if (nickname.isEmpty || nickname == null) {
      failure('Nickname is required', 'Please provide a nickname.');
      return false;
    }
    if (gender.isEmpty || gender == null) {
      failure('Gender is required', 'Please select your gender.');
      return false;
    }
    if (subGender.isEmpty || subGender == null) {
      failure('Sub-Gender is required', 'Please provide your sub-gender.');
      return false;
    }
    if (lang.isEmpty || lang == null) {
      failure('Language is required', 'Please select your languages.');
      return false;
    }
    if (interest.isEmpty || interest == null) {
      failure('Interest is required', 'Please provide your interest.');
      return false;
    }
    if (bio.isEmpty || bio == null) {
      failure('Bio is required', 'Please provide a short bio.');
      return false;
    }
    if (visibility.isEmpty || visibility == null) {
      failure('Visibility is required', 'Please choose your visibility.');
      return false;
    }
    if (emailAlerts.isEmpty || emailAlerts == null) {
      failure('Email Alerts is required',
          'Please select your email alert preferences.');
      return false;
    }
    if (preferences.isEmpty || preferences == null) {
      failure('Preferences are required', 'Please set your preferences.');
      return false;
    }
    if (desires.isEmpty || desires == null) {
      failure('Desires are required', 'Please set your desires.');
      return false;
    }
    return true;
  }
}
