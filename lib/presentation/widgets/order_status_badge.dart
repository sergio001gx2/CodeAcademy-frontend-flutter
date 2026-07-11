import 'package:flutter/material.dart';
import 'package:codeacademy/theme/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final bool isCompleted;

  const OrderStatusBadge({
    super.key,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.success.withAlpha(40) 
            : AppColors.info.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? AppColors.success : AppColors.info,
          width: 1,
        ),
      ),
      child: Text(
        isCompleted ? 'COMPLETADO' : 'ESTUDIANDO',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isCompleted ? AppColors.success : AppColors.info,
        ),
      ),
    );
  }
}
