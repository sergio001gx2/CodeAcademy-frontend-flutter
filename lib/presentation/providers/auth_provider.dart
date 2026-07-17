import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/auth_models.dart';
import 'package:codeacademy/domain/model/user.dart';
import 'package:codeacademy/domain/repository/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthStatus _status = AuthStatus.initial;
  AuthSession? _session;
  User? _profile;
  String? _errorMessage;

  AuthProvider({required AuthRepository authRepository}) : _authRepository = authRepository {
    checkSavedSession();
  }

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  User? get profile => _profile;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _session != null;
  bool get isAdmin => isAuthenticated && (_session?.isStaff ?? false);
  bool get isTeacher => isAuthenticated && (_session?.isTeacher ?? false);
  bool get isStudent => isAuthenticated && (_session?.isStudent ?? false);

  Future<void> checkSavedSession() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      _session = await _authRepository.getSavedSession();
      if (_session != null) {
        _status = AuthStatus.authenticated;
        await loadProfile();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      _profile = await _authRepository.getProfile();
      notifyListeners();
    } catch (e) {
      // Quietly fail or log if the backend does not return profile yet
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.login(email, password);
      _status = AuthStatus.authenticated;
      await loadProfile();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isTeacher,
    required bool isStudent,
    String? avatarPath,
    Uint8List? avatarBytes,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        isTeacher: isTeacher,
        isStudent: isStudent,
        avatarPath: avatarPath,
        avatarBytes: avatarBytes,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? avatarPath,
    Uint8List? avatarBytes,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        avatarPath: avatarPath,
        avatarBytes: avatarBytes,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmRecoveryNotification(String email, String newPassword) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.confirmRecoveryNotification(
        email: email,
        newPassword: newPassword,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al procesar la solicitud de recuperación';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    await _authRepository.logout();
    _session = null;
    _profile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void forceLogout() {
    _session = null;
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Sesión expirada. Por favor, vuelva a iniciar sesión.';
    notifyListeners();
  }
}
