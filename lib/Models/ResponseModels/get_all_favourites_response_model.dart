import 'package:dating_application/Models/ResponseModels/user_suggestions_response_model.dart';

class GetFavouritesResponse {
  bool success;
  Payload payload;
  Error error;

  GetFavouritesResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory GetFavouritesResponse.fromJson(Map<String, dynamic> json) {
    return GetFavouritesResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  String message;
  List<Favourite> data;

  Payload({
    required this.message,
    required this.data,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Favourite> favouritesList =
        list.map((item) => Favourite.fromJson(item)).toList();

    return Payload(
      message: json['message'],
      data: favouritesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((favourite) => favourite.toJson()).toList(),
    };
  }
}

class Favourite {
  String? id;
  String? userId;
  String? favouriteId;
  String? status;
  String? created;
  String? updated;
  final String? name;
  final String? email;
  final String? mobile;
  final String? city;
  final String? address;
  final String? gender;
  final String? subGender;
  final String? countryId;
  final String? password;
  final String? latitude;
  final String? longitude;
  final String? otp;
  final String? type;
  final String? dob;
  final String? nickname;
  final String? interest;
  final String? bio;
  final String? emailAlerts;
  final String? lookingFor;
  final String? username;
  final String? profileImage;
  final String? userActiveStatus;
  final String? statusSetting;
  final String? accountVerificationStatus;
  final String? accountHighlightStatus;
  final String? genderName;
  final String? subGenderName;
  final String? countryName;
  final List<String> images;
  final String? preferenceId;
  final String? desiresId;
  final String? langId;

  // Add missing fields:
  final String? countryCode;
  final String? points;
  final String? firstTranDone;
  final String? lastSeen;
  final String? packageStatus;
  final String? minimumAge;
  final String? maximumAge;
  final String? rangeKm;
  final String? version;
  final String? banned;
  final String? hookupStatus;
  final String? incognativeMode;
  final String? creator;

  Favourite({
    this.id,
    this.userId,
    this.favouriteId,
    this.status,
    this.created,
    this.updated,
    this.name,
    this.email,
    this.mobile,
    this.city,
    this.address,
    this.gender,
    this.subGender,
    this.countryId,
    this.password,
    this.latitude,
    this.longitude,
    this.otp,
    this.type,
    this.dob,
    this.nickname,
    this.interest,
    this.bio,
    this.emailAlerts,
    this.lookingFor,
    this.username,
    this.profileImage,
    this.userActiveStatus,
    this.statusSetting,
    this.accountVerificationStatus,
    this.accountHighlightStatus,
    this.genderName,
    this.subGenderName,
    this.countryName,
    this.images = const [],
    this.preferenceId,
    this.desiresId,
    this.langId,
    // new fields
    this.countryCode,
    this.points,
    this.firstTranDone,
    this.lastSeen,
    this.packageStatus,
    this.minimumAge,
    this.maximumAge,
    this.rangeKm,
    this.version,
    this.banned,
    this.hookupStatus,
    this.incognativeMode,
    this.creator,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    List<String> images = [
      json['img1'] as String? ?? '',
      json['img2'] as String? ?? '',
      json['img3'] as String? ?? '',
      json['img4'] as String? ?? '',
      json['img5'] as String? ?? '',
      json['img6'] as String? ?? '',
    ].where((img) => img.isNotEmpty).toList();

    return Favourite(
      id: json['id'],
      userId: json['user_id'],
      favouriteId: json['favourite_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      city: json['city'],
      address: json['address'],
      gender: json['gender'],
      subGender: json['sub_gender'],
      countryId: json['country_id'],
      password: json['password'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      otp: json['otp'],
      type: json['type'],
      dob: json['dob'],
      nickname: json['nickname'],
      interest: json['interest'],
      bio: json['bio'],
      emailAlerts: json['email_alerts'],
      lookingFor: json['looking_for'],
      username: json['username'],
      profileImage: json['profile_image'],
      userActiveStatus: json['user_active_status'],
      statusSetting: json['status_setting'],
      accountVerificationStatus: json['account_verification_status'],
      accountHighlightStatus: json['account_highlight_status'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      genderName: json['gender_name'],
      subGenderName: json['sub_gender_name'] ?? json['sub_gender_nm'],
      countryName: json['country_name'],
      images: images,
      preferenceId: json['preference_id'],
      desiresId: json['desires_id'],
      langId: json['lang_id'],
      // new fields
      countryCode: json['country_code'],
      points: json['points'],
      firstTranDone: json['first_tran_done'],
      lastSeen: json['last_seen'],
      packageStatus: json['package_status'],
      minimumAge: json['minimumAge'],
      maximumAge: json['maximumAge'],
      rangeKm: json['rangeKm'],
      version: json['version'],
      banned: json['banned'],
      hookupStatus: json['hookup_status'],
      incognativeMode: json['incognative_mode'],
      creator: json['creator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'favourite_id': favouriteId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'city': city,
      'address': address,
      'gender': gender,
      'sub_gender': subGender,
      'country_id': countryId,
      'password': password,
      'latitude': latitude,
      'longitude': longitude,
      'otp': otp,
      'type': type,
      'dob': dob,
      'nickname': nickname,
      'interest': interest,
      'bio': bio,
      'email_alerts': emailAlerts,
      'looking_for': lookingFor,
      'username': username,
      'profile_image': profileImage,
      'user_active_status': userActiveStatus,
      'status_setting': statusSetting,
      'account_verification_status': accountVerificationStatus,
      'account_highlight_status': accountHighlightStatus,
      'status': status,
      'created': created,
      'updated': updated,
      'gender_name': genderName,
      'sub_gender_name': subGenderName,
      'country_name': countryName,
      'images': images,
      'preference_id': preferenceId,
      'desires_id': desiresId,
      'lang_id': langId,
      // new fields
      'country_code': countryCode,
      'points': points,
      'first_tran_done': firstTranDone,
      'last_seen': lastSeen,
      'package_status': packageStatus,
      'minimumAge': minimumAge,
      'maximumAge': maximumAge,
      'rangeKm': rangeKm,
      'version': version,
      'banned': banned,
      'hookup_status': hookupStatus,
      'incognative_mode': incognativeMode,
      'creator': creator,
    };
  }

SuggestedUser convertFavouriteToSuggestedUser(Favourite favourite) {
  return SuggestedUser(
    id: favourite.id,
    userId: favourite.userId,
    name: favourite.name,
    dob: favourite.dob,
    username: favourite.username,
    city: favourite.city,
    images: favourite.images,
    status: favourite.status,
    created: favourite.created,
    updated: favourite.updated,
    email: favourite.email,
    mobile: favourite.mobile,
    address: favourite.address,
    gender: favourite.gender,
    subGender: favourite.subGender,
    countryId: favourite.countryId,
    password: favourite.password,
    latitude: favourite.latitude,
    longitude: favourite.longitude,
    otp: favourite.otp,
    type: favourite.type,
    nickname: favourite.nickname,
    interest: favourite.interest,
    bio: favourite.bio,
    emailAlerts: favourite.emailAlerts,
    lookingFor: favourite.lookingFor,
    profileImage: favourite.profileImage,
    userActiveStatus: favourite.userActiveStatus,
    statusSetting: favourite.statusSetting,
    accountVerificationStatus: favourite.accountVerificationStatus,
    accountHighlightStatus: favourite.accountHighlightStatus,
    genderName: favourite.genderName,
    subGenderName: favourite.subGenderName,
    countryName: favourite.countryName,
    preferenceId: favourite.preferenceId,
    desiresId: favourite.desiresId,
    langId: favourite.langId,
  );
}
}

class Error {
  int code;
  String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
