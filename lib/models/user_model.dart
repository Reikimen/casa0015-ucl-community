class User {
  final String id;
  final String username;
  final String studentId;
  final String? avatar;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int likesCount;

  User({
    required this.id,
    required this.username,
    required this.studentId,
    this.avatar,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.likesCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      studentId: json['student_id'],
      avatar: json['avatar'],
      bio: json['bio'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'student_id': studentId,
      'avatar': avatar,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'likes_count': likesCount,
    };
  }
}