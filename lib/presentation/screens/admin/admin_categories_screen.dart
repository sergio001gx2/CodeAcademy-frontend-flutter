import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<AdminProvider>(context, listen: false).loadCategories();
    });
  }

  void _deleteCategory(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Categoría?'),
        content: const Text('Esta acción eliminará la categoría. Asegúrese de que no haya cursos asignados a ella.'),
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
      final success = await Provider.of<AdminProvider>(context, listen: false).deleteCategory(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoría eliminada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = Provider.of<AdminProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error al eliminar la categoría'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Categorías'),
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: adminProvider.categories.isEmpty
            ? const Center(
                child: Text('No hay categorías registradas'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adminProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = adminProvider.categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Slug: ${category.slug}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
                            onPressed: () => context.push('/admin/categories/edit/${category.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deleteCategory(category.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/categories/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
