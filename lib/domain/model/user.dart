class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isTeacher;
  final bool isStudent;
  final String? bio;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isTeacher,
    required this.isStudent,
    this.bio,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isTeacher: json['is_teacher'] as bool? ?? false,
      isStudent: json['is_student'] as bool? ?? true,
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_teacher': isTeacher,
      'is_student': isStudent,
      'bio': bio,
      'avatar': avatar,
    };
  }

  String get fullName => '$firstName $lastName'.trim().isEmpty ? email : '$firstName $lastName';
}
