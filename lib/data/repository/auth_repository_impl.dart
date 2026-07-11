import 'package:dio/dio.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/core/utils/jwt_decoder.dart';
import 'package:codeacademy/data/local/secure_storage.dart';
import 'package:codeacademy/data/remote/dto/auth_dto.dart';
import 'package:codeacademy/domain/model/auth_models.dart';
import 'package:codeacademy/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required Dio dio,
    required SecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final dto = AuthResponseDto.fromJson(response.data);
        
        // Decode JWT token to get claims
        final decodedToken = JwtDecoder.decode(dto.access);
        if (decodedToken == null) {
          throw ApiException(message: 'El token de respuesta no es válido');
        }

        // Persist tokens securely
        await _secureStorage.saveTokens(access: dto.access, refresh: dto.refresh);

        return AuthSession.fromTokenResponse(
          accessToken: dto.access,
          refreshToken: dto.refresh,
          decodedToken: decodedToken,
        );
      } else {
        throw ApiException(
          message: 'Error de inicio de sesión',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 
                       e.response?.data?['non_field_errors']?[0] ??
                       e.message ?? 'Error de conexión con el servidor';
      throw ApiException(
        message: errorMsg.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required bool isTeacher,
    required bool isStudent,
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'is_teacher': isTeacher,
          'is_student': isStudent,
        },
      );

      if (response.statusCode != 201) {
        throw ApiException(
          message: 'Error al registrar usuario',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['email']?[0] ?? 
                       e.response?.data?['password']?[0] ??
                       e.message ?? 'Error de registro';
      throw ApiException(
        message: errorMsg.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearTokens();
  }

  @override
  Future<AuthSession?> getSavedSession() async {
    final access = await _secureStorage.getAccessToken();
    final refresh = await _secureStorage.getRefreshToken();

    if (access == null || refresh == null) return null;

    if (JwtDecoder.isExpired(access)) {
      // Return null, the interceptor will automatically refresh the token on the next request
      // or the app will force re-login if refresh token is expired.
      // But we can decode it anyway to construct the session.
    }

    final decodedToken = JwtDecoder.decode(access);
    if (decodedToken == null) return null;

    return AuthSession.fromTokenResponse(
      accessToken: access,
      refreshToken: refresh,
      decodedToken: decodedToken,
    );
  }
}
