import 'dart:convert';

import '../../constants.dart';

class UserRegistrationRequest {
  String name;
  String email;
  String mobile;
  String countryCode;
  String referalcode;
  String latitude;
  String longitude;
  String address;
  String password;
  String countryId;
  String city;
  String dob;
  String nickname;
  String gender;
  String subGender;
  List<String> preferences;
  List<String> desires;
  String interest;
  List<String> lang;
  String bio;
  List<String> photos;
  String imgcount;
  String emailAlerts;
  String username;
  String lookingFor;
  String? googleToken;

  UserRegistrationRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.countryCode,
    required this.referalcode,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.password,
    required this.countryId,
    required this.city,
    required this.dob,
    required this.lang,
    required this.nickname,
    required this.gender,
    required this.subGender,
    required this.preferences,
    required this.desires,
    required this.interest,
    required this.bio,
    required this.photos,
    required this.imgcount,
    required this.emailAlerts,
    required this.username,
    required this.lookingFor,
    this.googleToken,
  });

  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      countryCode: json['country_code'],
      referalcode: json['referal_code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      password: json['password'],
      countryId: json['country_id'],
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      preferences: List<String>.from(json['preferences'] ?? []),
      desires: List<String>.from(json['desires'] ?? []),
      interest: json['interest'],
      bio: json['bio'],
      imgcount: json['img_count'],
      lang: List<String>.from(json['lang']),
      photos: List<String>.from(json['photos'] ?? []),
      emailAlerts: json['email_alerts'],
      username: json['username'],
      lookingFor: json['looking_for'],
      googleToken: json['google_token'],
    );
  }

  void reset() {
    name = '';
    email = '';
    mobile = '';
    countryCode = '';
    referalcode = '';
    latitude = '';
    longitude = '';
    address = '';
    password = '';
    countryId = '';
    city = '';
    dob = '';
    nickname = '';
    gender = '';
    subGender = '';
    preferences = [];
    desires = [];
    interest = '';
    lang = [];
    bio = '';
    photos = [];
    imgcount = '';
    emailAlerts = '';
    username = '';
    lookingFor = '';
    googleToken = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'country_code': countryCode,
      'referal_code': referalcode,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'password': password,
      'country_id': countryId,
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'sub_gender': subGender,
      'preferences': preferences,
      'desires': desires,
      'interest': interest,
      'bio': bio,
      'lang': lang,
      'img_count': imgcount,
      'photos': jsonEncode(photos),
      'email_alerts': emailAlerts,
      'username': username,
      'looking_for': lookingFor,
      'google_token': googleToken ?? '',
    };
  }

  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  void validateEmail(String email) {
    if (email.isEmpty) {
      throw ArgumentError("Email cannot be empty.");
    }
    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw FormatException("Invalid email format for field: Email.");
    }
  }

  void validatePassword(String password) {
    if (password.length < 8) {
      throw ArgumentError("Password must be at least 8 characters long.");
    }

    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (!hasDigit || !hasSpecialChar) {
      throw ArgumentError(
          "Password must contain at least one digit and one special character.");
    }
  }

  void validateCoordinate(String coordinate, String fieldName) {
    final doubleValue = double.tryParse(coordinate);
    if (doubleValue == null || doubleValue < -180 || doubleValue > 180) {
      throw ArgumentError("Invalid coordinate value for field: $fieldName.");
    }
  }

  void validateDateFormat(String date) {
    // Backend expects dd/MM/yyyy format (with / separator)
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(date)) {
      throw ArgumentError(
          "Date of birth must be in the format dd/MM/yyyy (e.g., 16/12/1993) for field: Date of Birth.");
    }
  }

  void validateAge(String dob) {
    // Parse dd/MM/yyyy format (with / separator)
    try {
      final parts = dob.split('/');
      if (parts.length != 3) {
        throw ArgumentError("Invalid date format. Expected dd/MM/yyyy");
      }
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final dateOfBirth = DateTime(year, month, day);
      final now = DateTime.now();
      int age = now.year - dateOfBirth.year;
      // Adjust for month and day
      if (now.month < dateOfBirth.month || 
          (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        age--;
      }
    if (age < 18) {
      throw ArgumentError("User must be at least 18 years old.");
      }
    } catch (e) {
      if (e is ArgumentError) {
        rethrow;
      }
      throw ArgumentError("Invalid date format. Expected dd/MM/yyyy");
    }
  }

  void validateGender(String gender, String fieldName) {
    final validGenders = ['Male', 'Female', 'Other'];
    if (!validGenders.contains(gender)) {
      throw ArgumentError(
          "Invalid value for $fieldName. Valid options are: Male, Female, Other.");
    }
  }

  void validateList(List<String> list, String fieldName) {
    if (list.isEmpty) {
      throw ArgumentError("$fieldName cannot be empty.");
    }
    if (!list.every((item) => item is int)) {
      throw ArgumentError("$fieldName must contain only integers.");
    }
  }

  // validatePhotos(List<String> photos) {
  //   if (photos.isEmpty) {
  //     failure('Photo', "Photos list cannot be empty for field: Photos.");
  //   }
  //   final urlPattern =
  //       RegExp(r'^(http|https):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}\/[^\s]*$');
  //   for (var photo in photos) {
  //     if (!urlPattern.hasMatch(photo)) {
  //       failure("Photo", "Invalid photo URL for field: $photo.");
  //     }
  //   }
  // }

  void validate() {
    try {
      validateNotEmpty(name, "Name");
      validateNotEmpty(email, "Email");
      validateNotEmpty(mobile, "Mobile");
      validateNotEmpty(password, "Password");
      validateNotEmpty(address, "Address");
      validateNotEmpty(countryId, "Country ID");
      validateNotEmpty(city, "City");
      validateNotEmpty(dob, "Date of Birth");
      validateNotEmpty(gender, "Gender");
      validateNotEmpty(subGender, "Sub-Gender");
      validateEmail(email);
      validatePassword(password);
      validateCoordinate(latitude, "Latitude");
      validateCoordinate(longitude, "Longitude");
      validateDateFormat(dob);
      validateAge(dob);
      validateGender(gender, "Gender");
      validateGender(subGender, "Sub-Gender");
      validateList(lang, "Language");
      validateList(preferences, "Preferences");
      validateList(desires, "Desires");
      // validatePhotos(photos);
    } catch (e) {
      failure("Validation Error", e.toString());
    }
  }
}
