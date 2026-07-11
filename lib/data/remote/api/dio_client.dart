import 'package:dio/dio.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/data/local/secure_storage.dart';
import 'package:codeacademy/data/remote/interceptor/auth_interceptor.dart';

class DioClient {
  final Dio dio;
  final SecureStorage _secureStorage;

  DioClient({
    required SecureStorage secureStorage,
    required Function() onAuthExpired,
  }) : _secureStorage = secureStorage,
       dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    dio.interceptors.add(
      AuthInterceptor(
        secureStorage: _secureStorage,
        onAuthExpired: onAuthExpired,
      ),
    );
  }
}
