import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/teacher_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;final auth = Provider.of<AuthProvider>(context, listen: false);
      final teacher = Provider.of<TeacherProvider>(context, listen: false);
      if (auth.session?.userId != null) {
        teacher.loadMyCourses(auth.session!.userId);
      }
    });
  }

  void _deleteCourse(BuildContext context, Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar curso', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '¿Seguro que deseas eliminar "${course.title}"?',
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
      final success = await teacher.deleteCourse(course.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Curso eliminado' : teacher.errorMessage ?? 'Error'),
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
        title: const Text('Mis Cursos', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.session?.userId != null) {
                teacherProvider.loadMyCourses(auth.session!.userId);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Curso', style: TextStyle(color: Colors.white)),
        onPressed: () => context.push('/teacher/courses/new'),
      ),
      body: teacherProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : teacherProvider.myCourses.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teacherProvider.myCourses.length,
                  itemBuilder: (context, index) {
                    final course = teacherProvider.myCourses[index];
                    return _buildCourseCard(context, course);
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Aún no tienes cursos',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Crea tu primer curso con el botón +',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.isPublished
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.isPublished ? 'Publicado' : 'Borrador',
                    style: TextStyle(
                      color: course.isPublished ? AppColors.success : AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: AppColors.accent),
                Text(
                  '\$${course.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.book_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${course.lessons.length} lecciones',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                // Lessons button
                IconButton(
                  icon: const Icon(Icons.list_alt, color: AppColors.primary),
                  tooltip: 'Gestionar lecciones',
                  onPressed: () => context.push('/teacher/courses/${course.id}/lessons'),
                ),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                  tooltip: 'Editar curso',
                  onPressed: () => context.push('/teacher/courses/edit/${course.id}'),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Eliminar curso',
                  onPressed: () => _deleteCourse(context, course),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
