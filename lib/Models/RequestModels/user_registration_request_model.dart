
import '../../constants.dart';  

class UserRegistrationRequest {
   String name;
   String email;
   String mobile;
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
   List<int> preferences;
   List<int> desires;
   String interest;
   List<int> lang;
   String bio;
   List<String> photos;
   String packageId;
   String emailAlerts;
   String username;
   String lookingFor;

  UserRegistrationRequest({
    required this.name,
    required this.email,
    required this.mobile,
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
    required this.packageId,
    required this.emailAlerts,
    required this.username,
    required this.lookingFor,
  });


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
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      preferences: List<int>.from(json['preferences'] ?? []), 
      desires: List<int>.from(json['desires'] ?? []), 
      interest: json['interest'],
      bio: json['bio'],
      lang: List<int>.from(json['lang']),
      photos: List<String>.from(json['photos'] ?? []),
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
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'sub_gender': subGender,
      'preferences': preferences,  
      'desires': desires,  
      'interest': interest,
      'bio': bio,
      'lang':lang,
      'photos': photos, 
      'package_id': packageId,
      'email_alerts': emailAlerts,
      'username': username,
      'looking_for': lookingFor,
    };
  }

  // Validation Methods
  void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError("$fieldName is required and cannot be empty.");
    }
  }

  // Validate Email
  void validateEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError("Invalid email format for field: Email.");
    }
  }

  // Validate Latitude and Longitude
  void validateCoordinate(String coordinate, String fieldName) {
    final doubleValue = double.tryParse(coordinate);
    if (doubleValue == null || doubleValue < -180 || doubleValue > 180) {
      throw ArgumentError("Invalid coordinate value for field: $fieldName.");
    }
  }

  // Validate Date Format
  void validateDateFormat(String date) {
    final datePattern = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!datePattern.hasMatch(date)) {
      throw ArgumentError("Date of birth must be in the format YYYY/MM/DD for field: Date of Birth.");
    }
  }

  // Validate Lists (Preferences, Desires, lang)
  void validateList(List<int> list, String fieldName) {
    if (list.isEmpty) {
      throw ArgumentError("$fieldName cannot be empty.");
    }

    if (!list.every((item) => item is int)) {
      throw ArgumentError("$fieldName must contain only integers.");
    }
  }

  // Validate Photos (URLs)
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
      validateCoordinate(latitude, "Latitude");
      validateCoordinate(longitude, "Longitude");
      validateDateFormat(dob);
      validateList(lang,"lang");
      validateList(preferences, "Preferences");
      validateList(desires, "Desires");
      validatePhotos(photos);
    } catch (e) {
      failure("Validation Error", e.toString());
    }
  }
}
