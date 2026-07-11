class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String email;
  final int userId;
  final bool isStaff;
  final bool isTeacher;
  final bool isStudent;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.userId,
    required this.isStaff,
    required this.isTeacher,
    required this.isStudent,
  });

  factory AuthSession.fromTokenResponse({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> decodedToken,
  }) {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      email: decodedToken['email'] as String? ?? '',
      userId: decodedToken['user_id'] as int? ?? 0,
      isStaff: decodedToken['is_staff'] as bool? ?? false,
      isTeacher: decodedToken['is_teacher'] as bool? ?? false,
      isStudent: decodedToken['is_student'] as bool? ?? false,
    );
  }
}
