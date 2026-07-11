import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/presentation/widgets/order_status_badge.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Inscripciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: AppColors.accent),
            tooltip: 'Mis Certificados',
            onPressed: () => context.push('/certificates'),
          ),
        ],
      ),
      body: orderProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : orderProvider.errorMessage != null
              ? Center(
                  child: Text(
                    orderProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              : orderProvider.orders.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 80, color: AppColors.textMuted),
                            SizedBox(height: 16),
                            Text(
                              'Aún no estás inscrito en ningún curso.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: orderProvider.orders.length,
                      itemBuilder: (context, index) {
                        final enrollment = orderProvider.orders[index];
                        final isCompleted = enrollment.completedAt != null;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push('/course/${enrollment.course}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Inscrito el: ${enrollment.enrolledAt.day}/${enrollment.enrolledAt.month}/${enrollment.enrolledAt.year}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  if (isCompleted) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.verified_outlined, size: 16, color: AppColors.success),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Completado el: ${enrollment.completedAt!.day}/${enrollment.completedAt!.month}/${enrollment.completedAt!.year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.success.withAlpha(220),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryLight),
                                      SizedBox(width: 6),
                                      Text(
                                        'Ver curso, lecciones y exámenes',
                                        style: TextStyle(
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
