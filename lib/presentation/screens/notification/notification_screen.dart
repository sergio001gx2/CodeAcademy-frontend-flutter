import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/presentation/providers/notification_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    // Simple format helper
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hrs';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  void _showNotificationDetail(BuildContext context, dynamic notification, NotificationProvider provider) {
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            notification.title,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              notification.message,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR', style: TextStyle(color: AppColors.primaryLight)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.surface,
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await provider.markAllAsRead();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas las notificaciones marcadas como leídas'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primaryLight),
              label: const Text(
                'Leer todas',
                style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: provider.loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.surfaceLight,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = provider.notifications[index];
                      return ListTile(
                        onTap: () => _showNotificationDetail(context, item, provider),
                        leading: CircleAvatar(
                          backgroundColor: item.isRead 
                              ? AppColors.surface 
                              : AppColors.primary.withAlpha(40),
                          child: Icon(
                            item.isRead 
                                ? Icons.notifications_none_rounded 
                                : Icons.notifications_active_rounded,
                            color: item.isRead ? AppColors.textSecondary : AppColors.primaryLight,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: item.isRead ? AppColors.textPrimary : Colors.white,
                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item.isRead ? AppColors.textMuted : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(item.createdAt),
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: !item.isRead
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin notificaciones',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Te avisaremos cuando tengas novedades.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
