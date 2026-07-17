import 'dart:typed_data';
import 'package:codeacademy/domain/model/auth_models.dart';
import 'package:codeacademy/domain/model/user.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);
  
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isTeacher,
    required bool isStudent,
    String? avatarPath,
    Uint8List? avatarBytes,
  });

  Future<void> logout();

  Future<AuthSession?> getSavedSession();

  Future<User> getProfile();

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? avatarPath,
    Uint8List? avatarBytes,
  });

  Future<bool> confirmRecoveryNotification({
    required String email,
    required String newPassword,
  });
}
