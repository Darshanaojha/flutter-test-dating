class UserProfileUpdateRequest {
  final String name;
  final String latitude;
  final String longitude;
  final String address;
  final String countryId;
  final String state;
  final String city;
  final String dob;
  final String nickname;
  final String gender;
  final String subGender;
  final String interest;
  final String bio;
  final String emailAlerts;
  final String preferences;
  final String desires;

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
    required this.emailAlerts,
    required this.preferences,
    required this.desires,
  }) {
    if (name.isEmpty) {
      throw ArgumentError("Name is required.");
    }
    if (latitude.isEmpty || !isValidCoordinate(latitude)) {
      throw ArgumentError("Latitude is invalid.");
    }
    if (longitude.isEmpty || !isValidCoordinate(longitude)) {
      throw ArgumentError("Longitude is invalid.");
    }
    if (address.isEmpty) {
      throw ArgumentError("Address is required.");
    }
    if (countryId.isEmpty) {
      throw ArgumentError("Country ID is required.");
    }
    if (city.isEmpty) {
      throw ArgumentError("City is required.");
    }
    if (dob.isEmpty || !isValidDate(dob)) {
      throw ArgumentError("Date of birth is invalid or empty.");
    }
    if (nickname.isEmpty) {
      throw ArgumentError("Nickname is required.");
    }
    if (gender.isEmpty) {
      throw ArgumentError("Gender is required.");
    }
    if (subGender.isEmpty) {
      throw ArgumentError("Sub Gender is required.");
    }
    if (interest.isEmpty) {
      throw ArgumentError("Interest is required.");
    }
    if (bio.isEmpty) {
      throw ArgumentError("Bio is required.");
    }
    if (emailAlerts.isEmpty) {
      throw ArgumentError("Email Alerts preference is required.");
    }
    if (preferences.isEmpty) {
      throw ArgumentError("Preferences are required.");
    }
    if (desires.isEmpty) {
      throw ArgumentError("Desires are required.");
    }
  }

  // Factory constructor to create UserProfileUpdateRequest from JSON
  factory UserProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateRequest(
      name: json['name'],
      latitude: json['latitute'],
      longitude: json['longitude'],
      address: json['address'],
      countryId: json['country_id'],
      state: json['state'] ?? '', // Default to an empty string if 'state' is null
      city: json['city'],
      dob: json['dob'],
      nickname: json['nickname'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      interest: json['interest'],
      bio: json['bio'],
      emailAlerts: json['email_alerts'],
      preferences: json['preferences'],
      desires: json['desires'],
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
      'state': state,
      'city': city,
      'dob': dob,
      'nickname': nickname,
      'gender': gender,
      'sub_gender': subGender,
      'interest': interest,
      'bio': bio,
      'email_alerts': emailAlerts,
      'preferences': preferences,
      'desires': desires,
    };
  }

  // Helper function to validate latitude and longitude
  bool isValidCoordinate(String coordinate) {
    final doubleValue = double.tryParse(coordinate);
    return doubleValue != null && doubleValue >= -180 && doubleValue <= 180;
  }

  // Helper function to validate date of birth (YYYY/MM/DD format)
  bool isValidDate(String date) {
    final datePattern = RegExp(r'^\d{4}/\d{2}/\d{2}$'); // Regex for YYYY/MM/DD
    return datePattern.hasMatch(date);
  }
}
