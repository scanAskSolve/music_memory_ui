class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String provider;
  final bool isNewUser;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.provider,
    this.isNewUser = false,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: json['provider'] as String? ?? 'unknown',
      isNewUser: json['isNewUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider,
      'isNewUser': isNewUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
