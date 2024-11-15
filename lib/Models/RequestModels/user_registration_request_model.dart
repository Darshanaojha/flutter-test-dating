import 'dart:convert';

class UserRegistrationRequest {
  final String name;
  final String email;
  final String mobile;
  final String latitude;
  final String longitude;
  final String address;
  final String password;
  final String countryId;
  final String state;
  final String city;
  final String dob;
  final String nickname;
  final String gender;
  final String subGender;
  final List<int> preferences;
  final List<int> desires;
  final String interest;
  final String bio;
  final List<String> photos;
  final String packageId;
  final String emailAlerts;
  final String username;
  final String lookingFor;

  UserRegistrationRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.password,
    required this.countryId,
    required this.state,
    required this.city,
    required this.dob,
    required this.nickname,
    required this.gender,
    required this.subGender,
    required this.preferences,
    required this.desires,
    required this.interest,
    required this.bio,
    required this.photos,
    required this.packageId,
    required this.emailAlerts,
    required this.username,
    required this.lookingFor,
  }) {
    // Perform validations
    validateNotEmpty(name, "Name");
    validateNotEmpty(email, "Email");
    validateEmail(email);
    validateNotEmpty(mobile, "Mobile");
    validateNotEmpty(latitude, "Latitude");
    validateCoordinate(latitude);
    validateNotEmpty(longitude, "Longitude");
    validateCoordinate(longitude);
    validateNotEmpty(address, "Address");
    validateNotEmpty(password, "Password");
    validateNotEmpty(countryId, "Country ID");
    validateNotEmpty(city, "City");
    validateNotEmpty(dob, "Date of Birth");
    validateDateFormat(dob);
    validateNotEmpty(nickname, "Nickname");
    validateNotEmpty(gender, "Gender");
    validateNotEmpty(subGender, "Sub Gender");
    validateNotEmpty(interest, "Interest");
    validateNotEmpty(bio, "Bio");
    validateList(preferences, "Preferences");
    validateList(desires, "Desires");
    validatePhotos(photos);
    validateNotEmpty(packageId, "Package ID");
    validateNotEmpty(emailAlerts, "Email Alerts");
    validateNotEmpty(username, "Username");
    validateNotEmpty(lookingFor, "Looking For");
  }

  // Factory constructor to create UserRegistrationRequest from JSON
  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      password: json['password'],
      countryId: json['country_id'],
      state: json['state'] ?? '',
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      preferences: List<int>.from(jsonDecode(json['preferences'])),
      desires: List<int>.from(jsonDecode(json['desires'])),
      interest: json['interest'],
      bio: json['bio'],
      photos: List<String>.from(jsonDecode(json['photos'])),
      packageId: json['package_id'],
      emailAlerts: json['email_alerts'],
      username: json['username'],
      lookingFor: json['looking_for'],
    );
  }

  // Method to convert UserRegistrationRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'password': password,
      'country_id': countryId,
      'state': state,
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'sub_gender': subGender,
      'preferences': jsonEncode(preferences),
      'desires': jsonEncode(desires),
      'interest': interest,
      'bio': bio,
      'photos': jsonEncode(photos),
      'package_id': packageId,
      'email_alerts': emailAlerts,
      'username': username,
      'looking_for': lookingFor,
    };
  }

  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }


  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: Email.");
    }
  }

  void validateCoordinate(String coordinate) {
    final doubleValue = double.tryParse(coordinate);
    if (doubleValue == null || doubleValue < -180 || doubleValue > 180) {
      throw ArgumentError("Invalid coordinate value for field: $coordinate.");
    }
  }


  void validateDateFormat(String date) {
    final datePattern = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!datePattern.hasMatch(date)) {
      throw ArgumentError("Date of birth must be in the format YYYY/MM/DD for field: Date of Birth.");
    }
  }


  void validateList(List<int> list, String fieldName) {
    if (list.isEmpty) {
      throw ArgumentError("$fieldName cannot be empty.");
    }

    if (!list.every((item) => item is int)) {
      throw ArgumentError("$fieldName must contain only integers.");
    }
  }


  void validatePhotos(List<String> photos) {
    if (photos.isEmpty) {
      throw ArgumentError("Photos list cannot be empty for field: Photos.");
    }
    for (var photo in photos) {
      final urlPattern = RegExp(r'^(http|https):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}\/[^\s]*$');
      if (!urlPattern.hasMatch(photo)) {
        throw ArgumentError("Invalid photo URL for field: $photo.");
      }
    }
  }
}
