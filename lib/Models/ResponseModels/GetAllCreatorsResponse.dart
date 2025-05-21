class GetAllCreatorsResponse {
  final bool success;
  final String message;
  final List<Creator> data;

  GetAllCreatorsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetAllCreatorsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllCreatorsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Creator.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Creator {
  final String creatorId;
  final String userId;
  final String packageId;
  final String genderId;
  final String subscriptionType;
  final int status;
  final String? genreId;
  final double amountPayable;
  final double balance;
  final String name;
  final String city;
  final String profileImage;
  final CreatorGender gender;
  final CreatorSubGender subGender;
  final CreatorCountry country;
  final int imageCount;
  final int videoCount;
  final int followers;
  final int following;

  Creator({
    required this.creatorId,
    required this.userId,
    required this.packageId,
    required this.genderId,
    required this.subscriptionType,
    required this.status,
    this.genreId,
    required this.amountPayable,
    required this.balance,
    required this.name,
    required this.city,
    required this.profileImage,
    required this.gender,
    required this.subGender,
    required this.country,
    required this.imageCount,
    required this.videoCount,
    required this.followers,
    required this.following,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      creatorId: json['creatorId'] ?? '',
      userId: json['userId'] ?? '',
      packageId: json['packageId'] ?? '',
      genderId: json['genderId'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      status: json['status'] ?? 0,
      genreId: json['genreId'],
      amountPayable: (json['amountPayable'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      profileImage: json['profileImage'] ?? '',
      gender: CreatorGender.fromJson(json['gender'] ?? {}),
      subGender: CreatorSubGender.fromJson(json['subGender'] ?? {}),
      country: CreatorCountry.fromJson(json['country'] ?? {}),
      imageCount: json['imageCount'] ?? 0,
      videoCount: json['videoCount'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}

class CreatorGender {
  final String id;
  final String title;

  CreatorGender({
    required this.id,
    required this.title,
  });

  factory CreatorGender.fromJson(Map<String, dynamic> json) {
    return CreatorGender(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class CreatorSubGender {
  final String id;
  final String title;

  CreatorSubGender({
    required this.id,
    required this.title,
  });

  factory CreatorSubGender.fromJson(Map<String, dynamic> json) {
    return CreatorSubGender(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class CreatorCountry {
  final String id;
  final String name;

  CreatorCountry({
    required this.id,
    required this.name,
  });

  factory CreatorCountry.fromJson(Map<String, dynamic> json) {
    return CreatorCountry(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
