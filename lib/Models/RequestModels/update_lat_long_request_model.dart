class UpdateLatLongRequest {
   String latitude;
   String longitude;
   String city;
   String address;

  // Constructor
  UpdateLatLongRequest({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.address,
  });

  // Factory method to create UpdateLatLongRequest object from JSON
  factory UpdateLatLongRequest.fromJson(Map<String, dynamic> json) {
    return UpdateLatLongRequest(
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
    );
  }

  // Convert UpdateLatLongRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'address': address,
    };
  }

  // Validation Method
  String? validate() {
    if (latitude.isEmpty || longitude.isEmpty) {
      return 'Latitude and Longitude cannot be empty';
    }

    if (!_isValidCoordinate(latitude) || !_isValidCoordinate(longitude)) {
      return 'Latitude and Longitude must be valid numeric values';
    }

    if (city.isEmpty) {
      return 'City cannot be empty';
    }

    if (address.isEmpty) {
      return 'Address cannot be empty';
    }

    return null; // Return null if no validation errors
  }

  // Helper method to validate if a string can be parsed as a valid number
  bool _isValidCoordinate(String coordinate) {
    try {
      double value = double.parse(coordinate);
      // Validate the range for latitude and longitude
      return (value >= -180 && value <= 180); // Allow only valid lat/long ranges
    } catch (e) {
      return false; // Return false if parsing fails
    }
  }
}
