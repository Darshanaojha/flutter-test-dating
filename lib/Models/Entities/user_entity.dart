class UserEntity {
  final int? id;
  final String userId;
  final String username;
  final String email;
  final String? profilePhoto;
  final int? age;
  final String? gender;
  final String? location;
  final String? bio;
  final bool isOnline;
  final int? lastSeen;
  final int createdAt;
  final int updatedAt;

  UserEntity({
    this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.profilePhoto,
    this.age,
    this.gender,
    this.location,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserEntity to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'profilePhoto': profilePhoto,
      'age': age,
      'gender': gender,
      'location': location,
      'bio': bio,
      'isOnline': isOnline ? 1 : 0,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create UserEntity from Map retrieved from database
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      email: map['email'],
      profilePhoto: map['profilePhoto'],
      age: map['age'],
      gender: map['gender'],
      location: map['location'],
      bio: map['bio'],
      isOnline: map['isOnline'] == 1,
      lastSeen: map['lastSeen'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // Create a copy with updated fields
  UserEntity copyWith({
    int? id,
    String? userId,
    String? username,
    String? email,
    String? profilePhoto,
    int? age,
    String? gender,
    String? location,
    String? bio,
    bool? isOnline,
    int? lastSeen,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
