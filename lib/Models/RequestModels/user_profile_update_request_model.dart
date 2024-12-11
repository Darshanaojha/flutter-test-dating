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
      'preferences': preferences,
      'desires': desires,
    };
  }

  List<String> validate() {
    List<String> validationErrors = [];

    // Validate required fields
    validationErrors.addAll(_validateNotEmpty(name, 'Name'));
    validationErrors.addAll(_validateNotEmpty(address, 'Address'));
    validationErrors.addAll(_validateNotEmpty(countryId, 'Country ID'));
    validationErrors.addAll(_validateNotEmpty(city, 'City'));
    validationErrors.addAll(_validateNotEmpty(gender, 'Gender'));
    validationErrors.addAll(_validateNotEmpty(subGender, 'Sub-Gender'));

    // Validate lists for null or empty
    if (preferences.isEmpty) {
      validationErrors.add('Preferences list cannot be empty.');
    }
    if (desires.isEmpty) {
      validationErrors.add('Desires list cannot be empty.');
    }

    // Validate coordinates
    if (!isValidCoordinate(latitude)) {
      validationErrors.add('Latitude must be between -180 and 180.');
    }
    if (!isValidCoordinate(longitude)) {
      validationErrors.add('Longitude must be between -180 and 180.');
    }

    // Validate date of birth format
    if (!isValidDate(dob)) {
      validationErrors.add('Date of Birth should be in YYYY/MM/DD format.');
    }

    return validationErrors;
  }

  List<String> _validateNotEmpty(String value, String fieldName) {
    List<String> errors = [];
    if (value.isEmpty) {
      errors.add('$fieldName is required and cannot be empty.');
    }
    return errors;
  }

  bool isValidCoordinate(String coordinate) {
    final doubleValue = double.tryParse(coordinate);
    return doubleValue != null && doubleValue >= -180 && doubleValue <= 180;
  }

  bool isValidDate(String date) {
    final datePattern = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    return datePattern.hasMatch(date);
  }
}