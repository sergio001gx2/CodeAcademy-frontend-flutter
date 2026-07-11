import 'package:codeacademy/domain/model/auth_models.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);
  
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isTeacher,
    required bool isStudent,
  });

  Future<void> logout();

  Future<AuthSession?> getSavedSession();
}
