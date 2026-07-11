import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      if (authProvider.isTeacher && !authProvider.isAdmin) {
        adminProvider.loadCourses(teacherId: authProvider.session?.userId);
      } else {
        adminProvider.loadCourses();
      }
    });
  }

  void _deleteCourse(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Curso?'),
        content: const Text('Esta acción eliminará el curso de forma permanente de la base de datos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await Provider.of<AdminProvider>(context, listen: false).deleteCourse(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso eliminado correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = Provider.of<AdminProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error al eliminar el curso'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.isAdmin ? 'Administrar Cursos' : 'Mis Cursos (Docente)'),
        actions: authProvider.isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: 'Categorías',
                  onPressed: () => context.push('/admin/categories'),
                ),
                IconButton(
                  icon: const Icon(Icons.people_outline),
                  tooltip: 'Usuarios',
                  onPressed: () => context.push('/admin/users'),
                ),
              ]
            : [],
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: Column(
          children: [
            Expanded(
              child: adminProvider.courses.isEmpty
                  ? const Center(
                      child: Text('No hay cursos registrados'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.courses.length,
                      itemBuilder: (context, index) {
                        final course = adminProvider.courses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              course.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Categoría: ${course.categoryName}\nPrecio: \$${course.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
                                  onPressed: () => context.push('/admin/courses/edit/${course.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _deleteCourse(course.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/courses/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
