import 'package:dio/dio.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/data/local/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _refreshDio; // Separate dio instance to avoid infinite loop on refresh requests
  final Function() _onAuthExpired; // Callback to notify provider of token expiration

  AuthInterceptor({
    required SecureStorage secureStorage,
    required Function() onAuthExpired,
  })  : _secureStorage = secureStorage,
        _onAuthExpired = onAuthExpired,
        _refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // If error is 401 (Unauthorized) and we are not already hitting the login or refresh endpoints
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(AppConfig.loginEndpoint) &&
        !err.requestOptions.path.contains(AppConfig.tokenRefreshEndpoint)) {
      
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final response = await _refreshDio.post(
            AppConfig.tokenRefreshEndpoint,
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'] as String;
            
            // Save new access token (keep old refresh token as Simple JWT doesn't rotate it by default unless configured)
            await _secureStorage.saveTokens(access: newAccessToken, refresh: refreshToken);

            // Clone and retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl)); // Temporary client to complete this retry
            final retryResponse = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              ),
            );
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          // Refresh failed, token is invalid or expired
          await _secureStorage.clearTokens();
          _onAuthExpired();
          
          // Retry the request without Authorization header (handles public endpoints)
          try {
            final requestOptions = err.requestOptions;
            requestOptions.headers.remove('Authorization');
            
            final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
            final retryResponse = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              ),
            );
            return handler.resolve(retryResponse);
          } catch (retryError) {
            return handler.next(err);
          }
        }
      } else {
        // No refresh token available
        await _secureStorage.clearTokens();
        _onAuthExpired();
        
        // Retry the request without Authorization header (handles public endpoints)
        try {
          final requestOptions = err.requestOptions;
          requestOptions.headers.remove('Authorization');
          
          final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
          final retryResponse = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
          );
          return handler.resolve(retryResponse);
        } catch (retryError) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
