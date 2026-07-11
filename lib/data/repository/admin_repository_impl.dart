import 'package:dio/dio.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/user.dart';
import 'package:codeacademy/domain/repository/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio;

  AdminRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<User>> getUsers({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/users/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final list = response.data['results'] as List? ?? [];
        return list.map((item) => User.fromJson(item)).toList();
      }
      throw ApiException(message: 'Error al obtener usuarios', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '/users/',
        data: userData,
      );
      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw ApiException(message: 'Error al crear usuario', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '/users/$id/',
        data: userData,
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw ApiException(message: 'Error al actualizar usuario', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/users/$id/');
      if (response.statusCode != 204) {
        throw ApiException(message: 'Error al eliminar usuario', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
