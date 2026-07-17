import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/domain/model/notification.dart';
import 'package:codeacademy/domain/repository/notification_repository.dart';
import 'package:codeacademy/data/local/secure_storage.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;

  NotificationRepositoryImpl({
    required Dio dio,
    required SecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  Future<List<AppNotification>> getNotifications() async {
    List<AppNotification> serverNotifs = [];
    try {
      final response = await _dio.get(AppConfig.notificationsEndpoint);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['results'] is List) {
          list = data['results'] as List;
        } else {
          list = [];
        }
        serverNotifs = list.map((item) => AppNotification.fromJson(item)).toList();
      } else {
        throw ApiException(
          message: 'Error al obtener notificaciones',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }

    // Load local recovery requests and merge them
    try {
      final localRequestsJson = await _secureStorage.readData('local_recovery_requests');
      if (localRequestsJson != null) {
        final List<dynamic> localList = json.decode(localRequestsJson) as List<dynamic>;
        final List<AppNotification> localNotifs = localList.map((item) {
          return AppNotification(
            id: item['id'] as int,
            title: item['title'] as String? ?? '',
            message: item['message'] as String? ?? '',
            isRead: item['is_read'] as bool? ?? false,
            createdAt: item['created_at'] != null 
                ? DateTime.parse(item['created_at'] as String) 
                : DateTime.now(),
          );
        }).toList();
        
        serverNotifs.insertAll(0, localNotifs.where((n) => !n.isRead));
      }
    } catch (_) {
      // Quietly ignore local storage reading errors
    }

    return serverNotifs;
  }

  @override
  Future<void> markAsRead(int id) async {
    // 1. Try to handle it locally if it exists in local storage
    try {
      final localRequestsJson = await _secureStorage.readData('local_recovery_requests');
      if (localRequestsJson != null) {
        final List<dynamic> localList = json.decode(localRequestsJson) as List<dynamic>;
        final index = localList.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          localList.removeAt(index);
          await _secureStorage.writeData('local_recovery_requests', json.encode(localList));
          return;
        }
      }
    } catch (_) {}

    // 2. Otherwise, mark as read on remote server
    try {
      final response = await _dio.patch(
        '${AppConfig.notificationsEndpoint}$id/',
        data: {'is_read': true},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Error al marcar la notificación como leída',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?.toString() ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
