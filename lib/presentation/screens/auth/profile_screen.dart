import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final session = authProvider.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User avatar stub
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Email
            Text(
              session?.email ?? 'correo@ejemplo.com',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            
            // Role Tag
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (session?.isStaff ?? false) 
                      ? AppColors.accent.withAlpha(40) 
                      : (session?.isTeacher ?? false)
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.success.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (session?.isStaff ?? false) 
                        ? AppColors.accent 
                        : (session?.isTeacher ?? false)
                            ? AppColors.primary
                            : AppColors.success,
                  ),
                ),
                child: Text(
                  (session?.isStaff ?? false) 
                      ? 'ADMINISTRADOR' 
                      : (session?.isTeacher ?? false)
                          ? 'DOCENTE'
                          : 'ESTUDIANTE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (session?.isStaff ?? false) 
                        ? AppColors.accent 
                        : (session?.isTeacher ?? false)
                            ? AppColors.primaryLight
                            : AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Navigation Options
            Card(
              child: Column(
                children: [
                  if (authProvider.isStudent) ...[
                    ListTile(
                      leading: const Icon(Icons.school_outlined, color: AppColors.primaryLight),
                      title: const Text('Mis Cursos Inscritos', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/orders'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primaryLight),
                      title: const Text('Mi Lista de Deseos', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/wishlist'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryLight),
                      title: const Text('Carrito de Compras', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/cart'),
                    ),
                  ],
                  
                  // Teacher options
                  if (authProvider.isTeacher && !authProvider.isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.class_outlined, color: AppColors.primaryLight),
                      title: const Text('Cursos que Imparto (Docente)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/teacher/courses'),
                    ),
                  ],
                  
                  // Admin options
                  if (authProvider.isAdmin) ...[
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent),
                      title: const Text('Panel de Administración (Cursos)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/courses'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.category_outlined, color: AppColors.accent),
                      title: const Text('Panel de Administración (Categorías)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/categories'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.people_outline, color: AppColors.accent),
                      title: const Text('Panel de Administración (Usuarios)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/users'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined, color: AppColors.accent),
                      title: const Text('Auditoría de Matrículas (Admin)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/orders'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Logout
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada correctamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('CERRAR SESIÓN'),
            ),
          ],
        ),
      ),
    );
  }
}
