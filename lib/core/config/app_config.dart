import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api'; // IP del host en emulador de Android
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api'; // iOS o escritorio
  }
  
  // Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String tokenRefreshEndpoint = '/auth/token/refresh/';
  static const String coursesEndpoint = '/courses/';
  static const String categoriesEndpoint = '/categories/';
  static const String usersEndpoint = '/users/';
}
