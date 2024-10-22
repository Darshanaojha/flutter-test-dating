class RegisterRequest {
  String name;
  String email;
  String mobile;
  String city;
  String state;
  String address;
  String gender;
  String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.city,
    required this.state,
    required this.address,
    required this.gender,
    required this.password,
  });
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'city': city,
      'state': state,
      'address': address,
      'gender': gender,
      'password': password,
    };
  }

  String? validate() {
    if (_isEmpty(name)) return 'Name cannot be empty';
    if (!_isValidEmail(email)) return 'Invalid email';
    if (!_isValidMobile(mobile)) return 'Invalid mobile number';
    if (_isEmpty(city)) return 'City cannot be empty';
    if (_isEmpty(state)) return 'State cannot be empty';
    if (_isEmpty(address)) return 'Address cannot be empty';
    if (_isEmpty(gender)) return 'Gender cannot be empty';
    if (!_isValidPassword(password)) return 'Password is invalid';
    return null; // No errors
  }

  bool _isEmpty(String value) => value.trim().isEmpty;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidMobile(String mobile) {
    final mobileRegex = RegExp(r'^[0-9]{10}$');
    return mobileRegex.hasMatch(mobile);
  }

  bool _isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }
}
