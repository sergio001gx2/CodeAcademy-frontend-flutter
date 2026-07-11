import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final int enrollmentId;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.enrollmentId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<OrderProvider>(context, listen: false).loadProgress(widget.enrollmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final isCompleted = orderProvider.isCompletedCompleted(widget.lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video placeholder / link
            if (widget.lesson.videoUrl != null) ...[
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, size: 60, color: AppColors.primaryLight),
                      const SizedBox(height: 8),
                      Text(
                        'Reproducir Lección en Video',
                        style: TextStyle(color: Colors.white.withAlpha(220), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            Text(
              widget.lesson.title,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            
            // Duration
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Duración: ${widget.lesson.duration} minutos',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const Divider(height: 40, color: AppColors.surfaceLight),

            // Content
            const Text(
              'Material de Estudio',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 12),
            Text(
              widget.lesson.content,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 50),

            // Progress Toggle
            Card(
              color: isCompleted ? AppColors.success.withAlpha(30) : AppColors.surface,
              child: SwitchListTile(
                title: const Text(
                  'Completar lección',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  isCompleted 
                      ? '¡Excelente! Has terminado esta lección.' 
                      : 'Marcar cuando termines de estudiar este material.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                value: isCompleted,
                activeColor: AppColors.success,
                onChanged: (val) async {
                  await orderProvider.toggleLessonProgress(
                    enrollmentId: widget.enrollmentId,
                    lessonId: widget.lesson.id,
                    completed: val,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? '¡Lección marcada como completada!' : 'Progreso de lección desmarcado'),
                        backgroundColor: val ? AppColors.success : AppColors.info,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add extension to check if completed safely
extension on OrderProvider {
  bool isCompletedCompleted(int id) {
    try {
      return isLessonCompleted(id);
    } catch (_) {
      return false;
    }
  }
}
