import 'package:codeacademy/domain/model/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(int id);
}
