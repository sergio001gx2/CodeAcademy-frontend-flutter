import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/teacher_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';

class TeacherLessonsScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const TeacherLessonsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<TeacherLessonsScreen> createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<TeacherProvider>(context, listen: false).loadLessons(widget.courseId);
    });
  }

  void _deleteLesson(BuildContext context, Lesson lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar lección', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '¿Eliminar "${lesson.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final teacher = Provider.of<TeacherProvider>(context, listen: false);
      final success = await teacher.deleteLesson(lesson.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Lección eliminada' : teacher.errorMessage ?? 'Error'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lecciones', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            Text(widget.courseTitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Lección', style: TextStyle(color: Colors.white)),
        onPressed: () => context.push(
          '/teacher/courses/${widget.courseId}/lessons/new',
          extra: {'courseTitle': widget.courseTitle},
        ),
      ),
      body: teacherProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : teacherProvider.lessons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 80, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text('No hay lecciones aún',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Añade lecciones con el botón +',
                          style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teacherProvider.lessons.length,
                  onReorder: (oldIndex, newIndex) {
                    // Visual reorder only (would need API PATCH to persist)
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final lessons = List<Lesson>.from(teacherProvider.lessons);
                      final item = lessons.removeAt(oldIndex);
                      lessons.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final lesson = teacherProvider.lessons[index];
                    return _buildLessonTile(context, lesson, key: ValueKey(lesson.id));
                  },
                ),
    );
  }

  Widget _buildLessonTile(BuildContext context, Lesson lesson, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            '${lesson.order}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(lesson.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('${lesson.duration} min', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (lesson.videoUrl != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.play_circle_outline, size: 14, color: AppColors.info),
              const SizedBox(width: 4),
              const Text('Video', style: TextStyle(color: AppColors.info, fontSize: 12)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.info, size: 20),
              onPressed: () => context.push(
                '/teacher/courses/${widget.courseId}/lessons/edit/${lesson.id}',
                extra: {'courseTitle': widget.courseTitle, 'lesson': lesson},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _deleteLesson(context, lesson),
            ),
            const Icon(Icons.drag_handle, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
