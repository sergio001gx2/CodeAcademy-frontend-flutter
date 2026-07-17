import 'package:flutter/material.dart';
import 'package:codeacademy/core/error/api_exception.dart';
import 'package:codeacademy/domain/model/notification.dart';
import 'package:codeacademy/domain/repository/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getNotifications();
      // Sort notifications by created_at descending (newest first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error inesperado al cargar notificaciones';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      // Optimistic update
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final original = _notifications[index];
        _notifications[index] = AppNotification(
          id: original.id,
          title: original.title,
          message: original.message,
          isRead: true,
          createdAt: original.createdAt,
        );
        notifyListeners();
      }

      await _notificationRepository.markAsRead(id);
    } catch (e) {
      // Revert if failed
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    for (var n in unread) {
      await markAsRead(n.id);
    }
  }
}
