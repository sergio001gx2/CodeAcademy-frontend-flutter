import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/presentation/widgets/order_status_badge.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<AdminProvider>(context, listen: false).loadAllEnrollments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoría de Matrículas'),
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: adminProvider.enrollments.isEmpty
            ? const Center(
                child: Text('No hay matrículas registradas en el sistema'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: adminProvider.enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = adminProvider.enrollments[index];
                  final isCompleted = enrollment.completedAt != null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      key: ValueKey(enrollment.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  enrollment.courseTitle,
                                  style: AppTextStyles.h3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OrderStatusBadge(isCompleted: isCompleted),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.surfaceLight),
                          Text(
                            'ID Matrícula: ${enrollment.id}',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID Estudiante: ${enrollment.student}',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inscrito el: ${enrollment.enrolledAt.day}/${enrollment.enrolledAt.month}/${enrollment.enrolledAt.year}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
