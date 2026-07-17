import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/catalog_provider.dart';
import 'package:codeacademy/presentation/providers/cart_provider.dart';
import 'package:codeacademy/presentation/providers/notification_provider.dart';
import 'package:codeacademy/presentation/widgets/category_chip.dart';
import 'package:codeacademy/presentation/widgets/course_card.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
      catalogProvider.loadCategories();
      catalogProvider.loadCourses();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<CatalogProvider>(context, listen: false).loadCourses(
      search: _searchController.text.trim(),
      categoryId: _selectedCategoryId,
    );
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    Provider.of<CatalogProvider>(context, listen: false).loadCourses(
      search: _searchController.text.trim(),
      categoryId: categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    if (authProvider.isAuthenticated) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      if (!notificationProvider.isLoading && notificationProvider.notifications.isEmpty) {
        Future.microtask(() => notificationProvider.loadNotifications());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeAcademy'),
        actions: [
          // Notifications
          if (authProvider.isAuthenticated)
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                final unreadCount = notificationProvider.unreadCount;
                return IconButton(
                  tooltip: 'Notificaciones',
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: AppColors.error,
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => context.push('/notifications'),
                );
              },
            ),
          // Add Course (Teacher & Admin Only)
          if (authProvider.isTeacher || authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: AppColors.primaryLight),
              tooltip: 'Crear Nuevo Curso',
              onPressed: () => context.push('/teacher/courses/new'),
            ),
          
          // Cart
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartProvider.items.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        cartProvider.items.length.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/cart'),
          ),
          
          // Profile or Login
          IconButton(
            icon: Icon(
              authProvider.isAuthenticated 
                  ? Icons.person_rounded 
                  : Icons.login_rounded,
            ),
            onPressed: () {
              if (authProvider.isAuthenticated) {
                context.push('/profile');
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome text and Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.isTeacher
                      ? 'Tus Cursos Asignados'
                      : authProvider.isAdmin
                          ? 'Panel de Administración'
                          : '¿Qué vas a aprender hoy?',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar cursos...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => _onSearchChanged(),
                ),
                
                // Quick Access shortcuts for Students / Teachers
                if (authProvider.isAuthenticated) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (authProvider.isTeacher || authProvider.isAdmin) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/teacher/courses'),
                            icon: const Icon(Icons.dashboard_customize_rounded, size: 18),
                            label: const Text('Panel de Docente', style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/certificates'),
                          icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                          label: const Text('Mis Certificados', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Categories horizontal scroll
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: catalogProvider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CategoryChip(
                      label: 'Todos',
                      isSelected: _selectedCategoryId == null,
                      onTap: () => _onCategorySelected(null),
                    ),
                  );
                }
                final cat = catalogProvider.categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  key: ValueKey(cat.id),
                  child: CategoryChip(
                    label: cat.name,
                    isSelected: _selectedCategoryId == cat.id,
                    onTap: () => _onCategorySelected(cat.id),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Courses List
          Expanded(
            child: catalogProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : catalogProvider.errorMessage != null
                    ? Center(
                        child: Text(
                          catalogProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : catalogProvider.courses.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron cursos.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: catalogProvider.courses.length,
                            itemBuilder: (context, index) {
                              final course = catalogProvider.courses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: CourseCard(
                                  course: course,
                                  onTap: () => context.push('/course/${course.id}'),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
